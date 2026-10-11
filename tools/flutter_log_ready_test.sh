#!/usr/bin/env bash
# flutter_log_ready.py: stale VM URI must not fake readiness.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
READY="$ROOT/tools/flutter_log_ready.py"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

tmp="$(mktemp -d "${TMPDIR:-/tmp}/flutter-log-ready.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

printf 'no uri yet\n' >"$tmp/empty.log"
python3 "$READY" "$tmp/empty.log" && fail "empty log must not be ready"

printf 'A Dart VM Service is available at: http://127.0.0.1:61234/abc_Def-9=/\n' \
  >"$tmp/uri.log"
python3 "$READY" "$tmp/uri.log" || fail "URI-only log should be ready"

cat >"$tmp/stale.log" <<'EOF'
A Dart VM Service is available at: http://127.0.0.1:61234/abc_Def-9=/
Launching lib/main.dart on iPhone 13 mini in debug mode...
Running Xcode build...
EOF
python3 "$READY" "$tmp/stale.log" && fail "stale URI before Launching must not be ready"

cat >"$tmp/fresh.log" <<'EOF'
A Dart VM Service is available at: http://127.0.0.1:11111/old=/
Launching lib/main.dart on iPhone 13 mini in debug mode...
A Dart VM Service is available at: http://127.0.0.1:61234/abc_Def-9=/
EOF
python3 "$READY" "$tmp/fresh.log" || fail "URI after Launching should be ready"

cat >"$tmp/restarted.log" <<'EOF'
A Dart VM Service is available at: http://127.0.0.1:61234/abc_Def-9=/
Performing hot restart...
Restarted application in 1,234ms.
EOF
python3 "$READY" "$tmp/restarted.log" || fail "Restarted application should be ready"

cat >"$tmp/stuck.log" <<'EOF'
A Dart VM Service is available at: http://127.0.0.1:61234/abc_Def-9=/
Performing hot restart...
Launching lib/main.dart on iPhone 13 mini in debug mode...
Running Xcode build...
EOF
python3 "$READY" "$tmp/stuck.log" && fail "stuck Launching after hot-restart must not be ready"

echo "flutter_log_ready ok"
