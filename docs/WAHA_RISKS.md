# WhatsApp / WAHA risk notice

CtrlHub integrates with [WAHA](https://waha.devlike.pro/) (WhatsApp HTTP API)
for per-gym messaging. **WAHA is unofficial WhatsApp connectivity.** It is not
a Meta Business / Cloud API partner product.

## Risks you must accept

- WhatsApp may restrict, ban, or challenge numbers that use unofficial clients.
- Session disconnects, QR re-scans, and sudden API changes are expected.
- Bulk or promotional traffic without clear consent increases ban risk.
- WAHA credentials (`WAHA_API_KEY`, dashboard passwords) must stay private and
  must not be committed to source control.

## How CtrlHub mitigates (MVP)

- Default local provider is **`MESSAGING_PROVIDER=mock`** — no real WhatsApp.
- Campaigns require an approval step before n8n can deliver them.
- Marketing sends require `marketing_opt_in` (and WhatsApp consent) and are
  re-checked at send time.
- Message volume is bounded by each gym's `daily_message_limit`.
- Automated sends are deduplicated in `notification_logs`.
- The public nginx config blocks `/api/v1/automation` so the automation key is
  not reachable from the browser.

## Production guidance

- Prefer Meta's official WhatsApp Business Platform for anything customer-facing
  at scale.
- If you still run WAHA, use a dedicated number, keep daily volume low, honour
  opt-outs immediately, and monitor session health.
- Do **not** run real bulk sends without explicit operator approval.
