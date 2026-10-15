# Content agent run memory

Short operational summary for `/lesson-content-agent`. Capped rules live in
`.cursor/commands/lesson-content-agent-learnings.md`. Full per-lesson walk
history (Oct 12–15 2026, ~550 fold sections) was pruned on 2026-10-15 —
recover it with `git log -p -- docs/agents/content-agent-run-memory.md`.

When auditing a lesson, grep this file (and git history if needed) for its
`act-` / `lesson-` id before filing deal.mode / Still-a-list / handFamily gaps.

## Summary (as of 2026-10-15)

- All catalog JSON gap counts from `scan_content_gaps.mjs --counts` are **0**
  except short-ladder **224** on **LPT-829** (needs-human, product call).
- **LPT-351** (live warm-up curriculum split) is needs-human; leave open.
- Catalog parents LPT-624/625/626/627/628/635/667/669 are Done; do not reopen
  without a fresh `--counts` regression.
- Sections 1–7 lessons were all walked structurally clean on tips through
  `3b070569`; re-walking them produced only no-op notes. Do not re-walk
  without a content/ change on `origin/main`.
- Clean re-checks belong in `~/.live-poker-trainer/content-agent-coverage.jsonl`,
  not in this file or a PR.

## Recent entries

- Tip `3b070569` Prefer-next discovery `lesson-02-07-01-02-vs-raise-plan` / `act-02-07-01-02-explain-vsraise` + `act-02-07-01-scaffolded-vs` + `act-02-07-01-unguided-lab`: structural clean — one objective Respond to a raise with a planned action; explain SoftPulse OPEN→PLAN + `explainGrading` "Open → Plan → Act." **concept-aligned** (content-driven `authoredCues` / LPT-669 Done — do not reopen Dart map; SoftPulse residual N/A — LPT-668 split child OPEN→PLAN under vs-raise-plan; first-child was NINE→SAME→POSITION); scaffolded SoftPulse `call-22` one-per-press pressHints 1/1 densify N/A (`poker_action_sizing` `random_in_class` pair; SoftPulse map PRESENT in `poker_action_sizing_activity.dart`); unguided SoftPulse `lab-3bet` one-per-press pressHints 1/1 densify N/A (`full_table_hand_lab` `random_in_class` broadway/offsuit; SoftPulse coach line PRESENT); primary-family `random_in_class` without distractor variants — do not reopen LPT-627; short-ladder 3/5 already on catalog **LPT-829**; curriculum **LPT-668** Done — do not clone / SoftPulse residual N/A. Catalog `--counts` short-ladder **224** (other gaps **0**); tip-commented **LPT-829**/**LPT-351**; Prefer next NEVER `lesson-02-07-01-03-habits-while-deciding` / Low curriculum **LPT-351**. Vs-raise-plan Prefer NEVER re-check clean.
- Tip `83ca36db` Prefer-next discovery `lesson-02-07-01-01-full-ring-open` / `act-02-07-01-explain-full` + `act-02-07-01-guided-ep`: structural clean — one objective Make a baseline open on a full ring; explain SoftPulse NINE→SAME→POSITION + `explainGrading` "Nine → Same → Position." **concept-aligned** (content-driven `authoredCues` / teaching captions / LPT-669 Done — do not reopen Dart map; SoftPulse residual N/A — first-child concept-aligned, no LPT-749-style residual); guided SoftPulse `open-ajs` PRESENT densify N/A (`poker_action_sizing` `random_in_class` broadway/suited; SoftPulse map PRESENT in `poker_action_sizing_activity.dart`); pressHints N/A (both guided SoftPulse walks); short-ladder 2/5 already on catalog **LPT-829**; curriculum **LPT-668** Done — do not clone / SoftPulse residual N/A. Catalog `--counts` short-ladder **224** (other gaps **0**); tip-commented **LPT-829**/**LPT-351**; Prefer next NEVER `lesson-02-07-01-02-vs-raise-plan` / Low curriculum **LPT-351**. Full-ring-open Prefer NEVER re-check clean.
- Tip `83ca36db` Prefer-next discovery `lesson-02-06-01-03-protect-and-wait` / `act-02-06-01-03-explain-protect` + `act-02-06-01-unguided-protect` + `act-02-06-01-checkpoint-oot`: structural clean — one objective Protect cards and avoid acting out of turn; explain SoftPulse COVER→WAIT content-driven + teaching captions (COVER Protect hole cards / WAIT) **concept-aligned** (content-driven `authoredCues` / LPT-669 Done — do not reopen Dart map; SoftPulse residual N/A — LPT-749 was Follow-action WATCH→SAY→COVER→WAIT); unguided SoftPulse `chip-on-cards` one-per-press pressHints 1/1 densify PRESENT SoftPulse-quiet after LPT-844 (`select_identify` `deal.mode` `none` — do not file handFamily; `selectIdentifyDensifiedCoachLine` SoftPulse-quiet non-spoiling stem); checkpoint SoftPulse `oot-bad` cue kind `none` hintless densify PRESENT SoftPulse-off after LPT-786; short-ladder 3/5 already on catalog **LPT-829**; curriculum **LPT-133** Done — do not clone / SoftPulse residual N/A. Catalog `--counts` short-ladder **224** (other gaps **0**); tip-commented **LPT-829**/**LPT-351**; Done-ack **LPT-749**; Prefer next NEVER `lesson-02-07-01-01-full-ring-open` / Low curriculum **LPT-351**. Protect-and-wait Prefer NEVER re-check clean.

## Fold 2026-10-15gm (75357dea Prefer NEVER bet re-check)

- Tip-stable `75357dea` (#2788 Prefer NEVER call re-check learnings on tip — this fold ships Prefer NEVER bet re-check). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **234** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — Jira 32,767 limit); other parents Done.
- Prefer NEVER discovery `lesson-01-03-02-01-bet` / `act-01-03-02-explain-aggro` + `act-01-03-02-guided-bet` + `act-01-03-02-checkpoint-names`:
  - one objective Bet when the pot is unchecked; explain SoftPulse BET + `explainGrading` "Bet puts the first chips in." **concept-aligned** (LPT-733 Done BET-only — was BET→RAISE→ALL-IN; do not reopen SoftPulse residual).
  - guided SoftPulse `bet-half` PRESENT (`poker_action_sizing` `random_in_class` top_pair; densify N/A).
  - checkpoint SoftPulse `named-bet` cue kind `none` hintless (`random_in_class` air).
  - short-ladder 3/5 already on **LPT-829**; curriculum **LPT-100** Done — do not clone; SoftPulse residual N/A.
- Tip-commented **LPT-829**/**LPT-351**; leave open; leave ui-agent alone.
- Prefer next NEVER: `lesson-01-03-02-02-raise` / Low curriculum **LPT-351** / open catalog **LPT-829**.
- act-01-03-02-*: structural clean on tip — teachSpec/SoftPulse companions Done; curriculum via LPT-100 only; LPT-733 Done.

