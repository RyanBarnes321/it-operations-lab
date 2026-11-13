# IT Operations & Automation Lab

A practical Debian and Docker operations portfolio: provision host monitoring,
diagnose DNS/TCP/HTTP failures, investigate incidents, test alerts, and recover
Grafana and Prometheus from an encrypted off-device backup.

The lab runs on a Dell i5-7200U with 15 GiB RAM and SSD storage. It complements
the author's Service Desk API and AI Document Processing API projects by showing
the operational work around backend software: service health, Linux permissions,
network troubleshooting, controlled changes, recovery, and evidence-based handoffs.
Those applications are separate projects; neither is deployed or integrated here.

**v1.0.0 handoff:** functional acceptance evidence is recorded, including
user-executed Windows and recovery tests. Local release tagging is held for
historical LAN-address sanitization and final live validation from an authorized
host session. Nothing has been published. See the [release checklist](docs/RELEASE-CHECKLIST.md)
and [draft release notes](docs/releases/v1.0.0.md).

## What is implemented

| Component | Pinned version | Purpose |
|---|---|---|
| Grafana | 13.3.1 | Provisioned six-panel dashboard; authenticated access |
| Prometheus | 2.55.1 | 15-second scraping/evaluation; 15-day metric retention |
| Node Exporter | 1.8.2 | Host CPU, memory, disk, uptime and network metrics |
| Blackbox Exporter | 0.27.0 | HTTP and TCP availability probes |

Only Grafana and Prometheus publish host ports, on `127.0.0.1`. Access uses an
existing authenticated SSH tunnel. Exporters use the Compose network. The four
containers have a combined memory ceiling of 2 GiB; this is a configured bound,
not measured consumption. The host and Docker need additional memory.

The [architecture diagram](docs/architecture/overview.md) shows service and backup
flows. [Installation](docs/runbooks/installation.md) creates fresh credentials and
volumes without depending on the original Dell's identity or LAN address.

## Quick start

On a Linux host with Docker Engine and Compose v2, complete the fresh secret-file
setup in the [installation runbook](docs/runbooks/installation.md), then run:

```sh
docker compose config -q
docker compose up -d
./scripts/validate.sh
```

From an authorized workstation, substitute your own SSH account and host:

```sh
ssh -N -o ExitOnForwardFailure=yes -L 3000:127.0.0.1:3000 -L 9090:127.0.0.1:9090 '<lab-user>@<lab-address>'
```

Open `http://localhost:3000/d/dell-lab-overview` and sign in with the fresh Grafana
admin password. Prometheus is at `http://localhost:9090`. Never publish these ports
to the LAN or Internet to make access easier.

## Demonstrated skills and evidence

- **Linux and Docker operations:** private service networking, secret-file mounts,
  persistent volumes, resource limits and provisioning permission diagnosis.
- **Observability:** PromQL, seven dashboard expressions across six panels, seven
  scrape targets, four probes, and deterministic tests of three alert rules.
- **Automation:** Bash and PowerShell diagnostics with documented exit codes,
  bounded network checks and negative-input coverage.
- **Incident response:** a historical Grafana permission failure, isolated
  HTTP/TCP/DNS simulations, and an actual controlled exporter failure/recovery.
- **Recovery:** consistent state archives, checksums, encryption and isolated
  application restoration with production-state comparisons.

The user reports **9/9 Windows PowerShell tests passed, exit 0**, an encrypted
Windows backup round trip with matching original SHA-256, successful isolated
restoration, and a tested passphrase-encrypted USB recovery identity. These were
user-executed checks, not Windows actions performed by the final Codex session.

The user's historical dashboard screenshot reportedly showed CPU ~2.28%, memory
~8.23%, root usage ~7.63%, uptime ~39 minutes, two displayed scrape targets UP,
and network receive/transmit measurements. These are historical observations.
**The screenshot file is missing from this checkout**; no image is fabricated or
embedded. Dashboard source and earlier API/query evidence are available.

See the [evidence index](docs/TEST-EVIDENCE.md), [monitoring guide](docs/MONITORING.md),
[automation guide](docs/AUTOMATION.md), [incident reports](docs/incidents/),
[operations runbook](docs/runbooks/operations.md), and
[off-device recovery procedure](docs/runbooks/off-device-backup.md).

## Scope and limitations

This is a single-host lab, with a defective battery and manual LUKS unlocking after
power loss. Automatic power restoration is not implemented. Backups are manual and
off-device, with no independently verified offsite copy or guaranteed RPO/RTO.
Centralized logging and external alert delivery are deferred. Local privileged
users and Docker administrators remain trusted.

Read the [security overview](docs/SECURITY.md), [complete limitations](docs/LIMITATIONS.md),
[future roadmap](docs/ROADMAP.md), and [implementation record](docs/PROGRESS.md).
No continuous-uptime, enterprise disaster-recovery or vulnerability-free claim is made.

Licensed under [MIT](LICENSE).
