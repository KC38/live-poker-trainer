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
  fold into this file + `content-agent-run-memory.md` and ship a
  `chore/content-agent-learnings-*` PR the same tick. Coverage
  `learnings: pending` means unfolder until that PR is on tip and
  `~/.live-poker-trainer/content-agent-learnings-pending.md` has zero
  `- ` bullets — do not treat the coverage field alone as folded.
- Never create a `catalog:teachSpec` parent while
  `scan_content_gaps.mjs` `CATALOG_PARENTS.teachSpec` is `null` —
  interactive missing-teachSpec Highs stay per-lesson; only SoftPulse
  explain catch-up uses `catalog:explain-teachSpec` (LPT-635).

## Prefer

- Prefer `node tools/course/scan_content_gaps.mjs --counts` then
  `--gap <type> --markdown` every run before any lesson walk; sync open
  `(catalog)` parents in one edit. If agent Shell hangs with empty
  output on `--counts`, rerun in a short tmux/foreground session (script
  itself is ~40ms).
- Prefer one catalog ticket per structural gap type (pressHints,
  deal.variants, Nice! ladder, densify-tap, SoftPulse maps, guideRegion,
  permanent-gold). Append checklists; Done sibling clones (skip In Progress).
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

- Prefer when rebuilding densify-tap **LPT-628**: after a sibling densify PR clears arms, recompute ABSENT priority from `selectIdentifyDensifiedCoachLine` + course renderers — do not keep stale fallthrough counts from the prior tip.

