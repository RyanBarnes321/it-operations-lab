# Architecture

```mermaid
flowchart LR
  Admin[Administrator workstation] -->|SSH tunnel| Host[Dell Debian host]
  Host -->|loopback 3000| G[Grafana]
  Host -->|loopback 9090| P[Prometheus]
  subgraph Docker monitoring network
    G -->|Prometheus datasource| P
    P -->|scrape 15s| N[Node Exporter]
    P -->|scrape and request probes| B[Blackbox Exporter]
    B -->|HTTP and TCP| G
    B -->|HTTP and TCP| P
  end
  N -->|read-only mount| FS[Host filesystem and proc metrics]
  G --> GV[Grafana persistent volume]
  P --> PV[Prometheus persistent volume: 15 days]
  Config[Versioned provisioning and rules] --> G
  Config --> P
```

Only Grafana and Prometheus have host ports, both loopback. Other containers
are reachable on the Compose bridge. This is private exposure, not isolation from
other local users or Docker administrators. Node Exporter uses host PID namespace
and read-only root access for host metrics; Docker membership is privileged.
No remote logging flow is deployed. Docker logs are local operational evidence.
Grafana's authentication and existing secret files are preserved. Memory limits:
Grafana 1 GiB, Prometheus 768 MiB, exporters 128 MiB each. Prometheus retention is
15 days; volume capacity must still be monitored. Images retain existing versions.
Blackbox configuration follows the upstream multi-target pattern:
https://prometheus.io/docs/guides/multi-target-exporter/ .


Isolated restore verification uses a separate temporary **internal** Docker
network containing restored Grafana and Prometheus only. No ports are published;
no live volumes are mounted, and production services are not connected. The host
validation harness queries the temporary bridge address, then removes the drill.
This network exists only during a drill, not as a deployed monitoring component.

## Verified backup workflow

```mermaid
flowchart LR
  State[Consistent Grafana and Prometheus archive] -->|age public recipient| Cipher[Encrypted archive on Dell]
  Cipher -->|User SCP pull over trusted SSH| Windows[Protected Windows backup directory]
  USB[Passphrase-encrypted USB identity copy] -->|User recovery test| Windows
  Windows -->|User recovery and return over SSH| Staging[Private Dell staging]
  Staging -->|Original SHA-256 match| Drill[Isolated application restore]
```

The user reports a successful Windows round trip, matching original archive and
USB identity recovery test. The returned restore record verifies seven historical
queries and unchanged production state. This final session reviewed the evidence;
it did not perform the Windows transfer or inspect the recovery identity. Only
ciphertext is exported for backup storage; decrypted test material is returned
through trusted SSH to private staging for recovery verification. Same-house
Windows storage is off-device, not independently verified offsite protection.
See [backup procedure](../runbooks/off-device-backup.md) and
[evidence attribution](../TEST-EVIDENCE.md).
