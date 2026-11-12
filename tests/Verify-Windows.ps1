# Requires PowerShell 7 on Windows; no administrator rights or installed services.
[CmdletBinding()]
param([string]$EvidencePath = (Join-Path $PWD 'windows-verification.json'))
$ErrorActionPreference = 'Stop'
if (-not $IsWindows -or $PSVersionTable.PSVersion.Major -lt 7) { throw 'Run in PowerShell 7 on Windows.' }
$root = Split-Path $PSScriptRoot -Parent
$scripts = @(Get-ChildItem (Join-Path $root 'automation/powershell') -Filter '*.ps1')
if ($scripts.Count -ne 1 -or $scripts[0].Name -ne 'Test-LabEndpoint.ps1') { throw 'Diagnostic inventory changed; extend test coverage first.' }
foreach ($file in @($scripts.FullName) + @($PSCommandPath)) {
    $tokens = $null; $errors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$tokens, [ref]$errors)
    if ($errors.Count) { throw "Syntax check failed: $(Split-Path $file -Leaf)" }
}
# The fixture binds only loopback. Port is allocated by Windows; no URL ACL needed.
$job = Start-Job -ScriptBlock {
    $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
    $listener.Start()
    Write-Output $listener.LocalEndpoint.Port
    try {
        while ($true) {
            $client = $listener.AcceptTcpClient()
            try {
                $stream = $client.GetStream(); $stream.ReadTimeout = 1500
                $buffer = [byte[]]::new(8192)
                $length = $stream.Read($buffer, 0, $buffer.Length)
                if ($length -gt 0) {
                    $request = [Text.Encoding]::ASCII.GetString($buffer, 0, $length)
                    $status = if ($request -match '^GET /ok ') { '200 OK' } else { '404 Not Found' }
                    $response = [Text.Encoding]::ASCII.GetBytes("HTTP/1.1 $status`r`nContent-Length: 2`r`nConnection: close`r`n`r`nOK")
                    $stream.Write($response, 0, $response.Length)
                }
            } catch { } finally { $client.Dispose() }
        }
    } finally { $listener.Stop() }
}
$results = [Collections.Generic.List[object]]::new()
try {
    $port = $null
    for ($i=0; $i -lt 50; $i++) {
        $value = @(Receive-Job $job -Keep)
        if ($value.Count) { $port = [int]$value[0]; break }
        if ($job.State -eq 'Failed') { throw 'Loopback fixture failed.' }
        Start-Sleep -Milliseconds 100
    }
    if (-not $port) { throw 'Loopback fixture startup timed out.' }
    # Reserve a second port without Listen: it has no accepting TCP service.
    $closed = [Net.Sockets.Socket]::new([Net.Sockets.AddressFamily]::InterNetwork, [Net.Sockets.SocketType]::Stream, [Net.Sockets.ProtocolType]::Tcp)
    $closed.Bind([Net.IPEndPoint]::new([Net.IPAddress]::Loopback,0))
    $closedPort = $closed.LocalEndPoint.Port
    $ok = "http://127.0.0.1:$port/ok"
    $cases = @(
        @{ Name='success'; Expected=0; Args=@('-ComputerName','127.0.0.1','-Port',"$port",'-Url',$ok) },
        @{ Name='dns-failure'; Expected=1; Args=@('-ComputerName','lab-test.invalid','-Port',"$port",'-Url',$ok) },
        @{ Name='tcp-refused'; Expected=1; Args=@('-ComputerName','127.0.0.1','-Port',"$closedPort",'-Url',$ok) },
        @{ Name='http-404'; Expected=1; Args=@('-ComputerName','127.0.0.1','-Port',"$port",'-Url',"http://127.0.0.1:$port/missing") },
        @{ Name='port-zero'; Expected=2; Args=@('-Port','0') },
        @{ Name='port-overflow'; Expected=2; Args=@('-Port','65536') },
        @{ Name='invalid-host'; Expected=2; Args=@('-ComputerName','bad host') },
        @{ Name='invalid-url'; Expected=2; Args=@('-Url','not-a-url') },
        @{ Name='file-url'; Expected=2; Args=@('-Url','file:///C:/Windows/win.ini') }
    )
    foreach ($case in $cases) {
        $arguments = $case.Args
        # Child process contains diagnostic exit; discard raw output (addresses/errors).
        & (Join-Path $PSHOME 'pwsh.exe') -NoProfile -File $scripts[0].FullName @arguments *> $null
        $actual = $LASTEXITCODE
        $results.Add([pscustomobject]@{script=$scripts[0].Name; case=$case.Name; expected=$case.Expected; actual=$actual; passed=($actual -eq $case.Expected)})
    }
    $record = [ordered]@{timestamp=[DateTime]::UtcNow.ToString('o'); platform='Windows'; powershell=$PSVersionTable.PSVersion.ToString(); diagnosticSha256=(Get-FileHash $scripts[0].FullName -Algorithm SHA256).Hash; syntaxPassed=$true; tests=$results.ToArray()}
    $record | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $EvidencePath -Encoding utf8
    $results | Format-Table
    if (@($results | Where-Object { -not $_.passed }).Count) { exit 1 }
    exit 0
} finally {
    if ($closed) { $closed.Dispose() }
    Stop-Job $job; Remove-Job $job -Force
}
