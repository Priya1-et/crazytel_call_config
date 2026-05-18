# Deploy helpers

Copy `../asterisk/*.conf` and `../coturn/turnserver.conf` onto the PBX host (paths vary by distro). Prefer packaging these into your own Ansible/Terraform or `include` snippets rather than overwriting full `/etc/asterisk` trees blindly.

Example (manual):

```bash
sudo cp ../asterisk/pjsip.conf /etc/asterisk/pjsip.d/50-crazytel-calling.conf
sudo cp ../asterisk/extensions.conf /etc/asterisk/extensions.d/50-crazytel-calling.conf
sudo cp ../asterisk/rtp.conf /etc/asterisk/rtp.d/50-crazytel-calling.conf
sudo asterisk -rx "dialplan reload"
sudo asterisk -rx "module reload res_pjsip.so"
```
