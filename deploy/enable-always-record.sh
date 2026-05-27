#!/usr/bin/env bash
# Deploy record-on-answer MixMonitor dialplan + recording dirs.
# Also ensures app_mixmonitor.so is loaded (fixes "No application MixMonitor" / 603).
#
# On server (after git pull):
#   cd ~/Desktop/Crazytel_Calling/crazytel_call_config
#   sudo bash deploy/enable-always-record.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ETC="/etc/asterisk"
SRC_EXT="${ROOT}/asterisk/extensions.conf"
SRC_MOD="${ROOT}/asterisk/modules.conf"
DST_EXT="${ETC}/extensions.conf"
DST_MOD="${ETC}/modules.conf"
TS="$(date +%Y%m%d-%H%M%S)"
BK_EXT="${ETC}/extensions.conf.bak-always-record-${TS}"
BK_MOD="${ETC}/modules.conf.bak-always-record-${TS}"
RECORDINGS="/var/spool/asterisk/recordings"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Run with sudo: sudo bash $0"
  exit 1
fi

if [[ ! -f "${SRC_EXT}" ]]; then
  echo "FAIL: missing ${SRC_EXT}"
  exit 1
fi

if ! grep -q "sub-start-outbound-record" "${SRC_EXT}"; then
  echo "FAIL: repo extensions.conf missing record-on-answer subroutine."
  echo "      Pull latest code or check asterisk/extensions.conf"
  exit 1
fi

if [[ -f "${DST_EXT}" ]]; then
  cp -a "${DST_EXT}" "${BK_EXT}"
  echo "Backed up: ${BK_EXT}"
fi

cp "${SRC_EXT}" "${DST_EXT}"
chown asterisk:asterisk "${DST_EXT}"
chmod 640 "${DST_EXT}"
echo "Installed: ${DST_EXT}"

if [[ -f "${SRC_MOD}" ]]; then
  if [[ -f "${DST_MOD}" ]]; then
    cp -a "${DST_MOD}" "${BK_MOD}"
    echo "Backed up: ${BK_MOD}"
  fi
  cp "${SRC_MOD}" "${DST_MOD}"
  chown asterisk:asterisk "${DST_MOD}"
  chmod 640 "${DST_MOD}"
  echo "Installed: ${DST_MOD} (app_mixmonitor)"
fi

mkdir -p "${RECORDINGS}/incoming" "${RECORDINGS}/outgoing"
chown -R asterisk:asterisk "${RECORDINGS}"
chmod 755 "${RECORDINGS}" "${RECORDINGS}/incoming" "${RECORDINGS}/outgoing"
echo "Recording dirs: ${RECORDINGS}/{incoming,outgoing}"

if ! systemctl is-active --quiet asterisk 2>/dev/null; then
  echo "Starting asterisk..."
  systemctl start asterisk
  sleep 2
fi

load_module() {
  local mod="$1"
  if asterisk -rx "module show like ${mod}" 2>&1 | grep -qE "${mod}\.so.*Running"; then
    echo "OK: ${mod}.so already running"
    return 0
  fi
  echo "Loading ${mod}.so ..."
  asterisk -rx "module load ${mod}.so" || true
}

load_module app_mixmonitor
load_module format_wav

if ! asterisk -rx "core show application MixMonitor" 2>&1 | grep -q "MixMonitor"; then
  echo ""
  echo "FAIL: MixMonitor still not available."
  echo "      Try: sudo systemctl restart asterisk"
  echo "      Then re-run this script."
  exit 1
fi
echo "OK: MixMonitor application is available"

asterisk -rx "dialplan reload"

echo ""
echo "=== Verification ==="
asterisk -rx "dialplan show globals" | grep -E "RECORDINGS_BASE|ENABLE_MIXMONITOR" || true

if asterisk -rx "dialplan show from-webrtc" 2>&1 | grep -q "U(sub-start-outbound-record"; then
  echo "OK: outbound recording uses Dial U (on answer)"
else
  echo "WARN: check dialplan: asterisk -rx \"dialplan show from-webrtc\""
fi

if sudo -u asterisk touch "${RECORDINGS}/outgoing/.write-test" 2>/dev/null; then
  rm -f "${RECORDINGS}/outgoing/.write-test"
  echo "OK: asterisk can write to ${RECORDINGS}/outgoing"
else
  echo "FAIL: asterisk cannot write to ${RECORDINGS}/outgoing"
  exit 1
fi

echo ""
echo "Done. Place a test call, then:"
echo "  sudo ls -lt ${RECORDINGS}/outgoing/"
echo ""
echo "To revert dialplan:"
echo "  sudo cp ${BK_EXT} ${DST_EXT} && sudo asterisk -rx \"dialplan reload\""
echo "To revert modules.conf:"
echo "  sudo cp ${BK_MOD} ${DST_MOD} && sudo systemctl restart asterisk"
