# Asterisk custom sounds

## consultant_busy_tone (required for busy-wait queue)

Place your announcement WAV here as **`consultant_busy_tone.wav`** (mono 8 kHz recommended).

Example text: *"The consultant is currently engaged on another call. Please try again later."*

Deploy copies to:

- `/var/lib/asterisk/sounds/custom/consultant_busy_tone.wav` (primary — dialplan `Playback(custom/consultant_busy_tone)`)
- `/var/lib/asterisk/sounds/custom/consultant-busy.wav` (fallback alias)

Also supported at deploy time: `consultant_busy.wav` under this folder or `crazytel_calling_fe/public/sounds/`.

## Hold music (MOH)

Add `.wav` files under `../moh/crazytel-hold/` (see `moh/README.md`).
