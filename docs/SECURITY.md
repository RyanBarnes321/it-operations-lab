# Security review and publication hygiene

Final quality review: **2026-11-12, America/Montevideo** (UTC records extend into
Nov 13). This is a scoped source, configuration, history and live-boundary review,
not a vulnerability-free certification.

## Historical privacy cleanup

The starting checkout was clean at `444895fc0f5c6e103f20d6a6a8d64ac1c803d146`:
five commits, 69 reachable blobs and 41 trees, no remote or tag. Before changing
history, a complete Git recovery bundle was created and successfully verified
outside this repository, inside a mode-700 private directory; bundle mode is 600.
The original graph, refs, reflogs, local config, clean status, object inventory,
exact replacement specification and commit map are stored alongside it. These
private recovery artifacts are unpublished and must never be copied into a release.
They currently live in temporary local storage: retain them in user-controlled
private durable storage if long-term rollback is needed.

Two historical blobs in `runbooks/off-device-backup.md` and
`runbooks/windows-verification.md` contained the same unnecessary private LAN
address. The approved rewrite replaced it with documentation address `192.0.2.10`
in every affected revision. All five commits, their messages, author identities,
dates and ordering were preserved; the first three commit IDs were unchanged.
The fourth and fifth changed, yielding sanitized handoff HEAD
`3ee7829a39de27135f248c4827979fda615fcc3c` before the final quality commit.
Old refs/reflogs and unreachable objects were pruned from the publication repository.
The full private original remains recoverable only from the external bundle.

Every reachable commit/blob and the complete local object inventory were reviewed
again, including credential/private-key/token signatures, private addresses,
metadata, tracked paths and evidence. There are no binary screenshots or other
binary evidence blobs to redact. No matching credentials, personal operator email,
private-key material, sensitive archive/database/runtime content or remaining
private LAN address was found. Upstream maintainer contacts and container IDs in
historical evidence are diagnostic metadata, not operator identities. Standard
`/opt/it-operations-lab`, container paths, service DNS names, localhost, hardware
model and architecture information are intentional. Historical audit findings
remain labeled historical; stale object IDs in those records are not Git refs.

`.gitignore` excludes secret/runtime/backup directories, databases, key files,
bundles, encrypted archives and common archive formats. The recovery bundle is
outside the repository and cannot enter an ordinary project push. Ignore rules
are not protection against a deliberate force-add: review publication contents.
No other portfolio repository was modified. No remote, push or release tag was made.

## Effective deployment boundaries

- Final independent checks confirm Grafana `3000` and Prometheus `9090` bind only
  `127.0.0.1`; neither exporter publishes host ports. Access uses trusted SSH.
  Prometheus has no application authentication; local users remain trusted.
- Grafana disables anonymous access/signup and reads two local secret files.
  An unauthenticated dashboard API request returned HTTP 401; `/api/health` is
  intentionally accessible. No live secret value was displayed or collected.
- Secret/backup parents are mode 700. Mounted secret files are 444 so Grafana's
  unprivileged user can read their bind mounts while other host users cannot
  traverse the private parent. Compose file secrets are not encrypted storage.
- Services use memory ceilings and `no-new-privileges`; Blackbox also drops all
  capabilities and uses a read-only root filesystem. Node Exporter has host PID
  and read-only root visibility. Docker administrators and local root are trusted.
- Bridge networking does not isolate services from a compromised host. Exporter
  network counters are namespace-scoped, not verified host NIC traffic.

See [final live evidence](evidence/final-quality-live.json) and the
[quality audit](evidence/final-quality-audit.json). No service was restarted or
reconfigured during live validation. A separate restore regression started only
disposable test containers with restored copies, an internal network and no
published ports; production before/after state matched and cleanup succeeded.
No SSH, LUKS, firewall, Wi-Fi, boot or power configuration was changed.

## Backup and supply-chain boundaries

State archives contain credentials and Grafana state. Encrypt before export;
never publish plaintext, ciphertext, identities, passphrases, databases or volumes.
Checksums detect accidental corruption, not authenticity against an attacker who
can replace both files. Restore only trusted archives. The harness uses safe tar
data filtering, private temporary copies and unprivileged application containers;
checks remain active under Python optimization. Off-device storage is not verified
geographically separate offsite protection.

Images, Actions and the quality dependency use pinned version tags/versions, not
immutable digest/commit pins. No fresh image vulnerability scan or comprehensive
supply-chain attestation was performed. The automated privacy guard detects common
patterns; manual review is still required for encoded secrets, logs and screenshots.
No credential exposure was found in Git; this scan does not establish whether
secrets disclosed outside Git need rotation. A historical incident notes that
previously shared credentials were reportedly reset.

The local privacy/security hold is closed. CI has not yet run on GitHub and a
separate clean-host deployment remains untested; neither is represented as passed.
Report suspected exposure privately to the repository owner without pasting secrets.
