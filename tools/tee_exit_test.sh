#!/usr/bin/env bash
# tee_exit.sh must surface the command exit code, not tee's, and write .done.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEE="$ROOT/tools/tee_exit.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

tmp="$(mktemp -d "${TMPDIR:-/tmp}/tee-exit.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

ok_log="$tmp/ok.log"
if ! bash "$TEE" "$ok_log" true; then
  fail "true should exit 0"
fi
grep -q 'EXIT:0' "$ok_log" || fail "ok log missing EXIT:0: $(cat "$ok_log")"
[[ -f "$tmp/ok.done" ]] || fail "ok.done missing"
[[ "$(cat "$tmp/ok.done")" == "0" ]] || fail "ok.done should be 0: $(cat "$tmp/ok.done")"

fail_log="$tmp/fail.log"
rm -f "$tmp/fail.done"
set +e
bash "$TEE" "$fail_log" bash -c 'echo some tests failed; exit 7'
code=$?
set -e
[[ "$code" == 7 ]] || fail "expected exit 7, got $code"
grep -q 'some tests failed' "$fail_log" || fail "fail log missing command output"
grep -q 'EXIT:7' "$fail_log" || fail "fail log missing EXIT:7: $(cat "$fail_log")"
[[ -f "$tmp/fail.done" ]] || fail "fail.done missing"
[[ "$(cat "$tmp/fail.done")" == "7" ]] || fail "fail.done should be 7: $(cat "$tmp/fail.done")"

# Stale .done from a prior run must be cleared before the command starts.
printf '99\n' >"$tmp/stale.done"
stale_log="$tmp/stale.log"
# Hang briefly so we can observe .done absence mid-run is hard; just ensure
# a successful run replaces 99 with 0.
bash "$TEE" "$stale_log" true
[[ "$(cat "$tmp/stale.done")" == "0" ]] || fail "stale.done not replaced: $(cat "$tmp/stale.done")"

# Pipe to tee alone would report 0; tee_exit must not.
pipe_log="$tmp/pipe.log"
set +e
bash -c 'false | tee -a "'"$pipe_log"'"; echo EXIT:$?' >/dev/null
naive=$?
bash "$TEE" "$pipe_log" false
helper=$?
set -e
[[ "$naive" == 0 ]] || fail "sanity: bare tee should mask false (got $naive)"
[[ "$helper" != 0 ]] || fail "tee_exit must not mask false"
[[ "$(cat "$tmp/pipe.done")" != "0" ]] || fail "pipe.done must not be 0 after false"

echo "tee_exit ok"
