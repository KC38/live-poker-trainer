#!/usr/bin/env bash
# Fold home-dir pending agent learnings into the repo so the next loop
# run reads them from git (not only from ~/.live-poker-trainer/).
#
#   tools/fold_agent_learnings.sh              # fold both if pending
#   tools/fold_agent_learnings.sh content      # content agent only
#   tools/fold_agent_learnings.sh ui           # ui-design agent only
#   tools/fold_agent_learnings.sh --dry-run
#
# Content: appends pending bullets into docs/agents/content-agent-run-memory.md
# and prints a reminder to distill Never/Prefer into
# .cursor/commands/lesson-content-agent-learnings.md (cap 40).
# UI: appends into .cursor/commands/ui-design-agent-learnings.md under
# "## Pending fold" when under the 40-bullet cap, else into
# docs/agents/ui-agent-run-memory.md.
#
# Does not commit. Caller (monitor / chore) reviews and ships a PR, then
# truncates the pending file(s).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATE="${HOME}/.live-poker-trainer"
DRY=0
TARGET="both"

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    content|ui|both) TARGET="$arg" ;;
    -h|--help)
      sed -n '2,20p' "$0"
      exit 0
      ;;
  esac
done

fold_content() {
  local pending="$STATE/content-agent-learnings-pending.md"
  local memory="$ROOT/docs/agents/content-agent-run-memory.md"
  if [[ ! -s "$pending" ]]; then
    echo "content: no pending"
    return 0
  fi
  local count
  count="$(grep -c '^- ' "$pending" || true)"
  echo "content: folding $count pending bullets → $memory"
  if [[ "$DRY" -eq 1 ]]; then
    return 0
  fi
  mkdir -p "$(dirname "$memory")"
  if [[ ! -f "$memory" ]]; then
    cat >"$memory" <<'EOF'
# Content agent run memory

Append-only operational notes from `/lesson-content-agent` loops.
EOF
  fi
  {
    echo ""
    echo "## Fold $(date -u '+%Y-%m-%d')"
    echo ""
    grep '^- ' "$pending" || true
  } >>"$memory"
  # Keep a one-line stub so the next agent still sees the path exists,
  # but clear the backlog once folded into git.
  cat >"$pending" <<'EOF'
# content-agent learnings pending

(empty — last fold wrote into docs/agents/content-agent-run-memory.md;
 distill any new Never/Prefer into lesson-content-agent-learnings.md
 and ship chore/content-agent-learnings-YYYYMMDD)
EOF
  echo "content: pending cleared; distill Never/Prefer into"
  echo "  .cursor/commands/lesson-content-agent-learnings.md if needed (cap 40)"
}

fold_ui() {
  local pending="$STATE/ui-agent-learnings-pending.md"
  local learnings="$ROOT/.cursor/commands/ui-design-agent-learnings.md"
  local memory="$ROOT/docs/agents/ui-agent-run-memory.md"
  if [[ ! -s "$pending" ]]; then
    echo "ui: no pending"
    return 0
  fi
  # Skip if only the empty header / placeholder
  if ! grep -q '^- ' "$pending"; then
    echo "ui: no pending bullets"
    return 0
  fi
  local count bullets_now
  count="$(grep -c '^- ' "$pending" || true)"
  bullets_now="$(grep -c '^- ' "$learnings" || true)"
  echo "ui: folding $count pending bullets (learnings currently $bullets_now)"
  if [[ "$DRY" -eq 1 ]]; then
    return 0
  fi
  if [[ "$((bullets_now + count))" -le 40 ]]; then
    {
      echo ""
      echo "## Pending fold ($(date -u '+%Y-%m-%d'))"
      echo ""
      grep '^- ' "$pending" || true
    } >>"$learnings"
    echo "ui: appended into ui-design-agent-learnings.md"
  else
    mkdir -p "$(dirname "$memory")"
    if [[ ! -f "$memory" ]]; then
      cat >"$memory" <<'EOF'
# UI design agent run memory

Overflow operational notes when ui-design-agent-learnings.md is at the
40-bullet cap. Grep before repeating a retry.
EOF
    fi
    {
      echo ""
      echo "## Fold $(date -u '+%Y-%m-%d')"
      echo ""
      grep '^- ' "$pending" || true
    } >>"$memory"
    echo "ui: learnings at cap — appended into docs/agents/ui-agent-run-memory.md"
  fi
  cat >"$pending" <<'EOF'
# ui-agent learnings pending

(empty — last fold wrote into the repo; see ui-design-agent-learnings.md
 or docs/agents/ui-agent-run-memory.md)
EOF
}

case "$TARGET" in
  content) fold_content ;;
  ui) fold_ui ;;
  both) fold_content; fold_ui ;;
esac
