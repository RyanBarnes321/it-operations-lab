# Requires PowerShell 7. Exit 0 success, 1 failed check, 2 invalid input.
[CmdletBinding()]
param(
    [string]$ComputerName = 'localhost',
    [int]$Port = 3000,
    [string]$Url = 'http://localhost:3000/api/health'
)
$ErrorActionPreference = 'Stop'
if ($Port -lt 1 -or $Port -gt 65535 -or $ComputerName -notmatch '^[a-zA-Z0-9][a-zA-Z0-9.:-]*$') { exit 2 }
$uri = $null
if (-not [Uri]::TryCreate($Url, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -notin @('http','https')) { exit 2 }
$client = [System.Net.Sockets.TcpClient]::new()
try {
    $addresses = [System.Net.Dns]::GetHostAddresses($ComputerName)
    Write-Output "DNS: $($addresses -join ', ')"
    $task = $client.ConnectAsync($ComputerName, $Port)
    if (-not $task.Wait(5000)) { throw 'TCP connection timeout' }
    $task.GetAwaiter().GetResult()
    Write-Output "TCP: $ComputerName`:$Port reachable"
    $response = Invoke-WebRequest -Uri $uri -TimeoutSec 10
    Write-Output "HTTP: $($response.StatusCode)"
    exit 0
} catch { Write-Error -ErrorAction Continue $_; exit 1 }
finally { $client.Dispose() }
