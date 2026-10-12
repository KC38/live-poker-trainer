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
`lesson-03-06-01-river-decisions` (LPT-155). Missing teachSpec on
interactive steps is a content gap the agent files.

## Jira routing

| Labels | Owner | Validates |
| --- | --- | --- |
| `content,grokbot,…` | GrokBot (Linux / Chrome) | Catalog, schema, Dart wiring, web ~375×812 |
| `content,ui-agent,…` | Mac mini `/ui-design-agent` | SoftPulse/Hint/hearts/deal timing / iOS |

One owner per issue. Content agent default = `grokbot`.

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
