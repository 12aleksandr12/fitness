---
name: local-docker-stack
description: >-
  Maps Fitness local Docker Compose services and ops (up/recreate/logs/migrate).
  Use when the user mentions docker, compose, postgres, redis, mailpit, prisma,
  NestJS api, or local stack troubleshooting.
---

# Local Docker stack (Fitness)

Project root: repo root. Compose file: `docker-compose.yml` (project name `fitness`).

Flutter SDK runs **on the host** (FVM), not in Compose. From repo root: `./scripts/run-app.sh` (serves `:8080`, does not open a browser) or `./scripts/run-app.sh macos`. From `apps/app`: `../../scripts/run-app.sh`.

## Services

| Service | Role | Ports / notes |
|---------|------|----------------|
| `api` | NestJS (watch) | **3100** → container 3000 |
| `postgres` | PostgreSQL 16 | **5433** → 5432 |
| `redis` | cache / BullMQ | **6380** → 6379 |
| `mailpit` | SMTP catcher | UI **8025** |
| `adminer` | DB UI | **8088** |

## Commands

```bash
docker compose up -d
docker compose logs -f --tail=200 api
docker compose exec api npx prisma migrate dev
docker compose exec api npx prisma db seed
docker compose up -d --no-deps --force-recreate api
```

Flutter → API: `http://localhost:3100` (iOS/macos/chrome), Android emulator `http://10.0.2.2:3100`.

## Debug

1. `docker compose ps`
2. API 502 / crash → `docker compose logs api`
3. Mail not arriving → Mailpit UI `:8025`
4. Prefer targeted recreate over `compose down`.
