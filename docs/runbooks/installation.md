# Fresh installation and deployment

Use a separate Linux host or a fresh checkout with new Docker volumes. Do not run
the bootstrap below against the existing Dell deployment or overwrite its secrets.
No original host address, account or password is required. This procedure is
documented and statically reviewed; a separate clean-host rehearsal is not recorded.

## Prerequisites

- Linux with `/proc`, GNU coreutils/tar, Bash, curl, getent, timeout and OpenSSL.
- Docker Engine and Compose v2, already installed by the host administrator.
  Recorded Compose version is 2.26.1; see `compose.yaml` for exact image versions.
- Docker administrative access, permission to bind loopback ports 3000/9090, and
  enough disk for images, metrics and backup working copies. Container memory limits
  total 2 GiB; reserve additional RAM for Linux and Docker.
- An existing trusted SSH connection for remote access. Establish host access
  separately; this project does not install SSH or change firewall/boot settings.
- PowerShell 7 on Windows only for Windows diagnostics. Python 3.12+ is needed
  only for the optional restore harness (`tarfile` safe data filter); final source
  parsing used Python 3.13.5. Portable age is needed for encrypted backup transfer.

## Bootstrap a new checkout

Obtain the reviewed source into a directory owned by the deployment administrator,
then change into it. Preserve script executable bits. Use a rootful Docker daemon
to match the recorded deployment. The following commands must run with ownership
rights over this fresh directory. They create random secrets without displaying
them; `mkdir` fails if the secrets directory already exists.

```sh
umask 077
mkdir -m 700 secrets
openssl rand -hex 32 > secrets/grafana_admin_password
openssl rand -hex 32 > secrets/grafana_secret_key
chmod 444 secrets/grafana_admin_password secrets/grafana_secret_key
chmod 755 monitoring monitoring/grafana monitoring/grafana/provisioning
chmod 755 monitoring/grafana/provisioning/datasources monitoring/grafana/provisioning/dashboards
chmod 755 monitoring/grafana/dashboards monitoring/prometheus monitoring/prometheus/alerts monitoring/blackbox
find monitoring -type f -exec chmod 644 {} +
docker compose config -q
docker compose up -d
./scripts/validate.sh
```

The secret parent must remain mode 700 and owned by the deployment administrator.
Mounted secret files are mode 444 so Grafana's unprivileged user can read them;
ordinary host users cannot traverse the parent. Local root and Docker admins can
read them and are trusted. Compose local file secrets are bind mounts, not an
encrypted secret store. Use a private local editor to retrieve the initial admin
password when signing in; never paste it into chat, logs or Git. The initial user
is `admin`. Later changing the bootstrap password file does not reset an existing
Grafana database password. Preserve the secret key across state recovery.

## Acceptance and normal access

Wait at least five minutes for rate metrics. Confirm all four containers run,
seven scrape targets are UP, four `probe_success` series are 1 and no alerts remain
active. Use an SSH tunnel as shown in the README. Confirm the six-panel dashboard
and network receive/transmit lines (exporter bridge namespace, not verified host-NIC
traffic). Its scrape-health panel deliberately displays
two original targets, not the full seven-target inventory.

Check `docker compose port grafana 3000` and `docker compose port prometheus 9090`
return loopback bindings. Exporters must have no published host ports. An
unauthenticated request to `/api/dashboards/uid/dell-lab-overview` should return
HTTP 401; `/api/health` is intentionally accessible to health probes. Prometheus
has no application login and must remain behind the loopback/SSH boundary.

See [operations](operations.md) for troubleshooting, backups, rollback and power
recovery, and [Windows verification](windows-verification.md) for workstation tests.
New deployments should generate their own evidence; historical metrics, backups
and private identities are intentionally absent from the repository.
