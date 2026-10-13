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
  `chore/content-agent-learnings-*` (or `cursor/chore-content-*`)
  PR the same tick so the next agent reads them from git. Coverage
  `learnings: pending` means unfolder until that PR is on tip and
  `~/.live-poker-trainer/content-agent-learnings-pending.md` has zero
  `- ` bullets — do not treat the coverage field alone as folded.
  After the PR opens, leave PRIMARY clean on `main` (loop
  `sync_primary` returns any leftover `cursor/chore-content-*`).
- Never create a `catalog:teachSpec` parent while
  `scan_content_gaps.mjs` `CATALOG_PARENTS.teachSpec` is `null` —
  interactive missing-teachSpec Highs stay per-lesson; only SoftPulse
  explain catch-up uses `catalog:explain-teachSpec` (LPT-635).

- Never write Jira tip-comment markdown via unquoted shell heredocs (`python3 <<PY`) — backticks expand empty and leave blank SHA/`teachSpec` placeholders; always use a quoted heredoc (`python3 <<'PY'`) or write the body file from Python before `jira.py comment`.
- Never build Atlassian wiki monospace with nested f-string braces like `f"{{{{{{sha}}}}}}"` — that yields literal `{{{sha}}}`; use `'{{' + sha + '}}'` (or an equivalent helper) before `jira.py comment`/`edit`.

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
  false-positives `_feltFirstCoach` ids as PRESENT. SoftPulse-map sibling
  **Done** ≠ map arms PRESENT (LPT-621/622/623 Adjust Station/Nit/Maniac
  Done while `act-04-06-03-unguided` / `act-04-07-03-unguided` /
  `act-04-08-03-unguided` still ABSENT from `_guidedPulseTargetId` — keep
  **LPT-625** open; tip-comment, do not clear from sibling Dones alone).
- Prefer Done’ing per-lesson honesty tickets when tip already lands the
  fix mid-run; do not reopen Done teachSpecs from stale timer notes.

- Prefer when rebuilding densify-tap **LPT-628**: after a sibling densify PR clears arms, recompute ABSENT priority from `selectIdentifyDensifiedCoachLine` + course renderers — do not keep stale fallthrough counts from the prior tip.

