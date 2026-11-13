#!/usr/bin/env bash
# Failure-path checks use disposable fixtures, never a real Docker daemon.
set -euo pipefail
cd "$(dirname "$0")/.."
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir "$work/bin" "$work/destination"
chmod 700 "$work/destination"
export BACKUP_TEST_LOG="$work/docker-calls"
cat > "$work/bin/docker" <<'MOCK'
#!/usr/bin/env bash
set -eu
printf '%s\n' "$*" >> "$BACKUP_TEST_LOG"
case "$*" in
 'compose ps -q grafana'|'compose ps -q prometheus') echo fixture ;;
 'inspect -f {{.State.Running}} fixture') echo true ;;
 'compose stop grafana'|'compose stop prometheus'|'compose start grafana prometheus') exit 0 ;;
 'compose ps -aq grafana') echo fixture ;;
 cp*) exit 1 ;;
 *) echo 'Unexpected fixture call' >&2; exit 99 ;;
esac
MOCK
chmod +x "$work/bin/docker"
if PATH="$work/bin:$PATH" scripts/backup-state.sh --allow-service-stop "$work/destination" >/dev/null 2>&1; then
  echo 'FAIL: state copy failure returned success'; exit 1
fi
[[ $(tail -n 1 "$BACKUP_TEST_LOG") == 'compose start grafana prometheus' ]]
[[ -z $(find "$work/destination" -mindepth 1 -print -quit) ]]
cat > "$work/bin/tar" <<'MOCK'
#!/usr/bin/env bash
exit 1
MOCK
chmod +x "$work/bin/tar"
if PATH="$work/bin:$PATH" scripts/backup-config.sh "$work/destination" >/dev/null 2>&1; then
  echo 'FAIL: tar failure returned success'; exit 1
fi
[[ -z $(find "$work/destination" -mindepth 1 -print -quit) ]]
chmod 755 "$work/destination"
result=0
PATH="$work/bin:$PATH" scripts/backup-state.sh --allow-service-stop "$work/destination" >/dev/null 2>&1 || result=$?
[[ $result == 2 ]]
echo '3 backup failure-path checks passed (mock Docker, no production access)'
