#!/usr/bin/env bash
# Source configuration only, excludes credentials and application databases.
set -euo pipefail
[[ $# == 1 && $1 == /* ]] || { echo 'Usage: backup-config.sh /absolute/existing/backup-directory' >&2; exit 2; }
[[ -d $1 && ! -L $1 ]] || exit 2
cd "$(dirname "$0")/.."
umask 077
archive=$(mktemp "$1/lab-config-XXXXXXXX.tar.gz")
trap 'rm -f -- "$archive" "$archive.sha256"' ERR
tar -czf "$archive" compose.yaml monitoring automation scripts tests docs README.md .gitignore .env.example LICENSE .github requirements-quality.txt
sha256sum "$archive" > "$archive.sha256"
# Verify compressed stream, archive structure and checksum before reporting success.
gzip -t "$archive"
tar -tzf "$archive" >/dev/null
sha256sum -c "$archive.sha256"
printf '%s\n' "$archive"
