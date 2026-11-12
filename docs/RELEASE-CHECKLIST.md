# Proposed v1.0 release checklist

Assessment: **release candidate; not ready to mark v1.0 complete**.
Reviewed 2026-11-11 America/Montevideo (evidence timestamps use UTC).
No remote repository, push or release tag has been created.

| Gate | State | Evidence/action |
|---|---|---|
| Live private monitoring and six-panel provisioning | Passed API/query checks | dashboard-rc-audit.json |
| Grafana restored application startup and database | Passed | grafana-restore-verification.json |
| Restored data source, dashboard, real historical queries | Passed, seven queries | Same restore evidence; no live-volume writes |
| Test shutdown preserves production | Passed | Identical container IDs/start times/restarts; post-cleanup health |
| Compose, Prometheus config and three alert rules | Passed | release-candidate-audit.json; scripts/validate.sh |
| Alert delay, firing and recovery | Passed deterministic tests for all three rules | tests/alerts.yml; prior live TargetDown exercise retained |
| Bash diagnostics | Passed 12 checks | release-candidate-audit.json |
| Windows PowerShell diagnostics | **Pending** | Run tests/Verify-Windows.ps1 on Windows; return sanitized JSON and exit code |
| Visual six-panel dashboard inspection | **Pending** | Follow windows-verification.md; review cropped screenshot and record result |
| Configuration and application state local recovery | Passed within recorded scope | config-restore.json; state-restore.json; Grafana restore evidence |
| Backup encryption and tamper rejection | Passed local drill | backup-encryption-drill.json |
| Real independent backup and return-restore | **Pending** | Provide public age recipient, pull ciphertext to Windows, test recovery |
| Recoverable independent encryption identity copy | **Pending** | User confirms protected recovery copy without sharing private key |
| Git secret/history review | Passed scoped scan | Exact current secret values and selected token/key patterns; not a universal guarantee |
| Incident accuracy | Reviewed | Historical report attributed; HTTP/TCP/DNS simulated; exporter firing actual |
| Documentation and limitations | Updated | README, architecture, operations, progress and this checklist |
| Final evidence review and repository publication | Pending release decision | Approval required before remote creation/push/publication |

## Remaining limitations

- Power loss immediately stops the defective-battery laptop. No UPS, unattended
  power-on, verified reboot recovery or automatic LUKS unlock. No boot/encryption
  changes or reboot tests were performed. Restart policies apply only after boot.
- Single host and local SQLite/TSDB; no HA. DHCP address reservation is unconfirmed.
- Windows execution and actual browser rendering are not yet verified. The Windows
  runner itself has not executed on Windows; source review is not execution evidence.
- Backups remain on the Dell until Windows transfer is observed. Manual cadence,
  desktop availability, key recovery and retention are not operationally established;
  no RPO/RTO guarantees or offsite copy. Local state backup briefly stops Grafana and
  Prometheus. Uncatchable interruption requires manual recovery; capacity is checked
  by the operator. Partial failed archives must not be treated as valid generations.
- No scheduled backup/pruning. Proposed seven recent/four weekly retention is manual
  and must be confirmed against actual storage and successful recovery.
- No centralized logging or remote log retention. Docker log storage has no explicit
  per-service rotation policy in Compose. Memory is bounded but not total disk use;
  Prometheus retention is time-based and no byte cap is configured.
- Alerts are local Prometheus state only; no Alertmanager/notification delivery.
  Disk pressure is tested with synthetic rule input, not by filling the live SSD.
  HTTP/TCP/DNS one-shot simulations do not demonstrate a live ProbeFailed firing.
- Version tags are pinned but are mutable; observed image digests are evidence, not
  enforced digest pins. No image vulnerability scan or comprehensive supply-chain
  attestation review was performed. Existing images were not upgraded.
- Host PID/read-only root access for Node Exporter and Docker-administrator privileges
  remain security boundaries. Loopback access does not isolate local privileged users.
- The active session and protected backups are root-owned; normal `dell-lab` SSH cannot
  read plaintext backups. Export only encrypted copies with targeted permissions.
  Fresh-host secret readability/bootstrap is documented but not independently rehearsed.
- Stdlib Python 3 is used only for the restore/validation harness, not monitoring or
  diagnostic runtime. Restore ownership handling requires local administrative rights.
- No Service Desk API integration. Screenshots/demo material and remote publication
  are pending. No claim of continuous uptime, performance benchmarks or enterprise DR.

After the pending user checks, review the returned evidence, rerun non-disruptive
validation, update PROGRESS.md, and propose a v1.0 tag. Do not label the release
complete until these gates close. Do not create a remote or push without approval.
