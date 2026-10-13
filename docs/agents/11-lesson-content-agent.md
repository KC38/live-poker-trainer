# 11 — Lesson content agent

Unattended auditor for course content. Command:
`.cursor/commands/lesson-content-agent.md`. Loop:
`tools/lesson_content_agent_loop.sh`.

Runs on the Mac mini **without** the iPhone simulator, alongside
`/ui-design-agent`. Files tickets; does not implement.

## Two-stage model

| Stage | SoftPulse | Hint | Hearts on miss |
| --- | --- | --- | --- |
| `guided` | On (walks presses) | Off while gold SoftPulse on | Free |
| `scaffolded` | Off until Hint | Authored `pressHints` (one per press) | Spends |

`assessmentRole`: `checkpoint` | `jump_test` on scaffolded steps → **no
Hint** (path / placement role preserved). Legacy explain→guided;
unguided→scaffolded; old checkpoint/jump_test stages→scaffolded+role.

## teachSpec (optional → required over time)

Authored on activities (`content/course/v2/schemas/teach_spec.schema.json`):

- `deal.mode`: `none` | `fixed` | `random_in_class` (+ hand/suit families,
  `fixedCards`, `variants`)
- `pressHints[]`: one text per press
- `cues[]`: SoftPulse targets per press

Pilot: `lesson-01-01-01-your-two-cards`. Lessons that follow it on every
interactive step: `lesson-01-01-02-suits-and-ranks` (LPT-81),
`lesson-01-01-03-blinds-and-button` (LPT-85), `lesson-01-02-01-hand-ranks`
(LPT-88), `lesson-01-02-02-best-five-kickers` (LPT-91),
`lesson-01-03-01-fold-check-call` (LPT-94),
`lesson-01-03-02-bet-raise-allin` (LPT-98),
`lesson-01-04-01-streets-and-order` (LPT-101),
`lesson-01-05-01-winning-pots` (LPT-104),
`lesson-01-06-01-guided-complete-hand` (LPT-108),
`lesson-01-06-02-section-one-jump` (LPT-110),
`lesson-02-01-01-position-labels` (LPT-112), `lesson-02-01-02-acting-order`
(LPT-115), `lesson-02-02-01-hand-families` (LPT-119),
`lesson-02-03-01-open-fold` (LPT-122), `lesson-02-04-01-facing-raise`
(LPT-125), `lesson-02-05-01-effective-stack` (LPT-128),
`lesson-02-06-01-live-habits` (LPT-131),
`lesson-02-07-01-baseline-full-hand` (LPT-135),
`lesson-02-07-02-section-two-jump` (LPT-137),
`lesson-03-01-01-reading-live-table` (LPT-138),
`lesson-03-02-01-flop-hand-classes` (LPT-141),
`lesson-03-03-01-outs-and-price` (LPT-144), `lesson-03-04-01-flop-decisions`
(LPT-149), `lesson-03-05-01-turn-decisions` (LPT-152),
`lesson-03-06-01-river-decisions` (LPT-155),
`lesson-03-07-01-multiway-fundamentals` (LPT-158),
`lesson-03-08-01-leak-repair` (LPT-161),
`lesson-03-08-02-section-three-jump-test` (LPT-165),
`lesson-04-01-01-ranges-not-hands` (LPT-167),
`lesson-04-02-01-threebet-squeeze` (LPT-170),
`lesson-04-03-01-continuation-plans` (LPT-174),
`lesson-04-04-01-sizing-communicates` (LPT-177),
`lesson-04-05-01-spr-commitment` (LPT-180),
`lesson-04-06-01-observe-sticky-caller` (LPT-184),
`lesson-04-06-02-meet-calling-station` (LPT-187),
`lesson-04-06-03-adjust-calling-station` (LPT-190),
`lesson-04-07-01-observe-narrow-player` (LPT-193),
`lesson-04-07-02-meet-nit` (LPT-196), `lesson-04-07-03-adjust-nit`
(LPT-200), `lesson-04-08-01-observe-wild-aggressor` (LPT-203),
`lesson-04-08-02-meet-maniac` (LPT-206), `lesson-04-08-03-adjust-maniac`
(LPT-210), `lesson-04-09-01-type-identification` (LPT-213),
`lesson-04-10-01-exploit-checkpoints` (LPT-216),
`lesson-04-10-02-section-four-jump-test` (LPT-219),
`lesson-05-01-01-multiway-ranges` (LPT-222),
`lesson-05-02-01-deep-stack-play` (LPT-225), `lesson-05-03-01-implied-odds`
(LPT-228), `lesson-05-04-01-thin-value-bluffcatch` (LPT-231),
`lesson-05-06-01-line-reading` (LPT-237), `lesson-05-05-01-lines-and-probes`
(LPT-234), `lesson-05-08-01-table-dynamics` (LPT-245),
`lesson-05-09-01-session-discipline` (LPT-248),
`lesson-05-09-02-section-five-checkpoint` (LPT-251),
`lesson-06-04-01-polar-merged` (LPT-262),
`lesson-06-05-01-overbets-geometric` (LPT-265), `lesson-06-06-01-blockers`
(LPT-268), `lesson-06-09-01-threebet-fourbet` (LPT-280),
`lesson-06-10-01-difficult-folds` (LPT-283),
`lesson-06-11-01-observe-selective` (LPT-286), `lesson-06-11-02-meet-tag`
(LPT-289), `lesson-06-11-03-adjust-tag` (LPT-292),
`lesson-06-12-02-meet-lag` (LPT-298), `lesson-06-13-01-mix-five-types`
(LPT-304), `lesson-06-13-02-section-six-checkpoint` (LPT-307),
`lesson-07-01-01-preflop-to-flop` (LPT-308),
`lesson-07-04-01-pot-type-plans` (LPT-318), `lesson-07-05-01-hu-vs-multiway`
(LPT-321), `lesson-07-06-01-stack-depth-plans` (LPT-324),
`lesson-07-07-01-same-cards-types` (LPT-328),
`lesson-07-08-01-type-board-line` (LPT-331), `lesson-07-10-01-capstone-srp`
(LPT-337), `lesson-07-10-02-capstone-3bet` (LPT-339). Missing teachSpec on
interactive steps is a content gap the agent files.

