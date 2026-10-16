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

cat >"$tmp/xcode-stuck.log" <<'EOF'
Launching lib/main.dart on iPhone 13 mini in debug mode...
Running Xcode build...
Xcode build done.                                           24.9s
EOF
python3 "$READY" --stuck-post-xcode "$tmp/xcode-stuck.log" \
  || fail "Xcode done without VM must report stuck-post-xcode"
python3 "$READY" "$tmp/xcode-stuck.log" && fail "Xcode-stuck log must not be ready"

cat >"$tmp/xcode-ok.log" <<'EOF'
Launching lib/main.dart on iPhone 13 mini in debug mode...
Running Xcode build...
Xcode build done.                                           24.9s
A Dart VM Service is available at: http://127.0.0.1:61234/abc_Def-9=/
EOF
python3 "$READY" --stuck-post-xcode "$tmp/xcode-ok.log" \
  && fail "Xcode done with VM must not report stuck"
python3 "$READY" "$tmp/xcode-ok.log" || fail "Xcode+VM log should be ready"

# Cached Runner.app (.prebuilt) is still the bundled Dart until hot restart.
cat >"$tmp/prebuilt.log" <<'EOF'
Launching lib/main.dart on iPhone 13 mini in debug mode...
A Dart VM Service is available at: http://127.0.0.1:61234/abc_Def-9=/
EOF
touch "$tmp/prebuilt.log.prebuilt"
python3 "$READY" "$tmp/prebuilt.log" \
  && fail "prebuilt VM URI must wait for Restarted application"
python3 "$READY" --vm-only "$tmp/prebuilt.log" \
  || fail "--vm-only must accept a fresh VM URI despite .prebuilt"
printf 'Restarted application in 900ms.\n' >>"$tmp/prebuilt.log"
python3 "$READY" "$tmp/prebuilt.log" \
  || fail "prebuilt + Restarted after Launching should be ready"

cat >"$tmp/prebuilt-stale.log" <<'EOF'
Restarted application in 900ms.
Launching lib/main.dart on iPhone 13 mini in debug mode...
A Dart VM Service is available at: http://127.0.0.1:61234/abc_Def-9=/
EOF
touch "$tmp/prebuilt-stale.log.prebuilt"
python3 "$READY" "$tmp/prebuilt-stale.log" \
  && fail "Restarted before the latest Launching must not ready a prebuilt log"

cat >"$tmp/relaunch-stuck.log" <<'EOF'
Launching lib/main.dart on iPhone 13 mini in debug mode...
A Dart VM Service is available at: http://127.0.0.1:61234/abc_Def-9=/
Xcode build done.                                           24.9s
Launching lib/main.dart on iPhone 13 mini in debug mode...
EOF
python3 "$READY" --stuck-post-xcode "$tmp/relaunch-stuck.log" \
  || fail "relaunch after Xcode with no new VM must report stuck"
python3 "$READY" "$tmp/relaunch-stuck.log" \
  && fail "relaunch-stuck log must not be ready"

cat >"$tmp/xcode-restarted.log" <<'EOF'
Launching lib/main.dart on iPhone 13 mini in debug mode...
Xcode build done.                                           24.9s
Restarted application in 800ms.
EOF
python3 "$READY" --stuck-post-xcode "$tmp/xcode-restarted.log" \
  && fail "Restarted after Xcode must not report stuck"
python3 "$READY" "$tmp/xcode-restarted.log" \
  || fail "Restarted after Xcode should be ready"

set +e
python3 "$READY" "$tmp/missing.log"
missing_code=$?
set -e
[[ "$missing_code" -eq 2 ]] || fail "missing log must exit 2, got $missing_code"

echo "flutter_log_ready ok"
