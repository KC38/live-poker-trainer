# UI design agent run memory

Overflow operational notes when ui-design-agent-learnings.md is at the
40-bullet cap. Grep before repeating a retry.

## Fold 2026-10-12

- Open queue: `python3 tools/jira.py ui-queue` (local filter). Jira `labels != X` searches can hang for 10+ minutes with no stdout (2026-10-13).

## Fold 2026-10-13

- Prefer reclaiming immediately when `refresh-simulator.sh` leaves the mini
  FREE after stopping the worktree flutter session — the preflight
  `SIM_LOCK_RUN_ID` is stale; claim a new ui-design-agent id before
  closeout `agent_seed` / `agent_tap` (LPT-639).
- Prefer `HOME=/Users/kc` (or absolute `/Users/kc/.live-poker-trainer/…`
  paths) for coverage append and learnings-pending on cloud/machine SDK
  shells — a sandboxed `$HOME` under `/var/folders/…/tmp.*/home` leaves the
  real ledger and lock untouched (LPT-639).
