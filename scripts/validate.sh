#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose config -q
docker compose exec -T prometheus promtool check config /etc/prometheus/prometheus.yml
docker run --rm -v "$PWD/monitoring/prometheus/alerts:/etc/prometheus/alerts:ro" -v "$PWD/tests:/tests:ro" --entrypoint promtool prom/prometheus:v2.55.1 test rules /tests/alerts.yml
for script in automation/bash/*.sh scripts/*.sh tests/*.sh; do
  bash -n "$script"
done
./tests/diagnostics.sh
