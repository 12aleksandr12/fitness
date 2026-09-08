# Fitness

Студийное приложение: запись на тренировки, роли (админ создаёт роли из каталога прав), баланс абонемента. Один Flutter-клиент на iOS, Android, macOS, Windows и Web. API — NestJS в Docker.

## Локально

```bash
cp .env.example .env
docker compose up -d
```

- API: http://localhost:3100/api/v2  
- OpenAPI: http://localhost:3100/api/v2/docs  
- Mailpit: http://localhost:8025  
- Adminer: http://localhost:8088  
- Postgres на хосте: **5433** (внутри сети Compose — 5432)
- Redis на хосте: **6380**  

Seed:

| Email | Пароль | Роль |
|-------|--------|------|
| admin@fitness.local | Password123! | Администратор |
| trainer@fitness.local | Password123! | Тренер |
| client@fitness.local | Password123! | Участник |

```bash
# из корня репозитория (fitness), не из apps/app
./scripts/run-app.sh
# из apps/app:
../../scripts/run-app.sh
```

Сервер: http://localhost:8080 — браузер не открывается, добавьте закладку сами.

Окно приложения (нужен Xcode): `./scripts/run-app.sh macos`

Android emulator: API `http://10.0.2.2:3100`.
