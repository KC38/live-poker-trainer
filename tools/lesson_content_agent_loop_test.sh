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

echo "lesson-content-agent worktree isolation ok"
