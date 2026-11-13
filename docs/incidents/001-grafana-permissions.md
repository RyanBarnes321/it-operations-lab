# Historical incident: Grafana provisioning permissions

Status: historical, reported in the implementation handoff; not reproduced.

Impact and symptoms: Grafana restarted approximately twenty times, with HTTP
connection resets and no reported OOM kill. The recorded error was:
`Datasource provisioning error: open /etc/grafana/provisioning/datasources/prometheus.yml: permission denied`.

Root cause: restrictive umask left non-sensitive provisioning files unreadable
by Grafana's unprivileged container user. Corrective action reported by the user:
repair configuration permissions and restart Grafana. Reported verification:
HTTP 200, database ok, restart count zero, both scrape targets up and datasource
query functioning. Original command transcripts and exact chmod invocations are
not available; these are historical observations, not commands run this session.

Diagnostic commands for recurrence: `docker compose ps`, `docker compose logs
--tail 100 grafana`, `docker inspect` restart/OOM fields, `namei -l` on the affected
file, and `curl -fsS http://127.0.0.1:3000/api/health`.

The historical implementation session independently verified Grafana health, datasource/dashboard API,
real panel queries and restart count zero. See dashboard-validation.json.
Prevent recurrence with 755 non-secret directories, 644 provisioning files,
configuration checks and health verification after changes. Keep secrets private;
never use recursive permissive chmod on the project. Credentials exposed in a prior
conversation were reportedly reset; no credential values are retained here.