- Prefer after a densify sibling reaches **Done** with Validated-on-origin/main: immediately rebuild catalog densify-tap **LPT-628** ABSENT list from the new tip (helper arms + fallthrough) — do not wait for the next catalog walk. Sibling **Done** ≠ helper arms PRESENT — re-scan `selectIdentifyDensifiedCoachLine` (LPT-464 Soft timing Done while `act-05-07-01-*` still ABSENT; LPT-644 Mix Done #1937 → helper **44→47** / fallthrough **156→153**, Soft timing still ABSENT). Mix guided is `poker_action_sizing` — do not keep it on SI densify ABSENT after scaffolded/unguided/checkpoint land.
- Prefer after ui-agent Nice!/Oops Dones (cyan-selection LPT-641, open-pot felt redeal LPT-642, etc.): tip-comment open content catalog parents (LPT-624/625/626/628/635) on the new SHA — ui under Nice!/Oops does **not** clear those gaps; keep Hint-enablement companions (LPT-643) open separately.

- Prefer when `content-agent-coverage.jsonl` already has a catalog-parent sync line for this tip SHA: skip re-editing those parents unless a count/body error remains (e.g. LPT-626 raw **156** vs excluded fix **151**); tip-comment honesty/fingerprint Highs that still show zero hits for the SHA.
- Prefer when tip advances with scanner-only `NO_HINT_ACTIVITY_IDS` / pressHints exclude (#1916): rebuild **LPT-626** from `scan_content_gaps --gap pressHints --markdown` so the checklist count equals `--counts` (**151**) — drop manual 156−5 subtract wording; tip-comment other catalog parents on the new SHA without inventing count deltas.
- Prefer on a tip-stable catalog-synced SHA (including learnings-only tips like #1931/#1932/#1934/#1935 after LPT-292, and non-content ops tips like #1933 SDK queue-empty skip): tip-comment parents without inventing count deltas; tip-comment unchecked **To Do** High teachSpecs (LPT-258 capped / LPT-295 Observe wide / LPT-298 Meet LAG / LPT-301 Adjust LAG) rather than re-spamming In Progress / honesty already commented on that SHA; still append coverage for the SHA even when Jira tip-comments already exist from a mid-run. When re-checking Soft timing densify ABSENT, read arms only from `lib/ui/course/widgets/rex_coach_line.dart` `selectIdentifyDensifiedCoachLine` — inline `'act-05-07-01-*' =>` strings in `select_identify_activity.dart` framed/`_coachFallback` maps are not densify helper arms.

- Prefer after a High interactive teachSpec Done: append SoftPulse explain Nice! onto **LPT-624** when explain now has cues but no `explainGrading`; tip-comment **LPT-626** if scaffolded/unguided already listed; do **not** shrink LPT-635 S1–S2 when scanner full explain-teachSpec drops. If the land authors `deal.mode` `fixed` without `deal.variants` (e.g. LPT-280 #1920, LPT-283 #1923, LPT-292 #1930 `act-06-11-03-guided/scaffolded/unguided`): rebuild **LPT-627** from `--gap deal-variants --markdown` (count may *rise* — 75→78 for Adjust TAG). If outcome-tile `deal.mode` `none` (e.g. LPT-286 #1925 `act-06-11-01-*`, LPT-289 #1927 `act-06-11-02-*`): deal-variants stays flat — tip-comment **LPT-627** only, still rebuild **LPT-624** Nice! (38→39→40 for TIGHT→BARREL→SAMPLE then TIGHT→AGGRO→MODEL; 40→41 for CREDIT→TIGHTER→NO LIGHT after LPT-292). Depth chrome honesty (LPT-417) can survive teachSpec — re-check, do not Done. Still-a-list cells marked STALE in the High may survive the land — tip-comment the Done ticket; do not file a rebuild.

- Prefer when tip advances with ui-agent Hint-enablement **LPT-643** (`lessonFrameCanHint` / scaffolded Hint dock): tip-comment **LPT-626** that Hint enablement does **not** author `pressHints` — keep the pressHints catalog open; do not Done LPT-626 or Meet Nit pressHints clones from LPT-643 alone. Leave LPT-643 Done to ui-agent Validated-on-origin/main.

## Recent fold

- 2026-10-13: Folded 211 pending bullets into
  `docs/agents/content-agent-run-memory.md`; distilled Never/Prefer above.
  Added `tools/fold_agent_learnings.sh` so pending cannot stall again.
- 2026-10-13e: Folded cyan-selection ≠ catalog-clear (LPT-641); content
  loop backs off 600s on SDK exit 15 (504), matching ui-agent.
- 2026-10-13f: Generalized Nice!/Oops ui Dones ≠ catalog-clear to cover
  LPT-642 open-pot felt redeal (#1912) alongside LPT-641 cyan.
- 2026-10-13g: Tip `2604f13e` (#1916) scanner pressHints **156→151**;
  rebuild LPT-626 from markdown; tip-comment To Do High teachSpecs
  (LPT-258/283) when catalog parents already synced on the prior tip.
- 2026-10-13h: After LPT-280 teachSpec (#1920) deal-variants 73→74 + Nice! 36→37 (`act-06-09-01-explain`); LPT-417 survives teachSpec when stackLabel still missing.
- 2026-10-13i: After LPT-283 teachSpec (#1923) deal-variants 74→75 + Nice! 37→38 (`act-06-10-01-explain` HARD→COOLER→EGO); scaffolded/unguided stay on LPT-626 only.
- 2026-10-13i: Tip `561e3e4f` (#1926 LPT-643 Hint enablement on tip, still In Progress): LPT-643 ≠ authored pressHints / LPT-626 clear; Meet Nit routing unchanged (Nice! 39 / pressHints 151).
- 2026-10-13j: After LPT-286/289 outcome-tile teachSpecs (#1925/#1927) Nice! 38→40 (`act-06-11-01-explain` TIGHT→BARREL→SAMPLE, `act-06-11-02-explain` TIGHT→AGGRO→MODEL); deal-variants stays **75**; teachSpec 109→101 / explain-teachSpec 40→38; LPT-635 keeps 12 S1–S2.
- 2026-10-13k: After LPT-292 Adjust TAG teachSpec (#1930) Nice! 40→41 (`act-06-11-03-explain` CREDIT→TIGHTER→NO LIGHT); deal-variants **75→78** (guided/scaffolded/unguided `fixed` sans variants); teachSpec 101→97 / explain-teachSpec 38→37; LPT-635 keeps 12 S1–S2; Still-a-list “respect check” still stale on tip.
- 2026-10-13l: Tip `abd48de8` (#1931 learnings-only): scan flat 151/78/97/37; LPT-464 densify Done ≠ Soft timing helper arms; tip-commented LPT-295/298/301 To Do Highs.
- 2026-10-13m: Tip `bbad143c` (#1933 SDK queue-empty + #1932 learnings): scan still flat 151/78/97/37; tip-comment parents + To Do Highs / honesty on new SHA; Soft timing densify arms still ABSENT.
- 2026-10-13n: Tip `7f869c29` (#1934 learnings-only): scan still flat 151/78/97/37; tip-comment parents + To Do Highs / IP teachSpecs / honesty; Soft timing densify still ABSENT in `rex_coach_line.dart` (helper 44) despite framed-path `act-05-07-01-*` strings in `select_identify_activity.dart`.
- 2026-10-13o: Tip `c7ee5e78` (#1935 learnings-only): scan still flat 151/78/97/37; tip-comment parents + To Do Highs / IP teachSpecs / honesty; SoftPulse-map still 68 arms / 18+qq ABSENT; Soft timing densify still ABSENT (helper 44).
- 2026-10-13p: Tip `d42d78b0` (#1937 LPT-644 Mix densify + #1936 learnings): rebuilt LPT-628 44→47 / fallthrough 156→153; Soft timing densify still ABSENT; scan JSON gaps flat 151/78/97/37.

