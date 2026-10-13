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

## Fold 2026-10-13

- Prefer open-pot no-redeal finders on `dealt-back-3-0` (BTN) — seats 0–2 are early folds and do not paint `dealt-back-*` (LPT-642). Prefer exact `N chips` dock labels; bare `10` can pointer-tap Home hearts chrome.
- Prefer `python3 tools/jira.py get KEY` before creating a worktree when ui-queue shows In Progress — a concurrent ui-agent may already have shipped/closed it (LPT-642 #1912 vs conflicting #1913). Do not open a second make-change branch for the same KEY.
- Never force-release a live ui-design-agent lock held for another KEY; if claim exits 3 mid-run after a concurrent steal, end with coverage `blocked` after cleaning duplicate PRs/worktrees (2026-10-13 LPT-642).
- Prefer checking `jira.py ui-queue` + open PRs for the same KEY before `gh pr create` when another ui-design-agent is RUNNING — concurrent LPT-642 runs produced #1912 (merged) and #1913 (closed as duplicate); the loser should stop that KEY and not fight the lock (2026-10-13).
- Prefer treating a lock with `pid: none` that still heartbeats as live (do not `--force` release); wait for `NO_PID_STALE_SECONDS` (10 min) only when heartbeats also stop (LPT-642 race).
