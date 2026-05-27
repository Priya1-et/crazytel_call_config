#!/usr/bin/env bash
# Install Crazytel WebRTC dialplan + PJSIP on THIS host only.
# Touches ONLY: pjsip.conf, extensions.conf, rtp.conf, http.conf (with backup).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ETC="/etc/asterisk"
TS="$(date +%Y%m%d-%H%M%S)"
BK="${ETC}/crazytel-backup-${TS}"
FILES=(pjsip.conf extensions.conf rtp.conf http.conf)

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Re-run with sudo: sudo bash $0"
  exit 1
fi

mkdir -p "$BK"
for f in "${FILES[@]}"; do
  if [[ -f "${ETC}/${f}" ]]; then
    cp -a "${ETC}/${f}" "${BK}/"
    echo "Backed up ${f} -> ${BK}/"
  fi
done

for f in "${FILES[@]}"; do
  cp "${ROOT}/asterisk/${f}" "${ETC}/${f}"
done
chown asterisk:asterisk "${FILES[@]/#/${ETC}/}"
chmod 640 "${FILES[@]/#/${ETC}/}"
echo "Installed Crazytel configs from ${ROOT}/asterisk/"

mkdir -p /var/spool/asterisk/recordings/incoming /var/spool/asterisk/recordings/outgoing
chown -R asterisk:asterisk /var/spool/asterisk/recordings
chmod 750 /var/spool/asterisk/recordings
echo "Recording dirs: /var/spool/asterisk/recordings/{incoming,outgoing}"

if ! systemctl is-active --quiet asterisk 2>/dev/null; then
  echo "Starting asterisk service..."
  systemctl start asterisk
  sleep 2
fi

asterisk -rx "module reload res_http.so" 2>/dev/null || true
asterisk -rx "dialplan reload"
asterisk -rx "module reload res_pjsip.so"

echo ""
echo "=== Verification ==="
if asterisk -rx "pjsip show endpoint venus" 2>&1 | grep -q "Unable to find"; then
  echo "FAIL: endpoint venus not loaded"
  exit 1
fi
if asterisk -rx "pjsip show endpoint crazytel-trunk" 2>&1 | grep -q "Unable to find"; then
  echo "FAIL: endpoint crazytel-trunk not loaded"
  exit 1
fi
if ! asterisk -rx "pjsip show transports" 2>&1 | grep -q "transport-wss.*wss.*8089"; then
  echo "WARN: transport-wss not on 8089 — check http.conf and: pjsip show transports"
fi
asterisk -rx "pjsip show transports"
echo ""
asterisk -rx "pjsip show endpoints"
echo ""
asterisk -rx "dialplan show globals"
echo ""
echo "OK: venus + crazytel-trunk loaded. WSS should be :8089. Backup at ${BK}"
