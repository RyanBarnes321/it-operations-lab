# v1.0.0 release checklist

Assessment: **local handoff prepared; release tag and publication held**.
Reviewed 2026-11-12 America/Montevideo (UTC evidence continues into Nov 13).
Starting HEAD verified as `da25c7377cd0faabb260dbd2b5d7d9c2729490e8`.
No remote exists. No `v1.0.0` tag conflict was found; no tag was created.

| Gate | State | Evidence/action |
|---|---|---|
| Six-panel dashboard configuration, seven expressions | Passed source review; historical live queries passed | dashboard-rc-audit.json; MONITORING.md |
| Windows PowerShell diagnostics | Passed, user-executed 9/9, exit 0 | user-verification.json; raw runner JSON unavailable |
| Visual dashboard inspection | Passed per user report; screenshot artifact unavailable | Historical observations in user-verification.json; do not fabricate image |
| Grafana database, provisioning, dashboard and seven historical restored queries | Passed user-executed returned-archive drill; existing record reviewed | grafana-restore-verification.json; production snapshots match; cleanup true |
| Encrypted off-device round trip and original archive integrity | Passed per user report | Exact archive and original SHA-256 match; not a Codex Windows transfer |
| Independent protected recovery identity | Passed per user report | Passphrase-encrypted USB copy used to decrypt backup; matching SHA-256; safe storage confirmed |
| Prior local config/state recovery and encryption tamper test | Passed historical evidence | config-restore.json; state-restore.json; backup-encryption-drill.json |
| Three alert rules, Bash diagnostics and incident accuracy | Passed historical tests/review | release-candidate-audit.json; tests/alerts.yml; actual exporter exercise; labeled simulations |
| Compose and source validation | Passed final-session checks | final-handoff-audit.json; shell syntax, AST and JSON checks |
| Final live validation and effective private/authenticated access | **Blocked by session socket permissions** | Trusted local operator must run scripts/validate.sh, verify loopback bindings/no exporter host ports and unauthenticated dashboard HTTP 401 |
| Full local history/security audit | **Publication hold** | No matching secret material found; unnecessary private LAN address remains in historical runbooks; current instructions sanitized |
| Historical sanitization and repeat audit | **Requires explicit history-rewrite decision** | See SECURITY.md; do not publish original refs/history |
| Professional docs, installation, evidence, security, limits and roadmap | Prepared | README; docs guides/runbooks; fresh-host procedure not independently rehearsed |
| Release notes and version identifier | Prepared, draft v1.0.0 | releases/v1.0.0.md; no application/package version manifest |
| Final local commit and clean tree | Recorded in final handoff commit | Documentation and non-sensitive evidence committed; working tree checked after commit |
| Local annotated v1.0.0 tag | **Held until mandatory gates pass** | Recheck conflict after sanitization; procedure in release notes |
| GitHub repository creation/push | **Not authorized** | Separate explicit user authorization required after security hold closes |

The screenshot and raw Windows JSON are missing artifacts, not invented failures
of the user-executed tests. Results are accepted at their reported provenance level;
no Codex visual or Windows execution claim is made.

The defective battery, manual LUKS unlock, absence of automatic power restoration,
deferred centralized logging, lack of independently verified offsite storage and
manual backups with no guaranteed RPO/RTO are accepted lab limitations, not new
infrastructure tasks or automatic v1.0 blockers. Full inventory: LIMITATIONS.md.

After history remediation, retain sanitized audit results, rerun non-disruptive
live validation, update this checklist and release notes, commit, verify a clean
working tree, and create the local tag. Do not repeat historical outages or change
SSH, LUKS, Wi-Fi, firewall, boot configuration or unrelated applications.
