#!/usr/bin/env bash
# wait_flutter_vm.sh readiness + timeout.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WAIT="$ROOT/tools/wait_flutter_vm.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

chmod +x "$WAIT"
tmp="$(mktemp -d "${TMPDIR:-/tmp}/wait-flutter-vm.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

printf 'Launching…\n' >"$tmp/empty.log"
if "$WAIT" "$tmp/empty.log" 1 >/dev/null 2>&1; then
  fail "should time out without a Dart VM URI"
fi

printf 'A Dart VM Service on iPhone 13 mini is available at: http://127.0.0.1:61234/abc_Def-9=/\n' \
  >"$tmp/ready.log"
out="$("$WAIT" "$tmp/ready.log" 5)"
grep -q 'Dart VM ready' <<<"$out" || fail "should report ready: $out"

echo "wait_flutter_vm ok"
