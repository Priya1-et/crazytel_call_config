# Asterisk custom sounds

## consultant-busy (required for busy-wait queue)

Place your announcement WAV here as **`consultant_busy.wav`** (mono 8 kHz recommended).

Example text: *"The consultant is currently engaged on another call. Please try again later."*

Deploy copies this file to:

`/var/lib/asterisk/sounds/custom/consultant-busy.wav`

Dialplan plays: `Playback(custom/consultant-busy)` then `MusicOnHold(crazytel-hold)`.

Also supported at deploy time:

- `crazytel_calling_fe/public/sounds/consultant_busy.wav`

## Hold music (MOH)

Add `.wav` files under `../moh/crazytel-hold/` (see `moh/README.md`).
