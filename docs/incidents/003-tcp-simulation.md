# Controlled TCP failure simulation

Date: 2026-11-11. Impact: isolated one-shot Blackbox request only, no service
configuration or host networking changed. This is a simulation, not a real outage.

Detection: Blackbox probe_success returned 0. Evidence:
[isolated-probes.json](../evidence/isolated-probes.json).

Investigation: request /probe from the Prometheus container with the appropriate
http_2xx or tcp_connect module. Compare HTTP status, DNS lookup duration and
probe_success. Root cause: Grafana container port 1 has no listening service.

Corrective action: Use the configured Grafana port 3000. No rollback mutation was needed.
Validation: steady configured probes are checked separately in final-state evidence.
Prevention: distinguish DNS resolution, TCP connection acceptance and HTTP status;
confirm the health URL rather than relying on a server's fallback page.
Limitations: one-shot failures were not added to scrape configuration and therefore
were not expected to fire Prometheus alerts. A separate stopped-exporter exercise
verifies live alert evaluation.
