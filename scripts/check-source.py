#!/usr/bin/env python3
"""Source validation and a conservative publication guard; no network or secrets read."""
import ast
import ipaddress
import json
from pathlib import Path
import re
import subprocess

import yaml

ROOT = Path(__file__).resolve().parent.parent


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


class UniqueKeys(yaml.SafeLoader):
    pass


def mapping(loader, node):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node)
        if key in result:
            raise ValueError(f"duplicate YAML key: {key}")
        result[key] = loader.construct_object(value_node)
    return result


UniqueKeys.add_constructor(yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG, mapping)
private_networks = [ipaddress.ip_network(n) for n in ((0x0A000000, 8), (0xAC100000, 12), (0xC0A80000, 16))]
# Construct signatures in pieces so the scanner does not match its own source.
signatures = [
    r"-----BEGIN " + r"(?:[A-Z]+ )?PRIVATE KEY-----",
    r"AGE-SECRET-" + r"KEY-1[0-9A-Z]+",
    r"gh[pousr]_" + r"[A-Za-z0-9]{20,}",
    r"github_pat_" + r"[A-Za-z0-9_]{20,}",
    r"(?:AKIA|ASIA)" + r"[A-Z0-9]{16}",
    r"https?://[^\s/:]+:[^\s/@]+@",
]


def privacy(raw, label):
    text = raw.decode("utf-8", errors="replace")
    for pattern in signatures:
        if re.search(pattern, text):
            raise ValueError(f"credential signature in {label}; inspect privately")
    for value in re.findall(r"(?<![\w.])(?:\d{1,3}\.){3}\d{1,3}(?![\w.])", text):
        try:
            address = ipaddress.ip_address(value)
        except ValueError:
            continue
        if any(address in network for network in private_networks):
            raise ValueError(f"private LAN address in {label}; inspect privately")


paths = {p.decode() for p in git("ls-files", "-z", "--cached", "--others", "--exclude-standard").split(b"\0") if p}
counts = {"json": 0, "yaml": 0, "python": 0, "shell": 0, "local_links": 0}
for name in sorted(paths):
    path = ROOT / name
    if not path.is_file():
        continue
    raw = path.read_bytes()
    privacy(raw, name)
    if path.suffix == ".json":
        json.loads(raw)
        counts["json"] += 1
    if path.suffix in (".yaml", ".yml"):
        yaml.load(raw, Loader=UniqueKeys)
        counts["yaml"] += 1
    if path.suffix == ".py":
        ast.parse(raw, filename=name)
        counts["python"] += 1
    if path.suffix == ".sh":
        subprocess.run(["bash", "-n", str(path)], check=True)
        counts["shell"] += 1
    if path.suffix == ".md":
        for target in re.findall(r"!?\[[^\]]*\]\(([^)\s]+)\)", raw.decode()):
            if re.match(r"[a-zA-Z]+:|#", target):
                continue
            target = target.split("#", 1)[0]
            if not (path.parent / target).exists():
                raise ValueError(f"broken local link in {name}: {target}")
            counts["local_links"] += 1

objects = git("rev-list", "--objects", "--all").splitlines()
inventory = {}
for entry in objects:
    oid = entry.split(b" ", 1)[0].decode()
    kind = git("cat-file", "-t", oid).decode().strip()
    inventory[kind] = inventory.get(kind, 0) + 1
    if kind in ("blob", "commit", "tag"):
        privacy(git("cat-file", "-p", oid), oid)
dashboard = json.loads((ROOT / "monitoring/grafana/dashboards/dell-lab-overview.json").read_text())
if len(dashboard["panels"]) != 6 or sum(len(p["targets"]) for p in dashboard["panels"]) != 7:
    raise ValueError("dashboard inventory differs from documented six panels/seven expressions")
subprocess.run(["git", "diff", "--check"], cwd=ROOT, check=True)
print(json.dumps({"source_checks": counts, "reachable_objects_scanned": inventory}, indent=2))
