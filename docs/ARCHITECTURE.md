# Architecture

CtrlHub is a **modular monolith**: one Go API process, one MySQL database, one
React web app, one Flutter mobile app, plus n8n (schedules) and WAHA (WhatsApp
transport). There are no microservices, no Redis, and no message brokers in the
MVP.

## Runtime diagram

```
┌────────────┐   JWT    ┌──────────────────┐        ┌──────────┐
│ React web  │─────────▶│                  │───────▶│ MySQL 8  │
│ Flutter    │          │  Go API (chi)    │        └──────────┘
└────────────┘          │  Clean Arch      │
                        │                  │◀──────┐
┌────────────┐  X-Auto  │  /api/v1/...     │       │ X-Api-Key
│ n8n        │─────────▶│  /automation/*   │───────▶│ WAHA
└────────────┘          └──────────────────┘       └──────────┘
```

## Backend layers

| Layer | Path | Responsibility |
| --- | --- | --- |
| Interfaces | `backend/internal/interfaces` | HTTP routing, middleware, DTOs |
| Application | `backend/internal/application` | Use cases (auth, tenant, member, messaging, automation, …) |
| Domain | `backend/internal/domain` | Entities, permissions, date/money helpers |
| Infrastructure | `backend/internal/infrastructure` | MySQL store, WAHA client, mock WhatsApp |

Composition root: `backend/internal/app` wires config, DB, messaging provider,
and services. Entry point: `backend/cmd/api`.

## Tenancy

- Every gym row carries `tenant_id`.
- JWT subjects are user IDs only. Role and `tenant_id` are loaded from the
  database on every request into a `Principal`.
- Gym routes never accept a client-supplied tenant id.
- Composite foreign keys `(tenant_id, parent_id)` keep child rows inside the
  same gym.

## Roles

`PLATFORM_ADMIN` manages gyms. Gym roles are `GYM_ADMIN`, `GYM_MANAGER`,
`RECEPTIONIST`, and `TRAINER`. Permissions are enforced in Go
(`domain/roles.go`); frontends only hide UI.

## Messaging

`MessagingProvider` abstracts WhatsApp. Implementations:

- **mock** (default for local/smoke): in-memory sessions, placeholder QR, no
  network calls.
- **waha**: HTTP adapter against documented WAHA endpoints. Session name equals
  the tenant code (`gym_001`, …).

## Automation

n8n workflows call `/api/v1/automation/*` with `X-Automation-Key`. The backend
recomputes eligibility (consent, connected session, settings) and claims a
`notification_logs` dedupe key before sending, so retries are safe.

## Frontends

- **web/**: Vite + React + TanStack Query + React Router. Nginx serves the build
  and proxies `/api/` to the backend while blocking `/api/v1/automation`.
- **mobile/**: Flutter with BLoC, Dio (refresh interceptor), get_it, go_router,
  Freezed models, and secure token storage.
