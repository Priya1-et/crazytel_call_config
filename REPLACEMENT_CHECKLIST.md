# What you need to replace IAGU with Crazytel (checklist)

Fill these from the **Crazytel portal** / support. Nothing from IAGU should be copied into `crazytel_call_config/` (clean tree).

## Account & compliance

- [ ] Crazytel business account active; **international** outbound enabled if you need it.
- [ ] **Verified outbound caller ID** numbers (must match what Asterisk sends in `CALLERID(num)` / `DEFAULT_OUTBOUND_CLI`).
- [ ] **DIDs**: new numbers or **port-in** schedule from IAGU; inbound format often **`61…`** (no `+`).

## SIP trunk (Asterisk `pjsip.conf`) — configured for IP auth (IAGU-style)

- [x] **SIP host** `sip.biz.crazytel.net.au` on `[crazytel-trunk]` aor `contact=` (replaces `iagu.net`).
- [ ] **Crazytel portal**: allowlist PBX public IP **`223.178.215.86`** (required for IP trunk).
- [ ] **Non-default port** on trunk: change `contact=sip:sip.biz.crazytel.net.au:PORT` if portal shows not 5060.
- [ ] **Inbound identify**: `match=sip.biz.crazytel.net.au` **and** uncomment/add Crazytel **SBC IP** `match=` lines in `pjsip.conf` (hostname alone is often insufficient).
- [ ] **International** outbound enabled on Crazytel account if using `0011…` dial patterns.
- [ ] **Username/password trunk** only if Crazytel rejects IP auth — use commented blocks in `pjsip.conf`.
- [x] **Codecs**: trunk **ulaw/alaw**; WebRTC **Opus + ulaw** on `venus`.

## TLS / WebRTC (browser)

- [ ] **TLS certificate** paths on the PBX for **WSS** (`transport-wss`, port `8089` in template).
- [ ] **Strong WebRTC SIP password** for **`venus`** (must match `VITE_SIP_PASSWORD`).

## coturn

- [ ] **Public IPv4** (`external-ip`, `relay-ip` in `turnserver.conf`).
- [ ] **Realm** and **TURN username/password** (match `VITE_TURN_*`).

## Dialplan (`extensions.conf`)

- [ ] `DEFAULT_OUTBOUND_CLI` set to a **verified** AU national number (`0…`).
- [x] Inbound `Dial(PJSIP/venus,…)` — keep in sync with `VITE_SIP_USERNAME=venus`.

## Frontend (`crazytel_calling_fe/.env`)

- [ ] `VITE_API_BASE_URL` — your Nest API (e.g. `http://localhost:3001`).
- [ ] `VITE_SIP_WSS_URL` / `VITE_SIP_DOMAIN` — your Asterisk WebSocket URL and SIP domain/host.
- [ ] `VITE_SIP_USERNAME` / `VITE_SIP_PASSWORD` — same as WebRTC PJSIP auth in Asterisk.
- [ ] `VITE_TURN_URL` — e.g. `turn:YOUR_PUBLIC_HOST:3478?transport=udp` (and credentials if using lt-cred-mech).

## Backend (`crazytel_calling_be/.env`)

- [ ] `PORT`, `CORS_ORIGIN` (include Vite dev origin `http://localhost:5173`).

## IAGU wind-down (commercial — not in repo)

- [ ] Minimum term, ETF, port-out fee, notice period (from IAGU contract/support).

## Optional confirmation with Crazytel support

- [ ] Whether **P-Preferred-Identity** / **P-Asserted-Identity** is required for CLI beyond `From` / `CALLERID(num)`.
- [ ] Exact **dial string** rules if anything differs from **AU `0…`** and **`0011…`** international.
