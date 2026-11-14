# Release checklist — v1.0.0 history and v1.0.1 completion

The original annotated `v1.0.0` tag is preserved. The successor retains only its
audited ancestry and freshly recreated later file changes. Publication requires
its own passing Linux/Windows CI and a fresh annotated `v1.0.1`; private lab CI is
historical. See [publication](PUBLICATION.md), [CI evidence](evidence/github-ci-verification.json)
and [patch notes](releases/v1.0.1.md). Lab results below retain original attribution.

| Gate | State | Evidence |
|---|---|---|
| Five-commit historical privacy rewrite | Passed; two historical blobs sanitized, meaningful sequence preserved | SECURITY.md; external protected recovery bundle and map |
| Complete history/object and metadata review | Passed; no matching remaining sensitive material; Git integrity verified | evidence/final-quality-audit.json; source privacy guard |
| Compose, Prometheus and three alert rules | Passed in final Codex session | scripts/validate.sh; tests/alerts.yml |
| Bash diagnostics and backup failures | 12 live diagnostic cases and 3 isolated failure-path cases passed | final-quality-audit.json; tests/backup-failures.sh |
| Current system observations | User reports seven targets UP, four probes successful, no alerts, healthy DB and four services running; Compose accepted | evidence/user-final-live.json; Nov 12 user-executed |
| Independent live health/access boundaries | Passed after approved socket access; same health counts, loopback ports, no exporter publication, dashboard HTTP 401 | evidence/final-quality-live.json; Codex-executed |
| Dashboard reproducibility | Six source panels, seven expressions; historical queries and current isolated restoration passed | dashboard JSON; final-quality-restore.json |
| Windows PowerShell diagnostics | Historical user-executed 9/9, exit 0; hosted Windows fixture also passed | evidence/user-verification.json; original runner JSON unavailable |
| Real alert exercise and failure simulations | Historical firing/recovery retained; HTTP/TCP/DNS simulations labeled | incident reports; target-down.json |
| Encrypted off-device and USB recovery | Passed per historical user report; matching original archive SHA-256 | user-verification.json; returned restore record |
| Updated isolated restoration harness | Passed final Codex regression; seven historical queries, cleanup, unchanged production | evidence/final-quality-restore.json |
| YAML/JSON, Bash syntax, Python AST, links, dashboard inventory | Passed locally | scripts/check-source.py; final-quality-audit.json |
| README, runbooks, provenance and limitations | Reviewed and updated | README; TEST-EVIDENCE.md; LIMITATIONS.md |
| Clean-checkout procedure | Documented/static review; separate clean-host rehearsal not performed | runbooks/installation.md |
| CI workflow | Successor Linux/Windows required before publication; results in CI evidence | .github/workflows/quality.yml; QUALITY.md |
| Visual screenshot | Historical user inspection accepted; image missing and omitted | TEST-EVIDENCE.md; no invented image |
| Final commit/clean tree | Final quality changes committed; hash/clean result reported in handoff | Git status, log and fsck |
| Historical v1.0.0 tag | Annotated tag exists at original reviewed commit; unchanged | releases/v1.0.0.md |
| Remote repository/push | Separate successor, validated privately before public visibility | PUBLICATION.md |

No remaining mandatory functional/security blocker was found. The missing screenshot,
raw historical Windows JSON and separate-host rehearsal are transparent
evidence limits; they are not claimed as completed tests.

Accepted v1.0 limits: manual encrypted-disk unlock after power loss, defective
battery, no automatic power restoration, centralized logging deferred, manual
backup scheduling, no guaranteed RPO/RTO and no independently verified geographically
separate offsite backup. Local-only alerting, exporter network-namespace scope and
manual disk/log capacity management also remain explicit in LIMITATIONS.md.
