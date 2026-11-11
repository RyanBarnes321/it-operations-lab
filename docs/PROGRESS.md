# Persistent implementation record — 2026-11-11

A: Verified existing provisioned six-panel dashboard through authenticated Grafana
API, correct datasource UID and seven nonempty real queries. JSON parsed; Grafana
accepted provisioning YAML. Existing config modes 644, directories traversable.
No Grafana restart or credential change required. Browser visual check pending.

B: README, architecture, runbook and historical permissions incident written.
Local Git foundation being established; remote creation/publication not authorized.

C: Blackbox 0.27.0 deployed privately, 128 MiB cap. HTTP and TCP jobs and three
alert rules installed. Compose, promtool syntax and synthetic probe alert
pending/firing/recovery tests passed. Controlled exporter stop exercised separately.
No Alertmanager or outbound notifications deployed.

D: Bash diagnostic CLI and 12 runtime checks passed. PowerShell CLI implemented;
PowerShell unavailable on host, Windows execution remains unverified.

E: Loki/Alloy deferred. Local Docker logs support investigations but no centralized
log retention is claimed. Prefer completing existing operational capabilities before
adding another stateful system and Docker log access privileges.

F: Configuration-only backup and isolated restore drill implemented. No protected
off-device destination or application-state restore verified; no backup scheduling
installed. HTTP, TCP and DNS isolated failure reports plus historical Grafana report
written. Separate live TargetDown evidence retained.

G: Release remains incomplete: PowerShell execution, full application-state backup
and restore, independent backup destination, visual dashboard evidence and final
reproducibility review remain. No existing API integration attempted. No host
networking, SSH, boot, LUKS, power settings or unrelated services changed.

Next session: read this record, README and evidence; inspect live state first. Do
not repeat dashboard installation or rotate credentials. Finish outstanding gates
before claiming the first portfolio release. Local Git only; ask before remote creation.
