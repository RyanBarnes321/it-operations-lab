#!/usr/bin/env bash
# Consistent offline state copy. Briefly stops Grafana and Prometheus.
# Requires explicit acknowledgement, Docker access, GNU tar and coreutils.
set -euo pipefail
[[ $# == 2 && $1 == --allow-service-stop && $2 == /* && -d $2 && ! -L $2 ]] || {
 echo 'Usage: backup-state.sh --allow-service-stop /existing/private/destination' >&2; exit 2;
}
[[ $(stat -c %a "$2") == 700 ]] || { echo 'Destination must have mode 700' >&2; exit 2; }
cd "$(dirname "$0")/.."
umask 077
work=$(mktemp -d "$2/.state-XXXXXXXX")
services=()
cleanup() {
 local result=$?
 trap - EXIT
 if ((${#services[@]})); then docker compose start "${services[@]}" || result=1; fi
 rm -rf -- "$work"
 exit "$result"
}
trap cleanup EXIT
for service in grafana prometheus; do
 id=$(docker compose ps -q "$service")
 [[ -n "$id" && $(docker inspect -f '{{.State.Running}}' "$id") == true ]] || { echo "$service must be running" >&2; exit 1; }
done
for service in grafana prometheus; do
 services+=("$service")
 docker compose stop "$service"
done
mkdir "$work/grafana" "$work/prometheus" "$work/source"
docker cp "$(docker compose ps -aq grafana):/var/lib/grafana/." "$work/grafana/"
docker cp "$(docker compose ps -aq prometheus):/prometheus/." "$work/prometheus/"
cp -a compose.yaml monitoring secrets "$work/source/"
archive=$(mktemp "$2/lab-state-XXXXXXXX.tar.gz")
tar --numeric-owner -czf "$archive" -C "$work" .
gzip -t "$archive"
sha256sum "$archive" > "$archive.sha256"
printf '%s\n' "$archive"
