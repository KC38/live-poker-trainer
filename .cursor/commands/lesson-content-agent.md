---
description: >-
  Lesson content agent for Live Poker Trainer. Audits course content on
  origin/main (no simulator), verifies teachSpec / stages / hints / cues /
  randomization / hand+suit families / curriculum gaps, and files Jira
  tickets for GrokBot (default) or the Mac mini ui-agent when Chrome cannot
  validate. Audit and file only — never implements. Runs unattended
  alongside /ui-design-agent.
---

# Lesson content agent

You own **course content quality**: lesson structure, teachSpecs, variations,
hints, SoftPulse cues, hand/suit families, and Duolingo-style curriculum
gaps. Each run **audits** the catalog and **files** tickets. You do **not**
implement fixes, claim the iPhone 13 mini, or open make-change PRs.

Hard rules:

- One run, one audit pass: walk lessons / units from the coverage ledger,
  file or **append to catalog-bundled** tickets for every solid finding,
  log coverage, end. Never launch a subagent or parallel content-agent run.
- **No simulator.** Do not call `sim_lock.py`, `refresh-simulator.sh`,
  `agent_tap.py`, or `agent_seed.py`. Leave the mini for `/ui-design-agent`.
- Unattended: never ask the user a question. Product ambiguity → file with
  `needs-human` and continue auditing.
- Never edit the primary checkout for product code **except** learnings
  files (see §6). Ticket bodies go under
  `$PRIMARY/.cursor/tmp/content-agent/`.
- Read [lesson-content-agent-learnings.md](lesson-content-agent-learnings.md)
  and grep [content-agent-run-memory.md](../../docs/agents/content-agent-run-memory.md)
  for the target `act-` / `lesson-` id every run.
- Default Jira owner label: **`grokbot`**. Use **`ui-agent`** only when the
  finding cannot be validated in Flutter web / Chrome (~375×812).

```
Run progress:
- [ ] 0. Primary synced; Jira available
- [ ] 1. Contract + learnings read
- [ ] 2. Fast catalog gap scan (scan_content_gaps.mjs)
- [ ] 3. Audit target chosen (catalog parent sync, High re-check, or lesson walk)
- [ ] 4. Findings filed/updated (catalog-bundled when structural)
- [ ] 5. Coverage logged; learnings updated if needed; report
```

## 0. Sync and Jira

```bash
PRIMARY="$(tools/primary_checkout.sh)"
cd "$PRIMARY"
git fetch origin main
git merge --ff-only origin/main 2>/dev/null || true
python3 tools/jira.py check
```

If `jira.py check` fails → end with `JIRA_UNAVAILABLE`. Do not wait.

Use `python3 tools/jira.py` only (no Atlassian MCP). Bodies live under
`$PRIMARY/.cursor/tmp/content-agent/`.

| Action | Command |
| --- | --- |
| Search | `python3 tools/jira.py search '<JQL>'` |
| Get | `python3 tools/jira.py get LPT-NN` |
| Create (GrokBot) | `python3 tools/jira.py create --type Bug --summary "…" --priority Medium --labels content,grokbot,lesson --body-file body.md` |
| Create (Mac mini) | `python3 tools/jira.py create --type Bug --summary "…" --priority Medium --labels content,ui-agent,lesson --body-file body.md` |
| Comment | `python3 tools/jira.py comment LPT-NN --body-file note.md` |
| Edit | `python3 tools/jira.py edit LPT-NN [--body-file body.md] [--add-label needs-human]` |

## 1. Read the contract

**Every run:**

1. [docs/agents/04-course.md](../../docs/agents/04-course.md) — two-stage
   model, teachSpec, activity renderers.
2. [docs/agents/11-lesson-content-agent.md](../../docs/agents/11-lesson-content-agent.md)
   — this agent's contract and routing.
3. [lesson-content-agent-learnings.md](lesson-content-agent-learnings.md)
   (≤40 bullets) and grep
   [content-agent-run-memory.md](../../docs/agents/content-agent-run-memory.md)
   for the surface’s lesson/activity ids.
4. If `~/.live-poker-trainer/content-agent-learnings-pending.md` has
   bullets, run `tools/fold_agent_learnings.sh content` and ship a
   learnings-only chore PR before or after the audit (do not leave
   pending unfolder).
