# Inbound hold / call waiting — test checklist

| ID | Steps | Pass |
|----|--------|------|
| I-H1 | Answer inbound → **Hold** / **Resume** / timer | ☐ |
| I-H2 | On hold → caller hears MOH | ☐ |
| I-H3 | **Outbound active** → inbound rings → Accept → outbound on hold, inbound active | ☐ |
| I-H4 | End inbound → outbound panel still on hold → **Resume** outbound | ☐ |
| I-H5 | `hold` / `resume` events for inbound → 201 | ☐ |
