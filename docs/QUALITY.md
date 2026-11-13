# Reproducible quality checks

Run source checks from a checkout; no lab connection or credentials are needed:

```sh
python3 -m venv /tmp/itlab-quality
/tmp/itlab-quality/bin/pip install -r requirements-quality.txt
/tmp/itlab-quality/bin/python scripts/check-source.py
./tests/backup-failures.sh
```

The validator parses YAML (rejecting duplicate keys), JSON and Python, checks Bash
syntax, local Markdown file links and the six-panel/seven-expression dashboard
inventory. It scans candidate files and every reachable Git commit/blob/tag for
common credential signatures and private LAN addresses, without printing matched
values. This lightweight guard complements manual review; it cannot detect every
secret encoding, inspect screenshots or prove vulnerability freedom. External URLs
and Markdown section anchors are not checked. Private secrets, backups and runtime
files are ignored and are never opened by the source check.

On an installed lab run `./scripts/validate.sh`: Compose configuration, live
promtool configuration validation, deterministic delay/firing/recovery tests for
three alert rules, shell syntax, twelve Bash diagnostic cases, and three isolated
backup failure-path cases. Backup tests substitute Docker commands and exercise
restart-on-copy-failure, partial configuration-archive removal and unsafe destination
rejection. They never stop production. Network/host results depend on the local
machine; this is separate from source validation.

The [GitHub Actions workflow](../.github/workflows/quality.yml) runs source checks
with full history, starts a disposable four-service stack on an Ubuntu runner with
fresh random local secrets, reuses `scripts/validate.sh`, and removes runner volumes.
A Windows runner executes the existing nine-case loopback PowerShell fixture.
Neither job contacts the Dell or a private network; no stored GitHub secrets or paid
tool is required. Normal hosted-runner availability/usage limits still apply.
Actions and container versions use mutable version tags; digest/commit pinning
is a possible later supply-chain improvement.

**Workflow status: configured, not run on GitHub.** Local checks do not establish
that either hosted job passed. No separate clean-machine deployment or Windows
execution by this final Codex session is claimed. Do not add a passing CI badge
until a real run completes. The runner stack does not test power recovery,
off-device transfer, USB identity recovery or production backup restoration.