5. [content/course/v2/README.md](../../content/course/v2/README.md) and
   schemas under `content/course/v2/schemas/` (especially `activity`,
   `teach_spec`, `common`).

**When auditing a lesson surface:**

6. Design record **Lesson content** + that lesson's ledger row in
   `docs/ui/design-record.md`.
7. The lesson JSON in `content/course/v2/course.json` (and generated
   `assets/course/v2/catalog.json` / bank when relevant).

## 2. Fast catalog gap scan (every run)

Before choosing a lesson walk, run:

```bash
node tools/course/scan_content_gaps.mjs --counts
# → { counts, catalogParents: { pressHints: "LPT-626", … } }
# Then for the gap you will sync:
node tools/course/scan_content_gaps.mjs --gap pressHints --markdown
# gaps: pressHints | deal-variants | teachSpec | explain-teachSpec
```

Use `catalogParents` + the markdown table to **edit that LPT in one shot**
(no Jira search rediscovery). Keep `CATALOG_PARENTS` in
`scan_content_gaps.mjs` in sync when filing/closing parents. Do not re-walk
90 lessons to rediscover the same structural gaps.

Time-box: ≤10 minutes on scan → parent sync unless a High honesty ticket
needs a tip re-check.

## 3. Choose the audit target

**Priority order:**

1. **Open `(catalog)` parents** whose checklist is stale vs
   `scan_content_gaps.mjs` — edit body + comment SHA.
2. **High / In Progress content tickets** — re-verify still valid on this
   SHA; Done + comment when fixed; leave In Progress alone unless tip
   already satisfies acceptance.
3. **Discovery walk** only for honesty / curriculum / one-offs the scanner
   cannot see. Use
   `~/.live-poker-trainer/content-agent-coverage.jsonl`
   (`at`, `sha`, `surface`, `result`, `ticket`, `leads`):
   - A surface with prior `leads`.
   - A lesson whose `content/course` or wave source changed since last walk.
   - The surface walked longest ago.

Prefer honesty Highs and fingerprint gaps over re-auditing densify /
pressHints lesson-by-lesson when catalog parents already exist.

`surface` values: `lesson:<id>`, `unit:<id>`, `section:<id>`,
`catalog:teachSpec`, `catalog:stages`, `catalog:curriculum-gaps`,
`catalog:pressHints`, `catalog:deal-variants`, `catalog:nice-ladder`,
`catalog:densify-tap`, `catalog:unguided-softpulse-map`,
`catalog:explain-teachSpec`, `catalog:guideRegion`,
`catalog:permanent-gold`.

## 4. Audit checklist

Work from the catalog JSON and schemas. For each activity / lesson in the
surface, check:

### Stages (two-stage model)

- Stage is only `guided` or `scaffolded`.
- Former explain → guided; unguided → scaffolded; checkpoint/jump_test →
  scaffolded + `assessmentRole`.
- **Guided:** SoftPulse teach, free misses, Hint off while gold SoftPulse is
  on. Authored cues when interactive.
- **Scaffolded (practice):** no SoftPulse until Hint; **authored**
  `teachSpec.pressHints` (one per press) — fallback-only Hint is a gap
  (recommended bar).
- **Scaffolded + assessmentRole** (`checkpoint` / `jump_test`): **no Hint**
  (no `coachMedia` hint, no `pressHints`).

### teachSpec

- Present on interactive table steps (pilot standard: Your two cards).
- `deal.mode`: `none` | `fixed` | `random_in_class`.
- `random_in_class` has `handFamily` and/or `suitFamily`.
- `fixed` has `fixedCards`.
- **Variations (both):** (1) `random_in_class` enabled when the step teaches
  a class of hands; (2) authored `deal.variants` for review/practice pools
  when the lesson should show distinct spots.
- Coach copy / grading must be able to follow the deal (no hard-coded combo
  that disagrees with randomization).

### Hints and cues

- Scaffolded non-assessment: one `pressHints` entry per press (≥1).
- Guided interactive: cues defined; Hint not required while SoftPulse walks.
- Assessment: no hints.
- Cues use SoftPulse targets only (`GlowHighlight` system) — flag second cue
  systems if content asks for arrows/pulse widgets.

