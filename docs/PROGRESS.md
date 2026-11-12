# Persistent implementation record — release candidate

Updated 2026-11-11 America/Montevideo. Evidence uses UTC (some timestamps Nov 12).
Starting commit for this continuation: fd47545. Local repository only; no remote
creation/push/publication authorized. Read README and RELEASE-CHECKLIST.md next.

## Verified existing functionality

- Production Grafana/Prometheus/Node Exporter/Blackbox retain their pinned versions,
  memory limits, restart policies and private port bindings. No new monitoring
  component added. Seven targets UP, four probes successful, no active alerts at audit.
- Six-panel Dell Lab Overview provisioned with datasource UID prometheus. All seven
  live instant queries and seven one-hour range queries nonempty; correct source
  expressions, time range, refresh, panel types and units reviewed. Browser rendering
  remains **pending**. See dashboard-rc-audit.json.
- Compose and Prometheus/rule syntax pass. Shell syntax validation was corrected to
  check each script individually (bash -n accepts only one script filename). Three alert rules have deterministic
  delay/firing/recovery tests. Twelve Bash diagnostics pass. Prior real TargetDown
  exercise and incident evidence retained without repeating service interruption.
- Historical Grafana permissions incident remains attributed to the handoff;
  HTTP/TCP/DNS reports are isolated simulations, not alert-delivery demonstrations.

## Closed: Grafana restored application verification

The existing lab-state-PlVe4Kg0.tar.gz checksum was verified, restored into disposable
copies, and started as unprivileged Grafana and Prometheus on a dedicated internal
network, no published ports or production volume mounts. Restored Grafana database
health, datasource, provisioned dashboard and seven historical panel queries passed.
Test containers/network were removed. Production IDs, start times, restart counters
and running state were unchanged, and post-cleanup Grafana health passed.

See scripts/verify-grafana-restore.py, the operations runbook and evidence
`grafana-restore-verification.json`. Initial test attempts caught ownership dropped
by safe extraction; only disposable restored files were assigned appropriate UIDs.
Historical queries use the earlier recorded healthy snapshot, avoiding a gap from
the original outage exercise. No production permissions or credentials changed.

## Pending user verification

1. Execute tests/Verify-Windows.ps1 in PowerShell 7 **on Windows**. Nine safe test
   cases cover the sole diagnostic script. Return sanitized JSON and runner exit.
2. Inspect dashboard in a browser through the SSH tunnel; return a cropped reviewed
   screenshot and result. Exact steps: docs/runbooks/windows-verification.md.
3. Establish encrypted independent backup: docs/runbooks/off-device-backup.md.
   Portable age v1.3.2 downloaded only under ignored runtime; official release asset
   digest checked. Local existing-backup encrypt/decrypt SHA256 roundtrip and tamper
   rejection passed; temporary keys/plaintext removed. Windows public recipient,
   off-device transfer, independent key recovery copy and return-restore remain
   **pending**. No Windows services/system settings changed, no plaintext exported.

## Audit and release status

Scoped historical Git scan found no current secret values or selected private-key,
GitHub-token or AWS-key markers in prior blobs; no runtime/secrets/backups tracked.
Live image digests, memory limits, private bindings and validation results recorded
in release-candidate-audit.json. This is not a universal secret/vulnerability audit.
README/architecture/operations updated; comprehensive limitations and proposed gates
are in RELEASE-CHECKLIST.md. Logging remains deferred; offsite protection is absent.

**v1.0 is not complete.** Resume with the pending user evidence; do not reinstall
working services, repeat historical outages, alter host network/SSH/boot/LUKS or
publish remotely. No reboot, volume deletion or production restore was attempted.
