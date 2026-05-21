#!/usr/bin/env bash
# Install Crazytel WebRTC dialplan + PJSIP on THIS host only.
# Touches ONLY: /etc/asterisk/pjsip.conf, extensions.conf, rtp.conf (with backup).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ETC="/etc/asterisk"
TS="$(date +%Y%m%d-%H%M%S)"
BK="${ETC}/crazytel-backup-${TS}"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Re-run with sudo: sudo bash $0"
  exit 1
fi

mkdir -p "$BK"
for f in pjsip.conf extensions.conf rtp.conf; do
  if [[ -f "${ETC}/${f}" ]]; then
    cp -a "${ETC}/${f}" "${BK}/"
    echo "Backed up ${f} -> ${BK}/"
  fi
done

cp "${ROOT}/asterisk/pjsip.conf" "${ETC}/pjsip.conf"
cp "${ROOT}/asterisk/extensions.conf" "${ETC}/extensions.conf"
cp "${ROOT}/asterisk/rtp.conf" "${ETC}/rtp.conf"
chown asterisk:asterisk "${ETC}/pjsip.conf" "${ETC}/extensions.conf" "${ETC}/rtp.conf"
chmod 640 "${ETC}/pjsip.conf" "${ETC}/extensions.conf" "${ETC}/rtp.conf"
echo "Installed Crazytel configs from ${ROOT}/asterisk/"

if ! systemctl is-active --quiet asterisk 2>/dev/null; then
  echo "Starting asterisk service..."
  systemctl start asterisk
  sleep 2
fi

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
asterisk -rx "pjsip show endpoints"
echo ""
asterisk -rx "dialplan show globals"
echo ""
echo "OK: venus + crazytel-trunk loaded. Backup at ${BK}"
