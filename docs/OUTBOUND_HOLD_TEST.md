# Outbound hold / resume — test checklist

| ID | Steps | Pass |
|----|--------|------|
| O-H1 | Dial → answer → two-way audio | ☐ |
| O-H2 | **Hold** → remote hears MOH; you hear silence | ☐ |
| O-H3 | Hold **3+ min** → still connected | ☐ |
| O-H4 | **Resume** → two-way audio | ☐ |
| O-H5 | Hold → remote hangs up → UI ends | ☐ |
| O-H6 | Hold → **Hangup** → call ends | ☐ |
| O-H7 | Network tab: `hold` / `resume` events → 201 | ☐ |

Deploy MOH: see `asterisk/moh/README.md`.
