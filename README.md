# crazytel_call_config

Infra templates for **Browser (WebRTC) → coturn → Asterisk → Crazytel → PSTN**.

| Path | Purpose |
|------|---------|
| `asterisk/pjsip.conf` | PJSIP WSS/WS + WebRTC user + Crazytel UDP trunk |
| `asterisk/extensions.conf` | `from-webrtc` / `from-crazytel` dialplan |
| `asterisk/rtp.conf` | RTP port range + ICE |
| `asterisk/http.conf` | HTTP/TLS for WebSocket (parity with Iagu ops) |
| `asterisk/modules.conf` | Minimal module load list for PJSIP + WebRTC |
| `asterisk/cdr.conf` | CDR enabled (parity) |
| `asterisk/cel.conf` | CEL enabled (parity) |
| `coturn/turnserver.conf` | TURN relay (placeholders) |
| `deploy/README.md` | Example copy commands |
| `RUNBOOK.md` | Start order and sanity checks |
| `REPLACEMENT_CHECKLIST.md` | Everything you must obtain from Crazytel / ops |
| `FLOW_AND_CRAZYTEL_VS_IAGU.md` | Architecture and IAGU vs Crazytel summary |

No IAGU hostnames or `iagu-trunk` identifiers appear in this tree.

## WebRTC user and outbound CLI

- Default WebRTC PJSIP user is **`venus`** (matches `VITE_SIP_USERNAME` in the frontend).
- Default verified CLI/DID is **`61272643281`** (E.164). Inbound accepts `61…` / `0…` / `+…` and normalizes to **`61272643281`**. Override with **`VITE_VERIFIED_OUTBOUND_NUMBERS`**. Enable **international calling** in Crazytel for `0011…` / India / US etc.
- **Crazytel trunk** uses **IP authentication** (like IAGU): PBX public IP **`223.178.215.86`** must be allowlisted at Crazytel; trunk host **`sip.biz.crazytel.net.au`**; endpoint **`crazytel-trunk`**; no SIP registration. Optional username/password blocks are commented in `pjsip.conf` if your account requires them instead.
