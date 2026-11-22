SHELL := /bin/bash
include .env
export

TEST_DSN ?= root:$(MYSQL_ROOT_PASSWORD)@tcp(127.0.0.1:3306)/

.PHONY: up down logs ps migrate backend-test test-integration web-test mobile-test smoke

up: ## Build and start the full stack (dev override exposes ports on localhost)
	docker compose up -d --build

down:
	docker compose down

logs:
	docker compose logs -f --tail=100

ps:
	docker compose ps

migrate: ## Apply DB migrations manually (the API also applies them on startup)
	docker compose run --rm backend migrate

backend-test: ## Unit tests (no database needed)
	cd backend && go test ./...

test-integration: ## Integration + cross-tenant tests against the compose MySQL
	docker compose up -d mysql
	cd backend && TEST_MYSQL_DSN='$(TEST_DSN)' go test -tags integration -count=1 ./tests/...

web-test:
	cd web && npm ci && npm run lint && npm run test && npm run build

mobile-test:
	cd mobile && flutter pub get && dart run build_runner build --delete-conflicting-outputs && flutter analyze && flutter test

smoke: ## End-to-end smoke test against the running stack
	./scripts/smoke.sh