### Hand / suit families

- When `deal.mode` is `random_in_class`, families match the teaching goal
  (e.g. suited, offsuit, pair, four_suits, broadway).
- Missing families on a class-teaching step = gap ticket.

### Curriculum gaps (Duolingo-style)

Flag when **any** of these hold:

1. Fewer than a teach + practice + review/checkpoint rhythm for a concept.
2. Missing stage coverage (no guided teach, or no scaffolded practice) for a
   concept unit.
3. Lesson ledger "Still a list" steps that should move onto the felt.
4. **Multiple concepts merged into one lesson** (more than one new idea in
   `objectives` / title conjunctions like "Fold, check, call"). Propose a
   split into one-lesson-per-concept with the old lesson becoming a unit —
   label **`needs-human`** (progress ids / unlocks).

Compare against Plans 07–09 wave scope in `content/course/v2/README.md` and
live-cash NLH scope (validator bans tournaments / PLO / rake / HUD).

### Routing (owner)

| Label set | When |
| --- | --- |
| `content,grokbot,lesson` (default) | Content JSON, schema, validator, Dart teachSpec wiring, stage rules, copy, Chrome-validatable layout at ~375×812 |
| `content,ui-agent,lesson` | Needs iPhone 13 mini: SoftPulse gold/cyan proof, Hint wave timing, hearts spend/restore, deal timing, `agent_seed` / iOS-only |

Never put both `grokbot` and `ui-agent` on one issue.

## 5. File tickets

### Bundle structural gaps (default)

When the **same structural ask** applies across lessons and only the
activity/lesson ids differ, file **one catalog ticket**, not one ticket per
lesson. The implementer must fix **every listed activity in one change**
(same pattern, same fields, same validator proof).

**Bundle these gap types** (search/update the open catalog ticket first):

| Gap type | Catalog surface / summary stem | Owner |
| --- | --- | --- |
| Scaffolded missing `pressHints` | `catalog:pressHints` — “Scaffolded non-assessment steps missing authored pressHints (catalog)” | `grokbot` |
| Missing `deal.variants` | `catalog:deal-variants` — “Interactive fixed steps missing authored deal.variants (catalog)” | `grokbot` |
| SoftPulse explain Nice! short ladder | `catalog:nice-ladder` — “Explain SoftPulse Nice! repeats idle ask (catalog)” | `grokbot` |
| Densify still “Tap the best answer” | `catalog:densify-tap` — “Densified asks still say Tap the best answer (catalog)” | `grokbot` |
| Unguided SoftPulse map missing | `catalog:unguided-softpulse-map` — “Unguided SoftPulse maps missing (catalog)” | `grokbot` |
| SoftPulse explain missing teachSpec/cues | `catalog:explain-teachSpec` — “SoftPulse explain steps missing teachSpec cues (catalog)” | `grokbot` |
| Densify SoftPulse missing `guideRegion` | `catalog:guideRegion` — “Densified SoftPulse golds every tile / missing guideRegion (catalog)” | `ui-agent` |
| Permanent gold / icon spoilers | `catalog:permanent-gold` — “Correct SoftPulse tiles permanently gold-tipped (catalog)” | `ui-agent` |
| Same teachSpec field gap on many steps | `catalog:teachSpec` — name the field (e.g. “interactive steps missing teachSpec deal/cues (catalog)”) | `grokbot` |

**Keep a per-lesson (or per-activity) ticket only when:**

- Deal **honesty** / wrong cards / wrong streetLabel for a specific spot
- Curriculum **split** / new unit (`needs-human`)
- A one-off schema or renderer bug that is not a repeated content pattern
- An In Progress ticket already owns that exact lesson fix — comment there

**Match before create.** Search for the catalog summary stem (and
`labels = content`). If an open catalog ticket exists: **edit its body** to
append newly found `lessonId` / `activityId` rows (and SHA), comment the
delta, do **not** open a sibling lesson ticket. If only old per-lesson
tickets exist for that gap type: create/update the catalog parent, comment
each child with “Bundled into LPT-NN”, link Relates, then transition
children to **Done** (work tracked on the parent) — skip any child that is
**In Progress**.

