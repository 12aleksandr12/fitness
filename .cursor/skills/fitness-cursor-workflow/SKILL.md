---
name: fitness-cursor-workflow
description: >-
  Fitness Cursor workflow: Plan Mode, Compose for API, Flutter on host,
  Figma tokens later. Use when the user asks how to work in this repo.
disable-model-invocation: true
---

# Fitness Cursor workflow

Slash: `/fitness-cursor-workflow`. Manual only.

1. Ambiguous product work → Plan Mode first.
2. API: `docker compose exec api …` (skill `local-docker-stack`).
3. App: host `flutter run` (FVM). Do not put Flutter in Compose.
4. Stack lock: skill `fitness-stack`.
5. Figma is not in-repo yet — `ThemeExtension` placeholders; swap tokens later, do not rewrite screens for color-only changes.
