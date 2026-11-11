# IT Operations & Automation Lab

A permanently hosted Debian/Docker lab built to practice monitoring, Linux operations,
troubleshooting, and incident response alongside two application engineering portfolio projects.
Runs on a Dell i5-7200U with 15 GiB RAM and SSD storage. This is a single host,
not a high availability system.

## Current implementation

Prometheus 2.55.1 collects host metrics from Node Exporter 1.8.2 every 15 seconds.
Grafana 13.3.1 provisions Dell Lab Overview from JSON: CPU, memory, root disk,
network receive/transmit, uptime and scrape health. Blackbox Exporter 0.27.0 probes
Grafana and Prometheus over HTTP and TCP. Alert rules detect scrape/probe failures
and root disk pressure. Alerts are visible in Prometheus; external notifications are
not configured. Configuration and local backup tests do not constitute disaster recovery.

## Access and installation

Requires Linux, Docker Engine and Compose v2, curl, Bash, GNU coreutils and getent.
The current host uses approximately 2 GiB combined configured container memory limits.
Grafana and Prometheus publish only on loopback. From your workstation:

```sh
ssh -L 3000:127.0.0.1:3000 -L 9090:127.0.0.1:9090 dell-lab@<lab-address>
```

Open http://localhost:3000 and sign in; dashboard UID is `dell-lab-overview`.
For a fresh deployment, create `secrets/` mode 700 with two nonempty files,
`grafana_admin_password` and `grafana_secret_key`, using unique random values.
Protect their host access while ensuring the container user can read its mounted secrets.
Do not replace existing credentials or volumes. Non-sensitive provisioning directories
must be traversable and their files readable by container users (755/644).

```sh
docker compose config -q
docker compose up -d
./automation/bash/diagnose.sh docker
./tests/diagnostics.sh
```

See [operations](docs/runbooks/operations.md), [architecture](docs/architecture/overview.md),
[progress](docs/PROGRESS.md), and [incident reports](docs/incidents/).

## Automation and testing

```sh
./automation/bash/diagnose.sh host
./automation/bash/diagnose.sh http http://127.0.0.1:3000/api/health
./automation/bash/diagnose.sh dns localhost
./automation/bash/diagnose.sh tcp localhost 3000
pwsh -File automation/powershell/Test-LabEndpoint.ps1 -ComputerName localhost -Port 3000
./scripts/validate.sh
```

Exit codes: 0 success, 1 failed check, 2 invalid arguments. Scripts never repair
services automatically. PowerShell requires version 7; execution on Windows remains
unverified. Evidence contains actual API results, not benchmark or availability claims.
The dashboard API and all expressions were verified; screenshots and visual browser
inspection remain outstanding.

## Limitations and scope

The defective battery provides no power protection. Power loss stops the host;
manual LUKS unlock is required after reboot. Unattended recovery, automatic power-on,
a UPS and independent backup storage are not established. Docker restart policies
apply after Debian and Docker successfully start, not before disk unlock.
Loki/Alloy are deferred to keep this release focused: existing Docker logs support
local investigations, but are not centralized durable logging. No Service Desk API
integration is deployed. See the progress record for remaining release gates.

## Skills demonstrated

PromQL, provisioning, Docker networking, least exposure, bounded resources, Bash
troubleshooting, alert testing, controlled failure investigation and honest evidence.

Application-state backup is also implemented; see the operations runbook for the
maintenance-window command and verified isolated restore scope. Full Grafana restore
startup and independent disaster recovery remain unverified.
