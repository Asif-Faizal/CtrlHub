#!/usr/bin/env bash
# End-to-end smoke test against a running CtrlHub stack.
# Expects the API at API_BASE (default http://127.0.0.1:8080/api/v1) and
# MESSAGING_PROVIDER=mock so WhatsApp does not need a real phone.
set -euo pipefail

API_BASE="${API_BASE:-http://127.0.0.1:8080/api/v1}"
ADMIN_EMAIL="${PLATFORM_ADMIN_EMAIL:-admin@ctrlhub.local}"
ADMIN_PASSWORD="${PLATFORM_ADMIN_PASSWORD:?set PLATFORM_ADMIN_PASSWORD}"
AUTOMATION_KEY="${AUTOMATION_API_KEY:?set AUTOMATION_API_KEY}"

json() { python3 -c "import json,sys; d=json.load(sys.stdin); print($1)"; }
post() { curl -fsS -X POST -H "content-type: application/json" "$@"; }
auth() { curl -fsS -H "authorization: Bearer $TOKEN" -H "content-type: application/json" "$@"; }

echo "== health =="
curl -fsS "${API_BASE%/api/v1}/healthz" >/dev/null
curl -fsS "${API_BASE%/api/v1}/readyz" >/dev/null

echo "== platform login =="
SESSION=$(post "$API_BASE/auth/login" -d "{\"email\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}")
TOKEN=$(printf '%s' "$SESSION" | json "d['access_token']")
DASH=$(printf '%s' "$SESSION" | json "d['user']['dashboard']")
test "$DASH" = "platform"

SUFFIX=$(date +%s)
echo "== onboard gym =="
ONBOARD=$(auth -X POST "$API_BASE/platform/tenants" -d "{
  \"gym\": {
    \"name\": \"Smoke Gym $SUFFIX\",
    \"owner_name\": \"Owner\",
    \"contact_number\": \"900000${SUFFIX: -4}\",
    \"email\": \"gym$SUFFIX@example.com\",
    \"city\": \"Bengaluru\",
    \"country\": \"India\",
    \"timezone\": \"Asia/Kolkata\",
    \"currency\": \"INR\"
  },
  \"admin\": {
    \"name\": \"Gym Admin\",
    \"email\": \"admin$SUFFIX@example.com\",
    \"phone\": \"911111${SUFFIX: -4}\"
  }
}")
SETUP_URL=$(printf '%s' "$ONBOARD" | json "d.get('setup_url','')")
TENANT_ID=$(printf '%s' "$ONBOARD" | json "d['tenant']['id']")
test -n "$SETUP_URL"
SETUP_TOKEN=${SETUP_URL##*token=}

echo "== gym admin setup password =="
post "$API_BASE/auth/setup-password" -d "{\"token\":\"$SETUP_TOKEN\",\"password\":\"gym-admin-pass-1\"}" >/dev/null
GYM_SESSION=$(post "$API_BASE/auth/login" -d "{\"email\":\"admin$SUFFIX@example.com\",\"password\":\"gym-admin-pass-1\"}")
GYM_TOKEN=$(printf '%s' "$GYM_SESSION" | json "d['access_token']")
gauth() { curl -fsS -H "authorization: Bearer $GYM_TOKEN" -H "content-type: application/json" "$@"; }

echo "== create second user =="
USER_RES=$(gauth -X POST "$API_BASE/gym/users" -d "{
  \"name\": \"Reception\",
  \"email\": \"desk$SUFFIX@example.com\",
  \"role\": \"RECEPTIONIST\"
}")
printf '%s' "$USER_RES" | json "d['user']['id']" >/dev/null

echo "== create plan + member + membership =="
PLAN=$(gauth -X POST "$API_BASE/gym/plans" -d "{
  \"name\": \"Monthly\",
  \"duration_type\": \"MONTHLY\",
  \"price_minor\": 200000,
  \"is_active\": true
}")
PLAN_ID=$(printf '%s' "$PLAN" | json "d['id']")
MEMBER=$(gauth -X POST "$API_BASE/gym/members" -d "{
  \"full_name\": \"Smoke Member\",
  \"phone\": \"98888${SUFFIX: -5}\",
  \"whatsapp_opt_in\": true,
  \"marketing_opt_in\": true
}")
MEMBER_ID=$(printf '%s' "$MEMBER" | json "d['id']")
MS=$(gauth -X POST "$API_BASE/gym/memberships" -d "{
  \"member_id\": \"$MEMBER_ID\",
  \"plan_id\": \"$PLAN_ID\",
  \"initial_payment_minor\": 200000,
  \"payment_method\": \"UPI\"
}")
printf '%s' "$MS" | json "d['id']" >/dev/null

echo "== cross-tenant denial =="
OTHER=$(auth -X POST "$API_BASE/platform/tenants" -d "{
  \"gym\": {
    \"name\": \"Other Gym $SUFFIX\",
    \"owner_name\": \"Other\",
    \"contact_number\": \"922222${SUFFIX: -4}\",
    \"email\": \"other$SUFFIX@example.com\",
    \"timezone\": \"Asia/Kolkata\"
  },
  \"admin\": { \"name\": \"Other Admin\", \"email\": \"otheradmin$SUFFIX@example.com\" }
}")
OTHER_SETUP=$(printf '%s' "$OTHER" | json "d['setup_url']")
OTHER_TOKEN=${OTHER_SETUP##*token=}
post "$API_BASE/auth/setup-password" -d "{\"token\":\"$OTHER_TOKEN\",\"password\":\"gym-admin-pass-1\"}" >/dev/null
OTHER_SESSION=$(post "$API_BASE/auth/login" -d "{\"email\":\"otheradmin$SUFFIX@example.com\",\"password\":\"gym-admin-pass-1\"}")
OTHER_JWT=$(printf '%s' "$OTHER_SESSION" | json "d['access_token']")
CODE=$(curl -s -o /dev/null -w '%{http_code}' -H "authorization: Bearer $OTHER_JWT" "$API_BASE/gym/members/$MEMBER_ID")
test "$CODE" = "404" -o "$CODE" = "403"

echo "== mock WhatsApp connect + expiry due/send =="
gauth -X POST "$API_BASE/gym/whatsapp/connect" >/dev/null
# Wait briefly for mock provider to become WORKING
for _ in 1 2 3 4 5 6; do
  ST=$(gauth "$API_BASE/gym/whatsapp" | json "d['session']['status']")
  test "$ST" = "WORKING" && break
  sleep 1
done
DUE=$(curl -fsS -H "X-Automation-Key: $AUTOMATION_KEY" "$API_BASE/automation/notifications/due?type=expiry&limit=20")
COUNT=$(printf '%s' "$DUE" | json "d['count']")
echo "due expiry count=$COUNT (may be 0 depending on dates)"
if [ "$COUNT" != "0" ]; then
  TID=$(printf '%s' "$DUE" | json "d['items'][0]['tenant_id']")
  KEY=$(printf '%s' "$DUE" | json "d['items'][0]['dedupe_key']")
  curl -fsS -X POST -H "content-type: application/json" -H "X-Automation-Key: $AUTOMATION_KEY" \
    "$API_BASE/automation/notifications/send" \
    -d "{\"tenant_id\":\"$TID\",\"type\":\"expiry\",\"dedupe_key\":\"$KEY\"}" >/dev/null
fi

echo "SMOKE OK (tenant=$TENANT_ID)"
