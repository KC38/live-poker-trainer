#!/usr/bin/env bash
# wait_done.sh must parse numeric / EXIT: / DONE bodies and time out cleanly.
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

# Agent-written DONE marker (LPT-410 hang).
printf 'DONE\n' >"$tmp/marker.done"
set +e
bash "$WAIT" "$tmp/marker.done" 5
code=$?
set -e
[[ "$code" == 0 ]] || fail "DONE marker should exit 0, got $code"

printf 'DONE:3\n' >"$tmp/marker3.done"
set +e
bash "$WAIT" "$tmp/marker3.done" 5
code=$?
set -e
[[ "$code" == 3 ]] || fail "DONE:3 should exit 3, got $code"

printf 'EXIT:9\n' >"$tmp/exitmark.done"
set +e
bash "$WAIT" "$tmp/exitmark.done" 5
code=$?
set -e
[[ "$code" == 9 ]] || fail "EXIT:9 should exit 9, got $code"

# Unparseable .done + sibling log EXIT:N fallback.
printf 'not-a-code\n' >"$tmp/junk.done"
printf 'noise\nEXIT:0\n' >"$tmp/junk.log"
set +e
bash "$WAIT" "$tmp/junk.done" 5
code=$?
set -e
[[ "$code" == 0 ]] || fail "log EXIT fallback should exit 0, got $code"

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
