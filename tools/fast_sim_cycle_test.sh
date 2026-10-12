#!/usr/bin/env bash
# Tests for the fast simulator cycle: native_build_key, flutter_run_fast
# (fake flutter), flutter_log_ready prebuilt sidecar, main_matches_validated,
# disk_guard, and the deploy-functions unchanged skip.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

tmp="$(mktemp -d "${TMPDIR:-/tmp}/fast-sim-cycle.XXXXXX")"
cleanup() {
  [[ -f "$tmp/fake.pids" ]] && xargs kill 2>/dev/null <"$tmp/fake.pids" || true
  rm -rf "$tmp"
}
trap cleanup EXIT

git_repo() {
  local dir="$1"
  mkdir -p "$dir/ios/Runner" "$dir/lib"
  git -C "$dir" init -q -b main
  git -C "$dir" config user.email t@t
  git -C "$dir" config user.name t
  echo "name: app" >"$dir/pubspec.yaml"
  echo "packages: {}" >"$dir/pubspec.lock"
  echo "plist" >"$dir/ios/Runner/Info.plist"
  echo "pods" >"$dir/ios/Podfile.lock"
  echo "void main() {}" >"$dir/lib/main.dart"
  git -C "$dir" add -A
  git -C "$dir" commit -qm init
}

# --- native_build_key -------------------------------------------------------
repo="$tmp/repo"
git_repo "$repo"
key() { python3 "$ROOT/tools/native_build_key.py" "$repo"; }
k0="$(key)"
echo "void main() { print(1); }" >"$repo/lib/main.dart"
[[ "$(key)" == "$k0" ]] || fail "Dart-only edit must keep the native key"
echo "dirt" >>"$repo/ios/Podfile.lock"
[[ "$(key)" == "$k0" ]] || fail "Podfile.lock machine dirt must keep the native key"
git -C "$repo" checkout -q -- ios/Podfile.lock
echo "plist2" >"$repo/ios/Runner/Info.plist"
[[ "$(key)" != "$k0" ]] || fail "ios/ edit must change the native key"
git -C "$repo" checkout -q -- ios/Runner/Info.plist lib/main.dart
echo "packages: {a: 1}" >"$repo/pubspec.lock"
[[ "$(key)" != "$k0" ]] || fail "pubspec.lock edit must change the native key"
git -C "$repo" checkout -q -- pubspec.lock

# --- flutter_log_ready prebuilt sidecar --------------------------------------
log="$tmp/side.log"
printf 'Launching lib/main.dart on x...\nA Dart VM Service is available at: http://127.0.0.1:5/abc=/\n' >"$log"
python3 "$ROOT/tools/flutter_log_ready.py" "$log" || fail "VM after Launching is ready"
touch "$log.prebuilt"
python3 "$ROOT/tools/flutter_log_ready.py" "$log" && fail "prebuilt launch is not ready before hot restart"
python3 "$ROOT/tools/flutter_log_ready.py" --vm-only "$log" || fail "--vm-only ignores the sidecar"
echo "Restarted application in 80ms." >>"$log"
python3 "$ROOT/tools/flutter_log_ready.py" "$log" || fail "prebuilt launch is ready after hot restart"

# --- flutter_run_fast with a fake flutter ------------------------------------
bin="$tmp/bin"
mkdir -p "$bin"
cat >"$bin/flutter" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "pub" ]]; then
  echo "pub $*" >>"$FAKE_CALLS"
  exit 0
