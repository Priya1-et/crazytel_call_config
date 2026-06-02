#!/usr/bin/env bash
# Install Crazytel WebRTC dialplan + PJSIP on THIS host only.
# Touches ONLY: pjsip.conf, extensions.conf, rtp.conf, http.conf (with backup).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ETC="/etc/asterisk"
TS="$(date +%Y%m%d-%H%M%S)"
BK="${ETC}/crazytel-backup-${TS}"
FILES=(pjsip.conf extensions.conf modules.conf rtp.conf http.conf musiconhold.conf)

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
chmod 755 /var/spool/asterisk/recordings /var/spool/asterisk/recordings/incoming /var/spool/asterisk/recordings/outgoing
echo "Recording dirs: /var/spool/asterisk/recordings/{incoming,outgoing}"

mkdir -p /var/lib/asterisk/moh/crazytel-hold
if [[ -f "${ROOT}/asterisk/moh/hold-message.wav" ]]; then
  cp "${ROOT}/asterisk/moh/hold-message.wav" /var/lib/asterisk/moh/crazytel-hold/
  echo "Installed hold-message.wav -> /var/lib/asterisk/moh/crazytel-hold/"
fi
chown -R asterisk:asterisk /var/lib/asterisk/moh
echo "MOH dir: /var/lib/asterisk/moh/crazytel-hold (add hold-message.wav if missing)"

mkdir -p /var/lib/asterisk/sounds/custom
BUSY_SRC=""
for candidate in \
  "${ROOT}/asterisk/sounds/consultant_busy_tone.wav" \
  "${ROOT}/asterisk/sounds/consultant_busy.wav" \
  "${ROOT}/../crazytel_calling_fe/public/sounds/consultant_busy_tone.wav" \
  "${ROOT}/../crazytel_calling_fe/public/sounds/consultant_busy.wav" \
  "${ROOT}/../crazytel_calling_fe/public/sounds/consultaltn_busy.wav"; do
  if [[ -f "${candidate}" ]]; then
    BUSY_SRC="${candidate}"
    break
  fi
done
if [[ -n "${BUSY_SRC}" ]]; then
  cp "${BUSY_SRC}" /var/lib/asterisk/sounds/custom/consultant_busy_tone.wav
  cp "${BUSY_SRC}" /var/lib/asterisk/sounds/custom/consultant-busy.wav
  echo "Installed consultant_busy_tone.wav (+ consultant-busy alias) from ${BUSY_SRC}"
else
  echo "WARN: No consultant_busy_tone.wav — add asterisk/sounds/consultant_busy_tone.wav"
fi
chown -R asterisk:asterisk /var/lib/asterisk/sounds/custom

if ! systemctl is-active --quiet asterisk 2>/dev/null; then
  echo "Starting asterisk service..."
  systemctl start asterisk
  sleep 2
fi

asterisk -rx "module load res_curl.so" 2>/dev/null || true
asterisk -rx "module load func_curl.so" 2>/dev/null || true
asterisk -rx "module load app_system.so" 2>/dev/null || true
asterisk -rx "module load app_wait.so" 2>/dev/null || true
asterisk -rx "module reload res_http.so" 2>/dev/null || true
asterisk -rx "module reload" 2>/dev/null || true
asterisk -rx "dialplan reload"
asterisk -rx "module reload res_pjsip.so"
asterisk -rx "moh reload" 2>/dev/null || true

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
