#!/usr/bin/env python3
"""Ask before destructive or overly broad Docker Compose commands."""

from __future__ import annotations

import json
import re
import sys

COMPOSE = re.compile(r"(?:docker\s+compose|docker-compose)\b", re.I)


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except json.JSONDecodeError:
        print(json.dumps({"permission": "allow"}))
        return 0

    command = payload.get("command") or ""
    if not COMPOSE.search(command):
        print(json.dumps({"permission": "allow"}))
        return 0

    if re.search(r"\bdown\b", command):
        print(
            json.dumps(
                {
                    "permission": "ask",
                    "user_message": (
                        "docker compose down stops the whole local stack. "
                        "Confirm only if you meant a full teardown."
                    ),
                    "agent_message": (
                        "Prefer a targeted recreate, e.g. "
                        "`docker compose up -d --no-deps --force-recreate api`. "
                        "Use `down` only when the user explicitly asked to stop the stack."
                    ),
                }
            )
        )
        return 0

    if "force-recreate" in command and "--no-deps" not in command:
        print(
            json.dumps(
                {
                    "permission": "ask",
                    "user_message": (
                        "force-recreate without --no-deps may restart dependent services. "
                        "Confirm before continuing."
                    ),
                    "agent_message": (
                        "For a single service prefer "
                        "`docker compose up -d --no-deps --force-recreate api`."
                    ),
                }
            )
        )
        return 0

    print(json.dumps({"permission": "allow"}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
