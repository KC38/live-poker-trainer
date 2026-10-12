#!/usr/bin/env bash
# Unit tests for tools/functions_deploy_lock.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=functions_deploy_lock.sh
source "$ROOT/tools/functions_deploy_lock.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

tmp="$(mktemp -d "${TMPDIR:-/tmp}/functions-deploy-lock.XXXXXX")"
trap 'rm -rf "$tmp"; release_functions_deploy_lock 2>/dev/null || true' EXIT

export FUNCTIONS_DEPLOY_LOCK_DIR="$tmp/lock.d"
export FUNCTIONS_DEPLOY_LOCK_WAIT=5

# Fresh acquire / release.
acquire_functions_deploy_lock "abc123" \
  || fail "acquire should succeed on empty lock"
[[ -f "$FUNCTIONS_DEPLOY_LOCK_DIR/pid" ]] || fail "lock pid missing"
[[ "$(cat "$FUNCTIONS_DEPLOY_LOCK_DIR/sha")" == "abc123" ]] \
  || fail "lock sha mismatch"
release_functions_deploy_lock
[[ ! -d "$FUNCTIONS_DEPLOY_LOCK_DIR" ]] || fail "release should remove lock dir"

# Stale lock (dead pid) is reclaimed.
mkdir -p "$FUNCTIONS_DEPLOY_LOCK_DIR"
echo 999999999 >"$FUNCTIONS_DEPLOY_LOCK_DIR/pid"
acquire_functions_deploy_lock "def" \
  || fail "acquire should reclaim stale lock"
[[ "$(cat "$FUNCTIONS_DEPLOY_LOCK_DIR/pid")" == "$$" ]] \
  || fail "reclaimed lock should be ours"
release_functions_deploy_lock

# Live holder blocks until timeout.
mkdir -p "$FUNCTIONS_DEPLOY_LOCK_DIR"
echo $$ >"$FUNCTIONS_DEPLOY_LOCK_DIR/pid"
# Subshell cannot steal our live lock within WAIT.
FUNCTIONS_DEPLOY_LOCK_WAIT=2
if (
  # Fake a different pid file that is still alive (parent).
  acquire_functions_deploy_lock "blocked"
); then
  fail "acquire must not succeed while live holder exists"
fi
rm -rf "$FUNCTIONS_DEPLOY_LOCK_DIR"
FUNCTIONS_DEPLOY_LOCK_WAIT=5

# Stale deploy worktree prune (dirs only; git worktree remove falls back to rm).
primary="$tmp/primary"
mkdir -p "$primary/.worktrees"
# Fake worktree dir named after a dead pid.
stale_wt="$primary/.worktrees/deploy-999999998"
mkdir -p "$stale_wt"
# Alive pid worktree must be kept.
live_wt="$primary/.worktrees/deploy-$$"
mkdir -p "$live_wt"
prune_stale_deploy_worktrees "$primary"
[[ ! -d "$stale_wt" ]] || fail "stale deploy worktree should be removed"
[[ -d "$live_wt" ]] || fail "live deploy worktree must be kept"

echo "functions_deploy_lock ok"
