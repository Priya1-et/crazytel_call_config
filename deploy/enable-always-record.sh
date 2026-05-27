#!/usr/bin/env bash
# Deploy always-on MixMonitor dialplan + recording dirs (temporary testing).
# Safe: backs up /etc/asterisk/extensions.conf before overwrite.
#
# On server (after git pull):
#   cd ~/Desktop/Crazytel_Calling/crazytel_call_config
#   sudo bash deploy/enable-always-record.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ETC="/etc/asterisk"
SRC="${ROOT}/asterisk/extensions.conf"
DST="${ETC}/extensions.conf"
TS="$(date +%Y%m%d-%H%M%S)"
BK="${ETC}/extensions.conf.bak-always-record-${TS}"
RECORDINGS="/var/spool/asterisk/recordings"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run with sudo: sudo bash $0"
  exit 1
fi

if [[ ! -f "${SRC}" ]]; then
  echo "FAIL: missing ${SRC}"
  exit 1
fi

if ! grep -q "recording ALWAYS ON" "${SRC}"; then
  echo "FAIL: repo extensions.conf does not look like always-on recording build."
  echo "      Pull latest code or check asterisk/extensions.conf"
  exit 1
fi

if [[ -f "${DST}" ]]; then
  cp -a "${DST}" "${BK}"
  echo "Backed up: ${BK}"
fi

cp "${SRC}" "${DST}"
chown asterisk:asterisk "${DST}"
chmod 640 "${DST}"
echo "Installed: ${DST}"

mkdir -p "${RECORDINGS}/incoming" "${RECORDINGS}/outgoing"
chown -R asterisk:asterisk "${RECORDINGS}"
chmod 755 "${RECORDINGS}" "${RECORDINGS}/incoming" "${RECORDINGS}/outgoing"
echo "Recording dirs: ${RECORDINGS}/{incoming,outgoing}"

if ! systemctl is-active --quiet asterisk 2>/dev/null; then
  echo "Starting asterisk..."
  systemctl start asterisk
  sleep 2
fi

if ! asterisk -rx "module show like mixmonitor" 2>&1 | grep -q "app_mixmonitor.so"; then
  echo "WARN: app_mixmonitor.so not loaded — check modules.conf"
fi

asterisk -rx "dialplan reload"

echo ""
echo "=== Verification ==="
asterisk -rx "dialplan show globals" | grep -E "RECORDINGS_BASE|ENABLE_MIXMONITOR" || true

if asterisk -rx "dialplan show from-webrtc" 2>&1 | grep -q "ALWAYS ON"; then
  echo "OK: from-webrtc has always-on recording"
else
  echo "WARN: dialplan may not have reloaded — check: asterisk -rx \"dialplan show from-webrtc\""
fi

if sudo -u asterisk touch "${RECORDINGS}/outgoing/.write-test" 2>/dev/null; then
  rm -f "${RECORDINGS}/outgoing/.write-test"
  echo "OK: asterisk can write to ${RECORDINGS}/outgoing"
else
  echo "FAIL: asterisk cannot write to ${RECORDINGS}/outgoing — fix chown/chmod"
  exit 1
fi

echo ""
echo "Done. Place a test call, then:"
echo "  sudo ls -lt ${RECORDINGS}/outgoing/"
echo ""
echo "To revert: restore backup:"
echo "  sudo cp ${BK} ${DST} && sudo asterisk -rx \"dialplan reload\""