## Fold 2026-10-15gq (40730c30 Prefer NEVER action-order re-check)

- Tip-stable `40730c30` (#2793 Prefer NEVER four-streets + rescue all-in fold — this fold ships Prefer NEVER action-order re-check). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **234** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — Jira 32,767 limit); other parents Done.
- Prefer NEVER discovery `lesson-01-04-01-02-action-order` / `act-01-04-01-02-explain-order` + `act-01-04-01-scaffolded-order` + `act-01-04-01-checkpoint-postflop`:
  - one objective Know who acts first before and after the flop; explain SoftPulse BIG BLIND→CLOCKWISE→BUTTON + `explainGrading` "Left of the big blind → clockwise." **concept-aligned** (content-driven `authoredCues` / LPT-669 Done — do not reopen Dart map).
  - scaffolded SoftPulse seat-utg→seat-hj→seat-co→seat-btn one-per-press pressHints 4/4 (`order_sequence` `deal.mode` `none`; densify N/A).
  - checkpoint SoftPulse `sb-first` cue kind `none` hintless densify PRESENT SoftPulse-off non-spoiling after LPT-808.
  - short-ladder 3/5 already on **LPT-829**; curriculum **LPT-103** Done — do not clone; SoftPulse residual N/A (LPT-737 Done — do not reopen).
- Tip-commented **LPT-829**/**LPT-351**; leave open; leave ui-agent alone.
- Prefer next NEVER: `lesson-01-04-01-03-street-ends` / Low curriculum **LPT-351** / open catalog **LPT-829**.
- act-01-04-01-02-*: structural clean on tip — teachSpec/pressHints/densify/SoftPulse companions Done; curriculum via LPT-103 only; LPT-737 Done.

## Fold 2026-10-15gw (bd1c83f8 Prefer NEVER section-one-jump re-check)

- Tip-stable `bd1c83f8` (#2799 densify spoil scan; open #2798/#2800/#2801 showdown + main-and-side-pots + guided-complete-hand Prefer NEVER rescued onto this chore — this fold ships Prefer NEVER section-one-jump re-check). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **234** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — Jira 32,767 limit); other parents Done.
- Prefer NEVER discovery `lesson-01-06-02-section-one-jump` / `act-01-06-02-jump-ranks` + `act-01-06-02-jump-order` + `act-01-06-02-jump-legal` + `act-01-06-02-jump-hand`:
  - multi-objective Confirm hand ranking / acting order / legal action / complete toy hand; all four `scaffolded`+`assessmentRole` `jump_test` hintless cue kind `none` (assessment container — skip curriculum-split / pressHints).
  - jump-ranks `compare_rank` `random_in_class` flush + straight/two_pair seat variants SoftPulse you→sam→jo kind `none`.
  - jump-order `order_sequence` `deal.mode` `none` SoftPulse `j-utg`→`j-hj`→`j-co`→`j-btn` (do not file handFamily).
  - jump-legal `poker_action_sizing` `fixed` QhJd·Td8s2c +2 suit variants SoftPulse `j-check`.
  - jump-hand `authored_multi_step_hand` `random_in_class` suited_ace/suited SoftPulse `j-open`→`j-yes`.
  - densify N/A; short-ladder 4/5 already on **LPT-829**; LPT-107/110 Done — do not clone; SoftPulse residual N/A.
- Tip-commented **LPT-829**/**LPT-351**; leave open; leave ui-agent alone.
- Prefer next NEVER: `lesson-07-11-01-live-warmup-prep` / Low curriculum **LPT-351** / open catalog **LPT-829**.
- act-01-06-02-*: structural clean on tip — jump_test assessment container only.
