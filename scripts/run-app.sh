#!/usr/bin/env bash
set -euo pipefail

# Host Flutter (FVM / flutter). API stays in Compose — do not add an app service.
# Does not open a browser: serve http://localhost:8080 and use your own bookmark.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
docker compose up -d

DEVICE="${1:-web}"
cd "$ROOT/apps/app"

if command -v fvm >/dev/null 2>&1; then
  flutter=(fvm flutter)
else
  flutter=(flutter)
fi

if [[ "$DEVICE" == "web" || "$DEVICE" == "chrome" ]]; then
  exec "${flutter[@]}" run -d web-server --web-hostname localhost --web-port 8080
fi
exec "${flutter[@]}" run -d "$DEVICE"
