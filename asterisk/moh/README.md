# Hold message audio

Place a mono **8 kHz** or **16 kHz** WAV here, then deploy to the server:

```bash
sudo mkdir -p /var/lib/asterisk/moh/crazytel-hold
sudo cp hold-message.wav /var/lib/asterisk/moh/crazytel-hold/
sudo chown -R asterisk:asterisk /var/lib/asterisk/moh
sudo asterisk -rx "moh reload"
```

Suggested content: *"Sorry for the inconvenience, we have put your call on hold."*

Until you add a file, Asterisk may use the `[default]` MOH class.
