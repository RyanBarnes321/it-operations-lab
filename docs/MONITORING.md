# Monitoring and alerting

Configuration lives under `monitoring/`. Prometheus scrapes and evaluates every
15 seconds; metrics have 15-day retention. Grafana provisions the Prometheus
datasource with UID `prometheus` and the dashboard `dell-lab-overview` in the Dell
Lab folder. Source JSON is authoritative: provisioning is not editable in the UI,
refresh is 30 seconds and the default time window is the last hour.

| Panel | Meaning and units |
|---|---|
| CPU utilization | 100 × (1 − average five-minute idle rate), percent |
| Memory utilization | 100 × (1 − MemAvailable / MemTotal), percent |
| Root filesystem used | 100 × (1 − available / size), percent; reserved space affects available |
| System uptime | Evaluation time minus host boot time, seconds rendered as a duration |
| Network throughput | Five-minute receive/transmit byte rates in the exporter network namespace; excludes loopback, veth, docker and bridge interfaces |
| Scrape target health | `up` for the `dell-lab` and `prometheus` jobs; two displayed targets |

Six panels contain seven expressions because network has receive and transmit
queries. Full expressions are in the dashboard JSON and
[dashboard-rc-audit.json](evidence/dashboard-rc-audit.json). New deployments need
rate samples; zero traffic is valid. Historical evaluation time is not current
host uptime. The user's screenshot observations are recorded separately in
[manual verification](evidence/user-verification.json); the image itself is missing.

Prometheus has seven scrape targets: itself, Node Exporter, Blackbox Exporter,
two HTTP probes and two TCP probes. HTTP probes request Grafana `/api/health` and
Prometheus `/-/ready`; TCP probes connect to their service ports. A successful
Blackbox scrape does not imply `probe_success=1`. TCP acceptance alone does not
prove HTTP health or backend business behavior. Probes run from the Docker network,
not the workstation or public Internet.

| Alert | Condition | Hold time | Verification |
|---|---|---|---|
| TargetDown | `up == 0` | 1 minute | Deterministic rule tests and actual stopped-exporter exercise |
| ProbeFailed | `probe_success == 0` | 1 minute | Deterministic rule tests; one-shot failure probes are separate simulations |
| RootDiskLow | Root available / size < 0.15 | 5 minutes | Synthetic rule tests; live disk was not filled |

All rules have warning severity. `tests/alerts.yml` checks delay, firing and recovery
for each rule through promtool. Run `scripts/validate.sh` with Docker access.
Prometheus `/targets`, `/alerts` and `ALERTS` support investigation; no Alertmanager,
email or other external delivery is configured. No notification-delivery claim is made.

For incidents, compare service state, scrape health, probe result and endpoint
behavior. Use the [operations runbook](runbooks/operations.md) and
[incident evidence](incidents/). Preserve production access and restore only the
service deliberately stopped. No host networking changes are required for simulations.

Node Exporter has host PID/root filesystem visibility but uses a Compose bridge
network. Its network counters are not verified host-NIC traffic. CPU, memory,
filesystem and uptime monitoring remain useful; do not infer physical NIC throughput
from the network panel. Changing exporter network isolation is outside v1.0 scope.
