#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
check() {
 local expected=$1; shift
 local actual=0
 automation/bash/diagnose.sh "$@" >/dev/null 2>&1 || actual=$?
 [[ $actual == "$expected" ]] || { echo "FAIL $*: $actual != $expected"; exit 1; }
}
check 0 host
check 0 docker
check 0 http http://127.0.0.1:3000/api/health
check 1 http http://127.0.0.1:1
check 0 dns localhost
check 1 dns lab-test.invalid
check 0 tcp localhost 3000
check 1 tcp localhost 1
check 2 tcp localhost 65536
check 2 tcp localhost '80;id'
check 2 http file:///etc/passwd
check 2 unknown
echo '12 diagnostic checks passed'
