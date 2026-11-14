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
At that review, the hosted workflow had not run; no passing CI claim was added.

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

## Hosted CI and privacy-clean publication — 2026-11-13 local date

The original private lab's hosted Linux run exposed a Grafana startup connection
reset. Bounded readiness polling fixed it; private Linux and Windows CI then passed.
Historical recovery results above remain attributed and were not rerun.

The owner authorized a separate public successor because later private Git metadata
contained unnecessary personal information. Only `v1.0.0` and its six-commit ancestry
were fetched into a fresh local repository. The subsequent file diff was recreated
with a verified GitHub noreply identity, and its tree exactly matched the reviewed
private tree before publication documentation was updated. No old post-v1.0.0
commits, PR refs, release tags or private recovery material were imported.

The original repository is retained privately. The successor is validated privately
before release and public visibility. Its first main run passed Linux and Windows. Final main/tag runs are checked
again before release/public visibility. Its own results and provenance
are recorded in [CI evidence](evidence/github-ci-verification.json),
[publication](PUBLICATION.md) and [v1.0.1 notes](releases/v1.0.1.md).

The screenshot remains unavailable and optional. A separate clean-host rehearsal,
fresh vulnerability scan, ShellCheck, reboot and power-recovery test remain unperformed.
Accepted operational limits are unchanged; see [limitations](LIMITATIONS.md).
