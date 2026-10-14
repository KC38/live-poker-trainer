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
- Prefer `tools/flutter_run_fast.sh --no-cache` (or a fresh Xcode `Runner.app`) before filing Hint-disabled on SoftPulse-off scaffolded steps — a cached binary can disagree with tip `catalog.json` / `assessmentRole` and look like LPT-643 while source already enables Hint (`lessonFrameCanHint`).

## Fold 2026-10-13

- Prefer `tools/tee_exit.sh` in a short `jira-create-*` tmux + `tools/wait_done.sh` for `jira.py create` with PNG `--attach` (LPT-644: foreground create hung 10+ min with no stdout; tee_exit finished in ~4s). Avoid stacking `text ~` JQL searches in the same shell as mini drives — they can hang like `labels !=`.
- Prefer `tools/flutter_run_fast.sh --checkout PRIMARY` when `refresh-simulator.sh` aborts on an untracked primary file (e.g. `test/ui/course/_content_agent_probe_*.dart` from a content-agent) — do not discard that dirt or `needs-human` the ticket; origin/main Dart still hot-restarts (LPT-407).
- Prefer `rg '<<<<<<<|=======|>>>>>>>'` on conflicted files after a merge resolution **before** `git commit` — an earlier StrReplace can leave markers in HEAD while the working tree looks clean until the next edit (LPT-520).

## Fold 2026-10-13

- Prefer asserting densified frame speech by absence of "Tap the best answer." plus the densified stem (`Best leak note —`) — `withLessonTapInstruction` may rewrite authored `pick` to `tap`, so exact `pick the …` needles false-fail a fixed bubble (LPT-662).

## Fold 2026-10-14

- Prefer wiring `LessonActionDock(identifyUnavailable: spot.identifyUnavailable)` in `AuthoredMultiStepActivity` when Capstone/transfer spots set the flag — setting `identifyUnavailable` on `LessonActionSpot` alone does not reach the dock (LPT-670).

## Fold 2026-10-14

- Prefer patching `~/.live-poker-trainer/app-cache/<key>/Runner.app/.../assets/course/v2/catalog.json` from the checkout (or `--no-cache` rebuild) when `flutter_run_fast` hits Unknown lesson for an id that exists in source `catalog.json` — the native cache key ignores asset-only catalog updates, so hot-restart alone keeps the stale bundle (LPT-707).

## Fold 2026-10-14

- Prefer SoftPulse-none unguided dock labels (`C-bet 6`, `Call`) over large `Interactive …` accessibility tiles when auto-walking to a checkpoint — the Interactive needle can eat the step budget and never reach SoftPulse-off densify (LPT-764 validate).

## Fold 2026-10-14

- Prefer checking SoftPulse explain widget fixtures for `teachSpec` soft_pulse

## Fold 2026-10-14

- Prefer protecting English count phrases (`Your two cards`, `the two in front`, `Those/These two` before stay/are) inside `alignLessonTableCopy` before spoken rank-word remaps — a template board deuce remapped to a trey otherwise turns Hint into "Your three cards" (LPT-791) or Nice! into "Those three stay…" (LPT-797). Prefer stem-only Your two cards densify coach lines over hardcoded Ah Kd / Qs Jh 2c (LPT-792). Prefer validating Hint on SoftPulse-off siblings (unguided-mix) when guided SoftPulse keeps Hint disabled by design — do not treat Hint-disabled under gold SoftPulse as a regression (LPT-791 closeout).

## Fold 2026-10-14 LPT-813

- Prefer `villainSeatCount: 0` on conceptual outcome scenes that do not
  deal holes (effective-stack / depth tiles; default `1` paints a decoy
  Them pair — LPT-220). Prefer framed `LessonTableStage` with
  `lessonNineMaxVillainCount` + `seatNames: Seat N` when coach copy names
  seat numbers on a nine-handed ask (LPT-240); densify `blindsSeats`+
  `numberSeats` covers the no-frame path.
- 2026-10-13 LPT-641: loop rewrote `ui-agent-handoff.json` / reclaimed the mini mid-implement. When heartbeat/guard print not-the-holder, stop driving until `sim_lock.py claim` succeeds again (LPT-637); do not force-release the loop holder.

## Fold 2026-10-14

- Prefer waiting for Nice! / counting Continues before treating SoftPulse-none + densify stem as SoftPulse-off checkpoint idle — the window after the last SoftPulse press can still show densify before Nice!, so a too-early `<KEY>-validated.png` captures Nice! instead of the ask (LPT-814).

## Fold 2026-10-15

- Prefer checking `supportsHoleHandSeatDeal` / sibling deal maps when a curriculum split adds a new `act-…` id (e.g. LPT-83 `act-01-01-02-03-guided-suited`) — missing the id falls through to Them/You + text docks, mini overflow (~147px), SoftPulse-off, and densify spoil (LPT-815 / LPT-816).
- Prefer SoftPulse-quiet densify stems for scaffolded/unguided (`showTargetCue` unlocks guided only until Hint) — idle coach must not name the correct tile while SoftPulse is off (LPT-817 Working model; LPT-818 Station).
