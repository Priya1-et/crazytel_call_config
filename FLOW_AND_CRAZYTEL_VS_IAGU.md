# CRAZYTEL_CALLING — Architecture flow, Crazytel vs IAGU, and replacement approach

See `REPLACEMENT_CHECKLIST.md` for values to obtain from Crazytel. This file is the conceptual map.

## Target path

**Browser (WebRTC + sip.js) → coturn (TURN) → Asterisk (PJSIP WSS + UDP trunk) → Crazytel → PSTN.**

- The browser registers **only** to Asterisk (not to Crazytel).
- Crazytel is a **SIP trunk** from Asterisk, same **architectural slot** IAGU occupied: **PBX ↔ carrier ↔ PSTN**.

## Crazytel (this project)

- **UDP** SIP to carrier; **WSS** (or WS in lab) from browser.
- **Outbound dial format**: AU **national `0…`**; international **`0011…`**. Avoid sending `+` or bare `61…` for AU to the trunk unless Crazytel confirms otherwise.
- **Inbound DID** often **`61…`** without `+`.
- **Outbound CLI** must be **verified** in the Crazytel portal.

## IAGU (previous)

- Same role: **Asterisk → IAGU → PSTN**. Dial strings and CLI rules may differ; do not assume IAGU patterns work on Crazytel.

## Replacement approach

1. Configure **Crazytel trunk + identify + registration** in `pjsip.conf` with portal values.
2. Set **dialplan** contexts `from-webrtc` / `from-crazytel`.
3. Align **WebRTC user** password and **frontend** `VITE_*` with Asterisk.
4. **Pilot** outbound + inbound, then **port or renumber** DIDs and retire IAGU.

All infra templates live under `crazytel_call_config/` with **no IAGU hostnames** or `iagu-trunk` names.
