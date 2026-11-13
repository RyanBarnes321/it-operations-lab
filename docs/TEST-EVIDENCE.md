# Test and verification evidence

Results below distinguish historical tool output, user reports and checks actually
performed by the final Codex session. A timestamp in an old JSON record is not a
claim about current health. No outage, backup transfer or production restore was
repeated for this handoff.

| Verification | Result and provenance | Artifact |
|---|---|---|
| Grafana health and panel expressions | Historical API evidence; six panels, seven queries | [dashboard-validation.json](evidence/dashboard-validation.json) |
| Dashboard configuration and range queries | Historical audit; seven instant and one-hour range queries nonempty | [dashboard-rc-audit.json](evidence/dashboard-rc-audit.json) |
| Windows diagnostics | User-executed `pwsh -NoProfile -File .\tests\Verify-Windows.ps1`; 9/9 passed, exit 0 | [User report record](evidence/user-verification.json); original runner JSON absent |
| Visual dashboard | User reports six functioning panels through SSH; screenshot observations recorded as historical | [User report record](evidence/user-verification.json); image artifact missing |
| Compose, Prometheus, alert rules, Bash | Historical passing live validation; twelve Bash cases and three rules with delay/firing/recovery tests | [release-candidate-audit.json](evidence/release-candidate-audit.json), [rule fixtures](../tests/alerts.yml) |
| Final source/configuration checks | Compose config, all shell syntax, Python AST, JSON parsing, documentation links and Git integrity | [final-handoff-audit.json](evidence/final-handoff-audit.json) |
| Final live checks | Attempted, blocked by Docker socket and loopback socket permissions; no live result inferred | [final-handoff-audit.json](evidence/final-handoff-audit.json) |
| HTTP/TCP/DNS failures | Historical isolated Blackbox probes; no production target mutation or alert-delivery claim | [isolated-probes.json](evidence/isolated-probes.json), [incident reports](incidents/) |
| Live TargetDown exercise | Historical stopped-exporter firing and recovery | [target-down.json](evidence/target-down.json), [final-state.json](evidence/final-state.json) |
| Configuration recovery | Historical same-disk drill, 27 files identical | [config-restore.json](evidence/config-restore.json) |
| State integrity and initial TSDB recovery | Historical SQLite integrity and isolated Prometheus query; scope predates full Grafana test | [state-restore.json](evidence/state-restore.json) |
| Encryption drill | Historical local SHA-256 round trip and tamper rejection; Windows booleans reflect that earlier scope | [backup-encryption-drill.json](evidence/backup-encryption-drill.json) |
| Returned Windows backup restoration | User-executed round trip, reported exact archive/hash match; returned restore record reviewed, seven historical queries and unchanged production | [grafana-restore-verification.json](evidence/grafana-restore-verification.json) |
| USB recovery identity | User reports passphrase-encrypted copy, successful backup decryption, matching SHA-256 and safe storage | [User report record](evidence/user-verification.json); no identity/passphrase collected |

The modified `grafana-restore-verification.json` was already present at handoff.
Its archive identifier is `returned-state.tar.gz`; timestamp is
`2026-11-12T22:55:02.675775+00:00`. This session reviewed and retained it without
rerunning the drill or changing its contents. Before/after production snapshots
match, Grafana database health is `ok`, six provisioned panels and seven nonempty
historical query results are recorded, and cleanup is true. The earlier same-disk
Grafana drill remains available in commit `38637e3ce15d718e290fb10f7ef863a352b90c0d`.
The JSON alone does not prove the Windows transfer; that claim is user-attributed.

The visual observation record reports CPU ~2.28%, RAM ~8.23%, root usage ~7.63%,
uptime ~39 minutes, both displayed scrape targets UP and receive/transmit data.
Capture time and raw Windows runner JSON were not supplied. Recording dates and
current source hashes must not be substituted for those missing artifacts.

Original historical JSON records remain unchanged except the pre-existing returned
restore result, which is included with its provenance above. Earlier `false` or
"not tested" fields describe the scope at their recorded time; later reports do
not retroactively change those results. A future screenshot should be cropped and
reviewed for account, network and credential details before inclusion.

## Final security and quality pass — 2026-11-12 local date

The earlier handoff audit and its socket/publication holds above describe that
recorded session. The final pass supersedes those holds without editing the old
evidence. UTC recording timestamps may be Nov 13 (America/Montevideo is UTC−03).

| Check | Result and provenance | Artifact |
|---|---|---|
| User final live checks | User-executed Nov 12: seven targets UP, four probes successful, no active alerts, healthy Grafana DB, four services running, Compose config accepted; exact execution time/raw output absent | [user-final-live.json](evidence/user-final-live.json) |
| Independent final live checks | Codex, after authorized socket access: same health counts, loopback-only published ports, no exporter host ports, unauthenticated dashboard HTTP 401 | [final-quality-live.json](evidence/final-quality-live.json) |
| Updated validation suite | Codex: Prometheus configuration, three alert-rule delay/firing/recovery tests, twelve Bash cases and three backup failure-path cases passed | [final-quality-audit.json](evidence/final-quality-audit.json) |
| Updated isolated restore harness | Codex regression against the existing local archive; no new Windows transfer or USB test | [final-quality-restore.json](evidence/final-quality-restore.json) |
| Source and privacy checks | YAML/JSON, shell syntax, Python AST, local file links, dashboard inventory and full reachable-history privacy guard; complete object review and Git integrity | [final-quality-audit.json](evidence/final-quality-audit.json) |
| GitHub Actions | Added, no real workflow run yet; no passing CI claim | [quality workflow](../.github/workflows/quality.yml) |

No separate clean-machine deployment, current Windows execution, fresh vulnerability
scan, ShellCheck run, power-recovery test or new screenshot was performed. Network
throughput evidence reflects the exporter bridge namespace; it does not establish
physical host NIC throughput. Historical restoration evidence remains historical.
