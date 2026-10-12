# 10 — GrokBot (Linux / Chrome UI layout)

GrokBot is a separate agent on a Linux machine. It owns **browser-validatable
UI layout** tickets and **course content** tickets filed by
`/lesson-content-agent` (label `grokbot`). The Mac mini `/ui-design-agent`
owns simulator-backed work and must never pick up GrokBot's queue.

## Split of work

| Owner | Label | Validates on | Typical tickets |
| --- | --- | --- | --- |
| Mac mini `/ui-design-agent` | `ui-agent` | iPhone 13 mini simulator | SoftPulse / cyan cues, Hint waves, hearts, deal timing, `agent_seed` / `openlesson`, iOS-only clipping |
| GrokBot | `grokbot` | Flutter web in Chrome (~375×812) | Layout / theme / spacing / type / clipping; course `teachSpec` / stage / hint / family / catalog wiring that can be proved on web |

Do **not** put both `ui-agent` and `grokbot` on the same issue. One owner.

Content filings also carry `content` (from `/lesson-content-agent`). Fix and
validate those on Chrome unless the ticket was labeled `ui-agent` instead.

## Jira queues

**Mac mini (must exclude GrokBot):**

```
project = LPT AND labels = ui-agent AND labels != needs-human AND labels != grokbot AND statusCategory != Done ORDER BY priority DESC, created ASC
```

**GrokBot:**

```
project = LPT AND labels = grokbot AND labels != needs-human AND statusCategory != Done ORDER BY priority DESC, created ASC
```

Create GrokBot tickets with:

```bash
python3 tools/jira.py create --type Bug --summary "…" --priority Medium \
  --labels ui,grokbot,home --body-file body.md --attach <surface>-issue.png
```

Steps in the body should say Flutter web / Chrome at ~375×812 (not only
the iPhone 13 mini). Attach a current-issue screenshot the same way the
ui-design agent does.

## When the Mac mini agent routes to GrokBot

During a discovery walk, if a finding is layout-only and would show the
same way on web, file it with `grokbot` and **leave it open** — do not
implement it on the mini.

Filing GrokBot tickets is **not** a finished Mac-mini run. The same
`/ui-design-agent` session must keep walking surfaces until it has a
`ui-agent` KEY to fix (or every remaining surface is clean of Mac-mini
work). Do not release the lock / end the run so the loop starts a new
agent when the only tickets filed so far are `grokbot`.

Keep on `ui-agent` whenever proving the fix needs the simulator lock,
SoftPulse gold/cyan state, Hint / hearts / randomization, or iOS-only
behavior.

## GrokBot machine expectations

- Flutter SDK with web enabled (`flutter config --enable-web`), Node 22 for
  functions tooling when needed, repo clone with `make-change` worktrees.
- Validate with `flutter run -d chrome` (or a headless Chrome drive) at a
  phone-sized window; do not claim the Mac mini simulator lock.
- Ship through `.cursor/skills/make-change/SKILL.md` (worktree → PR →
  squash-merge). Skip iPhone 13 mini refresh when the change is web-only
  chrome that does not need a sim proof.
- On product ambiguity, add `needs-human` and stop — same as the ui agent.

## Related

- Mac mini command: `.cursor/commands/ui-design-agent.md` (step 3 queue +
  step 5 **GrokBot routing**)
- Design contract: [ui/design-record.md](../ui/design-record.md)
- Change flow: [09-agent-workflow.md](09-agent-workflow.md)
