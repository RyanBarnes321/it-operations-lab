# Controlled stopped-exporter incident

2026-11-11, actual lab exercise. Only Node Exporter was stopped, temporarily
interrupting host metric collection. Prometheus, Grafana and host access remained
running. `tests/diagnostics.sh` passed before the exercise.

Detection: `up{job="dell-lab"}` failed; Prometheus TargetDown progressed to firing
after its one-minute hold. The test polled `/api/v1/alerts` every five seconds,
with a two-minute deadline and a finally handler to start Node Exporter.
See [recorded samples](../evidence/target-down.json).

Investigation: Compose stop state explains the unavailable scrape target; compare
`docker compose ps`, `/targets` and `/alerts`. Root cause: intentional service stop,
not host network or authentication failure. Corrective action:
`docker compose start node-exporter` executed by cleanup. Final-state evidence
records every target up, four successful probes and no active alerts.

Prevention: restart policies recover unexpected exits after Docker startup, but an
intentional stop requires explicit restoration. Verify restoration after every
exercise. Limitation: this demonstrates live detection and recovery, not external
notification delivery or unattended host power recovery.
