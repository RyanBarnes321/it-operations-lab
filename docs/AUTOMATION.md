# Bash and PowerShell automation

Diagnostics observe and report; they do not restart or repair services.
Both scripts return 0 for success, 1 for a failed check and 2 for invalid supported
arguments. Review diagnostic output before publication because it can contain
addresses, filesystem details or service metadata.

| Script | Usage | Dependencies and behavior |
|---|---|---|
| `automation/bash/diagnose.sh` | `host`, `docker`, `http URL`, `dns NAME`, `tcp HOST PORT` | Bash, curl, coreutils, getent; Docker access for docker mode |
| `automation/powershell/Test-LabEndpoint.ps1` | `-ComputerName HOST -Port PORT -Url URL` | PowerShell 7; performs DNS, TCP then HTTP checks |

```sh
./automation/bash/diagnose.sh host
./automation/bash/diagnose.sh docker
./automation/bash/diagnose.sh http http://127.0.0.1:3000/api/health
./automation/bash/diagnose.sh dns localhost
./automation/bash/diagnose.sh tcp localhost 3000
```

```powershell
pwsh -NoProfile -File automation/powershell/Test-LabEndpoint.ps1 -ComputerName localhost -Port 3000 -Url http://localhost:3000/api/health
pwsh -NoProfile -File tests/Verify-Windows.ps1
$LASTEXITCODE
```

Bash host mode reports RAM/disk and checks available memory >10% and root use <85%.
Docker mode checks that the four project services are running; it is not a
container healthcheck or application test. HTTP mode uses curl failure status,
3-second connection and 10-second total deadlines; DNS uses host resolver behavior;
TCP has a 5-second deadline. Host and port inputs are validated and passed as
arguments, not interpolated commands. Resolver and Docker calls have their own
runtime behavior; there is no script-wide timeout.

PowerShell validates ports, hostname format and HTTP(S) URL, resolves DNS, waits
up to five seconds for TCP and uses a 10-second HTTP timeout. Its host/port and URL
are independent inputs; check they describe the intended endpoint. Defaults assume
an existing local Grafana tunnel. It reports errors rather than silently repairing.

`tests/diagnostics.sh` covers twelve Bash success, failure and input cases against
the local lab. The Windows runner uses its own temporary loopback fixture and
separate child processes, tests nine cases, parses source syntax and writes a
sanitized JSON result. The user reports all nine passed with exit 0; original
runner JSON is absent. See [test evidence](TEST-EVIDENCE.md) for attribution.

`scripts/validate.sh` validates Compose, Prometheus configuration, three alert
rules, each shell file's syntax, and Bash diagnostics. It needs live Docker access;
the earlier handoff was denied daemon access. The final quality pass obtained
authorized access and passed the suite, including three new backup failure-path
checks. Historical results remain separate evidence.

Backup scripts are maintenance tools with different effects: `backup-config.sh`
archives source only; `backup-state.sh --allow-service-stop` briefly stops Grafana
and Prometheus. The Python restore harness creates disposable isolated containers,
reads restored Grafana credentials internally, requires an explicit archive path,
and writes an ignored runtime result only on successful completion. New archives
need an appropriate `--evaluation-time` within their TSDB samples. Checks remain
active under Python optimization; SHA-256 hashing streams the archive. It does not transfer a Windows backup. Consult the
[operations](runbooks/operations.md) and [off-device backup](runbooks/off-device-backup.md)
runbooks before using them.

[Quality checks](QUALITY.md) explains source validation and the unexecuted GitHub
Actions workflow. ShellCheck and a current Windows run were not performed in this
Linux session. DNS and Docker commands rely on their own runtime behavior.
