#!/usr/bin/env bash
# Mutex + stale worktree cleanup for make-change functions deploy.
#
# Concurrent ui-agent + health-timer deploys used to race (Firebase 409) and
# leave orphan `.worktrees/deploy-<pid>` trees when a holder died mid-run.
# mkdir-based lock (portable; macOS has no flock(1)) with PID reclaim.
#
# shellcheck shell=bash

FUNCTIONS_DEPLOY_LOCK_DIR="${FUNCTIONS_DEPLOY_LOCK_DIR:-$HOME/.live-poker-trainer/functions-deploy.lock.d}"
FUNCTIONS_DEPLOY_LOCK_WAIT="${FUNCTIONS_DEPLOY_LOCK_WAIT:-900}"

# Remove .worktrees/deploy-<pid> trees whose pid is not alive.
# Args: primary_checkout_path
prune_stale_deploy_worktrees() {
  local primary="${1:-}"
  [[ -n "$primary" && -d "$primary/.worktrees" ]] || return 0
  local wt base pid
  shopt -s nullglob
  for wt in "$primary"/.worktrees/deploy-*; do
    [[ -e "$wt" ]] || continue
    base="$(basename "$wt")"
    pid="${base#deploy-}"
    if [[ ! "$pid" =~ ^[0-9]+$ ]]; then
      continue
    fi
    if kill -0 "$pid" 2>/dev/null; then
      continue
    fi
    echo "Removing stale deploy worktree $wt (pid $pid dead)"
    git -C "$primary" worktree remove --force "$wt" 2>/dev/null || rm -rf "$wt"
  done
  shopt -u nullglob
  git -C "$primary" worktree prune 2>/dev/null || true
}

# Acquire exclusive deploy lock. Writes pid (+ optional sha) into the lock dir.
# Args: [target_sha]
acquire_functions_deploy_lock() {
  local target_sha="${1:-}"
  local waited=0 holder
  mkdir -p "$(dirname "$FUNCTIONS_DEPLOY_LOCK_DIR")"
  while true; do
    if mkdir "$FUNCTIONS_DEPLOY_LOCK_DIR" 2>/dev/null; then
      echo $$ >"$FUNCTIONS_DEPLOY_LOCK_DIR/pid"
      if [[ -n "$target_sha" ]]; then
        echo "$target_sha" >"$FUNCTIONS_DEPLOY_LOCK_DIR/sha"
      fi
      return 0
    fi
    holder="$(cat "$FUNCTIONS_DEPLOY_LOCK_DIR/pid" 2>/dev/null || true)"
    if [[ -n "$holder" ]] && ! kill -0 "$holder" 2>/dev/null; then
      echo "Stale functions deploy lock (pid $holder dead); reclaiming"
      rm -rf "$FUNCTIONS_DEPLOY_LOCK_DIR"
      continue
    fi
    if (( waited >= FUNCTIONS_DEPLOY_LOCK_WAIT )); then
      echo "Timed out waiting for functions deploy lock (held by pid ${holder:-unknown})" >&2
      return 1
    fi
    if (( waited % 30 == 0 )); then
      echo "Waiting for functions deploy lock (pid ${holder:-unknown})…"
    fi
    sleep 5
    waited=$((waited + 5))
  done
}

# Release lock only if this process holds it.
release_functions_deploy_lock() {
  local holder
  holder="$(cat "$FUNCTIONS_DEPLOY_LOCK_DIR/pid" 2>/dev/null || true)"
  if [[ "$holder" == "$$" ]]; then
    rm -rf "$FUNCTIONS_DEPLOY_LOCK_DIR"
  fi
}
