# Lesson content agent learnings

Living rules for `/lesson-content-agent`. Read in step 1 of every run.
Update when this run hit a durable mistake the next run would repeat.

Operational memory only — product contract stays in
`docs/agents/04-course.md` and `docs/agents/11-lesson-content-agent.md`.
Lesson-specific pattern notes (full history) live in
`docs/agents/content-agent-run-memory.md` — **grep that file** for the
`act-` / `lesson-` id before filing deal.mode / Still-a-list / family gaps.

## How to update

1. Would the next run make the same mistake without a new rule?
2. If no, leave this file alone.
3. If yes, add or tighten **one** bullet under Never/Prefer. Cap **40**
   bullets total here. Prefer editing an existing bullet over a near-dupe.
4. Also append the full note to
   `docs/agents/content-agent-run-memory.md` (no cap — search target).
5. This agent **ships a learnings-only chore PR** when either file changes
   (`chore/content-agent-learnings-<YYYYMMDD>`). Do not leave durable
   notes only in `~/.live-poker-trainer/content-agent-learnings-pending.md`.
6. If a run cannot open a PR, append to the pending file; the monitor /
   next run must fold pending into the repo via
   `tools/fold_agent_learnings.sh` and clear pending.

## Never again

- Never claim the iPhone 13 mini or call `sim_lock.py` /
  `refresh-simulator.sh` / `agent_tap.py` / `agent_seed.py`.
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
- Never file a lesson-split without `needs-human`.
- Never run `build_seed_course.mjs` to patch one activity — prefer
  `course.json` + `validate_course.mjs`. Prefer `course.json` over
  `wave_*.mjs` as truth; file wave-sync when helpers lag.
- Never file a per-lesson clone when an open `(catalog)` parent covers
  that gap type — edit the parent from
  `scan_content_gaps.mjs --gap … --markdown`.
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
- Never leave durable loop learnings only in the home pending file —
  fold into this file + `content-agent-run-memory.md` and ship.
- Never create a `catalog:teachSpec` parent while
  `scan_content_gaps.mjs` `CATALOG_PARENTS.teachSpec` is `null` —
  interactive missing-teachSpec Highs stay per-lesson; only SoftPulse
  explain catch-up uses `catalog:explain-teachSpec` (LPT-635).

## Prefer

- Prefer `node tools/course/scan_content_gaps.mjs --counts` then
  `--gap <type> --markdown` every run before any lesson walk; sync open
  `(catalog)` parents in one edit via returned `catalogParents` keys
  (pressHints→LPT-626, deal-variants→LPT-627, explain-teachSpec→LPT-635,
  nice-ladder→LPT-624, densify-tap→LPT-628, unguided-softpulse-map→LPT-625)
  — do not re-search Jira for those stems unless a parent is Done/missing.
  If agent Shell hangs with empty output on `--counts`, rerun in a short
  tmux/foreground session (script itself is ~40ms).
- Prefer one catalog ticket per structural gap type (pressHints,
  deal.variants, Nice! ladder, densify-tap, SoftPulse maps, guideRegion,
  permanent-gold). Append checklists; Done sibling clones (skip In Progress).
- Prefer Done’ing a ui-agent densify sibling (e.g. LPT-639/LPT-640) only
  when tip `selectIdentifyDensifiedCoachLine` registers every listed
  `act-…` **and** a Validated-on-origin/main comment exists — then rebuild
  catalog densify-tap LPT-628 (arms/fallthrough + strip cleared priority
  ABSENT). Do not leave the sibling In Progress waiting for a second mini
  pass once both conditions hold; without Validated, tip-comment + rebuild
  parent only.
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
  false-positives `_feltFirstCoach` ids as PRESENT.
- Prefer Done’ing per-lesson honesty tickets when tip already lands the
  fix mid-run; do not reopen Done teachSpecs from stale timer notes.

## Recent fold

- 2026-10-13: Folded pending densify-Validated + catalogParents bullets into
  `docs/agents/content-agent-run-memory.md`; distilled Prefer rules for
  `catalogParents` direct edit and ui-agent densify Done-after-Validated.
  Tip `d98b1025` catalog sync: LPT-628 arms 44 / LPT-626 pressHints 156.
