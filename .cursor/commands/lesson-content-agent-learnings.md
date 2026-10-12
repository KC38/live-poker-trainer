# Lesson content agent learnings

Living rules for `/lesson-content-agent`. Read in step 1 of every run.
Update in step 5 when this run hit a durable mistake the next run would
repeat.

Operational memory only — product contract stays in
`docs/agents/04-course.md` and `docs/agents/11-lesson-content-agent.md`.

## How to update

1. Would the next run make the same mistake without a new rule?
2. If no, leave this file alone.
3. If yes, add or tighten **one** bullet. Cap **40** bullets.
4. This agent does not ship product PRs — append durable bullets to
   `~/.live-poker-trainer/content-agent-learnings-pending.md`. Fold into
   this file in a chore PR when pending has 5+ bullets.

## Never again

- Never claim the iPhone 13 mini or call `sim_lock.py` /
  `refresh-simulator.sh` / `agent_tap.py` / `agent_seed.py`. Leave the
  device for `/ui-design-agent`.
- Never implement, make-change, or close a ticket as Done after a code
  fix. Audit + file only. Re-verify open tickets; Done only when the
  catalog already matches the expected contract.
- Never use Atlassian MCP. `python3 tools/jira.py` only.
- Never put both `grokbot` and `ui-agent` on one issue. Default `grokbot`.
- Never treat accessibilityText fallback as a passing authored hint under
  the recommended bar — scaffolded non-assessment needs `pressHints`.
- Never require Hint on `assessmentRole` checkpoint / jump_test steps.
- Never file a lesson-split without `needs-human` (progress / lesson ids).
- Never run `build_seed_course.mjs` to patch one activity — prefer
  `course.json` + `validate_course.mjs` (full seed can wipe hand-maintained
  rows). Keep wave helpers in sync when you file wave-source tickets.
- Never file a new per-lesson clone when an open catalog ticket already
  covers that gap type — edit/append the parent checklist instead.
- Never leave duplicate per-lesson structural tickets open after creating
  a catalog parent — comment “Bundled into LPT-NN”, Relates-link, Done the
  children (skip In Progress).

## Prefer

- Prefer catalog surfaces `lesson:<id>` and `catalog:teachSpec` early in
  Section 1 before advanced sections.
- Prefer **one catalog ticket per structural gap type** listing every
  affected `act-…` — not one ticket per lesson when only content ids differ
  (pressHints, deal.variants, Nice! ladder, densify-tap, SoftPulse maps,
  guideRegion, permanent-gold). Append to the open catalog parent instead
  of filing siblings.
- Prefer per-lesson tickets only for deal honesty / wrong cards /
  curriculum splits (`needs-human`) / true one-offs.
- Prefer citing activity ids (`act-…`) and field paths in Jira bodies.
- Prefer GrokBot for schema/content/Dart wiring; `ui-agent` only for
  SoftPulse / Hint timing / hearts / iOS-only proofs.

## Recent run notes

- 2026-10-12: Agent introduced. Two-stage model (guided | scaffolded) +
  `assessmentRole` + optional `teachSpec`. Pilot: Your two cards.
