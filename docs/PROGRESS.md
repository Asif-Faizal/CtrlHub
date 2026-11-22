# Implementation progress

This file tracks what is implemented and, separately, what has actually been
verified. "Implemented" means code exists; "Verified" means it was exercised by
an automated test or a manual run described here.

## Phase status

| Phase | Implemented | Verified |
| --- | --- | --- |
| 1. Foundation (Go skeleton, MySQL schema, migrations, compose) | Yes | Yes |
| 2. Auth, roles, platform onboarding | Yes | Yes |
| 3. Gym management | Yes | Yes |
| 4. WhatsApp (WAHA adapter + mock) | Yes | Partially |
| 5. Automation API + n8n workflows | Yes | Partially |
| 6a. React web app | Yes | Yes (lint/test/build) |
| 6b. Flutter app | Yes | Yes (analyze/test) |
| 7. OpenAPI, smoke, docs | Yes | Partially |

## Verification log

### Backend unit tests (`cd backend && go test ./...`)

- `internal/domain`: membership date maths, renewal start, payment status,
  template rendering, phone normalisation, permission matrix.
- `internal/infrastructure/waha`: adapter against an `httptest` fake that
  asserts documented paths, `X-Api-Key`, and payloads.

### Backend integration tests (`make test-integration`)

Run against MySQL 8.4 from compose. Each test creates and drops its own
database and drives the real HTTP router. All 13 tests passed:

| Test | Covers |
| --- | --- |
| `TestPlatformLoginAndDashboardRouting` | Platform login, onboarding, dashboard routing |
| `TestSetupLinkIsSingleUse` | One-time password setup links |
| `TestRefreshTokenRotationAndReuseDetection` | Refresh rotation; reuse revokes sessions |
| `TestRolePermissionsEnforcedByBackend` | Receptionist/trainer blocked server-side |
| `TestTenantDeactivationLocksOutGym` | Inactive tenant rejected |
| `TestUserLimitPerTenant` | `max_users` enforced |
| `TestAutomationRequiresKey` | Automation API key required |
| `TestWhatsAppConnectAndTestMessage` | Connect/QR/test via mock provider |
| `TestExpiryHolidayBirthdayAndReportAutomation` | Due lists, consent, dedupe |
| `TestCampaignApprovalAndDelivery` | Approval + consented recipients |
| `TestMembershipLifecycle` | Plans, assign, renew, payments |
| `TestValidationErrorsAreConsistent` | Error envelope |
| `TestCrossTenantIsolation` | Cross-tenant 403/404 |

### Web (`cd web && npm run lint && npm test && npm run build`)

- Vitest: 13 tests passed.
- Production build succeeded.
- Docker image built; nginx health endpoint returned `ok`.
- `/api/v1/automation` returns 404 through nginx (blocked).

### Mobile (`cd mobile && flutter analyze && flutter test`)

- `flutter analyze`: no issues.
- `flutter test`: 3 tests passed (auth BLoC + formatMoney).

### Compose / smoke

- `mysql`, `backend`, `web`, `waha` started. Backend `/healthz` and `/readyz`
  returned 200; platform login succeeded earlier in development.
- **n8n-init / n8n:** not verified end-to-end. Pulling/importing n8n failed on
  this machine when the disk filled (`read-only file system` /
  `ERR_INVALID_PACKAGE_CONFIG` on a corrupted `n8n:latest` layer). Workflow JSON
  files and `n8n/workflows/import.sh` are present for re-import once Docker has
  free space.
- **`scripts/smoke.sh`:** implemented; re-run with `make smoke` after
  `docker compose up` once disk pressure is cleared.
- **Real WAHA / WhatsApp:** not verified (requires scanning a QR on a real
  number). Default provider remains `mock`.

## Known limitations

- Mock WhatsApp keeps session state in memory; backend restart clears it.
- On this Apple Silicon host, `nginx:1.27-alpine` multi-arch resolution was
  unreliable, so the web image is built for `linux/amd64` (emulated). See
  `web/Dockerfile` and the `platform` on the `web` service.
- WAHA service uses `platform: linux/amd64` (official free image has no arm64).
- Host disk was critically low (~100 MiB free) during final compose work;
  reclaim space before relying on n8n image pulls.
