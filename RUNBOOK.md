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

## DND note

Dialplan `[check-dnd]` reads Asterisk DB `dnd/venus`. BE `PUT /v1/dnd/venus` updates Nest memory/Postgres only until you sync to Asterisk DB (e.g. deploy script / AMI). FE DND UI is optional.

## TLS / WSS

If WSS fails on cert paths, use `transport-ws` on `8088` **LAN only**, or install certs matching `http.conf` / `pjsip.conf` paths.
