#!/usr/bin/env bash
# Prune local branches whose upstream was deleted (`git branch -vv` shows
# ": gone]") and remove worktrees still checked out on those branches.
#
# Usage:
#   tools/prune_gone_branches.sh [repo_dir]
#
# Safe defaults: never deletes the current branch; never touches detached
# HEAD worktrees (e.g. content-agent sticky tree); never force-resets dirt.
# File description: git hygiene helper for agent chore-branch leftovers.
set -euo pipefail

REPO="${1:-}"
if [[ -z "$REPO" ]]; then
  REPO="$(cd "$(dirname "$0")/.." && pwd)"
fi
REPO="$(cd "$REPO" && pwd)"

if [[ ! -d "$REPO/.git" && ! -f "$REPO/.git" ]]; then
  echo "error: not a git repo: $REPO" >&2
  exit 1
fi

git -C "$REPO" fetch --prune origin 2>/dev/null || true

current="$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo HEAD)"
removed_wt=0
deleted_br=0

gone_list="$(mktemp "${TMPDIR:-/tmp}/prune-gone.XXXXXX")"
trap 'rm -f "$gone_list"' EXIT

git -C "$REPO" branch -vv \
  | awk '/: gone]/ {
      # $1 is "*" (current) or "+" (other worktree) before the name.
      if ($1 == "*" || $1 == "+") name = $2
      else name = $1
      print name
    }' >"$gone_list"

while IFS= read -r branch || [[ -n "${branch:-}" ]]; do
  [[ -n "${branch:-}" ]] || continue
  [[ "$branch" == "$current" ]] && continue

  # Drop worktrees still on this branch (porcelain path + branch lines).
  wt_path=""
  wt_branch=""
  while IFS= read -r line || [[ -n "${line:-}" ]]; do
    if [[ -z "${line:-}" ]]; then
      if [[ -n "$wt_path" && "$wt_branch" == "$branch" && "$wt_path" != "$REPO" ]]; then
        if git -C "$REPO" worktree remove --force "$wt_path" 2>/dev/null; then
          removed_wt=$((removed_wt + 1))
        else
          rm -rf "$wt_path" 2>/dev/null || true
          git -C "$REPO" worktree prune 2>/dev/null || true
          removed_wt=$((removed_wt + 1))
        fi
      fi
      wt_path=""
      wt_branch=""
      continue
    fi
    case "$line" in
      worktree\ *)
        wt_path="${line#worktree }"
        wt_branch=""
        ;;
      branch\ refs/heads/*)
        wt_branch="${line#branch refs/heads/}"
        ;;
      detached)
        wt_branch=""
        ;;
    esac
  done < <(git -C "$REPO" worktree list --porcelain 2>/dev/null; echo "")

  if git -C "$REPO" branch -D "$branch" >/dev/null 2>&1; then
    deleted_br=$((deleted_br + 1))
  fi
done <"$gone_list"

git -C "$REPO" worktree prune 2>/dev/null || true

if (( removed_wt > 0 || deleted_br > 0 )); then
  echo "pruned gone refs: worktrees=$removed_wt branches=$deleted_br"
fi
