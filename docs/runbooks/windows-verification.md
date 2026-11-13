# Windows verification — repeatable procedure

The user reports `pwsh -NoProfile -File .\tests\Verify-Windows.ps1` completed
with nine of nine cases passed and exit 0. This final session did not execute on
Windows; original runner JSON is not present. See [evidence](../TEST-EVIDENCE.md).
The following procedure supports repeat verification.

Run on the Windows desktop in **PowerShell 7** (`pwsh`), as a normal user. No
Windows service, firewall, execution-policy, or system configuration changes are
required. If PowerShell 7 is absent, report that prerequisite; installation needs
separate user approval. Do not substitute Debian execution as Windows evidence.

Download only these source files over the existing LAN SSH connection:

```powershell
$work = Join-Path $HOME 'it-lab-verification'
New-Item -ItemType Directory -Force "$work\automation\powershell", "$work\tests" | Out-Null
scp '<lab-user>@<lab-address>:/opt/it-operations-lab/automation/powershell/Test-LabEndpoint.ps1' "$work\automation\powershell\"
scp '<lab-user>@<lab-address>:/opt/it-operations-lab/tests/Verify-Windows.ps1' "$work\tests\"
Set-Location $work
pwsh -NoProfile -File .\tests\Verify-Windows.ps1 -EvidencePath .\windows-verification.json
$verificationExit = $LASTEXITCODE
"Verification exit code: $verificationExit"
Get-Content .\windows-verification.json
```

Verify the SSH host fingerprint through the already trusted connection; do not
accept unexpected host-key changes. Replace `<lab-user>` and `<lab-address>` with your own trusted SSH account
and destination; no original Dell address is required. No credentials or secret backups are included in this transfer.

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
sharing it. For a repeated run, retain reviewed JSON and the runner exit code. Compare
the diagnostic SHA256 with `Get-FileHash` of the downloaded source. The fixture tests
script behavior, not connectivity to the Dell; tunnel health remains a separate
manual integration check below.

# Visual dashboard verification — reported complete; image unavailable

The user reports six functioning panels through the SSH tunnel: CPU ~2.28%,
memory ~8.23%, root usage ~7.63%, uptime ~39 minutes, both displayed targets UP,
and network receive/transmit measurements. These are historical screenshot
observations, not current measurements. The screenshot cannot be retrieved from
this checkout; do not embed a substitute or claim Codex viewed it.

For a repeated inspection, keep a separate Windows terminal open with:

```powershell
ssh -N -o ExitOnForwardFailure=yes -L 3000:127.0.0.1:3000 -L 9090:127.0.0.1:9090 '<lab-user>@<lab-address>'
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
