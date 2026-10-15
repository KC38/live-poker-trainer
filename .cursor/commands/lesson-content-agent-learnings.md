# Lesson content agent learnings

Living rules for `/lesson-content-agent`. Read in step 1 of every run.
Update only when this run hit a durable mistake the next run would repeat.

Operational memory only — product contract stays in
`docs/agents/04-course.md` and `docs/agents/11-lesson-content-agent.md`.
Lesson-specific pattern notes live in
`docs/agents/content-agent-run-memory.md` (short summary + recent
entries; full history in git) — **grep that file** for the `act-` /
`lesson-` id before filing deal.mode / Still-a-list / family gaps.

## How to update

1. Would the next run make the same mistake without a new rule?
2. If no, leave this file alone. Clean re-checks, tip bumps, and
   "Prefer next" pointers go to the local coverage jsonl, **not git**.
3. If yes, add or tighten **one** Never/Prefer bullet. Hard cap **40**
   bullets (`tools/fold_agent_learnings.sh --check` and
   `npm run course:test` fail above 40). Edit an existing bullet before
   adding a near-dupe. Never append dated fold logs here.
4. Optionally append a short note to `content-agent-run-memory.md`.
5. Ship a learnings-only chore PR **only** for that new rule, at most one
   per UTC day; never rescue or chain other open chore PRs.

## Never again

- Never claim the iPhone 13 mini or call `sim_lock.py` /
  `refresh-simulator.sh` / `agent_tap.py` / `agent_seed.py`.
- Never edit PRIMARY (`tools/primary_checkout.sh`) — after #2150 the
  loop cwd is the sticky worktree `$PRIMARY/.worktrees/content-agent`
  (detached `origin/main`). Learnings chore branches/PRs ship from that
  worktree only; leave PRIMARY on clean `main` for `/ui-design-agent`.
- Never implement product fixes or close tickets as Done after a code
  change you made. Audit + file only. Done only when tip catalog already
  matches; re-fetch/ff `origin/main` mid-run before Done (GrokBot lands
  between walks).
- Never use Atlassian MCP. `python3 tools/jira.py` only.
- Never put both `grokbot` and `ui-agent` on one issue. Default `grokbot`.
- Never treat `accessibilityText` / Dart hint speech as authored
  `pressHints` under the recommended bar.
- Never require Hint on `assessmentRole` checkpoint / jump_test steps;
  jump_test / section checkpoints skip needs-human multi-objective splits.
- Never file a lesson-split without `needs-human` — and never re-add
  `needs-human` after product approved / removed it (LPT-282/277/273/270/267/179…).
- Never run `build_seed_course.mjs` to patch one activity — prefer
  `course.json` + `validate_course.mjs`. Prefer `course.json` over
  `wave_*.mjs` as truth; file wave-sync when helpers lag.
- Never file a per-lesson clone when an open `(catalog)` parent covers
  that gap type — edit the parent from
  `scan_content_gaps.mjs --gap … --markdown`. Same for SoftPulse
  residual stems (`Curriculum residual: … SoftPulse still walks`):
  `search` open matches before create — concurrent loops filed
  LPT-728…730 as Duplicate of LPT-725…727 the same tip.
- Never audit renderer ids in camelCase (`selectIdentify`) — catalog uses
  snake_case (`select_identify`); camelCase filters silently report zero gaps.
- Never file handFamily/suitFamily gaps on `deal.mode` `none` outcome /
  habit / pot-math / label / observation tiles — those use SoftPulse
  choice-id cues, not hole+board families.
- Never re-file design-record Still-a-list rebuilds when the step is
  already on the felt (`tableRegionTap` / `*Outcomes` / showdown spots) —
  clear the ledger cell inside the teachSpec ticket instead.
- Never treat “teachSpec present” as schema-complete — diff
  `handFamily` / `suitFamily` against `teach_spec.schema.json` enums.
- Never open a learnings/run-memory chore PR for a clean re-check,
  a "Prefer next" pointer, or a tip-SHA bump — those go to
  `~/.live-poker-trainer/content-agent-coverage.jsonl` only. A chore PR
  is allowed only for a genuinely new Never/Prefer rule, at most one per
  UTC day, and never rescues, chains, or rebases other open chore PRs.
- Never create a `catalog:teachSpec` parent while
  `scan_content_gaps.mjs` `CATALOG_PARENTS.teachSpec` is `null` —
  interactive missing-teachSpec Highs stay per-lesson; only SoftPulse
  explain catch-up uses `catalog:explain-teachSpec` (LPT-635).
- Never mark a lesson structural `clean` when scaffolded non-assessment
  SoftPulse `cues` press numbers are not covered by `pressHints` press
  numbers — `--counts` pressHints **0** only means non-empty arrays
  (LPT-626 Done); incomplete one-per-press stays on catalog **LPT-667**.
  Capstone `NO_HINT` hands stay on **LPT-348** only.
