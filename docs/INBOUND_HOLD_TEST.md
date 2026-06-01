# Inbound hold / call waiting — test checklist

| ID | Steps | Pass |
|----|--------|------|
| I-H1 | Answer inbound → **Hold** / **Resume** / timer | ☐ |
| I-H2 | On hold → caller hears MOH | ☐ |
| I-H3 | **Outbound active** → inbound rings → Accept → **outbound disconnected**, inbound active | ☐ |
| I-H4 | **Outbound active** → inbound rings → Reject / no answer → **red missed call**, outbound continues | ☐ |
| I-H5 | **Call back** from missed list → fills dial → Dial → missed entry removed | ☐ |
| I-H5 | `hold` / `resume` events for inbound → 201 | ☐ |
