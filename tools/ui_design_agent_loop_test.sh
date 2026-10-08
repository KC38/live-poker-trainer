#!/usr/bin/env bash
# The ui-design-agent loop builds the right CLI call, keeps secrets off disk
# outside secrets.env, and skips runs while the mini is busy.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOOP="$ROOT/tools/ui_design_agent_loop.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

tmp="$(mktemp -d "${TMPDIR:-/tmp}/ui-agent-loop.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export SIM_LOCK_DIR="$tmp/lock"
mkdir -p "$HOME/.live-poker-trainer" "$tmp/bin"

# A throwaway primary checkout so the runner worktree is made from it.
export PRIMARY="$tmp/primary"
mkdir -p "$PRIMARY"
git -C "$PRIMARY" init -q -b main
git -C "$PRIMARY" config user.email test@example.com
git -C "$PRIMARY" config user.name test
touch "$PRIMARY/pubspec.yaml"
git -C "$PRIMARY" add pubspec.yaml
git -C "$PRIMARY" commit -qm seed
PRIMARY="$(cd "$PRIMARY" && pwd -P)"

# Secrets are loaded from secrets.env and turned into the Basic header value.
printf 'CURSOR_API_KEY=%q\nATLASSIAN_EMAIL=%q\nATLASSIAN_API_TOKEN=%q\n' \
  'key with space' 'kc@example.com' 'tok-123' >"$HOME/.live-poker-trainer/secrets.env"

# A fake Cursor CLI that records each run's arguments and environment.
cat >"$tmp/bin/agent" <<EOF
#!/usr/bin/env bash
if [[ "\${1:-}" == "status" ]]; then echo "Not logged in"; exit 0; fi
printf '%s\n' "\$@" >"$tmp/agent-args"
echo "\$ATLASSIAN_BASIC" >"$tmp/agent-basic"
echo started >>"$tmp/agent-started"
EOF
chmod +x "$tmp/bin/agent"

export UI_AGENT_LOOP_SOURCE_ONLY=1
# shellcheck disable=SC1090
source "$LOOP"
export PATH="$tmp/bin:$PATH"

[[ "${CURSOR_API_KEY:-}" == 'key with space' ]] || fail "secrets.env not loaded"
want_basic="$(printf '%s' 'kc@example.com:tok-123' | base64)"
[[ "${ATLASSIAN_BASIC:-}" == "$want_basic" ]] || fail "ATLASSIAN_BASIC not derived from the token"
logged_in || fail "a saved API key counts as logged in"

args="$(agent_args)"
for want in -p --force --trust --approve-mcps --sandbox disabled --workspace "$RUNNER_DIR" --add-dir "$PRIMARY"; do
  grep -qxF -- "$want" <<<"$args" || fail "agent args missing $want"
done
grep -q -- '--plugin-dir' <<<"$args" && fail "no plugin dirs by default"
grep -q 'tok-123' <<<"$args" && fail "the token must not appear on the command line"

UI_AGENT_MODEL=test-model
grep -qxF -- test-model <<<"$(agent_args)" || fail "UI_AGENT_MODEL not passed"
unset UI_AGENT_MODEL
mkdir -p "$tmp/extra-plugin"
UI_AGENT_PLUGIN_DIRS="$tmp/missing:$tmp/extra-plugin"
grep -qxF -- "$tmp/extra-plugin" <<<"$(plugin_args)" || fail "UI_AGENT_PLUGIN_DIRS ignored"
grep -q missing <<<"$(plugin_args)" && fail "missing plugin dir should be skipped"
unset UI_AGENT_PLUGIN_DIRS

# The runner is a detached worktree of the primary with an mcp.json that reads the env.
ensure_runner
[[ "$(git -C "$RUNNER_DIR" rev-parse HEAD)" == "$(git -C "$PRIMARY" rev-parse HEAD)" ]] \
  || fail "runner should sit at the primary's main"
mcp="$RUNNER_DIR/.cursor/mcp.json"
grep -qF '"Authorization": "Basic ${env:ATLASSIAN_BASIC}"' "$mcp" || fail "mcp.json should read the env header"
grep -q 'tok-123\|'"$want_basic" "$mcp" && fail "mcp.json must not hold the token"
echo change >"$PRIMARY/pubspec.yaml"
git -C "$PRIMARY" commit -qam next
ensure_runner
[[ "$(git -C "$RUNNER_DIR" rev-parse HEAD)" == "$(git -C "$PRIMARY" rev-parse HEAD)" ]] \
  || fail "runner should follow the primary's main"

sync_primary() { :; }

python3 "$ROOT/tools/sim_lock.py" claim --owner other-agent --purpose "holding" >/dev/null 2>&1
code=0
one_run >/dev/null 2>&1 || code=$?
[[ "$code" == 10 ]] || fail "busy mini should skip with 10, got $code"
[[ ! -f "$tmp/agent-started" ]] || fail "agent must not start while the mini is busy"

python3 "$ROOT/tools/sim_lock.py" release --force >/dev/null 2>&1
one_run >/dev/null 2>&1 || fail "free mini run failed"
[[ -f "$tmp/agent-started" ]] || fail "agent should start when the mini is free"
grep -qxF -- "$RUNNER_DIR" "$tmp/agent-args" || fail "run should use the runner workspace"
grep -q "primary checkout is $PRIMARY" "$tmp/agent-args" || fail "prompt should name the primary"
[[ "$(cat "$tmp/agent-basic")" == "$want_basic" ]] || fail "run should get ATLASSIAN_BASIC"

(unset UI_AGENT_LOOP_SOURCE_ONLY; bash "$LOOP" status >/dev/null) \
  || fail "status should exit 0"
rm -f "$LOG_DIR"/run-*.log
(unset UI_AGENT_LOOP_SOURCE_ONLY; bash "$LOOP" status >/dev/null) \
  || fail "status should exit 0 before the first run"

echo "ui-design-agent loop ok"