- Prefer after a densify sibling reaches **Done** with Validated-on-origin/main: immediately rebuild catalog densify-tap **LPT-628** ABSENT list from the new tip (helper arms + fallthrough) — do not wait for the next catalog walk. Sibling **Done** ≠ helper arms PRESENT — re-scan `selectIdentifyDensifiedCoachLine` (LPT-464 Soft timing Done while `act-05-07-01-*` still ABSENT; LPT-644 Mix Done #1937 → helper **44→47** / fallthrough **156→153**; LPT-645/646 3-bet+hard-fold Done #1979 → helper **47→53** / fallthrough **153→147**; LPT-647 Observe selective Done #2002 → helper **53→57** / fallthrough **147→143**; LPT-648 Meet TAG Done #2010 → helper **57→61** / fallthrough **143→139**; LPT-649 Observe wide Done #2012 → helper **61→65** / fallthrough **139→135**; LPT-650 Meet LAG #2017 → helper **65→69** / fallthrough **135→131**; LPT-651 Adjust LAG #2019 → helper **69→71** / fallthrough **131→129**; LPT-652 Adjust TAG #2024 → helper **71→72** / fallthrough **129→128** — LPT-654 Same cards Done #2031 → helper **72→73** / fallthrough **128→127**; LPT-655 Section 6 checkpoint Done #2036 → helper **73→78** / fallthrough **127→122**; LPT-656 Carry preflop plan Done #2041 → helper **78→82** / fallthrough **122→118** (`act-07-01-01-guided` / `scaffolded` / `unguided` / `checkpoint`); LPT-657 Map turn Done/landed #2045 → helper **82→86** / fallthrough **118→114** (`act-07-02-01-guided` / `scaffolded` / `unguided` / `checkpoint`); LPT-658 Compose river Done/landed #2054 → helper **86→89** / fallthrough **114→111** (`act-07-03-01-scaffolded` / `unguided` / `checkpoint` — guided is `poker_action_sizing`, skip); LPT-659/660/661 pot-type / HU-MW / stacks landed #2060 → helper **89→101** / densify-tap ABSENT **140→128** (`act-07-04-01-*` / `act-07-05-01-*` / `act-07-06-01-*`), Soft timing still ABSENT; on tip `2172c3f4` those three are already **Done** — Done-ack + keep Soft timing Priority on LPT-628; LPT-662/663/664/665 S7 book/warmup/cite landed #2063 → helper **101→111** / densify-tap **128→118** (`act-07-09-01-*` / `act-07-11-01-*` / `act-07-07-01-checkpoint` / `act-07-08-01-checkpoint`); on tip `7f22b9e7` those four are already **Done** — Done-ack + rebuild LPT-628 body off stale In Progress wording the same tick; Soft timing still ABSENT). Mix guided is `poker_action_sizing` — do not keep it on SI densify ABSENT after scaffolded/unguided/checkpoint land. Leave ui-agent densify siblings to Validated-on-origin/main (then Done-ack when status is Done — do not leave “In Progress” wording after Validated); tip-comment Relates + arms ABSENT/PRESENT on **LPT-628** when filed/landed; rebuild LPT-628 the same tick when helper count moves (filing alone with flat helper is tip-comment only). After #2056 prefer `--gap densify-tap --markdown` over hand fallthrough tables (ABSENT count is broader than prior fallthrough). Tip-comment / coverage “rebuilt LPT-628” ≠ body synced — before skipping densify rebuild, verify description densify-tap row count / helper arms / SHA audited against `--counts` (tip `1c0553ff`: comments claimed LPT-652 rebuild while body still said **71** @ `4a199707`; tip `a5081631` body still **140**/helper **89** while tip `9f5dd58d`/#2060 already had helper **101** — rebuild body the same tick).
- Prefer after ui-agent Nice!/Oops Dones (cyan-selection LPT-641, open-pot felt redeal LPT-642, etc.): tip-comment open content catalog parents (LPT-624/625/626/628/635) on the new SHA — ui under Nice!/Oops does **not** clear those gaps; keep Hint-enablement companions (LPT-643) open separately.

- Prefer when `content-agent-coverage.jsonl` already has a catalog-parent sync line for this tip SHA: skip re-editing those parents unless a count/body error remains (e.g. LPT-626 raw **156** vs excluded fix **151**); tip-comment honesty/fingerprint Highs that still show zero hits for the SHA. Coverage `ticket` lists can over-claim — before skipping tip-comments, `jira.py get` must contain the tip SHA on **each** claimed High *and* each catalog parent (tip `7d946ea7`: prior coverage listed LPT-242/312/315/352/… while only LPT-624/626/628 + some IP Highs actually had the comment; tip `c03044af`: coverage again listed LPT-312/315/349/352/… while only LPT-242 + catalog parents had the SHA — re-commented 20 Highs the same tick; tip `56f22fa8`: coverage listed LPT-624/626/628 while LPT-625/627/635 + frontier LPT-242/312/315 lacked the SHA — tip-commented those same tick; tip `e785c399`: coverage listed LPT-625/627/635/242/312/315/628/659 while `jira.py get` showed **zero** tickets with that SHA — tip advanced mid-run to `8e5ae40a`/#2054 before re-comment; tip `2172c3f4`/#2061: coverage listed LPT-628/659/660/661/624… while `jira.py get` again showed **zero** tickets with that SHA — tip-commented parents+Highs+Done-ack densify siblings the same tick; tip `1c037025`/#2062: coverage again listed parents+Highs while `jira.py get` showed **zero** tickets with that SHA — tip-commented 26 tickets the same tick before tip advanced to `b03f35e8`/#2063; tip `fa1490fd`/#2065: coverage listed densify parents+frontier+Done-ack LPT-662..665 (those had the SHA) while S6/honesty/fingerprint Highs LPT-252/255/258/271/275/295/301/348/408/409/411/414/417 lacked it — tip-commented those same tick).
- Prefer when tip advances with scanner-only `NO_HINT_ACTIVITY_IDS` / pressHints exclude (#1916): rebuild **LPT-626** from `scan_content_gaps --gap pressHints --markdown` so the checklist count equals `--counts` (**151**) — drop manual 156−5 subtract wording; tip-comment other catalog parents on the new SHA without inventing count deltas.
- Prefer on a tip-stable catalog-synced SHA (including learnings-only tips like #1931/#1932/#1934/#1935 after LPT-292 / #1974 after LPT-318 / #1977 after LPT-321/324 / #2026 after Capstone re-check, scanner-only tips like #1949 nice-ladder `--counts` / #1964/#1965 densifyHelperArms, densify-helper tips like #1979 LPT-645/646 / #2017 LPT-650 / #2019 LPT-651 / #2024 LPT-652, and non-content ops tips like #1933 SDK queue-empty skip / #1948 soft-stop / #1966 / #1978 sync_primary / #1989 ui-agent status idle-skip / #1999 soft-stop-wait / #2027 ui-agent status log-preview skip / #2040 soft-stop-hold): tip-comment parents without inventing count deltas when the tip is *new* **and JSON gaps are flat**; when densifyHelperArms moves, rebuild **LPT-628** the same tick. If a catalog body shows a broken `{{{{{sha}}}}}` / empty SHA audited placeholder, rebuild that parent from `--gap … --markdown` the same tick even when counts are flat. Skip re-editing/re-spamming parents when coverage already has a catalog sync for *that* SHA and counts still match; tip-comment **unchecked** High teachSpecs *or* needs-human companions (LPT-348 capstone `noHintIds`) / fingerprint+honesty Highs not in that coverage ticket list — S5 Soft timing LPT-242 / S6 LPT-258·295·301, then S7+ LPT-312 Map turn / LPT-315 Compose river / LPT-334·LPT-349..352 (frontier after LPT-337/#1993 + LPT-339/#2005 + LPT-341/#2014 + LPT-345/#2022 **Done**; warm-up **LPT-349**/#2044 **Done** + Final **LPT-352**/#2048 **Done**; next Highs LPT-312/315 / Soft timing LPT-242; Capstone 4-bet LPT-347/#2033 **Done**) / LPT-252·255·271·275 (LPT-308/#1951 + LPT-318/#1972 + LPT-321/#1973 + LPT-324/#1975 + LPT-328/#1981 + LPT-331/#1987 + LPT-337/#1993 + LPT-339/#2005 + LPT-341/#2014 + LPT-345/#2022 **Done**) — rather than re-spamming honesty already commented on that SHA; still append coverage. When re-checking Soft timing densify ABSENT, read arms only from `lib/ui/course/widgets/rex_coach_line.dart` `selectIdentifyDensifiedCoachLine` (or `--counts` `densifyHelperArms`) — inline `'act-05-07-01-*' =>` strings in `select_identify_activity.dart` framed/`_coachFallback` maps are not densify helper arms. Re-read Dart atmosphere before repeating “honesty still valid” — LPT-394 tip now `Jh`/`9d`·`Ks`/`Tc`/`2d`/`3s` (**Done**); if a teachSpec body still says “current 9h/8h”, edit that body the same run (LPT-312). After mid-run honesty lands (e.g. #1985 LPT-396; #1997 LPT-405; #2069 LPT-408 nut-FD): re-read `lesson_action_table.dart` ActionSpot before any “still valid” tip-comment; Done-ack + correct stale comments the same tick when tip already matches (`Jh`/`Td`·`Kh`/`Ts`/`8h`/`2d` second pair under K — not `Ts`/`9h`/`8c`/`2d` top pair; LPT-405 Q83r on rainbow `Qs`/`8h`/`3d` — not Q83tt); edit sibling teachSpec bodies that still cite old codes (LPT-331; LPT-339 Q83tt→Q83r). Coverage `learnings: updated` is not folded until the chore PR is on tip — if run-memory lacks the SHA fold, ship it this tick.

- Prefer after a High interactive teachSpec Done: append SoftPulse explain Nice! onto **LPT-624** when explain now has cues but no `explainGrading`; tip-comment **LPT-626** if scaffolded/unguided already listed; do **not** shrink LPT-635 S1–S2 when scanner full explain-teachSpec drops. If the land authors `deal.mode` `fixed` without `deal.variants` (e.g. LPT-280 #1920, LPT-283 #1923, LPT-292 #1930 `act-06-11-03-guided/scaffolded/unguided`, LPT-304 #1944 `act-06-13-01-guided/scaffolded/unguided`, LPT-328 #1981 `act-07-07-01-guided/scaffolded/unguided`, LPT-331 #1987 `act-07-08-01-guided/scaffolded/unguided`, LPT-337 #1993 `act-07-10-01-hand`, LPT-339 #2005 `act-07-10-02-hand`, LPT-341 #2014 `act-07-10-03-hand`, LPT-347 #2033 `act-07-10-05-hand`, LPT-345 #2022 `act-07-10-04-hand`): rebuild **LPT-627** from `--gap deal-variants --markdown` (count may *rise* — 75→78 Adjust TAG; 78→81 Mix five / Same cards; 81→84 same-cards types; 84→87 type×board; 87→88 Capstone SRP hand; 88→89 Capstone 3-bet hand; 89→90 Capstone multiway hand; 90→91 Capstone limped hand; 91→92 Capstone 4-bet hand). If outcome-tile `deal.mode` `none` (e.g. LPT-286 #1925 `act-06-11-01-*`, LPT-289 #1927 `act-06-11-02-*`, LPT-298 #1939 `act-06-12-02-*`, LPT-307 #1945 `act-06-13-02-cp-*`, LPT-308 #1951 `act-07-01-01-*`, LPT-318 #1972 `act-07-04-01-*`, LPT-321 #1973 `act-07-05-01-*`, LPT-324 #1975 `act-07-06-01-*`): deal-variants stays flat — tip-comment **LPT-627** only, still rebuild **LPT-624** Nice! when an explain landed (38→39→40 for TIGHT→BARREL→SAMPLE then TIGHT→AGGRO→MODEL; 40→41 CREDIT→TIGHTER→NO LIGHT; 41→42 WIDE→PRESSURE→MODEL Meet LAG; 42→43 CARDS→SEATS→EVIDENCE Mix five; 43→44 REASON→CONFIRM→CANCEL preflop-to-flop; 44→45 LIMPED→SRP→3-4BET pot type; 45→47 FEWER→THICKER→WIDEN HU/multiway + SHORT→DEEP→EFFECTIVE stack-depth; 47→48 CARDS→MODELS→CITE same-cards types; 48→49 type×board explain after LPT-331; 49→50 Capstone SRP explain after LPT-337; 50→51 Capstone 3-bet explain after LPT-339; 51→52 Capstone multiway explain after LPT-341; 52→53 Capstone limped explain after LPT-345; 53→54 Capstone 4-bet explain after LPT-347; 54→55 warm-up explain after LPT-349). Checkpoint-only lands (LPT-307) add no Nice! row. Depth chrome honesty (LPT-417) can survive teachSpec — re-check, do not Done. Still-a-list cells marked STALE in the High may survive the land — tip-comment the Done ticket; do not file a rebuild. When tip lands an In Progress teachSpec High mid-run (LPT-324 #1975; LPT-345 #2022), Done + comment the same tick if catalog already matches — do not wait for Validated-on-origin/main.

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
- 2026-10-13q: Tip `6cea459c` after #1939 LPT-298 Meet LAG teachSpec: Nice! 41→42 (`act-06-12-02-explain`); deal-variants flat 78; teachSpec 97→93 / explain-teachSpec 37→36; Done LPT-298 on tip.
- 2026-10-13r: Tip `e4ed9c09` after #1944 LPT-304 Mix five / Same cards + #1945 LPT-307 S6 checkpoint: Nice! 42→43 (`act-06-13-01-explain`); deal-variants **78→81**; teachSpec 93→84 / explain-teachSpec 36→35; LPT-635 keeps 12 S1–S2; Soft timing densify still ABSENT (helper 47).
- 2026-10-13s: Tip `5697b07d` (#1949 scanner `nice-ladder` in `--counts` + prior #1947/#1948): scan flat 151/81/84/35/nice-43; tip-commented parents + Highs LPT-242/295/301/258/308/312/315/318; SoftPulse-map 68; densify helper 47 Soft timing ABSENT.
- 2026-10-13s: Tip-stable `bba9ad9f` (catalog already synced): scan flat 151/81/84/35 Nice! 43; skipped parent re-spam; tip-commented unchecked S7 Highs LPT-308 (IP, all five `act-07-01-01-*` MISSING) + LPT-312 (To Do, `act-07-02-01-*` MISSING); SoftPulse-map 68 / densify helper 47 Soft timing ABSENT.
- 2026-10-13t: Tip `c5851fdd` after #1951 LPT-308 preflop-to-flop teachSpec: Nice! 43→44 (`act-07-01-01-explain`); deal-variants flat 81; teachSpec 84→80 / explain-teachSpec 35→34; Done LPT-308; scaffolded/unguided stay on LPT-626 pressHints.
- 2026-10-13u: Tip-stable `89d9a5ae` (#1952 learnings): scan flat 151/81/80/34/nice-44; parents already synced — no rebuild. SoftPulse-map sibling Done ≠ `_guidedPulseTargetId` PRESENT (LPT-621/622/623 while Adjust unguided still ABSENT on LPT-625); Soft timing densify still ABSENT (helper 47).
- 2026-10-13v: Tip-stable `89d9a5ae` honesty re-read: LPT-394 **Done** (`Jh`/`9d`·`Ks`/`Tc`/`2d`/`3s`); edited LPT-312 body off stale “current 9h/8h”; LPT-396 still valid; tip-commented needs-human LPT-348 (keep off LPT-626).
- 2026-10-13w: Mid-run tip → `a8658386` (#1956 LPT-394 + #1957/#1959 SoftPulse-map scanner): rebuilt **LPT-625** ABSENT **20→24** from `--gap unguided-softpulse-map --markdown` (`softpulseMapArms` 68); tip-commented LPT-624/626/627/635/628/242; JSON gaps still flat 151/81/80/34/nice-44.

- 2026-10-13x: Tip-stable `51f39807` (#1960): scan flat 151/81/80/34/nice-44/map-24 softpulseMapArms 68; parents tip-comment only; Soft timing LPT-242 still all-five MISSING (GrokBot IP); densify helper 47 Soft timing ABSENT; LPT-396 still valid JhTd/Ts9h8c2d top-as-second; LPT-312 still MISSING.
- 2026-10-13y: Tip `5b0de9e2` (#1964/#1965 densifyHelperArms in `--counts` + #1966): scan flat 151/81/80/34/nice-44/map-24 softpulseMapArms 68 densifyHelperArms 47; parents already synced — no rebuild; tip-commented unchecked fingerprint/IP/capstone Highs + LPT-348; Soft timing densify ABSENT; LPT-396 still valid; prior coverage `learnings: updated` lacked git fold — shipped this chore.
- 2026-10-13z: Tip-stable `380f87d2` (#1969 learnings): scan flat 151/81/80/34/nice-44/map-24 softpulseMapArms 68 densifyHelperArms 47; parents already synced — no rebuild; tip-commented unchecked S6/S7 Highs LPT-258/295/301/315/318 + companion LPT-331; LPT-396 still valid JhTd/Ts9h8c2d top-as-second; Soft timing densify ABSENT.
- 2026-10-13aa: Tip `8bcf69a8` (#1970 learnings): scan flat 151/81/80/34/nice-44/map-24 softpulseMapArms 68 densifyHelperArms 47; parents tip-commented no rebuild; tip-commented Soft timing LPT-242 + Map turn LPT-312 + IP LPT-252/255/271/275 + honesty LPT-396 + fingerprint LPT-401/402/405/408/409/411/414/417; Soft timing densify ABSENT; pending empty.
- 2026-10-13ab: Tip `da985d39` after #1972 LPT-318 pot-type teachSpec: Nice! **44→45** (`act-07-04-01-explain` LIMPED→SRP→3-4BET); deal-variants flat **81**; teachSpec **80→76** / explain-teachSpec **34→33**; LPT-635 keeps 12 S1–S2; scaffolded/unguided stay on LPT-626; Soft timing densify ABSENT (helper 47); LPT-396 still valid JhTd/Ts9h8c2d top-as-second.
- 2026-10-13ac: Tip `39754d09` after #1973 LPT-321 Switch gears + #1975 LPT-324 stack-depth: Nice! **45→47** (`act-07-05-01-explain` FEWER→THICKER→WIDEN, `act-07-06-01-explain` SHORT→DEEP→EFFECTIVE); deal-variants flat **81**; teachSpec **76→68** / explain-teachSpec **33→31**; LPT-635 keeps 12 S1–S2; Done LPT-324 on tip (IP→Done); Soft timing densify ABSENT (helper 47); LPT-396 still valid; next teachSpec frontier LPT-328.
- 2026-10-13ad: `sync_primary` returns every leftover `cursor/chore-content-*` (not only `*-agent-learnings-*`) to `main` when clean — stops next run auditing a stuck Nice!/learnings chore tip; Never: ship learnings to git same tick.
- 2026-10-13ae: Tip `5f6741ab` after #1979 LPT-645/646 densify + #1978 sync: JSON gaps flat 151/81/68/31/nice-47/map-24; densifyHelperArms **47→53** / fallthrough **153→147**; rebuilt LPT-628; Soft timing densify still ABSENT; next teachSpec frontier LPT-328.
- 2026-10-13af: Tip-stable `cbecf233` (#1980 learnings): scan flat 151/81/68/31/nice-47/map-24 densifyHelperArms 53; parents tip-comment only (LPT-628 already rebuilt on 5f6741ab); Soft timing densify ABSENT; frontier LPT-328; LPT-396 still valid JhTd/Ts9h8c2d top-as-second.
- 2026-10-13ag: Tip `872a8183` after #1981 LPT-328 same-cards: Nice! **47→48** (`act-07-07-01-explain` CARDS→MODELS→CITE); deal-variants **81→84**; teachSpec 68→64 / explain-teachSpec 31→30; LPT-635 keeps 12 S1–S2; scaffolded/unguided stay on LPT-626; Soft timing densify ABSENT (helper 53); frontier LPT-312/315; LPT-396 still valid.
- 2026-10-13ah: Tip-stable `872a8183` re-check: scan still flat 151/84/64/30/nice-48/map-24 densifyHelperArms 53; parents already synced — no rebuild; tip-commented unchecked S6/S7/capstone/fingerprint Highs + LPT-348; Soft timing densify ABSENT; LPT-396 still valid JhTd/Ts9h8c2d top-as-second; frontier LPT-242/312/315.
- 2026-10-13ai: Tip `a55b968e` (#1983 learnings + #1985 LPT-396): scan flat 151/84/64/30/nice-48/map-24 densifyHelperArms 53; Done-ack LPT-396 (`Jh`/`Td`·`Kh`/`Ts`/`8h`/`2d`); edited LPT-331 guided codes; Soft timing densify ABSENT; frontier LPT-242/312/315.
- 2026-10-13aj: Tip `c20d28d9` after #1987 LPT-331 type×board (+ #1986 learnings / #1985 LPT-396): Nice! **48→49**; deal-variants **84→87**; teachSpec 64→60 / explain-teachSpec 30→29; LPT-635 keeps 12 S1–S2; Soft timing densify ABSENT (helper 53); frontier LPT-242/312/315; corrected stale flat-48/84 tip-comments once #1987 noticed on tip.
- 2026-10-13ak: Tip-stable `34010f3e` (#1989 ui-agent status after #1988): scan flat 151/87/60/29/nice-49/map-24 densifyHelperArms 53; rebuilt LPT-624/627 bodies to clear broken SHA placeholder; tip-commented parents + frontier/unchecked Highs; Soft timing densify ABSENT; frontier LPT-242/312/315.
- 2026-10-13al: Tip `4a5c557e` after #1993 LPT-337 Capstone SRP (+ #1992 learnings): Nice! **49→50** (`act-07-10-01-explain`); deal-variants **87→88** (`act-07-10-01-hand` fixed sans variants); teachSpec 60→59 / explain-teachSpec 29→28; corrected stale flat-49/87 tip-comments; Soft timing densify ABSENT; frontier LPT-242/312/315.
- 2026-10-13am: Tip-stable `4a5c557e` after LPT-337 catalog rebuild: tip-commented unchecked S6/S7/capstone/honesty/fingerprint Highs + LPT-348 + frontier LPT-242/312/315 with corrected 151/88/59/28/nice-50; Soft timing densify ABSENT; pending empty.
- 2026-10-13an: Tip-stable `3689fc40` (#1995 learnings after #1993 LPT-337): scan flat 151/88/59/28/nice-50/map-24 densifyHelperArms 53; parents tip-comment only (coverage already synced this SHA); tip-commented frontier + unchecked S6/S7/capstone/honesty Highs + LPT-348; Soft timing densify ABSENT; frontier LPT-242/312/315; next Capstone LPT-339; pending empty.
- 2026-10-13ao: Tip `5be698bd` (#1997 LPT-405 Q83r): scan flat 151/88/59/28/nice-50/map-24 densifyHelperArms 53; Done-ack LPT-405; edited LPT-339 off stale Q83tt; parents tip-comment only; Soft timing densify ABSENT; frontier LPT-242/312/315 / Capstone teachSpec LPT-339; pending empty.
- 2026-10-13ap: Tip `cbb7fb14` (#1999 soft-stop after #1997 LPT-405): scan flat 151/88/59/28/nice-50/map-24 densifyHelperArms 53; parents tip-comment only; Capstone LPT-339 still both MISSING (Q83r Done); Soft timing densify ABSENT; honesty LPT-401/414/417 still valid; frontier LPT-242/312/315 / Capstone LPT-339; pending empty.
- 2026-10-13aq: Tip `d8070119` after #2005 LPT-339 Capstone 3-bet (+ #2002 LPT-647 densifyHelperArms **53→57**): Nice! **50→51** (`act-07-10-02-explain`); deal-variants **88→89** (`act-07-10-02-hand` fixed sans variants); teachSpec 59→58 / explain-teachSpec 28→27; rebuilt LPT-624/627 (also cleared empty SHA placeholders); Done-ack LPT-339; Soft timing densify ABSENT; frontier LPT-242/312/315; next Capstone LPT-341+; pending empty.
- 2026-10-13ar: Never unquoted heredocs for Jira tip bodies (shell backtick wipe → empty SHA placeholders); corrected tip-comments on `0de0a739` after #2007.
- 2026-10-13as: Tip `a92e6cfe` (#2010 LPT-648 Meet TAG densify): densifyHelperArms **57→61** / fallthrough **143→139**; rebuilt LPT-628; Soft timing densify still ABSENT; next Capstone High LPT-341. Also Never nested f-string wiki monospace (`{{{sha}}}` slip).
- 2026-10-13at: Tip `8c473b7a` after #2014 LPT-341 Capstone multiway (+ #2012 LPT-649 densifyHelperArms **61→65**): Nice! **51→52** (`act-07-10-03-explain`); deal-variants **89→90** (`act-07-10-03-hand` fixed sans variants); teachSpec 58→57 / explain-teachSpec 27→26; LPT-624/627/628 already rebuilt on tip; Meet Nit still LPT-624/626; Soft timing densify ABSENT; next Capstone LPT-345; pending empty.
- 2026-10-13au: Tip `657b8def` after #2017 LPT-650 Meet LAG densify: densifyHelperArms **65→69** / fallthrough **135→131**; rebuilt LPT-628; Soft timing densify still ABSENT; Capstone limped LPT-345 still both MISSING; JSON gaps flat 151/90/57/26/nice-52/map-24; leave LPT-650 Done to ui-agent Validated-on-origin/main.
- 2026-10-13av: Tip `4a199707` after #2019 LPT-651 Adjust LAG densify: densifyHelperArms **69→71** / fallthrough **131→129** (`act-06-12-03-unguided` / `checkpoint` only); rebuilt LPT-628; Soft timing densify still ABSENT; Capstone limped LPT-345 still both MISSING; JSON gaps flat 151/90/57/26/nice-52/map-24; leave LPT-651 Done to ui-agent Validated-on-origin/main; densify ≠ teachSpec (LPT-301 still open).
- 2026-10-13aw: Tip `99f9889b` after #2022 LPT-345 Capstone limped (mid-run from tip-stable `cff31614`): Nice! **52→53** (`act-07-10-04-explain` NUTS→VALUE→THIN); deal-variants **90→91** (`act-07-10-04-hand` fixed sans variants); teachSpec 57→56 / explain-teachSpec 26→25; rebuilt LPT-624/627; Done LPT-345 on tip; Soft timing densify ABSENT (helper 71); next Capstone LPT-347; densify ≠ teachSpec LPT-301.
- 2026-10-13ax: Tip `f6d22a26` after #2024 LPT-652 Adjust TAG densify (+ #2023 learnings): densifyHelperArms **71→72** / fallthrough **129→128** (`act-06-11-03-checkpoint`); Soft timing densify still ABSENT; JSON flat 151/91/56/25/nice-53/map-24; leave LPT-652 Done to ui-agent Validated-on-origin/main; next Capstone LPT-347.
- 2026-10-13ay: Tip-stable `2f755e89` (#2025 learnings after #2024 LPT-652): scan still flat 151/91/56/25/nice-53/map-24 densifyHelperArms 72; parents tip-comment only (no rebuild); tip-commented Capstone LPT-347 + frontier LPT-242/312/315 + unchecked High teachSpecs LPT-301/258/295/252/255/271/275/334/349/352 + needs-human LPT-348 + honesty/fingerprint LPT-417/401/402/408/409/411/414; Soft timing densify ABSENT; next Capstone LPT-347.
- 2026-10-13az: Tip-stable `cb3f2076` (#2026 learnings + #2027 ui-agent status log-preview skip): scan still flat 151/91/56/25/nice-53/map-24 densifyHelperArms 72; parents tip-comment only (coverage already synced this SHA — no rebuild); Capstone LPT-347 still both MISSING (`act-07-10-05-explain`/`hand`; Kh/Kd·Q83r/+2d/+Ad); Soft timing densify ABSENT; honesty LPT-417 still valid; next Capstone LPT-347.
- 2026-10-13ba: Tip-stable `1c0553ff` (#2028 learnings): JSON flat 151/91/56/25/nice-53/map-24 densifyHelperArms 72; LPT-628 **description** still helper **71** @ `4a199707` despite tip-comments claiming LPT-652 rebuild — rebuilt body to **72** / fallthrough **128** (`act-06-11-03-checkpoint`); Capstone LPT-347 still both MISSING; Soft timing densify ABSENT; next Capstone LPT-347.
- 2026-10-13bb: Tip-stable `75f67c67` (#2029 after LPT-628 body lag fold): JSON still flat 151/91/56/25/nice-53/map-24 densifyHelperArms 72 (LPT-628 description now matches); Capstone LPT-347 still both MISSING (`act-07-10-05-explain`/`hand`); Soft timing densify ABSENT; tip-commented unchecked Highs not in densify coverage list + honesty LPT-414/417; next Capstone LPT-347 after GrokBot.
- 2026-10-13bc: Tip `d8f1e0fa` after #2033 LPT-347 Capstone 4-bet (+ #2031 LPT-654 densifyHelperArms **72→73**): Nice! **53→54** (`act-07-10-05-explain`); deal-variants **91→92** (`act-07-10-05-hand` fixed sans variants); teachSpec 56→55 / explain-teachSpec 25→24; rebuilt LPT-624/627/628; Done-ack LPT-347; Meet Nit still LPT-624/626; Soft timing densify ABSENT; next warm-up LPT-349 / Final LPT-352; pending empty.
- 2026-10-13bd: Tip `0092c2ba` after #2036 LPT-655 Section 6 checkpoint densify: densifyHelperArms **73→78** / fallthrough **127→122** (`act-06-13-02-cp-adv` / `cp-cap` / `cp-polar` / `cp-tag` / `cp-lag`); rebuilt LPT-628; JSON gaps flat 151/92/55/24/nice-54/map-24; Soft timing densify still ABSENT; leave LPT-655 Done to ui-agent Validated-on-origin/main; next Soft timing LPT-242 / Map turn LPT-312 / Compose river LPT-315 / warm-up LPT-349 / Final LPT-352; pending empty.
- 2026-10-13be: Tip-stable `7d946ea7` (#2038 learnings after LPT-655 / LPT-628 rebuild): JSON still flat 151/92/55/24/nice-54/map-24 densifyHelperArms 78; Soft timing teachSpec all-five MISSING + densify ABSENT; honesty LPT-414 Gutshot-ish / LPT-417 180bb-250bb / LPT-401 Weak TPTK still valid; prior coverage over-claimed tip-comments — verified via `jira.py get` and tip-commented missing Highs/parents; pending empty.
- 2026-10-13bf: Tip `c03044af` (#2039) → mid-run `b9398420` (#2040 soft-stop-hold): JSON flat 151/92/55/24/nice-54/map-24 densifyHelperArms 78; parents tip-comment only on new tip; coverage on `c03044af` over-claimed High tip-comments again — `jira.py get` showed only LPT-242 + parents had the SHA; tip-commented 20 unchecked Highs (LPT-312/315/349/352/301/258/295/252/255/271/275/334/348 + honesty LPT-414/417/401/402/408/409/411); Soft timing densify ABSENT; frontier LPT-242/312/315/349/352; pending empty.
- 2026-10-13bg: Tip `ac29f3e1` after #2041 LPT-656 Carry preflop plan densify (+ #2040/#2042): densifyHelperArms **78→82** / fallthrough **122→118**; rebuilt LPT-628 (body lagged at **78**); Soft timing densify still ABSENT; JSON flat 151/92/55/24/nice-54/map-24; Meet Nit still LPT-624/626; leave LPT-656 Done to ui-agent Validated-on-origin/main; pending empty.
- 2026-10-13bh: Tip `85724074` after #2044 LPT-349 warm-up teachSpec (+ #2043 LPT-656 learnings): Nice! **54→55** (`act-07-11-01-explain`); deal-variants flat **92**; teachSpec 55→51 / explain-teachSpec 24→23; densifyHelperArms **82**; rebuilt LPT-624; Done-ack LPT-349; Meet Nit still LPT-624/626; Soft timing densify ABSENT; next Final LPT-352; pending empty.
- 2026-10-13bi: Tip `7abac821` after #2045 LPT-657 Map turn densify (+ #2044 LPT-349 Nice! **54→55**): densifyHelperArms **82→86** / fallthrough **118→114**; rebuilt LPT-628; Soft timing densify still ABSENT; JSON 151/92/51/23/nice-55/map-24; Meet Nit still LPT-624/626; next Final LPT-352; pending empty.
- 2026-10-13bj: Tip `2c24d461` after #2048 LPT-352 Final teachSpec (+ #2047 LPT-349 Nice!/LPT-657 densify learnings): teachSpec **51→44** / explain-teachSpec flat **23** / nice-ladder flat **55** (checkpoint-only final — no SoftPulse explain Nice! row); deal-variants flat **92**; densifyHelperArms **86**; Done-ack LPT-352; LPT-628 tip-comment only; Soft timing densify ABSENT; frontier Soft timing LPT-242 / Map turn LPT-312 / Compose river LPT-315; pending empty.
- 2026-10-13bk: Tip `9a7ca173` after #2051 LPT-401 Weak TPTK→Weak top pair: JSON flat 151/92/44/23/nice-55/map-24 densifyHelperArms 86; parents tip-comment only; Done-ack LPT-401; Soft timing densify still ABSENT; frontier LPT-242/312/315 still all-five MISSING; pending empty.
- 2026-10-13bl: Tip-stable `56f22fa8` (#2052 learnings after LPT-401): JSON still flat 151/92/44/23/nice-55/map-24 densifyHelperArms 86; prior coverage over-claimed — LPT-625/627/635 + frontier LPT-242/312/315 lacked tip SHA; tip-commented those + LPT-628/659 (ui-agent pot-type densify sibling, arms ABSENT); Relates LPT-659↔628; Soft timing densify ABSENT; pending empty.
- 2026-10-13bm: Tip `8e5ae40a` after #2054 LPT-658 Compose river densify (+ #2053 learnings): densifyHelperArms **86→89** / fallthrough **114→111** (`act-07-03-01-scaffolded` / `unguided` / `checkpoint`); rebuilt LPT-628; Soft timing densify still ABSENT; JSON flat 151/92/44/23/nice-55/map-24; prior `e785c399` coverage over-claimed tip-comments (zero tickets had that SHA) — tip-commented parents+Highs on new tip; leave LPT-658 to ui-agent Validated-on-origin/main; densify ≠ teachSpec LPT-315; LPT-659 pot-type arms still ABSENT; pending empty.
- 2026-10-13af: scanner `--gap densify-tap --markdown` lists SI / `player_read_classify` missing helper arms (LPT-628); `--counts` emits densify-tap ABSENT + densifyHelperArms PRESENT.
- 2026-10-13bn: Tip `c88437f9` (#2056 densify-tap markdown + #2057 LPT-402 + #2058): first LPT-628 rebuild from `--gap densify-tap --markdown` → densify-tap **140** (broader than prior hand fallthrough **111** — includes early-catalog SI); densifyHelperArms still **89**; Done-ack LPT-402 (`9s8s`·`Ks7s2h3hAh`); Soft timing densify still ABSENT; frontier LPT-242/312/315 still MISSING; pending empty.
- 2026-10-13bo: Tip `9f5dd58d` (#2060 LPT-659/660/661 densify): densifyHelperArms **89→101** / densify-tap **140→128**; rebuilt LPT-628 from `--gap densify-tap --markdown`; Soft timing densify still ABSENT; leave LPT-659/660/661 In Progress for ui-agent Validated-on-origin/main; frontier LPT-242/312/315 still MISSING; pending empty.
- 2026-10-13bp: Tip-stable `2172c3f4` (#2061 learnings after #2060): JSON still flat 151/92/44/23/nice-55/map-24 densifyHelperArms 101 densify-tap 128; LPT-628 body matches; prior coverage over-claimed tip-comments (`jira.py get` zero SHA hits) — tip-commented parents+Highs; Done-ack LPT-659/660/661 (**Done**, arms PRESENT); Soft timing densify ABSENT; frontier LPT-242/312/315 still MISSING; honesty LPT-414/417 still valid; pending empty.
- 2026-10-13bq: Tip-stable `1c037025` (#2062 learnings): JSON still flat 151/92/44/23/nice-55/map-24 densifyHelperArms 101 densify-tap 128; LPT-628 body matches; prior coverage over-claimed tip-comments again (`jira.py get` zero SHA) — tip-commented 26 parents+Highs+Done-ack; Soft timing densify ABSENT; frontier LPT-242/312/315 still MISSING; pending empty.
- 2026-10-13br: Tip `b03f35e8` (#2063 LPT-662/663/664/665 densify): densifyHelperArms **101→111** / densify-tap **128→118**; rebuilt LPT-628 from `--gap densify-tap --markdown`; Soft timing densify still ABSENT; leave LPT-662..665 In Progress for ui-agent Validated-on-origin/main; densify ≠ teachSpec LPT-334/242/312/315; JSON otherwise flat 151/92/44/23/nice-55/map-24; pending empty.

- 2026-10-13bs: Tip-stable `7f22b9e7` (#2064): JSON flat 151/92/44/23/nice-55/map-24 densify-tap 118 densifyHelperArms 111; Done-ack LPT-662..665 (**Done**) + rebuilt LPT-628 body; Soft timing densify still ABSENT; frontier LPT-242/312/315/334 still MISSING; pending empty.
- 2026-10-13bt: Tip-stable `fa1490fd` (#2065): JSON flat 151/92/44/23/nice-55/map-24 densify-tap 118 densifyHelperArms 111; LPT-628 body matches — tip-comment only; prior coverage omitted S6/honesty Highs — tip-commented LPT-252/255/258/271/275/295/301/348/408/409/411/414/417 + LPT-628 Soft timing Priority; Soft timing densify ABSENT; frontier LPT-242/312/315/334 still MISSING; pending empty.
- 2026-10-13bu: Tip `0b226db6` (#2069 LPT-408): Done-ack nut-FD remap; JSON flat; corrected empty-SHA tip-comments from unquoted heredoc (Never); Soft timing densify ABSENT; frontier LPT-242/312/315/334 still MISSING; LPT-409/411/414/417 still open; pending empty.

- 2026-10-13bv: Tip-stable `ea9654be` (#2071): JSON still flat 151/92/44/23/nice-55/map-24 densify-tap 118 densifyHelperArms 111; LPT-628 body matches — tip-comment only; Soft timing densify ABSENT; frontier LPT-242/312/315/334 still MISSING; honesty LPT-414/417 still valid; pending empty.
