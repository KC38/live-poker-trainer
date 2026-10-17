#!/usr/bin/env bash
# Cloud Agent boot step for the Exploitative Poker Lab Flutter web app.
#
# `start` runs on every agent boot; `install` does not. Cursor ignores
# `terminals` entries unless `start` is also set, so this script is what
# keeps the app listening. Safe to rerun: if something is already serving
# port 8080, it exits instead of launching a second compiler.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

PORT=8080
if curl -sf -o /dev/null --max-time 2 "http://127.0.0.1:${PORT}/"; then
  echo "[start] flutter web already listening on :${PORT}"
  exit 0
fi

# Install symlinks flutter onto /usr/local/bin. Keep /opt/flutter on PATH for
# hosts where that symlink is missing.
if [[ -d /opt/flutter/bin ]]; then
  export PATH="/opt/flutter/bin:${PATH}"
fi

exec flutter run -d web-server --web-hostname 0.0.0.0 --web-port "$PORT"
