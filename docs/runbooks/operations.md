# Operations, installation and recovery

## Validate and troubleshoot

Run `scripts/validate.sh` from the project. Inspect `docker compose ps`,
`docker compose logs --since 10m --tail 100 SERVICE`, Prometheus `/targets`
and `/alerts`, and Grafana `/api/health`. Do not publish raw logs without review.
HTTP probes test the health endpoints; TCP probes only demonstrate connection
acceptance. A healthy scrape of Blackbox does not imply a healthy probe.
Dashboard UID and datasource UID are `dell-lab-overview` and `prometheus`.

CPU uses idle rate over five minutes; RAM uses MemAvailable; root disk uses
available/size (includes reserved-space effects); network excludes virtual devices;
uptime is time minus boot time. New deployments need enough samples for rates.
Zero traffic is valid. `up` tests scraping, not application business functionality.

For permissions errors inspect `namei -l` on the reported path, container logs,
and `docker compose exec grafana id`. Non-secret JSON/YAML should be 644,
directories 755. Change only affected files; never recursively relax secrets.
Do not recreate volumes to repair provisioning.

## Controlled failures and rollback

The recorded exporter test stopped only Node Exporter, waited for TargetDown,
then restarted it in a cleanup handler. Manual recovery: `docker compose start
node-exporter`. Verify `up{job="dell-lab"}=1` and no firing TargetDown alert.
Never simulate failure by changing host DNS, SSH, firewall or Wi-Fi.
One-shot failed probes of a missing Prometheus route, closed port 1 and reserved
`.invalid` name do not change production targets. They are simulations, not outages.
No external notification delivery is configured.

Before updates save configuration and verify a usable backup. Pull only an
explicitly reviewed pinned version; run Compose and promtool validation before
`docker compose up -d SERVICE`. Verify health, queries and restart counts afterward.
Rollback by restoring the previous configuration and pinned image, then recreating
only the changed service. Check upstream database migration compatibility first.
Do not use `docker compose down -v`. During this session pre-change Compose and
Prometheus files were saved under `/tmp/lab-*.rollback`; these are temporary aids.

## Backup and restore

`./scripts/backup-config.sh /absolute/existing/destination` creates a private
configuration archive plus SHA256 sidecar, validates gzip/tar and verifies the hash.
The destination must already exist and should be mode 700. Treat archives as private.
This backup deliberately excludes secrets and Docker volumes. It cannot recover
Grafana users/settings or historical metrics. Provisioned dashboard/configuration
can be reconstructed. No independent backup destination is presently verified.

For a restore drill, verify `sha256sum -c ARCHIVE.sha256`, extract into an empty
private temporary directory, compare `compose.yaml` and monitoring files with the
source and run `docker compose -f RESTORE/compose.yaml config --no-interpolate` only
after restoring the required secret files securely. Do not deploy a drill over the
live stack. For real recovery provision secrets through a separate protected channel,
restore source configuration, validate, start, and verify targets/dashboard.
Full application-state backup and restoration remain release gates. Do not claim
same-disk archives provide disaster recovery. Scheduling is deferred until protected
off-device storage and retention requirements are established.

## Power recovery

After a power loss, a person must power on the Dell as needed and unlock LUKS
locally. Once Debian boots, verify Docker is active, run `docker compose ps`,
then `docker compose up -d` if needed and `scripts/validate.sh`. Verify the Grafana
dashboard and all Prometheus targets. Restart policies are `unless-stopped`;
intentionally stopped services can remain stopped. No reboot test was performed.
Investigate a UPS, replacement battery and firmware power restoration options in
future; no boot, encryption, firmware or power settings were changed.
