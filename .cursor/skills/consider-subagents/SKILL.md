---
name: consider-subagents
description: >-
  Decide on every user request whether Task/subagents help. Always-on via
  core.mdc: run the gate silently; launch when YES.
---

# Consider subagents

**Always-on:** `core.mdc` requires this at the start of **every user request**
(not every nested `Task`). Goal: useful parallel work — never spam.

**Do not `Read` this file** if the skill text is already inlined.

## Gate

**Hard NO first:** finishable in 1–2 tool calls; one known file; rename; Q&A;
user said «без subagents» / «сам».

Else **launch** if **at least two** apply:

1. **Wide search** — several areas before changing code
2. **Parallel tracks** — independent workstreams
3. **Matching specialist** — `explore` / `shell` / `generalPurpose` actually fits
4. **Speed / context** — heavy dig belongs in a child

Cap ~8 `Task` in one wave. Max nest depth 2. Parent merges; children return `file:line`.

`post-change-audit` is **not** launched from this gate — opt-in only.