## Jira routing

| Labels | Owner | Validates |
| --- | --- | --- |
| `content,grokbot,…` | GrokBot (Linux / Chrome) | Catalog, schema, Dart wiring, web ~375×812 |
| `content,ui-agent,…` | Mac mini `/ui-design-agent` | SoftPulse/Hint/hearts/deal timing / iOS |

One owner per issue. Content agent default = `grokbot`.

## Catalog-bundled tickets

Structural gaps that only differ by lesson/activity id are filed as **one
catalog ticket** with a full affected checklist. The fixer applies the same
pattern across every listed activity in one change (not lesson-by-lesson
PRs). Examples: missing `pressHints`, missing `deal.variants`, SoftPulse
explain Nice! short ladder, densify “Tap the best answer”, unguided SoftPulse
maps, densify `guideRegion`, permanent-gold spoilers.

Per-lesson tickets stay for deal honesty / wrong cards, curriculum splits
(`needs-human`), and true one-offs. See
`.cursor/commands/lesson-content-agent.md` §5.

## Fast gap scan

```bash
node tools/course/scan_content_gaps.mjs --counts
node tools/course/scan_content_gaps.mjs --gap pressHints --markdown
```

Gaps: `pressHints` | `deal-variants` | `teachSpec` | `explain-teachSpec` |
`nice-ladder` | `unguided-softpulse-map`. `--counts` also reports
`softpulseMapArms` and `densifyHelperArms`. Those two are activity ids on
`'act-…' =>` arms inside the Dart switch, matched by brace depth. A regex
that stops at the first `}` drops arms that follow an inner block. A
truncated regex literal is what made `--counts` fail to parse (#1964).
`catalogParents.teachSpec` stays null
(per-lesson Highs, not one catalog parent). The content agent runs this
every pass to refresh `(catalog)` parents. Tests:
`tools/course/scan_content_gaps.test.mjs` via `npm run course:test`.

## Learnings (must land in git)

| File | Role |
| --- | --- |
| `.cursor/commands/lesson-content-agent-learnings.md` | ≤40 Never/Prefer rules — read every run |
| `docs/agents/content-agent-run-memory.md` | Full lesson/catalog pattern notes — grep by `act-` / `lesson-` |
| `tools/fold_agent_learnings.sh` | Folds `~/.live-poker-trainer/*-learnings-pending.md` into the repo |

Durable loop notes must ship in a
`chore/content-agent-learnings-<YYYYMMDD>` PR (or fold via the script +
monitor). Do not leave them only in the home pending file.

## Loop ops

```bash
tools/lesson_content_agent_loop.sh setup|verify|start|status|stop|once
```

Shares `~/.live-poker-trainer/secrets.env` with the UI agent. Coverage:
`~/.live-poker-trainer/content-agent-coverage.jsonl`. Does **not** touch
`simulator-lock.json`.

## Related

- [04-course.md](04-course.md)
- [10-grokbot.md](10-grokbot.md)
- Design record → Lesson content
