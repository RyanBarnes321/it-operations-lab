#!/usr/bin/env bash
# Dependencies: bash, curl, coreutils, getent; docker for docker mode.
# Exit: 0 healthy, 1 failed check, 2 usage error. No remediation.
set -euo pipefail
usage() { echo 'Usage: diagnose.sh host | docker | http URL | dns NAME | tcp HOST PORT' >&2; exit 2; }
[[ $# -gt 0 ]] || usage
mode=$1; shift
case "$mode" in
 host)
  [[ $# == 0 ]] || usage
  free -m
  df -h /
  awk '/MemAvailable:/ {a=$2} /MemTotal:/ {t=$2} END {exit !(a/t > .1)}' /proc/meminfo || exit 1
  [[ $(df --output=pcent / | tail -1 | tr -dc '0-9') -lt 85 ]] || exit 1;;
 docker)
  [[ $# == 0 ]] || usage
  cd -- "$(dirname -- "$0")/../.." || exit 1
  docker compose ps
  for service in grafana prometheus node-exporter blackbox; do
    id=$(docker compose ps -q "$service") || exit 1
    [[ -n "$id" && $(docker inspect -f '{{.State.Running}}' "$id") == true ]] || exit 1
  done;;
 http)
  [[ $# == 1 && $1 =~ ^https?:// ]] || usage
  curl --fail --silent --show-error --connect-timeout 3 --max-time 10 --output /dev/null -- "$1" || exit 1;;
 dns)
  [[ $# == 1 && $1 =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]] || usage
  getent ahosts "$1" || exit 1;;
 tcp)
  [[ $# == 2 && $1 =~ ^[a-zA-Z0-9][a-zA-Z0-9.:-]*$ && $2 =~ ^[0-9]{1,5}$ ]] || usage
  port=$((10#$2)); ((port > 0 && port < 65536)) || usage
  timeout 5 bash -c 'exec 3<>/dev/tcp/$1/$2' bash "$1" "$port" || exit 1;;
 *) usage;;
esac
