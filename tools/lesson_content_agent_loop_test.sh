#!/usr/bin/env bash
# Unit tests for lesson_content_agent_loop.sh worktree + PRIMARY isolation.
set -euo pipefail

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOOP="$ROOT/tools/lesson_content_agent_loop.sh"
tmp="$(mktemp -d "${TMPDIR:-/tmp}/content-agent-loop.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

export CONTENT_AGENT_LOOP_SOURCE_ONLY=1
export STATE_DIR="$tmp/state"
export HOME="$tmp/home"
mkdir -p "$STATE_DIR" "$HOME"
# shellcheck source=lesson_content_agent_loop.sh
source "$LOOP"

fake_primary="$tmp/primary"
mkdir -p "$fake_primary"
git -C "$fake_primary" init -q
git -C "$fake_primary" config user.email t@t
git -C "$fake_primary" config user.name t
printf 'repo\n' >"$fake_primary/pubspec.yaml"
# Match PRIMARY .gitignore so .worktrees/ is not "dirty".
printf '.worktrees/\n' >"$fake_primary/.gitignore"
git -C "$fake_primary" add pubspec.yaml .gitignore
git -C "$fake_primary" commit -m init -q
git -C "$fake_primary" branch -M main
tip="$(git -C "$fake_primary" rev-parse HEAD)"
git -C "$fake_primary" update-ref refs/remotes/origin/main "$tip"

primary() { echo "$fake_primary"; }

grep -q 'prepare_content_run_worktree' "$LOOP" \
  || fail "loop must define prepare_content_run_worktree"
grep -q 'ensure_primary_clean_main' "$LOOP" \
  || fail "loop must define ensure_primary_clean_main"
grep -q '\-\-cwd "\$worktree_dir"' "$LOOP" \
  || fail "SDK run must use worktree cwd, not primary"

wt="$(prepare_content_run_worktree)"
[[ -d "$wt" ]] || fail "worktree path missing: $wt"
[[ "$wt" == "$fake_primary/.worktrees/content-agent" ]] \
  || fail "unexpected worktree path: $wt"
[[ "$(git -C "$wt" rev-parse HEAD)" == "$tip" ]] \
  || fail "worktree should be at origin/main tip"
# Detached HEAD expected.
branch="$(git -C "$wt" rev-parse --abbrev-ref HEAD)"
[[ "$branch" == "HEAD" ]] || fail "worktree should be detached, got $branch"

# Dirty worktree is reset on next prepare.
printf 'scratch\n' >"$wt/scratch.txt"
wt2="$(prepare_content_run_worktree)"
[[ "$wt2" == "$wt" ]] || fail "sticky worktree path should reuse"
[[ ! -f "$wt/scratch.txt" ]] || fail "prepare must clean prior scratch"

# Leftover chore branch on PRIMARY is returned to main when clean.
git -C "$fake_primary" checkout -b cursor/chore-content-agent-learnings-test -q
ensure_primary_clean_main
[[ "$(git -C "$fake_primary" rev-parse --abbrev-ref HEAD)" == "main" ]] \
  || fail "ensure_primary_clean_main should return chore branch to main"

# Prompt must forbid PRIMARY edits and name the worktree.
export CONTENT_AGENT_WORKTREE="$wt"
prompt_out="$(prompt)"
grep -q "WORKTREE: $wt" <<<"$prompt_out" \
  || fail "prompt must name WORKTREE: $prompt_out"
grep -q "Never checkout, commit, or edit PRIMARY" <<<"$prompt_out" \
  || fail "prompt must forbid PRIMARY edits"
grep -q "PRIMARY: $fake_primary" <<<"$prompt_out" \
  && fail "prompt must not advertise PRIMARY as the edit root"

grep -q 'print_content_run_log_preview' "$LOOP" \
  || fail "loop must define print_content_run_log_preview"
grep -q 'print_content_run_log_preview "\$run_log"' "$LOOP" \
  || fail "one_run exit summary must use scrubbed preview, not raw tail"
# Finished SDK logs must not dump raw NDJSON crumbs on status.
preview_log="$tmp/sdk-polluted.log"
cat >"$preview_log" <<'LOG'
# ui-agent-sdk start runtime=machine
{"t":1,"type":"assistant"}
**Tickets:** tip-commented LPT-348.{"t":2,"type":"assistant"}
{"t":3,"type":"assistant"}
**Learnings:** updated (PR #2178 merged){"t":4,"type":"assistant"}
{"t":5,"type":"status"}
# ui-agent-sdk status=finished resultId=run-abc
LOG
preview_out="$(print_content_run_log_preview "$preview_log" 8)"
grep -q 'status=finished' <<<"$preview_out" \
  || fail "preview should keep finished status line: $preview_out"
grep -q 'Tickets:' <<<"$preview_out" \
  || fail "preview should keep Tickets closeout: $preview_out"
grep -q '"type":"assistant"' <<<"$preview_out" \
  && fail "preview must scrub SDK NDJSON crumbs: $preview_out"

grep -q 'sleep_unless_stopped' "$LOOP" \
  || fail "loop must define sleep_unless_stopped for stop-aware gaps"
grep -q 'sleep_unless_stopped "\$_s"' "$LOOP" \
  || fail "usage-limit sleep must use sleep_unless_stopped"
# STOP_FILE mid-sleep must return promptly (not wait out the full window).
STOP_FILE="$STATE_DIR/content-agent.stop"
rm -f "$STOP_FILE"
(
  sleep 1
  touch "$STOP_FILE"
) &
start="$(date +%s)"
sleep_unless_stopped 30
elapsed=$(( $(date +%s) - start ))
rm -f "$STOP_FILE"
(( elapsed < 10 )) || fail "sleep_unless_stopped should wake on STOP_FILE, took ${elapsed}s"

echo "lesson-content-agent worktree isolation ok"