fi
pidfile="" prebuilt=0
args=("$@")
for ((i = 0; i < ${#args[@]}; i++)); do
  case "${args[$i]}" in
    --pid-file) pidfile="${args[$((i + 1))]}" ;;
    --use-application-binary) prebuilt=1 ;;
  esac
done
echo "$$" >>"$FAKE_PIDS"
echo "args: $*" >>"$FAKE_CALLS"
trap 'echo "Restarted application in 42ms."' USR2
echo "Launching lib/main.dart on iPhone 13 mini in debug mode..."
if [[ "$prebuilt" == 0 ]]; then
  echo "Running Xcode build..."
  mkdir -p build/ios/iphonesimulator/Runner.app
  echo app >build/ios/iphonesimulator/Runner.app/Runner
fi
echo "A Dart VM Service on iPhone 13 mini is available at: http://127.0.0.1:61234/tok_en=/"
echo "$$" >"$pidfile"
echo "Flutter run key commands."
while true; do sleep 0.2; done
EOF
chmod +x "$bin/flutter"
export FAKE_PIDS="$tmp/fake.pids" FAKE_CALLS="$tmp/fake.calls"
export UI_AGENT_APP_CACHE_DIR="$tmp/app-cache"
run_fast() {
  FLUTTER_BIN="$bin/flutter" HOME="$tmp/home" "$ROOT/tools/flutter_run_fast.sh" \
    --checkout "$repo" --log "$tmp/run.log" --pid-file "$tmp/run.pid" \
    --device FAKE-UDID --timeout 20
}
mkdir -p "$tmp/home"
out="$(run_fast)" || fail "first fast run should succeed: $out"
grep -q 'full flutter run' <<<"$out" || fail "first run must build: $out"
grep -q 'cache: saved Runner.app' <<<"$out" || fail "first run must cache Runner.app: $out"
[[ -f "$UI_AGENT_APP_CACHE_DIR/$k0/Runner.app/Runner" ]] || fail "cache entry missing for $k0"

echo "void main() { print(2); }" >"$repo/lib/main.dart"
out="$(run_fast)" || fail "second fast run should succeed: $out"
grep -q 'skipping Xcode' <<<"$out" || fail "Dart-only rerun must use the cached app: $out"
grep -q -- "--use-application-binary $UI_AGENT_APP_CACHE_DIR/$k0/Runner.app" "$FAKE_CALLS" \
  || fail "prebuilt run must pass the cached app: $(cat "$FAKE_CALLS")"
grep -q 'Restarted application in' "$tmp/run.log" || fail "prebuilt run must hot-restart onto the checkout"
[[ ! -e "$tmp/run.log.prebuilt" ]] || fail "sidecar must be cleared once restarted"
# A second hot restart must wait for its own "Restarted" line.
out="$("$ROOT/tools/flutter_hot_restart.sh" "$tmp/run.log" "$tmp/run.pid" 10)" \
  || fail "hot restart helper should succeed: $out"
[[ "$(grep -c 'Restarted application in' "$tmp/run.log")" == 2 ]] \
  || fail "hot restart helper must wait for a new restart line"
git -C "$repo" checkout -q -- lib/main.dart

# --- main_matches_validated ---------------------------------------------------
remote="$tmp/remote.git"
git clone -q --bare "$repo" "$remote"
git -C "$repo" remote add origin "$remote"
git -C "$repo" fetch -q origin
validated="$(git -C "$repo" rev-parse HEAD)"
match() { (cd "$repo" && "$ROOT/tools/main_matches_validated.sh" "$@"); }
match "$validated" >/dev/null || fail "identical main must match"
echo "# notes" >"$repo/NOTES.md"
git -C "$repo" add -A && git -C "$repo" commit -qm docs && git -C "$repo" push -q origin main
match "$validated" >/dev/null || fail "docs-only main commits must still match"
echo "void main() { print(3); }" >"$repo/lib/main.dart"
git -C "$repo" add -A && git -C "$repo" commit -qm lib && git -C "$repo" push -q origin main
match "$validated" >/dev/null && fail "lib/ change on main must not match"
git -C "$repo" checkout -q -b feat
mkdir -p "$repo/functions"
echo "x" >"$repo/functions/index.ts"
git -C "$repo" add -A && git -C "$repo" commit -qm fn
fn_sha="$(git -C "$repo" rev-parse HEAD)"
git -C "$repo" checkout -q main
git -C "$repo" merge -q --squash feat && git -C "$repo" commit -qm "fn (squash)"
git -C "$repo" push -q origin main
match "$fn_sha" >/dev/null && fail "a change that touched functions/ must not match"
git -C "$repo" checkout -q -b feat2
echo "void main() { print(4); }" >"$repo/lib/main.dart"
git -C "$repo" add -A && git -C "$repo" commit -qm lib2
lib_sha="$(git -C "$repo" rev-parse HEAD)"
git -C "$repo" checkout -q main
git -C "$repo" merge -q --squash feat2 && git -C "$repo" commit -qm "lib2 (squash)"
git -C "$repo" push -q origin main
match "$lib_sha" >/dev/null || fail "squash-merged Dart-only change must match its validated branch"

# --- deploy-functions skips when functions/ is unchanged ----------------------
sha_file="$tmp/deployed-sha"
git -C "$repo" rev-parse HEAD >"$sha_file"
echo "more docs" >>"$repo/NOTES.md"
git -C "$repo" add -A && git -C "$repo" commit -qm docs2 && git -C "$repo" push -q origin main
out="$(PRIMARY="$repo" FUNCTIONS_DEPLOYED_SHA_FILE="$sha_file" UI_AGENT_SECRETS_FILE=/dev/null \
  bash "$ROOT/.cursor/skills/make-change/scripts/deploy-functions.sh" 2>&1)" \
  || fail "unchanged functions should exit 0: $out"
grep -q 'skipping deploy' <<<"$out" || fail "unchanged functions must skip: $out"

# --- disk_guard -----------------------------------------------------------------
dd="$tmp/home/Library/Developer/Xcode/DerivedData"
mkdir -p "$dd/Runner-gone" "$dd/Runner-live"
plist() {
  cat >"$1/info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0"><dict><key>WorkspacePath</key><string>$2</string></dict></plist>
EOF
}
plist "$dd/Runner-gone" "$tmp/deleted-worktree/ios/Runner.xcworkspace"
plist "$dd/Runner-live" "$repo/ios"
HOME="$tmp/home" PRIMARY="$repo" python3 "$ROOT/tools/disk_guard.py" --quiet --min-free-gb 0 >/dev/null
[[ ! -e "$dd/Runner-gone" ]] || fail "orphan DerivedData must be removed"
[[ -d "$dd/Runner-live" ]] || fail "DerivedData for a live workspace must stay"

# --- heartbeats keep the holder's purpose --------------------------------------
lock_home="$tmp/lock-home"
mkdir -p "$lock_home"
run_id="$(HOME="$lock_home" python3 "$ROOT/tools/sim_lock.py" claim --owner ui-design-agent --purpose "LPT-1: validate" --pid $$)"
printf 'Launching lib/main.dart ...\n' >"$tmp/slow.log"
HOME="$lock_home" SIM_LOCK_RUN_ID="$run_id" "$ROOT/tools/wait_flutter_vm.sh" "$tmp/slow.log" 1 >/dev/null 2>&1 || true
sleep 30 &
sleeper=$!
echo "$sleeper" >"$tmp/slow.pid"
HOME="$lock_home" SIM_LOCK_RUN_ID="$run_id" "$ROOT/tools/flutter_hot_restart.sh" "$tmp/slow.log" "$tmp/slow.pid" 1 >/dev/null 2>&1 || true
kill "$sleeper" 2>/dev/null || true
lock_status() { HOME="$lock_home" python3 "$ROOT/tools/sim_lock.py" status 2>&1 || true; }
grep -q 'purpose: LPT-1: validate' <<<"$(lock_status)" \
  || fail "wait helpers must not overwrite the holder's purpose: $(lock_status)"
HOME="$lock_home" SIM_LOCK_RUN_ID="$run_id" "$ROOT/tools/wait_flutter_vm.sh" "$tmp/slow.log" 1 --purpose "LPT-1: wait VM" >/dev/null 2>&1 || true
grep -q 'purpose: LPT-1: wait VM' <<<"$(lock_status)" \
  || fail "an explicit --purpose must still replace the purpose"

echo "fast sim cycle ok"
