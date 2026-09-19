#!/usr/bin/env bash
# Deploy Cloud Functions from an up-to-date main checkout.
# Used by ship-change after merge so production matches origin/main.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
NODE22_BIN="$(brew --prefix node@22 2>/dev/null)/bin"
if [[ -d "$NODE22_BIN" ]]; then
  export PATH="$NODE22_BIN:$PATH"
fi

if ! node -v | grep -q '^v22\.'; then
  echo "Node 22 required for functions deploy (found $(node -v))." >&2
  exit 1
fi

WORKTREE="$(mktemp -d /tmp/lpt-deploy-XXXXXX)"
cleanup() {
  git -C "$ROOT" worktree remove --force "$WORKTREE" 2>/dev/null || rm -rf "$WORKTREE"
}
trap cleanup EXIT

git -C "$ROOT" fetch origin
git -C "$ROOT" worktree add --detach "$WORKTREE" origin/main

# firebase-tools <15 breaks on jose ESM during analysis; predeploy
# `npm --prefix "$RESOURCE_DIR"` also fails under /bin/sh -c.
python3 - <<PY
import json
from pathlib import Path
path = Path("$WORKTREE") / "firebase.json"
data = json.loads(path.read_text())
for entry in data.get("functions", []):
    entry["predeploy"] = []
path.write_text(json.dumps(data, indent=2) + "\n")
PY

(
  cd "$WORKTREE/functions"
  npm ci
  npm run build
)

(
  cd "$WORKTREE"
  npx -y firebase-tools@15.30.2 deploy --only functions --project live-poker-trainer
)

echo "Functions deploy complete from origin/main."