- Never claim learnings/coverage `tip-commented` (or LPT-829 "body rebuilt") until `python3 tools/jira.py comment`/`edit` succeeds and `jira.py get` shows the tip SHA — draft fold text in the worktree is not enough. LPT-829 full 224-row description PUT can hit Jira's 32,767-character limit; when flat, tip-comment the checklist count/SHA only (do not invent a successful rebuild).
- Never write Jira tip-comment markdown via unquoted shell heredocs (`python3 <<PY`) — backticks expand empty and leave blank SHA/`teachSpec` placeholders; always use a quoted heredoc (`python3 <<'PY'`) or write the body file from Python before `jira.py comment`.
- Never build Atlassian wiki bodies with Python f-strings — `f"{{act-…}}"` collapses to `{act-…}` and `f"{{{{{{sha}}}}}}"` yields `{{{sha}}}`; write non-f-string templates with `'{{' + sha + '}}'` (or an equivalent helper) before `jira.py comment`/`edit`.

## Prefer

- Prefer `node tools/course/scan_content_gaps.mjs --counts` then
  `--gap <type> --markdown` every run before any lesson walk; sync open
  `(catalog)` parents in one edit. After #1949, `--counts` includes
  `nice-ladder` (LPT-624); after #1957/#1959 also `unguided-softpulse-map`
  (LPT-625) + `softpulseMapArms` — use `--gap unguided-softpulse-map
  --markdown`, do not hand-count `_guidedPulseTargetId` ABSENT. After
  #1964/#1965, `--counts` also emits `densifyHelperArms` (PRESENT arms
  from `selectIdentifyDensifiedCoachLine`); use `--gap densify-tap
  --markdown` for LPT-628 ABSENT (SI / `player_read_classify` missing
  helper arms) — do not hand-rebuild fallthrough tables. Soft timing
  `act-05-07-01-*` stays on LPT-628 until those arms PRESENT. If agent
  Shell hangs with empty output on `--counts`, rerun in a short
  tmux/foreground session (script itself is ~40ms).
- Prefer one catalog ticket per structural gap type (pressHints empty
  → LPT-626 Done; pressHints **one-per-press** incomplete → **LPT-667**;
  deal.variants, Nice! ladder, densify-tap, SoftPulse maps, guideRegion,
  permanent-gold; split SoftPulse explain Dart table-tap/visual →
  **LPT-669**). On discovery walks after catalog `--counts` all **0**,
  still diff scaffolded non-assessment `cues` press sets vs `pressHints`
  press sets and edit/append **LPT-667** (do not reopen LPT-626). For
  `lessonSplitMap` successors: after **LPT-669** Done (#2256 tip
  `4f56674b`), SoftPulse explain walks are **content-driven** —
  `isTableRegionTapActivity` uses `authoredSoftPulseTargets` (authored
  `soft_pulse` cues) so successors stay walks without a per-id
  allowlist; do **not** reopen LPT-669 or re-file Dart map clones when
  cues + `explainGrading` are present. Pre-Done checklist history (S1
  16 → S2 32 → S3 46 → S4 72) is closed.
  Walked-lesson history lives in run-memory / git log, not here.
- Prefer per-lesson tickets only for deal honesty / wrong cards /
  curriculum splits / true one-offs.
- Prefer `poker_action_sizing` / fixed interactive: `deal.mode` `fixed` +
  `deal.variants` matching Dart `resolveLessonActionSpot` hero/board codes;
  still author deal when SoftPulse map is missing.
- Prefer grepping `docs/agents/content-agent-run-memory.md` for the
  activity id before filing a new structural gap on a walked lesson.
- Prefer citing `act-…` ids and field paths in Jira bodies.
- Prefer GrokBot for schema/content/Dart wiring; `ui-agent` only for
  SoftPulse / Hint timing / hearts / iOS-only proofs.
- Prefer densify fallthrough scans that match Dart
  `selectIdentifyDensifiedCoachLine` arms (`'act-…' =>`), not framed-path
  heuristics alone. SoftPulse-map re-checks must brace-extract
  `_guidedPulseTargetId` arms only — substring search in a nearby chunk
  false-positives `_feltFirstCoach` ids as PRESENT. SoftPulse-map sibling
  **Done** ≠ map arms PRESENT (LPT-621/622/623 Adjust Station/Nit/Maniac
  Done while `act-04-06-03-unguided` / `act-04-07-03-unguided` /
  `act-04-08-03-unguided` still ABSENT from `_guidedPulseTargetId` — keep
  **LPT-625** open; tip-comment, do not clear from sibling Dones alone).
- Prefer Done’ing per-lesson honesty tickets when tip already lands the
  fix mid-run; do not reopen Done teachSpecs from stale timer notes.
- Prefer ending with `IDLE_NO_GAPS` (no PR, no Jira comments) when
  `scan_content_gaps.mjs --counts` matches the last coverage line and the
  only open parents are `needs-human` (e.g. LPT-829 / LPT-351); tip-comment
  needs-human tickets only when their counts changed.
- Prefer re-scanning `--counts` before Done-acking any catalog parent —
  a sibling **Done** or a PR title is not proof that arms/gaps cleared.
