#!/usr/bin/env bash
# Deploy Cloud Functions from an up-to-date main checkout.
# Used by ship-change after merge so production matches origin/main.
#
# Non-interactive auth (first match):
#   FIREBASE_SERVICE_ACCOUNT — JSON for a GCP/Firebase service account
#   GOOGLE_APPLICATION_CREDENTIALS — path to an existing key file
#   FIREBASE_TOKEN — from `npx -y firebase-tools@15.30.2 login:ci`
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
NODE22_BIN="$(brew --prefix node@22 2>/dev/null)/bin"
if [[ -d "$NODE22_BIN" ]]; then
  export PATH="$NODE22_BIN:$PATH"
fi

if ! command -v node >/dev/null 2>&1 || ! node -v | grep -q '^v22\.'; then
  echo "Node 22 required for functions deploy (found $(command -v node >/dev/null 2>&1 && node -v || echo missing))." >&2
  exit 1
fi

auth_file=""
if [[ -n "${FIREBASE_SERVICE_ACCOUNT:-}" && -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]]; then
  auth_file="$(mktemp)"
  printf '%s\n' "$FIREBASE_SERVICE_ACCOUNT" > "$auth_file"
  chmod 600 "$auth_file"
  export GOOGLE_APPLICATION_CREDENTIALS="$auth_file"
fi

if [[ -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" && -z "${FIREBASE_TOKEN:-}" ]]; then
  echo "Firebase deploy needs non-interactive credentials." >&2
  echo "Set FIREBASE_SERVICE_ACCOUNT (JSON), GOOGLE_APPLICATION_CREDENTIALS, or FIREBASE_TOKEN (firebase login:ci)." >&2
  echo "On GitHub, add the same value as a repository Actions secret; deploys also run from the deploy-functions job on main." >&2
  exit 1
fi

WORKTREE="$(mktemp -d /tmp/lpt-deploy-XXXXXX)"
cleanup() {
  if [[ -n "$auth_file" ]]; then
    rm -f "$auth_file"
  fi
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
  npx -y firebase-tools@15.30.2 deploy --only functions --project live-poker-trainer --non-interactive
)

echo "Functions deploy complete from origin/main."
