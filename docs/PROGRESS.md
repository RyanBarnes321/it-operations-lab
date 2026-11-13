# Persistent implementation record — final v1.0.0 handoff

Updated 2026-11-12 America/Montevideo (UTC checks continue into Nov 13).
Verified starting HEAD: `da25c7377cd0faabb260dbd2b5d7d9c2729490e8`.
The existing modified returned-archive restore JSON was reviewed and preserved.
No remote exists; no publication, host changes or new infrastructure was performed.

## Completed acceptance evidence

- Historical live audit: pinned four-service stack, private bindings, seven targets
  UP, four probes successful, no active alerts, six provisioned panels with seven
  instant and seven one-hour range queries nonempty. Values are historical.
- Historical Compose/Prometheus/rule validation and twelve Bash cases passed.
  All three alert rules test delay, firing and recovery. The real exporter exercise
  and accurately labeled HTTP/TCP/DNS simulations remain in incident evidence.
- User reports Windows PowerShell execution: nine of nine tests passed, exit 0;
  success, DNS failure, TCP refusal, HTTP 404 and invalid input behavior covered.
  Final Codex session did not run Windows. Original runner JSON is absent.
- User reports six working Grafana panels through an SSH tunnel: CPU ~2.28%, RAM
  ~8.23%, root ~7.63%, uptime ~39 minutes, two displayed targets UP and network RX/TX.
  These are historical screenshot observations. Screenshot file is missing here.
- User reports encrypted Windows round trip, original SHA-256 and exact-byte match.
  Existing returned restore JSON records database health, provisioning, six panels,
  seven historical queries, cleanup and unchanged production. Codex reviewed the
  record; it did not independently transfer or decrypt the returned archive.
- User reports passphrase-encrypted USB identity recovery, successful backup
  decryption and matching plaintext archive SHA-256; safe storage confirmed.
  No private identity or passphrase was inspected, copied, displayed or collected.

See [test evidence](TEST-EVIDENCE.md) for provenance and historical scope.

## Final local checks and documentation

Compose syntax, all five shell files individually, Python restore-harness AST,
evidence JSON and Git integrity pass. Dashboard source matches the six-panel/seven-
expression description, including the deliberately two-target scrape-health panel.
Secret/backup parent permissions and ignore rules were checked without reading
private data. Documentation now covers fresh installation with independent secrets,
architecture, monitoring/alerts, automation, incident evidence, recovery, security,
limitations, roadmap and draft release notes.

The live validation command was attempted but Docker socket access was denied.
Loopback HTTP checks were also denied by the execution environment. No service was
restarted or reconfigured. Current effective bindings/authentication and health
therefore require a trusted local operator's validation; older results were not
relabeled as current. See evidence/final-handoff-audit.json.

## Security finding and release disposition

All 51 starting Git blobs and four commits were scanned (complete local object
inventory, refs/reflogs included); no credential/private-key/token patterns or
tracked sensitive backup/runtime data were found. Historical runbooks do contain
the original private LAN address. Current files now use placeholders, but history
still exposes it. Publication is stopped pending an approved history rewrite and
repeat audit. Commit identities were not rewritten without an explicit decision.
Full scope and remediation: [security overview](SECURITY.md).

**v1.0.0 is prepared but not release-ready or tagged.** No tag conflict existed.
After approved historical sanitization and final live checks, update the checklist
and release notes, commit the result, and create the local annotated tag. No package
version manifest exists; draft release documents use the planned `v1.0.0` identifier.
Creating a remote or pushing still requires explicit user authorization.

Accepted limits remain: manual LUKS unlocking, defective battery, no automatic
power restoration, deferred centralized logging, no independently verified offsite
backup, manual backup cadence and no guaranteed RPO/RTO. See LIMITATIONS.md.
