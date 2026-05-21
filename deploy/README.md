# Deploy helpers (local PBX)

Installs **only** these files on the host (with timestamped backup under `/etc/asterisk/crazytel-backup-*`):

- `pjsip.conf` — replaces old test users (`kartik` / `1001`) with `venus` + `crazytel-trunk`
- `extensions.conf` — Crazytel dialplan
- `rtp.conf` — RTP range + NAT

Does **not** modify other `/etc/asterisk/*` files.

## One command (local)

```bash
cd ~/kartik/Crazytel_calling/crazytel_call_config
sudo bash deploy/install-local-asterisk.sh
```

## Manual (same result)

```bash
cd ~/kartik/Crazytel_calling/crazytel_call_config
sudo mkdir -p /etc/asterisk/crazytel-backup-$(date +%Y%m%d)
sudo cp -a /etc/asterisk/pjsip.conf /etc/asterisk/extensions.conf /etc/asterisk/rtp.conf /etc/asterisk/crazytel-backup-$(date +%Y%m%d)/ 2>/dev/null || true
sudo cp asterisk/pjsip.conf /etc/asterisk/pjsip.conf
sudo cp asterisk/extensions.conf /etc/asterisk/extensions.conf
sudo cp asterisk/rtp.conf /etc/asterisk/rtp.conf
sudo chown asterisk:asterisk /etc/asterisk/pjsip.conf /etc/asterisk/extensions.conf /etc/asterisk/rtp.conf
sudo asterisk -rx "dialplan reload"
sudo asterisk -rx "module reload res_pjsip.so"
sudo asterisk -rx "pjsip show endpoints"
```

## Verify

```bash
sudo asterisk -rx "pjsip show endpoint venus"
sudo asterisk -rx "pjsip show endpoint crazytel-trunk"
sudo asterisk -rx "dialplan show globals"
```

## CLI (do not stop Asterisk)

```bash
sudo systemctl start asterisk
sudo asterisk -r
# inside: pjsip show endpoints
# leave with: exit
```

Use `module reload res_pjsip.so` — there is no `pjsip reload` on this build.
