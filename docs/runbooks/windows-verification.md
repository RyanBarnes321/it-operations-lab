# Windows verification — pending execution

Run on the Windows desktop in **PowerShell 7** (`pwsh`), as a normal user. No
Windows service, firewall, execution-policy, or system configuration changes are
required. If PowerShell 7 is absent, report that prerequisite; installation needs
separate user approval. Do not substitute Debian execution as Windows evidence.

Download only these source files over the existing LAN SSH connection:

```powershell
$work = Join-Path $HOME 'it-lab-verification'
New-Item -ItemType Directory -Force "$work\automation\powershell", "$work\tests" | Out-Null
scp dell-lab@192.0.2.10:/opt/it-operations-lab/automation/powershell/Test-LabEndpoint.ps1 "$work\automation\powershell\"
scp dell-lab@192.0.2.10:/opt/it-operations-lab/tests/Verify-Windows.ps1 "$work\tests\"
Set-Location $work
pwsh -NoProfile -File .\tests\Verify-Windows.ps1 -EvidencePath .\windows-verification.json
$verificationExit = $LASTEXITCODE
"Verification exit code: $verificationExit"
Get-Content .\windows-verification.json
```

Verify the SSH host fingerprint through the already trusted connection; do not
accept unexpected host-key changes. Substitute the current private address if DHCP
has changed it. No credentials or secret backups are included in this transfer.

The runner checks the entire current diagnostic inventory (one script), parses
PowerShell syntax, and launches each test in its own child PowerShell process.
A temporary TCP/HTTP fixture binds **127.0.0.1 only**, uses an OS-assigned port,
and is stopped in finally. No administrator rights or URL ACL are needed. Cases:
success (0), reserved `.invalid` DNS failure (1), non-listening local TCP port (1),
HTTP 404 (1), zero/overflow ports (2), invalid host (2), invalid URL (2), file URL (2).
Raw diagnostic output is discarded; JSON records only case names, expected/actual
codes, version, timestamp and diagnostic source hash. No username, machine name,
address, credential or full filesystem path is recorded.

Expected runner exit: 0, nine cases with `passed: true`, syntaxPassed true. Exit 1
means at least one mismatch. Fixture/infrastructure errors abort and require review;
never manually edit evidence to turn a failure into a pass. Review the JSON before
sharing it. Return the JSON and runner exit code to close this release gate. Compare
the diagnostic SHA256 with `Get-FileHash` of the downloaded source. The fixture tests
script behavior, not connectivity to the Dell; tunnel health remains a separate
manual integration check below.

# Visual dashboard verification — pending browser inspection

Keep a separate Windows terminal open with:

```powershell
ssh -N -o ExitOnForwardFailure=yes -L 3000:127.0.0.1:3000 -L 9090:127.0.0.1:9090 dell-lab@192.0.2.10
```

Open `http://localhost:3000/d/dell-lab-overview`, sign in with the existing account,
select **Last 1 hour**, and allow two refreshes (30s). Confirm six visible panels:
CPU, memory, root filesystem, uptime, network receive/transmit and scrape health.
Percent panels must be in 0–100%; uptime must have duration units; network must use
bytes/sec with two labeled lines. Scrape health must show both original targets UP.
Check there are no panel errors or unexpected No data messages. Zero network traffic
is valid. Compare a value with Explore using the same query/time window; different
refresh instants may differ. Panel configuration, UID, source expressions and live
queries were checked automatically; those checks do not prove browser rendering.

Save a cropped dashboard screenshot with timestamp and a short pass/fail record,
excluding login fields, profile menu, browser account details and unrelated tabs.
Do not publish until reviewed. Close the SSH tunnel when finished. If local port
3000/9090 is occupied, resolve that locally or use alternative tunnel ports and update
the browser address. No host networking changes are needed.
