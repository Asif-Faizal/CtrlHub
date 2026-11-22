# CtrlHub

Multi-tenant gym management and WhatsApp automation (MVP).

- **Backend:** Go modular monolith, MySQL 8, JWT auth, Clean Architecture  
- **Web:** React + TypeScript (Vite, TanStack Query, Tailwind)  
- **Mobile:** Flutter (BLoC, Dio, get_it, go_router, Freezed)  
- **Automation:** n8n schedules → backend automation API → WAHA or mock WhatsApp  

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), [docs/WAHA_RISKS.md](docs/WAHA_RISKS.md),
and [docs/PROGRESS.md](docs/PROGRESS.md).

## Prerequisites

- Docker Desktop / Docker Compose
- Optional for local iteration: Go 1.26+, Node 22+, Flutter 3.47+, MySQL client

## Quick start

```bash
cp .env.example .env
# edit secrets in .env (JWT_SECRET, AUTOMATION_API_KEY, MYSQL passwords, …)

make up          # docker compose up -d --build
make smoke       # end-to-end API smoke against the running stack
```

Dev override publishes ports on `127.0.0.1` only:

| Service | URL |
| --- | --- |
| Web | http://127.0.0.1:8081 (or `WEB_PORT`) |
| API | http://127.0.0.1:8080 |
| n8n | http://127.0.0.1:5678 |
| WAHA | http://127.0.0.1:3000 |
| MySQL | 127.0.0.1:3306 |

Default platform admin comes from `PLATFORM_ADMIN_EMAIL` /
`PLATFORM_ADMIN_PASSWORD` in `.env`.

## Messaging provider

```bash
MESSAGING_PROVIDER=mock   # default — safe for local/smoke, no WhatsApp
MESSAGING_PROVIDER=waha   # real WAHA (see docs/WAHA_RISKS.md)
```

On Apple Silicon the WAHA image runs under `platform: linux/amd64` emulation.

## Migrations

The API applies embedded SQL migrations on startup (`AUTO_MIGRATE` unless
`false`). To run them manually:

```bash
make migrate
```

## Development without full compose

```bash
docker compose up -d mysql
# from .env: DATABASE_DSN=ctrlhub:...@tcp(127.0.0.1:3306)/ctrlhub
cd backend && go run ./cmd/api

cd web && npm install && npm run dev
cd mobile && flutter pub get && flutter run \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1
```

## Tests

```bash
make backend-test
make test-integration   # needs MySQL from compose
make web-test
make mobile-test
make smoke
```

## Security notes

- Never trust `tenant_id` from a browser or mobile client.
- Do not expose MySQL / WAHA / n8n / API ports publicly in production (base
  `docker-compose.yml` only publishes the web container).
- Keep secrets in `.env` (gitignored). Use `.env.example` as the template.
- Automation routes require `X-Automation-Key` and are blocked at nginx.
