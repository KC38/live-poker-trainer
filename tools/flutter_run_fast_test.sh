#!/usr/bin/env bash
# Unit coverage for course-asset overlay into a cached Runner.app.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/tools/flutter_run_fast.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

grep -q 'sync_course_assets_into_app' "$SCRIPT" \
  || fail "flutter_run_fast.sh must define sync_course_assets_into_app"
grep -q 'sync_course_assets_into_app "\$APP"' "$SCRIPT" \
  || fail "prebuilt path must call sync_course_assets_into_app before launch"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/flutter-run-fast.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

# Source only the helper by extracting it into a tiny harness.
# shellcheck disable=SC1090
CHECKOUT="$tmp/checkout"
APP="$tmp/Runner.app"
mkdir -p "$CHECKOUT/assets/course/v2"
mkdir -p "$APP/Frameworks/App.framework/flutter_assets/assets/course/v2"
printf '{"version":"old"}\n' >"$APP/Frameworks/App.framework/flutter_assets/assets/course/v2/catalog.json"
printf '{"version":"new"}\n' >"$CHECKOUT/assets/course/v2/catalog.json"
printf 'extra\n' >"$CHECKOUT/assets/course/v2/other.json"

# Extract and run the function body from the script.
eval "$(sed -n '/^sync_course_assets_into_app()/,/^}/p' "$SCRIPT")"
sync_course_assets_into_app "$APP"

grep -q '"version":"new"' \
  "$APP/Frameworks/App.framework/flutter_assets/assets/course/v2/catalog.json" \
  || fail "sync must overwrite stale catalog.json"
[[ -f "$APP/Frameworks/App.framework/flutter_assets/assets/course/v2/other.json" ]] \
  || fail "sync must copy sibling course v2 assets"

# Idempotent when already matching.
sync_course_assets_into_app "$APP"
grep -q '"version":"new"' \
  "$APP/Frameworks/App.framework/flutter_assets/assets/course/v2/catalog.json" \
  || fail "second sync must keep catalog"

echo "flutter_run_fast course asset sync ok"
