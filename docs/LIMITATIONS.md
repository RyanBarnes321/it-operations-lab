# Known limitations for v1.0.0

- The Dell battery is defective. A power loss stops the host. Manual power-on as
  needed and manual LUKS unlocking are required; automatic power restoration,
  unattended unlocking and reboot recovery have not been implemented or verified.
  Docker restart policies apply only after Debian and Docker start.
- One host, local SQLite/TSDB, no HA. DHCP reservation is unconfirmed.
- Backups run manually and can briefly stop Grafana and Prometheus. There is no
  guaranteed RPO or RTO, scheduled pruning or established ongoing cadence. A
  successful user-executed Windows round trip and USB key recovery test verify
  that backup generation, not every future backup. Storage is off-device but not
  independently verified offsite. Desktop availability and capacity are dependencies.
- Seven recent/four weekly backup generations are a proposed manual retention
  policy, subject to capacity and recovery checks. Uncatchable interruption during
  backup requires manual service recovery. Partial archives are not valid backups.
- Centralized logging and remote log retention are deliberately deferred. Docker
  logs have no explicit per-service rotation policy here. Memory ceilings do not
  bound disk use; Prometheus has 15-day time retention without a byte cap.
- Prometheus alerts remain local; no Alertmanager or external notifications.
  Disk-pressure testing uses synthetic input. HTTP/TCP/DNS simulations do not
  demonstrate a live ProbeFailed firing or notification delivery.
- Version tags are mutable; no fresh vulnerability scan or comprehensive
  supply-chain attestation. Host PID/root visibility and Docker privileges are
  explicit trust boundaries; loopback does not isolate local users.
- Fresh installation is documented with new credentials; a separate clean-host
  deployment has not been rehearsed. Recovery needs administrative ownership
  handling and Python 3.12+ safe tar extraction; normal monitoring does not use Python.
- No backend application integration is deployed. There are no continuous-uptime,
  performance benchmark or enterprise disaster-recovery claims.
- The user's dashboard screenshot and original Windows runner JSON are not
  available in this checkout. Reported results remain clearly attributed.
- Node Exporter uses bridge networking; network counters reflect the exporter
  namespace, not verified host NIC traffic. Host CPU, memory, filesystem and uptime
  metrics remain in scope.
- CI is configured but has not run on GitHub. Source checks do not prove hosted
  runner compatibility or absence of every possible secret/vulnerability.
