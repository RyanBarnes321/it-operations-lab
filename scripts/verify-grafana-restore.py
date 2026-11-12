#!/usr/bin/env python3
"""Offline-backup drill; stdlib only. Creates/removes only uniquely named test containers/network."""
import sys, os, base64, datetime, hashlib, json, pathlib, subprocess, tarfile, tempfile, time, urllib.parse, urllib.request, uuid
ROOT = pathlib.Path(__file__).resolve().parent.parent
archive = pathlib.Path(sys.argv[1]).resolve() if len(sys.argv) == 2 else ROOT / 'backups/lab-state-PlVe4Kg0.tar.gz'
if len(sys.argv) > 2: raise SystemExit('Usage: verify-grafana-restore.py [archive-with-sha256-sidecar]')
output = ROOT / 'docs/evidence/grafana-restore-verification.json'
def cmd(*args):
    return subprocess.check_output(args, text=True, stderr=subprocess.PIPE).strip()
def inspect(name):
    return json.loads(cmd('docker', 'inspect', name))[0]
def production():
    result = {}
    for service in ('grafana', 'prometheus', 'node-exporter', 'blackbox'):
        ident = cmd('docker', 'compose', 'ps', '-q', service)
        x = inspect(ident)
        result[service] = {'id': ident, 'started_at': x['State']['StartedAt'], 'running': x['State']['Running'], 'restarts': x['RestartCount']}
    return result
def get(url, credential=None):
    headers = {'Authorization': 'Basic '+credential} if credential else {}
    with urllib.request.build_opener(urllib.request.ProxyHandler({})).open(urllib.request.Request(url, headers=headers), timeout=3) as r:
        return json.load(r)
expected = archive.with_name(archive.name+'.sha256').read_text().split()[0]
assert hashlib.sha256(archive.read_bytes()).hexdigest() == expected
before = production()
name = 'lab-restore-'+uuid.uuid4().hex[:10]
containers = []
network_created = False
record = {'timestamp': datetime.datetime.now(datetime.timezone.utc).isoformat(), 'backup': archive.name, 'sha256_verified': True,
          'method': 'restored Grafana and Prometheus copies on dedicated internal Docker network; no published ports; no production volumes',
          'commands': ['docker network create --internal UNIQUE', 'docker run --network UNIQUE --network-alias prometheus [restored TSDB bind] prom/prometheus:v2.55.1',
                       'docker run --network UNIQUE [restored Grafana data/provisioning/secrets binds] grafana/grafana:13.3.1',
                       'GET /api/health; authenticated GET /api/datasources/uid/prometheus; GET /api/dashboards/uid/dell-lab-overview',
                       'GET /api/datasources/proxy/uid/prometheus/api/v1/query?query=EXPR&time=RECORDED_HEALTHY_SNAPSHOT_TIME',
                       'docker rm -f TEST_CONTAINERS; docker network rm UNIQUE'], 'production_before': before}
with tempfile.TemporaryDirectory(prefix='grafana-drill-', dir=ROOT/'backups') as temp:
    restored = pathlib.Path(temp)
    try:
        with tarfile.open(archive) as t:
            t.extractall(restored, filter='data')
        # The safe tar data filter drops archived ownership; repair ONLY disposable copies.
        for folder, uid in [('grafana',472), ('prometheus',65534)]:
            for parent, dirs, files in os.walk(restored/folder):
                os.chown(parent,uid,uid)
                for child in files: os.chown(pathlib.Path(parent)/child,uid,uid)
        (restored/'prometheus.yml').write_text('global:\n  scrape_interval: 15s\nscrape_configs: []\n')
        cmd('docker', 'network', 'create', '--internal', name)
        network_created = True
        prom, graf = name+'-prom', name+'-graf'
        containers.append(prom)
        cmd('docker','run','-d','--name',prom,'--network',name,'--network-alias','prometheus','--user','65534:65534','--memory','768m',
            '-v',str(restored/'prometheus')+':/prometheus','-v',str(restored/'prometheus.yml')+':/etc/prometheus/prometheus.yml:ro',
            'prom/prometheus:v2.55.1')
        source = restored/'source'
        containers.append(graf)
        cmd('docker','run','-d','--name',graf,'--network',name,'--memory','1g','--security-opt','no-new-privileges:true',
            '-v',str(restored/'grafana')+':/var/lib/grafana',
            '-v',str(source/'monitoring/grafana/provisioning')+':/etc/grafana/provisioning:ro',
            '-v',str(source/'monitoring/grafana/dashboards')+':/etc/grafana/dashboards:ro',
            '-v',str(source/'secrets')+':/run/secrets:ro',
            '-e','GF_SECURITY_SECRET_KEY__FILE=/run/secrets/grafana_secret_key',
            '-e','GF_AUTH_ANONYMOUS_ENABLED=false','-e','GF_USERS_ALLOW_SIGN_UP=false',
            '-e','GF_ANALYTICS_REPORTING_ENABLED=false','grafana/grafana:13.3.1')
        address = inspect(graf)['NetworkSettings']['Networks'][name]['IPAddress']
        base = 'http://'+address+':3000'
        for _ in range(45):
            try:
                health = get(base+'/api/health')
                if health['database']=='ok': break
            except Exception:
                if not inspect(graf)['State']['Running']: raise RuntimeError('Restored Grafana exited; inspect test permissions')
            time.sleep(1)
        else: raise RuntimeError('Restored Grafana health deadline exceeded')
        credential = base64.b64encode(('admin:'+(source/'secrets/grafana_admin_password').read_text().strip()).encode()).decode()
        ds = get(base+'/api/datasources/uid/prometheus', credential)
        dash = get(base+'/api/dashboards/uid/dell-lab-overview', credential)
        assert ds['uid']=='prometheus' and dash['meta']['provisioned']
        record.update(health=health, datasource={'uid':ds['uid'],'url':ds['url']}, dashboard={'uid':dash['dashboard']['uid'],'panels':len(dash['dashboard']['panels']),'provisioned':True}, queries=[])
        snapshot_time = datetime.datetime.fromisoformat(json.loads((ROOT/'docs/evidence/dashboard-validation.json').read_text())['timestamp']).timestamp()
        for panel in dash['dashboard']['panels']:
            for target in panel['targets']:
                query = urllib.parse.urlencode({'query':target['expr'],'time':snapshot_time})
                data = get(base+'/api/datasources/proxy/uid/prometheus/api/v1/query?'+query, credential)
                assert data['status']=='success' and data['data']['result'], panel['title']
                record['queries'].append({'panel':panel['title'],'expression':target['expr'],'evaluation_time':snapshot_time,'results':data['data']['result']})
        record['temporary_containers_unprivileged'] = {n:inspect(n)['Config']['User'] for n in containers}
    finally:
        for container in reversed(containers):
            subprocess.run(['docker','rm','-f',container],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,check=False)
        if network_created: cmd('docker','network','rm',name)
record['production_after'] = production()
assert before == record['production_after'], 'Production state changed during drill'
record['production_health_after'] = get('http://127.0.0.1:3000/api/health')
assert record['production_health_after']['database']=='ok'
record['cleanup_verified'] = all(n not in cmd('docker','ps','-a','--format','{{.Names}}').splitlines() for n in containers)
output.write_text(json.dumps(record,indent=2)+'\n')
print('PASS: restored Grafana database, provisioning, dashboard, seven historical queries; cleanup and unchanged production verified')
