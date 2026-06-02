# CRAZYTEL_CALLING — Runbook

## Start order

1. **Firewall** — coturn (if used), Asterisk WSS `8089` / WS `8088`, RTP `10000-20000`, UDP SIP to Crazytel.
2. **coturn** (optional) — see [STUN vs coturn](#stun-vs-coturn) below.
3. **Asterisk** — `sudo bash deploy/install-local-asterisk.sh` (pjsip + **http.conf** for WSS **8089**). FE: `VITE_SIP_WSS_URL=wss://HOST:8089/ws`.
4. **Backend** — `cd crazytel_calling_be && cp .env.example .env && npm run start:dev` (port **3001**).
5. **Frontend** — `cd crazytel_calling_fe && cp .env.example .env && npm run dev` (port **5173**).

## STUN vs coturn

| Use | When |
|-----|------|
| **Google STUN** (`stun:stun.l.google.com:19302` in FE `.env`) | Dev / simple NAT; no server TURN needed |
| **coturn** (`coturn/turnserver.conf`) | Production symmetric NAT, relay required; set `VITE_TURN_URL=turn:YOUR_IP:3478?transport=udp` + credentials |

## Sanity checks

```bash
sudo bash deploy/install-local-asterisk.sh

sudo asterisk -rx "pjsip show endpoints"
sudo asterisk -rx "pjsip show endpoint venus"
sudo asterisk -rx "pjsip show endpoint crazytel-trunk"
sudo asterisk -rx "pjsip show contacts"
sudo asterisk -rx "pjsip show registrations"
```

- IP-auth trunk: **no** Crazytel registration row expected.
- Browser: **Socket connected, registered venus**.

## Pilot test

1. **Outbound** — dial AU mobile `04xxxxxxxx`; CLI from dropdown (`X-Outgoing-Number`).
2. **Inbound** — call a Crazytel DID; UI rings; Accept.
3. **Events** — Network tab: `POST http://localhost:3001/v1/asterisk/events` → **201**.

## Hold / resume (outbound + inbound)

- FE: **Hold** / **Resume** on active outbound panel and inbound modal (SIP re-INVITE).
- Asterisk: `moh_suggest=crazytel-hold` on `venus` + trunk; install `musiconhold.conf` and MOH WAVs.
- Tests: `docs/OUTBOUND_HOLD_TEST.md`, `docs/INBOUND_HOLD_TEST.md`
- Deploy: `sudo bash deploy/install-local-asterisk.sh` then `sudo asterisk -rx "moh reload"`

## Venus busy queue (User 2 while Venus on a call)

- Announcement `custom/consultant-busy` + MOH loop, max **120s**, then missed call.
- `device_state_busy_at=1` on `venus` — no parallel browser ring while busy.
- Set `MISSED_API_URL` in `extensions.conf` `[globals]`; PBX needs **curl**.
- Audio: `asterisk/sounds/consultant_busy.wav` (see `asterisk/sounds/README.md`).
- Tests: `docs/BUSY_WAIT_QUEUE.md`

## Call recording (MixMonitor)

- **Outbound / inbound:** Every **answered** call is recorded (Yes/No in the UI does not change Asterisk). Files: `outgoing/` and `incoming/` under `RECORDINGS_BASE`.
- **Outbound:** `Dial(...,U(sub-start-outbound-record^s^1))` — MixMonitor starts when the trunk leg answers.
- **Inbound:** `Dial(...,U(sub-start-inbound-record...))` — MixMonitor starts when the consultant answers.
- **Paths:** `RECORDINGS_BASE=/var/spool/asterisk/recordings`; deploy scripts set `chmod 755` and `chown asterisk`. Backend user needs read access (see BE `RECORDINGS_DIR`).
- **Module:** `app_mixmonitor.so` in `asterisk/modules.conf`.

Dialplan `[check-dnd]` reads Asterisk DB `dnd/venus`. BE `PUT /v1/dnd/venus` updates Nest memory/Postgres only until you sync to Asterisk DB (e.g. deploy script / AMI). FE DND UI is optional.

## TLS / WSS

If WSS fails on cert paths, use `transport-ws` on `8088` **LAN only**, or install certs matching `http.conf` / `pjsip.conf` paths.
