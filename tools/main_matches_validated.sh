#!/usr/bin/env bash
# Is origin/main's app identical to the worktree build we already validated?
#
# After a squash-merge, origin/main usually carries the exact lib/ios/assets
# the agent just validated on the worktree build. Then the origin/main walk
# is redundant: refresh, take one <KEY>-validated.png, close.
#
# Usage:
#   tools/main_matches_validated.sh <validated-sha> [ref=origin/main]
#
# Exit 0 when no app path differs between the two and the change did not
# touch functions/ (the worktree ran against the old deployed backend).
# Exit 1 with the reason otherwise; exit 2 on usage errors.
set -euo pipefail

VALIDATED="${1:-}"
REF="${2:-origin/main}"
if [[ -z "$VALIDATED" ]]; then
  echo "usage: $0 <validated-sha> [ref=origin/main]" >&2
  exit 2
fi

APP_PATHS=(lib assets ios pubspec.yaml pubspec.lock)

git fetch -q origin main 2>/dev/null || true
if ! git rev-parse -q --verify "$VALIDATED^{commit}" >/dev/null; then
  echo "unknown commit: $VALIDATED" >&2
  exit 2
fi

changed="$(git diff --name-only "$VALIDATED" "$REF" -- "${APP_PATHS[@]}")"
if [[ -n "$changed" ]]; then
  echo "differs: $REF changes app files vs validated $VALIDATED:"
  sed 's/^/  /' <<<"$changed"
  exit 1
fi

base="$(git merge-base "$VALIDATED" "$REF")"
backend="$(git diff --name-only "$base" "$VALIDATED" -- functions)"
if [[ -n "$backend" ]]; then
  echo "differs: the change touched functions/ (worktree ran on the old backend):"
  sed 's/^/  /' <<<"$backend"
  exit 1
fi

echo "match: $REF app == validated $VALIDATED; one validated screenshot is enough"
