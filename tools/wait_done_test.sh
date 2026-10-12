#!/usr/bin/env bash
# wait_done.sh must surface the .done exit code and time out cleanly.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WAIT="$ROOT/tools/wait_done.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

tmp="$(mktemp -d "${TMPDIR:-/tmp}/wait-done.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

# Accepts .log path and reads sibling .done.
printf '0\n' >"$tmp/ok.done"
out="$(bash "$WAIT" "$tmp/ok.log" 5)"
grep -q 'EXIT:0' <<<"$out" || fail "ok wait missing EXIT:0: $out"

# Non-zero exit from .done.
printf '7\n' >"$tmp/fail.done"
set +e
bash "$WAIT" "$tmp/fail.done" 5
code=$?
set -e
[[ "$code" == 7 ]] || fail "expected exit 7, got $code"

# Appears after a short delay.
rm -f "$tmp/late.done"
(
  sleep 1
  printf '0\n' >"$tmp/late.done"
) &
bash "$WAIT" "$tmp/late.done" 10 >/dev/null \
  || fail "late .done should succeed"

# Timeout when never written.
rm -f "$tmp/missing.done"
set +e
bash "$WAIT" "$tmp/missing.done" 2
code=$?
set -e
[[ "$code" == 124 ]] || fail "expected timeout 124, got $code"

echo "wait_done ok"
