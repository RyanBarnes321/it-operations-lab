# Implementation and release record

## Final security and portfolio pass — 2026-11-12 local date

Starting HEAD was `444895fc0f5c6e103f20d6a6a8d64ac1c803d146`; the tree was clean,
with five commits and no remote/tag. The user approved rewriting unpublished local
history. A verified, mode-600 full recovery bundle and graph/state snapshots were
created in a mode-700 directory outside the repository before rewriting. It is
private temporary recovery storage, excluded from publication; preserve it elsewhere
privately if durable recovery is needed.

Two historical runbook blobs contained an unnecessary private LAN address. Their
replacement uses a documentation address; all five commits remain, with author
metadata, messages and order preserved. Sanitized handoff HEAD became
`3ee7829a39de27135f248c4827979fda615fcc3c`. Old refs/reflogs/objects were pruned;
repeat object review and Git integrity checks passed. No other portfolio repository
was touched. See [security review](SECURITY.md).

The user's final live report is recorded as user-executed Nov 12 observations:
seven Prometheus targets UP, four probes successful, zero active alerts, healthy
Grafana DB, four services running and error-free Compose validation. Exact execution
time/raw output was not supplied. After approved access, Codex independently
verified those results, effective loopback bindings, no published exporter ports
and unauthenticated dashboard HTTP 401. No production restart was needed.

Codex reran Compose, promtool configuration and all three rule fixtures, twelve
Bash diagnostics and three new backup failure-path tests. Backup scripts now remove
incomplete outputs and Bash host diagnostics stop on command failures. The restore
harness now requires an explicit archive, streams SHA-256, supports an archive-specific
healthy timestamp, keeps checks active under Python optimization and writes ignored
runtime evidence by default. Its isolated regression passed with seven historical
queries, cleanup and identical production before/after state. This did not repeat
the Windows transfer or USB recovery test.

README now leads with monitoring, alert firing/recovery, the real Grafana permission
incident, cross-platform diagnostics and encrypted recovery. Detailed runbooks remain
linked. Exporter network counters are accurately scoped to bridge networking.
A source validator checks YAML/JSON, shell/Python syntax, local links, dashboard
inventory and reachable-history privacy patterns. GitHub Actions reuses the local
validation and Windows fixtures on disposable runners, without private dependencies.
The hosted workflow has not run; no passing CI badge or claim was added.

## Preserved historical acceptance

Historical evidence remains attributed: nine Windows tests passed per user report,
twelve Bash cases, actual exporter alert firing/recovery, isolated HTTP/TCP/DNS
simulations, local configuration/state recovery and encryption tamper rejection.
The user reports encrypted Windows backup return, original SHA-256 match, isolated
restoration and a successfully tested passphrase-encrypted USB recovery identity.
No private identity/passphrase was collected. The returned restore JSON was preserved.

The user's six-panel visual observations are historical; the screenshot and original
Windows runner JSON are missing. No image was invented. The earlier handoff's
socket restrictions and privacy holds remain in its immutable evidence record;
this pass resolves those holds with new evidence rather than relabeling old results.
See [test evidence](TEST-EVIDENCE.md).

## Release disposition

Ready for a local `v1.0.0` tag after the final quality commit and clean-tree check;
no tag or remote has been created. Hosted CI and a separate clean-host rehearsal
are pending evidence, not passed tests. No current Windows, ShellCheck, fresh
vulnerability scan, reboot or power-recovery test was performed.

Accepted limits remain manual LUKS unlock, defective battery, no automatic power
restoration, deferred centralized logging, manual backups, no guaranteed RPO/RTO
and no independently verified geographically separate offsite backup. Read the
[checklist](RELEASE-CHECKLIST.md), [release notes](releases/v1.0.0.md) and
[limitations](LIMITATIONS.md) before publication.
