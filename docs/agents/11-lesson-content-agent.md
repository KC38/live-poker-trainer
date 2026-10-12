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

Pilot: `lesson-01-01-01-your-two-cards`. Missing teachSpec on interactive
steps is a content gap the agent files.

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
