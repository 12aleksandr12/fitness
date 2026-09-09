---
name: post-change-audit
description: >-
  Opt-in audit of git diff vs Fitness rules. Run only when the user explicitly
  asks «по rules» / «проверь правки» / attaches this skill.
---

# Post-change audit

Opt-in. **Never** after every `Write`. **Never** from a Plan todo named audit.

**Hard rule:** do not claim an audit without `git diff` in this agent.

## How the parent launches

`Task` (`generalPurpose`): run `git diff`, follow this skill. Return 1–2 sentences + reverted/fixed paths.

## Checks

1. Every added line required by the task?
2. Why-only comments, English.
3. No pass-through wrappers; no unused exports.
4. NestJS: no Prisma in controllers; permissions from DB.
5. Flutter: no `Platform.isX` hiding features; repository owns HTTP.
6. ReadLints on edited files.

## Act, do not only report

- **Revert** drive-by / YAGNI (unrelated refactors, speculative layers).
- **Fix in the diff** remaining rule defects: why-only comments, unused exports.
- Do **not** merge unrelated domain mappers into one helper (same `code` in 2 screens → extract; different codes stay local — `dart-standards`).
- Do not expand scope beyond the diff.
