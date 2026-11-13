# Encrypted off-device backup and recovery

Status: the user reports a completed encrypted Windows backup round trip, matching
original SHA-256, isolated application restore, and successful recovery using a
passphrase-encrypted USB identity copy. The existing returned-archive restore JSON
is consistent with that report. These were user-executed activities, not Windows
transfers performed by this final Codex session. See [evidence](../TEST-EVIDENCE.md).
Offsite storage and a recurring backup cadence remain unverified.

Use the Windows desktop as a **pull destination over existing LAN SSH**, storing
only age-encrypted archives. No incoming Windows service is needed. The desktop
must be awake and have free space when pulling; missed copies must be reported,
not counted as successful backups. Same-house desktop storage is off-device, not
offsite: fire, theft and electrical damage can affect both machines. Offsite storage
requires an already available independently located disk/device or approved service;
none is verified. No paid storage is proposed.

The portable [age tool](https://github.com/FiloSottile/age) supports recipient
public-key encryption. The locally tested Linux v1.3.2 binary lives under ignored
`runtime/age/`; its SHA256 matched the official GitHub release asset digest.
That is a same-origin integrity check, not independent release-signature validation.
Local testing encrypted the existing state archive, decrypted it and compared SHA256,
then modified ciphertext and confirmed decryption rejection. Temporary test identity,
ciphertext and restored copies were removed. See backup-encryption-drill.json.

## One-time Windows preparation (user action)

Obtain portable age v1.3.2 Windows binaries from the
[official release](https://github.com/FiloSottile/age/releases/tag/v1.3.2), verify
the asset SHA256 against the official release digest, and extract under your user
profile. No system installation is required. The examples assume executables in
`$HOME\Tools\age\`; adjust to their actual extracted location. If this portable
tool is not acceptable, leave the gate pending rather than transferring plaintext.

In PowerShell 7, as the normal desktop user:

```powershell
$age = Join-Path $HOME 'Tools\age\age.exe'
$keygen = Join-Path $HOME 'Tools\age\age-keygen.exe'
$vault = Join-Path $HOME 'ITLabBackups'
New-Item -ItemType Directory -Force $vault | Out-Null
icacls $vault /inheritance:r /grant:r "${env:USERNAME}:(OI)(CI)F"
if ($LASTEXITCODE -ne 0) { throw 'Directory ACL setup failed' }
& $keygen -o "$vault\identity.txt"
if ($LASTEXITCODE -ne 0) { throw 'Identity generation failed; do not overwrite an existing identity' }
& $keygen -y "$vault\identity.txt"
```

Provide **only the public `age1...` recipient** to the Dell administrator. Never
send `identity.txt`, paste it into chat or commit it. Check the directory ACL; an
administrator/account compromise can still access decrypted files. Keep a second
protected copy of the identity on an existing offline device or use an established
password manager with independent recovery. Without recoverable identity, backups
are unusable. The user confirms a passphrase-encrypted USB copy was tested successfully and
that both recovery key and passphrase are safely stored. Do not inspect, send or
collect either. For a new deployment, independently establish and test recovery
without overwriting the existing identity.

## Dell encryption and export (after public recipient is provided)

Run locally as the authorized lab administrator. Use an existing verified archive;
create a fresh state backup in a maintenance window when appropriate. Substitute
its actual filename and the public recipient. Never supply a private identity.

```sh
cd /opt/it-operations-lab
# Replace with the authorized export account on your own host.
LAB_SSH_USER=your-lab-user
umask 077
sha256sum -c backups/lab-state-PlVe4Kg0.tar.gz.sha256
runtime/age/age -r 'age1PUBLIC_RECIPIENT_HERE' \
  -o backups/lab-state-PlVe4Kg0.tar.gz.age backups/lab-state-PlVe4Kg0.tar.gz
install -d -o "$LAB_SSH_USER" -g "$(id -gn "$LAB_SSH_USER")" -m 700 runtime/export
install -o "$LAB_SSH_USER" -g "$(id -gn "$LAB_SSH_USER")" -m 600 backups/lab-state-PlVe4Kg0.tar.gz.age runtime/export/
cd runtime/export
sha256sum lab-state-PlVe4Kg0.tar.gz.age > lab-state-PlVe4Kg0.tar.gz.age.sha256
chown "$LAB_SSH_USER:$(id -gn "$LAB_SSH_USER")" lab-state-PlVe4Kg0.tar.gz.age.sha256
chmod 600 lab-state-PlVe4Kg0.tar.gz.age.sha256
```

These targeted permissions apply only to newly exported ciphertext. The root-only
plaintext backup and live secrets remain unchanged. Do not make the plaintext archive
readable to facilitate scp. The export directory is ignored through `/runtime/`.

Replace `<lab-user>` and `<lab-address>` below with your own trusted SSH destination.
The named archive is the historical tested generation; use your actual verified
generation and its sidecar when making a newer backup.

## Windows pull, integrity check and recovery

```powershell
scp '<lab-user>@<lab-address>:/opt/it-operations-lab/runtime/export/lab-state-PlVe4Kg0.tar.gz.age' "$vault\"
if ($LASTEXITCODE -ne 0) { throw 'Backup copy failed' }
scp '<lab-user>@<lab-address>:/opt/it-operations-lab/runtime/export/lab-state-PlVe4Kg0.tar.gz.age.sha256' "$vault\"
if ($LASTEXITCODE -ne 0) { throw 'Checksum copy failed' }
$encrypted = Join-Path $vault 'lab-state-PlVe4Kg0.tar.gz.age'
$expected = ((Get-Content "$encrypted.sha256").Trim() -split '\s+')[0]
if ((Get-FileHash $encrypted -Algorithm SHA256).Hash -ne $expected) { throw 'Hash mismatch' }
& $age -d -i "$vault\identity.txt" -o "$vault\restore-test.tar.gz" $encrypted
if ($LASTEXITCODE -ne 0) { throw 'Decryption failed; discard any partial output' }
tar -tzf "$vault\restore-test.tar.gz" > $null
if ($LASTEXITCODE -ne 0) { throw 'Archive validation failed' }
```

Keep decrypted material only in the protected directory. Do not extract into the
repository, Downloads, shared folders or automatically synced directories. The
archive listing is only an integrity check, not application restoration. Close the
end-to-end recovery gate by transferring the archive back over SSH into a private
Dell staging directory, comparing it with the original SHA256, placing a matching `.sha256` sidecar next
to it, and running the
isolated Grafana/Prometheus drill against that recovered copy:
`python3 scripts/verify-grafana-restore.py /private/staging/returned-state.tar.gz`.
The current drill uses this known backup and its original healthy snapshot timestamp. Never overwrite live
volumes. Remove only the drill plaintext after success; ordinary deletion does not
guarantee secure erasure on SSDs. Encryption at rest on Windows remains important.

Manual retention proposal: retain seven successful recent generations and four
weekly generations **after** verifying a newer copy and recoverable key; do not
install automatic deletion yet. Check free space before each run. Record UTC time,
archive identifier, encrypted-file hash, transfer result and drill result, without
keys/credentials/host details. Review monthly and after configuration changes.
No guaranteed RPO/RTO is claimed while copying is manual and desktop availability
is unknown. For every new generation, record success only after real off-device transfer and
recovery verification. The reported round trip closes the original functional gate;
an encrypted copy on the Dell alone does not establish off-device protection.


## USB identity recovery verification

For this release the user reports a passphrase-encrypted USB copy of the age
private identity. A subsequent recovery test decrypted the stored backup and the
plaintext archive SHA-256 matched the previously verified backup. The user confirms
safe storage of the USB recovery key and passphrase. Neither was inspected by Codex.

For future drills, use the protected recovery copy locally, compare decrypted
archive bytes against the trusted original SHA-256 and perform the isolated
application restore. Keep identities and temporary plaintext outside the checkout
and shared/synced folders. Do not put passphrases in command arguments, shell
history or result records. Do not overwrite a known-good identity or delete the
last recoverable backup while testing. Record only sanitized outcomes.
