# Venus busy — announcement + hold music (User 2)

## Flow

1. **User 1 ↔ Venus** — normal call (unchanged).
2. **User 2/3** calls DID while Venus busy:
   - Hears `consultant_busy_tone` announcement (fallback `consultant-busy`) → hold music → repeats.
   - Venus browser gets **call-waiting** popup (SIP INVITE) after the announcement; accept disconnects the current call.
   - Up to **120 seconds** (`BUSY_WAIT_MAX_SEC` in `[globals]`).
3. If Venus becomes free → rings Venus (browser) → normal inbound accept flow.
4. If **timeout**, **User 2 hangs up**, or Venus does not answer → **missed call** (API + red list in UI).

## Audio files

| File | Location |
|------|----------|
| Announcement | `asterisk/sounds/consultant_busy_tone.wav` (installed as `custom/consultant_busy_tone.wav`) |
| Hold music | `asterisk/moh/crazytel-hold/*.wav` |

## Deploy

```bash
# Set MISSED_API_URL in extensions.conf [globals] if BE is not on 127.0.0.1:3001
sudo bash deploy/install-local-asterisk.sh
sudo asterisk -rx "dialplan reload"
sudo asterisk -rx "module reload res_pjsip.so"
```

Requires **curl** on the PBX for missed API posts.

## Tests

| # | Steps |
|---|--------|
| BQ-1 | Venus on call → User 2 calls → hears announcement + music |
| BQ-2 | Venus ends User 1 → User 2 connects (rings browser) |
| BQ-3 | Wait 2 min → User 2 disconnected → missed in red panel |
| BQ-4 | User 2 hangs up while waiting → missed in red panel |
| BQ-5 | Call back from missed list → entry cleared on Dial |
