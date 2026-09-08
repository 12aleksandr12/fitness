---
name: fitness-stack
description: >-
  Locked Fitness stack and folder layout: NestJS modular monolith, Flutter
  feature-first, permission catalog, what not to add. Use when adding
  packages, modules, or debating architecture.
---

# Fitness stack (locked)

## API

NestJS 11 + Fastify, Prisma 6, PostgreSQL 16, Redis 7, BullMQ for mail, argon2id, JWT access + hashed refresh. OpenAPI at `/api/v2`.

Modules: `auth`, `users`, `roles`, `schedule`, `booking`, `ledger`, `studio`.

## Flutter

Riverpod, `go_router`, `dio`, `flutter_secure_storage`. Typed DTO / `freezed` when the same JSON is read in 2+ screens — not a repo-wide codegen pass. Theme tokens in `ThemeExtension`. Breakpoints 600 / 900. One repository per feature (`data/`).

## Permissions (catalog in code/seed only)

`manage_roles`, `manage_schedule`, `book_self`, `book_others`, `check_in`, `adjust_balance`, `manage_users`, `view_clients`.

Admin creates **roles** (bundles of these slugs). Do not invent slugs from the UI.

## Do not add

Yii2, Expo, Electron, Supabase-as-auth, GraphQL, TypeORM, GetX, Bloc, CASL, Keycloak, Syncfusion, Nx/Turborepo, CQRS bus, 4-layer Clean folders at repo root.
