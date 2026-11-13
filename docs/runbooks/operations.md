# Operations, installation and recovery

For a new host, follow [fresh installation](installation.md). This runbook covers
the deployed stack and maintenance. Final quality-pass live checks succeeded after
authorized socket access; the earlier handoff restrictions are historical.
See [release checklist](../RELEASE-CHECKLIST.md).

## Validate and troubleshoot

Run `scripts/validate.sh` from the project. Inspect `docker compose ps`,
`docker compose logs --since 10m --tail 100 SERVICE`, Prometheus `/targets`
and `/alerts`, and Grafana `/api/health`. Do not publish raw logs without review.
HTTP probes test the health endpoints; TCP probes only demonstrate connection
acceptance. A healthy scrape of Blackbox does not imply a healthy probe.
Dashboard UID and datasource UID are `dell-lab-overview` and `prometheus`.

CPU uses idle rate over five minutes; RAM uses MemAvailable; root disk uses
available/size (includes reserved-space effects); network excludes virtual devices but reflects the exporter bridge namespace, not verified host-NIC traffic;
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
Do not use `docker compose down -v`. Historical implementation used `/tmp/lab-*.rollback` files as temporary aids;
their continued existence is not guaranteed. Use versioned configuration and a
verified backup for future changes.

## Backup and restore

`./scripts/backup-config.sh /absolute/existing/destination` creates a private
configuration archive plus SHA256 sidecar, validates gzip/tar and verifies the hash.
The destination must already exist and should be mode 700. Treat archives as private.
This backup deliberately excludes secrets and Docker volumes. It cannot recover
Grafana users/settings or historical metrics. Provisioned dashboard/configuration
can be reconstructed. The user reports a verified encrypted Windows off-device backup; no independent
offsite destination is verified. See off-device-backup.md for the transfer workflow.

For a restore drill, verify `sha256sum -c ARCHIVE.sha256`, extract into an empty
private temporary directory, compare `compose.yaml` and monitoring files with the
source and run `docker compose -f RESTORE/compose.yaml config -q` only
after restoring the required secret files securely. Do not deploy a drill over the
live stack. For real recovery provision secrets through a separate protected channel,
restore source configuration, validate, start, and verify targets/dashboard.
Application-state restoration and a user-executed Windows round trip are recorded
in [the evidence index](../TEST-EVIDENCE.md). Do not claim
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

## Application state backup drill

`scripts/backup-state.sh --allow-service-stop /private/destination` requires a
mode-700 existing directory. It checks both services are running, stops only
Grafana and Prometheus, copies their data and source/secrets, then creates a
mode-600 gzip archive plus checksum. An EXIT handler restarts services and removes
working copies. Failed/incomplete archive output is removed; valid completed backups
are retained even if restarting a service fails. Allow a maintenance window; monitoring has a gap while stopped.
An uncatchable kill or power loss requires manual `docker compose start grafana
prometheus`. Check available space first: working copy plus compressed archive
requires additional capacity. There is no automatic pruning; monitor backup space.

The state archive contains credentials and Grafana state: never upload it to Git
or include it in public evidence. For restoration, verify its checksum and extract
into a private directory. SQLite integrity was checked on the restored Grafana DB.
A temporary Prometheus container with network disabled, no published ports, and the
restored data started successfully and returned a historical host metric. The test
container was removed and live volumes were never overwritten. Grafana restored application startup, provisioning and queries are now verified;
the user-executed off-device return-restore also passed. See the repeatable drill below.


## Repeat Grafana application restoration without touching production

If the ignored project `backups/` directory is absent, first create it with
`mkdir -m 700 backups` from the project root; keep it private.
Use your own trusted archive and matching SHA-256 sidecar. The historical tested
generation is `backups/lab-state-PlVe4Kg0.tar.gz`; it is private and absent from a
clean checkout. Run as an authorized local administrator:

```sh
python3 scripts/verify-grafana-restore.py /private/staging/returned-state.tar.gz
# For a new backup, use a known healthy instant within its retained TSDB data:
# append: --evaluation-time 2026-11-12T18:00:00+00:00
```

The stdlib Python 3.12+ harness checks the stored SHA256 using a streaming hash, extracts with the safe data
filter into a private temporary directory under ignored backups, creates uniquely
named Grafana/Prometheus containers and a dedicated **internal** bridge, publishes
no ports, and mounts only restored copies. Production containers are not attached
to this network. The harness requires Docker access and local ownership-management
rights; the current session runs as root. Production configuration/ownership is not
changed. Images are already cached; no installation is performed by the drill.

Safe extraction deliberately drops archived ownership. The first test attempts
found SQLite readonly errors and Prometheus query-log permission errors. The harness
now explicitly assigns only disposable Grafana state to UID/GID 472 and Prometheus
state to 65534 before unprivileged startup. These permissions are part of recovery,
not a reason to relax live secrets or run restored services as root. Earlier failed
test containers/networks were cleaned up.

Health verifies the restored Grafana database. Authenticated API calls verify the
provisioned datasource and six-panel dashboard; seven expressions execute through
the restored datasource against restored Prometheus. Because the backup is old,
queries default to the known healthy timestamp from dashboard-validation.json.
For another archive, explicitly supply its healthy timezone-aware `--evaluation-time`;
the example timestamp above is illustrative, not evidence of a sample in your archive. An initial timestamp near the prior failure exercise returned an empty memory
series; choosing the recorded healthy snapshot avoids confusing historic gaps with
restore failure. Uptime at a historic evaluation instant is historical uptime, not
current host uptime. No current-availability claim is made from restored data.

The finally handler removes only the uniquely named temporary containers/network;
TemporaryDirectory removes only the temporary extracted copies. The original archive
is retained. The recorded production container IDs, start times, restart counters
and running states are identical before and after, and production Grafana health is
checked again after test shutdown. New runs write ignored `runtime/restore-verification.json` by default (`--output`
can select another private path); they do not overwrite historical committed evidence.
Historical evidence: grafana-restore-verification.json. The final harness regression
is summarized in final-quality-restore.json under the evidence directory.
This drill checks application/API behavior; it does not replace visual rendering
inspection. The user reports both visual inspection and off-device recovery
complete; see [evidence](../TEST-EVIDENCE.md) for provenance and the missing image.
If forcibly killed or the host loses power, inspect uniquely named `lab-restore-*` resources before cleanup;
never remove production volumes.