### Body template (catalog bundle)

```markdown
## What happened
Structural gap: <gap type>. Same fix applies across the catalog; do not
ship lesson-by-lesson PRs for this pattern.

## Affected (fix all in one change)
| Lesson id | Activity id | Stage / role | Notes |
| --- | --- | --- | --- |
| lesson-… | act-… | scaffolded | e.g. pressHints length 0 |

## Steps (for implementer)
1. Apply the **same** field/pattern fix to **every** row above (and any
   siblings still missing it when you re-scan `course.json` / wave sources).
2. Keep wave helpers (`wave_*.mjs`) in sync with `course.json`.
3. Validate: `node tools/course/validate_course.mjs`
4. Spot-check ≥2 affected lessons on Flutter web / Chrome ~375×812
   **or** iPhone 13 mini if `ui-agent`. Prefer one PR covering the catalog.

## Expected
Cite two-stage model + teachSpec contract (docs/agents/04-course.md,
11-lesson-content-agent.md). Gap type: <pressHints | deal.variants |
nice-ladder | densify-tap | softpulse-map | teachSpec | guideRegion |
permanent-gold | …>.

## Acceptance criteria
1. Every listed activity (and any remaining catalog matches for this gap)
   satisfies the contract
2. Validator / unit test locks the rule when applicable
3. Spot-check on owner device for ≥2 lessons
4. Design-record / handbook sentence updated when behavior changes

Device: GrokBot Chrome ~375×812 (or iPhone 13 mini when `ui-agent`).
SHA audited: `<SHA>`.
```

### Body template (lesson-specific exception)

```markdown
## What happened
<concrete content / schema / catalog path — why this is NOT a catalog bundle>

## Steps (for implementer)
1. Open `content/course/v2/course.json` lesson `<id>` (or named schema).
2. <exact field gap>
3. Validate: `node tools/course/validate_course.mjs`
4. Prove on Flutter web / Chrome ~375×812 **or** iPhone 13 mini if `ui-agent`.

## Expected
Cite two-stage model + teachSpec contract. Name the lesson-specific check.

## Acceptance criteria
1. <observable in catalog / validator>
2. <observable in app on the owner’s device>
3. Validator / unit test locks the rule when applicable
4. Design-record / handbook sentence updated when behavior changes

Device: GrokBot Chrome ~375×812 (or iPhone 13 mini when `ui-agent`).
SHA audited: `<SHA>`.
```

Priority: Highest = first lesson / onboarding broken; High = mis-teach or
missing randomization on a core step; Medium = structural catalog gaps;
Low = polish splits already marked needs-human.

**Curriculum split / new unit proposals** always get `needs-human` until a
human approves id migration.

Prefer **few catalog tickets** per run over many lesson clones. You never
implement them.

## 6. Coverage, learnings, report

Append one line to `~/.live-poker-trainer/content-agent-coverage.jsonl`:

```json
{"at": "<ISO>", "sha": "<SHA>", "surface": "<surface>", "result": "filed|clean|needs-human|jira-unavailable", "ticket": "LPT-NN|null", "leads": ["…"], "learnings": "updated|pending|unchanged"}
```

Update learnings per
[lesson-content-agent-learnings.md](lesson-content-agent-learnings.md)
**How to update**:

1. Distill a Never/Prefer bullet into
   `.cursor/commands/lesson-content-agent-learnings.md` (cap 40).
2. Append the full note to
   `docs/agents/content-agent-run-memory.md` (no cap).
3. **Ship a learnings-only chore PR**
   (`chore/content-agent-learnings-<YYYYMMDD>`) in the same turn when
   either file changed. This is the only product-repo write this agent
   may open a PR for.
4. Only if git/PR is unavailable: append to
   `~/.live-poker-trainer/content-agent-learnings-pending.md` and set
   coverage `learnings: pending`. The next run (or monitor) must run
   `tools/fold_agent_learnings.sh content` and ship.

Delete `$PRIMARY/.cursor/tmp/content-agent/` scratch bodies if desired.

Reply short: SHA, surface, tickets filed, leads, learnings status
(`updated` = shipped to git; `pending` = home file only).
Never claim a simulator lock. Never start `/ui-design-agent` work.
