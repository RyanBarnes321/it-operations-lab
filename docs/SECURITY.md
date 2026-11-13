# Security overview and final local audit

Reviewed 2026-11-12 America/Montevideo (UTC evidence continues into Nov 13).
Starting HEAD: `da25c7377cd0faabb260dbd2b5d7d9c2729490e8`.

## Publication hold

The complete local object database at audit start contained four commits, 51 blobs
and 35 trees. All blobs and commit metadata were examined, including objects
discoverable outside the current checkout; refs and reflogs were included in path
mapping. `git fsck --full` passed. The review covered historical source changes,
evidence, tracked paths, ignore rules, credential/token patterns, private-key
markers, credential URLs/assignments, email addresses and private IPv4 addresses.
No matching private identity, authentication token, credential assignment, database
dump, archive, secret directory or runtime volume was found in committed content.
Email matches were upstream container-maintainer contacts in historical evidence,
not personal operator contact information. No tracked file was world-writable.
This is a scoped content/configuration review, not proof that every possible
secret encoding or vulnerability is absent. Private identities and passphrases
were not opened, copied or collected; live Grafana secret contents were not read.

**Finding:** historical `docs/runbooks/windows-verification.md` and
`docs/runbooks/off-device-backup.md` contain the original private LAN address.
It is unnecessary for reproduction. Current instructions now use placeholders,
but ordinary edits do not remove it from Git history. Publication is stopped.
There is no evidence from this scan that credentials need rotation.

Recommended remediation: authorize a local history rewrite replacing that address
in every affected revision. Preserve an access-restricted local recovery reference
outside the publication repository, review the rewritten changes, then repeat
the full-object and metadata audit. Do not include old refs, reflogs, backup refs,
bundles or audit snapshots in publication. Check the tag only after sanitization.
History was not rewritten during this handoff because it replaces existing commit
identities and needs an explicit decision. No remote is configured.

## Deployment boundaries

- Compose publishes Grafana `3000` and Prometheus `9090` only on loopback;
  exporters publish no host ports. Remote access requires an authenticated SSH
  tunnel. Prometheus has no application authentication; its boundary is SSH and
  host-local access. The monitoring bridge itself is not an air gap.
- Grafana disables anonymous access and signup and uses two mounted local secret
  files. Earlier API evidence records HTTP 401 for an unauthenticated dashboard
  request. Secret files are mode 444 inside a root-owned mode-700 directory so
  unprivileged containers can read their mounts while ordinary host users cannot
  traverse the parent. Never relax that parent or commit its contents.
- Services use memory ceilings and `no-new-privileges`; Blackbox also drops all
  capabilities and has a read-only root filesystem. Node Exporter uses host PID
  and a read-only root mount, which grants broad host visibility.
- Docker administration is privileged. Authenticated Grafana access does not
  protect against a compromised host, local root or a Docker administrator.
- `/secrets/`, `/backups/`, `/runtime/`, `.env`, database files and common private-key
  extensions are ignored. Ignore rules do not sanitize already tracked content.
  Actual secret and backup parent modes were checked as 700 without reading data.

Final-session `docker compose config -q` passed. Docker daemon access and loopback
HTTP sockets were denied by this session's execution environment, so current
bindings, effective authentication, container health and rule execution could not
be independently revalidated. Last live evidence is
[release-candidate-audit.json](evidence/release-candidate-audit.json), not a current
measurement. A trusted local operator must rerun `scripts/validate.sh` and verify
effective published bindings and unauthenticated dashboard HTTP 401 before tagging.
No host SSH, LUKS, Wi-Fi, firewall, boot configuration or service was changed.

## Backup and publication hygiene

State archives contain Grafana credentials/database and monitoring history; they
are sensitive even when integrity checks pass. Publish only sanitized result
records, never an archive, private identity, passphrase, database or runtime volume.
Encrypt before export. Keep the protected USB recovery identity and its passphrase
under user control. Off-device storage is not independently verified offsite.

Image tags are version-pinned but mutable. Historical image digests are evidence,
not enforced digest pins. No new image pull, vulnerability scan or supply-chain
attestation was performed. Report a suspected exposure privately to the repository
owner; do not paste secrets into a public issue.
