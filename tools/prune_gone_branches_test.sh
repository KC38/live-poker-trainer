#!/usr/bin/env bash
# Unit test for tools/prune_gone_branches.sh
set -euo pipefail

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PRUNE="$ROOT/tools/prune_gone_branches.sh"
[[ -x "$PRUNE" ]] || chmod +x "$PRUNE"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/prune-gone.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

bare="$tmp/bare.git"
git init --bare -q "$bare"

# Primary clone with main + a "gone" feature branch.
clone="$tmp/clone"
git clone -q "$bare" "$clone"
git -C "$clone" config user.email t@t
git -C "$clone" config user.name t
printf 'repo\n' >"$clone/pubspec.yaml"
git -C "$clone" add pubspec.yaml
git -C "$clone" commit -m init -q
git -C "$clone" branch -M main
git -C "$clone" push -q origin main

git -C "$clone" checkout -b cursor/chore-content-learnings-gone -q
printf 'chore\n' >"$clone/note.txt"
git -C "$clone" add note.txt
git -C "$clone" commit -m chore -q
git -C "$clone" push -q -u origin cursor/chore-content-learnings-gone
git -C "$clone" checkout main -q

# Worktree on that branch, then delete the remote branch (gone).
wt="$tmp/wt-gone"
git -C "$clone" worktree add -q "$wt" cursor/chore-content-learnings-gone
git -C "$clone" push -q origin --delete cursor/chore-content-learnings-gone
git -C "$clone" fetch --prune origin -q

git -C "$clone" branch -vv | grep -q 'cursor/chore-content-learnings-gone.*: gone]' \
  || fail "fixture branch should be gone: $(git -C "$clone" branch -vv)"

bash "$PRUNE" "$clone"

git -C "$clone" show-ref --verify --quiet refs/heads/cursor/chore-content-learnings-gone \
  && fail "gone branch should be deleted"
[[ ! -e "$wt" ]] || fail "worktree path should be removed: $wt"
git -C "$clone" rev-parse --abbrev-ref HEAD | grep -qx main \
  || fail "main checkout must remain"

# No-op when nothing is gone.
out="$(bash "$PRUNE" "$clone")"
[[ -z "$out" ]] || fail "second prune should be silent, got: $out"

echo "prune_gone_branches ok"
