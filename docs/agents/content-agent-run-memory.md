# Content agent run memory

Append-only operational notes from `/lesson-content-agent` loops. The capped
rules live in `.cursor/commands/lesson-content-agent-learnings.md`; this file
keeps the full lesson/catalog pattern notes so later runs can search them.

Folded from `~/.live-poker-trainer/content-agent-learnings-pending.md` on
2026-10-12.

When auditing a lesson, grep this file for its `act-` / `lesson-` id before
filing deal.mode / Still-a-list / handFamily gaps.

- Audit scripts must match catalog renderer ids as snake_case (`select_identify`, not `selectIdentify`); camelCase filters silently report zero teachSpec gaps.
- Seat/puck lessons (Button and blinds) author `deal.mode` `none` + SoftPulse puck `cues` (`D`/`SB`/`BB`); do not file handFamily/suitFamily gaps for non-card-class steps. Same-concept quiet guided ids still need authored Hint (`pressHints` or existing coachMedia) because SoftPulse waits for Hint. After LPT-87 split: first-child `act-01-01-03-explain-button` stays Dart-wired; successors `act-01-01-03-02-explain-blinds` / `03-explain-when` (and 14 other S1 `lessonSplitMap` SoftPulse explains) need Dart `isTableRegionTapActivity` + `resolveCoachDialogueVisual` → catalog **LPT-669** (tip `14d32fb9`). After LPT-114 Position split (tip `77669c63`): reused `act-02-01-01-explain-pos` stays wired; new `act-02-01-01-01-explain-seats` / `02-explain-blinds` (+14 other S2/S3 successors) append to **LPT-669** (**32** rows) — do not open a sibling catalog. Hand-families post-split (`lesson-02-02-01-01/02/03`, tip `e9a8f54e`): first-child `act-02-02-01-explain-families` SoftPulse Pairs→Broadways→Suited aces→Connectors **wired**; successors `act-02-02-01-02-explain-broadway` / `03-explain-connectors` cues+`explainGrading` but Dart table-tap/visual missing → **LPT-669**; interactive SI `random_in_class` + SoftPulse `hf-*` + densify PRESENT; scaffolded/unguided one-per-press OK; checkpoint hintless; curriculum **LPT-121** Done (do not clone).
- Acting-order post-split (`lesson-02-01-02-01/02/03`, tip `e9a8f54e`/`b8d4de07`): first-child `act-02-01-02-explain-order` SoftPulse UTG→HJ→CO→BTN **concept-aligned** under Preflop order; successors `act-02-01-02-02-explain-post` SB→BTN + `act-02-01-02-03-explain-wait` EARLIER SEATS→YOUR TURN content-driven SoftPulse walks (LPT-669 Done — do not reopen). Interactive seat/wait tiles `deal.mode` `none` — do not file handFamily; guided-pre SoftPulse CO→BTN→SB; scaffolded-post one-per-press OK; unguided-wait one-per-press + densify PRESENT; checkpoint-full assessmentRole checkpoint hintless cue kind `none` densify PRESENT under Postflop (who acts last = BTN matches objective). Curriculum split **LPT-117** Done (#2222) — do not clone teachSpec/pressHints (LPT-115/116/667 Done). Tip `b8d4de07` NEVER re-walk: no SoftPulse residual and no LPT-739-style activity↔objective mismatch.
- Position-labels post-split (`lesson-02-01-01-01/02/03`, tip `121c5995`): SoftPulse EP→HJ→CO→BTN / SB→BB **concept-aligned**; postflop last-actor guided SoftPulse `pos-btn` (`act-02-01-01-guided-btn`) still under Seat labels → residual **LPT-739** (needs-human; Relates LPT-114); Later seats SoftPulse `D` + checkpoint `prefer-btn` OK; curriculum **LPT-114** Done — do not clone / do not re-add needs-human.
- Open-fold post-split (`lesson-02-03-01-01/02/03`, tip `0431044f`): first-child `act-02-03-01-explain-open` SoftPulse EARLY→BUTTON→LIVE 3x + `explainGrading` under Fold-early-only → residual **LPT-741** (needs-human; Relates LPT-124); successors `act-02-03-01-02-explain-strong` STRONG→LIVE SIZE + `act-02-03-01-03-explain-button` BUTTON→WIDER content-driven SoftPulse walks (LPT-669 Done — do not reopen). Guided-utg SoftPulse `fold` PRESENT (`random_in_class` trash/offsuit); scaffolded-qq SoftPulse `open-qq` one-per-press OK; unguided-btn SoftPulse `open-k9s` one-per-press OK; checkpoint-hj SoftPulse `open-ato` kind `none` hintless; densify N/A (`poker_action_sizing`); curriculum **LPT-124** Done — do not clone / do not re-add needs-human.
- Versus-open post-split (`lesson-02-04-01-01/02/03`, tip `d0901a24`/`7e8336c1`): first-child `act-02-04-01-explain-vs` SoftPulse FOLD→CALL→3-BET + `explainGrading` under Fold-weak-only → residual **LPT-743** (needs-human; Relates LPT-127); successors `act-02-04-01-02-explain-call` PLAYABLE→IN POSITION→CALL + `act-02-04-01-03-explain-threebet` STRONG→3-BET content-driven SoftPulse walks (LPT-669 Done — do not reopen). Guided-fold SoftPulse `fold-j3` PRESENT (`random_in_class` trash/offsuit); scaffolded-call SoftPulse `call-87s` one-per-press OK; unguided-3bet SoftPulse `3bet-kk` one-per-press OK; checkpoint-aq SoftPulse `3bet-aqs` kind `none` hintless; densify N/A (`poker_action_sizing`); primary-family `random_in_class` without distractor variants — do not reopen LPT-380/LPT-627; curriculum **LPT-127** Done — do not clone / do not re-add needs-human.
- Hand-ranks / `compare_rank` showdown steps (`act-01-02-01-*`, post-split `lesson-01-02-01-01/02/03`) deal multi-seat hand-class triples with physical seat shuffle (`dealShowdownOrderCards`); author teachSpec via class variants / role map — never treat static catalog You/Sam/Jo a11y or Dart `showdownOrderHintSpeech` as a passing authored `pressHints` under the recommended bar. Tip `01eacc7c` discovery: first-child `act-01-02-01-explain-ladder` SoftPulse showdown **wired**; successors `act-01-02-01-02-explain-spot` / `03-explain-compare` cues+`explainGrading` but Dart table-tap/visual missing → catalog **LPT-669**; guided/scaffolded/unguided/checkpoint author `random_in_class` + handFamily + variants matching Dart classes; scaffolded/unguided one-per-press OK (**LPT-667** Done); checkpoint cue kind `none` / no pressHints — curriculum split **LPT-90** Done (do not clone).
- Kickers / best-five post-split (`lesson-01-02-02-01/02/03`, tip `bd4a6f0b`): first-child `act-01-02-02-explain-five` SoftPulse five-press **wired** (table-tap+visual); successors `act-01-02-02-02-explain-kicker` SAME PAIR→KICKER + `act-01-02-02-03-explain-board` BOARD→CHOP author cues+`explainGrading` but zero Dart occurrences in `isTableRegionTapActivity`/`resolveCoachDialogueVisual` → catalog **LPT-669**; guided-seven SoftPulse five-press + pulse-map/densify PRESENT; checkpoint-build one-per-press 1–5; scaffolded-kicker/unguided-board one-per-press + densify PRESENT; curriculum split **LPT-93** Done (do not clone).
- Fold/check/call post-split (`lesson-01-03-01-01/02/03`, tip `bd4a6f0b`): first-child `act-01-03-01-explain-passive` SoftPulse FOLD→CHECK→CALL **wired** (table-tap+`passiveActions`); successors `act-01-03-01-02-explain-check` NO BET→CHECK + `act-01-03-01-03-explain-call` BET→CALL author cues+`explainGrading` but zero Dart occurrences in `isTableRegionTapActivity`/`resolveCoachDialogueVisual` → catalog **LPT-669**; guided-fold `random_in_class` trash/offsuit SoftPulse `fold-72` PRESENT; scaffolded-check weak_draw one-per-press SoftPulse `check-free` PRESENT; unguided-call strong_draw one-per-press SoftPulse `call-5` PRESENT; checkpoint-legal assessmentRole checkpoint hintless cue kind `none` (`check-illegal`); densify N/A (`poker_action_sizing`); curriculum split **LPT-96** Done (do not clone).
- Bet/raise/all-in post-split (`lesson-01-03-02-01/02/03`, tip `05892395`): first-child `act-01-03-02-explain-aggro` SoftPulse BET→RAISE→ALL-IN **wired** (table-tap+visual); successors `act-01-03-02-02-explain-raise` FACING BET→RAISE + `act-01-03-02-03-explain-allin` STACK→ALL-IN author cues+`explainGrading` but zero Dart occurrences in `isTableRegionTapActivity`/`resolveCoachDialogueVisual` → catalog **LPT-669**; guided-bet `random_in_class` top_pair SoftPulse `bet-half` PRESENT; scaffolded-raise one-per-press SoftPulse `raise-15` PRESENT; unguided-allin one-per-press SoftPulse `shove-12` PRESENT; checkpoint-names assessmentRole checkpoint hintless cue kind `none` (`named-bet`); densify N/A (`poker_action_sizing`); curriculum split **LPT-100** Done (do not clone teachSpec/pressHints/variants/map LPT-98/99/373/355/591).
- Streets/acting-order post-split (`lesson-01-04-01-01/02/03`, tip `2bcc97fe`/`ff0b8002`): first-child `act-01-04-01-explain-streets` SoftPulse PREFLOP→FLOP→TURN→RIVER **concept-aligned**; successors `act-01-04-01-02-explain-order` BIG BLIND→CLOCKWISE→BUTTON + `act-01-04-01-03-explain-end` BETS MATCHED→NEXT STREET content-driven (LPT-669 Done — do not reopen); guided-streets SoftPulse four presses; scaffolded-order one-per-press 1–4; unguided-end one-per-press densify PRESENT; checkpoint-postflop SoftPulse `sb-first` under Action order (preflop-only) → residual **LPT-737** (needs-human); curriculum split **LPT-103** Done (do not clone).
- Winning-pots post-split (`lesson-01-05-01-01/02/03`, tip `2905e103`): first-child `act-01-05-01-explain-win` SoftPulse FOLD WIN→SHOWDOWN→SIDE POT **wired**; successors `act-01-05-01-02-explain-showdown` RIVER CALL→SHOWDOWN→BEST FIVE + `act-01-05-01-03-explain-pots` MAIN POT→SIDE POT author cues+`explainGrading` but zero Dart occurrences → catalog **LPT-669**; guided-fold-win fixed+variants densify PRESENT; scaffolded-showdown one-per-press densify PRESENT; unguided-pot chip tiles `deal.mode` `none` one-per-press; checkpoint-side densify PRESENT hintless; curriculum **LPT-106** Done (do not clone).
- Prefer `content/course/v2/course.json` over `wave_*.mjs` when counting items/sequence; wave helpers can lag (e.g. streets `scaffolded-order` CO). File wave-sync in the teachSpec ticket; never treat wave-only as catalog truth.
- Pot-math / open-size steps (`act-01-05-01-unguided-pot`) author `deal.mode` `none` + `deal.variants` for open-to sizes (`kLessonOpenToAmounts`); do not file handFamily/suitFamily gaps for chip-total outcome tiles. Tip `528069f0` discovery `lesson-01-05-01-winning-pots`: structural clean — explain SoftPulse FOLD WIN→SHOWDOWN→SIDE POT + `explainGrading`; guided fold-win `fixed`+suit variants cue `no-show`; scaffolded showdown fixed+variants one-per-press; unguided-pot chip tiles one-per-press; checkpoint-side assessmentRole checkpoint hintless cue kind `none`; densify arms PRESENT for all four interactive acts. Multi-concept split stays on needs-human **LPT-106** (fold-win / showdown / main-vs-side); do not clone teachSpec/pressHints/densify (LPT-104/374/485/525 Done).
- Synthesis / complete-hand lessons (e.g. Play a full toy hand) with process objectives (follow hand, act, finish) are not multi-concept title splits — skip `needs-human` lesson-split when the unit already is the integration container; still file teachSpec/pressHints gaps. Tip `118e4148` discovery `lesson-01-06-01-guided-complete-hand`: structural clean — explain SoftPulse BLINDS→YOU ACT→ENDING + `explainGrading`; guided-steps `random_in_class` suited_ace/suited SoftPulse cues; scaffolded-multi one-per-press OK (cues 1–2 / pressHints 1–2); unguided-lab high_card/offsuit + pressHints press 1; checkpoint-finish assessmentRole checkpoint cue kind `none` hintless; densify N/A (authored_multi_step_hand / full_table_hand_lab, not SI); do not clone teachSpec/pressHints (LPT-108/109/358/375/586 Done).
- Section 1 jump-order + jump-ranks are both on the felt (LPT-107): ranks use `handRanksShowdownSpot` / You·Sam·Jo seats — do not re-file still-list for jump-ranks unless that wiring regresses. jump_test lessons skip pressHints and needs-human multi-objective splits (assessment container). Still file teachSpec deal/cues (LPT-110).
- Before keeping a content Still-a-list / curriculum ticket open, re-check catalog `sequenceItems` + Dart `handRanksShowdownSpot` / sibling Done UI tickets on the current SHA — LPT-111 was obsolete after LPT-107.
- Before closing a content ticket as Done (or writing "still open" in coverage), re-fetch/ff \`origin/main\` — GrokBot may land teachSpec mid-run (LPT-81/#1711). Re-audit the activity fields on the new tip; do not trust the SHA from the start of the walk alone.
- When a lesson objective names a family/concept (e.g. suited aces) but that family never appears as the *correct* answer on a teach/practice step (distractor-only), file it inside the needs-human split / curriculum-gap ticket — do not treat explain tiles alone as coverage.
- Stack BB / effective-stack / depth outcome tiles (`act-02-05-01-*` select_identify) author `deal.mode` `none` + SoftPulse choice-id `cues` (`bb-100` / `eff-60` / `depth-50`); do not file handFamily/suitFamily gaps for chip÷BB math steps (same class as pot-math chip-total tiles). Tip `de176d1b` discovery `lesson-02-05-01-effective-stack`: structural clean — explain SoftPulse CHIPS→BB→SHORTER→DEPTH + `explainGrading`; all interactive densify arms PRESENT; scaffolded/unguided one-per-press OK; checkpoint hintless cue kind `none`; multi-concept chips→BB / shorter=effective / depth-feel stayed on needs-human **LPT-130** until split. Tip `2e42d603` post-split (`lesson-02-05-01-01/02/03`): first-child `act-02-05-01-explain-bb` SoftPulse CHIPS→BB→SHORTER→DEPTH **wired** (`bbStackDepth`); successors `act-02-05-01-02-explain-eff` / `03-explain-depth` cues+`explainGrading` but Dart table-tap/visual missing → catalog **LPT-669** (already listed; checklist still **46**); guided-convert SoftPulse `bb-100` densify PRESENT; scaffolded-eff SoftPulse `eff-60` one-per-press densify PRESENT; unguided-depth SoftPulse `depth-50` one-per-press densify PRESENT; checkpoint-200 hintless cue kind `none` (`bb-200`) densify PRESENT; curriculum **LPT-130** Done — do not clone.
- Habit / etiquette outcome tiles (`act-02-06-01-*` select_identify + explain `tableHabits`) author `deal.mode` `none` + SoftPulse cues (`WATCH`/`SAY`/`COVER`/`WAIT` or choice ids `watch` / `say-raise` / `chip-on-cards` / `oot-bad`); do not file handFamily/suitFamily gaps for live-habit steps (same class as pot-math / stack-BB tiles). Tip `cd522c93` post-split (`lesson-02-06-01-01/02/03`): first-child `act-02-06-01-explain-habits` SoftPulse WATCH→SAY→COVER→WAIT **wired**; successors `act-02-06-01-02-explain-say` / `03-explain-protect` content-driven (LPT-669 Done — do not reopen). Tip `2efbb166`: first-child SoftPulse WATCH→SAY→COVER→WAIT under Follow-action-only → residual **LPT-749** (needs-human; Relates LPT-133); guided-follow SoftPulse `watch` densify PRESENT; scaffolded-verbal SoftPulse `say-raise` one-per-press densify PRESENT; unguided-protect SoftPulse `chip-on-cards` one-per-press densify PRESENT; checkpoint-oot hintless cue kind `none` (`oot-bad`) densify PRESENT; curriculum **LPT-133** Done — do not clone / do not re-add needs-human.
- Versus an open / `act-02-04-01-*` `poker_action_sizing`: explain SoftPulse FOLD/CALL/3-BET (`deal.mode` `none` + `explainGrading`); guided/scaffolded/unguided/checkpoint author `deal.mode` `random_in_class` (trash/offsuit, connector/suited, pair, broadway/suited) with SoftPulse cues `fold-j3` / `call-87s` / `3bet-kk` / checkpoint `3bet-aqs` kind `none` (maps PRESENT); scaffolded/unguided one-per-press OK; checkpoint hintless. Primary-family `random_in_class` without distractor `deal.variants` is the shipped pattern after LPT-380 bundled into fixed-only catalog **LPT-627** — do not reopen per-lesson variant clones when scanner deal-variants is **0**. Wave: `wave_one_foundations.mjs`. Lesson id is `lesson-02-04-01-facing-raise`. Tip `be5bc2c2`/`d4097dd7` discovery: structural clean; multi-concept fold/call-IP/value-3-bet stays on needs-human **LPT-127**.
- Full-ring baseline / `act-02-07-01-*` (`lesson-02-07-01-baseline-full-hand` → post-split `lesson-02-07-01-01/02/03`, unit `unit-02-07-baseline-checkpoint`): explain SoftPulse NINE→SAME→POSITION (`deal.mode` `none` + activity-level `explainGrading`); guided `poker_action_sizing` `random_in_class` broadway/suited SoftPulse `open-ajs`; scaffolded vs-open `random_in_class` pair SoftPulse `call-22` one-per-press OK; unguided `full_table_hand_lab` broadway/offsuit SoftPulse `lab-3bet` one-per-press OK; checkpoint habit outcome tiles `deal.mode` `none` cue `cover-wait` kind `none` densify PRESENT — do not file handFamily on checkpoint; primary-family `random_in_class` without distractor variants matches Versus-open / LPT-627 fixed-only — do not reopen deal.variants clones. Tip `d0c4ff18` discovery: structural clean; multi-concept full-ring open / vs-raise plan / habit-while-deciding filed needs-human **LPT-668** (not a Capstone/jump assessment skip); do not clone teachSpec/pressHints/densify/explain (LPT-135/136/365/383/487/586 Done). Tip `c32322ec` Prefer NEVER post-split: first-child SoftPulse NINE→SAME→POSITION under full-ring-open **concept-aligned** (no SoftPulse residual); successors `act-02-07-01-02-explain-vsraise` OPEN→PLAN + `act-02-07-01-03-explain-habits` COVER→WAIT content-driven; curriculum **LPT-668** Done — do not clone / do not re-add needs-human. Wave: `wave_one_foundations.mjs`.
- Baseline jump `act-02-07-02-jump-stack` is already on the felt (`LessonTableLayout.effectiveStackOutcomes` / `tableRegionTap`); design-record Still-a-list "stack check" is stale — do not file a Still-a-list rebuild; clear the ledger cell inside the teachSpec ticket (LPT-137). Same re-check rule as LPT-111/jump-ranks. Tip `b89286fc` discovery `lesson-02-07-02-section-two-jump`: structural clean — all five acts `scaffolded`+`assessmentRole` `jump_test` (hintless; cue kind `none`); jump-pos/stack `deal.mode` `none` + SoftPulse choice cues; jump-family `random_in_class` suited_ace/suited (+ distractor variants); jump-open `random_in_class` trash/offsuit; jump-vs `fixed` Ah/Ad + suit variants; densify PRESENT for SI jump acts; jump_test assessment container — no curriculum-split / no pressHints; do not clone teachSpec/deal-variants/densify (LPT-137/377/488/221 Done).
- Table-read / pot-seat-verbal steps (`act-03-01-01-*` select_identify + explain `tableRead`) author `deal.mode` `none` + SoftPulse cues (`POT`/`STACKS`/`BUTTON`/`WHO ACTS` or choice ids `pot-21` / `utg-first` / `bound` / `eff-55`); do not file handFamily/suitFamily gaps (same class as pot-math / stack-BB / habit tiles). Wave source is `wave_two_live_competence.mjs` — keep in sync, prefer `course.json` as truth. Tip `cd522c93` post-split (`lesson-03-01-01-01/02/03`): first-child `act-03-01-01-explain` SoftPulse POT→STACKS→BUTTON→WHO ACTS **wired**; successors `act-03-01-01-02-explain-seat` / `03-explain-verbal` cues+`explainGrading` but Dart table-tap/visual missing → catalog **LPT-669** (already listed; checklist still **72**); guided SoftPulse `pot-21` densify PRESENT; scaffolded SoftPulse `utg-first` one-per-press densify PRESENT; unguided SoftPulse `bound` one-per-press densify PRESENT; checkpoint SoftPulse `eff-55` hintless cue kind `none` densify PRESENT; curriculum **LPT-140** Done — do not clone.
- Flop-class / `flopClass*Outcomes` steps (`act-03-02-01-*`) author `deal.mode` `fixed` (+ `deal.variants` for alternate spots) matching Dart hero/board codes; SoftPulse cues use MADE/DRAW/SDV/AIR (explain) and choice ids (`made-tp` / `nfd` / `air` / `oesd`); do not file as `deal.mode` `none` pot-math tiles. SDV distractor-only + checkpoint objective mismatches go in the needs-human split ticket. Tip `cd522c93` post-split (`lesson-03-02-01-01/02/03`): first-child `act-03-02-01-explain` SoftPulse MADE→DRAW→SDV→AIR **wired**; successors `act-03-02-01-02-explain-draws` / `03-explain-air` cues+`explainGrading` but Dart table-tap/visual missing → catalog **LPT-669** (already listed; checklist still **72**); guided SoftPulse `made-tp` densify PRESENT; scaffolded SoftPulse `nfd` one-per-press densify PRESENT; unguided SoftPulse `air` one-per-press densify PRESENT (Air Nice! five-high — **LPT-414** Done); checkpoint SoftPulse `oesd` hintless cue kind `none` densify PRESENT; curriculum **LPT-143** Done (do not clone teachSpec/pressHints/densify/Nice!/variants LPT-141/479/577/384).
- Outs / price steps (`act-03-03-01-*`): explain SoftPulse CLEAN/DIRTY/PRICE (`deal.mode` `none`); guided is already `outsCleanAcesTap` / `OutsCleanAcesPicker` (design-record Still-a-list “clean aces” is STALE — clear in teachSpec ticket); scaffolded call-price is chip tiles `deal.mode` `none` + cue `call-10` (no handFamily); unguided/checkpoint use `deal.mode` `fixed` with hero/board codes. Wave: `wave_two_live_competence.mjs`.
- Flop-line / `poker_action_sizing` steps (`act-03-04-01-*`): explain SoftPulse VALUE/C-BET/CHECK/CALL/FOLD/RAISE (`deal.mode` `none`); guided/scaffolded/unguided/checkpoint author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes; SoftPulse cues use choice ids `bet-tp` / `cbet` / `raise-set` / `fold-bp` (unguided may lack SoftPulse map today — still author deal). Wave: `wave_two_live_competence.mjs`. Lesson id is `lesson-03-04-01-flop-decisions` (not flop-lines).
- Turn-decision / `poker_action_sizing` steps (`act-03-05-01-*`): explain SoftPulse BRICK/CHANGE/BARREL/DELAY (`deal.mode` `none`); guided/scaffolded/unguided/checkpoint author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` / table-scene hero/board codes; SoftPulse cues use choice ids `brick` / `barrel` / `delay-bet` / `give-up`. Tip `6c7948fd` post-split (`lesson-03-05-01-01/02/03`): first-child `act-03-05-01-explain` SoftPulse BRICK→CHANGE→BARREL→DELAY under Brick-or-change → residual **LPT-754** (needs-human; Relates LPT-154); successors BRICK→BARREL / CHECKED BACK→BET TURN content-driven; guided SoftPulse `brick` densify PRESENT; scaffolded SoftPulse `barrel` one-per-press; unguided SoftPulse `delay-bet` one-per-press; checkpoint SoftPulse `give-up` kind `none` densify PRESENT; curriculum **LPT-154** Done — do not clone / do not re-add needs-human; distinct from **LPT-684**. Wave: `wave_two_live_competence.mjs`.
- River-decision / `poker_action_sizing` steps (`act-03-06-01-*`): explain SoftPulse VALUE/BLUFF/CATCH/FOLD (`deal.mode` `none`); guided/scaffolded/unguided author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes; SoftPulse cues use choice ids `val-bet` / `bluff` (unguided may lack SoftPulse map today — still author deal); checkpoint is role tiles (`role-catch`) with `deal.mode` `none` + SoftPulse cue (not hole+board fixed). Wave: `wave_two_live_competence.mjs`. Lesson id is `lesson-03-06-01-river-decisions`.
- Multiway / `act-03-07-01-*`: explain SoftPulse STRONGER/FEWER/NUTS (`deal.mode` `none`); guided/scaffolded `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes; SoftPulse cues use choice ids `check-2p` / `mw-check`; unguided speculative + checkpoint observe are outcome tiles (`deal.mode` `none` + cues `sc` / `obs-many`) — do not file handFamily/suitFamily gaps; checkpoint participation-observation vs nut-potential objective mismatch goes in the needs-human split ticket. Wave: `wave_two_live_competence.mjs`. Lesson id was `lesson-03-07-01-multiway-fundamentals`. Tip `4f56674b` post-split (`lesson-03-07-01-01/02/03`): first-child `act-03-07-01-explain` SoftPulse STRONGER→FEWER→NUTS **content-driven** (LPT-669 Done — authored `soft_pulse` cues); successors `act-03-07-01-02-explain-crowd` CROWD→FEWER BLUFFS + `act-03-07-01-03-explain-nuts` NUTS→POSITION content-driven SoftPulse walks — do **not** reopen LPT-669; guided SoftPulse `check-2p` PRESENT (`7h/9d`·`Kc7s2d` + variants); scaffolded SoftPulse `mw-check` one-per-press PRESENT (`7s3d`·`AhKh9h` + variants); unguided SoftPulse `sc` one-per-press densify PRESENT; checkpoint SoftPulse `obs-many` hintless cue kind `none` densify PRESENT; curriculum **LPT-160** Done — do not clone teachSpec/pressHints/variants (LPT-158/159/418/367/368/552).
- Leak-repair / `act-03-08-01-*`: explain SoftPulse TOP PAIR/PRICES/PASSIVE/CROWDS (`deal.mode` `none`); guided/scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes; SoftPulse cues use choice ids `careful` / `fold-gut` / `fold-air`; checkpoint is seat-frequency note tiles (`deal.mode` `none` + cue `notes`) — do not file handFamily/suitFamily gaps. Wave: `wave_two_live_competence.mjs`. Lesson id was `lesson-03-08-01-leak-repair`. Tip `39155796`/`a08d105d` post-split (`lesson-03-08-01-01/02/03`): first-child SoftPulse content-driven for LPT-669; successors BAD PRICE→FOLD / PASSIVE→CROWD content-driven — do **not** reopen LPT-669; interactive fixed+variants SoftPulse PRESENT one-per-press OK; curriculum **LPT-163** Done — do not clone. Tip `a09c96cf` SoftPulse residual: first-child `act-03-08-01-explain` TOP PAIR→PRICES→PASSIVE→CROWDS under Weak-top-pair → **LPT-757** (needs-human; Relates LPT-163); also checkpoint `notes` under Passive-and-crowds — do not re-add needs-human on LPT-163; distinct from Strategy-book **LPT-727**.
- After closing a teachSpec ticket Done, diff authored `handFamily` / `suitFamily` against `teach_spec.schema.json` enums — LPT-94 shipped `weak_draw` / `strong_draw` outside the schema while `validate_course.mjs` only checks presence (LPT-166). Do not treat “teachSpec present” as schema-complete.
- Section 3 jump `act-03-08-02-jump-table` is already on the felt (`LessonTableLayout.jumpTableTrackOutcomes` / `tableRegionTap`); design-record Still-a-list “table-read” is stale — do not file a Still-a-list rebuild; clear the ledger cell inside the teachSpec ticket (LPT-165). Same re-check rule as LPT-111 / LPT-137. Tip `8bad05d8` discovery `lesson-03-08-02-section-three-jump-test`: structural clean — all five `scaffolded`+`assessmentRole` `jump_test` (hintless; cue kind `none`); jump-table `deal.mode` `none` cue `j3-track` densify PRESENT; jump-class fixed `Jd/Td`·`Qd9d3c` + suit variants cue `j3-draw` densify PRESENT; jump-mw fixed air `7s/3d`·`AhKh9h` matches Dart (LPT-425/391) + air suit variants SoftPulse map `j3-fold` PRESENT; jump-river fixed `Ah/Kd` brick + variants SoftPulse map `j3-val` PRESENT; jump-leak true gutshot `Jh/9d`·`KsTc2d` matches Dart (LPT-389/381) + variants densify PRESENT cue `j3-foldprice`; jump_test assessment container — no curriculum-split / no pressHints; do not clone teachSpec/honesty/variants/densify (LPT-165/389/425/426/391/554/555 Done).
- Ranges / `act-04-01-01-*`: explain SoftPulse ONE HAND/RANGE/UPDATE (`deal.mode` `none`); guided/scaffolded are outcome tiles (`deal.mode` `none` + cues `strong-narrow` / `bb-stronger`); unguided/checkpoint author `deal.mode` `fixed` matching Dart hero/board codes + cues `too-exact` / `read-drives` — do not file handFamily/suitFamily gaps on guided/scaffolded. Wave: `wave_two_live_competence.mjs`. Lesson id was `lesson-04-01-01-ranges-not-hands`. Tip `8cb997f9` post-split (`lesson-04-01-01-01/02/03`): first-child `act-04-01-01-explain` SoftPulse ONE HAND→RANGE→UPDATE **content-driven** for LPT-669; successors `act-04-01-01-02-explain-move` RAISE→NARROWER→CALL + `act-04-01-01-03-explain-exact` ONE HAND→RANGE content-driven SoftPulse walks — do **not** reopen LPT-669; interactive SI densify structural clean; curriculum **LPT-169** Done — do not clone (LPT-167/168/573/432 Done). Tip `fad43b6a` SoftPulse residual: first-child SoftPulse ONE HAND→RANGE→UPDATE under Seat-as-range → **LPT-759** (needs-human; Relates LPT-169) — do not re-add needs-human on LPT-169; distinct from Range-nut **LPT-692**.
- 3-bet/squeeze / `act-04-02-01-*`: explain SoftPulse 3-BET/RANGES/SQUEEZE (`deal.mode` `none`); guided/scaffolded/unguided/checkpoint `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero codes; SoftPulse cues use choice ids `3bet-qq` / `fold-72` / `squeeze` / `size-18` (maps PRESENT — LPT-601 Done). Wave: `wave_two_live_competence.mjs`. Lesson id was `lesson-04-02-01-threebet-squeeze`. Tip `8cb997f9` post-split (`lesson-04-02-01-01/02/03`): first-child `act-04-02-01-explain` SoftPulse 3-BET→RANGES→SQUEEZE **wired** (`threeBetSqueeze`); successors `act-04-02-01-02-explain-facing` 3-BET→FOLD→CONTINUE + `act-04-02-01-03-explain-squeeze` OPEN→CALLERS→SQUEEZE content-driven SoftPulse walks (LPT-669 Done — do not reopen); guided SoftPulse `3bet-qq` PRESENT (`Qh/Qd` + suit variants); scaffolded SoftPulse `fold-72` one-per-press PRESENT (`7h/2d` + variants); unguided SoftPulse `squeeze` one-per-press PRESENT (`Ah/Kd` + variants); checkpoint SoftPulse `size-18` hintless cue kind `none` (`Kh/Kd` + variants); curriculum **LPT-172** Done — do not clone teachSpec/pressHints/variants/Nice!/map (LPT-170/171/434/572/601 Done). Tip `59fe21e0` SoftPulse residual: first-child SoftPulse 3-BET→RANGES→SQUEEZE under Value-3bet → **LPT-760** (needs-human; Relates LPT-172; + checkpoint `size-18` under Squeeze spots) — do not re-add needs-human on LPT-172; distinct from Versus **LPT-743** / Ranges **LPT-759**.
- Continuation / `act-04-03-01-*`: explain SoftPulse FLOP/TURN/RIVER (`deal.mode` `none` via MultiStreetPlanDemo); guided `authored_multi_step_hand` authors `deal.mode` `fixed` (+ `deal.variants`) matching Dart multi-step hero/board codes + SoftPulse `flop-bet` / `turn-bet`; scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ variants) matching `resolveLessonActionSpot` codes + cues `abort` / `small-pot` (maps PRESENT — LPT-602 Done); checkpoint outcome tiles (`deal.mode` `none` + cue `branches`) — do not file handFamily/suitFamily gaps on explain/checkpoint. Wave: `wave_two_live_competence.mjs`. Lesson id was `lesson-04-03-01-continuation-plans`. Tip `3b13dcb5` post-split (`lesson-04-03-01-01/02/03`, re-verify after #2265): first-child `act-04-03-01-explain` SoftPulse FLOP→TURN→RIVER **content-driven** (LPT-669 Done); successors `act-04-03-01-02-explain-abort` BOARD CHANGES→STOP + `act-04-03-01-03-explain-pot` MEDIUM→SMALL POT content-driven SoftPulse walks — do **not** reopen LPT-669; guided SoftPulse `flop-bet`/`turn-bet` PRESENT (`Ah/Kd`·`As7c2d3h` + variants); scaffolded SoftPulse `abort` one-per-press PRESENT (`Qd/9c`·`Kh7h2h3h` + variants); unguided SoftPulse `small-pot` one-per-press PRESENT (`Jh/Td`·`Qc9s3h` + variants); checkpoint SoftPulse `branches` hintless cue kind `none` densify PRESENT; curriculum **LPT-176** Done — do not clone teachSpec/pressHints/variants/Nice!/map (LPT-174/175/496/570/602 Done).
- Sizing / `act-04-04-01-*` (post **LPT-179** Done #2242): unit `unit-04-04-sizing` children `lesson-04-04-01-01/02/03`. Explain SoftPulse VALUE/PRESSURE/SIZE + successors NEARBY/STORY + TINY/VALUE (`deal.mode` `none`); guided/scaffolded/checkpoint `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot`; SoftPulse `half` / `big` / `bad-1` (checkpoint kind `none`); unguided soft-grade tiles (`deal.mode` `none` + cue `soft`) — do not file handFamily/suitFamily. SoftPulse explain successors content-driven (LPT-669 Done — do not reopen). **Residual:** `act-04-04-01-scaffolded` polar scare-river SoftPulse `big` still nests under Nearby `lesson-04-04-01-02-nearby-sizes` while Dart densify says polar pressure → **LPT-676** (needs-human); do not reopen Done **LPT-179**. Wave: `wave_two_live_competence.mjs` (retired id breadcrumb). Tip `63ae3ddc` NEVER walk: structural companions clear; filed LPT-676. Tip `a0032775` Prefer NEVER re-walk: SoftPulse VALUE→PRESSURE→SIZE packs value+polar under still-merged Value objective (expected — not a new SoftPulse residual); successors NEARBY→STORY / TINY→VALUE content-driven; guided SoftPulse `half` + scaffolded SoftPulse `big` one-per-press + unguided SoftPulse `soft` densify PRESENT + checkpoint SoftPulse `bad-1` kind `none`; residual **LPT-676** still valid; tip-commented LPT-676/179/760 + Meet Nit LPT-198/216; next Prefer NEVER SPR children.
- Catalog densify-tap reopen after curriculum split: tip mid-run `d9a56dff`→`416bd186` (#2212 LPT-83 Suits-and-ranks lesson split)→`417a2a02` (#2214 sizing learnings). `--counts` densify-tap **0→3** / densifyHelperArms still **229** — ABSENT `act-01-01-02-01-scaffolded-suits` / `act-01-01-02-01-checkpoint-suits` / `act-01-01-02-03-guided-suited`. Reopened catalog **LPT-628** To Do + rebuilt Affected from `--gap densify-tap --markdown` the same tick; other JSON gaps still **0**. Do not Done-ack LPT-628 from empty checklist while markdown rows remain.
- SPR / `act-04-05-01-*`: explain SoftPulse SPR/LOW/HIGH (`deal.mode` `none`); guided `select_identify` is `sprGuidedOutcomes` chip÷pot math (`deal.mode` `none` + cue `spr-4`) — do not file handFamily/suitFamily; scaffolded/unguided/checkpoint `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes; SoftPulse cues use choice ids `commit` / `flexible` / `before` (unguided SoftPulse map may be missing today — still author deal). Wave: `wave_two_live_competence.mjs`. Lesson id is `lesson-04-05-01-spr-commitment`. Checkpoint weigh-SPR habit vs numeric estimate objective mismatch goes in the needs-human split ticket.
- Sticky-caller observe / `act-04-06-01-*`: explain SoftPulse ENTERS/CALLS/FOLDS (`deal.mode` `none`); guided/scaffolded/unguided/checkpoint are observation outcome tiles (`deal.mode` `none` + cues `high-part` / `sticky` / `low-conf` / `bundle`) — do not file handFamily/suitFamily gaps; design-record Still-a-list “participation note, observation bundle” is STALE (`tableRegionTap` / `observe*Outcomes`) — clear in teachSpec ticket. Wave: `wave_two_live_competence.mjs`. Lesson id is `lesson-04-06-01-observe-sticky-caller` (singular). Multi-concept high-participation / sticky low-folding / observation≠certainty + checkpoint evidence-bundle vs certainty stay on curriculum **LPT-186** (human-approved split — `needs-human` removed; still To Do for id migration). Tip `a5fc541e` discovery: structural clean — explain SoftPulse ENTERS→CALLS→FOLDS + `explainGrading`; interactive `deal.mode` `none` SoftPulse cues; scaffolded/unguided one-per-press OK; densify PRESENT all four; SoftPulse region maps PRESENT (`observeParticipationOutcomes` / sticky / confidence / bundle); companions LPT-184/185/416/536/567 Done.
- Meet Calling Station / `act-04-06-02-*`: explain SoftPulse STATION/HIGH/LOW (`deal.mode` `none`); guided/unguided `player_read_classify` route through `SelectIdentifyActivity` + `tableRegionTap` (`playerTypeStationOutcomes` / `playerTypeStationManiacOutcomes`) with cues `pt-station` / `station2`; scaffolded `labelModelOutcomes` cue `model`; checkpoint `sampleConfidenceOutcomes` cue `low` — do not file handFamily/suitFamily; design-record Still-a-list “label quizzes” is STALE — clear in teachSpec ticket. Wave: `wave_two_live_competence.mjs`. Lesson id is `lesson-04-06-02-meet-calling-station`. Checkpoint sample-confidence vs identify-from-evidence + scaffolded model-vs-soul vs introduce-Station stay on curriculum **LPT-189** (human-approved split 2026-10-13 — `needs-human` removed; still To Do for id migration). Tip `d41550f0` discovery: structural clean — explain SoftPulse STATION→HIGH→LOW + `explainGrading`; interactive `deal.mode` `none` SoftPulse cues; scaffolded/unguided one-per-press OK; densify PRESENT; checkpoint hintless; companions LPT-187/188/420/537/542/566 Done.
- Adjust vs Calling Station / `act-04-06-03-*`: explain SoftPulse VALUE/BLUFFS/CITE (`deal.mode` `none`); guided/scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes; SoftPulse cues use choice ids `thin-val` / `give-up` / `baseline-check` (maps PRESENT — LPT-621 Done); checkpoint is cite tiles (`deal.mode` `none` + cue `cite-fold` via `stationBluffCiteOutcomes`) — do not file handFamily/suitFamily gaps; design-record Still-a-list “bluff-less reason” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_two_live_competence.mjs`. Lesson id is `lesson-04-06-03-adjust-calling-station`. Tip `9094f561` discovery: structural clean — explain SoftPulse VALUE→BLUFFS→CITE + `explainGrading`; guided `Jh`/`Td`·`QcTs3h2d7c` SoftPulse `thin-val`; scaffolded `8h`/`7h`·`Kh9h2c3d5s` SoftPulse `give-up` (LPT-399); unguided same second-pair SoftPulse `baseline-check`; one-per-press OK; checkpoint densify PRESENT hintless. Unguided unknown-baseline vs cite objective + multi-concept value/bluff/cite stay on curriculum **LPT-192** (human-approved split — `needs-human` removed; still To Do for id migration). Do not clone teachSpec/pressHints/densify/Nice! (LPT-190/191/421/565/399 Done).
- Observe narrow / `act-04-07-01-*`: explain SoftPulse RARE/ENTER/MEAN IT (`deal.mode` `none`); guided/scaffolded/unguided/checkpoint are observation outcome tiles (`deal.mode` `none` + cues `narrow` / `strong-aggr` / `wait` / `bundle-nit`) — do not file handFamily/suitFamily; design-record Still-a-list “entry quizzes” is STALE (`tableRegionTap` / `observeNarrow*Outcomes`) — clear in teachSpec ticket. Wave: `wave_two_live_competence.mjs`. Lesson id is `lesson-04-07-01-observe-narrow-player` (singular). Checkpoint evidence-bundle vs wait-for-samples objective mismatch goes in the needs-human split ticket. Post-split tip `49e27b42`: SoftPulse RARE→ENTER→MEAN IT under Tag-narrow-entry-only → **LPT-768** (needs-human; Relates LPT-195); checkpoint `bundle-nit` evidence-bundle residual note under strong-aggression (same ticket); successors content-driven. Tip `d41550f0` discovery: structural clean — explain SoftPulse + activity-level `explainGrading`; scaffolded/unguided one-per-press OK; densify + SoftPulse `guideRegion` PRESENT; multi-concept split stays on needs-human **LPT-195**; do not clone teachSpec/pressHints/densify/guideRegion/Nice! (LPT-193/194/422/433/538/564 Done).
- Meet Nit / `act-04-07-02-*` (post **LPT-198** Done split → `lesson-04-07-02-01-nit-model` / `02-spot-nit`): explain SoftPulse NIT/NARROW/RESPECT (`deal.mode` `none`); guided/unguided `player_read_classify` route through `SelectIdentifyActivity` + `tableRegionTap` (`meetNitVsStationOutcomes` / `meetNitVsManiacOutcomes`) with cues `pt-nit` / `nit2`; checkpoint `meetNitModelOutcomes` cue `model-n` — do not file handFamily/suitFamily; design-record Still-a-list “label quizzes” is STALE — clear in teachSpec ticket. Wave: `wave_two_live_competence.mjs`. Tip `1c64dc95` Prefer NEVER: SoftPulse NIT→NARROW→RESPECT under Introduce **concept-aligned**; checkpoint SoftPulse `model-n` working-model meta under Introduce → **LPT-769** (needs-human; Relates LPT-198; siblings TAG **LPT-708** / Station **LPT-767**); Spot SoftPulse FEW HANDS→BIG RAISES content-driven; guided SoftPulse `pt-nit` + unguided SoftPulse `nit2` one-per-press densify PRESENT; curriculum **LPT-198** Done — do not clone / do not re-add needs-human; distinct from Observe-narrow SoftPulse **LPT-768**. Tip `d41550f0` pre-split: structural clean — explain SoftPulse + activity-level `explainGrading` (“Nit → Narrow → Respect.”); unguided one-per-press OK; densify + SoftPulse `guideRegion` PRESENT on meetNit*Outcomes; Nice!/pressHints cleared on Done LPT-624/626 (do not reopen); do not clone teachSpec/pressHints/densify/guideRegion/Nice! (LPT-196/197/423/440/543/563 Done).
- Adjust vs Nit / `act-04-07-03-*`: explain SoftPulse STEAL/CREDIT/EXPLODE (`deal.mode` `none`); guided/scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes; SoftPulse cues use choice ids `steal` / `fold-mid` (unguided SoftPulse map may be missing today — still author deal); checkpoint is cite tiles (`deal.mode` `none` + cue `cite-strong` via `nitRespectCiteOutcomes`) — do not file handFamily/suitFamily gaps; design-record Still-a-list “respect reason” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_two_live_competence.mjs`. Lesson id is `lesson-04-07-03-adjust-nit`. Unguided unknown-baseline vs cite objective + multi-concept steal/respect/cite go in the needs-human split ticket.
- Observe wild / `act-04-08-01-*`: explain SoftPulse RAISE/BARREL/COUNT (`deal.mode` `none`); guided/scaffolded/unguided/checkpoint are observation outcome tiles (`deal.mode` `none` + cues `extreme` / `pressure` / `calm` / `bundle-m`) — do not file handFamily/suitFamily; design-record Still-a-list “entry quizzes” is STALE (`tableRegionTap` / `observeWild*Outcomes`) — clear in teachSpec ticket. Wave: `wave_two_live_competence.mjs`. Lesson id was `lesson-04-08-01-observe-wild-aggressor` (singular). Tip `1cf6bccf` discovery: structural clean — explain SoftPulse + activity-level `explainGrading`; scaffolded/unguided one-per-press OK; checkpoint hintless cue kind `none`; densify arms PRESENT for all four interactive acts; multi-concept split stayed on needs-human **LPT-205** until split. Tip `b2b96c67` post-split (`lesson-04-08-01-01/02/03`): first-child SoftPulse RAISE→BARREL→COUNT under Tag extreme entry → residual **LPT-773** (needs-human; Relates LPT-205); successors EVERY STREET→WEAK SHOWDOWNS / FREQUENCIES→NO EGO content-driven; guided SoftPulse `extreme` densify PRESENT; scaffolded SoftPulse `pressure` one-per-press densify PRESENT; unguided SoftPulse `calm` one-per-press densify PRESENT; checkpoint SoftPulse `bundle-m` kind `none` densify PRESENT (evidence-bundle residual note under Constant aggression); curriculum **LPT-205** Done — do not clone / do not re-add needs-human; do not clone teachSpec/pressHints/densify (LPT-203/204/428/544 Done).
- Meet Maniac / `act-04-08-02-*`: explain SoftPulse MANIAC/ENTRY/AGGRO (`deal.mode` `none`); guided/unguided `player_read_classify` route through `SelectIdentifyActivity` + `tableRegionTap` (`meetManiacVsNitOutcomes` / `meetManiacVsStationOutcomes`) with cues `pt-maniac` / `maniac2`; checkpoint `meetManiacMixOutcomes` cue `three` — do not file handFamily/suitFamily; design-record Still-a-list “label quizzes” is STALE — clear in teachSpec ticket. Wave: `wave_two_live_competence.mjs`. Lesson id is `lesson-04-08-02-meet-maniac`. Checkpoint mix-legal-types vs introduce-Maniac + multi-concept go in the needs-human split ticket.
- Adjust vs Maniac / `act-04-08-03-*`: explain SoftPulse WIDER/HANG/EGO (`deal.mode` `none`); guided/scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes; SoftPulse cues use choice ids `call-wider` / `val-m` (unguided SoftPulse map may be missing today — still author deal); checkpoint is cite tiles (`deal.mode` `none` + cue `cite-wide` via `maniacCallCiteOutcomes`) — do not file handFamily/suitFamily gaps; design-record Still-a-list “call-wider reason” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_two_live_competence.mjs`. Lesson id is `lesson-04-08-03-adjust-maniac`. Unguided unknown-baseline vs cite objective + multi-concept widen/value/ego/cite go in the needs-human split ticket.
- Confidence and samples / `act-04-09-01-*` (post **LPT-215** Done split → `lesson-04-09-01-01-observation-not-certainty` / `02-confidence-with-samples` / `03-retire-labels`): explain SoftPulse OBSERVE/SAMPLES/SHOWDOWNS (`deal.mode` `none`); guided/scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `one-note` / `rise` / `update` / `limits`) — do not file handFamily/suitFamily; design-record Still-a-list “confidence quizzes” is STALE (`tableRegionTap` / `confidence*Outcomes`) — clear in teachSpec ticket. Wave: `wave_two_live_competence.mjs`. Tip `7d9ff87c` Prefer NEVER: SoftPulse OBSERVE→SAMPLES→SHOWDOWNS under Observation-not-certainty → **LPT-775** (needs-human; Relates LPT-215; race clone **LPT-776** Done Duplicate; `limits` sample-limits residual note under Raise confidence; sibling **LPT-716**); successors SAMPLES→SHOWDOWNS / NEW EVIDENCE→RETIRE content-driven; guided SoftPulse `one-note` densify PRESENT; scaffolded SoftPulse `rise` densify PRESENT; unguided SoftPulse `update` densify PRESENT; checkpoint SoftPulse `limits` kind `none` densify PRESENT; curriculum **LPT-215** Done — do not clone / do not re-add needs-human; distinct from Sticky SoftPulse **LPT-761** / Narrow SoftPulse **LPT-768** / Observe-wild SoftPulse **LPT-773**. Tip `d41550f0` pre-split: structural clean — explain SoftPulse + activity-level `explainGrading`; densify + SoftPulse `guideRegion` PRESENT; do not clone teachSpec/pressHints/densify (LPT-213/214/431/495/560 Done).
- Same hand × types / `act-04-10-01-*` (post **LPT-218** Done #2242 → `lesson-04-10-01-01-same-hand-types` / `02-combine-factors`): explain SoftPulse CARDS/SEATS/EVIDENCE (`deal.mode` `none`); guided/scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes; SoftPulse cues use choice ids `st-val` / `nit-fold` / `m-call`; checkpoint is `full_table_hand_lab` (`lab-04-10-01-btn-vs-nit`, hero `Kh`/`Td`) with `deal.mode` `fixed` + cue kind `none` — do not file handFamily/suitFamily on explain. Tip `2d2ca320` Prefer NEVER: SoftPulse CARDS→SEATS→EVIDENCE under Change-lines-by-type **concept-aligned** (no SoftPulse residual); successor SoftPulse TYPE→POSITION→STACK content-driven; guided SoftPulse `st-val` + scaffolded SoftPulse `nit-fold` + unguided SoftPulse `m-call` densify PRESENT; checkpoint SoftPulse `lab-steal` kind `none` densify PRESENT. **Residuals** (incomplete LPT-218 AC): Keep-baseline still on lesson objectives but never recommended correct answer + checkpoint empty-board vs type×position×stack×board → **LPT-779** (needs-human; Relates LPT-218) — do not clone / do not re-add needs-human on LPT-218; distinct from Same-cards SoftPulse **LPT-725** / Mix-five SoftPulse **LPT-721** / Confidence SoftPulse **LPT-775**. Wave: `wave_two_live_competence.mjs`. Retired id `lesson-04-10-01-exploit-checkpoints`.
- Section 4 jump `act-04-10-02-*` (`lesson-04-10-02-section-four-jump-test`): already on the felt (`jumpUtgRangeOutcomes` / `sprGuidedOutcomes` / `jump*ExploitOutcomes` / `LessonActionSpot` for 3-bet+size); design-record Still-a-list “range, SPR, and player-type checks” cleared — do not file a Still-a-list rebuild. jump_test lessons skip pressHints and needs-human multi-objective splits (assessment container). Tip `3eb5705d` Prefer NEVER: all seven scaffolded+`jump_test` hintless cue kind `none`; teachSpec PRESENT (**LPT-219** Done — do not reopen); jump-range/spr/station/nit/maniac `deal.mode` `none` densify PRESENT; jump-3bet fixed `Kh`/`Kd` + jump-size fixed `Ah`/`Kd`·`As`/`7c`/`2d` + suit variants match Dart; SoftPulse maps `j4-3bet`/`j4-10` + `guideRegion` PRESENT — structural **clean** (no SoftPulse residual / no curriculum-split). Wave: `wave_two_live_competence.mjs`.
- Multiway ranges / `act-05-01-01-*`: explain SoftPulse NUTTED/AIR/DOMINATION (`deal.mode` `none`); guided/checkpoint are outcome tiles (`deal.mode` `none` + cues `nfd` / `nuts` via `multiwayContinueOutcomes` / `multiwayPriorityOutcomes`); scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes; SoftPulse cue `fold-76` on scaffolded / `bet-set` on unguided (maps PRESENT — LPT-600 Done); design-record Still-a-list “continue and priority checks” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-05-01-01-multiway-ranges`. Tip `f25ed146` post-split (`lesson-05-01-01-01/02/03`): first-child `act-05-01-01-explain` SoftPulse NUTTED→AIR→DOMINATION **content-driven** (LPT-669 Done); successors `act-05-01-01-02-explain-speculative` MULTIWAY→OOP→FOLD + `act-05-01-01-03-explain-value` CALLERS→SET→BET content-driven SoftPulse walks — do **not** reopen LPT-669; guided SoftPulse `nfd` densify PRESENT; scaffolded SoftPulse `fold-76` one-per-press OK; unguided SoftPulse `bet-set` one-per-press OK; checkpoint SoftPulse `nuts` hintless densify PRESENT; curriculum **LPT-224** Done — do not clone (no activity↔objective residual).
- Deep-stack / `act-05-02-01-*`: explain SoftPulse DEEP/REALIZE/STACK (`deal.mode` `none`); guided/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `impl` / `plan` / `pos` via `deepImpliedOutcomes` / `deepPlanOutcomes` / `deepRewardsOutcomes`); scaffolded `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes `Ad`/`9c` · `As`/`Th`/`7h` (LPT-404 TPWK — not obsolete Ah9d/As8h7h); SoftPulse cue `fold-tp`; do not file handFamily/suitFamily on explain/guided/unguided/checkpoint; design-record Still-a-list “implied, plan, and reward checks” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-05-02-01-deep-stack-play`. Tip `31134c82` Prefer NEVER re-check (`lesson-05-02-01-01/02/03`): first-child `act-05-02-01-explain` SoftPulse DEEP→REALIZE→STACK under Use-depth-for-speculative-implied-odds **concept-aligned** (no SoftPulse residual; LPT-669 Done); successors `act-05-02-01-02-explain-stack-off` DEEP→ONE PAIR→FOLD + `act-05-02-01-03-explain-plan` SPR→TURN→RIVER content-driven SoftPulse walks — do **not** reopen LPT-669; guided SoftPulse `impl` densify PRESENT; scaffolded SoftPulse `fold-tp` one-per-press OK (+ suit variants; Dart `stackLabel` Stacks left 500); unguided SoftPulse `plan` densify PRESENT; checkpoint SoftPulse `pos` hintless densify PRESENT; curriculum **LPT-227** Done — do not clone / do not re-add needs-human; **residual** rewards-synthesis checkpoint ("150–300bb cash play rewards?") still under Plan-high-SPR objective → **LPT-680** still To Do (needs-human).
- Implied / reverse odds / `act-05-03-01-*`: explain SoftPulse IMPLIED/REVERSE/SECOND (`deal.mode` `none`); guided/scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Jh9d/8s7c2d (LPT-393 — not obsolete Kc7s2h), KhJd/AsTh8h, 7h6h/Kh9h2c; SoftPulse cues use choice ids `call-io` / `rio` / `nonut` (maps PRESENT); checkpoint is rise tiles (`deal.mode` `none` + cue `depth-pay` via `impliedOddsRiseOutcomes`) — do not file handFamily/suitFamily gaps on explain/checkpoint; design-record Still-a-list “rise check” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-05-03-01-implied-odds`. Tip `a8361500` post-split (`lesson-05-03-01-01/02/03`): first-child `act-05-03-01-explain` SoftPulse IMPLIED→REVERSE→SECOND + Dart `impliedOdds` visual still pre-split ladder under Estimate objective → residual **LPT-681** (needs-human); guided SoftPulse `call-io` PRESENT (+ suit variants; `stackLabel` Stacks left 400); checkpoint SoftPulse `depth-pay` hintless densify PRESENT (checkpoint matches Estimate — OK); successors `act-05-03-01-02-explain-reverse` REVERSE→DOMINATED→FOLD + `act-05-03-01-03-explain-draws` NON-NUT→MULTIWAY→SKIP **content-driven** (LPT-669 Done — do not reopen); scaffolded SoftPulse `rio` + unguided SoftPulse `nonut` one-per-press OK; curriculum **LPT-230** Done — do not clone. Tip `4ff7eb4e` Prefer NEVER re-check: same residual **LPT-681** still To Do; interactive structural clean; next NEVER `lesson-05-04-01-*` thin-value.
- Thin value / `act-05-04-01-*`: explain SoftPulse THIN/CATCH/BARRELS (`deal.mode` `none`); guided/scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Jh9d / Kc9s4h2d7c; SoftPulse cues use choice ids `tv` / `call-m` / `check-nit` (maps PRESENT — LPT-614 Done); checkpoint is read tiles (`deal.mode` `none` + cue `read` via `thinValueReadOutcomes`) — do not file handFamily/suitFamily gaps on explain/checkpoint; design-record Still-a-list “read check” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-05-04-01-thin-value-bluffcatch`. Tip `ea625203` post-split (`lesson-05-04-01-01/02/03`): first-child `act-05-04-01-explain` SoftPulse THIN→CATCH→BARRELS + Dart `ThinValueDemo` still pre-split ladder under thin-value-only → residual **LPT-682** (needs-human); guided SoftPulse `tv` PRESENT (+ suit variants); checkpoint SoftPulse `read` meta-read under Thin objective → residual **LPT-683** (needs-human); successors `act-05-04-01-02-explain-catch` MANIAC→BARREL→CALL + `act-05-04-01-03-explain-overfold` NIT→FOLDS→CHECK **content-driven** (LPT-669 Done — do not reopen); scaffolded SoftPulse `call-m` + unguided SoftPulse `check-nit` one-per-press OK; curriculum **LPT-233** Done — do not clone.
- Advanced flop lines / `act-05-05-01-*`: explain SoftPulse X/R/PROBE/DELAY/DONK (`deal.mode` `none` via LineStoriesDemo); guided/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `strong` / `polar` / `delay` via `linesNitXrOutcomes` / `linesDonkPolarOutcomes` / `linesDelayOutcomes`); scaffolded `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes 9h 8d / Kc 9s 3h; SoftPulse cue `probe`; do not file handFamily/suitFamily on explain/guided/unguided/checkpoint; design-record Still-a-list “nit, donk, and delay checks” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-05-05-01-lines-and-probes`. Tip `348c121e` Prefer NEVER re-check (`lesson-05-05-01-01/02/03`): first-child `act-05-05-01-explain` SoftPulse X/R→PROBE→DELAY→DONK + Dart `LineStoriesDemo` still pre-split ladder under check-raises-only → residual **LPT-684** still To Do (needs-human); guided SoftPulse `strong` densify PRESENT; successors `act-05-05-01-02-explain-probe` PROBE→DELAY→PLAN + `act-05-05-01-03-explain-donk` DONK→STRONG→AIR **content-driven** (LPT-669 Done — do not reopen); scaffolded SoftPulse `probe` one-per-press OK (+ suit variants); checkpoint SoftPulse `delay` kind `none` densify PRESENT under approved probes+delays grouping (not a meta-read residual); unguided SoftPulse `polar` densify PRESENT; curriculum **LPT-236** Done — do not clone / do not re-add needs-human.
- Line-reading / `act-05-06-01-*`: explain SoftPulse ACTION/REWRITE/UPDATE (`deal.mode` `none` via RangeRewriteDemo); guided/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `capped` / `update` / `uncap` via `lineReadCappedOutcomes` / `lineReadRebuildOutcomes` / `lineReadUncappedOutcomes`); scaffolded `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes 7h 6h / Kh 9h 2c 3d; SoftPulse cue `repr`; do not file handFamily/suitFamily on explain/guided/unguided/checkpoint; design-record Still-a-list “capped, habit, and shove checks” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-05-06-01-line-reading`. Tip `ff066b01` Prefer NEVER re-check (`lesson-05-06-01-01/02/03`): first-child `act-05-06-01-explain` SoftPulse ACTION→REWRITE→UPDATE + Dart `RangeRewriteDemo` / `rangeRewrite` **concept-aligned** under update-each-street (no SoftPulse residual; unlike Lines LPT-684 / Thin LPT-682); unguided SoftPulse `update` densify PRESENT; successors `act-05-06-01-02-explain-capped` CHECK→CAPPED→UNCAPPED + `act-05-06-01-03-explain-stale` FLOP→TURN→RE-PRICE **content-driven** (LPT-669 Done — do not reopen); guided SoftPulse `capped` densify PRESENT; scaffolded SoftPulse `repr` one-per-press OK (+ suit variants); checkpoint SoftPulse `uncap` kind `none` densify PRESENT under approved capped+uncapped grouping; curriculum **LPT-239** Done — do not clone / do not re-add needs-human; **no** new residual.
- Soft timing evidence / `act-05-07-01-*`: explain SoftPulse TIMING/SIZING/CLUES (`deal.mode` `none` via TimingCluesDemo); guided/scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `soft` / `weakish` / `reject` / `tiny` via `timingSoftEvidenceOutcomes` / `timingSizingWeakOutcomes` / `timingRejectMagicOutcomes` / `timingTinyUpdateOutcomes`) — do not file handFamily/suitFamily; design-record Still-a-list “timing quizzes” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-05-07-01-timing-sizing-evidence`. Tip `e4d1d024` Prefer NEVER re-check (`lesson-05-07-01-01/02/03`): first-child `act-05-07-01-explain` SoftPulse TIMING→SIZING→CLUES + Dart `TimingCluesDemo` still pre-split ladder under timing-soft-only → residual **LPT-685** still To Do (needs-human); guided SoftPulse `soft` densify PRESENT; checkpoint SoftPulse `tiny` hintless densify PRESENT (matches soft-evidence — OK); successors `act-05-07-01-02-explain-sizing` TINY→BIG→RANGE + `act-05-07-01-03-explain-magic` TELL→MYTH→REJECT **content-driven** (LPT-669 Done — do not reopen); scaffolded SoftPulse `weakish` + unguided SoftPulse `reject` densify PRESENT; curriculum **LPT-244** Done — do not clone / do not re-add needs-human. Tip `18fc5334` Prefer NEVER SoftPulse residual re-check: first-child SoftPulse TIMING→SIZING→CLUES + `explainGrading` "Timing → Sizing → Clues." + Dart `TimingCluesDemo` / `LessonTimingCluesExplainTable` still pre-split under timing-soft-only → residual **LPT-685** still To Do (Relates LPT-244 — do not re-add needs-human on curriculum); successors SoftPulse TINY→BIG→RANGE / TELL→MYTH→REJECT content-driven (do not reopen LPT-669); guided SoftPulse `soft` densify PRESENT; scaffolded SoftPulse `weakish` densify PRESENT; unguided SoftPulse `reject` densify PRESENT; checkpoint SoftPulse `tiny` kind `none` under timing-soft — no companion residual.
- Table dynamics / `act-05-08-01-*`: explain SoftPulse STUCK/TILTED/GEARS (`deal.mode` `none` via TablesChangeDemo); guided/scaffolded/checkpoint are outcome tiles (`deal.mode` `none` + cues `stuck` / `gear` / `temp` via `dynamicsStuckOutcomes` / `dynamicsGearOutcomes` / `dynamicsFreshOutcomes`); unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Jh/Td / Kc9s4h2d7c (SoftPulse map PRESENT `reset` — LPT-619 Done); do not file handFamily/suitFamily on explain/guided/scaffolded/checkpoint; design-record Still-a-list “stuck, gear, and freshness checks” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-05-08-01-table-dynamics`. Tip `e36af944` post-split (`lesson-05-08-01-01/02/03`): first-child `act-05-08-01-explain` SoftPulse STUCK→TILTED→GEARS + Dart `TablesChangeDemo` still pre-split ladder under tilted/stuck-only → residual **LPT-686** (needs-human); guided SoftPulse `stuck` densify PRESENT; successors `act-05-08-01-02-explain-gears` GEAR→CHANGE→SAMPLE + `act-05-08-01-03-explain-reset` COOLER→CHASE→RESET **content-driven** (LPT-669 Done — do not reopen); scaffolded SoftPulse `gear` one-per-press OK; unguided SoftPulse `reset` one-per-press OK (+ suit variants); checkpoint SoftPulse `temp` fresh-samples under gear-changes objective → residual **LPT-687** (needs-human); curriculum **LPT-247** Done — do not clone.
- Session discipline / `act-05-09-01-*`: explain SoftPulse QUIT/GUARD/FIRST (`deal.mode` `none` via GuardrailsDemo); guided/scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `stop` / `decline` / `cash` / `edge` via `disciplineStopOutcomes` / `disciplineStakesOutcomes` / `disciplineCashOutOutcomes` / `disciplineEdgeOutcomes`) — do not file handFamily/suitFamily; design-record Still-a-list “discipline quizzes” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-05-09-01-session-discipline`. Tip `3ce8732e` post-split (`lesson-05-09-01-01/02/03`): first-child `act-05-09-01-explain` SoftPulse QUIT→GUARD→FIRST + Dart `GuardrailsDemo` still pre-split ladder under stop-loss-only → residual **LPT-690** (needs-human); guided SoftPulse `stop` densify PRESENT; successors `act-05-09-01-02-explain-bankroll` BANKROLL→STAKES→DECLINE + `act-05-09-01-03-explain-quit` TIRED→WILD→CASH OUT **content-driven** (LPT-669 Done — do not reopen); scaffolded SoftPulse `decline` + unguided SoftPulse `cash` one-per-press OK; checkpoint SoftPulse `edge` edge-meta under end-sessions objective → residual **LPT-691** (needs-human); curriculum **LPT-250** Done — do not clone.
- Section 5 checkpoint / `act-05-09-02-*` is already on the felt (`s5CpMultiOutcomes` / `s5CpTellOutcomes` / `s5CpStopOutcomes` / `LessonActionSpot` for value+catch); design-record Still-a-list “multiway, tell, and stop checks” is stale — do not file a Still-a-list rebuild; clear the ledger cell inside the teachSpec ticket (LPT-251). Same re-check rule as LPT-111 / LPT-137 / LPT-165 / LPT-219. Checkpoint assessment skips pressHints and needs-human multi-objective splits (assessment container). Still file teachSpec deal/cues (LPT-251). Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-05-09-02-section-five-checkpoint`. Outcome tiles (`cp-multi`/`cp-tell`/`cp-stop`) author `deal.mode` `none` + SoftPulse cues (`nut` / `soft` / `stop`); value/catch `poker_action_sizing` author `deal.mode` `fixed` (+ variants) matching Dart `Jh9d` / `Kc9s4h2d7c` + cues `bet` / `call` — do not file handFamily/suitFamily on outcome tiles. Tip `fee963ac` discovery: all five steps have teachSpec; value/catch codes match Dart `LessonActionSpot`; densify helper arms PRESENT for multi/tell/stop (LPT-467 Done); structural clean — teachSpec Done **LPT-251**; no curriculum split ticket (assessment container).
- Range / nut advantage / `act-06-01-01-*`: explain SoftPulse RANGE/NUT/ADVANTAGE (`deal.mode` `none` via RangeAdvantageDemo); guided/scaffolded/checkpoint are outcome tiles (`deal.mode` `none` + cues `pfr` / `caller-nuts` / `press` via `rangeAdvPfrOutcomes` / `rangeAdvNutsOutcomes` / `rangeAdvPressOutcomes`); unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Ah/Kd / Kc7s2d (SoftPulse map PRESENT `cbet`); do not file handFamily/suitFamily on explain/guided/scaffolded/checkpoint; design-record Still-a-list “dry-board, paired-board, and press checks” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-06-01-01-range-nut-advantage`. Tip `41d1f091` post-split (`lesson-06-01-01-01/02/03`): first-child `act-06-01-01-explain` SoftPulse RANGE→NUT→ADVANTAGE + Dart `RangeAdvantageDemo` still pre-split ladder under range-advantage-only → residual **LPT-692** (needs-human); guided SoftPulse `pfr` densify PRESENT; successors `act-06-01-01-02-explain-nuts` NUTS→PAIRED→CALLER + `act-06-01-01-03-explain-press` RANGE→NUTS→BET **content-driven** (LPT-669 Done — do not reopen); scaffolded SoftPulse `caller-nuts` + unguided SoftPulse `cbet` one-per-press OK; checkpoint SoftPulse `press` under press-both matches objective — no companion residual; curriculum **LPT-254** Done — do not clone.
- Equity realization / `act-06-02-01-*`: explain SoftPulse EQUITY/CASH/POS (`deal.mode` `none` via EquityRealizeDemo); guided/scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `ip` / `discount` / `realize` / `pos` via `eqRealizeIpOutcomes` / `eqRealizeDiscountOutcomes` / `eqRealizeAggressionOutcomes` / `eqRealizePosOutcomes`) — do not file handFamily/suitFamily; design-record Still-a-list “realization quizzes” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-06-02-01-equity-realization`. Tip `7d928fa9` post-split (`lesson-06-02-01-01/02/03`): first-child `act-06-02-01-explain` SoftPulse EQUITY→CASH→POS + Dart `EquityRealizeDemo` is POS-led Prefer-IP framing (not a NUT-style successor leak); guided SoftPulse `ip` densify PRESENT; successors `act-06-02-01-02-explain-oop` OOP→BARRELS→DISCOUNT + `act-06-02-01-03-explain-aggro` SEMI-BLUFF→FOLDS→OUTS **content-driven** (LPT-669 Done — do not reopen); scaffolded SoftPulse `discount` + unguided SoftPulse `realize` one-per-press OK; checkpoint SoftPulse `pos` grades Position + initiative under Prefer-IP-only → residual **LPT-693** (needs-human); curriculum **LPT-257** Done — do not clone.
- Capped/uncapped / `act-06-03-01-*`: explain SoftPulse CAPPED/UNCAPPED/NUTS (`deal.mode` `none` via CappedUncappedDemo); guided/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `cap` / `uncap` / `attack` via `cappedGuidedOutcomes` / `cappedUncappedLineOutcomes` / `cappedAttackOutcomes`); scaffolded `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Jh9d / Kc9s4h2d7c; SoftPulse cue `bet`; do not file handFamily/suitFamily on explain/guided/unguided/checkpoint; design-record Still-a-list “check-turn, bomb, and attack checks” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-06-03-01-capped-uncapped`. Tip `05df1191` post-split (`lesson-06-03-01-01/02/03`): first-child `act-06-03-01-explain` SoftPulse CAPPED→UNCAPPED→NUTS + Dart `CappedUncappedDemo` still pre-split ladder under spot-caps-only → residual **LPT-694** (needs-human; race clone LPT-695 Done); guided SoftPulse `cap` densify PRESENT; successors `act-06-03-01-02-explain-uncapped` RAISE→BET→RESPECT + `act-06-03-01-03-explain-attack` CAPPED→THIN→BLUFF **content-driven** (LPT-669 Done — do not reopen); unguided SoftPulse `uncap` + scaffolded SoftPulse `bet` one-per-press OK; checkpoint SoftPulse `attack` under attack-caps matches — no companion residual; curriculum **LPT-260** Done — do not clone.
- Polar/merged / `act-06-04-01-*`: explain SoftPulse POLAR/MERGED/SIZE (`deal.mode` `none` via PolarMergedDemo); guided/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `polar` / `mismatch` / `thin` via `polarGuidedOutcomes` / `polarMismatchOutcomes` / `polarAimOutcomes`); scaffolded `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Jh/Td / QcTs3h2d7c (LPT-395; not air Qc9s…); SoftPulse cue `mid`; do not file handFamily/suitFamily on explain/guided/unguided/checkpoint; design-record Still-a-list "overbet, mismatch, and aim checks" is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Post-split children `lesson-06-04-01-01/02/03` (tip `d7c46bd5`): first-child SoftPulse POLAR→MERGED→SIZE still under polarized-sizing-only → residual **LPT-696** needs-human; successors MERGED→MEDIUM→VALUE / SIZE→SHAPE→MATCH content-driven (do not reopen LPT-669); guided SoftPulse `polar` densify PRESENT; scaffolded SoftPulse `mid` one-per-press PRESENT; unguided SoftPulse `mismatch` densify PRESENT; checkpoint SoftPulse `thin` under merged-thin-value matches. Curriculum **LPT-264** Done — do not clone.
- Overbets / geometric / `act-06-05-01-*`: explain SoftPulse OVERBET/POLAR/GEO (`deal.mode` `none` via OverbetGeometryDemo); guided/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `polar-ob` / `avoid` / `multi` via `overbetGuidedOutcomes` / `overbetAvoidOutcomes` / `overbetPlanOutcomes`); scaffolded `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes As/Kd / Ah7c2d9s; SoftPulse cue `mid`; do not file handFamily/suitFamily on explain/guided/unguided/checkpoint; design-record Still-a-list “candidate, avoid, and plan checks” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-06-05-01-overbets-geometric`. Tip `b5ebcd9a` post-split (`lesson-06-05-01-01/02/03`): first-child `act-06-05-01-explain` SoftPulse OVERBET→POLAR→GEO + Dart `OverbetGeometryDemo` still pre-split ladder under polar-overbets-only → residual **LPT-699** (needs-human); guided SoftPulse `polar-ob` densify PRESENT; successors `act-06-05-01-02-explain-geometry` FLOP→TURN→RIVER + `act-06-05-01-03-explain-random` HUGE→MEDIUM→AVOID **content-driven** (LPT-669 Done — do not reopen); scaffolded SoftPulse `mid` one-per-press PRESENT (As/Kd·Ah/7c/2d/9s + suit variants match Dart); unguided SoftPulse `avoid` densify PRESENT; checkpoint SoftPulse `multi` under geometric-sizes matches — no companion residual; curriculum **LPT-267** Done — do not clone.
- Blockers / `act-06-06-01-*`: explain SoftPulse BLOCK/USE/NO EV (`deal.mode` `none` via BlockersDemo); guided/scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `as` / `unblock` / `tweak` / `no` via `blockersGuidedOutcomes` / `blockersUnblockOutcomes` / `blockersTweakOutcomes` / `blockersEvOutcomes`) — do not file handFamily/suitFamily (guided flush board codes are atmosphere only); design-record Still-a-list “unblock, tweak, and EV checks” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-06-06-01-blockers`. Fake-+EV distractor-only on guided + multi-concept block/unblock/no-EV go in the needs-human split ticket.
- Minimum defense / `act-06-07-01-*`: explain SoftPulse DEFEND/BLUFF/ENOUGH (`deal.mode` `none` via DefendEnoughDemo); guided/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `strong` / `int` / `punish` via `defendGuidedOutcomes` / `defendIntuitionOutcomes` / `defendPunishOutcomes`); scaffolded `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes 9h/7d / KcQh9d4c8s (LPT-397 third-pair — not obsolete KcQhJd2cTs); SoftPulse cue `fold`; do not file handFamily/suitFamily gaps on explain/guided/unguided/checkpoint; design-record Still-a-list "continue, intuition, and punish checks" is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-06-07-01-minimum-defense`. Tip `c6b4c02e` post-split (`lesson-06-07-01-01/02/03`): first-child `act-06-07-01-explain` SoftPulse DEFEND→BLUFF→ENOUGH + Dart `DefendEnoughDemo` still pre-split ladder under continue-catchers-only → residual **LPT-701** (needs-human); guided SoftPulse `strong` densify PRESENT; checkpoint SoftPulse `punish` under Continue catchers → residual **LPT-702** (needs-human); successors `act-06-07-01-02-explain-trash` THIRD PAIR→SCARY→FOLD + `act-06-07-01-03-explain-mdf` MDF→INTUITION **content-driven** (LPT-669 Done — do not reopen); scaffolded SoftPulse `fold` one-per-press OK (+ suit variants); unguided SoftPulse `int` one-per-press OK; curriculum **LPT-273** Done — do not clone.
- Mix with a reason / `act-06-08-01-*`: explain SoftPulse MIX/PURPOSE/STRONG (`deal.mode` `none`); guided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes 7h/7d / 7c Kd 2s; SoftPulse cue `protect`; scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `less` / `no` / `freq` via `mixStationOutcomes` / `mixReasonOutcomes` / `mixPurposeOutcomes`) — do not file handFamily/suitFamily; design-record Still-a-list “station, reason, and purpose checks” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-06-08-01-mixed-strategy`. Multi-concept purposeful-mix vs type-reduced vs reject-chaos go in the needs-human split ticket. Tip `2c1af5c0` discovery: structural clean — explain MIX→PURPOSE→STRONG + `explainGrading`; guided fixed+variants match Dart SoftPulse `protect` PRESENT; densify PRESENT scaffolded/unguided/checkpoint; tip-commented curriculum **LPT-277** (human-approved — no `needs-human`); do not clone LPT-275/276/475/500/644. Tip `05b93ac4` post-split (`lesson-06-08-01-01/02/03`): first-child `act-06-08-01-explain` SoftPulse MIX→PURPOSE→STRONG **wired** (`mixedStrategy`) but still pre-split ladder under mix-strong-only → residual **LPT-703** (needs-human; Relates LPT-277); successors `act-06-08-01-02-explain-types` TYPE→STATION→LESS + `act-06-08-01-03-explain-random` RANDOM→PURPOSE content-driven (do not reopen LPT-669); guided SoftPulse `protect` PRESENT; scaffolded/unguided one-per-press densify PRESENT; checkpoint SoftPulse `freq` under no-pure-random matches — no companion residual; curriculum **LPT-277** Done — do not clone.
- 3-bet/4-bet depth / `act-06-09-01-*`: explain SoftPulse 3BET/4BET/DEPTH (`deal.mode` `none` via ThreeBetFourBetSprDemo); guided/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `careful` / `avoid` / `spr` via `threeBetCommitOutcomes` / `threeBetEgoOutcomes` / `threeBetSprOutcomes`); scaffolded `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Ah/Qd / 8c 3h 2s; SoftPulse cue `small`; do not file handFamily/suitFamily on explain/guided/unguided/checkpoint; design-record Still-a-list “commit, ego, and SPR checks” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Retired lesson id was `lesson-06-09-01-threebet-fourbet`. Tip `2c1af5c0` discovery: structural clean — explain 3BET→4BET→DEPTH + `explainGrading`; scaffolded fixed+variants match Dart SoftPulse `small` + `stackLabel` 360; densify PRESENT guided/unguided/checkpoint; tip-commented curriculum **LPT-282** (human-approved — no `needs-human`); do not clone LPT-280/281/476/501/645. Tip `803ed55f` post-split (`lesson-06-09-01-01/02/03`): careful-4bet SoftPulse 4BET→STRONG→CAREFUL content-driven + guided SoftPulse `careful` densify PRESENT; **middle-child** `act-06-09-01-explain` SoftPulse 3BET→4BET→DEPTH + Dart `ThreeBetFourBetSprDemo` still pre-split ladder under plan-3bet-spr → residual **LPT-704** (needs-human; Relates LPT-282); scaffolded SoftPulse `small` one-per-press PRESENT; checkpoint SoftPulse `spr` under plan-3bet-spr matches — no companion residual; ego SoftPulse 4BET→EGO→AVOID content-driven + unguided SoftPulse `avoid` one-per-press densify PRESENT (do not reopen LPT-669); curriculum **LPT-282** Done — do not clone.
- Difficult folds / `act-06-10-01-*`: explain SoftPulse HARD/COOLER/EGO (`deal.mode` `none` via HardFoldCoolerDemo); guided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Ah/9d / As7c2hKd3c; SoftPulse cue `fold`; scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `cooler` / `ego` / `ask` via `hardFoldCoolerOutcomes` / `hardFoldEgoOutcomes` / `hardFoldReviewOutcomes`) — do not file handFamily/suitFamily; design-record Still-a-list “cooler, ego, and review checks” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-06-10-01-difficult-folds`. Checkpoint meta-review vs cooler-label objective + multi-concept hard-fold/cooler/ego go in the curriculum split ticket. Tip `463fbbb3` discovery: structural clean — explain HARD→COOLER→EGO + `explainGrading`; guided fixed+variants match Dart SoftPulse `fold` PRESENT; densify PRESENT scaffolded/unguided/checkpoint; one-per-press OK; checkpoint hintless; tip-commented curriculum **LPT-285** (human-approved — do not re-add `needs-human`); do not clone LPT-283/284/477/502.
- Observe selective / `act-06-11-01-*`: explain SoftPulse TIGHT/BARREL/SAMPLE (`deal.mode` `none`); guided/scaffolded/unguided/checkpoint are observation outcome tiles (`deal.mode` `none` + cues `sel` / `disc` / `low` / `bundle`) — do not file handFamily/suitFamily; design-record Still-a-list “entry quizzes” is STALE (`tableRegionTap` / `selective*Outcomes`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Pre-split lesson id was `lesson-06-11-01-observe-selective`. Tip `ee4d7f8b`/`f8c6579d` post-split (`lesson-06-11-01-01/02/03`): first-child `act-06-11-01-explain` SoftPulse TIGHT→BARREL→SAMPLE + Dart `SelectiveAggressionDemo` still pre-split ladder under selective-entry-only → **LPT-706**; successors `02-explain-discipline` / `03-explain-wait` content-driven; checkpoint SoftPulse `bundle` under wait-for-samples matches (NOTE BUNDLE) — no companion residual; curriculum **LPT-288** Done — do not clone / do not re-add needs-human.
- Meet TAG / `act-06-11-02-*`: explain SoftPulse TIGHT/AGGRO/MODEL (`deal.mode` `none` via TagModelDemo); guided/unguided `player_read_classify` route through `SelectIdentifyActivity` + `tableRegionTap` (`meetTagVsStationOutcomes` / `meetTagVsManiacOutcomes`) with cues `tag` / `tag2`; scaffolded `meetTagDiffOutcomes` cue `diff`; checkpoint `meetTagModelOutcomes` cue `model` — do not file handFamily/suitFamily; design-record Still-a-list “label quizzes” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-06-11-02-meet-tag`. Checkpoint model-vs-insult vs introduce-TAG + scaffolded selective-vs-extreme vs introduce-TAG go in the needs-human split ticket. Tip `a493f7a2` discovery: structural clean — explain SoftPulse TIGHT→AGGRO→MODEL + `explainGrading`; all interactive `deal.mode` `none` SoftPulse choice cues; scaffolded/unguided one-per-press OK; checkpoint hintless cue kind `none`; densify arms PRESENT guided/scaffolded/unguided/checkpoint; region maps PRESENT — curriculum **LPT-291** only (do not clone teachSpec/pressHints/densify/guideRegion — LPT-289/290/436/491/648 Done).
- Adjust vs TAG / `act-06-11-03-*`: explain SoftPulse CREDIT/TIGHTER/NO LIGHT (`deal.mode` `none`); guided/scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Jh9d/Qc9s3h, Kh9d, JhTd/QcTs3h2d7c; SoftPulse cues use choice ids `fold` / `fold-k9` (unguided SoftPulse map may be missing today — still author deal); checkpoint is cite tiles (`deal.mode` `none` + cue `cite` via `tagRespectCiteOutcomes`) — do not file handFamily/suitFamily gaps; design-record Still-a-list “respect check” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-06-11-03-adjust-tag`. Unguided thin-value vs cite objective + multi-concept respect/no-light-XR/thin-value/cite go in the needs-human split ticket.
- Observe wide / `act-06-12-01-*` (post **LPT-297** Done): unit `unit-06-12-lag` children `lesson-06-12-01-01/02/03`. Explain SoftPulse WIDE/PRESSURE/SAMPLE + successors BARRELS/MANY HANDS + FOLDS SOMETIMES/PLAN (`deal.mode` `none` via WidePressureDemo); guided/scaffolded/unguided/checkpoint are observation outcome tiles (`deal.mode` `none` + cues `wide` / `sep` / `wait` / `bundle` via `lagObserveGuidedOutcomes` / `lagObserveDiscOutcomes` / `lagObserveSampleOutcomes` / `lagObserveBundleOutcomes`) — do not file handFamily/suitFamily; design-record Still-a-list “entry quizzes” is STALE (`tableRegionTap`). SoftPulse explain successors content-driven (LPT-669 Done — do not reopen). **Residuals:** first-child SoftPulse still walks PRESSURE/SAMPLE under Note wide entry → **LPT-713**; Keep-sampling unguided under Note sustained pressure → **LPT-714**; evidence-bundle checkpoint under Planned-not-maniac → **LPT-715** (all needs-human); do not reopen Done **LPT-297**. Wave: `wave_three_advanced_play.mjs` (retired id breadcrumb). Tip `9886d4bb` NEVER walk: structural companions clear; filed LPT-713/714/715.
- Meet LAG / `act-06-12-02-*`: explain SoftPulse WIDE/PRESSURE/MODEL (`deal.mode` `none` via LagModelDemo); guided/unguided `player_read_classify` route through `SelectIdentifyActivity` + `tableRegionTap` (`meetLagVsTagOutcomes` / `meetLagVsNitOutcomes`) with cues `lag` / `lag2`; scaffolded `meetLagDiffOutcomes` cue `diff`; checkpoint `meetLagLimitsOutcomes` cue `limits` — do not file handFamily/suitFamily; design-record Still-a-list “label quizzes” is STALE — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-06-12-02-meet-lag`. Checkpoint sample-limits vs introduce-LAG + scaffolded pressure-vs-passive vs introduce-LAG go in the needs-human split ticket.
- Adjust vs LAG / `act-06-12-03-*`: explain SoftPulse CALL/TRAP/FANCY LESS (`deal.mode` `none`); guided/scaffolded `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Jh9d/Qc9s3h2d7c, AsAd/Ac7s2h; SoftPulse cues use choice ids `call` / `trap`; unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `avoid` / `cite` via `lagAdjustAvoidOutcomes` / `lagAdjustCiteOutcomes`) — do not file handFamily/suitFamily gaps; design-record Still-a-list “avoid and cite checks” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-06-12-03-adjust-lag`. Checkpoint cite vs widen-call objective + multi-concept widen/trap/avoid/cite go in the needs-human split ticket. Tip `8bad05d8` discovery: structural clean — explain SoftPulse CALL→TRAP→FANCY LESS + `explainGrading`; guided fixed Jh/9d·Qc9s3h2d7c + suit variants match Dart `resolveLessonActionSpot`; scaffolded As/Ad·Ac7s2h + variants; SoftPulse maps `call`/`trap` PRESENT; unguided/checkpoint densify PRESENT; one-per-press OK; Still-a-list avoid/cite STALE — no rebuild; curriculum **LPT-303** only (do not clone teachSpec/pressHints/densify — LPT-301/302/441/503/651 Done).
- Mix five types / `act-06-13-01-*`: explain SoftPulse CARDS/SEATS/EVIDENCE (`deal.mode` `none` via ExploitEvidenceDemo); guided/scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Jh/Td / Qc Ts 3h 2d 7c; SoftPulse cues use choice ids `cs` / `nit` (unguided SoftPulse map may be missing today — still author deal; choice id `lag`); checkpoint is cite tiles (`deal.mode` `none` + cue `tag` via `mixFiveTagRespectOutcomes`) — do not file handFamily/suitFamily gaps; design-record Still-a-list "label check" is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-06-13-01-mix-five-types`. Maniac never-as-correct + baseline-without-evidence objective + multi-concept Station/Nit/LAG/cite go in the needs-human split ticket.
- Section 6 checkpoint / `act-06-13-02-*` is already on the felt (`s6CpAdvOutcomes` / `s6CpCapOutcomes` / `s6CpPolarOutcomes` / `s6CpTagOutcomes` / `s6CpLagOutcomes` / `tableRegionTap`); design-record Still-a-list “advantage, cap, polar, TAG, and LAG checks” is stale — do not file a Still-a-list rebuild; clear the ledger cell inside the teachSpec ticket (LPT-307). Same re-check rule as LPT-111 / LPT-137 / LPT-165 / LPT-219 / LPT-251. Checkpoint assessment skips pressHints and needs-human multi-objective splits (assessment container). Still file teachSpec deal/cues (LPT-307). Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-06-13-02-section-six-checkpoint`. All five are outcome/label tiles (`deal.mode` `none` + SoftPulse cues `ra` / `cap` / `polar` / `tag` / `lag`) — do not file handFamily/suitFamily gaps; cp-tag/cp-lag use `player_read_classify` → `SelectIdentifyActivity` + `tableRegionTap`.
- Preflop plan to flop / `act-07-01-01-*`: explain SoftPulse REASON/CONFIRM/CANCEL (`deal.mode` `none` via PreflopFlopPlanDemo); guided/scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `dead` / `value` / `thesis` / `abandon` via `preflopFlop*Outcomes`) — do not file handFamily/suitFamily; design-record Still-a-list “plan quizzes” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-01-01-preflop-to-flop`. Multi-concept thesis vs flop-update vs abandon-dead-plans go in the needs-human split ticket. Tip `0bbe821c` Prefer NEVER: first-child SoftPulse REASON→CONFIRM→CANCEL under thesis-only → **LPT-790** (needs-human; Relates LPT-310); successors content-driven; densify PRESENT; checkpoint under abandon matches; curriculum **LPT-310** Done — do not clone.
- Flop-to-turn map / `act-07-02-01-*`: explain SoftPulse BARREL/GIVE-UP/MAP (`deal.mode` `none` via turnMap coach visual); guided/scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `ok` / `give` / `avoid` / `list` via `turnMap*Outcomes`); guided/scaffolded scene hero+board codes are caption atmosphere only — do not file handFamily/suitFamily; design-record Still-a-list “no-plan and definition checks” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-02-01-flop-to-turn-map`. Multi-concept continue vs give-up vs bet-only-with-map go in the needs-human split ticket. Tip `7854ec96` Prefer NEVER post-split (`lesson-07-02-01-01/02/03`): first-child SoftPulse BARREL→GIVE-UP→MAP + Dart `TurnMapDemo` still pre-split under List-turn-continue-cards-only → residual **LPT-794** (needs-human; Relates LPT-314); successors BRICK→GIVE UP / CONTINUE→GIVE-UP→MAP content-driven; densify PRESENT; checkpoint under map-definition matches; curriculum **LPT-314** Done — do not clone.
- River composition / `act-07-03-01-*` (post **LPT-317** Done): unit children `lesson-07-03-01-01/02/03`. First-child SoftPulse VALUE→BLUFF→HOLD + Dart `RiverCompositionDemo` under value-only → residual **LPT-795** (needs-human); checkpoint SoftPulse `rule` under value-only → residual **LPT-796** (needs-human); successors BLOCKER→FEWER CALLS / NO STORY→CHECK content-driven (do not reopen LPT-669). Guided `poker_action_sizing` `fixed` (+ variants) As/Ad·Ac9s4h2d7c SoftPulse `val`; scaffolded/unguided outcome tiles `deal.mode` `none` cues `block`/`check` one-per-press densify PRESENT — do not file handFamily. Curriculum **LPT-317** Done — do not clone / do not re-add needs-human. Wave: `wave_three_advanced_play.mjs`.
- Pot-type plans / `act-07-04-01-*` (post **LPT-320** Done): unit children `lesson-07-04-01-01/02/03`. First-child SoftPulse LIMPED→SRP→3-4BET + Dart `PotTypePlansDemo` under limped-only → residual **LPT-798** (needs-human); checkpoint SoftPulse `both` ("Ranges and SPR") under 3-bet/4-bet-only → residual **LPT-799** (needs-human); successors HEADS-UP→C-BET / LOW SPR→COMMIT content-driven (do not reopen LPT-669). Guided/scaffolded/unguided outcome tiles `deal.mode` `none` cues `nuts`/`cb`/`commit` one-per-press densify PRESENT — do not file handFamily. Curriculum **LPT-320** Done — do not clone / do not re-add needs-human. Wave: `wave_three_advanced_play.mjs`. Retired id breadcrumb `lesson-07-04-01-pot-type-plans`.
- HU vs multiway / `act-07-05-01-*` (post **LPT-323** Done): unit children `lesson-07-05-01-01/02/03`. First-child SoftPulse FEWER→THICKER→WIDEN + Dart `HuVsMultiwayDemo` under bluff-less-only → residual **LPT-800** (needs-human); checkpoint SoftPulse `input` ("Player count is?") under bluff-less-only → residual **LPT-801** (needs-human); successors MULTIWAY→THICK VALUE / HEADS-UP→STEAL MORE content-driven (do not reopen LPT-669). Guided/unguided/scaffolded outcome tiles `deal.mode` `none` cues `no`/`thick`/`higher` one-per-press densify PRESENT — do not file handFamily. Curriculum **LPT-323** Done — do not clone / do not re-add needs-human. Wave: `wave_three_advanced_play.mjs`. Retired id breadcrumb `lesson-07-05-01-hu-vs-multiway`.
- Stack-depth plans / `act-07-06-01-*`: explain SoftPulse SHORT/DEEP/EFFECTIVE (`deal.mode` `none` via `LessonStackDepthPlansExplainTable` / `StackDepthPlansDemo` — *not* `BbStackDepthDemo` CHIPS→BB/SHORTER/DEPTH, which is S2 `act-02-05-01-explain-bb` only); guided/scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `commit` / `yes` / `40` / `every` via `stackDepth*Outcomes`); unguided SoftPulse map may be missing today — still author deal; do not file handFamily/suitFamily; design-record Still-a-list “depth quizzes” is STALE (`tableRegionTap`) — clear in teachSpec ticket (LPT-324). Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-06-01-stack-depth-plans`. Multi-concept commit-short vs deep-implied vs recalculate-every-hand go in the needs-human split ticket.
- Replay same hand × types / `act-07-07-01-*`: explain SoftPulse CARDS/MODELS/CITE (`deal.mode` `none` via `LessonSameCardsTypesExplainTable` / `SameCardsTypesDemo`); guided/scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Ah/Kd · Kc8s3h (unguided turn adds 2d); SoftPulse cues use choice ids `bet` / `fold` (unguided SoftPulse map may be missing today — still author deal; choice id `call`); checkpoint is cite/baseline tiles (`deal.mode` `none` + cue `base` via `sameCardsCheckpointOutcomes`) — do not file handFamily/suitFamily gaps on explain/checkpoint; design-record Still-a-list “no-evidence check” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-07-01-same-cards-types`. Nit/Maniac never-as-correct + multi-concept type-cite vs baseline-absent vs practice-all-five go in the needs-human split ticket.
- Type × board × line / `act-07-08-01-*`: explain SoftPulse TYPE/BOARD/LINE/SIZE (`deal.mode` `none` via `LessonTypeBoardLineExplainTable` / `TypeBoardLineDemo`); guided/scaffolded/unguided `poker_action_sizing` author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveLessonActionSpot` hero/board codes Jh/Td·KhTs8h2d (post LPT-396; was Ts9h8c2d top-pair leak), 9h/8d·Ac7s2dKd, Jh/Td·QcTs3h2d7c; SoftPulse cues use choice ids `call` / `raise` (unguided SoftPulse map may be missing today — still author deal; choice id `fold`); checkpoint is input-set tiles (`deal.mode` `none` + cue `four` via `typeBoardCheckpointOutcomes`) — do not file handFamily/suitFamily gaps on explain/checkpoint; design-record Still-a-list “integration check” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-08-01-type-board-line`. Checkpoint meta all-four vs coherent-action objective + multi-concept type×board / line×sizing / integration go in the needs-human split ticket.
- Leak-review book / `act-07-09-01-*`: explain SoftPulse LEAK/BOOK/REVIEW (`deal.mode` `none` via `LeakReviewBookDemo` / `LessonLeakReviewBookExplainTable`); guided/scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `spec` / `book` / `sched` / `base` via `leakReview*Outcomes`) — do not file handFamily/suitFamily; design-record Still-a-list “book quizzes” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-09-01-leak-review-book`. Checkpoint book-purpose vs schedule-review objective + multi-concept name-leaks/write-defaults/schedule-review go in the needs-human split ticket.
- Capstone SRP / `act-07-10-01-*`: explain SoftPulse PLAN/UPDATE/FINISH (`deal.mode` `none` via `CapstoneSrpDemo` / `LessonCapstoneSrpExplainTable`); hand is `authored_multi_step_hand` scaffolded SoftPulse-quiet — author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveToyHandStepSpot` hero/board codes Ah/Qd · Kc7s2h/+2d/+9c; optional cues `cb` / `barrel` / `check-r` after Hint; "No hints" copy means intentional no-Hint **transfer** assessment (`assessmentRole: transfer`, no authored pressHints; LPT-348). Keep `NO_HINT_ACTIVITY_IDS` in sync; do not reopen LPT-626/LPT-667 (do not reopen LPT-626/667). Skip `needs-human` lesson-split (synthesis container in `unit-07-10-capstones`). Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-10-01-capstone-srp`. Tip `f95fbbb0` discovery: explain has activity-level `explainGrading` + PLAN/UPDATE/FINISH cues; hand fixed AhQd/Kc7s2h2d9c + 2 suit variants match Dart; cues `cb`/`barrel`/`check-r`; pressHints empty (LPT-348); teachSpec Done **LPT-337** — structural clean aside from Capstone NO_HINT policy.
- Capstone 3-bet / `act-07-10-02-*`: explain SoftPulse SPR/TURN/CLOSE (`deal.mode` `none` via `Capstone3betDemo` / `LessonCapstone3betExplainTable`); hand is `authored_multi_step_hand` scaffolded SoftPulse-quiet — author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveToyHandStepSpot` hero/board codes Ah/Qd · Qs8h3d/+2d/+7c; optional cues `bet` / `barrel` / `fold` after Hint; "No hints" copy means intentional no-Hint **transfer** assessment (`assessmentRole: transfer`, no authored pressHints; LPT-348). Keep `NO_HINT_ACTIVITY_IDS` in sync; do not reopen LPT-626/LPT-667. Skip `needs-human` lesson-split (synthesis container in `unit-07-10-capstones`). Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-10-02-capstone-3bet`.
- Capstone multiway deep / `act-07-10-03-*`: explain SoftPulse NUTS/DEEP/NO-BLUFF (`deal.mode` `none` via `CapstoneMultiwayDeepDemo` / `LessonCapstoneMultiwayDeepExplainTable`); hand is `authored_multi_step_hand` scaffolded SoftPulse-quiet — author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveToyHandStepSpot` hero/board codes Ah/Qh · Jh 8h 2c/+3d/+9c; optional cues `call` / `bet` / `check-r` after Hint; "No hints" copy means intentional no-Hint **transfer** assessment (`assessmentRole: transfer`, no authored pressHints; LPT-348). Keep `NO_HINT_ACTIVITY_IDS` in sync; do not reopen LPT-626/LPT-667. Skip `needs-human` lesson-split (synthesis container in `unit-07-10-capstones`). Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-10-03-capstone-multiway-deep`.
- Capstone limped / `act-07-10-04-*`: explain SoftPulse NUTS/VALUE/THIN (`deal.mode` `none` via `CapstoneLimpedDemo` / `LessonCapstoneLimpedExplainTable`); hand is `authored_multi_step_hand` scaffolded SoftPulse-quiet — author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveToyHandStepSpot` hero/board codes Ah/Kh · Kd 9c 4h/+2s/+8d; optional cues `bet` / `barrel` / `value` after Hint; "No hints" copy means intentional no-Hint **transfer** assessment (`assessmentRole: transfer`, no authored pressHints; LPT-348). Keep `NO_HINT_ACTIVITY_IDS` in sync; do not reopen LPT-626/LPT-667. Skip `needs-human` lesson-split (synthesis container in `unit-07-10-capstones`). Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-10-04-capstone-limped`.
- Capstone 4-bet / `act-07-10-05-*`: explain SoftPulse SPR/COMMIT/NO HERO (`deal.mode` `none` via `Capstone4betDemo` / `LessonCapstone4betExplainTable`); hand is `authored_multi_step_hand` scaffolded SoftPulse-quiet — author `deal.mode` `fixed` (+ `deal.variants`) matching Dart `resolveToyHandStepSpot` hero/board codes Kh/Kd · Qs 8h 3d/+2d/+Ad; optional cues `bet` / `barrel` / `fold` after Hint; "No hints" copy means intentional no-Hint **transfer** assessment (`assessmentRole: transfer`, no authored pressHints; LPT-348). Keep `NO_HINT_ACTIVITY_IDS` in sync; do not reopen LPT-626/LPT-667. Skip `needs-human` lesson-split (synthesis container in `unit-07-10-capstones`). Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-10-05-capstone-4bet`. Tip `e8523695` discovery: explain has activity-level `explainGrading` + SoftPulse cues; hand fixed Kh/Kd·Qs8h3d2dAd + suit-rotated variants match Dart; cues `bet`/`barrel`/`fold`; pressHints empty → **LPT-348** only (do not reopen LPT-626/667); structural clean; no curriculum-split.
- Prep Live warm-up / `act-07-11-01-*`: explain SoftPulse CHECKLIST/DEFAULTS/ONE HAND (`deal.mode` `none` via `LiveWarmupPrepDemo` / `LessonLiveWarmupPrepExplainTable`); guided/scaffolded/unguided/checkpoint are outcome tiles (`deal.mode` `none` + cues `list` / `defaults` / `scope` / `one` via `liveWarmup*Outcomes`); do not file handFamily/suitFamily; design-record Still-a-list “warm-up quizzes” is STALE (`tableRegionTap`) — clear in teachSpec ticket. Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-11-01-live-warmup-prep`. Checkpoint one-hand vs carry-defaults objective + multi-concept checklist/defaults/scope go in the needs-human split ticket.
- Five-type final / `act-07-12-01-*`: all seven are scaffolded + `assessmentRole` checkpoint outcome tiles (`deal.mode` `none` + SoftPulse cues `cs` / `nit` / `man` / `tag` / `lag` / `low` / `retire` via `fiveType*Outcomes` / `tableRegionTap`); cs–lag use `player_read_classify` → `SelectIdentifyActivity`; uncertain/retire use `select_identify` — do not file handFamily/suitFamily; design-record Still-a-list “station, nit, maniac, TAG, LAG, certainty, and retire checks” is STALE — clear in teachSpec ticket (LPT-352). Checkpoint assessment skips pressHints and needs-human multi-objective splits (assessment container in `unit-07-12-final`). Still file teachSpec deal/cues (LPT-352). Wave: `wave_three_advanced_play.mjs`. Lesson id is `lesson-07-12-01-five-type-final` (catalog exit / SECTION_SEVEN_EXIT_LESSON). Tip `d2ed1c8a` discovery: all seven author teachSpec `deal.mode` `none` + cue kind `none` (targets above); densify helper arms PRESENT in `selectIdentifyDensifiedCoachLine`; hintless; no curriculum-split; structural clean (LPT-352/443 Done).
- SoftPulse `coach_dialogue` explains left out of Done interactive teachSpec tickets (LPT-81/94/98/101/104/108 carved explains as “later”) still need authored `teachSpec`/`cues` — pilot / Button / Hand ranks / habits / outs / flop-lines already set the bar; do not treat Done interactive teachSpec as explain-complete. Section 1 catch-up: LPT-353…LPT-358. Cue ids for suits explain use `LessonSuitToken` names (`hearts`…), not guided `board_hearts`.
- Section 2 SoftPulse explains missing teachSpec while interactive Done: position (`BTN` / `_PositionLabelsDemo`), acting-order (`UTG`→`HJ`→`CO`→`BTN` / `ActionOrderDemo`), hand-families (`fam-pairs`…`fam-connectors` / `HandFamiliesDemo`), open (`EARLY`/`BUTTON`/`LIVE 3x` / `OpenRangeDemo`), vs-open (`FOLD`/`CALL`/`3-BET` / `VsOpenResponseDemo`), effective-stack (`CHIPS→BB`/`SHORTER`/`DEPTH` / `BbStackDepthDemo`), baseline-full (`NINE`/`SAME`/`POSITION` / `FullRingDemo`). Habits explain already authors cues — skip. Use demo SoftPulse labels, not guided dock ids. Filed LPT-359…LPT-365. Wave: `wave_one_foundations.mjs`.
- SoftPulse explain catch-up only when interactive teachSpec is already Done and the Done ticket carved `coach_dialogue` as “later” (S1/S2 → LPT-353…365). When the open High interactive teachSpec ticket already lists the explain activity (S3 multiway LPT-158, leak LPT-161, and later section Highs), do **not** file a separate SoftPulse-explain Medium — comment tip SHA on the High ticket instead.
- After interactive teachSpec lands Done, re-walk the same lesson for (1) authored `deal.variants` on `random_in_class` steps that still lack them while sibling steps already have distractor/practice variants (Suits: unguided/checkpoint had variants; guided-suits + scaffolded-ranks did not — LPT-369 after LPT-366 pilot pattern), and (2) SoftPulse `cues` on scaffolded `order_sequence` / multi-press steps that shipped deal-only in the teachSpec PR (LPT-81 acceptance only required guided cues — ranks cues filed LPT-370). Do not treat “teachSpec present” as variants-complete or SoftPulse-after-Hint-complete.
- Seat/puck / phase `deal.mode` `none` lessons (Button and blinds, position, streets order, stack-BB tiles, etc.) cannot author useful `deal.variants` under current `teach_spec.schema.json` (variants only carry `handFamily` / `suitFamily` / `fixedCards`) — after teachSpec+cues land, do **not** file a variants gap; re-walk only for pressHints / cue completeness. Card-class lessons (`random_in_class` / `fixed`) still need the LPT-366/369 variants follow-up when siblings already ship distractor variants.
- After a deal-honesty fix lands for one activity (LPT-367 multiway missed air → `7s3d`/`AhKh9h`; LPT-381 leak gutshot → `Jh9d`/`KsTc2d`), re-scan *sibling* scenes that still hard-code the old template before keeping open teachSpec tickets verbatim — Section 3 jump-leak still used JT/A72 under a gutshot ask (LPT-389). Update open High teachSpec bodies (LPT-158/161) to the tip Dart codes in the same run; do not leave implementers copying obsolete `Jh Td` lines.
- After LPT-381/389 gutshot zero-outs fixes, scan *all* `streetLabel` / prompts containing “gutshot” in `lesson_action_table.dart` (not only JT/A72 siblings) — `act-05-03-01-guided` taught gutshot+overs on J9/K72 air (LPT-393). Update open High teachSpec bodies (LPT-228) to corrected codes in the same run.
- After LPT-381/389/393 gutshot zero-outs fixes, scan *lesson_table_context.dart* captions + `select_identify` densify + catalog prompts for “gutshot” (not only `lesson_action_table.dart` streetLabel) — turn-map scaffolded atmosphere 98hh/K723 was zero-outs under a gutshot densify/caption (LPT-394). Update open High teachSpec bodies (LPT-312) to corrected atmosphere codes in the same run; `deal.mode` `none` outcome tiles still need honest caption cards when coach names a hand class.
- After gutshot zero-outs honesty (LPT-381/389/393/394), scan *pair-class* streetLabel + catalog prompts (`second pair` / `third pair` / `top pair`) against `LessonActionSpot` hole+board — LPT-395 polar scaffolded JT/`Qc9s…` is air under second-pair/thin-value (siblings use `QcTs…`); LPT-396 type-board guided JT/`Ts9h8c2d` is top pair under second-pair copy; LPT-397 MDF scaffolded 97o/`KQJ2T` is air under third-pair fold. Update open High teachSpec bodies (LPT-262/271/331) to corrected codes in the same run; do not leave implementers copying dishonest templates.
- After pair-class streetLabel honesty (LPT-395…397), scan *missed draw* / *four hearts* (and other board-texture claims) in `streetLabel` + catalog `prompt` against `LessonActionSpot` hole+board — LPT-398 sizing scaffolded and LPT-399 station scaffolded claim missed draw on air (never FD/SD); LPT-400 continuation scaffolded claims four hearts on a three-heart board. Update open High teachSpec bodies (LPT-177/190/174) to corrected codes in the same run; set/trips/FD streetLabels can be clean while these still fail.
- After missed-draw / four-hearts / pair-class streetLabel honesty (LPT-395…400), scan *TPTK* claims in `streetLabel` / feltStatus against true top-pair-top-kicker (unpaired hole outranks every unpaired board card — `lesson_card_deal.dart`) — LPT-401 leak guided `Weak TPTK` over Ah4d/A97 TPWK (catalog prompt already said weak kicker). Update open High teachSpec bodies (LPT-161) to say TPWK / weak top pair, not “weak TPTK”.
- After streetLabel missed-draw honesty (LPT-398/399), also scan *catalog prompts* / a11y that say “You missed a flush draw” (or “missed draw”) against `teachSpec.fixedCards` / Dart hole+board — LPT-402 river scaffolded `9s8s`/`Kh7h2c3dAh` never had FD while `streetLabel` only said “flush completes” (board scare). Prompt-level missed-FD can fail when the felt label looks structural; update open variants tickets (LPT-388) to the corrected template in the same run.
- After missed-draw / pair-class / TPTK streetLabel honesty (LPT-395…402), also scan *conjunction* class claims where one half can be false while the other looks structural — “gutshot with overs” (LPT-393: LPT-381 Jh9d/KT2 restores gutshot but zero overs; need Jh9d/872-class) and “fold light top pair” that silently deals TPTK (LPT-404 Ah9d/As8h7h — 9>8,7; three hearts is backdoor only, not NFD). Update open High teachSpec bodies (LPT-228/225) to true TPWK codes in the same run; do not copy gutshot-only or TPTK-as-weak templates under those asks.
- Three hearts (1 hole + 2 board) is backdoor only — not a flush draw / NFD. Do not file NFD honesty on Ah+two-heart flops; separately check TPTK vs “weak/light TP” via `lesson_card_deal` top-kicker rule (LPT-404 corrected after false NFD diagnosis).
- After pair/gutshot/missed-draw/TPTK honesty sweeps, scan streetLabel / catalog / coach **texture codes** (`r` / `tt` / mono) against the three flop suits — LPT-405 Q83tt on rainbow `Qs8h3d` while sibling capstone 4-bet already labels the same board `Q83r`. Update open High teachSpec bodies (LPT-339) in the same run.
- After LPT-406 strongOffsuitBroadway, scan postflop teach fingerprints for class claims remap can break — nut flush draw (NFD) is **not** in `_postflopTeachKey` today, so Ah9h/Jh8h3c and AhQh/Jh8h2c remaps into Kh9s-class non-nut FDs while SoftPulse/`nfd`/feltStatus still say nut (LPT-408). Do not treat “strongDraw + 9 outs + suited” as nut-complete; same sibling-scan habit as gutshot/TPTK/missed-draw honesty.
- After LPT-408 nut-FD fingerprint, scan *pair-depth* under `HandClass.weakPair` — `_postflopTeachKey` has no board-rank index, so second-pair templates remap to third/fourth/fifth (LPT-409; proved Jh9d/Q9s… and multiway 79o/K72). Combo draw (15 outs) and non-nut FD stay locked by existing fields — do not re-file those. Fixed-deal air/top-pair mislabels (LPT-395…397) are not remap fixtures until deals are honest.
- After LPT-409 pair-depth under `weakPair`, scan *set board-depth* under `isSet` / `HandClass.strongMade` — top vs middle vs bottom among unique board ranks (LPT-411; proved `99`/`987` top-set → middle/bottom and `77`/`7K2` middle→bottom). Ace/King top sets may stay locked by `broadwayCount` coincidence — do not treat that as fingerprint-complete. Underpair vs board-pair is already split by `distinctBoardPairingHoles` (probe `55`/`K72`) — do not file a separate underpair ticket; LPT-409 sentinel note covers pair-depth implementation. Sibling: `act-06-12-03-guided` “second pair good kicker” also breaks pair-depth (~155/200) while broadway kicker stays locked — fold into LPT-409, do not file a separate good-kicker ticket.
- After LPT-411 set-depth, tip scan found *no* dealt `streetLabel` trips / full-house / nut-straight claims; overpair stays `HandClass.topPair`-locked; top-two AK brick stays depth (0,1); OESD (outs=8) and combo (outs=15) stay locked; non-nut FD → nut reverse clean 200/200. Do not re-file those; only reopen if a new dealt class claim appears. Correct open High teachSpec bodies that conflate demos (LPT-324 cited `BbStackDepthDemo` for S7 `StackDepthPlansDemo` SHORT/DEEP/EFFECTIVE).
- After streetLabel / densify / prompt gutshot·pair·TPTK·missed-draw honesty sweeps (LPT-389…405), also scan catalog `choices[].grading.feedback` (and wave/bank duplicates) for class claims vs `teachSpec.fixedCards` / Dart spots — LPT-414 Air Nice! said “Gutshot-ish” for zero-outs 5h4h/Qc7d2s while SoftPulse `air` was correct. Feedback-only lies are still deal-honesty; update open variants tickets (LPT-384) so implementers do not densify dishonest Nice! strings.
- After LPT-413 SPR scaffolded `Stacks left 60` / pot ~60, sibling-scan other `potLabel` / coach densify SPR claims missing `stackLabel` — `act-04-05-01-unguided` claimed SPR 20 over default $200 into pot 12 (SPR ≈ 16.7; LPT-415 → `Stacks left 240`). Checkpoint already had `Stacks left 55`. Outcome-tile captions like deep-stack unguided `SPR ~12` (`deal.mode` `none`) are not felt stacks÷pot claims — skip. Update open High teachSpec bodies (LPT-180) in the same run.
- After streetLabel / SPR / feedback honesty sweeps, scan *NNbb depth chrome* on `LessonActionSpot` (`streetLabel` / `villainLine` / `feltStatusLine` matching `\d+bb`) against default lesson **100bb** stacks (`lesson_table_stage.dart`; CHIPS→BB `200 @ 1/2 = 100bb`). Missing `stackLabel` → seats stay `$200` while chrome names 180–250bb (LPT-417; siblings LPT-278/415). At `$1/$2`: 180bb=`$360`, 200bb=`$400`, 250bb=`$500` via `Stacks left N`. Update open High teachSpec bodies (LPT-225/228/280/216) in the same run; skip outcome-tile captions that never paint seat stacks.
- After sticky densify lands (LPT-416 / `act-04-06-01-*`), the *next* player-type label lesson Meet Calling Station (`act-04-06-02-*`) still has felt-first `_coachText` but is missing from `selectIdentifyDensifiedCoachLine` — frame falls through to catalog + "Tap the best answer." (LPT-420). File densify for Meet Station (and later observe-narrow / Meet Nit siblings) as a separate Medium; do not fold into teachSpec Highs. Chrome-validatable → `content,grokbot,lesson` from this agent (UI-agent historically filed densify as `ui-agent`).
- After Meet Calling Station densify is filed (LPT-420), continue the *player-type densify chain* as separate Mediums (do not fold into teachSpec Highs): Adjust Station cite `act-04-06-03-checkpoint` (LPT-421), Observe narrow `act-04-07-01-*` (LPT-422), Meet Nit `act-04-07-02-*` (LPT-423), then Adjust Nit cite / Observe wild / Meet Maniac / Adjust Maniac cite / Confidence — each has felt-first `_coachText` but is missing from `selectIdentifyDensifiedCoachLine`. Chrome-validatable → `content,grokbot,lesson`.
- After LPT-165 Section 3 jump teachSpec lands Done, re-diff catalog `teachSpec.deal.fixedCards` against Dart `resolveLessonActionSpot` / `LessonTableScene` before treating the lesson clean — `act-03-08-02-jump-mw` still authored `9h8d`/`AhKh7h` (FD) while Dart already deals true air `7s3d`/`AhKh9h` (LPT-391; filed LPT-425). File honesty High separately; then variants (LPT-426) on the four `fixed` jump steps (jump-table `mode` `none` skip). Wave `wave_two_live_competence.mjs` may still lag — keep in sync in the honesty/variants tickets.
- Player-type densify chain (after LPT-420…423): Adjust Nit cite `act-04-07-03-checkpoint` (LPT-427), Observe wild `act-04-08-01-*` (LPT-428), Meet Maniac `act-04-08-02-*` (LPT-429), Adjust Maniac cite `act-04-08-03-checkpoint` (LPT-430), Confidence `act-04-09-01-*` (LPT-431) — chain complete through Confidence. Do not fold into teachSpec Highs; Chrome-validatable → `content,grokbot,lesson`.
- After Confidence densify is filed (LPT-431), continue the *Section 6 player-type densify chain* as separate Mediums (do not fold into teachSpec Highs): Observe selective `act-06-11-01-*` (LPT-435), Meet TAG `act-06-11-02-*` (LPT-436), Adjust TAG cite `act-06-11-03-checkpoint` (LPT-437), Observe wide `act-06-12-01-*` (LPT-438), Meet LAG `act-06-12-02-*` (LPT-439) — then Adjust LAG avoid+cite `act-06-12-03-unguided/checkpoint`, Mix five cite `act-06-13-01-checkpoint`, five-type final `act-07-12-01-*`. Each has felt-first `_coachText` but is missing from `selectIdentifyDensifiedCoachLine`. Chrome-validatable → `content,grokbot,lesson`. After LPT-400 Done, LPT-174 scaffolded fixedCards must use `Kh7h2h3h` (not stale three-heart `Kh7h2c3h`).
- After Meet LAG densify (LPT-439), finish the *player-type densify chain* as separate Mediums: Adjust LAG avoid+cite `act-06-12-03-unguided/checkpoint` (LPT-441), Mix five cite `act-06-13-01-checkpoint` (LPT-442), five-type final `act-07-12-01-*` (LPT-443), plus Section 6 checkpoint `act-06-13-02-cp-*` (LPT-444). Player-type densify chain complete through final + S6 cp. Next densify walk: S7 plan lessons with felt-first `_coachText` still missing from `selectIdentifyDensifiedCoachLine` (`act-07-01-01-*` preflop-to-flop first). Do not fold into teachSpec Highs; Chrome-validatable → `content,grokbot,lesson`.
- After player-type densify chain completes (LPT-420…444), start the *Section 7 plan densify chain* as separate Mediums (do not fold into teachSpec Highs): Carry a preflop plan `act-07-01-01-*` (LPT-445), Map turn barrels `act-07-02-01-*` (LPT-446), Compose river select_identify `act-07-03-01-{scaffolded,unguided,checkpoint}` (LPT-447; guided is `poker_action_sizing` — skip), Change plans by pot type `act-07-04-01-*` (LPT-448). Next: HU vs multiway `act-07-05-01-*`, stack-depth `act-07-06-01-*`, same-cards checkpoint `act-07-07-01-checkpoint`, type-board checkpoint `act-07-08-01-checkpoint`, leak-review `act-07-09-01-*`, live-warmup `act-07-11-01-*` (five-type final already LPT-443). Each has felt-first `_coachText` but is missing from `selectIdentifyDensifiedCoachLine`. Chrome-validatable → `content,grokbot,lesson`.
- After pot-type densify (LPT-448), finish the *Section 7 plan densify chain* as separate Mediums: HU vs multiway `act-07-05-01-*` (LPT-449), stack-depth `act-07-06-01-*` (LPT-450), same-cards checkpoint `act-07-07-01-checkpoint` (LPT-451; guided/scaffolded/unguided `poker_action_sizing` skip), type-board checkpoint `act-07-08-01-checkpoint` (LPT-452; action steps skip), leak-review `act-07-09-01-*` (LPT-453), live-warmup `act-07-11-01-*` (LPT-454). S7 plan densify chain complete (LPT-445…454; five-type final already LPT-443). Do not fold into teachSpec Highs; Chrome-validatable → `content,grokbot,lesson`. Capstones (`act-07-10-0*`) are `authored_multi_step_hand` / SoftPulse-quiet — not this densify helper path.
- After S7 plan densify completes (LPT-445…454), start the *Section 5 outcome-tile densify chain* as separate Mediums (do not fold into teachSpec Highs): multiway-ranges `act-05-01-01-{guided,checkpoint}` (LPT-456; poker_action_sizing skip), deep-stack `act-05-02-01-{guided,unguided,checkpoint}` (LPT-457), implied checkpoint `act-05-03-01-checkpoint` (LPT-458), thin-value checkpoint `act-05-04-01-checkpoint` (LPT-459), lines `act-05-05-01-{guided,unguided,checkpoint}` (LPT-460), line-reading `act-05-06-01-{guided,unguided,checkpoint}` (LPT-461). Next: timing `act-05-07-01-*`, dynamics `act-05-08-01-{guided,scaffolded,checkpoint}`, discipline `act-05-09-01-*`, S5 checkpoint `act-05-09-02-cp-{multi,tell,stop}` — then Section 6 theory densify `act-06-01`…`act-06-10` (player-type densify already LPT-435…444). Each has felt-first `_coachText` but is missing from `selectIdentifyDensifiedCoachLine`. Chrome-validatable → `content,grokbot,lesson`.
- After S5 outcome-tile densify LPT-456…461 (multiway→line-reading), finish the *Section 5 densify chain* and start *Section 6 theory densify* as separate Mediums (do not fold into teachSpec Highs): timing `act-05-07-01-*` (LPT-464), dynamics `act-05-08-01-{guided,scaffolded,checkpoint}` (LPT-465; unguided poker_action_sizing skip), discipline `act-05-09-01-*` (LPT-466), S5 checkpoint `act-05-09-02-cp-{multi,tell,stop}` (LPT-467; value/catch skip), range `act-06-01-01-{guided,scaffolded,checkpoint}` (LPT-468; unguided skip), equity `act-06-02-01-*` (LPT-469). Next: capped `act-06-03-01-{guided,unguided,checkpoint}`, then polar/overbet/blockers/MDF/mix/3bet4bet/hard-fold (`act-06-04`…`act-06-10`). S5 densify chain complete (LPT-456…467). Chrome-validatable → `content,grokbot,lesson`.
- After S6 theory densify LPT-468…469 (range/equity), finish the *Section 6 theory densify chain* as separate Mediums (do not fold into teachSpec Highs): capped `act-06-03-01-{guided,unguided,checkpoint}` (LPT-470; scaffolded poker_action_sizing skip), polar `act-06-04-01-{guided,unguided,checkpoint}` (LPT-471), overbet `act-06-05-01-{guided,unguided,checkpoint}` (LPT-472), blockers `act-06-06-01-*` all four (LPT-473), MDF `act-06-07-01-{guided,unguided,checkpoint}` (LPT-474), mix `act-06-08-01-{scaffolded,unguided,checkpoint}` (LPT-475; guided skip), 3bet/4bet `act-06-09-01-{guided,unguided,checkpoint}` (LPT-476), hard-fold `act-06-10-01-{scaffolded,unguided,checkpoint}` (LPT-477; guided skip). S6 theory densify chain complete (LPT-468…477; player-type densify already LPT-435…444). Next densify walk: none left in S5/S6/S7 plan/outcome chains — prefer re-verify earliest High LPT-174 / SoftPulse explain LPT-353 / pressHints LPT-82, or scan new honesty/fingerprint gaps. Chrome-validatable → `content,grokbot,lesson`.
- After S6 theory densify completes (LPT-468…477), backfill *Section 3 early select_identify densify* skipped when the chain jumped sticky→player-types→S5/S6/S7: table-read `act-03-01-01-*` (LPT-478), flop-class `act-03-02-01-*` (LPT-479), turn `act-03-05-01-{guided,checkpoint}` (LPT-480; poker_action_sizing skip), plus Section 4 jump `act-04-10-02-jump-{range,spr,station,nit,maniac}` (LPT-481; 3bet/size skip). Next: S1/S2 felt-first select_identify still missing from `selectIdentifyDensifiedCoachLine` (stack-BB / habits / hand-families / pot-math). Do not fold into teachSpec Highs; Chrome-validatable → `content,grokbot,lesson`. LPT-462 SoftPulse gold ≠ densify Tap-the-best-answer (LPT-428 stays open).
- After S3 densify backfill (LPT-478…481), start the *S1/S2 felt-first densify chain* as separate Mediums (do not fold into teachSpec Highs): Effective stacks `act-02-05-01-*` (LPT-482), Live table habits `act-02-06-01-*` (LPT-483), Hand families `act-02-02-01-*` (LPT-484), How pots are won guided-fold-win `act-01-05-01-guided-fold-win` (LPT-485; unguided-pot `kOpenPotActivityId` skip; scaffolded/checkpoint already Tap in catalog), Acting order `act-02-01-02-{unguided-wait,checkpoint-full}` (LPT-486). Next: Position labels guided-btn authored coachMedia footer `act-02-01-01-guided-btn`, Your two cards / Button guided authored footers `act-01-01-01-guided-find-holes` / `act-01-01-03-guided-button`, baseline habit `act-02-07-01-checkpoint-habit`, S2 jump-pos `act-02-07-02-jump-pos`. Authored `coachMedia` without tap/pick still appends “Tap the best answer.” via `resolveLessonCoachPrompt` before densify — register those ids too. Chrome-validatable → `content,grokbot,lesson`.
- After S1/S2 densify LPT-482…486, finish true frame-append leftovers: baseline habit `act-02-07-01-checkpoint-habit` (LPT-487) + jump-pos `act-02-07-02-jump-pos` (LPT-488; family/stack already LPT-221). Do **not** file densify for `act-02-01-01-guided-btn` / `act-01-01-01-guided-find-holes` / `act-01-01-03-guided-button` when catalog `prompt` already contains `Tap` — `coachMedia` kind `hint` is skipped by `primaryCoachLine`, so frame uses the Tap prompt (no “Tap the best answer.” append). S1/S2 densify chain complete after LPT-487/488. Next: SoftPulse explain LPT-353 OR pressHints LPT-82 OR re-verify earliest High LPT-174 after GrokBot.
- After Meet Maniac SoftPulse one-gold lands Done (LPT-489), continue the *player-type SoftPulse guideRegion chain* as separate Highs with `content,ui-agent,lesson` (iPhone SoftPulse proof — not grokbot densify): Meet TAG unguided `act-06-11-02-unguided` / `_buildMeetTagVsManiacOutcomes` (LPT-491), Meet LAG unguided `act-06-12-02-unguided` / `_buildMeetLagVsNitOutcomes` (LPT-492), Observe wide unguided `act-06-12-01-unguided` / `_buildLagObserveSampleOutcomes` (LPT-493), Observe selective unguided `act-06-11-01-unguided` / `_buildSelectiveSampleOutcomes` (LPT-494), plus Confidence all four `act-04-09-01-*` builders (LPT-495; also strip permanent `AppColors.gold` / `_PotChipDot(gold:true)` — LPT-183 class). `_buildOutcomePhases` null `guideRegion` SoftPulses every phase while `invitePulse`. Do not fold into densify Mediums (LPT-435/436/438/439/431) or teachSpec Highs. Next SoftPulse-one-gold walk: other null-guideRegion SoftPulse-on outcome builders (many unguided “No SoftPulse” comments still need guideRegion for Hint-after SoftPulse).
- After LPT-174 Plan beyond the flop teachSpec lands Done (#1801), file Medium `deal.variants` for the three `fixed` steps (guided/scaffolded/unguided) — LPT-496. Explain/checkpoint stay `deal.mode` `none` (skip variants). Scaffolded fixedCards must stay LPT-400 four-heart `Kh7h2h3h`. Earliest open High teachSpec becomes LPT-177 Size with a message.
- After player-type SoftPulse one-gold LPT-491…495, continue the *S6 theory SoftPulse guideRegion chain* as separate Highs with `content,ui-agent,lesson` (iPhone SoftPulse proof — not grokbot densify): overbet unguided `act-06-05-01-unguided` / `_buildOverbetAvoidOutcomes` (LPT-497), blockers unguided `act-06-06-01-unguided` / `_buildBlockersTweakOutcomes` (LPT-498), MDF unguided `act-06-07-01-unguided` / `_buildDefendIntuitionOutcomes` (LPT-499), mix unguided `act-06-08-01-unguided` / `_buildMixReasonOutcomes` (LPT-500), 3-bet/4-bet unguided `act-06-09-01-unguided` / `_buildThreeBetEgoOutcomes` (LPT-501). Next SoftPulse-one-gold: hard-fold unguided `_buildHardFoldEgoOutcomes` (LPT-283 companion), Adjust LAG avoid `_buildLagAdjustAvoidOutcomes`, Size with a message `_buildSizingUnguidedOutcomes` (three tiles), then S7 plan unguided (`preflopFlop`/`turnMap`/…). `_buildOutcomePhases` null `guideRegion` SoftPulses every phase while `invitePulse`. Do not fold into densify Mediums (LPT-472…477) or teachSpec Highs.
- After S6 theory SoftPulse guideRegion LPT-497…501, finish hard-fold/LAG-adjust/sizing + *S7 plan SoftPulse guideRegion chain* as separate Highs with `content,ui-agent,lesson` (iPhone SoftPulse proof — not grokbot densify): hardFoldEgo `act-06-10-01-unguided` (LPT-502), lagAdjustAvoid `act-06-12-03-unguided` (LPT-503), sizingUnguided `act-04-04-01-unguided` three tiles + permanent gold Soft band (LPT-504), preflopFlop `act-07-01-01-unguided` (LPT-505), turnMap `act-07-02-01-unguided` (LPT-506), riverComp `act-07-03-01-unguided` (LPT-507), potType `act-07-04-01-unguided` (LPT-508), huMw `act-07-05-01-unguided` (LPT-509), stackDepth `act-07-06-01-unguided` (LPT-510), leakReview `act-07-09-01-unguided` (LPT-511), liveWarmup `act-07-11-01-unguided` (LPT-512). Skip same-cards/type-board unguided (`poker_action_sizing`) and capstones (`authored_multi_step_hand`). S7 plan SoftPulse unguided chain complete. Next SoftPulse-one-gold: remaining null-`guideRegion` SoftPulse-on densify builders that lack the unguided “No SoftPulse” comment (S5 timing/dynamics/discipline/multiway/deep/lines/line-read guided+checkpoint tiles that SoftPulse every phase). Do not fold into densify Mediums or teachSpec Highs.
- After S7 plan SoftPulse guideRegion LPT-505…512, file the *S5 densify SoftPulse guideRegion chain* as separate Highs with `content,ui-agent,lesson` (iPhone SoftPulse proof — not grokbot densify): multiway guided+checkpoint `act-05-01-01-{guided,checkpoint}` (LPT-513), deep guided/unguided/checkpoint `act-05-02-01-{guided,unguided,checkpoint}` (LPT-514), implied checkpoint `act-05-03-01-checkpoint` (LPT-515), thin-value checkpoint `act-05-04-01-checkpoint` (LPT-516), lines guided/unguided/checkpoint `act-05-05-01-{guided,unguided,checkpoint}` (LPT-517), line-reading guided/unguided/checkpoint `act-05-06-01-{guided,unguided,checkpoint}` (LPT-518), timing all four `act-05-07-01-*` (LPT-519), dynamics guided/scaffolded/checkpoint `act-05-08-01-{guided,scaffolded,checkpoint}` (LPT-520; unguided poker_action_sizing skip), discipline all four `act-05-09-01-*` (LPT-521). Unlike the unguided-only S6/S7 SoftPulse chain, these S5 densify builders SoftPulse *every* stage (guided on-by-default too) because `guideRegion` is null — also strip permanent `AppColors.gold` on correct tiles (LPT-495 class). S5 checkpoint SoftPulse already has guideRegion — skip. Next SoftPulse-one-gold: S6 theory densify builders still missing guideRegion — rangeAdv `act-06-01-01-{guided,scaffolded,checkpoint}` + equity `act-06-02-01-*` all four (capped/polar builders already pass guideRegion; unguided Overbet/Blockers/MDF/mix/3bet/hardFold already LPT-497…502). Do not fold into densify Mediums (LPT-456…469) or teachSpec Highs.
- After LPT-177 Size with a message teachSpec lands Done (#1805), file Medium `deal.variants` for the three `fixed` steps (guided/scaffolded/checkpoint) — LPT-522. Explain/unguided stay `deal.mode` `none` (skip variants). Scaffolded fixedCards must stay LPT-398 honest `9h8h`/`Kh7h2c3dAs`. Earliest open High teachSpec becomes LPT-180 SPR.
- After S5 SoftPulse guideRegion LPT-513…521, finish *S6 theory densify SoftPulse* + *leftover null-guideRegion densify builders* as separate Highs with `content,ui-agent,lesson`: rangeAdv `act-06-01-01-{guided,scaffolded,checkpoint}` (LPT-523), equity `act-06-02-01-*` all four (LPT-524), then pots `act-01-05-01-{unguided-pot,checkpoint-side}` (LPT-525), drawPrice `act-03-03-01-unguided` (LPT-526), hand-family ug/cp (LPT-527), jump-family (LPT-528), ranges ug/cp (LPT-529), plan checkpoint (LPT-530), Station/Nit/Maniac cite (LPT-531…533), S4 jump-range (LPT-534). Null-guideRegion SoftPulse-on densify builders fully ticketed — next SoftPulse walk only if a new `_build*Outcomes` ships without `guideRegion`. Do not fold into densify Mediums or teachSpec Highs.
- After LPT-180 SPR teachSpec lands Done (#1806), file Medium `deal.variants` for the three `fixed` steps (scaffolded/unguided/checkpoint) — LPT-535. Explain/guided stay `deal.mode` `none` (skip variants). Keep LPT-415 Stacks left 240 densify open (teachSpec does not author stack chrome). Earliest open High teachSpec becomes LPT-184 Observe sticky callers.
- After SoftPulse null-guideRegion densify builders are fully ticketed (LPT-491…534), re-walk builders that already pass guideRegion for leftover permanent answer tips (`_PotChipDot(..., gold: true)` / correct-tile `AppColors.gold`) — LPT-183 class. Sticky guided HI + scaffolded Sticky icon (LPT-536), Meet Station checkpoint LO (LPT-537), observe-narrow guided Narrow (LPT-538), SPR guided SPR 4 (LPT-539), outs call-price Call 10 + header (LPT-540; guideRegion already present — do not re-file as missing guideRegion), S3 jump-table Pot·effective (LPT-541). Skip atmospheric header strips (BB-convert / SPR Stack÷Pot / 3-bet depthChip) unless they tip the same answer id. Do not fold into densify Mediums or teachSpec Highs — `content,ui-agent,lesson`. After LPT-184/LPT-187 Done, skip `deal.variants` on observation/player-type `deal.mode` `none` lessons; pressHints stay LPT-185/LPT-188; Still-a-list clear is docs-only inside a nearby change.
- After LPT-187 Meet Calling Station teachSpec lands Done (#1810), skip `deal.variants` (`deal.mode` `none` player-type tiles). Keep LPT-188 pressHints and LPT-537 checkpoint permanent-gold open. Earliest open High teachSpec becomes LPT-190 Adjust versus Calling Station. Clear design-record Still-a-list "label quizzes" in a nearby docs touch (do not file Still-a-list rebuild).
- After PotChipDot permanent-gold batch (LPT-536…541), re-walk builders that already pass `guideRegion` for leftover correct-tile `AppColors.gold` *icons* (not only `_PotChipDot gold: true`) — Meet Station guided/scaffolded/unguided (LPT-542; checkpoint LO already LPT-537), Meet Nit (LPT-543), Observe wild (LPT-544), Meet Maniac (LPT-545), Ranges guided/scaffolded (LPT-546; ug/cp SoftPulse still LPT-529), habits watch/verbal (LPT-547), pots fold-win Take pot (LPT-548). Expand LPT-538 to strip observe-narrow Strong-heat/Wait/bundle gold icons; comment LPT-525 to strip Side pot `M` chip with guideRegion. Skip atmospheric header strips (BB-convert Chips / SPR Stack÷Pot / 3-bet depthChip). `content,ui-agent,lesson`. Next: remaining guideRegion+AppColors.gold densify builders (turnScare/riverJob/multiwayObserve/leakSeat/jumpFlop/jumpLeak…).
- After LPT-190 Adjust Station teachSpec lands Done (#1813), file Medium `deal.variants` for the three `fixed` steps (guided/scaffolded/unguided) — LPT-549. Explain/checkpoint stay `deal.mode` `none` (skip variants). Scaffolded fixedCards must stay LPT-399 honest `8h7h`/`Kh9h2c3d5s`. After LPT-193 Observe narrow Done (#1814), skip `deal.variants` (`deal.mode` `none` observation tiles). Earliest open High teachSpec becomes LPT-196 Meet the Nit.
- After player-type / sticky / ranges / habits / pots permanent-gold icons (LPT-536…548), continue the *guideRegion+AppColors.gold* densify chain as separate Highs with `content,ui-agent,lesson`: turnScarePlan `act-03-05-01-checkpoint` (LPT-550), riverJob `act-03-06-01-checkpoint` (LPT-551), multiwayObserve `act-03-07-01-checkpoint` (LPT-552), leakSeatNote `act-03-08-01-checkpoint` (LPT-553), jumpFlopClass `act-03-08-02-jump-class` (LPT-554), jumpLeakPrice `act-03-08-02-jump-leak` (LPT-555). Skip BbConvert Chips header gold and ThreeBetCommit depthChip header gold (atmospheric — answer chips already non-gold). Do not fold into densify Mediums or teachSpec Highs.
- After LPT-200 Adjust versus Nit teachSpec lands Done (#1817), file Medium `deal.variants` for the three `fixed` steps (guided/scaffolded/unguided) — LPT-556. Explain/checkpoint stay `deal.mode` `none` (skip variants). Scaffolded middle-pair fixedCards must stay honest under LPT-409 pair-depth (pair the middle of three unique board ranks). Earliest open High teachSpec becomes LPT-203 Observe wild aggressors. After LPT-196 Meet Nit Done (#1815), skip `deal.variants` (`deal.mode` `none` player-type tiles); keep LPT-197 pressHints and LPT-423 densify open. guideRegion+AppColors.gold densify chain exhausted except atmospheric BbConvert Chips / ThreeBetCommit depthChip headers (skip).
- After SoftPulse guideRegion / permanent-gold densify chains are exhausted, re-scan `_guidedPulseTargetId` for *scaffolded non-unguided* `poker_action_sizing` steps that already author `teachSpec.cues` kind `soft_pulse` but are missing from the SoftPulse map — first-choice Hint fallback is not a passing authored map (Open/fold scaffolded-qq → LPT-557). Do not batch-file every unguided SoftPulse-map lag (known intentional pattern until teachSpec lands SoftPulse wiring).
- After Done teachSpec lands in `course.json`, diff wave helpers (`wave_one_foundations.mjs` / `wave_two_live_competence.mjs` / `wave_three_advanced_play.mjs`) for missing `teachSpec` blocks — pilot Your two cards still had full course teachSpec with zero wave_one teachSpec (LPT-558). Prefer `course.json` as truth; file wave-sync separately from variants (LPT-366) so a wave edit cannot wipe the pilot.
- Tip SoftPulse ui-agent Done (LPT-497/498 class) does **not** clear teachSpec Highs — re-verify LPT-203 Observe wild (still all five `act-04-08-01-*` missing) before filing siblings. Keep skipping atmospheric BbConvert Chips / ThreeBetCommit `100bb` depthChip header gold (answer chips already non-gold; LPT-536…555 exhaust answer-tip chain).
- Densify Mediums: audit `selectIdentifyDensifiedCoachLine` in `rex_coach_line.dart` only — inline `_coachText` speech in `select_identify_activity.dart` does not clear LPT-428-class framed "Tap the best answer." footer under `LessonFrameScope`.
- After LPT-203 Observe wild teachSpec lands Done (#1825), skip `deal.variants` (`deal.mode` `none` observation tiles). Keep LPT-204 pressHints, LPT-428 densify, LPT-544 permanent-gold icons, LPT-205 curriculum split. Earliest open High teachSpec becomes LPT-206 Meet the Maniac. Mid-run tip can land while re-verify comments are in flight — always `git fetch` + re-check earliest High before ending as `clean`.
- After LPT-210 Adjust versus Maniac teachSpec lands Done (#1827), file Medium `deal.variants` for the three `fixed` steps (guided/scaffolded/unguided) — LPT-559. Explain/checkpoint stay `deal.mode` `none` (skip variants). Keep LPT-211 pressHints open. FixedCards must stay TPWK-honest Ah9d/`As7c2dTh3c` (9<T) and top-two AhKd/`AsKc2d9h3c`. After LPT-206 Meet Maniac Done (#1826), skip `deal.variants` (`deal.mode` `none` player-type tiles). Earliest open High teachSpec becomes LPT-213 Confidence and samples.
- After SoftPulse explain `teachSpec` lands Done, file Medium `explainGrading` Nice! short ladder when idle ask would repeat (LPT-490 / LPT-463 class) — do not treat deal/cues Done as Nice!-complete. Confidence LPT-560 (`Observe → Samples → Showdowns.`); Adjust Maniac LPT-561 (`Wider → Hang → Ego.`). Chrome-validatable → `content,grokbot,lesson`. Walk one explain per run after its teachSpec Done (many SoftPulse explains still lack `explainGrading` — do not batch-file the whole backlog in one pass). Skip `deal.variants` on observation/confidence `deal.mode` `none` lessons (LPT-213).
- After SoftPulse explain Nice! LPT-560/561 (Confidence / Adjust Maniac), continue the *S4 SoftPulse explain Nice! chain* one Medium per run (do not batch): Adjust Nit `act-04-07-03-explain` STEAL/CREDIT/EXPLODE (LPT-562), then Meet Nit `act-04-07-02-explain` NIT/NARROW/RESPECT, Observe narrow `act-04-07-01-explain` RARE/ENTER/MEAN IT, Adjust Station `act-04-06-03-explain` VALUE/BLUFFS/CITE, Meet Station `act-04-06-02-explain` STATION/HIGH/LOW, Observe sticky `act-04-06-01-explain` ENTERS/CALLS/FOLDS — then SPR/sizing/continuation/3-bet/ranges explains still missing `explainGrading`. Do not fold into teachSpec Highs or pressHints; Chrome-validatable → `content,grokbot,lesson`. Skip `deal.variants` on observation/player-type `deal.mode` `none` lessons. After LPT-425 Done, jump-mw fixedCards are honest `7s3d`/`AhKh9h` — do not re-file that honesty gap.
- After Adjust Nit Nice! LPT-562, continue S4 SoftPulse explain Nice! one Medium per run: Meet Nit `act-04-07-02-explain` NIT/NARROW/RESPECT (LPT-563), then Observe narrow `act-04-07-01-explain` RARE/ENTER/MEAN IT, Adjust Station `act-04-06-03-explain` VALUE/BLUFFS/CITE, Meet Station `act-04-06-02-explain` STATION/HIGH/LOW, Observe sticky `act-04-06-01-explain` ENTERS/CALLS/FOLDS — then SPR/sizing/continuation/3-bet/ranges. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After Meet Nit Nice! LPT-563, continue S4 SoftPulse explain Nice! one Medium per run: Observe narrow `act-04-07-01-explain` RARE/ENTER/MEAN IT (LPT-564), then Adjust Station `act-04-06-03-explain` VALUE/BLUFFS/CITE, Meet Station `act-04-06-02-explain` STATION/HIGH/LOW, Observe sticky `act-04-06-01-explain` ENTERS/CALLS/FOLDS — then SPR/sizing/continuation/3-bet/ranges. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After Observe narrow Nice! LPT-564, continue S4 SoftPulse explain Nice! one Medium per run: Adjust Station `act-04-06-03-explain` VALUE/BLUFFS/CITE (LPT-565), then Meet Station `act-04-06-02-explain` STATION/HIGH/LOW, Observe sticky `act-04-06-01-explain` ENTERS/CALLS/FOLDS — then SPR/sizing/continuation/3-bet/ranges. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After Adjust Station Nice! LPT-565, continue S4 SoftPulse explain Nice! one Medium per run: Meet Station `act-04-06-02-explain` STATION/HIGH/LOW (LPT-566), then Observe sticky `act-04-06-01-explain` ENTERS/CALLS/FOLDS — then SPR/sizing/continuation/3-bet/ranges. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After Meet Station Nice! LPT-566, continue S4 SoftPulse explain Nice! one Medium per run: Observe sticky `act-04-06-01-explain` ENTERS/CALLS/FOLDS (LPT-567), then SPR `act-04-05-01-explain` SPR/LOW/HIGH, sizing `act-04-04-01-explain` VALUE/PRESSURE/SIZE, continuation `act-04-03-01-explain` FLOP/TURN/RIVER, 3-bet `act-04-02-01-explain` 3-BET/RANGES/SQUEEZE, ranges `act-04-01-01-explain` ONE HAND/RANGE/UPDATE. S4 player-type/observe Nice! chain complete through sticky (LPT-560…567). Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`. LPT-82 Done — earliest pressHints lead clears; prefer next open pressHints (LPT-185/188/191/…) or LPT-216 teachSpec re-verify.
- After Observe sticky Nice! LPT-567, continue S4 SoftPulse explain Nice! one Medium per run: SPR `act-04-05-01-explain` SPR/LOW/HIGH (LPT-568), then sizing `act-04-04-01-explain` VALUE/PRESSURE/SIZE, continuation `act-04-03-01-explain` FLOP/TURN/RIVER, 3-bet `act-04-02-01-explain` 3-BET/RANGES/SQUEEZE, ranges `act-04-01-01-explain` ONE HAND/RANGE/UPDATE. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`. LPT-82 Done — earliest pressHints lead clears; prefer next open pressHints (LPT-185/188/191/…) or LPT-216 teachSpec re-verify.
- After SPR Nice! LPT-568, continue S4 SoftPulse explain Nice! one Medium per run: sizing `act-04-04-01-explain` VALUE/PRESSURE/SIZE (LPT-569), then continuation `act-04-03-01-explain` FLOP/TURN/RIVER, 3-bet `act-04-02-01-explain` 3-BET/RANGES/SQUEEZE, ranges `act-04-01-01-explain` ONE HAND/RANGE/UPDATE. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After Size Nice! LPT-569, continue S4 SoftPulse explain Nice! one Medium per run: continuation `act-04-03-01-explain` FLOP/TURN/RIVER (LPT-570), then 3-bet `act-04-02-01-explain` 3-BET/RANGES/SQUEEZE, ranges `act-04-01-01-explain` ONE HAND/RANGE/UPDATE. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After SoftPulse explain teachSpec lands Done, file Medium Nice! short ladder in the *same* next content-agent pass (LPT-353 → LPT-571 Suits `Hearts → Diamonds → Clubs → Spades.`) — do not let the S4 Nice! walk starve freshly Done Section 1 SoftPulse explains. Prefer freshly Done teachSpec Nice! over advancing the S4 theory chain when both are available. Next S4 theory Nice! after LPT-569 sizing: continuation `act-04-03-01-explain` FLOP/TURN/RIVER, then 3-bet / ranges. Four-press explains (suits/habits) still use one short ladder string.
- After Plan beyond the flop Nice! LPT-570, continue S4 SoftPulse explain Nice! one Medium per run: Navigate 3-bet pots `act-04-02-01-explain` 3-BET/RANGES/SQUEEZE (LPT-572), then ranges `act-04-01-01-explain` ONE HAND/RANGE/UPDATE. S4 theory Nice! chain (after sticky→SPR→sizing→continuation) advances to 3-bet. Prefer freshly Done SoftPulse-explain teachSpec Nice! (LPT-353→571 class) over advancing this chain when both are available. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After Navigate 3-bet Nice! LPT-572, finish S4 SoftPulse explain Nice! one Medium per run: Think in ranges `act-04-01-01-explain` ONE HAND/RANGE/UPDATE (LPT-573). S4 SoftPulse explain Nice! chain complete (player-type/observe LPT-560…567 + theory sticky→SPR→sizing→continuation→3-bet→ranges LPT-567…573). Next SoftPulse explain Nice!: S3 table-read `act-03-01-01-explain` POT/STACKS/BUTTON/WHO ACTS (teachSpec already present) — then flop-class/outs/flop-lines/turn/river/multiway/leak explains with cues; skip SoftPulse-explain teachSpec still-open LPT-354…365 until Done. Prefer freshly Done SoftPulse-explain teachSpec Nice! (LPT-353→571 class) over advancing S3 when both available. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After S4 SoftPulse explain Nice! completes through ranges (LPT-560…573), continue *Section 1 SoftPulse explain Nice!* one Medium per run: Suits LPT-571, Button `act-01-01-03-explain-button` D/SB/BB (LPT-574), then pilot hole-cards `act-01-01-01-explain-hole-cards` (single cue `hero_holes` — still author short Nice! line, e.g. "Your two cards."), then S3 table-read/flop-class/outs/… explains that already have teachSpec+cues. Skip filing Nice! for SoftPulse explains that still lack teachSpec (LPT-354… open) — wait until teachSpec Done. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After Think in ranges Nice! LPT-573, start S3 SoftPulse explain Nice! one Medium per run: Read the table first `act-03-01-01-explain` POT/STACKS/BUTTON/WHO ACTS (LPT-575), then flop-class `act-03-02-01-explain` MADE/DRAW/SDV/AIR, outs `act-03-03-01-explain` CLEAN/DIRTY/PRICE, flop-lines `act-03-04-01-explain` VALUE/C-BET/CHECK/CALL/FOLD/RAISE, turn `act-03-05-01-explain` BRICK/CHANGE/BARREL/DELAY, river `act-03-06-01-explain` VALUE/BLUFF/CATCH/FOLD, multiway `act-03-07-01-explain` STRONGER/FEWER/NUTS, leak `act-03-08-01-explain` TOP PAIR/PRICES/PASSIVE/CROWDS. Concurrent pass filed Button Nice! LPT-574 (`act-01-01-03-explain-button`); Hand ranks explain already has explainGrading — skip. Skip SoftPulse-explain teachSpec still-open LPT-354…365 until Done. Prefer freshly Done SoftPulse-explain teachSpec Nice! (LPT-353→571 class) or Section 1 hole-cards Nice! lead over advancing S3 when both available. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After Read the table Nice! LPT-575 + Button Nice! LPT-574, continue *Section 1 SoftPulse explain Nice!* one Medium per run: pilot hole-cards `act-01-01-01-explain-hole-cards` single cue `hero_holes` (LPT-576 — short line `"Your two cards."`, not a multi-arrow ladder). Hand ranks explain already has explainGrading — skip. Next SoftPulse explain Nice!: S3 flop-class `act-03-02-01-explain` MADE/DRAW/SDV/AIR, then outs/flop-lines/turn/river/multiway/leak. Skip SoftPulse-explain teachSpec still-open LPT-354…365 until Done. Prefer freshly Done SoftPulse-explain teachSpec Nice! over advancing S3 when both available. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After Your two cards Nice! LPT-576 + Read the table Nice! LPT-575, continue *Section 3 SoftPulse explain Nice!* one Medium per run: flop-class `act-03-02-01-explain` MADE/DRAW/SDV/AIR (LPT-577), then outs `act-03-03-01-explain` CLEAN/DIRTY/PRICE, flop-lines `act-03-04-01-explain` VALUE/C-BET/CHECK/CALL/FOLD/RAISE, turn `act-03-05-01-explain` BRICK/CHANGE/BARREL/DELAY, river `act-03-06-01-explain` VALUE/BLUFF/CATCH/FOLD, multiway `act-03-07-01-explain` STRONGER/FEWER/NUTS, leak `act-03-08-01-explain` TOP PAIR/PRICES/PASSIVE/CROWDS. Skip SoftPulse-explain teachSpec still-open LPT-354…365 until Done. Prefer freshly Done SoftPulse-explain teachSpec Nice! over advancing S3 when both available. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After S1 Nice! LPT-574/576 + S3 table-read/flop-class LPT-575/577, continue *Section 3 SoftPulse explain Nice!* one Medium per run: outs `act-03-03-01-explain` CLEAN/DIRTY/PRICE (LPT-578), then flop-lines `act-03-04-01-explain` (six cues VALUE/C-BET/CHECK/CALL/FOLD/RAISE — still one short ladder string), turn `act-03-05-01-explain` BRICK/CHANGE/BARREL/DELAY, river `act-03-06-01-explain` VALUE/BLUFF/CATCH/FOLD, multiway `act-03-07-01-explain`, leak `act-03-08-01-explain`. When LPT-216 flips In Progress→Done, re-fetch tip before filing Same-hand Nice! / variants / pressHints companions. Do not fold into teachSpec Highs; `content,grokbot,lesson`.
- After flop-class Nice! LPT-577 + outs Nice! LPT-578, continue *Section 3 SoftPulse explain Nice!* one Medium per run: flop-lines `act-03-04-01-explain` VALUE/C-BET/CHECK/CALL/FOLD/RAISE (LPT-579), then turn `act-03-05-01-explain` BRICK/CHANGE/BARREL/DELAY, river `act-03-06-01-explain` VALUE/BLUFF/CATCH/FOLD, multiway `act-03-07-01-explain` STRONGER/FEWER/NUTS, leak `act-03-08-01-explain` TOP PAIR/PRICES/PASSIVE/CROWDS. Skip SoftPulse-explain teachSpec still-open LPT-354…365 until Done. Prefer freshly Done SoftPulse-explain teachSpec Nice! over advancing S3 when both available. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After flop-lines Nice! LPT-579 + turn Nice! LPT-580, continue *Section 3 SoftPulse explain Nice!* one Medium per run: river `act-03-06-01-explain` VALUE/BLUFF/CATCH/FOLD, then multiway `act-03-07-01-explain` STRONGER/FEWER/NUTS, leak `act-03-08-01-explain` TOP PAIR/PRICES/PASSIVE/CROWDS. Skip SoftPulse-explain teachSpec still-open LPT-354…365 until Done. Prefer freshly Done SoftPulse-explain teachSpec Nice! over advancing S3 when both available. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After turn Nice! LPT-580 + river Nice! LPT-581, continue *Section 3 SoftPulse explain Nice!* one Medium per run: multiway `act-03-07-01-explain` STRONGER/FEWER/NUTS, then leak `act-03-08-01-explain` TOP PAIR/PRICES/PASSIVE/CROWDS. Skip SoftPulse-explain teachSpec still-open LPT-354…365 until Done. Prefer freshly Done SoftPulse-explain teachSpec Nice! over advancing S3 when both available. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After S3 SoftPulse explain Nice! LPT-578…581 (outs→river), continue: multiway `act-03-07-01-explain` STRONGER/FEWER/NUTS (LPT-582), then leak `act-03-08-01-explain` TOP PAIR/PRICES/PASSIVE/CROWDS. S3 SoftPulse explain Nice! chain completes after leak. Then prefer re-verify LPT-216 Done companions (Nice!/variants/pressHints) or S2 SoftPulse explain teachSpec opens (LPT-359…) — do not file Nice! until those teachSpecs land. `content,grokbot,lesson`.
- After multiway Nice! LPT-582 + river Nice! LPT-581, finish *Section 3 SoftPulse explain Nice!* one Medium per run: leak `act-03-08-01-explain` TOP PAIR/PRICES/PASSIVE/CROWDS (LPT-583). S3 SoftPulse explain Nice! chain complete (LPT-575…583). SoftPulse coach_dialogue explains with cues still missing `explainGrading` are fully ticketed for S1/S3/S4 (24 open gaps; 5 landed). Skip Nice! for SoftPulse-explain teachSpec still-open LPT-354…365 and for S5+ explains that still lack teachSpec (listed on High LPT-222+). Prefer freshly Done SoftPulse-explain teachSpec Nice! or re-verify earliest High LPT-216 / pressHints / honesty Highs next. Do not fold into teachSpec Highs or pressHints; `content,grokbot,lesson`.
- After LPT-216 Same hand teachSpec lands Done (#1845), file Medium companions in the *same* next content-agent pass: SoftPulse explain Nice! `act-04-10-01-explain` CARDS/SEATS/EVIDENCE (LPT-584) + `deal.variants` for guided/scaffolded/unguided fixed second-pair rivers (LPT-585). Keep LPT-217 pressHints open; skip variants on explain (`deal.mode` none) and do not require lab variants on checkpoint unless separately approved. Earliest open High teachSpec becomes LPT-219 Section 4 jump. LPT-417 200bb chrome stays separate. Prefer freshly Done SoftPulse-explain teachSpec Nice! (LPT-354…365 when Done) over advancing older Nice! backlog when both available. `content,grokbot,lesson`.
- After LPT-216 Same hand companions (LPT-584 Nice! / LPT-585 variants) are filed, earliest High teachSpec is LPT-219 Section 4 jump. On re-verify: jump-station/nit/maniac SoftPulse builders already pass `guideRegion` — do **not** re-file SoftPulse-one-gold for those; only jump-range remains LPT-534. SoftPulse dock map already wires `j4-3bet`/`j4-10` before teachSpec — when authoring LPT-219 use assessment-safe cue kind `none` (or non-spoiling), do not treat the map as Done contract. jump-spr shares `_buildSprGuidedOutcomes` with SPR guided (LPT-539 permanent-gold SPR 4). SoftPulse tip landings (e.g. #1846 pot-type) do not clear teachSpec Highs — re-fetch tip and re-check all seven `act-04-10-02-*` before ending as Done. SoftPulse-explain teachSpec LPT-354…365 still open — skip Nice! until Done; prefer pressHints LPT-185 or honesty Highs LPT-393/395 when LPT-219 stays open.
- After LPT-219 Section 4 jump re-verify stays open on tip, SoftPulse explain Nice! for S1/S3/S4 is fully ticketed (LPT-560…584) and SoftPulse-explain teachSpec LPT-354…365 is still To Do — do **not** invent Nice! for S5+ / wave_three explains that still lack teachSpec (listed on High LPT-222+ / LPT-321). Ui-agent SoftPulse one-gold Dones (e.g. LPT-509 HU/mw) do not clear teachSpec Highs and do not unlock Nice!. Prefer comment-refresh earliest High LPT-219 + honesty Highs LPT-393/394/395 + pressHints LPT-185; after LPT-389 Done, jump-leak honesty is closed — cite that when refreshing LPT-394. `content,grokbot,lesson`.
- After wave_one gains teachSpec on most S1/S2 rows, tip-scan course.json vs `wave_one_foundations.mjs` for leftover gaps — pilot Your two cards stays LPT-558; additionally toy-hand + baseline `unguided-lab` (`act-01-06-01-unguided-lab` / `act-02-07-01-unguided-lab`) can lag while 80+ siblings already sync (LPT-586). Do not fold lab wave-sync into LPT-558 or variants/pressHints tickets. Prefer `course.json` as truth.
- After LPT-219 Section 4 jump teachSpec lands Done (#1850): Still-a-list already `—`; cue kind `none` on all seven (assessment); file Medium `deal.variants` only for the two `fixed` docks jump-3bet/size (LPT-587) — skip outcome/math/player-type `deal.mode` `none` jumps. SoftPulse map already has `j4-3bet`/`j4-10` while cues stay kind `none` (do not re-file SoftPulse map as missing for jump_test). Earliest open High teachSpec becomes LPT-222 Build multiway ranges.
- Mid-run `git fetch` + ff before closing/filing — GrokBot can land the open High teachSpec between the start SHA and the comment (LPT-219/#1850 advanced tip 81d8b346→f3f3678a while this agent was still on the old tip). Do not trust the SHA from the start of the walk alone (tightens the existing re-fetch rule).
- Course↔wave teachSpec lag scans must bound each activity to the next activity-id span — a long lookahead window false-positives on the *next* lesson’s teachSpec (unguided-mix looked “synced” until span-accurate scan; LPT-586 labs were truly synced, pilot five were not).
- After interactive `poker_action_sizing` teachSpec lands, diff `LessonTableScene` boards for the same activity id against `teachSpec.fixedCards` / `LessonActionSpot` — Spot paints the felt today, but Scene can lag a street (SPR checkpoint flop-only vs turn `9h` → LPT-588). File Medium even when Spot is honest.
- After teachSpec SoftPulse `cues` kind `soft_pulse` land on unguided `poker_action_sizing` steps, SoftPulse-map lag is no longer an intentional skip for that activity (Same hand unguided wired `m-call` with LPT-216). File one Medium SoftPulse map per run via `_guidedPulseTargetId` — start Fold/check/call unguided `call-5` (LPT-589), then `act-01-03-02-unguided-allin` → `shove-12`, then Open/fold unguided-btn `open-k9s`, then S3/S4 unguided docks still missing map while cues exist. Keep LPT-557 as the only *non-unguided* map gap. Chrome-validatable → `content,grokbot,lesson`. Do not batch-file the whole unguided backlog in one pass.
- After S1/S2 densify tickets for habits/families/pots/acting/effective/full-ring/baseline-jump, tip-scan `selectIdentifyDensifiedCoachLine` for *zero* `act-01-*` registrations — Button and blinds guided/scaffolded/unguided/checkpoint can still fall through to catalog + "Tap the best answer." despite local `_coachText` (LPT-590). Do not assume Section 1 densify is done because later S2/S3 tickets exist. Prefer `rex_coach_line.dart` as frame truth over activity `_coachText`. `content,grokbot,lesson`.
- Earliest open pressHints after Suits LPT-82 Done is Button LPT-86 (`act-01-01-03-scaffolded-blinds` / `unguided-when`), not sticky LPT-185 — re-scan scaffolded non-assessment with teachSpec and empty `pressHints` by lesson order before citing “earliest.”
- After LPT-589 Fold/check/call unguided SoftPulse map (`call-5`), continue the *unguided poker_action_sizing SoftPulse-map chain* one Medium per run: Bet/raise/all-in `act-01-03-02-unguided-allin` → `shove-12` (LPT-591), then Open/fold `act-02-03-01-unguided-btn` → `open-k9s`, then Versus an open `act-02-04-01-unguided-3bet` → `3bet-kk`. Keep LPT-557 as the only *non-unguided* map gap. Do not batch-file the whole unguided backlog. Chrome-validatable → `content,grokbot,lesson`.
- After LPT-591 Bet/raise/all-in unguided SoftPulse map (`shove-12`), continue the *unguided poker_action_sizing SoftPulse-map chain* one Medium per run: Open/fold `act-02-03-01-unguided-btn` → `open-k9s` (LPT-592), then Versus an open `act-02-04-01-unguided-3bet` → `3bet-kk`. Keep LPT-557 as the only *non-unguided* map gap. Do not batch-file the whole unguided backlog. Chrome-validatable → `content,grokbot,lesson`.
- After LPT-222 Build multiway teachSpec lands Done (#1854), file Medium SoftPulse explain Nice! `act-05-01-01-explain` NUTTED/AIR/DOMINATION (LPT-593) and Medium `deal.variants` for the two `fixed` steps (scaffolded/unguided) — LPT-595. Explain/guided/checkpoint stay `deal.mode` `none` (skip variants). SoftPulse map for unguided `bet-set` is SoftPulse-map chain (after Facing-an-open `3bet-kk` LPT-594) — do not fold into Nice!/variants. LPT-513 guideRegion Done (#1853) — densify footer remains LPT-456. Earliest open High teachSpec becomes LPT-225 deep-stack.
- After LPT-596 Choose a flop line unguided SoftPulse map (`raise-set`), continue the *unguided poker_action_sizing SoftPulse-map chain* one Medium per run: Plan the turn `act-03-05-01-unguided` → `delay-bet` (LPT-597), then Close the river `act-03-06-01-unguided` → `fold-weak`, then leak `act-03-08-01-unguided` → `fold-air` (or multiway `act-05-01-01-unguided` → `bet-set` when preferring freshly Done S5 teachSpec). Keep LPT-557 as the only *non-unguided* map gap. Do not batch-file the whole unguided backlog. Tip can advance on unrelated deploys (#1855) — re-fetch before SoftPulse-map / teachSpec comments. Chrome-validatable → `content,grokbot,lesson`.
- After LPT-597 Plan the turn unguided SoftPulse map (`delay-bet`), continue the *unguided poker_action_sizing SoftPulse-map chain* one Medium per run: Close the river `act-03-06-01-unguided` → `fold-weak` (LPT-598), then leak `act-03-08-01-unguided` → `fold-air` (or multiway `act-05-01-01-unguided` → `bet-set` when preferring freshly Done S5 teachSpec). Keep LPT-557 as the only *non-unguided* map gap. Do not batch-file the whole unguided backlog. Tip unchanged on deploy chore #1855 (806db709) — still re-fetch before SoftPulse-map / teachSpec comments. Chrome-validatable → `content,grokbot,lesson`.
- After LPT-598 Close the river unguided SoftPulse map (`fold-weak`), continue the *unguided poker_action_sizing SoftPulse-map chain* one Medium per run: leak `act-03-08-01-unguided` → `fold-air` (LPT-599), then multiway `act-05-01-01-unguided` → `bet-set` (prefer freshly Done S5 teachSpec LPT-222). Keep LPT-557 as the only *non-unguided* map gap. Do not batch-file the whole unguided backlog. Tip advanced on LPT-514 SoftPulse densify #1856 (0006d94b) — re-fetch before SoftPulse-map / teachSpec comments; SoftPulse ui-agent Dones do not clear teachSpec Highs. Chrome-validatable → `content,grokbot,lesson`.
- After LPT-600 Build multiway unguided SoftPulse map (`bet-set`), continue the *unguided poker_action_sizing SoftPulse-map chain* one Medium per run: Navigate 3-bet pots `act-04-02-01-unguided` → `squeeze` (LPT-601 next), then Plan beyond the flop `act-04-03-01-unguided` → `small-pot`, then SPR `act-04-05-01-unguided` → `flexible`, then Adjust Station/Nit/Maniac unguided docks (`baseline-check` / `tighter` / `baseline-fold`). Keep LPT-557 as the only *non-unguided* SoftPulse map gap. Do not batch-file the whole unguided backlog. Tip unchanged on SoftPulse densify #1856 (0006d94b) — still re-fetch before SoftPulse-map / teachSpec comments; SoftPulse ui-agent Dones do not clear teachSpec Highs. Chrome-validatable → `content,grokbot,lesson`.
- Deep-stack / `act-05-02-01-*` scaffolded Dart spot after LPT-404 (#1858) is hero `Ad`/`9c` + board `As`/`Th`/`7h` (true TPWK). Do not cite obsolete Ah9d/As8h7h TPTK in LPT-225 comments or teachSpec fixedCards; keep SoftPulse cue `fold-tp`.
- After LPT-620 SPR unguided SoftPulse map (`flexible`), continue the *unguided poker_action_sizing SoftPulse-map chain* one Medium per run: Adjust Station `act-04-06-03-unguided` → `baseline-check` (next), then Adjust Nit `act-04-07-03-unguided` → `tighter`, then Adjust Maniac `act-04-08-03-unguided` → `baseline-fold`. Keep LPT-557 as the only *non-unguided* SoftPulse map gap. Do not batch-file the whole unguided backlog. Tip 9cb8a9c1 — LPT-242 Soft timing still earliest High (all five MISSING; already tip-commented); LPT-245/248/251 companions already filed (LPT-615…619). Prefer freshly Done SoftPulse-explain teachSpec Nice! (when LPT-242 lands) over advancing SoftPulse-map when both available. Chrome-validatable → `content,grokbot,lesson`.
- After LPT-621 Adjust Station unguided SoftPulse map (`baseline-check`), continue the *unguided poker_action_sizing SoftPulse-map chain* one Medium per run: Adjust Nit `act-04-07-03-unguided` → `tighter` (next), then Adjust Maniac `act-04-08-03-unguided` → `baseline-fold`. Keep LPT-557 as the only *non-unguided* SoftPulse map gap. Do not batch-file the whole unguided backlog. Tip f5d7c103 — LPT-242 Soft timing still earliest High (all five MISSING; tip-commented); LPT-252 range advantage still In Progress missing all five. Prefer freshly Done SoftPulse-explain teachSpec Nice! (when LPT-242 lands) over advancing SoftPulse-map when both available. Chrome-validatable → `content,grokbot,lesson`.
- After LPT-622 Adjust Nit unguided SoftPulse map (`tighter`), continue the *unguided poker_action_sizing SoftPulse-map chain* one Medium per run: Adjust Maniac `act-04-08-03-unguided` → `baseline-fold` (next). Keep LPT-557 as the only *non-unguided* SoftPulse map gap. Do not batch-file the whole unguided backlog. Tip f5d7c103 — LPT-242 Soft timing still earliest High (all five MISSING; tip-commented); LPT-252 range advantage still In Progress missing all five. Prefer freshly Done SoftPulse-explain teachSpec Nice! (when LPT-242 lands) over advancing SoftPulse-map when both available. Chrome-validatable → `content,grokbot,lesson`.
- After LPT-623 Adjust Maniac unguided SoftPulse map (`baseline-fold`), the S4 Adjust Station/Nit/Maniac SoftPulse-map chain is complete (LPT-621 / LPT-622 / LPT-623). Remaining unguided SoftPulse-map backlog is already filed (LPT-589…602 / LPT-607 / LPT-614 / LPT-619 / LPT-620); keep LPT-557 as the only *non-unguided* SoftPulse map gap. Do not invent SoftPulse-map tickets for TAG/LAG/mix-five unguided until those High teachSpecs land SoftPulse cues. Prefer re-verify earliest High LPT-242 Soft timing (or freshly Done SoftPulse-explain Nice! when it lands) over advancing SoftPulse-map when the unguided chain has no next unticketed candidate. Tip f5d7c103 — LPT-242/252 still missing all five. Chrome-validatable → `content,grokbot,lesson`.
- SoftPulse explain Nice! `explainGrading` is authored at the *activity* top level in `course.json` / bank (Done LPT-199/490 class), not nested under `teachSpec`. Scanning only `teachSpec.explainGrading` false-negatives landed ladders; catalog.json intentionally strips `explainGrading` into the private bank payload.
- After LPT-623 SoftPulse-map chain completes and tip advances on SoftPulse ui-agent densify only (e.g. LPT-523 #1877 → tip 03bb9196), re-verify earliest High LPT-242 Soft timing first — SoftPulse one-gold Dones do not clear teachSpec. Soft timing companions already filed (LPT-243/244/464); skip SoftPulse explain Nice! until LPT-242 Done. Prefer tip-comment LPT-242/252 + densify LPT-464 + earliest pressHints LPT-86 + sole SoftPulse-cues gap LPT-370 when no new SoftPulse-map candidate exists. `content,grokbot,lesson`.
- After #1879 catalog-bundled policy: structural SoftPulse-explain teachSpec catch-up for Done interactive lessons is **LPT-629** (not new LPT-354 clones); densify guideRegion Highs → **LPT-630**; permanent-gold Highs → **LPT-631**. Enrich SoftPulse-map catalog **LPT-625** with concrete `act-…` + cue targets on tip re-scan; keep LPT-557 as the only non-unguided SoftPulse map one-off (Relates LPT-625). Soft timing / range-advantage SoftPulse explains stay on High LPT-242 / LPT-252 — do not fold into LPT-629. Honesty Highs stay per-activity. Prefer append/edit catalog parents over per-lesson clones.
- Catalog SoftPulse-explain teachSpec parent is **LPT-635** (not LPT-629); densify guideRegion **LPT-634**; permanent-gold **LPT-633**. After bundling Done children (LPT-354…365), the parent body must list every concrete `act-…` + SoftPulse cue targets — lesson-title-only / single-row parents are incomplete. S5–S7 SoftPulse explains stay on open High teachSpec tickets (LPT-242…) — do not duplicate into LPT-635. Same enrichment rule for pressHints **LPT-626** and deal.variants **LPT-627** (concrete `act-…` checklists on tip re-scan).
- When bundling densify-tap / structural catalog children, match by **summary** (e.g. `summary ~ "Tap the best answer"`), never `text ~` — body/comment mentions of Tap footer on High teachSpec tickets can false-match and wrongly Done those Highs. If that happens: reopen to To Do immediately and rebuild the catalog parent body.
- Densify seat-footer gaps (`_seatAnswerActivityIds`: jump-pos / acting-order checkpoint-full / table-read scaffolded) belong under catalog parent LPT-628 (`catalog:densify-tap`) — append concrete act-ids + bundle per-lesson densify clones by *summary* only (never text~ High teachSpecs); do not keep jump-pos as a standalone densify ticket once the parent exists.
- Densify-tap catalog parent (LPT-628): measure fallthrough via `selectIdentifyDensifiedCoachLine` + `_lessonFrameLine` special-cases + authored pick/tap prompts — not via Done densify child tickets. Bundling children to Done tracks ownership only; helper arms may still be absent (tip 98ba4a8b: 28 registered, 176 fallthrough). Keep LPT-488 jump-pos seat-footer on the densify-tap parent.
- When tip lands catalog `permanent-gold` (LPT-633 / #1883) and `lesson_table_context.dart` has zero densified `gold: true` tips, Done the ui-agent catalog parent from content-agent re-verify — do not keep it In Progress waiting for a second mini pass. Then prefer enriching `catalog:nice-ladder` (LPT-624) with concrete `act-…` + SoftPulse cue ladders for every SoftPulse explain that already has `teachSpec` but lacks **activity-level** `explainGrading` (not nested under `teachSpec`; bank strips into private payload). Skip Nice! for explains still on LPT-635 / open High teachSpecs (earliest LPT-242).
- SoftPulse-map gaps (`catalog:unguided-softpulse-map` / `_guidedPulseTargetId`) only apply to authored cues with `kind: soft_pulse`. Cue `kind: none` on jump_test/checkpoint PAS docks is intentional SoftPulse-off — do not append those act-ids to LPT-625.
- Catalog guideRegion parent **LPT-634**: tip-scan `_build*Outcomes` for missing `guideRegion:` (not activity-id windows). After permanent-gold LPT-633 lands, drop builders that already pass `guideRegion` (e.g. How pots) and append new siblings (e.g. `_buildSizingUnguidedOutcomes` / `act-04-04-01-unguided`). Body must list concrete `act-…` + builder names; prove on iPhone 13 mini (`ui-agent`).
- Capstone hands/explains in Dart `lessonFrameHintsDisabled` `noHintIds` (`act-07-10-0{1-5}-{hand,explain}`) must **not** be listed on catalog `pressHints` (LPT-626) — learner copy says "No hints" and Hint is disabled. LPT-348 decided: Capstone *-hand* activities use `assessmentRole: transfer` (intentional no-Hint); keep noHintIds / `NO_HINT_ACTIVITY_IDS` in sync; do not reopen LPT-626/LPT-667. Do not treat noHintIds rows as ordinary scaffolded pressHints gaps.
- When tip lands catalog `guideRegion` (LPT-634 / #1885) and every listed densify `_build*Outcomes` / `_buildOutcomePhases(` **call** passes `guideRegion:` (ignore the method signature), Done the ui-agent catalog parent from content-agent re-verify — same pattern as permanent-gold LPT-633. Do not keep it In Progress waiting for a second mini pass when design-record already cites LPT-634. Then prefer re-verify earliest High LPT-242 Soft timing (or honesty Highs / SoftPulse-map LPT-625) over inventing new guideRegion siblings.
- After ui-agent catalog Done (e.g. LPT-634 guideRegion #1885), tip-update stale explain-teachSpec **LPT-635** SHA and re-confirm the 12 S1–S2 SoftPulse explains still missing `teachSpec` — SoftPulse one-gold/guideRegion Dones never clear teachSpec. Meet Nit Nice! stays on **LPT-624** (already listed); do not file a per-lesson Meet Nit Nice! clone when the timer mentions it.
- When tip SHA is unchanged and LPT-242 / SoftPulse-map LPT-625 were already tip-commented on that SHA, prefer honesty High re-verify (LPT-394/396/401/402/417) + Scene drift LPT-588 / cues LPT-370, then rebuild densify-tap catalog parent **LPT-628** from `rex_coach_line.dart` `selectIdentifyDensifiedCoachLine` arms (strip quotes when matching) excluding catalog prompt/a11y that already author tap|pick — do not re-spam teachSpec High comments on the same SHA. Helper arm count on tip 862bbfbb stayed 28 (through Meet Station); fallthrough checklist size is ~172 after that exclusion.
- After LPT-262 polar teachSpec lands Done (#1886 / tip 4d08a6cb): append SoftPulse explain Nice! `act-06-04-01-explain` POLAR→MERGED→SIZE onto catalog **LPT-624** (34 explains) and `deal.variants` for scaffolded fixed onto **LPT-627** (72 fixed-empty); do **not** file per-lesson Nice!/variants clones. pressHints/densify already listed on LPT-626/628. Scaffolded SoftPulse map already wires `mid` — skip LPT-625; unguided is `select_identify` outcome tiles (not poker_action_sizing SoftPulse-map). Keep LPT-395 second-pair `JhTd`/`QcTs…` in variants notes. Earliest High teachSpec remains LPT-242 Soft timing (all five still MISSING). Curriculum split stays needs-human LPT-264.
- After LPT-265 overbet teachSpec lands Done (#1887 / tip bd9520d2): append SoftPulse explain Nice! `act-06-05-01-explain` OVERBET→POLAR→GEO onto catalog **LPT-624** (35 explains) and `deal.variants` for scaffolded fixed onto **LPT-627** (73 fixed-empty); do **not** file per-lesson Nice!/variants clones. pressHints/densify already listed on LPT-626/628 (LPT-266/472 Done as bundles). SoftPulse map already wires scaffolded `mid` — skip LPT-625; unguided is `select_identify` outcome tiles (not poker_action_sizing SoftPulse-map). Earliest High teachSpec remains LPT-242 Soft timing (all five still MISSING). Curriculum split stays needs-human LPT-267.
- When a densify PR lands only a subset of `catalog:densify-tap` (e.g. LPT-636 capped arms on tip d22db3c2), Done that lesson ticket if helper arms match AC, then tip-comment **LPT-628** that sibling listed arms (polar/overbet SI, seat footers) remain ABSENT — do not file new per-lesson densify clones.
- After LPT-636 (#1888) lands capped densify coach helper arms (`act-06-03-01-guided` / `unguided` / `checkpoint`), rebuild catalog densify-tap **LPT-628** from `selectIdentifyDensifiedCoachLine` (strip quotes when matching) — arms become **31** and SI/PR fallthrough drops **172→169** on tip `d22db3c2`. Densify does **not** clear High teachSpec LPT-258 (all five still MISSING). Prefer honesty High tip-comments (LPT-394/396/397/401/402/417) + Scene LPT-588 / cues LPT-370 over re-spamming LPT-242 on the same tip SHA. Seat footers remain fallthrough. `content,grokbot,lesson`.
- When tip SHA is unchanged and densify/teachSpec Highs were already tip-commented, prefer the *fingerprint + texture honesty* cluster next (LPT-405 Q83tt; LPT-408/409/411 `_postflopTeachKey` field gaps; LPT-414 Gutshot-ish Air feedback) plus In Progress teachSpec Highs not yet commented on that SHA (e.g. LPT-268 blockers). Verify fingerprint tickets by reading `_postflopTeachKey` fields — do not re-run isomorphic seed sims every tip-comment. Chrome-validatable → `content,grokbot,lesson`.
- Wave teachSpec lag scans must parse activity blocks by `id: "…"` → next `id:` (not a fixed char window) and treat `dialogue(id, …)` explains separately from `selectAct({id})`. LPT-558 tip d22db3c2: pilot checkpoint already has wave teachSpec; only guided/scaffolded/unguided + dialogue explain still lag — do not claim “all five missing.” Skip Done on In Progress ui-agent densify siblings (LPT-637); Relates + keep catalog LPT-628.
- Densify framed path only counts `selectIdentifyDensifiedCoachLine` arms — after helper PRs (LPT-636/637) rebuild catalog densify-tap LPT-628 fallthrough from the helper (31→34 / 169→166); local `_coachText` / activity switch does not clear the framed Tap footer. Pilot wave lag LPT-558: all five `act-01-01-01-*` missing teachSpec in `wave_one` (checkpoint was a false HAS — parse `id: "…"` blocks). SoftPulse explain rows that already have activity-level `explainGrading` without teachSpec (streets / acting-order) must keep that ladder when LPT-635 adds cues.
- Wave sync ticket LPT-558 is not pilot-only: when courseHAS/waveMISS appears elsewhere in the same `wave_*.mjs` file (e.g. act-01-06-01-* / act-02-07-01-unguided-lab on wave_one), append those ids to LPT-558 (or expand the body) instead of filing per-lesson wave clones. Scan all three wave helpers with id/dialogue block parse; tip 503aa5e6 also had wave_two ≈2 (`act-04-03-01-guided`, `act-04-10-01-checkpoint`) and wave_three ≈0.
- When tip lands a deal-honesty PR (e.g. LPT-397 MDF third pair #1892), **Done** that per-lesson honesty ticket on content-agent re-verify, then **edit the open teachSpec High body** for the same lesson (here LPT-271) so `fixedCards` / Steps cite the corrected hole+board — do not leave stale air codes in the High while only tip-commenting. Densify/SoftPulse-map parents get tip-comments only when helper counts are unchanged. Chrome-validatable → `content,grokbot,lesson`.
- Densify fallthrough scans must match Dart `selectIdentifyDensifiedCoachLine` arms via `'act-…' =>` (switch expression) and course `renderer` snake_case (`select_identify` / `player_read_classify`) — camelCase / `case '…':` parsers false-zero the checklist.
- Timer mentions of LPT-216 / Meet Nit Nice! / pressHints: LPT-216 is **Done** (exploit teachSpec landed) — do not reopen or file clones. Meet Nit Nice! → catalog **LPT-624** (`act-04-07-02-explain`); Meet Nit pressHints → catalog **LPT-626** (`act-04-07-02-unguided`). Exploit explain Nice! / exploit scaffolded+unguided pressHints are already on those parents after LPT-216. Tip-comment the parents; never file per-lesson Meet Nit or LPT-216 sibling tickets.
- Tip `46dd0793` (#1898 soft-stop only): `scan_content_gaps --counts` still pressHints 155 / deal-variants 73 / teachSpec 117 / explain-teachSpec 42; `CATALOG_PARENTS.teachSpec` stays **null** by design — do **not** open a catalog interactive-teachSpec parent (Highs LPT-242… stay per-lesson). SoftPulse-map re-check must brace-extract `_guidedPulseTargetId` (68 arms) — all 18 unguided + scaffolded-qq still ABSENT; densify helper still 41 arms with seat-footer + Soft timing/MDF/mix SI ABSENT. Honesty Highs still valid: LPT-394 98hh/K723, LPT-396 JT/T98x top-as-second, LPT-401 Weak TPTK, LPT-402 missed-FD air, LPT-414 Gutshot-ish Air, LPT-417 NNbb sans stackLabel, LPT-405 Q83tt, Scene LPT-588 flop-only, cues LPT-370 ranks. LPT-635 keeps the **12** S1–S2 SoftPulse explains only (do not expand to scanner’s full 42). `content,grokbot,lesson`.

## Fold 2026-10-13

- When rebuilding densify-tap **LPT-628** priority ABSENT after a sibling clears (e.g. LPT-640 MDF guided/unguided/checkpoint), re-include every still-ABSENT Soft timing SI id including **`act-05-07-01-guided`** — do not drop guided when listing only scaffolded/unguided/checkpoint. Verify with helper arms + fallthrough scan before editing the parent body.

## Fold 2026-10-13

- After a densify sibling reaches **Done** with Validated-on-origin/main (e.g. LPT-640), immediately edit catalog densify-tap **LPT-628** body text that still says “leave In Progress until Validated” — stale waiting language confuses the next pass. Keep arms/fallthrough numbers; only flip the sibling status sentence.
- ui-agent Hint-disabled tickets (e.g. LPT-643): identify the activity stage before agreeing with “Hint always on.” Guided SoftPulse teach intentionally keeps **Hint off while gold SoftPulse is on** (04-course). Scaffolded non-assessment (e.g. `act-01-02-02-checkpoint-build` after #1900) must allow Hint — pair with catalog pressHints **LPT-626**; do not file a per-lesson pressHints clone. Prefer Relates to LPT-626; keep `ui-agent` for mini proof.

## Fold 2026-10-13

- Loop learnings must land in git every tick: run
  `tools/fold_agent_learnings.sh`, distill Never/Prefer into
  `lesson-content-agent-learnings.md`, append full notes here, and ship
  `chore/content-agent-learnings-YYYYMMDD` (e.g. #1903 / #1905). Coverage
  JSONL `learnings: pending` is not enough — next agents still miss the
  rule until tip has the fold and the home pending file has zero `- `
  bullets. After machine-SDK 504 thrash, ff-pull `origin/main` before
  Done/tip-comments (loop SHA can lag merges like #1905/#1906).

## Fold 2026-10-13

- ui-agent cyan-selection Dones (e.g. LPT-641 #1908) do **not** clear content Nice! ladders (LPT-624), pressHints (LPT-626), SoftPulse-map (LPT-625), densify-tap (LPT-628), or explain-teachSpec (LPT-635). Tip-comment those parents on the new SHA; keep Hint-enablement companions (LPT-643) open separately.

## Fold 2026-10-13

- Tip `dc3f830f` (#1910 uiagenttest-only): `scan_content_gaps --counts` still pressHints **156** / deal-variants **73** / teachSpec **117** / explain-teachSpec **42**. Rebuilt catalog parents LPT-626/627/635. **LPT-626** fix table must list **151** after subtracting Dart `noHintIds` five capstone `-hand` rows (scanner still emits them; prior tip text wrongly said 156 “after excluding”). SoftPulse-map `_guidedPulseTargetId` still **68** arms (unguided mostly ABSENT; no `scaffolded-qq`). Densify helper still **44**. Honesty Highs still valid: LPT-394 `act-07-02-01-scaffolded` 9h8h/Kh7c2d3s gutshot-brick, LPT-396 `act-07-08-01-guided` JhTd/Ts9h8c2d top-as-second, LPT-401 Weak TPTK, LPT-402 missed-FD air, LPT-405 Q83tt, LPT-414 Gutshot-ish, LPT-417 NNbb sans stackLabel, Scene LPT-588 flop-only, cues LPT-370 ranks. In Progress teachSpec Highs (LPT-242/252/255/271/275/280) still all-five MISSING — tip-comment only, leave In Progress. `CATALOG_PARENTS.teachSpec` stays null.

## Fold 2026-10-13 honesty tip-pass

- Tip `dc3f830f` (#1910): concurrent coverage already tip-synced catalog parents (Nice!/pressHints/SoftPulse-map/densify/explain). This run tip-commented honesty/fingerprint/Scene/cues/wave + In Progress teachSpecs that still had **zero** `dc3f830f` hits: LPT-394/396/401/402/405/414/417, LPT-588, LPT-370, LPT-558, LPT-252/271/275/280, LPT-408/409/411 — all still valid.
- Corrected **LPT-626** body: scanner raw **156** − five `noHintIds` `-hand` → fix checklist **151** (prior tip text wrongly said 156 after excluding).
- `scan_content_gaps --counts` unchanged 156/73/117/42; densify helper still 44; SoftPulse-map 18+qq ABSENT; LPT-635 12 S1–S2 MISSING; earliest High teachSpec LPT-242 still all-five MISSING.

## Fold 2026-10-13 tip b8e09524 (#1912)

- Tip `b8e09524` after #1912 LPT-642 Done (ui-agent open-pot felt redeal under Nice!/Oops on `act-01-05-01-unguided-pot`). That fix does **not** clear content catalog gaps — same class as LPT-641 cyan ≠ catalog-clear.
- `scan_content_gaps --counts` still pressHints **156** / deal-variants **73** / teachSpec **117** / explain-teachSpec **42**. Rebuilt catalog parents: LPT-626 (fix **151** after `noHintIds`), LPT-627 (**73**), LPT-635 (12 S1–S2), LPT-625 SoftPulse-map (**68** arms / **18+qq ABSENT**), LPT-628 densify (**44** arms / **156** fallthrough; priority seat-footer + Soft timing `act-05-07-01-*` incl. guided + mix SI).
- Tip-commented LPT-624 Nice! + LPT-643 Hint companion + earliest High LPT-242 (all five `act-05-07-01-*` still MISSING teachSpec) + honesty/fingerprint LPT-394/396/401/402/405/414/417/370/588/408/409/411.
- In Progress teachSpec Highs LPT-252/255/271/275/280 still all-five MISSING (not re-spammed this tip beyond LPT-242). `CATALOG_PARENTS.teachSpec` stays null.
- SoftPulse-map re-check: brace-extract `String? _guidedPulseTargetId` definition only (call-site substring false-positives `_feltFirstCoach`).

## Fold 2026-10-13 tip 2604f13e (#1916)

- Tip `2604f13e` after #1916: scanner `NO_HINT_ACTIVITY_IDS` excludes Dart `lessonFrameHintsDisabled` capstone `-hand`/`-explain` ids — `scan_content_gaps --counts` pressHints **156→151** (matches prior manual LPT-626 fix table). deal-variants **73** / teachSpec **117** / explain-teachSpec **42** unchanged.
- Rebuilt catalog parents from markdown: **LPT-626** (151), **LPT-627** (73), **LPT-635** (12 S1–S2). Tip-commented LPT-624/625/628 + earliest In Progress High **LPT-242** (all five `act-05-07-01-*` still MISSING) + To Do High **LPT-258** (all five `act-06-03-01-*` still MISSING; densify capped ≠ teachSpec) + **LPT-283** (`act-06-10-01-*` still MISSING) + cues **LPT-370** (`act-01-01-02-scaffolded-ranks` cues still null).
- Densify helper still **44** / priority ABSENT Soft timing SI + mix SI + seat footers. SoftPulse-map still **68** arms / `scaffolded-qq` ABSENT. `CATALOG_PARENTS.teachSpec` stays null.
- `act-` / `lesson-` greps: Soft timing `act-05-07-01-*`, capped `act-06-03-01-*`, hard-folds `act-06-10-01-*`, ranks cues `act-01-01-02-scaffolded-ranks` — all still open as prior tickets; no new per-lesson clones.
- Tip `cab31c48` (#1921 health; course #1920 LPT-280 Done): `scan_content_gaps --counts` pressHints **151**, deal-variants **73→74**, teachSpec **117→113**, explain-teachSpec **42→41**. Rebuilt catalog **LPT-627** (new `act-06-09-01-scaffolded` fixed sans variants) and **LPT-624** Nice! **37** (appended `act-06-09-01-explain` 3BET→4BET→DEPTH). LPT-280 all five `act-06-09-01-*` teachSpec PRESENT — already Done; follow-ups stay on catalog parents. **LPT-417** still valid (180bb chrome sans `stackLabel` after teachSpec). Soft timing densify helper arms PRESENT while High **LPT-242** teachSpec still all-five MISSING — densify ≠ teachSpec clear; tip-comment LPT-628 ABSENT priority (mix guided still ABSENT). LPT-635 keeps **12** S1–S2 MISSING. Honesty Highs still valid: LPT-394/396/401/402/405/414/417; Scene LPT-588; cues LPT-370; fingerprints LPT-408/409/411. To Do Highs LPT-258/283 still all-five MISSING. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.

## Fold 2026-10-13 tip f28983c8 (#1923 LPT-283)

- Tip `f28983c8` after #1923 LPT-283 Done (hard-folds teachSpec on all five `act-06-10-01-*`). `scan_content_gaps --counts`: pressHints **151**, deal-variants **74→75**, teachSpec **113→109**, explain-teachSpec **41→40**.
- Rebuilt catalog **LPT-627** (**75** — new `act-06-10-01-guided` fixed sans variants) and **LPT-624** Nice! **38** (appended `act-06-10-01-explain` HARD→COOLER→EGO). Tip-commented **LPT-626** (scaffolded/unguided still on 151; outcome-tile `deal.mode` `none` — no deal-variants rows), **LPT-635** (keep 12 S1–S2; scanner full drop only), **LPT-625** / **LPT-628**, Done ack **LPT-283**, In Progress **LPT-242** still all-five MISSING Soft timing.
- `act-` / `lesson-` greps: hard-folds `act-06-10-01-*` — teachSpec PRESENT; follow-ups on catalog parents only (no per-lesson Nice!/variants/pressHints clones; LPT-284/477/502 already Done). Curriculum split LPT-285 stays `needs-human`. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.

- Tip `561e3e4f` (#1926 LPT-643 `lessonFrameCanHint` on tip; Jira still In Progress pending ui Validated): `scan_content_gaps` unchanged pressHints **151** / deal-variants **75** / teachSpec **105** / explain-teachSpec **39**. Hint enablement ≠ authored pressHints — tip-commented **LPT-626** + Meet Nit routing (Nice! **LPT-624** 39 / pressHints unguided). Rebuilt LPT-635 scanner-full **39** (S1–S2 still 12). LPT-242 still all-five MISSING. `content,grokbot,lesson`.

## Fold 2026-10-13 tip 41a10b06 (#1927 LPT-289 + #1925 LPT-286)

- Tip `41a10b06` after #1927 LPT-289 Done (Meet TAG) and #1925 LPT-286 Done (Observe selective); also includes #1926 LPT-643 Hint enablement on tip. `scan_content_gaps --counts`: pressHints **151**, deal-variants **75** (unchanged — both lands are outcome-tile `deal.mode` `none`), teachSpec **109→101**, explain-teachSpec **40→38**.
- Rebuilt catalog **LPT-624** Nice! **38→40** (appended `act-06-11-01-explain` TIGHT→BARREL→SAMPLE + `act-06-11-02-explain` TIGHT→AGGRO→MODEL). Tip-commented **LPT-626** (scaffolded/unguided still on 151 for both lessons), **LPT-627** (flat at 75), **LPT-635** (keep 12 S1–S2), **LPT-625** / **LPT-628**, Done ack **LPT-286** / **LPT-289**, In Progress **LPT-242** still all-five MISSING Soft timing. Honesty/fingerprint Highs tip-commented still valid. LPT-643 ≠ authored pressHints (see Prefer).
- Run-memory grep `act-06-11-01-*` / `act-06-11-02-*`: observation / player-type tiles — no handFamily gaps; Still-a-list entry/label quizzes STALE. Densify LPT-435/436 + SoftPulse guideRegion LPT-494/491 stay separate. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.

## Fold 2026-10-13 tip 7bb2676f (#1930 LPT-292)

- Tip `7bb2676f` after #1930 LPT-292 Done (Adjust versus TAG teachSpec on all five `act-06-11-03-*`). `scan_content_gaps --counts`: pressHints **151**, deal-variants **75→78**, teachSpec **101→97**, explain-teachSpec **38→37**.
- Rebuilt catalog **LPT-627** (**78** — new `act-06-11-03-guided` / `scaffolded` / `unguided` fixed sans variants) and **LPT-624** Nice! **41** (appended `act-06-11-03-explain` CREDIT→TIGHTER→NO LIGHT). Tip-commented **LPT-626** (scaffolded/unguided still on 151; LPT-292 authored deal/cues only), **LPT-635** (keep 12 S1–S2; scanner full drop only), **LPT-625** / **LPT-628**, Done ack **LPT-292**. Design-record Still-a-list “respect check” still present on tip — tip-commented on LPT-292; do not file a Still-a-list rebuild. In Progress **LPT-242** Soft timing still all-five MISSING.
- Run-memory grep `act-06-11-03-*`: explain SoftPulse CREDIT/TIGHTER/NO LIGHT (`deal.mode` `none`); guided/scaffolded/unguided `poker_action_sizing` `fixed` + cues `fold` / `fold-k9` / `check`; checkpoint cite tiles `deal.mode` `none` — no handFamily gaps; follow-ups on catalog parents only (no per-lesson Nice!/variants/pressHints clones; densify LPT-437 Done). Curriculum split LPT-294 stays `needs-human`. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.

## Fold 2026-10-13 tip abd48de8 (#1931 learnings-only)

- Tip `abd48de8` after #1931 content-agent learnings chore (no course.json delta vs `7bb2676f`). `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **78**, teachSpec **97**, explain-teachSpec **37**. Catalog parents already body-synced on `7bb2676f` (Nice! **41** / variants **78** / pressHints **151** / LPT-635 12 S1–S2); tip-commented parents on `abd48de8` without inventing count deltas. LPT-643 **Done** (Hint enablement) — still ≠ authored pressHints.
- Re-verified In Progress High **LPT-242** Soft timing: all five `act-05-07-01-*` still MISSING teachSpec. Densify sibling **LPT-464** is Done but `selectIdentifyDensifiedCoachLine` still has **zero** `act-05-07-01-*` arms (and zero `act-06-08-01-*` mix) — keep Soft timing + mix SI on densify-tap **LPT-628** ABSENT priority; sibling Done ≠ helper arms PRESENT. Helper arm count still **44**. SoftPulse-map still **18** unguided + scaffolded-qq ABSENT on **LPT-625**.
- Tip-commented To Do High teachSpecs **LPT-295** / **LPT-298** / **LPT-301** (Observe wide / Meet LAG / Adjust LAG — all five `act-06-12-*` MISSING each). Run-memory grep `act-06-12-01-*`: observation outcome tiles (`deal.mode` `none`) — no handFamily gaps; Still-a-list entry quizzes STALE; companions densify LPT-438 / SoftPulse LPT-493 / needs-human LPT-297 already filed. Honesty/fingerprint Highs already tip-commented on this SHA. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR implement catalog LPT-626(151)/627(78)/635/624(41)/625/628 OR densify Soft-timing/mix helper arms on LPT-628 OR honesty if tip advances.

## Fold 2026-10-13 tip bbad143c (#1933 SDK + #1932 learnings)

- Tip `bbad143c` after #1933 (SDK run-log dedupe / skip when ui-queue empty) and #1932 (prior content-agent tip-pass learnings). No `course.json` / densify / SoftPulse-map land vs `abd48de8`. `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **78**, teachSpec **97**, explain-teachSpec **37**. Catalog parent bodies already synced on `7bb2676f` (Nice! **41** / variants **78** / pressHints **151** / LPT-635 12 S1–S2); tip-commented LPT-624/625/626/627/628/635 on `bbad143c` without inventing count deltas.
- Re-verified In Progress High **LPT-242** Soft timing: all five `act-05-07-01-*` still MISSING teachSpec. Densify helper still **44** arms with zero `act-05-07-01-*` (LPT-464 Done ≠ arms PRESENT) — keep on **LPT-628**. Tip-commented To Do Highs **LPT-258** / **LPT-295** / **LPT-298** / **LPT-301** (capped + Observe wide / Meet LAG / Adjust LAG — all five MISSING each) and In Progress teachSpecs LPT-252/255/271/275; honesty/fingerprint Highs LPT-394/396/401/402/405/414/417/408/409/411 + Scene LPT-588 + cues LPT-370 still valid.
- Run-memory grep `act-06-12-*` / `act-05-07-01-*`: unchanged vs abd48de8 fold — observation tiles / Soft timing teachSpec gaps; no new per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Prefer: non-content ops tips (#1933) get the same tip-comment-only treatment as learnings-only tips. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR implement catalog LPT-626(151)/627(78)/635/624(41)/625/628 OR densify Soft-timing/mix helper arms on LPT-628 OR honesty if tip advances.

## Fold 2026-10-13 tip 7f869c29 (#1934 learnings-only)

- Tip `7f869c29` after #1934 (prior content-agent tip-pass learnings on `bbad143c`). No `course.json` / densify / SoftPulse-map land. `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **78**, teachSpec **97**, explain-teachSpec **37**. Catalog parent bodies already synced on `7bb2676f` (Nice! **41** / variants **78** / pressHints **151** / LPT-635 12 S1–S2); tip-commented LPT-624/625/626/627/628/635 on `7f869c29` without inventing count deltas.
- Re-verified In Progress High **LPT-242** Soft timing: all five `act-05-07-01-*` still MISSING teachSpec. Densify helper in `rex_coach_line.dart` still **44** arms with zero `act-05-07-01-*` (framed-path inline strings in `select_identify_activity.dart` ~L937 must not count as PRESENT). Tip-commented To Do Highs **LPT-258** / **LPT-295** / **LPT-298** / **LPT-301** and IP teachSpecs LPT-252/255/271/275; honesty/fingerprint Highs LPT-394/396/401/402/405/414/417/408/409/411 + Scene LPT-588 + cues LPT-370 still valid.
- Run-memory grep `act-05-07-01-*` / `act-06-12-*` / `act-06-03-01-*`: unchanged — Soft timing teachSpec + Observe wide / Meet LAG / Adjust LAG / capped still MISSING; no new per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR implement catalog LPT-626(151)/627(78)/635/624(41)/625/628 OR densify Soft-timing/mix helper arms on LPT-628 OR honesty if tip advances.

## Fold 2026-10-13 tip c7ee5e78 (#1935 learnings-only)

- Tip `c7ee5e78` after #1935 (prior content-agent tip-pass learnings on `7f869c29`). No `course.json` / densify / SoftPulse-map land. `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **78**, teachSpec **97**, explain-teachSpec **37**. Catalog parent bodies already synced on `7bb2676f` (Nice! **41** / variants **78** / pressHints **151** / LPT-635 12 S1–S2); tip-commented LPT-624/625/626/627/628/635 on `c7ee5e78` without inventing count deltas.
- Re-verified In Progress High **LPT-242** Soft timing: all five `act-05-07-01-*` still MISSING teachSpec. SoftPulse-map brace-extract `_guidedPulseTargetId` still **68** arms (unguided backlog + `scaffolded-qq` ABSENT). Densify helper in `rex_coach_line.dart` still **44** arms with zero `act-05-07-01-*`. Tip-commented To Do Highs **LPT-258** / **LPT-295** / **LPT-298** / **LPT-301** and IP teachSpecs LPT-252/255/271/275; honesty/fingerprint Highs LPT-394/396/401/402/405/414/417/408/409/411 + Scene LPT-588 + cues LPT-370 still valid.
- Run-memory grep `act-05-07-01-*` / `act-06-12-*` / `act-06-03-01-*`: unchanged — Soft timing teachSpec + Observe wide / Meet LAG / Adjust LAG / capped still MISSING; no new per-lesson clones. Meet Nit routing stable (Nice! LPT-624 / pressHints LPT-626). `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR implement catalog LPT-626(151)/627(78)/635/624(41)/625/628 OR densify Soft-timing/mix helper arms on LPT-628 OR honesty if tip advances.

## Fold 2026-10-13 tip d42d78b0 (#1937 LPT-644 + #1936 learnings)

- Tip `d42d78b0` includes #1937 LPT-644 Mix densify (`act-06-08-01-scaffolded` / `unguided` / `checkpoint` helper arms) and #1936 prior tip-pass learnings. `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **78**, teachSpec **97**, explain-teachSpec **37** (densify Dart land ≠ catalog JSON gaps).
- Immediately rebuilt densify-tap **LPT-628** from `selectIdentifyDensifiedCoachLine`: helper **44→47**; Priority ABSENT dropped the three Mix SI rows (mix guided is `poker_action_sizing` — not SI densify); Soft timing `act-05-07-01-*` still ABSENT priority; fallthrough checklist **156→153**. Relates LPT-644↔LPT-628. Tip-commented LPT-624/625/626/627/635 + IP LPT-275 (densify ≠ teachSpec) + LPT-242.
- Run-memory grep `act-06-08-01-*` / `act-05-07-01-*`: Mix SI densify PRESENT for three stages; Soft timing teachSpec + densify still open. SoftPulse-map still 68 / 18+qq ABSENT. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR densify Soft-timing/seat-footer on LPT-628 OR implement catalog LPT-626(151)/627(78)/635/624(41)/625 OR honesty if tip advances.


## Fold 2026-10-13 tip 6cea459c (#1939 LPT-298 Meet LAG)

- Tip `6cea459c` after #1939 LPT-298 Done (Meet the LAG teachSpec on all five `act-06-12-02-*`); also includes #1938/#1940–#1942 ops/learnings. `scan_content_gaps --counts`: pressHints **151**, deal-variants **78** (unchanged — outcome-tile / player_read_classify `deal.mode` `none`), teachSpec **97→93**, explain-teachSpec **37→36**.
- Rebuilt catalog **LPT-624** Nice! **41→42** (appended `act-06-12-02-explain` WIDE→PRESSURE→MODEL). Tip-commented **LPT-626** (scaffolded/unguided still on 151), **LPT-627** (flat 78), **LPT-635** (keep 12 S1–S2), **LPT-625** / **LPT-628**. Transitioned **LPT-298** Done on tip. Tip-commented To Do High **LPT-301** Adjust LAG still all-five MISSING.
- Run-memory grep `act-06-12-02-*`: explain SoftPulse WIDE/PRESSURE/MODEL (`deal.mode` `none`); guided/unguided `player_read_classify`; scaffolded/checkpoint outcome tiles — no handFamily gaps; follow-ups on catalog parents only (no per-lesson Nice!/pressHints clones). `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: re-verify LPT-242 Soft timing OR LPT-301 Adjust LAG / LPT-295 Observe wide OR densify Soft-timing/seat-footer on LPT-628 OR implement catalog LPT-626(151)/627(78)/635/624(42)/625 OR honesty if tip advances.

## Fold 2026-10-13 tip e4ed9c09 (#1944 LPT-304 + #1945 LPT-307)

- Tip `e4ed9c09` after #1944 LPT-304 Done (Same cards / five type models teachSpec on all five `act-06-13-01-*`) and #1945 LPT-307 Done (Section 6 checkpoint `act-06-13-02-cp-*`). Mid-run local tip was still `018b69cf` until re-fetch — always ff `origin/main` before treating Validated-on-origin Done as tip-missing.
- `scan_content_gaps --counts`: pressHints **151** (flat), deal-variants **78→81**, teachSpec **93→84**, explain-teachSpec **36→35**. Rebuilt **LPT-624** Nice! **42→43** (`act-06-13-01-explain` CARDS→SEATS→EVIDENCE). Rebuilt **LPT-627** from `--gap deal-variants --markdown` (**81**; new Mix five guided/scaffolded/unguided `fixed` sans variants). Tip-commented **LPT-626** (scaffolded/unguided still on 151), **LPT-635** (keep 12 S1–S2), **LPT-625** (SoftPulse-map 68), **LPT-628** (helper 47; Soft timing ABSENT). Confirmed Done LPT-304/307 on tip; tip-commented Highs LPT-242/295/301/258 still MISSING.
- Run-memory grep `act-06-13-01-*` / `act-06-13-02-*`: Mix five explain SoftPulse CARDS/SEATS/EVIDENCE (`deal.mode` `none`); guided/scaffolded/unguided `poker_action_sizing` `fixed` (+ variants gap on LPT-627); checkpoint cite `deal.mode` `none` cue `tag`. S6 cp all outcome tiles `deal.mode` `none` — no Nice! / no deal-variants delta. No per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: re-verify LPT-242 Soft timing OR implement LPT-295/301 teachSpec OR densify Soft-timing on LPT-628 OR implement catalog LPT-626(151)/627(81)/635/624(43)/625 OR honesty if tip advances.

## Fold 2026-10-13 tip bba9ad9f (tip-stable re-pass after #1946 learnings)

- Tip still `bba9ad9f` (learnings chore after e4ed9c09 #1944/#1945). Coverage already had catalog+honesty sync on this SHA. `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **81**, teachSpec **84**, explain-teachSpec **35**; Nice! **43**. Parent checklists match (LPT-626=151 / LPT-627=81 / LPT-635 S1–S2=12 scanner full 35 / LPT-624=43). SoftPulse-map `_guidedPulseTargetId` **68** arms; densify helper **47** with Soft timing `act-05-07-01-*` still ABSENT.
- Skipped catalog parent re-edit/re-spam. Tip-commented unchecked S7 Highs: **LPT-308** In Progress (GrokBot; all five `act-07-01-01-*` still MISSING — outcome-tile SoftPulse REASON/CONFIRM/CANCEL + `dead`/`value`/`thesis`/`abandon`; Still-a-list plan quizzes STALE) and **LPT-312** To Do (all five `act-07-02-01-*` MISSING — turn-map SoftPulse BARREL/GIVE-UP/MAP + `ok`/`give`/`avoid`/`list`). Earliest frontier remains LPT-242 Soft timing.
- Prefer tightened: on tip-stable catalog-synced SHA, tip-comment S7+ Highs absent from prior coverage ticket list instead of re-spamming parents/honesty. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-308 land OR LPT-295/301 OR densify Soft-timing on LPT-628 OR implement catalog LPT-626(151)/627(81)/635/624(43)/625 OR honesty if tip advances.

## Fold 2026-10-13 tip 5697b07d (#1949 nice-ladder scanner)

- Tip `5697b07d` after #1949 (`scan_content_gaps --counts` now emits `nice-ladder`) plus #1947 learnings / #1948 soft-stop. `scan_content_gaps --counts` flat vs e4ed9c09 catalog rebuild: pressHints **151**, deal-variants **81**, teachSpec **84**, explain-teachSpec **35**, nice-ladder **43**. `--gap nice-ladder --markdown` matches LPT-624 checklist (Meet Nit `act-04-07-02-explain` + Mix five `act-06-13-01-explain` still listed). SoftPulse-map `_guidedPulseTargetId` **68** arms; densify helper **47** with Soft timing `act-05-07-01-*` still ABSENT.
- Tip-commented catalog parents LPT-624/626/627/635/625/628 (no body rebuild — counts flat). Tip-commented Highs still all-five MISSING: LPT-242 Soft timing (IP), LPT-295 Observe wide (To Do), LPT-301 Adjust LAG (IP), LPT-258 capped (To Do), LPT-308 preflop-to-flop (IP), LPT-312 Map turn (To Do), plus unchecked S7 To Do LPT-315 Compose river / LPT-318 pot type (`act-07-03-01-*` / `act-07-04-01-*` MISSING).
- Run-memory grep `act-05-07-01-*` / `act-07-01-01-*` / `act-07-02-01-*` / `act-07-03-01-*` / `act-07-04-01-*`: outcome-tile SoftPulse classes; no handFamily gaps; no per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-308/315/318 land OR LPT-295/301 OR densify Soft-timing on LPT-628 OR implement catalog LPT-626(151)/627(81)/635/624(43)/625 OR honesty if tip advances.

## Fold 2026-10-13 tip c5851fdd (#1951 LPT-308 preflop-to-flop)

- Tip `c5851fdd` after #1951 LPT-308 Done (Carry a preflop plan onto the flop teachSpec on all five `act-07-01-01-*`). Mid-run tip advanced from `5697b07d` during learnings ship — always re-`scan_content_gaps --counts` after ff.
- `scan_content_gaps --counts`: pressHints **151** (flat; scaffolded/unguided still listed), deal-variants **81** (flat — outcome-tile `deal.mode` `none`), teachSpec **84→80**, explain-teachSpec **35→34**, nice-ladder **43→44**. Rebuilt **LPT-624** from `--gap nice-ladder --markdown` (appended `act-07-01-01-explain` REASON→CONFIRM→CANCEL). Tip-commented **LPT-626/627/635/625/628**. Transitioned **LPT-308** Done on tip.
- Run-memory grep `act-07-01-01-*`: explain SoftPulse REASON/CONFIRM/CANCEL (`deal.mode` `none`); guided/scaffolded/unguided/checkpoint outcome tiles + cues `dead`/`value`/`thesis`/`abandon` — no handFamily; pressHints gap stays on LPT-626; Still-a-list plan quizzes STALE. Next unchecked S7 High: LPT-312 Map turn. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: re-verify LPT-242 Soft timing OR LPT-312/315/318 OR LPT-295/301 OR densify Soft-timing on LPT-628 OR implement catalog LPT-626(151)/627(81)/635/624(44)/625 OR honesty if tip advances.

## Fold 2026-10-13 tip 89d9a5ae (tip-stable SoftPulse-map sibling Done ≠ arms)

- Tip still `89d9a5ae` (#1952 learnings after #1951 LPT-308). Coverage already had catalog+honesty+S7 High tip-comments on this SHA. `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **81**, teachSpec **80**, explain-teachSpec **34**, nice-ladder **44**. Skipped catalog parent re-edit/re-spam (checklists match).
- SoftPulse-map brace-extract `_guidedPulseTargetId`: still **68** arms; all **18** LPT-625 unguided rows + `act-02-03-01-scaffolded-qq` still ABSENT. Sibling SoftPulse-map tickets LPT-621/622/623 show **Done** but Adjust Station/Nit/Maniac unguided ids appear only in `_feltFirstCoach`, not the SoftPulse map — keep **LPT-625** open (same class as densify sibling Done ≠ helper arms). Only unguided PRESENT remains `act-04-10-01-unguided` → `m-call`.
- Re-verified: LPT-242 Soft timing all five still MISSING; densify helper **47** Soft timing ABSENT (LPT-464 Done). SoftPulse-map sibling **Done** ≠ `_guidedPulseTargetId` PRESENT — tip-comment LPT-625, do not clear. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315/318 OR LPT-295/301 OR densify Soft-timing on LPT-628 OR implement catalog LPT-626(151)/627(81)/635/624(44)/625 OR honesty if tip advances.

## Fold 2026-10-13 tip 89d9a5ae (LPT-394 Done atmosphere + LPT-312 body + LPT-348)

- Tip still `89d9a5ae`. `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **81**, teachSpec **80**, explain-teachSpec **34**, nice-ladder **44**. Catalog parent checklists match markdown — skipped rebuild/re-spam.
- Honesty re-read (do not trust prior “still valid” without Dart): **LPT-394 Done** — `act-07-02-01-scaffolded` is `Jh`/`9d` on `Ks`/`Tc`/`2d`/`3s` under “Gutshot · brick · raise” (four outs to Q). Prior fold text claiming `9h`/`8h`·`Kh`/`7c`/`2d`/`3s` still valid was stale. Edited **LPT-312** body + tip-comment to cite fixed atmosphere; leave In Progress (all five teachSpec still MISSING). **LPT-396** still valid (`Jh`/`Td`·`Ts`/`9h`/`8c`/`2d` + “second pair”). Tip-commented needs-human **LPT-348** (capstone `noHintIds` — keep off LPT-626).
- SoftPulse-map still **68** arms / **20+qq** ABSENT on LPT-625; densify helper **47** Soft timing ABSENT. Grep `act-07-02-01-*` / `act-07-10-05-*` / LPT-348: outcome-tile SoftPulse + capstone policy; no new per-lesson clones. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312 land OR densify Soft-timing on LPT-628 OR implement catalog LPT-626(151)/627(81)/635/624(44)/625 OR LPT-396 honesty if tip advances.

## Fold 2026-10-13 tip a8658386 (#1956 LPT-394 + SoftPulse-map scanner)

- Mid-run tip advanced from `89d9a5ae` → `a8658386` (#1956 LPT-394 gutshot brick, #1957 SoftPulse-map ABSENT in gap counts, #1958 status prose, #1959 complete SoftPulse-map + `softpulseMapArms` in `--counts`). Always re-`scan_content_gaps --counts` after ff.
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **81**, teachSpec **80**, explain-teachSpec **34**, nice-ladder **44**, **unguided-softpulse-map 24**, `softpulseMapArms` **68**. Rebuilt **LPT-625** from `--gap unguided-softpulse-map --markdown` (ABSENT **20→24**: added `act-06-01-01-unguided`→`cbet`, `act-07-07-01-unguided`→`call`, `act-07-08-01-unguided`→`fold`; `act-02-03-01-scaffolded-qq`→`open-qq` now in scanner checklist). Tip-commented LPT-624/626/627/635/628 (no body rebuild — JSON gaps flat) + LPT-242 still all-five MISSING.
- LPT-394 Done confirmed on tip (`Jh`/`9d`·`Ks`/`Tc`/`2d`/`3s`); LPT-312 body already cites fixed atmosphere; LPT-396 still valid. Prefer: after tip lands SoftPulse-map scanner keys, rebuild LPT-625 from markdown — do not keep hand-counted 18/20 ABSENT. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: implement LPT-625 SoftPulse maps (24) OR re-verify LPT-242 after GrokBot OR LPT-312/315/318 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(81)/635/624(44) OR LPT-396 honesty if tip advances.

## Fold 2026-10-13 tip 51f39807 (tip-stable SoftPulse-map + Soft timing / honesty)

- Tip still `51f39807` (#1960 learnings after SoftPulse-map scanner). `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **81**, teachSpec **80**, explain-teachSpec **34**, nice-ladder **44**, unguided-softpulse-map **24**, `softpulseMapArms` **68**. Catalog parents already checklist-synced on this SHA — tip-comment only, no rebuild.
- Soft timing **LPT-242** still all five `act-05-07-01-*` MISSING `teachSpec` (GrokBot In Progress; tip not landed). Densify helper still **47**; Soft timing still ABSENT from `selectIdentifyDensifiedCoachLine` (LPT-464 Done ≠ arms — stay on **LPT-628**).
- Honesty **LPT-396** still valid: `act-07-08-01-guided` prompt “Second pair” + Dart streetLabel “second pair” vs `Jh`/`Td`·`Ts`/`9h`/`8c`/`2d` (top pair T). Tip-commented **LPT-331** companion. **LPT-312** still all five `act-07-02-01-*` MISSING (atmosphere stays LPT-394 Done codes). Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR implement LPT-625 SoftPulse maps (24) OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(81)/635/624(44) OR LPT-396 if tip advances.

## Fold 2026-10-13 tip 5b0de9e2 (#1964/#1965 densifyHelperArms + tip-stable unchecked Highs)

- Tip `5b0de9e2` after #1964/#1965 (`densifyHelperArms` in `scan_content_gaps --counts`) + #1966 ops. Prior coverage line claimed `learnings: updated` for this SHA but run-memory/learnings had **no** fold — treat coverage alone as unfolder; ship chore this tick.
- `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **81**, teachSpec **80**, explain-teachSpec **34**, nice-ladder **44**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, **`densifyHelperArms` 47**. Catalog parents already tip-commented this SHA — skipped rebuild/re-spam.
- Soft timing **LPT-242** still all five `act-05-07-01-*` MISSING; Soft timing still ABSENT from densify helper (47). **LPT-312** still all five MISSING. **LPT-396** still valid (`Jh`/`Td`·`Ts`/`9h`/`8c`/`2d` top-as-second under “second pair”). SoftPulse-map ABSENT still **24**.
- Tip-commented unchecked Highs absent from prior `5b0de9e2` coverage ticket list: fingerprint/honesty LPT-401/402/405/408/409/411/414/417; IP LPT-252/255/271/275; capstone/S7 LPT-321..352 (selected) + needs-human LPT-348. Grep `act-07-08-01-*` / `act-05-07-01-*` / `act-07-02-01-*`: no new per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR implement LPT-625 SoftPulse maps (24) OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(81)/635/624(44) OR LPT-396 if tip advances.

## Fold 2026-10-13 tip 380f87d2 (#1969 learnings — tip-stable unchecked S6/S7 Highs)

- Tip still `380f87d2` (#1969 learnings after densifyHelperArms). Coverage already had catalog:teachSpec sync on this SHA. `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **81**, teachSpec **80**, explain-teachSpec **34**, nice-ladder **44**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **47**. Catalog parent checklists match markdown — skipped rebuild/re-spam.
- Soft timing **LPT-242** still all five MISSING; Soft timing densify still ABSENT (helper 47). **LPT-312** still all five MISSING. SoftPulse-map ABSENT **24**.
- Tip-commented unchecked Highs absent from prior `380f87d2` coverage ticket list: S6 **LPT-258** capped (To Do), **LPT-295** Observe wide (To Do), **LPT-301** Adjust LAG (IP); S7 **LPT-315** Compose river (IP), **LPT-318** pot type (IP); companion **LPT-331** type×board teachSpec (To Do). Re-confirmed **LPT-396** honesty still valid (`Jh`/`Td`·`Ts`/`9h`/`8c`/`2d` top-as-second). Grep `act-06-03-01-*` / `act-06-12-01-*` / `act-06-12-03-*` / `act-07-03-01-*` / `act-07-04-01-*` / `act-07-08-01-*`: no new per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR implement LPT-625 SoftPulse maps (24) OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(81)/635/624(44) OR LPT-396 if tip advances.

## Fold 2026-10-13 tip 8bcf69a8 (#1970 learnings — tip-stable Soft timing / Map turn / fingerprint)

- Tip advanced `380f87d2` → `8bcf69a8` (#1970 S6/S7 High tip-pass learnings). `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **81**, teachSpec **80**, explain-teachSpec **34**, nice-ladder **44**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **47**. Catalog parents tip-commented on new SHA — no checklist rebuild (counts match prior sync).
- Soft timing **LPT-242** still all five `act-05-07-01-*` MISSING `teachSpec` (GrokBot IP). Soft timing densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper 47 — stay on **LPT-628**). **LPT-312** Map turn still all five `act-07-02-01-*` MISSING (atmosphere stays LPT-394 Done `Jh`/`9d`·`Ks`/`Tc`/`2d`/`3s`). SoftPulse-map ABSENT still **24**.
- Honesty **LPT-396** still valid: `act-07-08-01-guided` catalog prompt “Second pair” + Dart streetLabel “Turn · second pair · wet” vs hero `Jh`/`Td` · board `Ts`/`9h`/`8c`/`2d` (top pair T). Tip-commented IP teachSpecs **LPT-252/255/271/275** + fingerprint/honesty **LPT-401/402/405/408/409/411/414/417** (unchecked vs prior `380f87d2` coverage ticket list). Grep `act-05-07-01-*` / `act-07-02-01-*` / `act-07-08-01-*`: no new per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR implement LPT-625 SoftPulse maps (24) OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(81)/635/624(44) OR LPT-396 if tip advances.

## Fold 2026-10-13 tip da985d39 (#1972 LPT-318 pot-type teachSpec)

- Tip advanced `8bcf69a8` → `da985d39` (#1972 LPT-318 Change plans by pot type teachSpec Validated-on-origin/main). Always re-`scan_content_gaps --counts` after ff.
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **81** (flat), teachSpec **80→76**, explain-teachSpec **34→33**, nice-ladder **44→45**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **47**.
- Outcome-tile land: all five `act-07-04-01-*` author `deal.mode` `none` + SoftPulse cues (explain LIMPED/SRP/3-4BET; guided/scaffolded/unguided/checkpoint `nuts`/`cb`/`commit`/`both`). Rebuilt **LPT-624** Nice! from `--gap nice-ladder --markdown` (new row `act-07-04-01-explain`). Tip-commented **LPT-626** (scaffolded/unguided already listed — pressHints still **151**), **LPT-627** flat, **LPT-625**/ **LPT-628**/ **LPT-635** (keeps **12** S1–S2; do not shrink). Tip-commented Done **LPT-318** catalog follow-ups.
- Soft timing **LPT-242** still all five MISSING; densify Soft timing still ABSENT (helper 47). **LPT-312** Map turn + **LPT-315** Compose river still all five MISSING. Tip-commented S6 **LPT-258**/ **LPT-295**/ **LPT-301**. Honesty **LPT-396** still valid (`Jh`/`Td`·`Ts`/`9h`/`8c`/`2d` top-as-second). Grep `act-07-04-01-*`: no handFamily gaps; no per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 land OR implement LPT-625 SoftPulse maps (24) OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(81)/635/624(45) OR LPT-396 honesty if tip advances.

## Fold 2026-10-13 tip 39754d09 (#1973 LPT-321 + #1975 LPT-324 after #1972 LPT-318)

- Tip `39754d09` after Switch gears + stack-depth teachSpecs (and pot-type already on tip). Always re-`scan_content_gaps --counts` after ff.
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **81** (flat), teachSpec **76→68**, explain-teachSpec **33→31**, nice-ladder **45→47**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **47**.
- Outcome-tile lands (`deal.mode` `none`): rebuilt **LPT-624** Nice! from `--gap nice-ladder --markdown` (FEWER→THICKER→WIDEN; SHORT→DEEP→EFFECTIVE; pot-type LIMPED→SRP→3-4BET already listed). Tip-commented **LPT-626**/ **LPT-627**/ **LPT-625**/ **LPT-628**/ **LPT-635** (keeps **12** S1–S2; pressHints still **151** — tip-comment only, no new rows). Marked **LPT-324** Done (tip already satisfied while still In Progress). Tip-commented Done **LPT-321**.
- Meet Nit still on **LPT-624**/ **LPT-626** (LPT-216 Done — no clones). Soft timing **LPT-242** still all five MISSING; densify Soft timing ABSENT (helper 47). **LPT-312**/ **LPT-315** still open; **LPT-396** still valid. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: LPT-242 after GrokBot OR LPT-312/315 OR LPT-328 same-cards OR LPT-625 SoftPulse maps (24) OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(81)/635/624(47) OR LPT-396.

## Fold 2026-10-13 (monitor) — sync_primary chore-content-*

- Loop `sync_primary` previously only returned
  `cursor/chore-content-agent-learnings-*` to `main`. Agents also open
  `cursor/chore-content-learnings-*`, `cursor/chore-content-nice47-*`,
  and `cursor/chore-content-lptNNNN-*` learnings chores from PRIMARY,
  so the next run audited against a stale chore tip and re-struggled
  (duplicate Nice! drafts #1976/#1977, stuck off `1459c22f`).
- Widened case to all `cursor/chore-content-*` / `chore/content-*` when
  the tree is clean. Durable Never: ship learnings to git same tick +
  leave PRIMARY on `main`.
- Closed conflicted supersession #1967; closed duplicate #1976 in favor
  of #1977.

## Fold 2026-10-13 tip 5f6741ab (#1979 LPT-645/646 densify + #1978 sync_primary)

- Tip advanced through `1459c22f` (#1974 learnings) → `39754d09`/`3328c056` (#1975/#1977) → `b866ee11` (#1979 densify) → `5f6741ab` (#1978). Always re-`scan_content_gaps --counts` after ff mid-run.
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **81**, teachSpec **68**, explain-teachSpec **31**, nice-ladder **47**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **47→53**.
- Immediately rebuilt catalog densify-tap **LPT-628** from `selectIdentifyDensifiedCoachLine` (strip quotes): helper **53**; Priority ABSENT still seat-footer + Soft timing `act-05-07-01-*` (incl. guided); fallthrough **153→147**. Relates LPT-645/646↔LPT-628. Tip-commented LPT-624/625/626/627/635 (JSON flat — no rebuild) + Done ack LPT-645/646 + IP Soft timing LPT-242.
- Grep `act-07-05-01-*` / `act-07-06-01-*`: teachSpec PRESENT (LPT-321/324 Done). Frontier **LPT-328** `act-07-07-01-*` all five MISSING — tip-commented. Map turn LPT-312 / Compose river LPT-315 / Soft timing LPT-242 still MISSING. Honesty LPT-396 still valid `Jh`/`Td`·`Ts`/`9h`/`8c`/`2d` top-as-second. needs-human LPT-348 keep off LPT-626. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR implement LPT-328 same-cards teachSpec OR densify Soft-timing/seat-footer on LPT-628 OR LPT-625 SoftPulse maps (24) OR catalog LPT-626(151)/627(81)/635/624(47) OR LPT-396 if tip advances.

## Fold 2026-10-13 tip cbecf233 (#1980 learnings — tip-stable after densifyHelperArms 53)

- Tip advanced `5f6741ab`/`de212b1e`/`1288535b` → `cbecf233` (#1980 learnings after #1979 densify). `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **81**, teachSpec **68**, explain-teachSpec **31**, nice-ladder **47**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **53**. Catalog parents already checklist-synced on densify tip — tip-comment only, no rebuild.
- Soft timing **LPT-242** still all five `act-05-07-01-*` MISSING; Soft timing densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper **53** — stay on **LPT-628**). Frontier **LPT-328** same-cards all five MISSING; **LPT-312**/ **LPT-315** still MISSING.
- Honesty **LPT-396** still valid: `act-07-08-01-guided` prompt "Second pair" + Dart streetLabel "Turn · second pair · wet" vs hero `Jh`/`Td` · board `Ts`/`9h`/`8c`/`2d` (top pair T). Tip-commented parents LPT-624/625/626/627/628/635 + Highs Soft timing/Map turn/Compose river/same-cards/honesty + S6/S7 IP + fingerprint/needs-human batch. Grep `act-05-07-01-*` / `act-07-07-01-*` / `act-07-08-01-*`: no new per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315/328 OR densify Soft-timing/seat-footer on LPT-628 OR LPT-625 SoftPulse maps (24) OR catalog LPT-626(151)/627(81)/635/624(47) OR LPT-396 if tip advances.

## Fold 2026-10-13 tip 872a8183 (#1981 LPT-328 same-cards teachSpec)

- Mid-run tip advanced `cbecf233` → `872a8183` (#1981 LPT-328 Replay the same hand versus each type teachSpec Validated-on-origin/main). Always re-`scan_content_gaps --counts` after ff.
- `scan_content_gaps --counts`: pressHints **151** (flat), deal-variants **81→84**, teachSpec **68→64**, explain-teachSpec **31→30**, nice-ladder **47→48**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **53**.
- Rebuilt **LPT-624** Nice! from `--gap nice-ladder --markdown` (new `act-07-07-01-explain` CARDS→MODELS→CITE). Rebuilt **LPT-627** from `--gap deal-variants --markdown` (guided/scaffolded/unguided `fixed` sans variants). Tip-commented **LPT-626** (scaffolded/unguided already listed — pressHints still **151**), **LPT-625**/ **LPT-628**/ **LPT-635** (keeps **12** S1–S2; do not shrink). Done-ack **LPT-328** catalog follow-ups (ticket already Done on tip).
- Soft timing **LPT-242** still all five MISSING; densify Soft timing still ABSENT (helper 53). Next teachSpec frontier **LPT-312** Map turn / **LPT-315** Compose river. Honesty **LPT-396** still valid (`Jh`/`Td`·`Ts`/`9h`/`8c`/`2d` top-as-second). Grep `act-07-07-01-*`: no handFamily gaps; no per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR densify Soft-timing on LPT-628 OR LPT-625 SoftPulse maps (24) OR catalog LPT-626(151)/627(84)/635/624(48) OR LPT-396 if tip advances.

## Fold 2026-10-13 tip 872a8183 (tip-stable re-check — unchecked Highs)

- Tip still `872a8183` after #1981 LPT-328 catalog sync already on coverage. `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **84**, teachSpec **64**, explain-teachSpec **30**, nice-ladder **48**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **53**. Catalog parents already checklist-synced this SHA — skipped rebuild/re-spam.
- Soft timing **LPT-242** still all five `act-05-07-01-*` MISSING; Soft timing densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper **53** — stay on **LPT-628**). **LPT-312** Map turn + **LPT-315** Compose river still all five MISSING (grep `act-07-02-01-*` / `act-07-03-01-*`: outcome-tile SoftPulse classes; no handFamily gaps).
- Honesty **LPT-396** still valid: `act-07-08-01-guided` catalog prompt “Second pair” + Dart streetLabel “Turn · second pair · wet” vs hero `Jh`/`Td` · board `Ts`/`9h`/`8c`/`2d` (top pair T). Tip-commented unchecked Highs absent from prior `872a8183` coverage ticket list: S6 **LPT-258**/ **LPT-295**/ **LPT-301**; IP **LPT-252**/ **LPT-255**/ **LPT-271**/ **LPT-275**; companion **LPT-331**; capstones **LPT-334**…**352**; needs-human **LPT-348**; fingerprint/honesty **LPT-401**/ **402**/ **405**/ **408**/ **409**/ **411**/ **414**/ **417**. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 land OR densify Soft-timing/seat-footer on LPT-628 OR LPT-625 SoftPulse maps (24) OR catalog LPT-626(151)/627(84)/635/624(48) OR LPT-396 if tip advances.


## Fold 2026-10-13 tip a55b968e (#1983 learnings + #1985 LPT-396)

- Tip advanced `872a8183` (#1981 LPT-328) → `fa4fb660` (#1985 LPT-396 second-pair board) → `a55b968e` (#1983 learnings). Always re-`scan_content_gaps --counts` + re-read ActionSpot after honesty lands mid-run.
- `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **84**, teachSpec **64**, explain-teachSpec **30**, nice-ladder **48**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **53**. Parents tip-comment only.
- **LPT-396 Done**: `act-07-08-01-guided` now `Jh`/`Td` · `Kh`/`Ts`/`8h`/`2d` (true second pair under K). Corrected stale “still valid Ts9h8c2d” tip-comment. Edited companion **LPT-331** body guided codes to tip atmosphere.
- Soft timing **LPT-242** still all-five MISSING; densify Soft timing ABSENT (helper 53). Frontiers **LPT-312**/ **LPT-315**. Prefer: re-read ActionSpot before honesty “still valid”. Pending cleared. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(84)/635/624(48)/625(24).

## Fold 2026-10-13 tip c20d28d9 (#1987 LPT-331 type×board teachSpec)

- Tip advanced `a55b968e` → `582dea5d` (#1987 LPT-331) → `c20d28d9` (#1986 learnings). Always re-scan after ff — first tip-comment pass wrongly claimed flat 48/84 before noticing #1987.
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **84→87**, teachSpec **64→60**, explain-teachSpec **30→29**, nice-ladder **48→49**, SoftPulse-map **24**, densifyHelperArms **53**.
- Rebuilt **LPT-624** (new `act-07-08-01-explain`) + **LPT-627** (guided/scaffolded/unguided fixed sans variants; guided `Jh`/`Td`·`Kh`/`Ts`/`8h`/`2d`). Tip-commented LPT-626 (scaffolded/unguided still listed) / LPT-625 (unguided SoftPulse-map still ABSENT) / LPT-628 / LPT-635 (keeps 12 S1–S2). Done-ack **LPT-331**.
- Soft timing **LPT-242** still all-five MISSING; densify ABSENT. Frontiers **LPT-312**/ **LPT-315**. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(87)/635/624(49)/625(24).

## Fold 2026-10-13 tip 34010f3e (#1989 ui-agent status — tip-stable after LPT-331 catalog)

- Tip advanced `c20d28d9`/`47b1f956` (#1987/#1988 LPT-331 Nice! **48→49** / deal-variants **84→87**) → `34010f3e` (#1989 ui-agent status idle-skip reason). Always re-`scan_content_gaps --counts` after ff; non-content ops tip keeps JSON gaps flat.
- `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **87**, teachSpec **60**, explain-teachSpec **29**, nice-ladder **49**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **53**. Rebuilt **LPT-624**/ **LPT-627** bodies to clear broken `{{{{{sha}}}}}` placeholder (checklist counts already matched). Tip-commented LPT-626/625/628/635 + frontier Highs LPT-242/312/315 + unchecked S6/S7/capstone/fingerprint/needs-human batch.
- Soft timing **LPT-242** still all five `act-05-07-01-*` MISSING; Soft timing densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper **53** — stay on **LPT-628**). **LPT-312** Map turn + **LPT-315** Compose river still all five MISSING. LPT-328/331/396 Done. Grep `act-07-02-01-*` / `act-07-03-01-*` / `act-07-08-01-*`: outcome-tile / fixed teachSpec patterns; no new per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 land OR densify Soft-timing/seat-footer on LPT-628 OR LPT-625 SoftPulse maps (24) OR catalog LPT-626(151)/627(87)/635/624(49) OR fingerprint Highs if tip advances.

## Fold 2026-10-13 tip c8904ca9 (#1991 learnings — tip-stable)

- Tip still `c8904ca9` after #1991 learnings (prior coverage already synced catalog parents on this SHA). `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **87**, teachSpec **60**, explain-teachSpec **29**, nice-ladder **49**, unguided-softpulse-map **24**, `densifyHelperArms` **53**. Skip parent rebuild/re-spam when coverage already has catalog sync for *this* SHA and counts match.
- Tip-commented unchecked S6/S7/capstone Highs (LPT-252/255/258/271/275/295/301/334/337/339/341/345/347/349/352) + honesty/fingerprint Highs (LPT-401/402/405/408/409/411/414/417) + needs-human LPT-348 + Medium LPT-370/588. Skipped re-spam LPT-242/312/315 + catalog parents (already in prior coverage ticket list for this SHA).
- Soft timing **LPT-242** still all five `act-05-07-01-*` MISSING; Soft timing densify still ABSENT (helper **53** — stay on **LPT-628**). **LPT-312** / **LPT-315** still all five MISSING. Honesty still valid: Gutshot-ish air feedback (LPT-414), NNbb sans stackLabel (LPT-417), Weak TPTK (LPT-401), Q83tt (LPT-405). Grep `act-05-07-01-*` / `act-07-02-01-*` / `act-07-03-01-*`: outcome-tile teachSpec patterns; no new per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty (0 bullets). `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 land OR densify Soft-timing/seat-footer on LPT-628 OR LPT-625 SoftPulse maps (24) OR catalog LPT-626(151)/627(87)/635/624(49) OR fingerprint Highs if tip advances.

## Fold 2026-10-13 tip 4a5c557e (#1993 LPT-337 Capstone SRP teachSpec)

- Tip advanced through `8b2e3013` (#1993) → `4a5c557e` (#1992 learnings). First tip-comment pass wrongly claimed flat 49/87 — always re-scan after ff.
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **87→88**, teachSpec **60→59**, explain-teachSpec **29→28**, nice-ladder **49→50**, SoftPulse-map **24**, densifyHelperArms **53**.
- Rebuilt **LPT-624** (`act-07-10-01-explain`) + **LPT-627** (`act-07-10-01-hand` authored_multi_step_hand fixed Ah/Qd·Kc7s2h2d9c sans variants). Tip-commented LPT-626/625/628/635. Done-ack **LPT-337**.
- Soft timing **LPT-242** still all-five MISSING; densify ABSENT. Frontiers **LPT-312**/ **LPT-315**. Meet Nit still LPT-624/626. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(88)/635/624(50)/625(24).

- Tip-stable High tip-comment pass on same SHA: catalog parents LPT-626/625/628/635 tip-commented (flat vs rebuilt 624/627); tip-commented unchecked S6/S7/capstone Highs LPT-252/255/258/271/275/295/301/334/339/341/345/347/349/352 + honesty/fingerprint LPT-401/402/405/408/409/411/414/417 + needs-human LPT-348 + frontier LPT-242/312/315 with corrected 151/88/59/28/nice-50 counts. Soft timing densify still ABSENT (helper **53**). Pending empty.

## Fold 2026-10-13 tip 3689fc40 (#1995 learnings — tip-stable after LPT-337)

- Tip advanced `4a5c557e` → `3689fc40` (#1995 learnings after #1993 LPT-337 Capstone SRP). Prior coverage already had a catalog sync line for this tip SHA with flat 151/88/59/28/nice-50 — skip parent rebuild/re-spam; tip-comment only.
- `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **88**, teachSpec **59**, explain-teachSpec **28**, nice-ladder **50**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **53**. Soft timing densify still ABSENT (`rex_coach_line.dart` `selectIdentifyDensifiedCoachLine` has zero `act-05-07-01` arms — stay on **LPT-628**).
- Tip-commented catalog parents LPT-624/626/627/625/628/635 + frontier Highs LPT-242/312/315 (all five still MISSING) + unchecked S6/S7/IP teachSpecs LPT-252/255/258/271/275/295/301/334 + capstones LPT-339/341/345/347 + warm-up/final LPT-349/352 + needs-human LPT-348 + honesty/fingerprint LPT-401/402/405/408/409/411/414/417 (LPT-417 still sees 180/250bb depth chrome).
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. Next teachSpec frontier after LPT-337: Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315**; next Capstone Highs LPT-339…. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty (0 bullets). `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(88)/635/624(50)/625(24) OR Capstone 3-bet LPT-339.

## Fold 2026-10-13 tip 5be698bd (#1997 LPT-405 Q83r honesty)

- Tip advanced `43d19bd8` (#1996 learnings) → `5be698bd` (#1997 LPT-405). Honesty-only land — `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **88**, teachSpec **59**, explain-teachSpec **28**, nice-ladder **50**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **53**. Catalog parents tip-comment only (no rebuild).
- Done-ack **LPT-405**: `act-07-10-02-hand` step-3b-flop streetLabel / catalog prompt / authored coach all **Q83r** on rainbow `Qs`/`8h`/`3d` (matches sibling 4-bet). No remaining `Q83tt` in source. Edited open High teachSpec **LPT-339** body/comment off stale Q83tt — teachSpec still MISSING on explain + hand.
- Tip-commented catalog parents LPT-624/626/627/625/628/635 + frontier LPT-242/312/315 + IP teachSpecs LPT-252/255/271/275/301/334 + unchecked To Do Highs LPT-258/295/339/341/345/347/349/352 + needs-human LPT-348 + honesty/fingerprint LPT-401/402/408/409/411/414/417.
- Soft timing **LPT-242** still all-five MISSING; densify ABSENT (helper **53** — stay on **LPT-628**). Frontiers **LPT-312** / **LPT-315**; next Capstone teachSpec **LPT-339**. Grep `act-07-10-02-*`: no new per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty (0 bullets). `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR Capstone LPT-339 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(88)/635/624(50)/625(24).

## Fold 2026-10-13 tip cbb7fb14 (#1999 soft-stop — Capstone LPT-339 re-verify)

- Tip advanced `5be698bd` (#1997 LPT-405) → `cbb7fb14` (#1999 ui-agent soft-stop). Non-content ops tip — `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **88**, teachSpec **59**, explain-teachSpec **28**, nice-ladder **50**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **53**. Catalog parents tip-comment only (no rebuild). Prior #1998 learnings fold was open off `5be698bd` — folded here onto tip so next run reads from git.
- Capstone 3-bet **LPT-339** deep re-verify: `act-07-10-02-explain` + `act-07-10-02-hand` still **MISSING** teachSpec; catalog/Dart already **Q83r** (LPT-405 Done). Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315** still all-five MISSING. Soft timing densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper **53** — stay on **LPT-628**).
- Honesty still valid on tip: **LPT-401** Weak TPTK streetLabel; **LPT-414** Gutshot-ish Air feedback in `course.json`; **LPT-417** `180bb deep` / `250bb` depth chrome without stackLabel.
- Tip-commented catalog parents LPT-624/626/627/625/628/635 + Capstone LPT-339 + frontier LPT-242/312/315 + honesty LPT-401/414/417. Grep `act-07-10-02-*` / `act-05-07-01-*` / `act-07-02-01-*` / `act-07-03-01-*`: no new per-lesson clones. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty (0 bullets). `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR Capstone LPT-339 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(88)/635/624(50)/625(24).

## Fold 2026-10-13 tip d8070119 (#2005 LPT-339 Capstone 3-bet + #2002 LPT-647 densify)

- Tip advanced through #2002 LPT-647 Observe selective densify (`densifyHelperArms` **53→57** / fallthrough **147→143**; Soft timing `act-05-07-01-*` still ABSENT) then #2005 LPT-339 Capstone 3-bet teachSpec.
- `scan_content_gaps --counts` on tip `d8070119`: pressHints **151**, deal-variants **89**, teachSpec **58**, explain-teachSpec **27**, nice-ladder **51**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **57**.
- Verified Capstone 3-bet on tip `course.json`: `act-07-10-02-explain` teachSpec PRESENT (`deal.mode` `none` + SoftPulse SPR→TURN→CLOSE; no `explainGrading`); `act-07-10-02-hand` PRESENT (`deal.mode` `fixed` Ah/Qd + Q83r board + SoftPulse bet→barrel→fold; no `deal.variants`). Done-ack **LPT-339**.
- Rebuilt catalog parents **LPT-624** Nice! **50→51** (`act-07-10-02-explain`) and **LPT-627** deal-variants **88→89** (`act-07-10-02-hand`) from `--gap … --markdown`; also cleared empty SHA / field placeholders left by a prior broken wiki edit. Tip-commented LPT-626/625/635/628 + densify ack on LPT-647 + frontier Highs LPT-242/312/315 (still all-five MISSING).
- Soft timing densify still ABSENT — stay on **LPT-628**. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. Next Capstone Highs LPT-341+. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(89)/635/624(51)/625(24) OR Capstone LPT-341+.

## Fold 2026-10-13 tip 0de0a739 (#2007 learnings — Never unquoted Jira heredocs)

- Tip-stable learnings tip after LPT-339 catalog sync. Flat counts 151/89/58/27/nice-51/map-24 densifyHelperArms 57 — parents tip-comment only.
- First tip-comment batch on this SHA used an unquoted `python3 <<PY` heredoc; shell ate backticks and left empty SHA/`teachSpec` placeholders. Posted corrected comments the same tick. Distilled Never into lesson-content-agent-learnings.md.
- Soft timing densify still ABSENT; frontier LPT-242/312/315; next Capstone LPT-341+. Pending cleared. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(89)/635/624(51)/625(24) OR Capstone LPT-341+.

## Fold 2026-10-13 tip a92e6cfe (#2010 LPT-648 Meet TAG densify)

- Started on tip-stable `8f62f683` (#2009) with catalog already synced — tip-commented unchecked Capstone/High/honesty tickets (LPT-341+ / LPT-258·295 / IP teachSpecs / LPT-401…417 / LPT-348). Mid-run tip advanced to `a92e6cfe` via #2010 LPT-648 Meet the TAG densify.
- `scan_content_gaps --counts` on tip `a92e6cfe`: pressHints **151**, deal-variants **89**, teachSpec **58**, explain-teachSpec **27**, nice-ladder **51**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **61** (was **57**).
- Verified Meet TAG arms PRESENT: `act-06-11-02-guided` / scaffolded / unguided / checkpoint in `selectIdentifyDensifiedCoachLine`. Soft timing `act-05-07-01-*` still ABSENT. Capstone multiway `act-07-10-03-explain` + `hand` still MISSING teachSpec (Dart still Ah/Qh · Jh/8h/2c nut FD).
- Rebuilt catalog densify-tap **LPT-628** helper **57→61** / fallthrough **143→139**; tip-commented LPT-624/625/626/627/635 + LPT-648 ack + frontier LPT-242/312/315/341. JSON gaps flat — parents tip-comment only aside from LPT-628.
- Distilled Never: nested f-string wiki monospace (`f"{{{{{{sha}}}}}}"` → literal `{{{sha}}}`); use `'{{' + sha + '}}'`. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**. `CATALOG_PARENTS.teachSpec` stays null. Pending home file empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR densify Soft-timing on LPT-628 OR Capstone LPT-341 OR catalog LPT-626(151)/627(89)/635/624(51)/625(24).

## Fold 2026-10-13 tip 8c473b7a (#2014 LPT-341 Capstone multiway + #2012 LPT-649 densify)

- Tip advanced `e5569e82` (#2011) → `8c473b7a` via #2012 LPT-649 Observe wide densify then #2014 LPT-341 Capstone multiway deep teachSpec (+ #2013 ui-agent status).
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **90**, teachSpec **57**, explain-teachSpec **26**, nice-ladder **52**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **65**.
- Verified Capstone multiway teachSpec PRESENT: `act-07-10-03-explain` (`deal.mode` `none` + SoftPulse NUTS→DEEP→NO-BLUFF; no `explainGrading`); `act-07-10-03-hand` (`deal.mode` `fixed` Ah/Qh · Jh/8h/2c…; no `deal.variants`). LPT-341 already **Done** on tip.
- Catalog parents already tip-rebuilt: **LPT-624** Nice! **51→52**, **LPT-627** deal-variants **89→90**, **LPT-628** densifyHelperArms **61→65** / fallthrough **139→135** (LPT-649 arms PRESENT; Soft timing Priority ABSENT). Tip-commented Meet Nit on LPT-624/626 (LPT-216 Done — no clones) + Capstone limped LPT-345 / Compose river LPT-315.
- Soft timing **LPT-242** / Map turn **LPT-312** still all-five MISSING; densify Soft timing ABSENT. Next Capstone High **LPT-345**. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR Capstone LPT-345 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(90)/635/624(52)/625(24).

## Fold 2026-10-13 tip 657b8def (#2017 LPT-650 Meet LAG densify)

- Tip advanced `265f6ce5` (#2015 learnings) → `657b8def` via #2017 LPT-650 Meet the LAG densify. Pending home file empty (stub only).
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **90**, teachSpec **57**, explain-teachSpec **26**, nice-ladder **52**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **69** (was **65**).
- Verified Meet LAG arms PRESENT: `act-06-12-02-guided` / scaffolded / unguided / checkpoint in `selectIdentifyDensifiedCoachLine`. Soft timing `act-05-07-01-*` still ABSENT. Capstone limped `act-07-10-04-explain` + `hand` still MISSING teachSpec (run-memory NUTS/VALUE/THIN + Ah/Kh · Kd9c4h multi-step).
- Rebuilt catalog densify-tap **LPT-628** helper **65→69** / fallthrough **135→131**; tip-commented LPT-624/625/626/627/635 (JSON flat) + LPT-650 arms-PRESENT ack (leave Done to ui-agent Validated-on-origin/main) + Capstone/frontier/High/honesty/fingerprint unchecked (LPT-345/242/312/315/252…352/401…417/348).
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR Capstone LPT-345 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(90)/635/624(52)/625(24).

## Fold 2026-10-13 tip 4a199707 (#2019 LPT-651 Adjust LAG densify)

- Tip advanced after #2018 learnings / #2017 LPT-650 → `4a199707` via #2019 LPT-651 Adjust versus LAG densified frame speech. Pending home file empty (stub only).
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **90**, teachSpec **57**, explain-teachSpec **26**, nice-ladder **52**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **71** (was **69**).
- Verified Adjust LAG arms PRESENT: `act-06-12-03-unguided` / `act-06-12-03-checkpoint` in `selectIdentifyDensifiedCoachLine` (guided/scaffolded not in this densify land). Soft timing `act-05-07-01-*` still ABSENT. Capstone limped `act-07-10-04-explain` + `hand` still MISSING teachSpec. Adjust LAG teachSpec High LPT-301 still all-five MISSING (densify ≠ teachSpec).
- Rebuilt catalog densify-tap **LPT-628** helper **69→71** / fallthrough **131→129**; tip-commented LPT-624/625/626/627/635 (JSON flat) + LPT-651 arms-PRESENT ack (leave Done to ui-agent Validated-on-origin/main) + Capstone/frontier/High/honesty/fingerprint unchecked (LPT-345/242/312/315/252…352/401…417/348/301). Relates LPT-651↔LPT-628.
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR Capstone LPT-345 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(90)/635/624(52)/625(24).

## Fold 2026-10-13 tip 99f9889b (#2022 LPT-345 Capstone limped)

- Started tip-stable `cff31614` (#2020 learnings after #2019 LPT-651) with catalog already synced — tip-commented parents + frontier LPT-345/242/312/315 + densify≠teachSpec LPT-301. Mid-run tip advanced to `99f9889b` via #2022 LPT-345 Capstone limped teachSpec.
- `scan_content_gaps --counts` on tip `99f9889b`: pressHints **151**, deal-variants **91**, teachSpec **56**, explain-teachSpec **25**, nice-ladder **53**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **71**.
- Verified Capstone limped teachSpec PRESENT: `act-07-10-04-explain` (`deal.mode` `none` + SoftPulse NUTS→VALUE→THIN; no `explainGrading`); `act-07-10-04-hand` (`deal.mode` `fixed` Ah/Kh · Kd/9c/4h/2s/8d + cues bet/barrel/value; no `deal.variants`). SoftPulse-quiet hand not on pressHints scanner checklist (still **151**).
- Rebuilt **LPT-624** Nice! **52→53**; rebuilt **LPT-627** deal-variants **90→91**; tip-commented LPT-626/625/628/635 (pressHints/map/densify flat; explain-teachSpec drop — keep 12 S1–S2); Done-ack **LPT-345**; tip-commented next Capstone **LPT-347** still both MISSING + frontier LPT-242/312/315.
- Soft timing densify still ABSENT; densify ≠ teachSpec LPT-301. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR Capstone LPT-347 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(91)/635/624(53)/625(24).

## Fold 2026-10-13 tip f6d22a26 (#2024 LPT-652 Adjust TAG densify)

- Tip advanced `99f9889b`/#2023 learnings → `f6d22a26` via #2024 LPT-652 Adjust versus TAG densified frame speech. Pending empty.
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **91**, teachSpec **56**, explain-teachSpec **25**, nice-ladder **53**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **72** (was **71**).
- Verified `act-06-11-03-checkpoint` PRESENT in `selectIdentifyDensifiedCoachLine`. Soft timing `act-05-07-01-*` still ABSENT. Capstone 4-bet LPT-347 still both MISSING.
- Tip-commented **LPT-628** helper **71→72** / fallthrough **129→128** + flat parents LPT-624/625/626/627/635 + LPT-652 arms-PRESENT ack (leave Done to ui-agent Validated-on-origin/main) + frontier LPT-242/312/315/347.
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR Capstone LPT-347 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(91)/635/624(53)/625(24).

## Fold 2026-10-13 tip 2f755e89 (#2025 learnings after LPT-652)

- Tip-stable learnings tip after #2024 LPT-652 densify / #2025 fold. Prior coverage already had a densify-tap sync line for this SHA; JSON gaps still flat — no catalog parent body rebuild.
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **91**, teachSpec **56**, explain-teachSpec **25**, nice-ladder **53**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **72**. Soft timing `act-05-07-01-*` still ABSENT from `selectIdentifyDensifiedCoachLine`.
- Re-verified Capstone 4-bet **LPT-347**: `act-07-10-05-explain` / `act-07-10-05-hand` still both MISSING teachSpec (SPR/COMMIT/NO HERO explain; Kh/Kd · Q83r/+2d/+Ad hand SoftPulse-quiet — author `deal.mode` `fixed` + variants; skip `needs-human` lesson-split). Frontier Soft timing LPT-242 / Map turn LPT-312 / Compose river LPT-315 still MISSING.
- Tip-commented catalog parents LPT-624/625/626/627/628/635 (flat) + Capstone/frontier + unchecked High teachSpecs LPT-301/258/295/252/255/271/275/334/349/352 + needs-human LPT-348 (`noHintIds` stay off LPT-626) + honesty/fingerprint LPT-417 (250bb/180bb still in `lesson_action_table.dart`) / LPT-401/402/408/409/411/414.
- Densify ≠ teachSpec (LPT-301). Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR Capstone LPT-347 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(91)/635/624(53)/625(24).

## Fold 2026-10-13 tip cb3f2076 (#2026 learnings + #2027 ui-agent status)

- Tip advanced `2f755e89`/#2026 learnings → `cb3f2076` via #2027 ui-agent status log-preview skip (non-content ops). Coverage already had catalog sync lines for this SHA; JSON gaps still flat — parents tip-comment only, no rebuild.
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **91**, teachSpec **56**, explain-teachSpec **25**, nice-ladder **53**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **72**. Soft timing `act-05-07-01-*` still ABSENT from `selectIdentifyDensifiedCoachLine` (helper 72; stay on LPT-628).
- Re-verified Capstone 4-bet **LPT-347**: `act-07-10-05-explain` / `act-07-10-05-hand` still both MISSING teachSpec. Dart still SoftPulse SPR/COMMIT/NO HERO (`Capstone4betDemo`) + `resolveToyHandStepSpot` Kh/Kd · Qs/8h/3d/+2d/+Ad SoftPulse-quiet — author `deal.mode` `fixed` + variants; skip `needs-human` lesson-split. Frontier Soft timing LPT-242 / Map turn LPT-312 / Compose river LPT-315 / Adjust LAG LPT-301 still all-five MISSING. Honesty LPT-417 still valid (250bb / 180bb deep chrome sans `stackLabel`).
- Tip-commented catalog parents LPT-624/625/626/627/628/635 + Capstone LPT-347 + frontier LPT-242/312/315/301 + honesty LPT-417. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-347 after GrokBot OR LPT-242/312/315 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(91)/635/624(53)/625(24).

## Fold 2026-10-13 tip 1c0553ff (LPT-628 body lag after LPT-652 tip-comments)

- Tip-stable `1c0553ff` (#2028 learnings after #2027). JSON gaps flat: pressHints **151**, deal-variants **91**, teachSpec **56**, explain-teachSpec **25**, nice-ladder **53**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **72**. Soft timing `act-05-07-01-*` still ABSENT.
- Coverage/tip-comments claimed densify-tap **LPT-628** rebuilt on LPT-652 (`71→72`), but description still said helper **71** / fallthrough **~129** / SHA audited `4a199707` and omitted `act-06-11-03-checkpoint` from Already registered. Rebuilt body from `selectIdentifyDensifiedCoachLine` + SI/PR fallthrough excluding catalog tap|pick prompts → helper **72** / fallthrough **128**; Soft timing still Priority ABSENT. Relates LPT-652↔LPT-628.
- Re-verified Capstone 4-bet **LPT-347**: `act-07-10-05-explain` / `act-07-10-05-hand` still both MISSING (`Capstone4betDemo` SPR/COMMIT/NO HERO; `resolveToyHandStepSpot` Kh/Kd · Qs/8h/3d/+2d/+Ad SoftPulse-quiet). Frontier Soft timing LPT-242 / Map turn LPT-312 / Compose river LPT-315 / Adjust LAG LPT-301 still MISSING. Honesty LPT-417 still valid (250bb/180bb).
- Tip-commented flat parents LPT-624/625/626/627/635 + Capstone/frontier/honesty. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- Durable rule: tip-comment “rebuilt LPT-628” ≠ body synced — verify description helper count vs `--counts densifyHelperArms` before skip.
- next: re-verify LPT-347 after GrokBot OR LPT-242/312/315 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(91)/635/624(53)/625(24).

## Fold 2026-10-13 tip 75f67c67 (Capstone re-check after #2029 LPT-628 body fold)

- Tip-stable `75f67c67` (#2029 learnings after LPT-628 description helper **72** / fallthrough **128** landed on tip). Prior densify-tap coverage already synced this SHA — no catalog checklist rebuild.
- `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **91**, teachSpec **56**, explain-teachSpec **25**, nice-ladder **53**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **72**. Soft timing `act-05-07-01-*` still ABSENT from `selectIdentifyDensifiedCoachLine` (stay on LPT-628). Verified LPT-628 description Already registered (**72**) matches `--counts`.
- Re-verified Capstone 4-bet **LPT-347** (In Progress; GrokBot branch noted): `act-07-10-05-explain` / `act-07-10-05-hand` still both MISSING teachSpec on tip `course.json`. Dart still SoftPulse SPR/COMMIT/NO HERO (`Capstone4betDemo`) + `resolveToyHandStepSpot` Kh/Kd · Qs/8h/3d/+2d/+Ad SoftPulse-quiet — author `deal.mode` `fixed` + variants; skip `needs-human` lesson-split (synthesis in `unit-07-10-capstones`). Explain row also on catalog LPT-635.
- Tip-commented catalog parents LPT-624/625/626/627/628/635 (flat) + Capstone LPT-347 + frontier LPT-242/312/315/301 + unchecked High teachSpecs LPT-252/255/258/271/275/295/334/349/352 + honesty/fingerprint LPT-401/402/408/409/411/414 + depth LPT-417 (250bb/180bb sans `stackLabel`; LPT-414 Air Nice! still “Gutshot-ish”). Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-347 after GrokBot OR LPT-242/312/315 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(91)/635/624(53)/625(24).

## Fold 2026-10-13 tip d8f1e0fa (#2033 LPT-347 Capstone 4-bet + #2031 LPT-654 densify)

- Tip advanced through #2031 LPT-654 Same cards densify (`densifyHelperArms` **72→73** / fallthrough **128→127**) then #2033 LPT-347 Capstone 4-bet teachSpec (also #2032 duplicate land path).
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **92**, teachSpec **55**, explain-teachSpec **24**, nice-ladder **54**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **73**.
- Verified Capstone 4-bet teachSpec PRESENT: `act-07-10-05-explain` (`deal.mode` `none` + SoftPulse cues ×3; no `explainGrading`); `act-07-10-05-hand` (`deal.mode` `fixed` + SoftPulse cues ×3; no `deal.variants`). Done-ack **LPT-347**.
- Rebuilt **LPT-624** Nice! **53→54**, **LPT-627** deal-variants **91→92**, **LPT-628** densifyHelperArms **72→73**. Tip-commented Meet Nit on LPT-624/626 (LPT-216 Done — no clones) + flat parents + frontier Soft timing LPT-242 / Map turn LPT-312 / Compose river LPT-315 + warm-up LPT-349 / Final LPT-352 + LPT-654 arms ack.
- Soft timing densify still ABSENT — stay on **LPT-628**. Capstone High teachSpecs through 4-bet Done; next Highs warm-up **LPT-349** / Final **LPT-352**. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR LPT-312/315 OR LPT-349/352 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(92)/635/624(54)/625(24).

## Fold 2026-10-13 tip 0092c2ba (#2036 LPT-655 Section 6 checkpoint densify)

- Tip advanced `9db6f952`/#2034 learnings → `0092c2ba` via #2036 LPT-655 Section 6 checkpoint densify (`selectIdentifyDensifiedCoachLine` arms for `act-06-13-02-cp-adv` / `cp-cap` / `cp-polar` / `cp-tag` / `cp-lag`).
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **92**, teachSpec **55**, explain-teachSpec **24**, nice-ladder **54**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **73→78**. Soft timing `act-05-07-01-*` still ABSENT from helper (stay Priority ABSENT on **LPT-628**).
- Immediately rebuilt densify-tap **LPT-628** from `selectIdentifyDensifiedCoachLine` + SI/PR fallthrough excluding catalog tap|pick prompts → helper **78** / fallthrough **122**. Relates LPT-655↔LPT-628. Leave LPT-655 Done to ui-agent Validated-on-origin/main.
- JSON catalog gaps otherwise flat — tip-commented LPT-624/625/626/627/635 only (no checklist rebuild). Tip-commented frontier Soft timing LPT-242 (all five + explain MISSING) / Map turn LPT-312 / Compose river LPT-315 / Adjust LAG LPT-301 / warm-up LPT-349 / Final LPT-352 + honesty/fingerprint LPT-401/402/408/409/411/414/417.
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. Densify ≠ teachSpec. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: re-verify LPT-242 after GrokBot OR densify Soft-timing on LPT-628 OR LPT-312/315 OR LPT-349/352 OR catalog LPT-626(151)/627(92)/635/624(54)/625(24).

## Fold 2026-10-13 tip 7d946ea7 (Soft timing re-check + tip-comment verify)

- Tip-stable `7d946ea7` (#2038 learnings after #2036 LPT-655 densify + LPT-628 rebuild on `0092c2ba`). Pending empty.
- `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **92**, teachSpec **55**, explain-teachSpec **24**, nice-ladder **54**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **78**. Catalog parents already synced — no checklist rebuild. Soft timing `act-05-07-01-*` still ABSENT from `selectIdentifyDensifiedCoachLine` (Priority on **LPT-628**).
- Re-verified Soft timing **LPT-242**: all five `act-05-07-01-{explain,guided,scaffolded,unguided,checkpoint}` still MISSING teachSpec (`deal.mode` `none` + SoftPulse cues; outcome tiles — no handFamily). Frontier Map turn LPT-312 / Compose river LPT-315 / Adjust LAG LPT-301 / warm-up LPT-349 / Final LPT-352 still all MISSING.
- Honesty re-read (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided`; **LPT-417** `act-05-02-01-scaffolded` streetLabel *250bb* + `act-06-09-01-scaffolded` villain/felt *180bb deep* still sans `stackLabel`; **LPT-401** guided Ah4d/As9c7d still "Weak TPTK".
- Prior coverage for this SHA listed many High tip-comments that were missing on Jira — verified with `jira.py get` for `7d946ea7`, then tip-commented LPT-625/627/635 + LPT-242/312/315/352/301 + honesty LPT-401/402/408/409/411/414/417. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- Durable rule: coverage `ticket` lists can over-claim tip-comments — confirm tip SHA on each claimed issue before skip.
- next: re-verify LPT-242 after GrokBot OR densify Soft-timing on LPT-628 OR LPT-312/315/349/352 OR catalog LPT-626(151)/627(92)/635/624(54)/625(24).

## Fold 2026-10-13 tip c03044af → b9398420 (coverage over-claim + #2040 ops)

- Started on tip-stable `c03044af` (#2039 Soft timing tip-comment-verify learnings). Pending empty (zero `- ` bullets).
- `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **92**, teachSpec **55**, explain-teachSpec **24**, nice-ladder **54**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **78**. Catalog parents already rebuilt on `0092c2ba` — no checklist rebuild. Soft timing `act-05-07-01-*` still ABSENT from `selectIdentifyDensifiedCoachLine`.
- Re-verified frontier teachSpecs still all MISSING: Soft timing LPT-242 (`act-05-07-01-*`), Map turn LPT-312 (`act-07-02-01-*`), Compose river LPT-315 (`act-07-03-01-*`), Adjust LAG LPT-301 (`act-06-12-03-*`), warm-up LPT-349 (`act-07-11-01-*`), Final LPT-352 (`act-07-12-01-*`), plus S6 Highs LPT-258 (`act-06-03-01-*`) / LPT-295 / LPT-252 / LPT-255 / LPT-271 / LPT-275 / LPT-334.
- Honesty re-read (no sim): **LPT-414** Air Nice! still "Gutshot-ish trash…" on `act-03-02-01-unguided`; **LPT-417** depth chrome still sans `stackLabel` on 250bb/200bb/180bb spots; **LPT-401** guided still `Flop · Weak TPTK · Heat`.
- Prior coverage for `c03044af` listed many High tip-comments missing on Jira — only LPT-242 + catalog parents had the SHA. Tip-commented 20 unchecked Highs the same tick. Mid-run tip → `b9398420` (#2040 ui-agent soft-stop-hold, non-content): tip-commented parents + LPT-242 on the new SHA without inventing count deltas.
- Durable rule reinforced: coverage `ticket` lists can over-claim — confirm tip SHA via `jira.py get` before skip (also tip `7d946ea7`). Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/349/352 OR catalog LPT-626(151)/627(92)/635/624(54)/625(24).

- Tip `ac29f3e1` (#2041 LPT-656 Carry preflop plan densify + #2040 soft-stop-hold + #2042 learnings): `scan_content_gaps --counts` JSON flat pressHints **151** / deal-variants **92** / teachSpec **55** / explain-teachSpec **24** / nice-ladder **54** / unguided-softpulse-map **24**; densifyHelperArms **78→82** / fallthrough **122→118** (`act-07-01-01-guided` / `scaffolded` / `unguided` / `checkpoint` PRESENT). Rebuilt catalog densify-tap **LPT-628** (description had lagged at helper **78** @ `0092c2ba` while tip already had LPT-656). Soft timing `act-05-07-01-*` still Priority ABSENT. Meet Nit Nice! still LPT-624 (`act-04-07-02-explain` missing `explainGrading`) / pressHints LPT-626 (`act-04-07-02-unguided`); LPT-216 Done — no clones. Leave LPT-656 Done to ui-agent Validated-on-origin/main. densify ≠ teachSpec (LPT-242). Next: Soft timing LPT-242 / Map turn LPT-312 / Compose river LPT-315 / warm-up LPT-349 / Final LPT-352 OR densify Soft-timing on LPT-628 OR catalog LPT-626(151)/627(92)/635/624(54)/625(24).

- Tip `85724074` (#2044 LPT-349 warm-up teachSpec + #2043 LPT-656 densify learnings): `scan_content_gaps --counts` pressHints **151** / deal-variants **92** (flat) / teachSpec **55→51** / explain-teachSpec **24→23** / nice-ladder **54→55** / unguided-softpulse-map **24**; densifyHelperArms **82**. Rebuilt catalog Nice! **LPT-624** (appended `act-07-11-01-explain` CHECKLIST→DEFAULTS→ONE HAND). Done-ack LPT-349 (all five `act-07-11-01-*` PRESENT `deal.mode` `none` + cues). Scaffolded/unguided pressHints stay on **LPT-626**. Meet Nit still LPT-624/626; LPT-216 Done — no clones. Soft timing densify ABSENT; next High Final LPT-352 / Soft timing LPT-242 / Map turn LPT-312 / Compose river LPT-315.

- Tip `7abac821` (#2045 LPT-657 Map turn densify): densifyHelperArms **82→86** / fallthrough **118→114** (`act-07-02-01-guided` / `scaffolded` / `unguided` / `checkpoint` PRESENT). Rebuilt **LPT-628**. Soft timing still ABSENT. densify ≠ teachSpec (LPT-312 Map turn teachSpec still open). Same tip window as LPT-349 Nice! **54→55** rebuild on LPT-624.

## Fold 2026-10-13 tip 2c24d461 (#2048 LPT-352 Final teachSpec)

- Tip advanced `04de5ac5`/#2047 learnings → `2c24d461` via #2048 LPT-352 Final five-type teachSpec (all seven `act-07-12-01-*`).
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **92**, teachSpec **51→44**, explain-teachSpec **23**, nice-ladder **55** (flat — no SoftPulse explain step on final), unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **86**.
- Done-ack **LPT-352** (was In Progress; catalog already matched). Tip-commented LPT-624/625/626/627/628/635 (no checklist rebuild — densify already **86**/114 on `7abac821`). Soft timing densify still ABSENT.
- Frontier remaining High teachSpecs: Soft timing LPT-242 / Map turn LPT-312 / Compose river LPT-315. densify ≠ teachSpec for LPT-312 (LPT-657 arms PRESENT). Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24).

## Fold 2026-10-13 tip 9a7ca173 (#2051 LPT-401 Weak TPTK → Weak top pair)

- Tip advanced `291569c7` → `9a7ca173` via #2051 LPT-401 honesty (`act-03-08-01-guided` streetLabel `Flop · Weak top pair · Heat`; felt-hand-class test updated).
- `scan_content_gaps --counts` flat vs prior tip: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24**; `softpulseMapArms` **68**; `densifyHelperArms` **86**.
- Catalog parents LPT-624/625/626/627/628/635 tip-commented only (checklists already match `--gap … --markdown` — no body rebuild). Soft timing densify `act-05-07-01-*` still **ABSENT** on LPT-628 (LPT-464 Done ≠ helper PRESENT).
- Done-ack **LPT-401** (In Progress → Done). Tip-commented frontier High teachSpecs LPT-242 / LPT-312 / LPT-315 — all five `act-*` still MISSING teachSpec each. densify ≠ teachSpec for LPT-312 (LPT-657 arms PRESENT).
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**. `CATALOG_PARENTS.teachSpec` stays null. Pending empty after fold (0 bullets). `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24).

## Fold 2026-10-13 tip 56f22fa8 (tip-stable after #2052 + LPT-659 densify sibling)

- Tip-stable `56f22fa8` (#2052 learnings after #2051 LPT-401). Pending empty (zero `- ` bullets).
- `scan_content_gaps --counts` flat: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **86**. No catalog checklist rebuild (counts match prior tip).
- Prior coverage for this SHA listed LPT-624/626/628 but `jira.py get` showed LPT-625/627/635 + frontier Highs LPT-242/312/315 lacked `56f22fa8` — tip-commented those the same tick (coverage over-claim includes catalog parents, not only Highs).
- Re-verified Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315**: all five `act-*` still MISSING teachSpec each. Soft timing densify helper arms still ABSENT (LPT-464 Done ≠ PRESENT). densify ≠ teachSpec for LPT-312 (LPT-657 arms PRESENT).
- ui-agent filed densify sibling **LPT-659** (Change plans by pot type `act-07-04-01-guided` / `scaffolded` / `unguided` / `checkpoint` — framed "Tap the best answer"; helper arms ABSENT). Tip-commented LPT-628 + LPT-659; linked Relates. Leave LPT-659 to ui-agent Validated-on-origin/main; rebuild LPT-628 only when helper count moves. Soft timing remains Priority ABSENT on LPT-628.
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315 OR ui-agent LPT-659 pot-type densify OR catalog LPT-626(151)/627(92)/635/624(55)/625(24).

## Fold 2026-10-13 tip 8e5ae40a (#2054 LPT-658 Compose river densify)

- Tip advanced `e785c399`/#2053 learnings → `8e5ae40a` via #2054 LPT-658 Compose river densify (`act-07-03-01-scaffolded` / `unguided` / `checkpoint` helper PRESENT; guided is `poker_action_sizing` — skip).
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, `softpulseMapArms` **68**, `densifyHelperArms` **86→89**.
- Rebuilt densify-tap **LPT-628** body: helper **89** / fallthrough **114→111**; Soft timing `act-05-07-01-*` still Priority ABSENT (LPT-464 Done ≠ PRESENT). Linked Relates LPT-658↔LPT-628. Leave LPT-658 In Progress until ui-agent Validated-on-origin/main.
- Prior coverage on `e785c399` over-claimed tip-comments — `jira.py get` showed **zero** tickets containing that SHA. Tip-commented catalog parents LPT-624/625/626/627/635/628 + LPT-658/659 + frontier/unchecked Highs LPT-242/312/315/301/258/295/252/255/271/275/334 + LPT-348/216/370 + honesty/fingerprint LPT-402/408/409/411/414/417 on tip `8e5ae40a`.
- Re-verified Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315** / Adjust LAG **LPT-301**: all five `act-*` still MISSING teachSpec each. densify ≠ teachSpec for LPT-315 (LPT-658 arms PRESENT) and LPT-312 (LPT-657 arms PRESENT).
- LPT-659 pot-type `act-07-04-01-*` helper arms still ABSENT. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315 OR ui-agent LPT-659 pot-type densify OR catalog LPT-626(151)/627(92)/635/624(55)/625(24).

## Fold 2026-10-13 (monitor) — densify-tap --gap markdown

- Agents were hand-rebuilding LPT-628 after densify siblings because
  `scan_content_gaps --gap densify-tap` was unknown (parent only in
  `CATALOG_PARENTS` / `densifyHelperArms` PRESENT count).
- Added `gapDensifyTap` for `select_identify` + `player_read_classify`
  missing helper arms; `--counts` now emits `densify-tap` ABSENT.
- Prefer: rebuild LPT-628 from `--gap densify-tap --markdown` +
  `densifyHelperArms`; Soft timing `act-05-07-01-*` stays ABSENT until PRESENT.

## Fold 2026-10-13 tip c88437f9 (#2056 densify-tap markdown + #2057 LPT-402)

- Tip advanced `9feec4fa`/#2055 → `c88437f9` via #2056 densify-tap `--gap` markdown, #2057 LPT-402 missed-FD honesty, #2058 primary-busy skip.
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, **densify-tap 140** (new), `softpulseMapArms` **68**, `densifyHelperArms` **89** (flat).
- First catalog rebuild of **LPT-628** from `--gap densify-tap --markdown`: ABSENT **140** (includes early-catalog SI / `player_read_classify`, not only prior hand fallthrough **~111**). Soft timing `act-05-07-01-*` + pot-type LPT-659 `act-07-04-01-*` still ABSENT Priority. Other parents tip-comment only (JSON gaps flat).
- Done-ack **LPT-402**: tip Dart + `teachSpec.deal.fixedCards` now `9s`/`8s` · `Ks`/`7s`/`2h`/`3h`/`Ah` (real missed spade FD; prompt honest). Transitioned Done.
- Prior tip `9feec4fa` coverage missed tip-comments on LPT-408/409/411 + LPT-659 — tip-commented those, then re-commented parents + frontier Highs LPT-242/312/315 + honesty LPT-414/417 on `c88437f9` after mid-run tip advance.
- Re-verified Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315**: all five `act-*` still MISSING teachSpec each. densify ≠ teachSpec. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315 OR ui-agent LPT-659 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(140).

## Fold 2026-10-13 tip 9f5dd58d (#2060 LPT-659/660/661 densify)

- Tip advanced `a5081631`/#2059 learnings → `9f5dd58d` via #2060 densify frame speech for pot-type / HU-MW / stacks (`act-07-04-01-*` / `act-07-05-01-*` / `act-07-06-01-*` helper arms PRESENT).
- `scan_content_gaps --counts`: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, densify-tap **140→128**, `softpulseMapArms` **68**, `densifyHelperArms` **89→101**.
- Rebuilt densify-tap **LPT-628** from `--gap densify-tap --markdown` (body had lagged at densify-tap **140** / helper **89** @ `c88437f9`/`a5081631`). Soft timing `act-05-07-01-*` still Priority ABSENT (LPT-464 Done ≠ PRESENT). Linked Relates LPT-659/660/661↔LPT-628. Leave those ui-agent tickets In Progress for Validated-on-origin/main — content-agent does not Done them.
- Tip-commented catalog parents LPT-624/625/626/627/635/628 + siblings LPT-659/660/661 + frontier/unchecked Highs LPT-242/312/315/252/255/258/271/275/295/301/334 + fingerprint/honesty LPT-408/409/411/414/417.
- Re-verified Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315**: all five `act-*` still MISSING teachSpec each. densify ≠ teachSpec. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(128).

## Fold 2026-10-13 tip 2172c3f4 (#2061 learnings after densify 89→101)

- Tip-stable `2172c3f4` after #2061 learnings (#2060 LPT-659/660/661 densify). `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, densify-tap **128**, `softpulseMapArms` **68**, `densifyHelperArms` **101**. Catalog parent bodies already match (LPT-628 densify-tap **128** / helper **101** @ `9f5dd58d`) — no checklist rebuild.
- Prior coverage on this SHA listed parents+Highs+siblings while `jira.py get` showed **zero** tickets containing `2172c3f4` — tip-commented LPT-624/625/626/627/635/628 + Done-ack LPT-659/660/661 (now **Done**, arms PRESENT) + frontier/unchecked Highs LPT-242/312/315/252/255/258/271/275/295/301/334 + LPT-348 + fingerprint/honesty LPT-408/409/411/414/417.
- Soft timing densify `act-05-07-01-*` still **ABSENT** from `selectIdentifyDensifiedCoachLine` (LPT-464 Done ≠ PRESENT). Re-verified Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315**: all five / guided still MISSING teachSpec. densify ≠ teachSpec.
- Honesty still valid (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided` (`5h`/`4h`·`Qc`/`7d`/`2s`); **LPT-417** `250bb` streetLabel / `180bb deep` villain/felt still sans matching `stackLabel`.
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(128).

## Fold 2026-10-13 tip 1c037025 (#2062) → b03f35e8 (#2063 LPT-662..665 densify)

- Tip-stable `1c037025` after #2062 learnings: JSON flat pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, densify-tap **128**, `densifyHelperArms` **101**. LPT-628 body already matched — no rebuild. Prior coverage over-claimed tip-comments (`jira.py get` zero SHA hits) — tip-commented 26 parents+Highs+Done-ack densify siblings.
- Mid-run tip advanced to `b03f35e8` via #2063 densify frame speech for Write-default-book / Live warm-up / same-cards checkpoint / type-board checkpoint (`act-07-09-01-*` / `act-07-11-01-*` / `act-07-07-01-checkpoint` / `act-07-08-01-checkpoint` helper arms PRESENT).
- `scan_content_gaps --counts`: densify-tap **128→118**, `densifyHelperArms` **101→111**; other JSON gaps flat. Soft timing `act-05-07-01-*` still Priority ABSENT from `selectIdentifyDensifiedCoachLine`.
- Rebuilt densify-tap **LPT-628** from `--gap densify-tap --markdown`. Linked Relates LPT-662/663/664/665↔LPT-628. Leave those ui-agent tickets In Progress for Validated-on-origin/main — content-agent does not Done them. densify ≠ teachSpec (**LPT-334** strategy book still open High).
- Tip-commented catalog parents LPT-624/625/626/627/635/628 + siblings LPT-662..665 + frontier Highs LPT-242/312/315/334 on `b03f35e8`.
- Re-verified Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315**: all five `act-*` still MISSING teachSpec each. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## Fold 2026-10-13bs (tip 7f22b9e7 densify Done-ack)

- Tip-stable `7f22b9e7` (#2064 learnings after #2063 densifyHelperArms 101→111 / densify-tap 128→118): JSON still flat 151/92/44/23/nice-55/map-24 densify-tap **118** densifyHelperArms **111**.
- Prior coverage already tip-commented parents+Highs on this SHA (`jira.py get --json` confirmed hits). Soft timing `act-05-07-01-*` densify still ABSENT from `selectIdentifyDensifiedCoachLine`.
- LPT-662/663/664/665 reached **Done** (Validated-on-origin/main) while LPT-628 body still said leave In Progress — rebuilt LPT-628 from `--gap densify-tap --markdown` with Done-ack wording; tip-commented Done-ack on siblings + Soft timing Priority ABSENT.
- Re-verified Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315** / strategy book **LPT-334**: all five `act-*` still MISSING teachSpec each (densify ≠ teachSpec for 312/315/334). Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## Fold 2026-10-13bt (tip fa1490fd tip-stable High tip-comments)

- Tip-stable `fa1490fd` (#2065 learnings after Done-ack LPT-662..665): JSON still flat 151/92/44/23/nice-55/map-24 densify-tap **118** densifyHelperArms **111**. LPT-628 body counts match — tip-comment only (no rebuild).
- Prior coverage on `fa1490fd` listed densify parents+frontier+Done-ack siblings; `jira.py get` confirmed those had the SHA, but S6/honesty/fingerprint Highs **LPT-252/255/258/271/275/295/301/348/408/409/411/414/417** lacked it — tip-commented those + LPT-628 Soft timing Priority the same tick.
- Soft timing `act-05-07-01-*` densify still ABSENT from `selectIdentifyDensifiedCoachLine` (rex_coach_line zero hits). Frontier **LPT-242/312/315/334** still all-five MISSING teachSpec (densify ≠ teachSpec). Honesty LPT-414/417 still valid. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## Fold 2026-10-13bu (tip 0b226db6 LPT-408 Done-ack)

- Tip advanced mid-run `fa1490fd` → `0b226db6` (#2069 LPT-408 nut-FD remap + #2067/#2068 learnings). JSON gaps still flat 151/92/44/23/nice-55/map-24 densify-tap **118** densifyHelperArms **111**.
- Done-ack **LPT-408** (`nutFlushDraw` in `_postflopTeachKey` + remap test). First tip-comments used an unquoted shell heredoc → empty SHA placeholders — corrected with Python-written bodies (`0b226db6`) on parents + frontier + LPT-409/411/414/417 the same tick.
- Soft timing densify still ABSENT; frontier LPT-242/312/315/334 still MISSING teachSpec; sibling fingerprints LPT-409/411 + honesty LPT-414/417 still open. Meet Nit LPT-624/626. Pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## Fold 2026-10-13bv (tip ea9654be tip-stable catalog sync)

- Tip-stable `ea9654be` (#2071 ui-agent empty-pending stub ignore). `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, densify-tap **118**, `softpulseMapArms` **68**, `densifyHelperArms` **111**. LPT-628 body already matches — tip-comment only (no rebuild).
- Soft timing `act-05-07-01-*` densify still **ABSENT** from `selectIdentifyDensifiedCoachLine` (rex_coach_line zero hits; LPT-464 Done ≠ PRESENT). Re-verified Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315** / strategy book **LPT-334**: all five `act-*` still MISSING teachSpec each (densify ≠ teachSpec).
- Honesty still valid (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided`; **LPT-417** ActionSpot `streetLabel`/`villainLine`/`feltStatusLine` claim 250bb / 180bb deep with **no** `stackLabel` on the spot.
- Tip-commented catalog parents LPT-624/625/626/627/635/628 + frontier/unchecked Highs LPT-242/312/315/334/252/255/258/271/275/295/301/348 + fingerprint/honesty LPT-409/411/414/417 + LPT-370/216/408 on `ea9654be` (prior tip SHA absent on all).
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. Home pending empty (stub only). `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## Fold 2026-10-13bw (tip fe717e39 tip-stable High tip-comments)

- Tip-stable `fe717e39` (#2072 learnings after ea9654be/#2071). `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, densify-tap **118**, `softpulseMapArms` **68**, `densifyHelperArms` **111**. Catalog parent bodies match — no rebuild; parents + frontier LPT-242/312/315/334 already had tip SHA.
- Soft timing `act-05-07-01-*` densify still **ABSENT** from `selectIdentifyDensifiedCoachLine` (helper **111**; LPT-464 Done ≠ PRESENT). Frontier Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315** / strategy book **LPT-334** still all-five MISSING teachSpec (densify ≠ teachSpec).
- Honesty / fingerprint still valid (no sim): **LPT-414** Gutshot-ish Air Nice! on `act-03-02-01-unguided`; **LPT-417** 250bb / 180bb deep chrome sans `stackLabel`; **LPT-409** pair-depth / **LPT-411** set-depth still missing from `_postflopTeachKey`.
- Prior coverage on `fe717e39` listed only densify parents + frontier — `jira.py get` showed S6/honesty Highs lacked the SHA. Tip-commented **12**: LPT-252/255/258/271/275/295/301/348 + LPT-409/411/414/417 (Python body files; all five teachSpec still MISSING on each S6 High).
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. Home pending empty (stub only). `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## Fold 2026-10-13bx (tip 275d3d5c LPT-409 Done-ack)

- Tip advanced `da1e4dcd` → `275d3d5c` (#2074 LPT-409 pairDepth remap). `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, densify-tap **118**, `softpulseMapArms` **68**, `densifyHelperArms` **111**. Catalog parent bodies match — tip-comment only (no rebuild); parents + frontier LPT-242/312/315/334 already had tip SHA.
- Done-ack **LPT-409**: `_postflopTeachKey` now includes `pairDepth` (+ `nutFlushDraw` from LPT-408). **LPT-411** still open — `setDepth` ABSENT. Soft timing `act-05-07-01-*` densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper **111**; Priority on LPT-628). Frontier Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315** / strategy book **LPT-334** still all-five MISSING teachSpec (densify ≠ teachSpec).
- Honesty still valid (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided` (`5h 4h` / `Qc 7d 2s`); **LPT-417** ActionSpot cases still claim 250bb / 200bb / 180bb with **no** nearby `stackLabel`.
- `jira.py get` on tip `275d3d5c`: parents+frontier+LPT-409/411 had the SHA; S6/honesty Highs lacked it — tip-commented LPT-252/255/258/271/275/295/301/348/414/417 + LPT-628 Soft timing Priority + LPT-411 setDepth-still-open (Python body files).
- Grep `act-05-07-01-*` / `act-03-02-01-unguided` / `act-07-02-01-*` / `act-07-03-01-*` / `act-07-09-01-*`: Soft timing outcome tiles + frontier teachSpec gaps; no new per-lesson clones. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done. Home pending empty (stub only). `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-411 setDepth OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## Fold 2026-10-13by (tip 38c2a91e LPT-411 Done-ack)

- Tip advanced `6f674057` (#2075 learnings) → `38c2a91e` (#2076 LPT-411 setDepth remap) mid-run. `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, densify-tap **118**, `softpulseMapArms` **68**, `densifyHelperArms` **111**. Catalog parent bodies match — tip-comment only (no rebuild).
- Prior coverage on `6f674057` listed parents+frontier+LPT-411/414/417 while S6 Highs lacked the SHA — tip-commented LPT-252/255/258/271/275/295/301/348 on `6f674057`, then re-commented those + parents+frontier+honesty on `38c2a91e` after the tip advance.
- Done-ack **LPT-411**: `_postflopTeachKey` now includes `setDepth` (+ `pairDepth` / `nutFlushDraw` from LPT-409/408). Fingerprint class LPT-408/409/411 **Done**. Soft timing `act-05-07-01-*` densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper **111**; Priority on LPT-628). Frontier Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315** / strategy book **LPT-334** still all-five MISSING teachSpec (densify ≠ teachSpec).
- Honesty still valid (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided`; **LPT-417** ActionSpot cases still claim 250bb / 200bb / 180bb with **no** nearby `stackLabel`.
- Grep `act-05-07-01-*` / `act-03-02-01-unguided` / `act-07-02-01-*` / `act-07-03-01-*` / `act-07-09-01-*`: Soft timing outcome tiles + frontier teachSpec gaps; no new per-lesson clones. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done. Home pending empty (stub only). `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## Fold 2026-10-13bz (tip 25681d70 LPT-417 Done-ack)

- Tip advanced `93572f67` (#2077 learnings) → `25681d70` (#2078 LPT-417 deep-stack seat chips). `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, densify-tap **118**, `softpulseMapArms` **68**, `densifyHelperArms` **111**. Catalog parent bodies match (LPT-628 densify-tap **118** / helper **111**) — tip-comment only (no rebuild).
- Done-ack **LPT-417**: all four listed ActionSpot cases now author matching `stackLabel` on tip — `act-05-02-01-scaffolded` 250bb→Stacks left 500; `act-05-03-01-guided` 200bb→400; `act-06-09-01-scaffolded` 180bb→360; `act-04-10-01-checkpoint` 200bb→400. GrokBot already Validated-on-origin/main; content-agent re-verify + Done-ack comment. Soft timing `act-05-07-01-*` densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper **111**; Priority on LPT-628). Frontier Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315** / strategy book **LPT-334** still all-five MISSING teachSpec (densify ≠ teachSpec).
- Honesty still valid (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided` (`5h 4h` / `Qc 7d 2s`). Fingerprint class LPT-408/409/411 already Done; depth-chrome honesty LPT-417 Done.
- Tip-commented catalog parents LPT-624/625/626/627/628/635 + frontier LPT-242/312/315/334 + S6 Highs LPT-252/255/258/271/275/295/301 + LPT-414/348 + LPT-417 Done-ack on `25681d70` (Python body files; prior tip `38c2a91e` SHA only).
- Grep `act-05-07-01-*` / `act-03-02-01-unguided` / deep-stack / stackLabel: Soft timing densify ABSENT; LPT-414 still open; no new per-lesson clones. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done. Home pending empty (stub only). `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## Fold 2026-10-13ca (tip a4c9db38 tip-stable after #2079)

- Tip-stable `a4c9db38` (#2079 learnings after #2078 LPT-417 Done-ack). `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, densify-tap **118**, `softpulseMapArms` **68**, `densifyHelperArms` **111**. Catalog parent bodies match (LPT-628 densify-tap **118** / helper **111**) — tip-comment only (no rebuild). Parents + frontier LPT-242/312/315/334 + honesty LPT-414 already had tip SHA.
- Prior coverage on `a4c9db38` listed parents+frontier+LPT-414/417 while S6 Highs lacked the SHA — tip-commented LPT-252/255/258/271/275/295/301/348 + Done-ack LPT-417 (Python body files; `jira.py get` verified).
- Soft timing `act-05-07-01-*` densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper **111**; Priority on LPT-628). Frontier Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315** / strategy book **LPT-334** still all-five MISSING teachSpec (densify ≠ teachSpec).
- Honesty still valid (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided` (`5h 4h` / `Qc 7d 2s`). LPT-417 already Done (stackLabels PRESENT) — Done-ack only.
- Grep `act-05-07-01-*` / `act-03-02-01-unguided`: Soft timing outcome tiles + LPT-414 honesty; no new per-lesson clones. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done. Home pending empty (stub only). `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13cb — tip `2aac4238` (#2081 ui-agent idle wake ETA)

- Tip advanced `c6f50a24` → `2aac4238` (#2081 ui-agent status idle-wake ETA — non-content). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Catalog parents tip-comment only (LPT-628 body densify-tap **118** / helper **111** match — no rebuild).
- Soft timing densify still ABSENT from `selectIdentifyDensifiedCoachLine` (`act-05-07-01-*` Priority on **LPT-628**). Soft timing teachSpec **LPT-242** still all five MISSING; frontier **LPT-312/315/334** still MISSING. densify ≠ teachSpec.
- Honesty still valid (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided` (`5h`/`4h`·`Qc`/`7d`/`2s`, zero straight outs; SoftPulse `air` correct).
- Tip-commented parents LPT-624/625/626/627/628/635 + frontier LPT-242/312/315/334 + S6 Highs LPT-252/255/258/271/275/295/301 + needs-human LPT-348 + honesty LPT-414 + Done-ack LPT-417/401/402/408/409/411 (`pairDepth`/`setDepth`/`nutFlushDraw` PRESENT in `_postflopTeachKey`). Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

- Tip advanced `0fe062ab` → `bc5f24fd` (#2083 LPT-558): synced pilot `act-01-01-01-*` + toy-hand/jump/baseline lab `teachSpec` into `wave_one_foundations.mjs` (course.json already had the contract). Wave_two optional pair `act-04-03-01-guided` / `act-04-10-01-checkpoint` already PRESENT.
- Content-agent Done-ack **LPT-558** on tip after field-match (deal mode/families/variants, cues, pressHints; checkpoint/jump_test hintless). Wave sync ≠ catalog clear — `scan_content_gaps --counts` still flat pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Parents tip-comment only (LPT-628 body matches — Soft timing `act-05-07-01-*` Priority ABSENT).
- Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING. Honesty **LPT-414** still valid (`act-03-02-01-unguided` Air Nice! still "Gutshot-ish…" on zero-outs `5h`/`4h`·`Qc`/`7d`/`2s`).
- Tip-commented catalog LPT-624/625/626/627/628/635 + frontier LPT-242/312/315/334 + S6 Highs LPT-252/255/258/271/275/295/301 + needs-human LPT-348 + honesty LPT-414. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## Fold 2026-10-13cc (tip bc5f24fd LPT-558 Done-ack)

- Tip advanced `0fe062ab` (#2082 learnings) → `bc5f24fd` (#2083 LPT-558 wave_one pilot teachSpec sync). `scan_content_gaps --counts` still flat: pressHints **151**, deal-variants **92**, teachSpec **44**, explain-teachSpec **23**, nice-ladder **55**, unguided-softpulse-map **24**, densify-tap **118**, `softpulseMapArms` **68**, `densifyHelperArms` **111**. Catalog parent bodies match — tip-comment only (no rebuild). Wave sync does not change `course.json` gap counts.
- Done-ack **LPT-558**: `wave_one_foundations.mjs` now mirrors pilot `act-01-01-01-*` teachSpecs from `course.json` (+ catalog/validator tests). Soft timing `act-05-07-01-*` densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper **111**; Priority on LPT-628). Frontier Soft timing **LPT-242** / Map turn **LPT-312** / Compose river **LPT-315** / strategy book **LPT-334** still all-five MISSING teachSpec (densify ≠ teachSpec).
- Honesty still valid (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided`. **LPT-417** Done. **LPT-216** Done.
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626** — no clones. Concurrent tip-comments already on `bc5f24fd` for parents+frontier+Highs+LPT-558 — `jira.py get` confirms tip SHA; no re-spam this tick. Home pending empty. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).
- Tip advanced `bc5f24fd` → `bd6aa82f` (#2084 learnings). JSON still flat 151/92/44/23/nice-55/map-24 densify-tap 118 densifyHelperArms 111; parents+frontier+LPT-414 tip-commented on learnings tip; Soft timing densify ABSENT; LPT-558 Done.

## 2026-10-13cd — tip `f4a4d1fe` (#2086 LPT-558 wave follow-up)

- Started on tip-stable `2bcedefc` (#2085 Fold-cc after #2084/#2083). `scan_content_gaps --counts` flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Catalog parent bodies match — no rebuild.
- Prior coverage on `2bcedefc` listed parents+frontier+S6+LPT-558 while `jira.py get` showed S6 Highs LPT-252/255/258/271/275/295/301/348 + Done LPT-558 lacked the tip SHA — tip-commented those 9 (Python body files). Soft timing densify still ABSENT; Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING; honesty **LPT-414** still "Gutshot-ish…" on `act-03-02-01-unguided`.
- Mid-run tip advanced `2bcedefc` → `f4a4d1fe` (#2086 LPT-558 second wave_one pilot+labs sync). JSON still flat (wave sync ≠ catalog clear). Re-tip-commented catalog LPT-624/625/626/627/628/635 + frontier LPT-242/312/315/334 + S6 Highs LPT-252/255/258/271/275/295/301 + needs-human LPT-348 + honesty LPT-414 + Done-ack LPT-558 on the new SHA. Soft timing Priority on LPT-628. Meet Nit: Nice! **LPT-624** / pressHints **LPT-626**; LPT-216 Done — no clones. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty (stub). `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13ce — tip-stable `f3090100` (#2087 learnings re-check)

- Tip-stable `f3090100` (#2087 learnings after `f4a4d1fe`/#2086 LPT-558). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. `--gap … --markdown` row counts match parent checklists (LPT-626/627/624/635/625/628) — no rebuild.
- Prior coverage on `f3090100` listed parents+frontier+S6+LPT-348+LPT-414+LPT-558; `jira.py get` confirms tip SHA **HAS** on every claimed ticket — no tip-comment re-spam. Soft timing densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper **111**; Priority on LPT-628). Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING; S6 Highs LPT-252/255/258/271/275/295/301 still MISSING; honesty **LPT-414** still "Gutshot-ish…" on `act-03-02-01-unguided` (`5h`/`4h`·`Qc`/`7d`/`2s`). Done-ack **LPT-558** already on tip.
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626** — no clones. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty (stub). `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13cf — tip-stable `15b51730` (#2088 Medium honesty/cues re-check)

- Tip-stable `15b51730` (#2088 learnings after `f3090100`/#2087). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. `--gap … --markdown` row counts match parent checklists (LPT-626 **151** / LPT-627 **92** / LPT-628 **118** / LPT-624 nice-55 / LPT-635 S1–S2 **12**) — no rebuild.
- Prior densify/nice-ladder coverage on this SHA listed parents+frontier+S6+LPT-348+LPT-414+LPT-558; `jira.py get` confirms tip SHA **HAS** on every claimed catalog parent + High — no re-spam. Soft timing densify still ABSENT from `selectIdentifyDensifiedCoachLine` (helper **111**; Priority on LPT-628 / LPT-628 In Progress). Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING; densify ≠ teachSpec.
- Honesty still valid (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided` (`5h`/`4h`·`Qc`/`7d`/`2s`). Feedback-class scan found no new gutshot-ish siblings.
- Medium one-offs omitted from densify coverage lists still valid and lacked tip SHA — tip-commented **LPT-370** (`act-01-01-02-scaffolded-ranks` deal+pressHints PRESENT, `teachSpec.cues` still null) and **LPT-588** (`act-04-05-01-checkpoint` teachSpec/ActionSpot turn `Qs/7c/2d/9h` vs Scene flop-only `Qs/7c/2d`). Corrected first tip-comments after f-string `{{act-}}` collapse (Never: non-f-string Jira wiki bodies).
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626** — no clones. Done-ack **LPT-558** already on tip. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty (stub). `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 (IP) OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR Medium LPT-370/588 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13cg — tip `e23e1664` (#2090 ui-agent status)

- Started on tip-stable `c0b7b367` (#2089 learnings after #2088 Medium honesty/cues). Mid-run tip advanced → `e23e1664` (#2090 ui-agent status: filtered needs-human/grokbot counts — non-content). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Catalog parent bodies match — tip-comment only (no rebuild).
- Tip-commented catalog LPT-624/625/626/627/628/635 + frontier LPT-242/312/315/334 + S6 Highs LPT-252/255/258/271/275/295/301 + needs-human LPT-348 + honesty LPT-414 + Medium LPT-370/588 + Done-ack LPT-558 on `e23e1664` (Python non-f-string wiki bodies). Soft timing densify still ABSENT from `selectIdentifyDensifiedCoachLine` (rex_coach_line zero `act-05-07-01-*` hits; helper **111**; Priority on LPT-628 In Progress). Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING (`act-05-07-01-*` / `act-07-02-01-*` / `act-07-03-01-*` / `act-07-09-01-*`).
- Honesty still valid (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided` (`5h`/`4h`·`Qc`/`7d`/`2s`). Grep Soft timing / Map turn / Compose river / strategy book act-ids in run-memory before filing — outcome-tile / fixed teachSpec patterns; no new per-lesson clones.
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626** — no clones. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty (stub). `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 (IP) OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR Medium LPT-370/588 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13ch — tip-stable `6c6ee6d5` (#2091 learnings)

- Tip-stable `6c6ee6d5` (#2091 learnings after `e23e1664`/#2090). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Catalog parent bodies match scanner checklists (LPT-626 **151** / LPT-627 **92** / LPT-628 **118**/helper **111** / LPT-624 nice-55 / LPT-625 map-24 / LPT-635 S1–S2) — no rebuild.
- Prior coverage on this SHA listed parents+frontier+S6+LPT-348+LPT-414+LPT-370+LPT-588+LPT-558; `jira.py get` confirms tip SHA **HAS** on every claimed ticket — no re-spam. Soft timing densify still ABSENT from `selectIdentifyDensifiedCoachLine` (rex_coach_line zero `act-05-07-01-*` hits; helper **111**; Priority on LPT-628 In Progress). Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING (`act-05-07-01-*` / `act-07-02-01-*` / `act-07-03-01-*` / `act-07-09-01-*`).
- Honesty High re-check (no sim): **LPT-414** Air Nice! feedback still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided` (`5h`/`4h`·`Qc`/`7d`/`2s`, SoftPulse `air` correct). Medium **LPT-370** (`act-01-01-02-scaffolded-ranks` cues still null) + **LPT-588** (`act-04-05-01-checkpoint` Scene still `Qs/7c/2d` flop-only vs teachSpec/ActionSpot turn `9h`) still valid.
- Meet Nit: Nice! **LPT-624** / pressHints **LPT-626** — no clones. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty (stub). `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 (IP) OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR Medium LPT-370/588 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13ci — tip `4dd23e49` (#2092 learnings)

- Tip advanced → `4dd23e49` (#2092 learnings after tip-stable `6c6ee6d5` honesty re-check). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Catalog parents match — tip-comment only (no rebuild).
- Tip-commented catalog LPT-624/625/626/627/628/635 + frontier LPT-242/312/315/334 + S6 Highs LPT-252/255/258/271/275/295/301 + needs-human LPT-348 + honesty LPT-414 + Medium LPT-370/588 + Done-ack LPT-558 on `4dd23e49` (Python non-f-string markdown body-files). Soft timing densify still ABSENT (helper **111**; Priority on LPT-628). Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING.
- Honesty still valid: **LPT-414** Gutshot-ish on `act-03-02-01-unguided`; **LPT-370** cues null; **LPT-588** Scene flop-only. Meet Nit LPT-624/626. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing on LPT-628 (IP) OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR Medium LPT-370/588 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13cj — tip `784e19d9` (#2094 LPT-628 comment+test)

- Tip advanced → `784e19d9` (#2094 “LPT-628 densify … frame coach asks”). Diff is only a fallthrough comment in `selectIdentifyDensifiedCoachLine` + `densified_asks_still_say_densify_test.dart` — **no** new densify helper arms. `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Catalog parent bodies match — tip-comment only (no rebuild). Soft timing `act-05-07-01-*` still ABSENT from helper arms (Priority on LPT-628 — keep open; do **not** Done from #2094 title).
- Tip-commented catalog LPT-624/625/626/627/628/635 + frontier LPT-242/312/315/334 + S6 Highs LPT-252/255/258/271/275/295/301 + needs-human LPT-348 + honesty LPT-414 + Medium LPT-370/588 on `784e19d9` (Python non-f-string wiki body-files). Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING.
- Honesty still valid: **LPT-414** Gutshot-ish on `act-03-02-01-unguided`; **LPT-370** cues null; **LPT-588** Scene flop-only. Meet Nit LPT-624/626. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing arms on LPT-628 (IP) OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR Medium LPT-370/588 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13ck — tip `3ca3d7ac` (#2096 learnings after #2094)

- Tip-stable `3ca3d7ac` (#2096 learnings fold after #2094 LPT-628 comment+test). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Catalog parent bodies match (LPT-628 densify-tap **118** / helper **111**) — tip-comment only (no rebuild). Soft timing `act-05-07-01-*` still ABSENT from `selectIdentifyDensifiedCoachLine` (Priority on LPT-628 — #2094 ≠ densify clear).
- Coverage on this SHA listed parents+frontier+S6+Mediums as tip-commented; `jira.py get` confirmed **HAS** for those, but Done **LPT-558** lacked the tip SHA — Done-ack LPT-558 (course↔wave field match still holds; wave sync ≠ catalog/Soft-timing clear). Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING.
- Honesty re-read (no sim): **LPT-414** Air Nice! still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided` (`5h`/`4h`·`Qc`/`7d`/`2s`); **LPT-370** `act-01-01-02-scaffolded-ranks` cues still null (pressHints present); **LPT-588** Scene still flop-only `Qs`/`7c`/`2d` vs teachSpec/ActionSpot turn `9h`. Meet Nit LPT-624/626. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty (stub only). `content,grokbot,lesson`.
- next: densify Soft-timing arms on LPT-628 (IP) OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR Medium LPT-370/588 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13cl — tip-stable `ca18f0a0` (#2097 learnings)

- Tip-stable `ca18f0a0` (#2097 learnings fold after `3ca3d7ac`/#2096). Prior coverage on this SHA claimed `learnings: updated`, but run-memory lacked the `ca18f0a0` fold — ship this tick. `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Catalog parent bodies match (LPT-626 **151** / LPT-627 **92** / LPT-628 densify-tap **118**/helper **111** / LPT-624 nice-55 / LPT-625 map-24 / LPT-635 S1–S2) — no rebuild.
- `jira.py get` confirms tip SHA **HAS** on all claimed parents+frontier+S6+LPT-348+LPT-414+LPT-370/588+Done LPT-558 — no re-spam. Soft timing densify still ABSENT from `selectIdentifyDensifiedCoachLine` (rex_coach_line zero `act-05-07-01-*` hits; helper **111**; Priority on LPT-628 In Progress). Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING (`act-05-07-01-*` / `act-07-02-01-*` / `act-07-03-01-*` / `act-07-09-01-*`).
- Honesty / Medium re-read (no sim): **LPT-414** Air Nice! still "Gutshot-ish trash multiway…" on `act-03-02-01-unguided` (`5h`/`4h`·`Qc`/`7d`/`2s`, SoftPulse `air` correct); **LPT-370** `act-01-01-02-scaffolded-ranks` cues still null (sole teachSpec-without-cues scaffolded non-assessment; pressHints present); **LPT-588** Scene still flop-only `Qs`/`7c`/`2d` vs teachSpec/ActionSpot turn `9h`. Meet Nit LPT-624/626. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty (stub only). `content,grokbot,lesson`.
- next: densify Soft-timing arms on LPT-628 (IP) OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR Medium LPT-370/588 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13cm — tip `7f0b6177` (#2098 learnings after ca18f0a0)

- Tip advanced → `7f0b6177` (#2098 learnings fold of tip-stable `ca18f0a0`). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Catalog parents match — tip-comment only (no rebuild).
- Tip-commented catalog LPT-624/625/626/627/628/635 + frontier LPT-242/312/315/334 + S6 Highs LPT-252/255/258/271/275/295/301 + needs-human LPT-348 + honesty LPT-414 + Medium LPT-370/588 + Done-ack LPT-558 on `7f0b6177` (Python non-f-string body-file). Soft timing densify still ABSENT (helper **111**; Priority on LPT-628). Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING.
- Honesty/Medium still valid: **LPT-414** Gutshot-ish on `act-03-02-01-unguided`; **LPT-370** cues null; **LPT-588** Scene flop-only. Meet Nit LPT-624/626. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing arms on LPT-628 (IP) OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR Medium LPT-370/588 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13cn — tip `d21d2020` (#2099 learnings after 7f0b6177)

- Tip advanced → `d21d2020` (#2099 learnings fold of `7f0b6177` tip-comments). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Catalog parents match — tip-comment only (no rebuild).
- Tip-commented catalog LPT-624/625/626/627/628/635 + frontier LPT-242/312/315/334 + S6 Highs LPT-252/255/258/271/275/295/301 + needs-human LPT-348 + honesty LPT-414 + Medium LPT-370/588 + Done-ack LPT-558 on `d21d2020`. Soft timing densify still ABSENT (helper **111**; Priority on LPT-628). Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING.
- Honesty/Medium still valid: **LPT-414** Gutshot-ish; **LPT-370** cues null; **LPT-588** Scene flop-only. Meet Nit LPT-624/626. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: densify Soft-timing arms on LPT-628 (IP) OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR Medium LPT-370/588 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).

## 2026-10-13co — tip `5de1f130` (#2100) → mid-run `301c8694` (#2101)

- Started on post-cascade tip `5de1f130` (#2100 learnings). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **92** / teachSpec **44** / explain-teachSpec **23** / nice-ladder **55** / unguided-softpulse-map **24** (softpulseMapArms **68**) / densify-tap **118** / densifyHelperArms **111**. Catalog parents match — tip-comment only (no rebuild). Home pending empty (fold script left a blank Fold header — discarded; durable notes ship here).
- Tip-commented NEED set on `5de1f130` (21 tickets; LPT-628 already HAS): catalog LPT-624/625/626/627/635 + frontier LPT-242/312/315/334 + S6 LPT-252/255/258/271/275/295/301 + needs-human LPT-348 + honesty LPT-414 + Medium LPT-370/588 + Done-ack LPT-558.
- Mid-run tip → `301c8694` (#2101 ui-agent status deploy-marker; non-content). JSON still flat — re-tip-commented parents+frontier+S6+LPT-348+LPT-414+LPT-370/588+LPT-628 Soft timing Priority ABSENT + Done-ack LPT-558 on the new SHA (same tick; do not leave coverage claiming only the pre-advance tip).
- Soft timing densify still ABSENT (helper **111**; Priority on LPT-628). Soft timing teachSpec **LPT-242** + frontier **LPT-312/315/334** still all-five MISSING.
- Honesty/Medium still valid: **LPT-414** Gutshot-ish on `act-03-02-01-unguided` (`5h`/`4h`·`Qc`/`7d`/`2s`); **LPT-370** cues null on `act-01-01-02-scaffolded-ranks`; **LPT-588** Scene flop-only (`Qs`/`7c`/`2d` vs ActionSpot turn `9h`). Meet Nit LPT-624/626. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: densify Soft-timing arms on LPT-628 (IP) OR re-verify LPT-242 after GrokBot OR LPT-312/315/334 OR LPT-414 OR Medium LPT-370/588 OR catalog LPT-626(151)/627(92)/635/624(55)/625(24)/628(118).
- 2026-10-13cp tip `4ff23840` (#2102 densify remaining + #2103): Soft timing `act-05-07-01-*` densify helper arms PRESENT in `selectIdentifyDensifiedCoachLine` (guided/scaffolded/unguided/checkpoint). densify-tap ABSENT now **17** (Meet Nit `act-04-07-02-{guided,unguided}`, Meet Maniac `act-04-08-02-{guided,unguided}`, five-type final `act-07-12-01-{cs,nit,maniac,tag,lag}`, jump `act-04-10-02-jump-{station,nit,maniac}`, plus early SI: `act-01-01-03-checkpoint-layout`, `act-01-02-02-{scaffolded-kicker,unguided-board}`, `act-01-05-01-unguided-pot`, `act-04-09-01-unguided`). LPT-628 reopened+rebuilt; Soft timing teachSpec stays on LPT-242.

## Fold 2026-10-13cf (tip 03e193e8 #2105 teachSpec + #2102 densify)

- Tip advanced through #2102 densify → #2104 learnings → #2105 wave3 teachSpec batch (`03e193e8`). `scan_content_gaps --counts`: pressHints **151**, deal-variants **92→99**, teachSpec **44→0**, explain-teachSpec **23→12**, nice-ladder **55→66**, unguided-softpulse-map **24**, densify-tap **118→17**, `densifyHelperArms` **111→212**.
- Done-ack teachSpec Highs on tip: Soft timing **LPT-242**, Map turn **LPT-312**, Compose river **LPT-315**, strategy book **LPT-334**, Adjust LAG **LPT-301** (transitioned); S6 LPT-252/255/258/271/275/295 already Done — comment Done-ack. Soft timing densify `act-05-07-01-*` **PRESENT** via #2102 — drop Soft timing Priority on LPT-628.
- Rebuilt catalog parents from `--gap … --markdown`: **LPT-624** nice 66, **LPT-627** deal-variants 99, **LPT-635** explain-teachSpec 12, **LPT-628** densify-tap 17 (Meet Nit/Maniac, five-type final, jumps, early SI remain). Tip-commented **LPT-626** pressHints still 151 (Meet Nit unguided) + **LPT-625** + honesty **LPT-414** still Gutshot-ish + **LPT-348**.
- Meet Nit: teachSpec PRESENT but Nice! **LPT-624** / pressHints **LPT-626** / densify rows on **LPT-628** — no clones. LPT-216 Done. `CATALOG_PARENTS.teachSpec` stays null. `content,grokbot,lesson`.
- next: densify remaining 17 on LPT-628 OR Nice! LPT-624 OR pressHints LPT-626 OR LPT-414 OR catalog LPT-627(99)/635(12)/625(24).

## 2026-10-13cq — tip `9a7bfc87` (#2106) + LPT-666 ADVANTAGE⊃TAG

- Tip advanced → `9a7bfc87` (#2106 learnings fold of `03e193e8`/#2105). `scan_content_gaps --counts` still flat vs product tip: pressHints **151** / deal-variants **99** / teachSpec **0** / explain-teachSpec **12** / nice-ladder **66** / unguided-softpulse-map **24** / densify-tap **17** / densifyHelperArms **212**. Catalog parents match — tip-comment only (no rebuild).
- Prior `03e193e8` coverage omitted Medium **LPT-370**/ **LPT-588** + Done **LPT-558** — tip-commented those on `03e193e8` (quoted heredoc bodies) then tip-commented parents+Highs+Mediums+LPT-558 on `9a7bfc87`. Soft timing densify PRESENT; densify Priority = remaining **17** on LPT-628.
- Filed High **LPT-666**: `act-06-01-01-explain` SoftPulse cue target **ADVANTAGE** makes `blob.includes("TAG")` true and fails `course-contract` wave-three early-name test on tip (false positive — not player-type TAG). Grep SoftPulse cue targets for TAG/LAG substrings after teachSpec batch lands.
- Honesty/Medium still valid: **LPT-414** Gutshot-ish; **LPT-370** cues null; **LPT-588** Scene flop-only. Meet Nit LPT-624/626. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: LPT-666 ADVANTAGE/TAG guard OR densify remaining 17 on LPT-628 OR Nice! LPT-624 OR pressHints LPT-626 OR LPT-414 OR catalog LPT-627(99)/635(12)/625(24).

## 2026-10-13cr — tip `f9c109a1` (#2107 + #2108 LPT-414 Done)

- Tip `f9c109a1` merges #2107 learnings + #2108 LPT-414 Air feedback. `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **99** / teachSpec **0** / explain-teachSpec **12** / nice-ladder **66** / map **24** / densify-tap **17** / densifyHelperArms **212**. Parents tip-comment only.
- Done-ack **LPT-414**: `act-03-02-01-unguided` Air feedback is now five-high / no real draw (no gutshot); transitioned Done. Corrected stale same-SHA tip-comment that still said honesty valid.
- **LPT-666** still open (ADVANTAGE SoftPulse cue breaks TAG-early course-contract). Medium **LPT-370** cues null / **LPT-588** Scene flop-only still valid. Meet Nit LPT-624/626 + densify 17 on LPT-628. `content,grokbot,lesson`.
- next: LPT-666 OR densify remaining 17 on LPT-628 OR Nice! LPT-624 OR pressHints LPT-626 OR Medium LPT-370/588 OR catalog LPT-627(99)/635(12)/625(24).

## 2026-10-13cs — tip-stable `a3dc6374` (#2109) Done-ack NEED fix

- Tip-stable `a3dc6374` after #2109 learnings (fold of `f9c109a1` / LPT-414 Done). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **99** / teachSpec **0** / explain-teachSpec **12** / nice-ladder **66** / unguided-softpulse-map **24** / densify-tap **17** / densifyHelperArms **212**. Catalog parent bodies match densify-tap **17** (incl. five-type final) — no rebuild.
- Prior home coverage listed Done Highs + LPT-348/558 as tip-commented on `a3dc6374`, but `jira.py get` showed **NEED** on LPT-242/312/315/334/252/255/258/271/275/295/301/414/348/558 while parents+LPT-666+LPT-370/588/624..628/635 already **HAS**. Tip-commented the NEED set same tick (quoted Python body files — no unquoted heredoc).
- Re-verified open gaps: **LPT-666** `act-06-01-01-explain` SoftPulse **ADVANTAGE** still fails `course-contract` (`blob.includes("TAG")`); **LPT-370** `act-01-01-02-scaffolded-ranks` cues still null; **LPT-588** `act-04-05-01-checkpoint` Scene board still flop-only (`Qs`/`7c`/`2d` vs turn `9h`); **LPT-348** `act-07-10-05-hand` scaffolded non-assessment `pressHints` still null (teachSpec has deal+cues only — keep needs-human off LPT-626). Meet Nit Nice!/pressHints still LPT-624/626; densify remaining **17** on LPT-628. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: LPT-666 OR densify remaining 17 on LPT-628 OR Nice! LPT-624 OR pressHints LPT-626 OR Medium LPT-370/588 OR catalog LPT-627(99)/635(12)/625(24).

## 2026-10-13ct — tip `8f3f6aa3` (#2110 densify remaining + #2111) LPT-628 cleared

- Tip advanced `a3dc6374` → `940c7bf6` (#2110 LPT-628 remaining 17 densify arms) → `8f3f6aa3` (#2111 learnings). Mid-run after #2111 pull: `scan_content_gaps --counts` densify-tap **17→0** / densifyHelperArms **212→229**; other JSON still flat pressHints **151** / deal-variants **99** / teachSpec **0** / explain-teachSpec **12** / nice-ladder **66** / unguided-softpulse-map **24**.
- **LPT-628** already Done on tip — rebuilt description to empty densify-tap checklist (ABSENT **0**) + tip-commented Done-ack. Tip-commented catalog parents LPT-624/625/626/627/635 (flat) + High **LPT-666** + Medium **LPT-370**/ **LPT-588** + needs-human **LPT-348**. Densify clear ≠ Nice!/pressHints/SoftPulse-map/explain-teachSpec clear.
- Re-verified: **LPT-666** `act-06-01-01-explain` SoftPulse **ADVANTAGE** still fails `course-contract` TAG-early; **LPT-370** cues null; **LPT-588** Scene flop-only; **LPT-348** Capstone 4-bet `pressHints` still null (off LPT-626). Meet Nit Nice!/pressHints still LPT-624/626. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: LPT-666 OR Nice! LPT-624 OR pressHints LPT-626 OR Medium LPT-370/588 OR catalog LPT-627(99)/635(12)/625(24).

## 2026-10-13cu — tip `8922d49c` (#2112) Done-ack LPT-666

- Tip advanced `8f3f6aa3` → `8922d49c` via #2112 CI course-contract TAG word-boundary / densify fixture fix. `scan_content_gaps --counts` still densify-tap **0** / densifyHelperArms **229**; other flat pressHints **151** / deal-variants **99** / teachSpec **0** / explain-teachSpec **12** / nice-ladder **66** / map **24**.
- Done-ack **LPT-666**: `node --test tools/course/validate_course.test.mjs` wave-three TAG/LAG early **passes** (10/0). SoftPulse cue **ADVANTAGE** remains on `act-06-01-01-explain` (ticket option 2 — tighten guard, keep honest label). Transitioned Done.
- Prior densify-clear learnings PR #2113 closed unmerged — re-shipped ct fold + this cu fold. Tip-commented parents LPT-624/626/628 on `8922d49c`. Medium **LPT-370** cues null / **LPT-588** Scene flop-only / **LPT-348** Capstone pressHints still open. Meet Nit Nice!/pressHints still LPT-624/626. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: Nice! LPT-624 OR pressHints LPT-626 OR Medium LPT-370/588 OR catalog LPT-627(99)/635(12)/625(24) OR LPT-348 needs-human.

## 2026-10-13cv — tip-stable `46ead6a5` (#2114+#2117) coverage over-claim + fold catch-up

- Tip-stable `46ead6a5` after #2114 LPT-666 word-boundary TAG guard + #2117 ui-agent deploy-marker empty-queue skip (also #2115/#2116 learnings on tip). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **99** / teachSpec **0** / explain-teachSpec **12** / nice-ladder **66** / unguided-softpulse-map **24** / densify-tap **0** / densifyHelperArms **229**. Catalog parents match — no rebuild.
- Home coverage thrice claimed tip-comments + `learnings: updated` on `46ead6a5`, but `jira.py get` showed **zero** tickets with that SHA and this file lacked any `46ead6a5` fold (cu stopped at `8922d49c`). Tip-commented NEED set same tick: LPT-624/625/626/627/628/635 + Medium LPT-370/588 + needs-human LPT-348 + Done-ack LPT-666/414/558 (Python non-f-string body files).
- Re-verified: **LPT-370** `act-01-01-02-scaffolded-ranks` cues still null (now In Progress — leave; pressHints present); **LPT-588** `act-04-05-01-checkpoint` Scene still flop-only `Qs`/`7c`/`2d` vs teachSpec/ActionSpot turn `9h`; **LPT-348** `act-07-10-05-hand` pressHints still null (keep needs-human off LPT-626). Meet Nit Nice!/pressHints still LPT-624/626. Zero open High content tickets. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty (stub only). `content,grokbot,lesson`.
- next: Nice! LPT-624 OR pressHints LPT-626 OR Medium LPT-370 (IP)/588 OR catalog LPT-627(99)/635(12)/625(24) OR LPT-348 needs-human.

## 2026-10-13cw — tip `7542b85f` (#2120) Done-ack NEED + fold catch-up

- Tip advanced `46ead6a5` → `7542b85f` via #2120 learnings (cv over-claim fold). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **99** / teachSpec **0** / explain-teachSpec **12** / nice-ladder **66** / unguided-softpulse-map **24** / densify-tap **0** / densifyHelperArms **229**. Catalog parent bodies match markdown row-for-row (66/151/99/12/24/0) — no rebuild.
- Prior home coverage on `7542b85f` listed open parents+Mediums tip-commented, but `jira.py get` showed Done LPT-628/666/414/558 **NEED** the tip SHA; this file also lacked any `7542b85f` fold despite coverage `learnings: updated`. Done-ack those four same tick (quoted Python body file). Open parents LPT-624/625/626/627/635 + Medium LPT-370/588 + LPT-348 already **HAS** — no re-spam.
- Re-verified: **LPT-370** `act-01-01-02-scaffolded-ranks` cues still null (In Progress; pressHints length 3); **LPT-588** `act-04-05-01-checkpoint` `lesson_table_context` Scene still flop-only `Qs`/`7c`/`2d` while teachSpec/ActionSpot author turn `9h`; **LPT-348** `act-07-10-05-hand` pressHints still null (keep needs-human off LPT-626). Meet Nit `act-04-07-02-explain` still lacks `explainGrading` (LPT-624) / unguided pressHints length 0 (LPT-626). Zero open High content tickets. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty (stub only). `content,grokbot,lesson`.
- next: Nice! LPT-624 OR pressHints LPT-626 OR Medium LPT-370 (IP)/588 OR catalog LPT-627(99)/635(12)/625(24) OR LPT-348 needs-human.

## 2026-10-13cx — tip `024e3b56` (#2121) post-merge tip-comment

- Tip advanced `7542b85f` → `024e3b56` via #2121 learnings (cw Done-ack fold). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **99** / teachSpec **0** / explain-teachSpec **12** / nice-ladder **66** / unguided-softpulse-map **24** / densify-tap **0** / densifyHelperArms **229**. Catalog parents match — no rebuild.
- Tip-commented open parents LPT-624/625/626/627/635 + Medium LPT-370/588 + needs-human LPT-348 + Done-ack LPT-628/666/414/558 on the post-merge tip (quoted Python body file). No new tickets.
- Re-verified still open: **LPT-370** cues null (IP); **LPT-588** Scene flop-only (remote `fix/LPT-588-spr-checkpoint-scene-turn` not on tip); **LPT-348** Capstone pressHints. Meet Nit Nice!/pressHints still LPT-624/626. Zero open High content tickets. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: Nice! LPT-624 OR pressHints LPT-626 OR Medium LPT-370 (IP)/588 OR catalog LPT-627(99)/635(12)/625(24) OR LPT-348 needs-human.

## 2026-10-13cy — tip `db98900e` (#2124 LPT-588 + #2122 LPT-370)

- Tip advanced `cf95eea2` → `d61f9342` (#2122 LPT-370 ranks SoftPulse cues) mid-run → `db98900e` (#2124 LPT-588 SPR Scene turn `9h`). `scan_content_gaps --counts` still flat: pressHints **151** / deal-variants **99** / teachSpec **0** / explain-teachSpec **12** / nice-ladder **66** / unguided-softpulse-map **24** / densify-tap **0** / densifyHelperArms **229**. Catalog parents match markdown — no rebuild.
- **LPT-370** Done-ack: `act-01-01-02-scaffolded-ranks` has three SoftPulse `teachSpec.cues` `rank-2` → `rank-T` → `rank-A`; wave_one_foundations synced; order_sequence SoftPulse-after-Hint wired. Already **Done** on tip before content-agent comment.
- **LPT-588** Done-ack: `act-04-05-01-checkpoint` `resolveLessonTableScene` board `Qs`/`7c`/`2d`/`9h` matches teachSpec/ActionSpot (comment cites LPT-588). Already **Done** + tip SHA **HAS** on `db98900e` before content-agent re-check.
- Tip-commented NEED set on `db98900e` (quoted Python body files): LPT-624/625/626/627/635 + LPT-348 + Done-ack LPT-628/666/414/558/370 (LPT-588 already HAS). Verified `jira.py get` **HAS** on all twelve.
- Remaining open: catalog Nice! LPT-624 / pressHints LPT-626 / deal-variants LPT-627 / SoftPulse-map LPT-625 / explain-teachSpec LPT-635 (IP) / needs-human LPT-348 Capstone pressHints. Meet Nit still LPT-624/626. Zero open High content tickets. Medium cues/Scene one-offs cleared. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: Nice! LPT-624 OR pressHints LPT-626 OR catalog LPT-627(99)/635(12)/625(24) OR LPT-348 needs-human.
- act-01-01-02-scaffolded-ranks / act-04-05-01-checkpoint: SoftPulse cues + Scene turn board landed (#2122/#2124) — do not re-file.

## Fold 2026-10-13cz (fcba193c → 7a867c85)

- Tip `fcba193c` (#2125 LPT-635 S1–S2 SoftPulse explain teachSpec cues): explain-teachSpec **12→0**; nice-ladder **66→76** (+10 S1–S2 explains now have teachSpec/cues but lack activity-level `explainGrading`: `act-01-03-01-explain-passive`, `act-01-03-02-explain-aggro`, `act-01-05-01-explain-win`, `act-01-06-01-explain-run`, `act-02-01-01-explain-pos`, `act-02-02-01-explain-families`, `act-02-03-01-explain-open`, `act-02-04-01-explain-vs`, `act-02-05-01-explain-bb`, `act-02-07-01-explain-full`). Streets / acting-order already had ladders. Rebuilt **LPT-624**; Done-ack+empty checklist **LPT-635** → Done. Other flat 151/99/0/map-24 densify-tap 0 helper 229.
- Mid-run tip → `7a867c85` (#2128 LPT-625 SoftPulse-map): unguided-softpulse-map **24→0**; softpulseMapArms **68→92**. Done-ack+empty checklist **LPT-625** → Done. SoftPulse-map ≠ Nice!/pressHints/deal-variants clear — **LPT-624** still 76 / **LPT-626** still 151 / **LPT-627** still 99. Tip-commented parents+LPT-348+Done tickets on `7a867c85`.
- Meet Nit Nice! `act-04-07-02-explain` / pressHints `act-04-07-02-unguided` still LPT-624/626 — no clones. Capstone pressHints **LPT-348** needs-human. Zero open High content tickets. next: Nice! LPT-624 OR pressHints LPT-626 OR deal-variants LPT-627(99) OR LPT-348 needs-human.

## Fold 2026-10-13da (237f924e #2129 LPT-627)

- Tip advanced mid-run `0e519673` (#2130 learnings) → `237f924e` (#2129 LPT-627 suit-rotated `deal.variants` on fixed teachSpec deals): `scan_content_gaps --counts` deal-variants **99→0**. Rebuilt **LPT-627** empty checklist + transitioned **Done**. Other flat pressHints **151** / nice-ladder **76** / teachSpec **0** / explain-teachSpec **0** / SoftPulse-map **0** / densify-tap **0**; softpulseMapArms **92** / densifyHelperArms **229**.
- Tip-commented NEED (12) on `237f924e`: LPT-624/625/626/627/635/628 + LPT-348 + Done-ack LPT-666/414/558/370/588. Verified `jira.py get` **HAS** all twelve. Open IP catalog: Nice! **LPT-624** (76) / pressHints **LPT-626** (151). Done parents LPT-625/627/628/635 stay Done.
- Meet Nit Nice! `act-04-07-02-explain` (cues 3, no `explainGrading`) / pressHints `act-04-07-02-unguided` (empty) still LPT-624/626 — no clones. Capstone pressHints **LPT-348** needs-human. Zero open High content tickets. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty (stub only). `content,grokbot,lesson`.
- next: Nice! LPT-624 (IP, 76) OR pressHints LPT-626 (IP, 151) OR LPT-348 needs-human.
- act-*: deal.variants catalog clear (#2129) — do not re-file deal-variants clones; Nice!/pressHints remain separate.

## Fold 2026-10-13db (6cfa4454 #2132 LPT-624)

- Tip `6cfa4454` (#2132 LPT-624 SoftPulse explains author `explainGrading` Nice! ladder): `scan_content_gaps --counts` nice-ladder **76→0**. Rebuilt **LPT-624** empty checklist + transitioned **Done**. Other flat pressHints **151** / deal-variants **0** / teachSpec **0** / explain-teachSpec **0** / SoftPulse-map **0** / densify-tap **0**; softpulseMapArms **92** / densifyHelperArms **229**.
- Tip-commented NEED set on `6cfa4454`: open **LPT-626** + needs-human **LPT-348** + Done-ack LPT-624/625/627/635/628/666/414/558/370/588. Verified `jira.py get` **HAS** all twelve. Open IP catalog: pressHints **LPT-626** (151) only. Done parents LPT-624/625/627/628/635 stay Done.
- Meet Nit Nice! `act-04-07-02-explain` cleared with catalog **LPT-624**; pressHints `act-04-07-02-unguided` still **LPT-626** — no clones. Capstone pressHints **LPT-348** needs-human. Zero open High content tickets. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty (stub only). `content,grokbot,lesson`.
- next: pressHints LPT-626 (IP, 151) OR LPT-348 needs-human.
- act-*: SoftPulse explain Nice! ladder catalog clear (#2132) — do not re-file nice-ladder clones; pressHints remain separate.

## Fold 2026-10-13dc (cb195dd7 #2135 LPT-626)

- Tip advanced mid-run `6cfa4454` (#2132) / `35188158` (#2136 learnings) → `cb195dd7` (#2135 LPT-626 class-language `pressHints`): `scan_content_gaps --counts` pressHints **151→0**. Rebuilt **LPT-626** empty checklist + transitioned **Done**. Catalog structural gaps all **0** (pressHints/deal-variants/teachSpec/explain-teachSpec/nice-ladder/unguided-softpulse-map/densify-tap); softpulseMapArms **92** / densifyHelperArms **229**.
- Tip-commented NEED (13) on `cb195dd7`: LPT-624/625/626/627/635/628 + LPT-348 + LPT-216 + Done-ack LPT-666/414/558/370/588. Verified `jira.py get` **HAS**. Zero open IP content catalog tickets; Capstone **LPT-348** needs-human remains To Do.
- Meet Nit Nice! + pressHints cleared (`act-04-07-02-explain` has `explainGrading`; `act-04-07-02-unguided` has pressHints length 1). Checkpoint stays hintless. Zero open High content tickets. `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: LPT-348 Capstone pressHints needs-human OR discovery walk (honesty/curriculum one-offs scanner cannot see).
- act-04-07-02-unguided: pressHints PRESENT (#2135) — do not re-file pressHints clones; Capstone LPT-348 stays separate.

## 2026-10-13de — tip 43a1be2d discovery streets + LPT-667 one-per-press

- Tip-stable `43a1be2d` (#2138). `scan_content_gaps.mjs --counts` still all **0** (pressHints/deal-variants/teachSpec/explain/nice/map/densify-tap); softpulseMapArms **92** / densifyHelperArms **229**. Open catalog JSON parents already **HAS** tip SHA — no rebuild.
- Discovery oldest `lesson:lesson-01-04-01-streets-and-order` (`act-01-04-01-*`): teachSpec present; `deal.mode` `none` appropriate (street/seat/identify — no handFamily); checkpoint-postflop hintless; curriculum multi-concept still **LPT-103** needs-human.
- Incomplete one-per-press (SoftPulse cues press set ⊈ pressHints press set) on tip — scanner empty-array clear ≠ contract:
  - `act-01-04-01-scaffolded-order` cues 1–4 / pressHints length 1 (LPT-102 Done incompletely)
  - `act-01-02-01-scaffolded-spot` / `act-01-02-01-unguided-compare` cues 1–3 / pressHints 1 (prior hand-ranks walk wrongly `clean`)
  - `act-01-02-02-checkpoint-build` cues 1–5 / pressHints 1 (scaffolded, no assessmentRole — Hint-enabled)
  - `act-01-06-01-scaffolded-multi` cues 1–2 / pressHints 1
  - `act-02-01-02-scaffolded-post` cues 1–2 / pressHints 1 (LPT-116 Done incompletely)
- Filed catalog **LPT-667** (`content,grokbot,lesson`) — Scaffolded multi-press steps missing one pressHints entry per press. Relates LPT-102/116/626/348. Capstone `act-07-10-01-hand`…`act-07-10-05-hand` stay **LPT-348** only — do not reopen **LPT-626**.
- Tip-commented LPT-103 / LPT-348 / LPT-626 / LPT-102 / LPT-116 on `43a1be2d`.
- next: **LPT-667** one-per-press implement OR **LPT-348** Capstone needs-human OR Low curriculum splits.

## 2026-10-13df — tip 43a1be2d discovery position-labels

- Tip-stable `43a1be2d` (#2138). `scan_content_gaps.mjs --counts` still all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Open JSON catalog parents already **HAS** tip SHA — no rebuild. Prior draft learnings PR #2141 (LPT-667 fold) was not on tip — this fold supersedes onto `cursor/chore-content-learnings-pos-00bd`.
- Discovery oldest `lesson:lesson-02-01-01-position-labels` (`act-02-01-01-*`):
  - `act-02-01-01-explain-pos`: guided SoftPulse cues + activity-level `explainGrading`; `deal.mode` `none`
  - `act-02-01-01-guided-btn`: guided SoftPulse `pos-btn`; Hint off while gold on — no pressHints required
  - `act-02-01-01-scaffolded-blinds` / `act-02-01-01-unguided-co`: pressHints length 1 = cue presses (complete one-per-press — **not** on **LPT-667**)
  - `act-02-01-01-checkpoint-edge`: `assessmentRole` checkpoint, hintless — correct
  - Seat/puck outcome tiles — do not file handFamily/suitFamily gaps
  - Design-record SoftPulse puck path (LPT-118) already landed; Still-a-list not a rebuild ask
- Structural catalog clean. Multi-concept curriculum still **LPT-114** needs-human (tip-commented). Tip-commented **LPT-667** (6-row checklist unchanged) + **LPT-348**.
- next: **LPT-667** one-per-press implement OR **LPT-348** Capstone needs-human OR Low curriculum (e.g. acting-order **LPT-117** / next oldest discovery).
- act-02-01-01-*: structural teachSpec/pressHints/one-per-press clean on tip — curriculum split only via LPT-114.

## Fold 2026-10-13dd (43a1be2d discovery hand-ranks)

- Tip-stable `43a1be2d` (#2138 Prefer LPT-348 Medium focus after #2135/#2137). `scan_content_gaps --counts` still all catalog JSON gaps **0**; softpulseMapArms **92** / densifyHelperArms **229**. Catalog parents LPT-624/625/626/627/628/635 + LPT-348 + Done Mediums already **HAS** tip SHA — no rebuild/re-spam.
- Discovery walk oldest coverage surface `lesson:lesson-01-02-01-hand-ranks`: teachSpec/cues/explainGrading/`random_in_class` families OK; scaffolded/unguided one-per-press incomplete (later folded into **LPT-667**). Tip-commented needs-human curriculum split **LPT-90**. Capstone **LPT-348** still needs-human. Zero open High / IP content catalog tickets. Home pending empty. `content,grokbot,lesson`.
- next: **LPT-667** one-per-press OR **LPT-348** Capstone needs-human OR next-oldest discovery.
- act-01-02-01-*: do not re-file teachSpec/nice-ladder clones; curriculum split stays **LPT-90**; one-per-press on **LPT-667**.

## Fold 2026-10-13dd (43a1be2d Capstone LPT-348 bundle)

- Tip-stable `43a1be2d` (#2138 Prefer after #2137/#2135): catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Meet Nit Nice!+pressHints cleared; **LPT-216** Same-hand teachSpec Done. Parents already **HAS** tip — no catalog rebuild/re-spam.
- Discovery: five Capstone scaffolded hands still empty pressHints inside `NO_HINT_ACTIVITY_IDS` (`act-07-10-01-hand`…`act-07-10-05-hand`); only 4-bet was listed on **LPT-348**. Expanded **LPT-348** summary+body to needs-human Capstone catalog (all five); tip-commented LPT-348 + Done **LPT-626** (do not reopen). Keep `needs-human` until policy (author pressHints vs assessment/no-Hint contract).
- Zero open High / IP content catalog tickets. Open Medium content: **LPT-667** + **LPT-348** (+ Low curriculum splits). `CATALOG_PARENTS.teachSpec` stays null. Home pending empty. `content,grokbot,lesson`.
- next: LPT-667 one-per-press OR LPT-348 human policy OR Low curriculum / honesty discovery.
- act-07-10-0*-hand: Capstone NO_HINT bundle on LPT-348 — do not file per-Capstone pressHints clones.

## Fold 2026-10-13dg (43a1be2d discovery live-habits)

- Tip-stable `43a1be2d` (#2138). `scan_content_gaps --counts` all structural gaps **0**; softpulseMapArms **92** / densifyHelperArms **229**. Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Open Medium: one-per-press **LPT-667** (6 rows) + Capstone needs-human **LPT-348** (five hands).
- Discovery oldest-unfresh `lesson-02-06-01-live-habits`: teachSpec present; `deal.mode` `none` habit/identify tiles; scaffolded verbal/protect one-per-press complete; explain has `explainGrading`; checkpoint hintless. Structural clean. Curriculum multi-concept still **LPT-133** needs-human (tip-commented).
- Tip-commented **LPT-667** / **LPT-348** / **LPT-133** / Done **LPT-626** / **LPT-216**. One-per-press checklist unchanged (6). Do not reopen **LPT-626**.
- next: **LPT-667** one-per-press implement OR **LPT-348** Capstone human policy OR Low curriculum / next oldest discovery.
- act-02-06-01-*: structural clean on tip — curriculum split only via LPT-133.

## Fold 2026-10-13dh (monitor: fold superseded draft Prefer + live-habits)

- Tip `65d01ce6` (#2142) already on main with LPT-667 Never/Prefer + streets/position-labels folds. Monitor closed conflicted drafts #2139/#2140/#2144 after folding their unique Prefer/run-memory into tip (this section + learnings Prefer bullets).
- Catalog `--counts` still all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Open Medium: **LPT-667** + **LPT-348**. High content open: **0**.

## Fold 2026-10-13di (65d01ce6 acting-order — folded from conflicted #2146)

- Tip `65d01ce6` (#2142) then tip advanced to `4dbc5b9a` (#2145) before #2146 could merge (CONFLICTING). Catalog structural gaps all **0**.
- Discovery oldest-unfresh `lesson-02-01-02-acting-order`: explain has `explainGrading`; guided SoftPulse; unguided-wait one-per-press complete; checkpoint hintless; only `act-02-01-02-scaffolded-post` cues 1–2 / pressHints 1 — already on **LPT-667** (no checklist delta). Curriculum multi-concept **LPT-117** needs-human (tip-commented on `65d01ce6`).
- act-02-01-02-scaffolded-post: keep on LPT-667 — do not file acting-order pressHints clone.

## Fold 2026-10-13di (4dbc5b9a discovery meet-maniac)

- Tip `4dbc5b9a` (#2145). `scan_content_gaps --counts` all structural gaps **0**; softpulseMapArms **92** / densifyHelperArms **229**. Open Medium: **LPT-667** (6 one-per-press) + **LPT-348** Capstone needs-human. LPT-667/348 already **HAS** tip — no rebuild/re-spam.
- Discovery oldest-unfresh `lesson-04-08-02-meet-maniac`: teachSpec on all four steps; `deal.mode` `none` player-type tiles (no handFamily/suitFamily); explain has `explainGrading` (MANIAC/ENTRY/AGGRO SoftPulse); unguided one-per-press complete; checkpoint hintless. Structural clean. Curriculum multi-concept / checkpoint mix-vs-introduce still **LPT-208** needs-human (tip-commented). Done-ack **LPT-206** teachSpec.
- Design-record Still-a-list label quizzes already STALE (`tableRegionTap` / `meetManiac*Outcomes`) — do not file rebuild.
- next: **LPT-667** one-per-press implement OR **LPT-348** Capstone human policy OR next oldest discovery (`lesson-05-05-01-lines-and-probes`).
- act-04-08-02-*: structural clean on tip — curriculum split only via LPT-208; not on LPT-667.

## Fold 2026-10-13dj (3007ac2b discovery lines-and-probes)

- Tip `3007ac2b` (#2147). `scan_content_gaps --counts` all structural gaps **0**; softpulseMapArms **92** / densifyHelperArms **229**. Open Medium: **LPT-667** (6 one-per-press) + **LPT-348** Capstone needs-human. LPT-667/348 already **HAS** tip — no rebuild/re-spam. Tip-commented Done parents LPT-624/625/626/627/628/635 + Done-ack LPT-234/LPT-216 on tip.
- Discovery oldest-unfresh `lesson-05-05-01-lines-and-probes`: teachSpec on all five steps; explain SoftPulse X/R→PROBE→DELAY→DONK + `explainGrading`; guided `deal.mode` `none` cue `strong`; scaffolded `poker_action_sizing` fixed 9h8d/Kc9s3h (+ suit-rotated variants) matches Dart `resolveLessonActionSpot` + one-per-press probe; unguided `none` polar + one-per-press; checkpoint cue kind `none` / no pressHints. Structural clean — not appended to LPT-667.
- Curriculum multi-concept / probe-vs-delay objective merge still **LPT-236** needs-human (tip-commented). Design-record Still-a-list nit/donk/delay STALE — do not file rebuild.
- next: **LPT-667** one-per-press implement OR **LPT-348** Capstone human policy OR next oldest discovery (`lesson-05-06-01-line-reading`).
- act-05-05-01-*: structural clean on tip — curriculum split only via LPT-236; not on LPT-667.

## Fold 2026-10-13dk (fee963ac discovery session-discipline)

- Tip mid-run `196d3505` (#2148) → `fee963ac` (#2150 sticky worktree). `scan_content_gaps --counts` all structural gaps **0**; softpulseMapArms **92** / densifyHelperArms **229**. Open Medium: **LPT-667** In Progress (same 6 one-per-press rows — tip-comment only, leave IP) + **LPT-348** Capstone needs-human. Tip-commented LPT-250/248/249/348/667 + Done parents LPT-624/625/626/627/628/635 on `fee963ac` (`jira.py get` **HAS**).
- Discovery oldest-unfresh `lesson-05-09-01-session-discipline` (Keep cash session guardrails): teachSpec on all five; explain SoftPulse QUIT→GUARD→FIRST + `explainGrading`; guided/scaffolded/unguided/checkpoint `deal.mode` `none` (cues `stop`/`decline`/`cash`/`edge`); scaffolded+unguided one-per-press complete; checkpoint hintless. Structural clean — not appended to LPT-667.
- Curriculum multi-concept / edge-vs-end-session still **LPT-250** needs-human (tip-commented). Done-ack **LPT-248**/249. Design-record Still-a-list discipline quizzes STALE — do not file rebuild.
- Prior coverage already logged line-reading clean on `196d3505` (#2149 draft learnings) — skipped re-walk; next oldest after this fold is `lesson-05-09-02-section-five-checkpoint`.
- Never edit PRIMARY after #2150 — ship learnings from `$PRIMARY/.worktrees/content-agent` only.
- next: **LPT-667** one-per-press implement OR **LPT-348** Capstone human policy OR next oldest discovery (`lesson-05-09-02-section-five-checkpoint`).
- act-05-09-01-*: structural clean on tip — curriculum split only via LPT-250; not on LPT-667.

## Fold 2026-10-13dl (fee963ac discovery section-five-checkpoint)

- Tip-stable `fee963ac` (#2150). `scan_content_gaps --counts` all structural gaps **0**; softpulseMapArms **92** / densifyHelperArms **229**. Open Medium: **LPT-667** In Progress (6 one-per-press — already HAS tip, leave IP) + **LPT-348** Capstone needs-human. No catalog parent rebuild.
- Discovery oldest-unfresh `lesson-05-09-02-section-five-checkpoint`: all five `scaffolded` + `assessmentRole: checkpoint` with teachSpec; cp-multi/tell/stop `deal.mode` `none` + cue kind `none` (`nut`/`soft`/`stop`) on felt (`s5Cp*Outcomes`); cp-value/catch `fixed` Jh9d/Kc9s4h2d7c (+ suit-rotated variants) match Dart `LessonActionSpot` + cues `bet`/`call` kind `none`; pressHints null (correct). Structural clean.
- Done-ack **LPT-251** (teachSpec) + **LPT-467** (densify). Design-record Still-a-list “multiway, tell, and stop checks” STALE — do not file rebuild. No needs-human multi-objective split (assessment container rule).
- Also folded prior unmerged session-discipline learnings (dk) from sticky-worktree tip in this chore PR.
- next: **LPT-667** one-per-press implement OR **LPT-348** Capstone human policy OR next oldest discovery (`lesson-06-01-01-range-nut-advantage`).
- act-05-09-02-*: structural clean on tip — not on LPT-667; assessment skips curriculum split clones.

## Fold 2026-10-13dm (196d3505 line-reading — monitor rescue of #2149)

- Tip at fold `6d9cbf37` (#2152); discovery originally on `196d3505` (#2148). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Open Medium: **LPT-667** (6 one-per-press, IP) + Capstone **LPT-348**.
- Discovery oldest-unfresh `lesson-05-06-01-line-reading` (Street-by-street updates): explain has `explainGrading`; guided SoftPulse; scaffolded fixed 7h6h/Kh9h2c3d + variants + one-per-press; unguided one-per-press; checkpoint hintless. Structural clean. Curriculum multi-concept **LPT-239** needs-human (tip-commented on discovery run).
- Conflicted draft #2149 never landed; #2152 only referenced “prior coverage” — this fold ships the durable run-memory so next agents do not re-struggle the walk.
- next: **LPT-667** one-per-press implement OR **LPT-348** Capstone human policy OR next oldest `lesson-06-01-01-range-nut-advantage`.
- act-05-06-01-*: structural clean on tip — curriculum split only via LPT-239.

## Fold 2026-10-13dn (4c59e118 range-nut — monitor rescue of #2154)

- Tip `4c59e118` (#2156) after product tip `cacc5987` (#2153): **LPT-667** Done — one-per-press remaining **0**; catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Do not reopen LPT-667 or empty-array parent LPT-626. Capstone `NO_HINT` stays **LPT-348** needs-human.
- Discovery (originally on `6d9cbf37` / conflicted #2154): oldest-unfresh `lesson-06-01-01-range-nut-advantage` — explain has `explainGrading` (ADVANTAGE cues); guided SoftPulse; scaffolded/unguided one-per-press; unguided fixed `Ah`/`Kd`·`Kc`/`7s`/`2d` + variants; checkpoint hintless. Structural clean. Curriculum multi-concept **LPT-254** needs-human (tip-commented).
- Open Medium content: **LPT-348** only (+ Low curriculum). High content open: **0**.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-02-01-equity-realization` / Low curriculum.
- act-06-01-01-*: structural clean on tip — curriculum split only via LPT-254; do not re-file ADVANTAGE/TAG course-contract (LPT-666 Done).

## Fold 2026-10-13do (6d9f3068 discovery equity-realization)

- Tip-stable `6d9f3068` (#2157 after #2153 **LPT-667** Done). `scan_content_gaps --counts` all structural gaps **0**; softpulseMapArms **92** / densifyHelperArms **229**. Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Sole open Medium content: Capstone **LPT-348** needs-human (five `NO_HINT` hands; already **HAS** tip SHA — no re-spam). High content open: **0**.
- Discovery oldest-unfresh `lesson-06-02-01-equity-realization` (Realize equity in and out of position): all five teachSpec PRESENT; explain SoftPulse EQUITY→CASH→POS + `explainGrading`; guided/scaffolded/unguided/checkpoint `deal.mode` `none` (cues `ip` / `discount` / `realize` / `pos`); scaffolded+unguided one-per-press complete; checkpoint hintless. Structural clean — not a pressHints/deal-variants/handFamily clone.
- Curriculum multi-concept + checkpoint Prefer-IP vs position+initiative still **LPT-257** needs-human (tip-commented on `6d9f3068`). Design-record Still-a-list “realization quizzes” STALE — do not file rebuild.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-07-01-minimum-defense` / Low curriculum.
- act-06-02-01-*: structural clean on tip — curriculum split only via LPT-257.

## Fold 2026-10-13dp (6d9f3068 discovery minimum-defense)

- Tip-stable `6d9f3068` (#2157). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** (already HAS tip). Prior fold do covered equity-realization + **LPT-257**.
- Discovery oldest-unfresh `lesson-06-07-01-minimum-defense`: teachSpec on all five; explain DEFEND→BLUFF→ENOUGH + `explainGrading`; guided/unguided/checkpoint `deal.mode` `none`; scaffolded `fixed` + variants + one-per-press; unguided one-per-press; checkpoint hintless. Structural clean.
- Curriculum multi-concept / Any-two-% distractor / punish-vs-catchers still **LPT-273** needs-human (tip-commented on `6d9f3068`). Still-a-list continue/intuition/punish STALE — no rebuild.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-09-01-threebet-fourbet` / Low curriculum.
- act-06-07-01-*: structural clean on tip — curriculum split only via LPT-273.

## Fold 2026-10-13dq (6d9f3068 discovery threebet-fourbet)

- Tip-stable `6d9f3068` (#2157). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Re-verified Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Sole open Medium: Capstone **LPT-348** (already HAS tip). Prior folds do/dp covered equity-realization + minimum-defense.
- Discovery oldest-unfresh `lesson-06-09-01-threebet-fourbet`: teachSpec on all five; explain 3BET→4BET→DEPTH + `explainGrading`; guided/unguided/checkpoint `deal.mode` `none`; scaffolded `fixed` + variants + one-per-press; unguided one-per-press; checkpoint hintless. Structural clean.
- Curriculum multi-concept (tighten 4-bet / SPR plan / ego 4-bets) still **LPT-282** needs-human (tip-commented on `6d9f3068`). Still-a-list commit/ego/SPR STALE — no rebuild.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-10-01-difficult-folds` / Low curriculum.
- act-06-09-01-*: structural clean on tip — curriculum split only via LPT-282.

## Fold 2026-10-13dr (6d9f3068 discovery difficult-folds)

- Tip-stable `6d9f3068` (#2157). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Sole open Medium: Capstone **LPT-348** (already HAS tip).
- Discovery oldest-unfresh `lesson-06-10-01-difficult-folds`: teachSpec on all five; explain SoftPulse + `explainGrading`; guided `fixed` + variants; scaffolded/unguided `deal.mode` `none` one-per-press; checkpoint hintless. Structural clean.
- Curriculum multi-concept (dominated one-pair / coolers / ego call-downs) still **LPT-285** needs-human (tip-commented on `6d9f3068`).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-11-03-adjust-tag` / Low curriculum.
- act-06-10-01-*: structural clean on tip — curriculum split only via LPT-285.

## Fold 2026-10-13ds (6d9f3068 discovery adjust-tag + observe-wide-pressure)

- Tip-stable `6d9f3068` (#2157). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Re-verified Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Sole open Medium: Capstone **LPT-348** (already HAS tip).
- Discovery `lesson-06-11-03-adjust-tag`: teachSpec on all five; explain CREDIT→TIGHTER→NO LIGHT + `explainGrading`; guided/scaffolded/unguided `fixed` + variants + one-per-press; checkpoint cite tiles hintless. Structural clean. Curriculum **LPT-294** tip-commented.
- Discovery `lesson-06-12-01-observe-wide-pressure`: teachSpec on all five; explain SoftPulse + `explainGrading`; all interactive `deal.mode` `none`; scaffolded/unguided one-per-press; checkpoint hintless. Structural clean. Curriculum **LPT-297** tip-commented.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-12-02-meet-lag` / Low curriculum.
- act-06-11-03-* / act-06-12-01-*: structural clean — curriculum splits only via LPT-294 / LPT-297.

## Fold 2026-10-13dt (35c01162 discovery meet-lag — rescue unfolder #2159)

- Tip mid-run `6d9f3068` → `35c01162` (#2158). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Sole open Medium: Capstone **LPT-348**.
- Discovery oldest-unfresh `lesson-06-12-02-meet-lag`: teachSpec on all five; explain SoftPulse WIDE→PRESSURE→MODEL + `explainGrading`; interactive `deal.mode` `none`; scaffolded/unguided one-per-press; checkpoint hintless. Structural clean. Curriculum **LPT-300** needs-human (tip-commented).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-13-01-mix-five-types` / Low curriculum.
- act-06-12-02-*: structural clean on tip — curriculum split only via LPT-300.

## Fold 2026-10-14a (216437dc discovery mix-five-types — rescue unfolder #2161)

- Tip `216437dc` (#2160 ui-agent non-content after #2158). Catalog `--counts` structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Meet Nit Nice!+pressHints cleared; **LPT-216** Done; **LPT-667** Done (one-per-press **0**). Sole open Medium: Capstone **LPT-348** needs-human (five NO_HINT hands; already **HAS** tip — no re-spam).
- Discovery oldest-unfresh `lesson-06-13-01-mix-five-types`: teachSpec on all five; explain SoftPulse CARDS/SEATS/EVIDENCE + `explainGrading`; guided/scaffolded/unguided `poker_action_sizing` `deal.mode` `fixed` Jh/Td·Qc/Ts/3h/2d/7c match Dart + suit-rotated `deal.variants`; scaffolded/unguided one-per-press; checkpoint hintless cite (`deal.mode` `none`, cue `tag`). Structural clean — no new grokbot clone.
- Curriculum multi-concept still **LPT-306** needs-human (tip-commented on `216437dc`). Still-a-list label check STALE — no rebuild.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-13-02-section-six-checkpoint` / Low curriculum.
- act-06-13-01-*: structural clean on tip — curriculum split only via LPT-306.

## Fold 2026-10-14b (216437dc discovery section-six-checkpoint)

- Tip-stable `216437dc` (#2160). Catalog `--counts` structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** (already HAS tip). High content open: **0**.
- Discovery oldest-unfresh `lesson-06-13-02-section-six-checkpoint`: all five `assessmentRole` checkpoint + teachSpec PRESENT; `deal.mode` `none` + SoftPulse cues `ra` / `cap` / `polar` / `tag` / `lag` (cue kind `none`); pressHints empty (correct for assessment); densify helper arms PRESENT for all five `act-06-13-02-cp-*`. Structural clean — no new grokbot clone; no needs-human multi-objective split (assessment container).
- Done-ack tip-commented **LPT-307** (teachSpec) + **LPT-444** (densify) on `216437dc`. Design-record Still-a-list “advantage, cap, polar, TAG, and LAG checks” STALE — do not file rebuild.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-01-01-preflop-to-flop` / Low curriculum **LPT-310**.
- act-06-13-02-cp-*: structural clean on tip — companions LPT-307/444 Done.

## Fold 2026-10-14c (2a23197a discovery preflop-to-flop)

- Tip `2a23197a` (#2162 learnings after section-six-checkpoint). Catalog `--counts` structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human. High content open: **0**.
- Discovery oldest-unfresh `lesson-07-01-01-preflop-to-flop`: teachSpec on all five; explain SoftPulse REASON→CONFIRM→CANCEL + activity-level `explainGrading`; guided/scaffolded/unguided/checkpoint outcome tiles `deal.mode` `none` + cues `dead` / `value` / `thesis` / `abandon` (checkpoint cue kind `none`); scaffolded+unguided one-per-press complete; densify helper arms PRESENT (`act-07-01-01-guided`/`scaffolded`/`unguided`/`checkpoint` — LPT-656 Done). Structural clean — no new grokbot clone; Still-a-list plan quizzes STALE — no rebuild.
- Curriculum multi-concept still **LPT-310** needs-human (thesis / flop-update / abandon under one unlock) — tip-commented on `2a23197a`. Tip-commented Capstone **LPT-348** + Done-ack LPT-308/445/656/667/626/624/625/627/628/635/216 (prior tip SHA missing on new tip).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-02-01-flop-to-turn-map` / Low curriculum.
- act-07-01-01-*: structural clean on tip — curriculum split only via LPT-310; teachSpec/densify companions LPT-308/656 Done.

## Fold 2026-10-14d (ec75e4ae discovery flop-to-turn-map)

- Tip-stable `ec75e4ae` (#2163 learnings after preflop-to-flop). Catalog `--counts` structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip from merge-window — no re-spam). High content open: **0**. Prior curriculum **LPT-310** also HAS tip.
- Discovery oldest-unfresh `lesson-07-02-01-flop-to-turn-map`: teachSpec on all five; explain SoftPulse BARREL→GIVE-UP→MAP + activity-level `explainGrading`; guided/scaffolded/unguided/checkpoint outcome tiles `deal.mode` `none` + cues `ok` / `give` / `avoid` / `list` (checkpoint cue kind for definition); scaffolded+unguided one-per-press complete; densify helper arms PRESENT (`act-07-02-01-guided`/`scaffolded`/`unguided`/`checkpoint` — LPT-657 Done); scaffolded table atmosphere stays LPT-394 Done `Jh`/`9d`·`Ks`/`Tc`/`2d`/`3s`. Structural clean — no new grokbot clone; design-record Still-a-list “no-plan and definition checks” STALE — no rebuild.
- Curriculum multi-concept still **LPT-314** needs-human (continue cards / give-up cards / bet only with a turn map) — tip-commented on `ec75e4ae`. Done-ack tip-commented LPT-312/657/667/626/624/625/627/628/635/216/446/506 (NEED tip SHA).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-03-01-compose-river` / Low curriculum **LPT-317**.
- act-07-02-01-*: structural clean on tip — curriculum split only via LPT-314; teachSpec/densify companions LPT-312/657 Done.

## Fold 2026-10-14e (1978fa6a discovery river-composition)

- Tip-stable `1978fa6a` (#2165 learnings after flop-to-turn-map). Catalog `--counts` structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human. High content open: **0**.
- Discovery oldest-unfresh `lesson-07-03-01-river-composition`: teachSpec on all five; explain SoftPulse VALUE→BLUFF→HOLD + activity-level `explainGrading`; guided `poker_action_sizing` `deal.mode` `fixed` hero `As`/`Ad` board `Ac`/`9s`/`4h`/`2d`/`7c` matches Dart `resolveLessonActionSpot` + two suit-rotated `deal.variants` + cue `val`; scaffolded/unguided/checkpoint outcome tiles `deal.mode` `none` + cues `block` / `check` / `rule` (checkpoint cue kind `none`); scaffolded+unguided one-per-press complete; densify helper arms PRESENT (`act-07-03-01-scaffolded`/`unguided`/`checkpoint` — LPT-658 Done; guided is sizing — skip). Structural clean — no new grokbot clone; design-record Still-a-list “blocker, empty, and rule checks” STALE — no rebuild.
- Curriculum multi-concept still **LPT-317** needs-human (value candidates / blocker bluffs / check trash under one unlock; checkpoint objective still value-only vs rule-meta) — tip-commented on `1978fa6a`. Tip-commented Capstone **LPT-348** + Done-ack LPT-315/658/447/507/667/626/624/625/627/628/635/216 (all NEED tip SHA).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-04-01-pot-type-plans` / Low curriculum **LPT-320**.
- act-07-03-01-*: structural clean on tip — curriculum split only via LPT-317; teachSpec/densify companions LPT-315/658 Done.

## Fold 2026-10-14f (02762f5c discovery pot-type-plans)

- Tip-stable `02762f5c` (#2166 learnings after river-composition). Catalog `--counts` structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human. High content open: **0**.
- Discovery oldest-unfresh `lesson-07-04-01-pot-type-plans`: teachSpec on all five; explain SoftPulse LIMPED→SRP→3-4BET + activity-level `explainGrading`; guided/scaffolded/unguided/checkpoint outcome tiles `deal.mode` `none` + cues `nuts` / `cb` / `commit` / `both` (checkpoint cue kind `none`); scaffolded+unguided one-per-press complete; densify helper arms PRESENT (`act-07-04-01-guided`/`scaffolded`/`unguided`/`checkpoint` — LPT-659 Done). Structural clean — no new grokbot clone; design-record Still-a-list “pot-type quizzes” STALE — no rebuild; no handFamily gaps on `deal.mode` `none` tiles.
- Curriculum multi-concept still **LPT-320** needs-human (limped / SRP / 3-4bet under one unlock; checkpoint “Ranges and SPR” vs listed 3-bet/4-bet objective) — tip-commented on `02762f5c`. Tip-commented Capstone **LPT-348** + Done-ack LPT-318/448/659/508/667/626/624/625/627/628/635/216 (all NEED tip SHA).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-05-01-hu-vs-multiway` / Low curriculum.
- act-07-04-01-*: structural clean on tip — curriculum split only via LPT-320; teachSpec/densify companions LPT-318/659 Done.

## Fold 2026-10-14g (db21de67 discovery hu-vs-multiway)

- Tip mid-run `02762f5c`/`983fa0a0` → `db21de67` (#2168 STOP_FILE after #2167 pot-type). Catalog structural gaps all **0** (flat); softpulseMapArms **92** / densifyHelperArms **229**. Re-verified Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Sole open Medium: Capstone **LPT-348** needs-human.
- Discovery oldest-unfresh `lesson-07-05-01-hu-vs-multiway`: teachSpec on all five; explain SoftPulse FEWER→THICKER→WIDEN + `explainGrading`; guided/scaffolded/unguided/checkpoint `deal.mode` `none` outcome tiles; scaffolded/unguided one-per-press; densify PRESENT. Structural clean — Still-a-list player-count quizzes STALE — no rebuild.
- Curriculum multi-concept still **LPT-323** needs-human (tip-commented on `db21de67`). Tip-commented Capstone **LPT-348** + Done parents / **LPT-320** that NEED tip SHA.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-06-01-stack-depth-plans` / Low curriculum.
- act-07-05-01-*: structural clean on tip — curriculum split only via LPT-323.

## Fold 2026-10-14h (db21de67 discovery stack-depth-plans)

- Tip-stable `db21de67` (#2168). Catalog `--counts` structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Prior coverage claimed `learnings: updated` for hu-vs-multiway while draft #2169 was still unfolder — rescued that fold onto this chore branch. Sole open Medium: Capstone **LPT-348** needs-human. High content open: **0**.
- Discovery oldest-unfresh `lesson-07-06-01-stack-depth-plans`: teachSpec on all five; explain SoftPulse SHORT→DEEP→EFFECTIVE + activity-level `explainGrading` (“Short → Deep → Effective.”); guided/scaffolded/unguided/checkpoint outcome tiles `deal.mode` `none` + cues `commit` / `yes` / `40` / `every` (checkpoint cue kind `none`); scaffolded+unguided one-per-press complete; densify helper arms PRESENT (`act-07-06-01-guided`/`scaffolded`/`unguided`/`checkpoint` — LPT-450/LPT-661 Done). Structural clean — no new grokbot clone; design-record Still-a-list “depth quizzes” STALE — no rebuild; no handFamily gaps on `deal.mode` `none` tiles.
- Curriculum multi-concept still **LPT-326** needs-human (commit-short / implied-deep / recalculate-every-hand under one unlock) — tip-commented on `db21de67`. Done-ack LPT-324/450/510 (NEED tip SHA). Capstone **LPT-348** + **LPT-323** + Done catalog parents already HAS tip — no re-spam.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-07-01-same-cards-types` / Low curriculum.
- act-07-06-01-*: structural clean on tip — curriculum split only via LPT-326; teachSpec/densify companions LPT-324/450 Done.

## Fold 2026-10-14i (5d6ce7b0 discovery same-cards-types)

- Tip-stable `5d6ce7b0` (#2170 stack-depth learnings). Catalog `--counts` structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human. High content open: **0**.
- Discovery oldest-unfresh `lesson-07-07-01-same-cards-types`: teachSpec on all five; explain SoftPulse CARDS→MODELS→CITE + activity-level `explainGrading` (“Cards → Models → Cite.”); guided/scaffolded/unguided `poker_action_sizing` `deal.mode` `fixed` Ah/Kd · Kc8s3h (+2d unguided) match Dart `resolveLessonActionSpot` + suit-rotated `deal.variants`; SoftPulse cues `bet` / `fold` / `call`; scaffolded+unguided one-per-press complete; checkpoint `assessmentRole` hintless cue kind `none` (`base` via `sameCardsCheckpointOutcomes`); densify helper arm PRESENT (`act-07-07-01-checkpoint` — LPT-451/LPT-664 Done). Structural clean — no new grokbot clone; design-record Still-a-list “no-evidence check” STALE — no rebuild; no handFamily gaps on explain/checkpoint `deal.mode` `none`.
- Curriculum multi-concept still **LPT-330** needs-human (type-cite vs baseline-absent vs practice-all-five under one unlock) — tip-commented on `5d6ce7b0`. Tip-commented Capstone **LPT-348** + Done-ack LPT-328/329/451/664/667/626/624/625/627/628/635/216 (all NEED tip SHA).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-08-01-type-board-line` / Low curriculum.
- act-07-07-01-*: structural clean on tip — curriculum split only via LPT-330; teachSpec/pressHints/densify companions LPT-328/329/451 Done.

## Fold 2026-10-14j (34a43238 discovery type-board-line)

- Tip `34a43238` (#2171 after #2170). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Re-verified Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Sole open Medium: Capstone **LPT-348** needs-human.
- Discovery oldest-unfresh `lesson-07-08-01-type-board-line`: teachSpec on all five; explain SoftPulse + `explainGrading`; guided/scaffolded/unguided `fixed` + variants + one-per-press; checkpoint `deal.mode` `none` hintless; densify PRESENT on checkpoint (sizing steps skip SI densify). Structural clean.
- Curriculum multi-concept still **LPT-333** needs-human (tip-commented on `34a43238`). Tip-commented Capstone **LPT-348** + **LPT-330** + Done parents that NEED tip SHA.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-09-01-leak-review-book` / Low curriculum.
- act-07-08-01-*: structural clean on tip — curriculum split only via LPT-333.

## Fold 2026-10-14k (34a43238 discovery leak-review-book; rescue #2172)

- Tip-stable `34a43238` (#2171). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Rescued unfolder draft #2172 type-board-line fold onto this chore. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam).
- Discovery oldest-unfresh `lesson-07-09-01-leak-review-book`: teachSpec on all five; explain SoftPulse LEAK→BOOK→REVIEW + activity-level `explainGrading`; interactive `deal.mode` `none` SoftPulse/outcome tiles cues `spec`/`book`/`sched`/`base` (no handFamily); scaffolded+unguided one-per-press complete; checkpoint `assessmentRole` hintless; densify helper arms PRESENT (`act-07-09-01-*` — LPT-453/LPT-662 Done). Structural clean — no new grokbot clone; design-record Still-a-list “book quizzes” STALE — no rebuild.
- Curriculum multi-concept still **LPT-336** needs-human (name-leaks / write-defaults / schedule-review + checkpoint book-purpose vs schedule) — tip-commented on `34a43238`. Done-ack LPT-334/335/453/662/511 (NEED tip SHA). **LPT-348**/333/parents already HAS — no re-spam.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-10-01-capstone-srp` / `lesson-07-11-01-live-warmup` / Low curriculum.
- act-07-09-01-*: structural clean on tip — curriculum split only via LPT-336; teachSpec/pressHints/densify companions LPT-334/335/453 Done.

## Fold 2026-10-14l (f95fbbb0 discovery capstone-srp)

- Tip-stable `f95fbbb0` (#2173 after #2171). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam).
- Discovery oldest-unfresh `lesson-07-10-01-capstone-srp`: teachSpec on both activities; explain SoftPulse PLAN→UPDATE→FINISH + activity-level `explainGrading` (`deal.mode` `none`); hand scaffolded `authored_multi_step_hand` `deal.mode` `fixed` Ah/Qd · Kc7s2h/+2d/+9c (+2 suit-rotated `deal.variants`) matching Dart `resolveToyHandStepSpot`; cues `cb`/`barrel`/`check-r`; pressHints empty — intentional Capstone SoftPulse-quiet / `NO_HINT_ACTIVITY_IDS` (needs-human **LPT-348** only; do not reopen LPT-626/667). Synthesis container — no curriculum-split ticket. Design-record Still-a-list empty / Plan·Update·Finish on felt — no rebuild. Structural clean aside from Capstone NO_HINT policy.
- Tip-commented Done-ack LPT-337/338/339/341/345/347/349 (NEED tip SHA). **LPT-348**/parents/LPT-334/335/453/511/216/667 already HAS — no re-spam.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-10-02-capstone-3bet` / `lesson-07-11-01-live-warmup-prep` (curriculum **LPT-351**) / Low curriculum.
- act-07-10-01-*: structural clean on tip — Capstone pressHints policy only via LPT-348; teachSpec companion LPT-337 Done.

## Fold 2026-10-14m (6a883805 discovery capstone-3bet)

- Tip-stable `6a883805` (#2174 Capstone SRP learnings). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human.
- Discovery oldest-unfresh `lesson-07-10-02-capstone-3bet`: teachSpec on both activities; explain SoftPulse SPR→TURN→CLOSE + activity-level `explainGrading` (`deal.mode` `none`); hand scaffolded `authored_multi_step_hand` `deal.mode` `fixed` Ah/Qd · Qs8h3d/+2d/+7c (Q83r) (+2 suit-rotated `deal.variants`) matching Dart `resolveToyHandStepSpot`; cues `bet`/`barrel`/`fold`; pressHints empty — Capstone SoftPulse-quiet / `NO_HINT_ACTIVITY_IDS` (needs-human **LPT-348** only; do not reopen LPT-626/667). Synthesis container — no curriculum-split ticket. Design-record Still-a-list empty / SPR·Turn·Close on felt — no rebuild. Structural clean aside from Capstone NO_HINT policy.
- Prior coverage on `6a883805` listed LPT-348/parents+Capstone Dones while `jira.py get` still showed only `f95fbbb0` — tip-commented **LPT-348** + Done-ack **LPT-339** + Capstone Done LPT-337/338/341/345/347/349 + parents LPT-667/626/624/625/627/628/635 + LPT-216/334 the same tick (verified HAS).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-10-03-capstone-multiway-deep` / `lesson-07-11-01-live-warmup-prep` (curriculum **LPT-351**) / Low curriculum.
- act-07-10-02-*: structural clean on tip — Capstone pressHints policy only via LPT-348; teachSpec companion LPT-339 Done.

## Fold 2026-10-14n (706cf460 discovery Capstone multiway + live-warmup)

- Tip `706cf460` (#2175 after #2174). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Re-verified Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Sole open Medium: Capstone **LPT-348** needs-human.
- Discovery oldest-unfresh `lesson-07-10-03-capstone-multiway-deep`: teachSpec on explain+hand; explain SoftPulse + `explainGrading`; hand `fixed` AhQh/Jh8h2c3d9c + variants; cues 3 presses; pressHints empty → **LPT-348** only (no curriculum-split). Structural clean aside from Capstone NO_HINT policy. Done-ack **LPT-341**.
- Discovery `lesson-07-11-01-live-warmup-prep`: teachSpec on all five; explain SoftPulse + `explainGrading`; interactive `deal.mode` `none`; scaffolded/unguided one-per-press; checkpoint hintless. Structural clean. Curriculum **LPT-351** tip-commented.
- Tip-commented NEED parents on `706cf460`. Deleted stale typeboard draft branch if still remote.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-10-04-capstone-limped` / `lesson-07-12-01-five-type-final` / Low curriculum.
- act-07-10-03-* / act-07-11-01-*: Capstone policy via LPT-348; warm-up curriculum via LPT-351.

## Fold 2026-10-14o (706cf460 discovery Capstone limped)

- Tip-stable `706cf460` (#2175). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Rescued unfolder draft #2176 (multiway+warmup) onto this chore. Sole open Medium: Capstone **LPT-348** needs-human.
- Discovery oldest-unfresh `lesson-07-10-04-capstone-limped`: explain SoftPulse NUTS→VALUE→THIN + `explainGrading`; hand `fixed` Ah/Kh · Kd/9c/4h/2s/8d + 2 suit variants match Dart `resolveToyHandStepSpot`; cues `bet`/`barrel`/`value` (3 presses); pressHints empty → **LPT-348** only (synthesis container — no curriculum-split). Structural clean aside from Capstone NO_HINT policy. Done-ack **LPT-345**.
- Tip-commented NEED Capstone/Done siblings LPT-345/337/338/339/347/349/352/334 on `706cf460`; **LPT-348**/parents/351/216/667 already HAS — no re-spam.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-07-10-05-capstone-4bet` / `lesson-07-12-01-five-type-final` / Low curriculum.
- act-07-10-04-*: structural clean on tip — Capstone pressHints policy only via LPT-348; teachSpec companion LPT-345 Done.

## Fold 2026-10-14p (e8523695 / 39869c64 Capstone 4-bet)

- Tip-stable `e8523695` (#2177) folded via #2178 (`39869c64`). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human.
- Discovery `lesson-07-10-05-capstone-4bet`: explain SoftPulse SPR→COMMIT→NO HERO + `explainGrading`; hand `fixed` Kh/Kd · Qs8h3d2dAd + suit variants match Dart; cues `bet`/`barrel`/`fold`; pressHints empty → **LPT-348** only (no curriculum-split). Structural clean.
- next was: LPT-348 OR `lesson-07-12-01-five-type-final` / Low curriculum.

## Fold 2026-10-14q (d2ed1c8a discovery five-type-final)

- Tip mid-run `39869c64`→`d2ed1c8a` (#2179 content-agent loop ops). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human.
- Discovery oldest-unfresh `lesson-07-12-01-five-type-final`: all seven `act-07-12-01-*` scaffolded + `assessmentRole` checkpoint; teachSpec `deal.mode` `none` + SoftPulse cues `cs`/`nit`/`man`/`tag`/`lag`/`low`/`retire` kind `none`; densify arms PRESENT; pressHints empty (assessment — correct); no curriculum-split (assessment container). Design-record Still-a-list STALE — no rebuild. Structural clean. Done-ack **LPT-352** / densify **LPT-443**.
- Tip-commented **LPT-348** + Done-ack LPT-352/443/347/345/337/338/339/341/349/334/216/667 + Done parents LPT-624/625/626/627/628/635 on `d2ed1c8a` (all NEED before comment; verified HAS).
- next: **LPT-348** Capstone human policy OR oldest Low curriculum discovery (`lesson-01-02-02-best-five-kickers` / `lesson-01-05-01-winning-pots` / … — five-type-final now walked).
- act-07-12-01-*: structural clean on tip — teachSpec companion LPT-352 Done; densify LPT-443 Done.


## Fold 2026-10-14r (528069f0 discovery winning-pots)

- Tip-stable `528069f0` (#2180 after #2179). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam). Prior same-tip walks: five-type-final + best-five-kickers (**LPT-93**).
- Discovery oldest-unfresh `lesson-01-05-01-winning-pots`: explain SoftPulse FOLD WIN→SHOWDOWN→SIDE POT + `explainGrading`; guided fold-win `fixed` AhKd + suit variants cue `no-show`; scaffolded showdown fixed+board + one-per-press; unguided-pot `deal.mode` `none` + open-to `deal.variants` + one-per-press (chip tiles); checkpoint-side assessmentRole checkpoint hintless cue kind `none`; densify arms PRESENT for guided/scaffolded/unguided/checkpoint. Structural clean. Curriculum **LPT-106** tip-commented (three concepts still valid). Done-ack LPT-104/374/485/525.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-01-06-01-guided-complete-hand` (synthesis — no new curriculum split) / `lesson-01-06-02-section-one-jump` / `lesson-02-02-01-hand-families` (**LPT-121**).
- act-01-05-01-*: structural clean on tip — teachSpec LPT-104 Done; densify LPT-485/525 Done; curriculum via LPT-106 only.

## Fold 2026-10-14s (118e4148 discovery guided-complete-hand)

- Tip-stable `118e4148` (#2182 after winning-pots fold). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam). Catalog parents LPT-624/625/626/627/628/635/667/216 already HAS tip.
- Discovery oldest-unfresh `lesson-01-06-01-guided-complete-hand` (Play a full toy hand): explain SoftPulse BLINDS→YOU ACT→ENDING + `explainGrading`; guided-steps `random_in_class` suited_ace/suited SoftPulse cues (Hint off while gold); scaffolded-multi one-per-press OK; unguided-lab `random_in_class` high_card/offsuit + pressHints press 1; checkpoint-finish assessmentRole checkpoint cue kind `none` hintless; handFamily/suitFamily enums valid; densify N/A. Structural clean. Synthesis container — no new curriculum-split.
- Done-ack LPT-108/109/358/375/586/558/97 on tip (all NEED before comment).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-01-06-02-section-one-jump` / `lesson-02-02-01-hand-families` (**LPT-121**) / Low curriculum.
- act-01-06-01-*: structural clean on tip — teachSpec LPT-108 Done; pressHints LPT-109/667 Done; explain LPT-358 Done; variants LPT-375 Done; wave labs LPT-586/558 Done.

## Fold 2026-10-14u (be5bc2c2 discovery facing-raise)

- Tip `be5bc2c2` (#2185 after #2183). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Re-verified Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Sole open Medium: Capstone **LPT-348** (already HAS tip — no re-spam).
- Discovery oldest-unfresh `lesson-02-04-01-facing-raise` (Versus an open): teachSpec on all five; explain SoftPulse + `explainGrading`; guided SoftPulse; scaffolded/unguided one-per-press; checkpoint hintless. Structural clean.
- Curriculum multi-concept still **LPT-127** needs-human (tip-commented on `be5bc2c2`). Tip-commented Done parents that NEED tip SHA (incl. **LPT-216**).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-05-03-01-implied-odds` / Low curriculum.
- act-02-04-01-*: structural clean on tip — curriculum split only via LPT-127.

## Fold 2026-10-14v (be5bc2c2 discovery implied-odds — rescued)

- Tip `be5bc2c2` (#2185) walk after facing-raise; coverage had `learnings: pending` while #2186 only folded facing-raise — rescue onto tip `d4097dd7` (#2188).
- Discovery `lesson-05-03-01-implied-odds`: structural clean — explain SoftPulse IMPLIED→REVERSE→SECOND + `explainGrading`; guided/scaffolded/unguided fixed+suit variants; SoftPulse maps `call-io`/`rio`/`nonut` PRESENT; one-per-press OK; checkpoint hintless densify PRESENT.
- Curriculum **LPT-230** tip-commented (still valid). Capstone **LPT-348** already HAS prior tip.
- next: **LPT-348** OR `lesson-05-04-01-thin-value-bluffcatch` (**LPT-233**) / Low curriculum.
- act-05-03-01-*: structural clean — curriculum via LPT-230 only.

## Fold 2026-10-14w (d4097dd7 discovery thin-value)

- Tip-stable `d4097dd7` (#2188 after #2186 facing-raise fold). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human.
- Rescued unfolder implied-odds notes; tip-commented parents+LPT-348/127/230 + Done facing-raise siblings + Done thin-value siblings on `d4097dd7` (quoted heredoc — never unquoted `<<PY`).
- Discovery oldest-unfresh `lesson-05-04-01-thin-value-bluffcatch`: explain SoftPulse THIN→CATCH→BARRELS + `explainGrading`; guided/scaffolded/unguided fixed Jh9d·Kc9s4h2d7c + suit variants match Dart; SoftPulse maps `tv`/`call-m`/`check-nit` PRESENT; one-per-press OK; checkpoint hintless densify PRESENT. Structural clean. Curriculum **LPT-233** tip-commented.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-03-08-02-section-three-jump-test` / `lesson-05-05-01-lines-and-probes` / Low curriculum.
- act-05-04-01-*: structural clean on tip — teachSpec LPT-231 Done; pressHints LPT-232 Done; variants LPT-609 Done; SoftPulse-map LPT-614 Done; densify LPT-459/516 Done; curriculum via LPT-233 only.

## Fold 2026-10-14x (8bad05d8 discovery section-three-jump)

- Tip-stable `8bad05d8` (#2190 after thin-value fold). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam). Parents already HAS.
- Discovery oldest-unfresh `lesson-03-08-02-section-three-jump-test`: structural clean (see bullet above). Done-ack LPT-381/367/418/419 (NEED on tip); LPT-165/389/425/426/391/554/555 already HAS.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-05-05-01-lines-and-probes` / `lesson-06-11-01-observe-selective` / Low curriculum (`lesson-01-02-01-hand-ranks` **LPT-90**).
- act-03-08-02-*: structural clean on tip — jump_test assessment container only.

## Fold 2026-10-14y (8bad05d8 discovery observe-selective)

- Tip-stable `8bad05d8` (#2190). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam). Re-verified Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Rescued unfolder s3jump drafts #2191/#2192 onto this chore (Prefer discovery walk + Recent fold 14x).
- Discovery oldest-coverage `lesson-06-11-01-observe-selective`: explain SoftPulse TIGHT→BARREL→SAMPLE + `explainGrading`; guided/scaffolded/unguided/checkpoint observation tiles `deal.mode` `none` (no handFamily); SoftPulse cues `sel`/`disc`/`low` + checkpoint `bundle` kind `none`; scaffolded/unguided one-per-press OK; densify LPT-435 + SoftPulse guideRegion LPT-494 Done. Structural clean. Curriculum **LPT-288** tip-commented (three concepts + checkpoint evidence-bundle vs sample-delay still valid).
- Done-ack **LPT-286** / **287** / **435** / **494** on tip (NEED before comment).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-12-03-adjust-lag` / `lesson-05-05-01-lines-and-probes` / Low curriculum.
- act-06-11-01-*: structural clean on tip — teachSpec/pressHints/densify/SoftPulse companions Done; curriculum via LPT-288 only.

## Fold 2026-10-14z (8bad05d8 discovery adjust-lag)

- Tip-stable `8bad05d8` (#2190). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam). Parents already HAS. Re-verified Meet Nit Nice!+pressHints cleared; **LPT-216** Done.
- Discovery oldest-coverage `lesson-06-12-03-adjust-lag`: explain SoftPulse CALL→TRAP→FANCY LESS + `explainGrading`; guided/scaffolded `poker_action_sizing` fixed+suit variants matching Dart; SoftPulse maps `call`/`trap` PRESENT; unguided/checkpoint outcome tiles densify PRESENT; scaffolded/unguided one-per-press OK; Still-a-list avoid/cite STALE. Structural clean. Curriculum **LPT-303** tip-commented (widen/trap/avoid/cite + checkpoint cite-vs-widen still valid).
- Done-ack **LPT-301** / **302** / **441** / **503** / **651** on tip (NEED before comment).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-03-01-capped-uncapped` / `lesson-05-05-01-lines-and-probes` / Low curriculum.
- act-06-12-03-*: structural clean on tip — teachSpec/pressHints/densify/SoftPulse companions Done; curriculum via LPT-303 only.

## Fold 2026-10-14aa (e3f57aee discovery capped-uncapped)

- Tip-stable `e3f57aee` (#2194 after #2190). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam). Parents already HAS. Meet Nit Nice!+pressHints cleared; **LPT-216** Done.
- Discovery oldest-coverage `lesson-06-03-01-capped-uncapped`: explain SoftPulse CAPPED→UNCAPPED→NUTS + `explainGrading`; guided/unguided/checkpoint `deal.mode` `none` outcome tiles densify PRESENT; scaffolded fixed Jh/9d·Kc9s4h2d7c + suit variants match Dart `resolveLessonActionSpot`; SoftPulse map `bet` PRESENT; scaffolded/unguided one-per-press OK; checkpoint hintless cue kind `none`; Still-a-list check-turn/bomb/attack STALE. Structural clean. Curriculum **LPT-260** tip-commented (spot capped / respect uncapped / attack caps still valid).
- Done-ack **LPT-258** / **259** / **470** / **636** on tip (NEED before comment).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-04-01-polar-merged` / Low curriculum (`lesson-01-02-01-hand-ranks` **LPT-90**).
- act-06-03-01-*: structural clean on tip — teachSpec/pressHints/densify companions Done; curriculum via LPT-260 only.

## Fold 2026-10-14ab (de176d1b discovery polar-merged — rescued)

- Tip-stable `de176d1b` (#2195 after #2194). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam). Parents already HAS. Meet Nit Nice!+pressHints cleared; **LPT-216** Done.
- Prior coverage left `lesson-06-04-01-polar-merged` with `learnings: pending` — fold rescued here. Discovery: explain SoftPulse POLAR→MERGED→SIZE + `explainGrading`; guided/unguided/checkpoint `deal.mode` `none` densify PRESENT; scaffolded fixed Jh/Td·Qc/Ts/3h/2d/7c + suit variants match Dart (LPT-395 second-pair); SoftPulse map `mid` PRESENT; scaffolded/unguided one-per-press OK; checkpoint hintless cue `thin` kind `none`. Structural clean. Curriculum **LPT-264** tip-commented (polar / merged thin / mismatch + checkpoint aim-vs-polar still valid).
- Done-ack **LPT-262** / **263** / **395** / **471** / **637** on tip (already HAS before this fold).
- next: oldest unfresh `lesson-02-05-01-effective-stack` (**LPT-130**) / Low curriculum.
- act-06-04-01-*: structural clean on tip — teachSpec/pressHints/densify/honesty companions Done; curriculum via LPT-264 only.

## Fold 2026-10-14ac (de176d1b discovery effective-stack)

- Tip-stable `de176d1b` (#2195). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam). Parents already HAS. Meet Nit Nice!+pressHints cleared; **LPT-216** Done.
- Discovery oldest-coverage `lesson-02-05-01-effective-stack`: explain SoftPulse CHIPS→BB→SHORTER→DEPTH + `explainGrading`; guided/scaffolded/unguided/checkpoint `deal.mode` `none` outcome tiles SoftPulse cues `bb-100` / `eff-60` / `depth-50` / checkpoint `bb-200` kind `none`; densify helper arms PRESENT for all four interactive acts; scaffolded/unguided one-per-press OK; checkpoint assessmentRole hintless. Structural clean. Curriculum **LPT-130** tip-commented (chips→BB / shorter=effective / depth-feel still valid under `unit-02-05-stacks`).
- Done-ack **LPT-128** / **129** / **364** / **482** on tip (NEED before comment).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-02-07-01-baseline-full-hand` / `lesson-06-05-01-overbets-geometric` / Low curriculum.
- act-02-05-01-*: structural clean on tip — teachSpec/pressHints/explain/densify companions Done; curriculum via LPT-130 only.

## Fold 2026-10-14ad (d0c4ff18 discovery baseline-full-hand)

- Tip-stable `d0c4ff18` (#2198). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Capstone **LPT-348** needs-human already HAS tip — no re-spam. Parents already HAS. Meet Nit Nice!+pressHints cleared; **LPT-216** Done.
- Discovery oldest-coverage `lesson-02-07-01-baseline-full-hand`: explain SoftPulse NINE→SAME→POSITION + `explainGrading`; guided `random_in_class` broadway/suited SoftPulse `open-ajs`; scaffolded pair SoftPulse `call-22` one-per-press OK; unguided-lab broadway/offsuit SoftPulse `lab-3bet` one-per-press OK; checkpoint habit `deal.mode` `none` cue `cover-wait` kind `none` densify PRESENT hintless. Structural clean. Filed needs-human curriculum **LPT-668** (full-ring open / vs-raise plan / habit-while-deciding under `unit-02-07-baseline-checkpoint`) — not a Capstone/jump assessment skip.
- Done-ack **LPT-135** / **136** / **365** / **383** / **487** / **586** on tip (NEED before comment).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-06-11-02-meet-tag` / `lesson-06-05-01-overbets-geometric` / Low curriculum (**LPT-668**).
- act-02-07-01-*: structural clean on tip — teachSpec/pressHints/explain/densify companions Done; curriculum via LPT-668 only.

## 2026-10-14ah — tip `d41550f0` type-id rescue + Meet Nit discovery

- Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **229**.
- Rescued `lesson-04-09-01-type-identification` coverage that left `learnings: pending` on tip `d41550f0` (curriculum **LPT-215** already tip-commented; Done LPT-213/214/431/495/560).
- Discovery oldest-coverage `lesson-04-07-02-meet-nit`: structural clean; tip-commented curriculum **LPT-198**; Done-ack LPT-196/197/423/440/543/563 + LPT-668.
- Open Medium: Capstone **LPT-348** needs-human only. Next: LPT-348 OR `lesson-04-07-01-observe-narrow-player` / `lesson-06-05-01-overbets-geometric` / Low curriculum.

## Fold 2026-10-14ai (d41550f0 discovery observe-narrow)

- Tip-stable `d41550f0` (#2203). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam). Re-verified Meet Nit Nice!+pressHints cleared; **LPT-216** Done. Rescued unfolder Confidence #2204 + Meet Nit #2205 onto this chore (Recent fold 14ag/14ah).
- Discovery oldest-coverage `lesson-04-07-01-observe-narrow-player`: explain SoftPulse RARE→ENTER→MEAN IT + `explainGrading`; guided/scaffolded/unguided/checkpoint observation tiles `deal.mode` `none` cues `narrow`/`strong-aggr`/`wait`/`bundle-nit`; scaffolded/unguided one-per-press OK; densify LPT-422 + SoftPulse guideRegion LPT-433 + permanent-gold LPT-538 + Nice! LPT-564 Done. Structural clean. Curriculum **LPT-195** tip-commented (three concepts + checkpoint bundle-vs-wait still valid).
- Done-ack **LPT-193** / **194** / **422** / **433** / **538** / **564** on tip (NEED before comment).
- next: **LPT-348** Capstone human policy OR next oldest `lesson-04-06-02-meet-calling-station` / `lesson-06-05-01-overbets-geometric` / Low curriculum.
- act-04-07-01-*: structural clean on tip — teachSpec/pressHints/Nice!/densify/SoftPulse companions Done; curriculum via LPT-195 only.

## Fold 2026-10-14aj (d41550f0 discovery meet-calling-station)

- Tip-stable `d41550f0` (#2203). Catalog structural gaps all **0**; softpulseMapArms **92** / densifyHelperArms **229**. Sole open Medium: Capstone **LPT-348** needs-human (already HAS tip — no re-spam). Rescued unfolder Confidence #2204 + Meet Nit #2205 + observe-narrow onto this chore.
- Discovery oldest-coverage `lesson-04-06-02-meet-calling-station`: explain SoftPulse STATION→HIGH→LOW + `explainGrading`; guided/scaffolded/unguided/checkpoint `deal.mode` `none` SoftPulse cues `pt-station` / `model` / `station2` / checkpoint `low` kind `none`; scaffolded/unguided one-per-press OK; densify LPT-420 + permanent-gold LPT-537/542 + Nice! LPT-566 Done. Structural clean. Curriculum **LPT-189** tip-commented (human-approved one-lesson-per-concept split; leave To Do for id/unlock migration).
- Done-ack **LPT-187** / **188** / **420** / **537** / **542** / **566** on tip (NEED before comment). Parents/348/195/198/215/216 already HAS — no re-spam.
- next: **LPT-348** Capstone human policy OR next oldest `lesson-04-06-03-adjust-calling-station` / `lesson-06-05-01-overbets-geometric` / Low curriculum.
- act-04-06-02-*: structural clean on tip — teachSpec/pressHints/Nice!/densify/gold companions Done; curriculum via LPT-189 only.

## Fold 2026-10-14ak (b9a0dcf5 LPT-348 Done after #2207)

- Tip mid-run `d41550f0`→`fd26597e`/#2207→`b9a0dcf5`/#2208. Catalog structural gaps all **0**.
- #2207 promotes all five Capstone `act-07-10-0N-hand` to `assessmentRole` `transfer` (cue kind `none`; `NO_HINT_ACTIVITY_IDS` sync; schema/docs). Acceptance met — **Done-ack LPT-348** (was In Progress / sole open Medium).
- Do not reopen LPT-626/LPT-667 for Capstone. Next discovery: `lesson-04-06-03-adjust-calling-station` / Low curriculum (LPT-189 still To Do for id migration).

## Fold 2026-10-14al (f907e7a1 discovery adjust-calling-station)

- Tip-stable `f907e7a1` (#2210 after #2207 Capstone transfer). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **229**. No open Medium content catalog tickets (**LPT-348** Done).
- Discovery oldest-coverage `lesson-04-06-03-adjust-calling-station`: explain SoftPulse VALUE→BLUFFS→CITE + `explainGrading` ("Value → Bluffs → Cite."); guided/scaffolded/unguided `poker_action_sizing` `deal.mode` `fixed` + suit-rotated variants match Dart (`Jh`/`Td`·`QcTs3h2d7c` thin-val; `8h`/`7h`·`Kh9h2c3d5s` missed-draw give-up; unguided same second-pair + unknown seat); SoftPulse maps `thin-val`/`give-up`/`baseline-check` PRESENT; scaffolded/unguided one-per-press OK; checkpoint `deal.mode` `none` cue `cite-fold` kind `none` densify PRESENT hintless. Structural clean. Curriculum **LPT-192** tip-commented (+`needs-human`; value/bluff/cite split still valid for id migration).
- Done-ack **LPT-190** / **191** / **421** / **565** / **399** + parents **LPT-624**/625/626/627/628/635/667 + **LPT-348**/216 on tip (all NEED before comment).
- next: `lesson-04-06-01-observe-sticky-caller` / `lesson-06-05-01-overbets-geometric` / Low curriculum (**LPT-192**/189 still To Do).
- act-04-06-03-*: structural clean on tip — teachSpec/pressHints/Nice!/densify/SoftPulse companions Done; curriculum via LPT-192 only.


## Fold 2026-10-14ar (2c1af5c0 mix + LPT-628 Done)

- 2026-10-14ar: Tip mid-run `11b692c0`→`2c1af5c0` (#2217 Section 1 one-per-concept batch + LPT-628 densify). densify-tap **3→0** / densifyHelperArms **229→232** — Done-ack+empty checklist **LPT-628** → Done. Other JSON **0**. Discovery `lesson-06-08-01-mixed-strategy` structural clean (MIX→PURPOSE→STRONG + `explainGrading`; guided 7h/7d·7cKd2s SoftPulse `protect` PRESENT; densify SI PRESENT scaffolded/unguided/checkpoint; one-per-press OK); tip-commented curriculum **LPT-277** (human-approved — no `needs-human`); Done-ack LPT-275/276/475/500/644 + parents/216/Meet Nit. No open Medium content catalog. next: `lesson-06-09-01-threebet-fourbet` / Low curriculum. Rescue unfolder overbets/blockers/min-defense chore PRs (#2216/#2218) onto this fold if still open.

## Fold 2026-10-14ap (11b692c0 discovery overbets — rescued)

- Tip-stable `11b692c0` (#2215). Catalog densify-tap **3** / densifyHelperArms **229**; other JSON **0**. Open Medium **LPT-628** (suits/pairs SI after #2212) — already HAS tip.
- Discovery `lesson-06-05-01-overbets-geometric`: structural clean; tip-commented curriculum **LPT-267** (human-approved — do not re-add `needs-human`); Done-ack LPT-265/266/472/497/638.
- Coverage left `learnings: pending` on draft #2216/#2218 — rescued onto tip `2c1af5c0` chore.

## Fold 2026-10-14aq (11b692c0 discovery blockers — rescued)

- Tip-stable `11b692c0`. Discovery `lesson-06-06-01-blockers`: structural clean; tip-commented **LPT-270** (human-approved); Done-ack LPT-268/269/473/498/639.
- Rescued from draft #2218 onto tip `2c1af5c0` chore.

## Fold 2026-10-14as (11b692c0 discovery minimum-defense — rescued)

- Tip-stable `11b692c0`. Discovery `lesson-06-07-01-minimum-defense`: structural clean (DEFEND→BLUFF→ENOUGH + `explainGrading`; scaffolded `9h`/`7d`·`KcQh9d4c8s` SoftPulse `fold`; densify+guideRegion PRESENT); tip-commented **LPT-273** (human-approved); Done-ack LPT-271/272/474/499/640.
- Rescued from draft #2218 onto tip `2c1af5c0` chore.

## Fold 2026-10-14at (2c1af5c0 discovery threebet-fourbet)

- Tip-stable `2c1af5c0` (#2217). Catalog densify-tap **0** / densifyHelperArms **232** / softpulseMapArms **92**; other JSON **0**. **LPT-628** Done. Rescued #2216/#2218 pending folds.
- Discovery `lesson-06-09-01-threebet-fourbet`: explain SoftPulse 3BET→4BET→DEPTH + `explainGrading`; guided/unguided/checkpoint `deal.mode` `none` SoftPulse `careful`/`avoid`/`spr` densify PRESENT; scaffolded `poker_action_sizing` fixed `Ah`/`Qd`·`8c`/`3h`/`2s` + suit variants match Dart SoftPulse `small` + `stackLabel` Stacks left 360; one-per-press OK; checkpoint hintless. Structural clean.
- Tip-commented curriculum **LPT-282** (human-approved — do not re-add `needs-human`); Done-ack LPT-280/281/476/501/645.
- next: `lesson-06-10-01-difficult-folds` / oldest unfresh / Low curriculum.
- act-06-09-01-*: structural clean on tip — teachSpec/pressHints/densify/SoftPulse companions Done; curriculum via LPT-282 only.

## Fold 2026-10-14au (463fbbb3 discovery difficult-folds)

- Tip-stable `463fbbb3` (#2220 after #2217). Catalog densify-tap **0** / densifyHelperArms **232** / softpulseMapArms **92**; other JSON **0**. **LPT-628** Done.
- Discovery `lesson-06-10-01-difficult-folds`: explain SoftPulse HARD→COOLER→EGO + `explainGrading`; guided `poker_action_sizing` fixed `Ah`/`9d`·`As`/`7c`/`2h`/`Kd`/`3c` + suit variants match Dart SoftPulse `fold`; scaffolded/unguided `deal.mode` `none` SoftPulse `cooler`/`ego` densify PRESENT one-per-press OK; checkpoint hintless cue kind `none` densify PRESENT. Structural clean.
- Tip-commented curriculum **LPT-285** (human-approved — do not re-add `needs-human`); Done-ack LPT-283/284/477/502 + parents LPT-628/624/626/625/627/635/216/667/348.
- next: `lesson-06-11-01-observe-selective` / oldest unfresh / Low curriculum.
- act-06-10-01-*: structural clean on tip — teachSpec/pressHints/densify/SoftPulse companions Done; curriculum via LPT-285 only.

## Fold 2026-10-14av (14d32fb9 discovery button unit + LPT-669)

- Tip-stable `14d32fb9` (#2223). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open catalog parents Done (no checklist rebuild). No open Medium content until this tick.
- Rescued prior suits/ranks/pairs coverage (`learnings: pending` on tip) and **corrected** it: JSON/`pressHints`/densify remain OK, but SoftPulse explain successors `act-01-01-02-02-explain-ranks` + `act-01-01-02-03-explain-pairs` lack Dart `isTableRegionTapActivity` / `resolveCoachDialogueVisual` — tip-commented **LPT-83** + Done companions.
- Discovery NEVER post-split Button children:
  - `lesson-01-01-03-01-dealer-button`: one objective; `act-01-01-03-explain-button` SoftPulse D→SB→BB + `explainGrading` **wired** in Dart; guided-button densify PRESENT; deal.mode `none` OK.
  - `lesson-01-01-03-02-small-and-big-blind`: one objective; scaffolded-blinds one-per-press OK; checkpoint hintless cue kind `none`; densify PRESENT — but `act-01-01-03-02-explain-blinds` SoftPulse SB→BB **not** in Dart table-tap/visual.
  - `lesson-01-01-03-03-blinds-post-first`: one objective; unguided-when one-per-press OK; densify PRESENT — but `act-01-01-03-03-explain-when` SoftPulse BLINDS→DEAL **not** in Dart table-tap/visual.
- Catalog scan of all `lessonSplitMap` SoftPulse explain successors: **16** missing Dart maps (S1 units 01-01-02 … 01-05-01). Filed **LPT-669** (`content,grokbot,lesson`, Medium) — not LPT-635/625.
- Tip-commented curriculum **LPT-87** Done; Done-ack **LPT-85**/86/574 + Suits **LPT-81**/82/353/369/370/571. Parents already HAS tip — no re-spam.
- Prefer bullet tightened (cap 40): post-split SoftPulse explain Dart check → LPT-669.
- next: **LPT-669** SoftPulse explain Dart maps OR next NEVER split children (`lesson-01-02-01-02-*` …) / Low curriculum.
- act-01-01-03-*: interactive SI clean on tip; SoftPulse explain successors via LPT-669; curriculum via LPT-87 Done.

## Fold 2026-10-14aw (01eacc7c discovery hand-ranks split children)

- Tip-stable `01eacc7c` (#2225 learnings fold on main). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open catalog parent **LPT-669** only (others Done — no checklist rebuild).
- Discovery NEVER post-split Hand-ranks children:
  - `lesson-01-02-01-01-order-hand-ranks`: one objective; `act-01-02-01-explain-ladder` SoftPulse you→sam→jo + `explainGrading` **wired** (table-tap); guided-ladder `random_in_class` high_card + pair/flush variants match Dart.
  - `lesson-01-02-01-02-pairs-straights-flushes`: one objective; scaffolded-spot one-per-press OK (pair/straight/flush) — but `act-01-02-01-02-explain-spot` SoftPulse PAIR→STRAIGHT→FLUSH **not** in Dart table-tap/visual → **LPT-669**.
  - `lesson-01-02-01-03-compare-finished-hands`: one objective; unguided-compare one-per-press OK (full_house/trips/two_pair); checkpoint hintless cue kind `none` — but `act-01-02-01-03-explain-compare` SoftPulse FULL HOUSE→TRIPS→TWO PAIR **not** in Dart → **LPT-669**.
- Tip-commented catalog **LPT-669** (still valid; 16 rows unchanged); Done-ack **LPT-90**/88/89. Do not clone curriculum/teachSpec/pressHints.
- Prefer bullet tightened (cap 40): next NEVER → `lesson-01-02-02-*` kickers children.
- next: **LPT-669** SoftPulse explain Dart maps OR next NEVER `lesson-01-02-02-01/02/03` / Low curriculum.
- act-01-02-01-*: interactive compare_rank clean on tip; SoftPulse explain successors via LPT-669; curriculum via LPT-90 Done.

## Fold 2026-10-14ax (bd4a6f0b discovery kickers split children)

- Tip-stable `bd4a6f0b` (#2226). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open catalog parent **LPT-669** only (SHA audited cleaned).
- Discovery NEVER Kickers children:
  - `lesson-01-02-02-01-best-five`: `act-01-02-02-explain-five` SoftPulse hero_pair→…→board_top_kicker + `explainGrading` **wired**; guided-seven SoftPulse five-press + densify/pulse-map; checkpoint-build one-per-press OK.
  - `lesson-01-02-02-02-kickers`: scaffolded-kicker one-per-press + densify — but `act-01-02-02-02-explain-kicker` SoftPulse SAME PAIR→KICKER **not** in Dart table-tap/visual → **LPT-669**.
  - `lesson-01-02-02-03-board-plays`: unguided-board one-per-press + densify — but `act-01-02-02-03-explain-board` SoftPulse BOARD→CHOP **not** in Dart → **LPT-669**.
- Tip-commented catalog **LPT-669** (still valid; 16 rows unchanged); Done-ack **LPT-93**/91/92 + parents/348/216/667; Meet Nit **LPT-198** re-verify still valid (do not re-add `needs-human`).
- Prefer bullet tightened (cap 40): next NEVER → `lesson-01-03-01-*` fold/check/call children.
- next: **LPT-669** SoftPulse explain Dart maps OR next NEVER `lesson-01-03-01-01/02/03` / Low curriculum.
- act-01-02-02-*: interactive SI clean on tip; SoftPulse explain successors via LPT-669; curriculum via LPT-93 Done.

## Fold 2026-10-14ay (bd4a6f0b discovery fold/check/call split children)

- Tip-stable `bd4a6f0b` (#2226). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open catalog parent **LPT-669** only.
- Discovery NEVER Fold/check/call children:
  - `lesson-01-03-01-01-fold`: `act-01-03-01-explain-passive` SoftPulse FOLD→CHECK→CALL + `explainGrading` **wired**; guided-fold trash/offsuit SoftPulse `fold-72` PRESENT.
  - `lesson-01-03-01-02-check`: scaffolded-check weak_draw one-per-press SoftPulse `check-free` PRESENT — but `act-01-03-01-02-explain-check` SoftPulse NO BET→CHECK **not** in Dart table-tap/visual → **LPT-669**.
  - `lesson-01-03-01-03-call`: unguided-call strong_draw one-per-press SoftPulse `call-5` PRESENT; checkpoint-legal hintless cue kind `none` — but `act-01-03-01-03-explain-call` SoftPulse BET→CALL **not** in Dart → **LPT-669**.
- Tip-commented catalog **LPT-669** (still valid; 16 rows unchanged); Done-ack **LPT-96**/94/95. Do not clone curriculum/teachSpec/pressHints.
- Prefer bullet tightened (cap 40): next NEVER → `lesson-01-03-02-*` bet/raise/all-in children.
- next: **LPT-669** SoftPulse explain Dart maps OR next NEVER `lesson-01-03-02-01/02/03` / Low curriculum.
- act-01-03-01-*: interactive poker_action_sizing clean on tip; SoftPulse explain successors via LPT-669; curriculum via LPT-96 Done.

## Fold 2026-10-14az (05892395 discovery bet/raise/all-in split children)

- Tip-stable `05892395` (#2228). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open catalog parent **LPT-669** only.
- Discovery NEVER Bet/raise/all-in children:
  - `lesson-01-03-02-01-bet`: `act-01-03-02-explain-aggro` SoftPulse BET→RAISE→ALL-IN + `explainGrading` **wired**; guided-bet top_pair SoftPulse `bet-half` PRESENT; checkpoint-names hintless cue kind `none`.
  - `lesson-01-03-02-02-raise`: scaffolded-raise one-per-press SoftPulse `raise-15` PRESENT — but `act-01-03-02-02-explain-raise` SoftPulse FACING BET→RAISE **not** in Dart table-tap/visual → **LPT-669**.
  - `lesson-01-03-02-03-all-in`: unguided-allin one-per-press SoftPulse `shove-12` PRESENT — but `act-01-03-02-03-explain-allin` SoftPulse STACK→ALL-IN **not** in Dart → **LPT-669**.
- Tip-commented catalog **LPT-669** (still valid; 16 rows unchanged); Done-ack **LPT-100**/98/99/591. Do not clone curriculum/teachSpec/pressHints/variants/map.
- Prefer bullet tightened (cap 40): next NEVER → `lesson-01-04-01-*` streets/order children.
- next: **LPT-669** SoftPulse explain Dart maps OR next NEVER `lesson-01-04-01-01/02/03` / Low curriculum.
- act-01-03-02-*: interactive poker_action_sizing clean on tip; SoftPulse explain successors via LPT-669; curriculum via LPT-100 Done.

## Fold 2026-10-14ba (2bcc97fe discovery streets/acting-order split children)

- Tip-stable `2bcc97fe` (#2229). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open catalog parent **LPT-669** only.
- Discovery NEVER Streets/acting-order children:
  - `lesson-01-04-01-01-four-streets`: `act-01-04-01-explain-streets` SoftPulse PREFLOP→FLOP→TURN→RIVER + `explainGrading` **wired**; guided-streets SoftPulse four presses.
  - `lesson-01-04-01-02-action-order`: scaffolded-order one-per-press 1–4; checkpoint-postflop densify PRESENT hintless — but `act-01-04-01-02-explain-order` SoftPulse BIG BLIND→CLOCKWISE→BUTTON **not** in Dart → **LPT-669**.
  - `lesson-01-04-01-03-street-ends`: unguided-end one-per-press densify PRESENT — but `act-01-04-01-03-explain-end` SoftPulse BETS MATCHED→NEXT STREET **not** in Dart → **LPT-669**.
- Tip-commented catalog **LPT-669**; Done-ack **LPT-103**/101/102 + parents/348/216/667; Meet Nit **LPT-198** re-verify still valid.
- Prefer bullet tightened (cap 40): next NEVER → `lesson-01-05-01-*` winning-pots children.
- next: **LPT-669** SoftPulse explain Dart maps OR next NEVER `lesson-01-05-01-01/02/03` / Low curriculum.
- act-01-04-01-*: interactive order_sequence/SI clean on tip; SoftPulse explain successors via LPT-669; curriculum via LPT-103 Done.

## Fold 2026-10-14bb (2905e103 discovery winning-pots split children + streets rescue)

- Tip-stable `2905e103` (#2231 after #2229). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open catalog parent **LPT-669** only.
- Rescued Streets fold from draft #2230 (Prefer/Recent/run-memory) onto this tip.
- Discovery NEVER Winning-pots children:
  - `lesson-01-05-01-01-win-by-fold`: `act-01-05-01-explain-win` SoftPulse FOLD WIN→SHOWDOWN→SIDE POT + `explainGrading` **wired**; guided-fold-win densify PRESENT.
  - `lesson-01-05-01-02-showdown`: scaffolded-showdown one-per-press densify PRESENT — but `act-01-05-01-02-explain-showdown` SoftPulse RIVER CALL→SHOWDOWN→BEST FIVE **not** in Dart → **LPT-669**.
  - `lesson-01-05-01-03-main-and-side-pots`: unguided-pot one-per-press; checkpoint-side densify PRESENT hintless — but `act-01-05-01-03-explain-pots` SoftPulse MAIN POT→SIDE POT **not** in Dart → **LPT-669**.
- Tip-commented catalog **LPT-669** (Streets successors still valid too); Done-ack **LPT-106**/104/105 + **LPT-103**/101/102 + parents/348/216/667; Meet Nit **LPT-198** re-verify still valid.
- Prefer bullet tightened (cap 40): S1 split SoftPulse explain successors exhausted on LPT-669 — next oldest unfresh / Low curriculum.
- next: **LPT-669** SoftPulse explain Dart maps OR oldest unfresh / Low curriculum.
- act-01-05-01-*: interactive SI/chip tiles clean on tip; SoftPulse explain successors via LPT-669; curriculum via LPT-106 Done.

## Fold 2026-10-14bc (77669c63 discovery position-labels split + LPT-669 S2/S3 expand)

- Tip-stable `77669c63` (#2232 learnings fold on main after #2231). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open catalog parent **LPT-669** only.
- Full SoftPulse-explain missing tap/vis re-scan: **16→32**. Rebuilt **LPT-669** body (S1 16 unchanged + S2/S3 16 new). Not a new catalog ticket.
- Discovery NEVER Position-labels children:
  - `lesson-02-01-01-01-seat-labels`: `act-02-01-01-01-explain-seats` SoftPulse EP→HJ→CO→BTN + `explainGrading` **not** in Dart → **LPT-669**; guided-btn densify PRESENT; unguided-co one-per-press densify PRESENT.
  - `lesson-02-01-01-02-blind-labels`: `act-02-01-01-02-explain-blinds` SoftPulse SB→BB **not** in Dart → **LPT-669**; scaffolded-blinds one-per-press densify PRESENT.
  - `lesson-02-01-01-03-later-seats`: reused `act-02-01-01-explain-pos` SoftPulse **wired**; checkpoint-edge densify PRESENT hintless cue kind `none`.
- Tip-commented catalog **LPT-669**; Done-ack **LPT-114**/112/113; Meet Nit **LPT-198** re-verify still valid (do not re-add `needs-human`).
- Prefer bullet tightened (cap 40): next NEVER → `lesson-02-01-02-*` acting-order children; LPT-669 checklist **32**.
- next: **LPT-669** SoftPulse explain Dart maps OR NEVER `lesson-02-01-02-01/02/03` / Low curriculum.
- act-02-01-01-*: interactive SI clean on tip; SoftPulse explain successors via LPT-669; curriculum via LPT-114 Done.

## Fold 2026-10-14bd (e9a8f54e discovery acting-order split)

- Tip-stable `e9a8f54e` (#2235 Position learnings on main). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open catalog parent **LPT-669** only (checklist still **32** — no rebuild).
- Discovery NEVER Acting-order children:
  - `lesson-02-01-02-01-preflop-order`: first-child `act-02-01-02-explain-order` SoftPulse UTG→HJ→CO→BTN **wired**; guided-pre SoftPulse CO→BTN→SB (`deal.mode` `none`).
  - `lesson-02-01-02-02-postflop-order`: `act-02-01-02-02-explain-post` SoftPulse SB→BTN + `explainGrading` **not** in Dart → **LPT-669**; scaffolded-post one-per-press OK; checkpoint-full densify PRESENT hintless cue kind `none`.
  - `lesson-02-01-02-03-wait-your-turn`: `act-02-01-02-03-explain-wait` EARLIER SEATS→YOUR TURN **not** in Dart → **LPT-669**; unguided-wait one-per-press densify PRESENT.
- Tip-commented catalog **LPT-669**; Done-ack **LPT-117**/115/116; Meet Nit **LPT-198** re-verify still valid (do not re-add `needs-human`).
- Prefer bullet tightened (cap 40): next NEVER → `lesson-02-02-01-*` hand-families children; LPT-669 checklist **32**.
- next: **LPT-669** SoftPulse explain Dart maps OR NEVER `lesson-02-02-01-01/02/03` / Low curriculum.
- act-02-01-02-*: interactive seat/wait tiles clean on tip; SoftPulse explain successors via LPT-669; curriculum via LPT-117 Done.

## Fold 2026-10-14be (e9a8f54e discovery hand-families split + acting-order rescue)

- Tip-stable `e9a8f54e` (#2235). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open catalog parent **LPT-669** only (checklist still **32** — no rebuild) + ui-agent densify-spoil **LPT-672**. Rescued Acting-order fold from draft #2236 onto this chore.
- Discovery NEVER Hand-families children:
  - `lesson-02-02-01-01-pocket-pairs`: first-child `act-02-02-01-explain-families` SoftPulse Pairs→Broadways→Suited aces→Connectors **wired**; guided-pair `random_in_class` pair/pair SoftPulse `hf-pair` densify PRESENT.
  - `lesson-02-02-01-02-broadways-suited-aces`: `act-02-02-01-02-explain-broadway` SoftPulse BROADWAY→SUITED ACE + `explainGrading` **not** in Dart → **LPT-669**; scaffolded-broadway broadway one-per-press SoftPulse `hf-broadway` densify PRESENT.
  - `lesson-02-02-01-03-connectors-vs-trash`: `act-02-02-01-03-explain-connectors` SoftPulse CONNECTORS→TRASH **not** in Dart → **LPT-669**; unguided-sc connector/suited one-per-press SoftPulse `hf-sc` densify PRESENT; checkpoint-trash trash/offsuit hintless cue kind `none` densify PRESENT.
- Tip-commented catalog **LPT-669**; Done-ack **LPT-121**/119/120/484/527; Meet Nit **LPT-198** re-verify still valid (do not re-add `needs-human`). Primary-family `random_in_class` without distractor variants matches LPT-627 — do not reopen.
- Prefer bullet tightened (cap 40): next NEVER → `lesson-02-03-01-*` open-fold children; LPT-669 checklist **32**.
- next: **LPT-669** SoftPulse explain Dart maps OR NEVER `lesson-02-03-01-01/02/03` / Low curriculum.
- act-02-02-01-*: interactive SI clean on tip; SoftPulse explain successors via LPT-669; curriculum via LPT-121 Done.


## Fold 2026-10-14bf (c83ff628 discovery open-fold split + LPT-669 S3 rebuild)

- Tip mid-run `219cf150`→`c83ff628` (#2239 S3 postflop `lessonSplitMap` batch LPT-143/146/151/154/157/160/163)→`ff81af2c` (#2240 LPT-671). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open catalog parent **LPT-669** rebuilt **32→46** on `c83ff628` (+14 S3 SoftPulse explain successors: flop-class / outs-price / flop-line / turn / river / multiway / leaks) + ui-agent densify-spoil **LPT-672**.
- Discovery NEVER Open/fold children:
  - `lesson-02-03-01-01-fold-early-trash`: first-child `act-02-03-01-explain-open` SoftPulse EARLY→BUTTON→LIVE 3x **wired** (table-tap + visual `openRange`); guided-utg `random_in_class` trash/offsuit SoftPulse `fold` PRESENT.
  - `lesson-02-03-01-02-open-strong`: `act-02-03-01-02-explain-strong` SoftPulse STRONG→LIVE SIZE + `explainGrading` **not** in Dart → **LPT-669**; scaffolded-qq pair one-per-press SoftPulse `open-qq` PRESENT; checkpoint-hj broadway/offsuit hintless cue kind `none` (`open-ato`).
  - `lesson-02-03-01-03-widen-button`: `act-02-03-01-03-explain-button` SoftPulse BUTTON→WIDER **not** in Dart → **LPT-669**; unguided-btn high_card/suited one-per-press SoftPulse `open-k9s` PRESENT.
- Densify N/A (`poker_action_sizing`). Primary-family `random_in_class` without distractor variants matches LPT-627 — do not reopen. Curriculum split **LPT-124** Done — do not clone.
- Tip-commented + rebuilt catalog **LPT-669**; Done-ack **LPT-124**/122/123/362/379/557/592 + S3 splits LPT-143/146/151/154/157/160/163 + parents/348/216; Meet Nit **LPT-198** re-verify still valid (do not re-add `needs-human`).
- Prefer bullet tightened (cap 40): next NEVER → `lesson-02-04-01-*` vs-open children; LPT-669 checklist **46**.
- next: **LPT-669** SoftPulse explain Dart maps OR NEVER `lesson-02-04-01-01/02/03` / Low curriculum.
- act-02-03-01-*: interactive poker_action_sizing clean on tip; SoftPulse explain successors via LPT-669; curriculum via LPT-124 Done.
- Open-fold / S3 SoftPulse explain: `act-02-03-01-02-explain-strong`, `act-02-03-01-03-explain-button`, `act-03-02-01-02-explain-draws`, `act-03-02-01-03-explain-air`, `act-03-03-01-02-explain-price`, `act-03-03-01-03-explain-implied`, `act-03-04-01-02-explain-cbet`, `act-03-04-01-03-explain-plan`, `act-03-05-01-02-explain-barrel`, `act-03-05-01-03-explain-delay`, `act-03-06-01-02-explain-bluff`, `act-03-06-01-03-explain-catch`, `act-03-07-01-02-explain-crowd`, `act-03-07-01-03-explain-nuts`, `act-03-08-01-02-explain-price`, `act-03-08-01-03-explain-passive` → catalog **LPT-669**.


## Fold 2026-10-15i tip 9fa61f02 (#2522 Selective Prefer → Meet-TAG working-model LPT-708 Prefer)

- Tip-stable `9fa61f02` after #2522 SoftPulse residual Prefer LPT-706 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Meet-TAG working-model residual re-check `lesson-06-11-02-01/02/03` / `act-06-11-02-*`: SoftPulse TIGHT→AGGRO→MODEL + `explainGrading` + Dart `TagModelDemo.points` TIGHT/AGGRO/MODEL (captions Tight in / Aggressive after / Working model) **concept-aligned** under Introduce TAG / The TAG model (not SoftPulse residual); checkpoint SoftPulse `model` kind `none` densify PRESENT (prompt "TAG is?" / Working model vs Insult) still grades working-model-vs-insult under Introduce TAG-only → residual **LPT-708** still To Do (needs-human; Relates LPT-291 — do not re-add needs-human on curriculum); successors SoftPulse FOLDS MOST→PLANNED BARRELS / ENTRY WIDTH→DISCIPLINE content-driven (do not reopen LPT-669); guided SoftPulse `tag` densify PRESENT; scaffolded SoftPulse `diff` one-per-press densify PRESENT; unguided SoftPulse `tag2` one-per-press densify PRESENT.
- Curriculum **LPT-291** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-708/291/706/709/710/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Adjust-TAG SoftPulse residual **LPT-709** (+ cite **LPT-710**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-02-*: interactive structural clean on tip except LPT-708 working-model residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` player-type tiles — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15y tip 12d97b23 (#2541 Capstone Prefer → LPT-676 SoftPulse Prefer)

- Tip-stable `12d97b23` after #2541 Capstone Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-04-04-01-01/02/03` / `act-04-04-01-*`: first-child SoftPulse VALUE→PRESSURE→SIZE + `explainGrading` "Value → Pressure → Size." + Dart `LessonSizingLanguageExplainTable` **concept-aligned**; guided SoftPulse `half` PRESENT (`Ah`/`Kd`·`As`/`7c`/`2d` +2 variants); scaffolded SoftPulse `big` one-per-press (`9h`/`8h`·`Kh`/`7h`/`2c`/`3d`/`As` +2 variants) + pressHint bluff-story + Dart densify "Missed draw on a scare river — sell polar pressure into 40." / felt "Sell polar pressure" still under Nearby → residual **LPT-676** still To Do (needs-human; Relates LPT-179 — do not re-add needs-human on curriculum); unguided SoftPulse `soft` densify PRESENT (`deal.mode` `none`); successors NEARBY→STORY / TINY→VALUE content-driven (do not reopen LPT-669); checkpoint SoftPulse `bad-1` kind `none` hintless under Avoid-tiny — no companion residual.
- Curriculum **LPT-179** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-676/179/351/198/216/677; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER weigh-SPR residual **LPT-677** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-04-04-01-*: interactive structural clean on tip except LPT-676 curriculum residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.


## Fold 2026-10-14

## Fold 2026-10-14bg (d0901a24 discovery versus-open split children)

- Tip-stable `d0901a24` (#2244). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open Mediums **LPT-669** (46) + **LPT-672** In Progress; **LPT-671** Done.
- Discovery NEVER Versus-open children:
  - `lesson-02-04-01-01-fold-to-open`: `act-02-04-01-explain-vs` SoftPulse FOLD→CALL→3-BET + `explainGrading` **wired**; guided-fold SoftPulse `fold-j3`.
  - `lesson-02-04-01-02-call-in-position`: scaffolded-call one-per-press `call-87s` — but `act-02-04-01-02-explain-call` SoftPulse PLAYABLE→IN POSITION→CALL already on **LPT-669** (still ABSENT).
  - `lesson-02-04-01-03-value-3bet`: unguided-3bet one-per-press `3bet-kk`; checkpoint-aq hintless — but `act-02-04-01-03-explain-threebet` SoftPulse STRONG→3-BET already on **LPT-669** (still ABSENT).
- Tip-commented catalog **LPT-669** (no checklist rebuild); Done-ack **LPT-127**/125/126/671 + parents/348/216/667; Meet Nit **LPT-198** re-verify still valid; left **LPT-672** In Progress.
- Prefer bullet tightened (cap 40): next NEVER → `lesson-02-05-01-*` stack children.
- next: **LPT-669** SoftPulse explain Dart maps OR next NEVER `lesson-02-05-01-01/02/03` / Low curriculum.

## Fold 2026-10-14bh (2e42d603 discovery effective-stacks split children)

- Tip-stable `2e42d603` (#2245). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open Medium **LPT-669** only (checklist still **46** — no rebuild); **LPT-672** Done.
- Discovery NEVER Effective-stacks children:
  - `lesson-02-05-01-01-chips-to-bb`: `act-02-05-01-explain-bb` SoftPulse CHIPS→BB→SHORTER→DEPTH + `explainGrading` **wired** (`bbStackDepth`); guided-convert SoftPulse `bb-100` densify PRESENT; checkpoint-200 hintless densify PRESENT.
  - `lesson-02-05-01-02-shorter-stack`: scaffolded-eff one-per-press SoftPulse `eff-60` densify PRESENT — but `act-02-05-01-02-explain-eff` SoftPulse SHORTER→EFFECTIVE already on **LPT-669** (still ABSENT).
  - `lesson-02-05-01-03-stack-depth`: unguided-depth one-per-press SoftPulse `depth-50` densify PRESENT — but `act-02-05-01-03-explain-depth` SoftPulse 50BB→100BB→200BB already on **LPT-669** (still ABSENT).
- Tip-commented catalog **LPT-669** (no checklist rebuild); Done-ack **LPT-130**/128/672 + parents/348/216/667.
- Prefer bullet tightened (cap 40): next NEVER → `lesson-02-06-01-*` live-habits children.
- next: **LPT-669** SoftPulse explain Dart maps OR next NEVER `lesson-02-06-01-01/02/03` / Low curriculum.

## Fold 2026-10-14bi (a98abf0f LPT-669 S4 rebuild after #2246)

- Tip mid-run `2e42d603` → `1e75347d` (#2246 S4 `lessonSplitMap` LPT-186/189/195/198/202/205/208/212 + broader S4 splits) → `a98abf0f` (#2247).
- Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**.
- Rebuilt catalog **LPT-669** checklist *46→72* (+26 S4 successor SoftPulse explains: ranges / 3-bet-squeeze / c-bet / sizing / SPR / sticky / station / nit / maniac / confidence / exploit-checkpoint).
- Effective-stacks NEVER walk on `2e42d603` unchanged (eff/depth already listed).
- next: **LPT-669** SoftPulse explain Dart maps OR NEVER `lesson-02-06-01-*` live-habits / S4 NEVER / Low curriculum.

## Fold 2026-10-14bj (cd522c93 discovery live-habits split children — rescued)

- Tip-stable `cd522c93` (#2248). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open Medium **LPT-669** only (checklist still **72** — no rebuild).
- Discovery NEVER Live-habits children:
  - `lesson-02-06-01-01-follow-action`: `act-02-06-01-explain-habits` SoftPulse WATCH→SAY→COVER→WAIT + `explainGrading` **wired**; guided-follow SoftPulse `watch` densify PRESENT.
  - `lesson-02-06-01-02-say-your-action`: scaffolded-verbal one-per-press SoftPulse `say-raise` densify PRESENT — but `act-02-06-01-02-explain-say` SoftPulse SAY→CHIPS already on **LPT-669** (still ABSENT).
  - `lesson-02-06-01-03-protect-and-wait`: unguided-protect one-per-press SoftPulse `chip-on-cards` densify PRESENT; checkpoint-oot hintless densify PRESENT — but `act-02-06-01-03-explain-protect` SoftPulse COVER→WAIT already on **LPT-669** (still ABSENT).
- Tip-commented catalog **LPT-669** (no checklist rebuild); Done-ack **LPT-133**/131/132 + parents/348/216/667/198/672.
- Prior coverage claimed `learnings: updated` without Prefer/run-memory fold — rescued onto this chore.
- next: **LPT-669** SoftPulse explain Dart maps OR NEVER `lesson-03-01-01-*` table-read / Low curriculum.

## Fold 2026-10-14bk (cd522c93 discovery table-read split children)

- Tip-stable `cd522c93` (#2248). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open Medium **LPT-669** only (checklist still **72** — no rebuild).
- Discovery NEVER Table-read children:
  - `lesson-03-01-01-01-pot-and-stacks`: `act-03-01-01-explain` SoftPulse POT→STACKS→BUTTON→WHO ACTS + `explainGrading` **wired**; guided SoftPulse `pot-21` densify PRESENT; checkpoint SoftPulse `eff-55` hintless densify PRESENT.
  - `lesson-03-01-01-02-button-and-action`: scaffolded SoftPulse `utg-first` one-per-press densify PRESENT — but `act-03-01-01-02-explain-seat` SoftPulse BUTTON→WHO ACTS already on **LPT-669** (still ABSENT).
  - `lesson-03-01-01-03-verbal-binds`: unguided SoftPulse `bound` one-per-press densify PRESENT — but `act-03-01-01-03-explain-verbal` SoftPulse SAY→BINDING already on **LPT-669** (still ABSENT).
- Tip-commented catalog **LPT-669** (no checklist rebuild); Done-ack **LPT-478**/575 (NEED tip SHA); LPT-140/138/139 already HAS.
- Prefer bullet tightened (cap 40): next NEVER → `lesson-03-02-01-*` flop-class children.
- next: **LPT-669** SoftPulse explain Dart maps OR NEVER `lesson-03-02-01-01/02/03` / Low curriculum.


## Fold 2026-10-14bl (cd522c93 discovery flop-class split children)

- Tip-stable `cd522c93` (#2248). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open Medium **LPT-669** only (checklist still **72** — no rebuild).
- Discovery NEVER Flop-class children:
  - `lesson-03-02-01-01-made-hands`: `act-03-02-01-explain` SoftPulse MADE→DRAW→SDV→AIR + `explainGrading` **wired**; guided SoftPulse `made-tp` densify PRESENT (`Kh/Qh`·`Ks9d2c` + variants).
  - `lesson-03-02-01-02-draws-vs-showdown`: scaffolded SoftPulse `nfd` one-per-press densify PRESENT; checkpoint SoftPulse `oesd` hintless densify PRESENT — but `act-03-02-01-02-explain-draws` SoftPulse DRAW→SHOWDOWN VALUE already on **LPT-669** (still ABSENT).
  - `lesson-03-02-01-03-air`: unguided SoftPulse `air` one-per-press densify PRESENT (Air feedback five-high / no Gutshot-ish) — but `act-03-02-01-03-explain-air` SoftPulse AIR→FOLD EQUITY already on **LPT-669** (still ABSENT).
- Tip-commented catalog **LPT-669** (no checklist rebuild); Done-ack **LPT-479**/577/414/384/143.
- Prefer bullet tightened (cap 40): next NEVER → `lesson-03-03-01-*` outs-price children.
- next: **LPT-669** SoftPulse explain Dart maps OR NEVER `lesson-03-03-01-01/02/03` / Low curriculum.

## Fold 2026-10-14bm (4f56674b discovery river-decisions split — rescued)

- Tip mid-run `4f56674b` (#2256 LPT-669 Done) → `50b54367` (#2257 S5 `lessonSplitMap` LPT-224/227/230/233/236/239/244/247/250). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open Medium catalog parent **none**.
- Discovery NEVER River children (`lesson-03-06-01-01/02/03`): SoftPulse explain successors content-driven SoftPulse walks via authored `soft_pulse` cues (LPT-669 Done — do not reopen); interactive `poker_action_sizing` one-per-press OK; checkpoint densify PRESENT; curriculum **LPT-157** Done — do not clone teachSpec/pressHints/variants/Nice! (LPT-155/156/581/625/627/628/635).
- Prior coverage claimed `learnings: pending` without Prefer/run-memory fold — rescued onto this chore.
- next: NEVER `lesson-03-07-01-*` multiway / Low curriculum.

## Fold 2026-10-14bn (4f56674b→50b54367 discovery multiway split children)

- Tip mid-run `4f56674b` → `50b54367` (#2257). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open Medium catalog parent **none**. S5 successor SoftPulse explains (`act-05-01-01-02-explain-speculative` … `act-05-09-01-03-explain-quit`) stay content-driven under LPT-669 Done — do **not** reopen catalog.
- Discovery NEVER Multiway children (audited on `4f56674b`; structural unchanged on `50b54367`):
  - `lesson-03-07-01-01-stronger-value`: first-child `act-03-07-01-explain` SoftPulse STRONGER→FEWER→NUTS + `explainGrading` **content-driven**; guided SoftPulse `check-2p` PRESENT (`7h/9d`·`Kc7s2d` +2 variants matching Dart).
  - `lesson-03-07-01-02-bluff-less`: `act-03-07-01-02-explain-crowd` SoftPulse CROWD→FEWER BLUFFS content-driven; scaffolded SoftPulse `mw-check` one-per-press PRESENT (`7s3d`·`AhKh9h` +2 variants).
  - `lesson-03-07-01-03-nut-potential`: `act-03-07-01-03-explain-nuts` SoftPulse NUTS→POSITION content-driven; unguided SoftPulse `sc` one-per-press densify PRESENT (`deal.mode` `none`); checkpoint SoftPulse `obs-many` hintless cue kind `none` densify PRESENT.
- Tip-commented curriculum **LPT-160** + Done-ack LPT-158/159/418/552/667/348/669 (on `4f56674b`).
- Prefer bullet tightened: LPT-669 Done content-driven; next NEVER → `lesson-03-08-01-*` leak-repair children.
- next: NEVER `lesson-03-08-01-01/02/03` / Low curriculum.
- act-03-07-01-*: interactive structural clean on tip; SoftPulse explain successors via LPT-669 content-driven; curriculum via LPT-160 Done.

## Fold 2026-10-14bo (39155796/a08d105d discovery leak-repair split — rescued)

- Tips `39155796` (#2259) → `a08d105d` (#2260 S6). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open Medium catalog parent **none**. LPT-669 Done content-driven.
- Discovery NEVER Leak-repair children (`lesson-03-08-01-01/02/03`): first-child `act-03-08-01-explain` SoftPulse TOP PAIR→PRICES→PASSIVE→CROWDS content-driven; successors `act-03-08-01-02-explain-price` BAD PRICE→FOLD + `act-03-08-01-03-explain-passive` PASSIVE→CROWD content-driven SoftPulse walks — do **not** reopen LPT-669; interactive fixed+variants SoftPulse PRESENT one-per-press OK; checkpoint densify PRESENT; curriculum **LPT-163** Done — do not clone.
- Coverage had claimed `learnings: updated`/`pending` without Prefer/run-memory fold — rescued onto 2026-10-14bq chore.
- next: NEVER `lesson-04-01-01-*` ranges / Low curriculum.

## Fold 2026-10-14bp (8cb997f9 discovery ranges split — rescued)

- Tip-stable `8cb997f9` (#2262). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open Medium catalog parent **none**.
- Discovery NEVER Ranges children (`lesson-04-01-01-01/02/03`): first-child `act-04-01-01-explain` SoftPulse ONE HAND→RANGE→UPDATE content-driven; successors `act-04-01-01-02-explain-move` RAISE→NARROWER→CALL + `act-04-01-01-03-explain-exact` ONE HAND→RANGE content-driven SoftPulse walks — do **not** reopen LPT-669; interactive SI densify structural clean; curriculum **LPT-169** Done — do not clone.
- Coverage had claimed `learnings: updated` without Prefer/run-memory fold — rescued onto 2026-10-14bq chore.
- next: NEVER `lesson-04-02-01-*` 3-bet-squeeze / Low curriculum.

## Fold 2026-10-14bs (63ae3ddc discovery sizing split children)

- Tip-stable `63ae3ddc` (#2266 continuation learnings; tip after #2265). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232** flat; densify-tap still **0** — no LPT-628 reopen.
- Discovery NEVER Sizing children:
  - `lesson-04-04-01-01-value-vs-pressure`: first-child `act-04-04-01-explain` SoftPulse VALUE→PRESSURE→SIZE content-driven + `explainGrading`; guided SoftPulse `half` PRESENT (`Ah/Kd`·`As7c2d` +2 variants).
  - `lesson-04-04-01-02-nearby-sizes`: `act-04-04-01-02-explain-nearby` SoftPulse NEARBY→STORY content-driven; scaffolded SoftPulse `big` one-per-press PRESENT (`9h/8h`·`Kh7h2c3dAs` +2 variants) — **polar pressure content** under Nearby objective → **LPT-676**; unguided SoftPulse `soft` densify PRESENT (`deal.mode` `none`).
  - `lesson-04-04-01-03-no-tiny-sizes`: `act-04-04-01-03-explain-tiny` SoftPulse TINY→VALUE content-driven; checkpoint SoftPulse `bad-1` hintless cue kind `none` (`Ah/Ad`·`Kc9s3h` +2 variants).
- Do **not** reopen LPT-669. Curriculum **LPT-179** Done — do not clone; residual honesty on **LPT-676** (needs-human).
- Tip-commented LPT-179/676 + Done-ack LPT-177/178/398/410/504/522/569/625/627/628/635/667/669.
- Prefer bullet tightened: next NEVER → `lesson-04-05-01-*` SPR children.
- next: NEVER `lesson-04-05-01-01/02/03` / S5–S6 NEVER / Low curriculum.
- act-04-04-01-*: interactive structural clean on tip except curriculum residual LPT-676; SoftPulse explain successors via LPT-669 content-driven.

## Fold 2026-10-14br (3b13dcb5 discovery continuation split children)

- Tip mid-run `63e19df3`→`3b13dcb5` (#2265 S6 player-type splits after #2264 3-bet-squeeze learnings). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232** flat; densify-tap still **0** — no LPT-628 reopen from S6 split mint.
- Discovery NEVER continuation children:
  - `lesson-04-03-01-01-multi-street-plan`: first-child `act-04-03-01-explain` SoftPulse FLOP→TURN→RIVER content-driven + `explainGrading`; guided SoftPulse `flop-bet`/`turn-bet` PRESENT (`Ah/Kd`·`As7c2d3h` +2 variants); checkpoint SoftPulse `branches` hintless densify PRESENT.
  - `lesson-04-03-01-02-abort-plan`: `act-04-03-01-02-explain-abort` SoftPulse BOARD CHANGES→STOP content-driven; scaffolded SoftPulse `abort` one-per-press PRESENT (`Qd/9c`·`Kh7h2h3h` +2 variants).
  - `lesson-04-03-01-03-pot-size-control`: `act-04-03-01-03-explain-pot` SoftPulse MEDIUM→SMALL POT content-driven; unguided SoftPulse `small-pot` one-per-press PRESENT (`Jh/Td`·`Qc9s3h` +2 variants).
- Tip-commented curriculum **LPT-176** + Done-ack LPT-174/175/496/570/602/669/625/627/628/635/667.
- Prefer bullet tightened: next NEVER → `lesson-04-04-01-*` sizing children.
- next: NEVER `lesson-04-04-01-01/02/03` / Low curriculum.
- act-04-03-01-*: interactive structural clean on tip; SoftPulse explain successors via LPT-669 content-driven; curriculum via LPT-176 Done.

## Fold 2026-10-14bq (8cb997f9 discovery 3-bet-squeeze split children)

- Tip-stable `8cb997f9` (#2262). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; open Medium catalog parent **none**.
- Discovery NEVER 3-bet-squeeze children:
  - `lesson-04-02-01-01-value-3bet`: first-child `act-04-02-01-explain` SoftPulse 3-BET→RANGES→SQUEEZE **wired** (`threeBetSqueeze`); guided SoftPulse `3bet-qq` PRESENT (`Qh/Qd` +2 suit variants matching Dart).
  - `lesson-04-02-01-02-facing-3bet`: `act-04-02-01-02-explain-facing` SoftPulse 3-BET→FOLD→CONTINUE content-driven; scaffolded SoftPulse `fold-72` one-per-press PRESENT (`7h/2d` +2 variants).
  - `lesson-04-02-01-03-squeeze`: `act-04-02-01-03-explain-squeeze` SoftPulse OPEN→CALLERS→SQUEEZE content-driven; unguided SoftPulse `squeeze` one-per-press PRESENT (`Ah/Kd` +2 variants); checkpoint SoftPulse `size-18` hintless cue kind `none` (`Kh/Kd` +2 variants).
- Tip-commented curriculum **LPT-172** + Done-ack LPT-170/171/434/572/601/625/627/628/635.
- Prefer bullet tightened: next NEVER → `lesson-04-03-01-*` continuation children.
- Rescued unfolder leak-repair + ranges Prefer/run-memory folds from prior coverage over-claim.
- next: NEVER `lesson-04-03-01-01/02/03` / Low curriculum.
- act-04-02-01-*: interactive structural clean on tip; SoftPulse explain successors via LPT-669 content-driven; curriculum via LPT-172 Done.

## Fold 2026-10-14bt (0b9f93f7 discovery SPR split children)

- Tip-stable `0b9f93f7` (#2267 sizing learnings). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232** flat; densify-tap still **0** — no LPT-628 reopen. Open Medium catalog parent **none**.
- Discovery NEVER SPR children:
  - `lesson-04-05-01-01-estimate-spr`: first-child `act-04-05-01-explain` SoftPulse SPR→LOW→HIGH **wired** (`sprDepth`) + `explainGrading`; guided SoftPulse `spr-4` densify PRESENT (`deal.mode` `none` — chip÷pot math, no handFamily); checkpoint SoftPulse `before` hintless cue kind `none` densify PRESENT (`Ah/Kd`·`Qs/7c/2d/9h` +2 variants; Scene board matches ActionSpot) — **weigh-SPR habit under Estimate objective** → **LPT-677**.
  - `lesson-04-05-01-02-commit-low-spr`: `act-04-05-01-02-explain-low` SoftPulse LOW SPR→COMMIT content-driven; scaffolded SoftPulse `commit` one-per-press PRESENT (`Kh/Kd`·`Kc/7s/2d` +2 variants; Stacks left 60 / SPR ~1).
  - `lesson-04-05-01-03-flexible-high-spr`: `act-04-05-01-03-explain-high` SoftPulse HIGH SPR→FLEXIBLE content-driven; unguided SoftPulse `flexible` one-per-press PRESENT (`Jh/9d`·`Qc/9s/3h` +2 variants; Stacks left 240 / SPR 20).
- Do **not** reopen LPT-669. Curriculum **LPT-182** Done — do not clone; residual honesty on **LPT-677** (needs-human).
- Tip-commented LPT-182/677 + Done-ack LPT-180/181/535/620/568/625/627/628/635/667/669.
- Prefer bullet tightened: next NEVER → `lesson-05-01-01-*` multiway ranges children.
- next: NEVER `lesson-05-01-01-01/02/03` / S5–S6 NEVER / Low curriculum.
- act-04-05-01-*: interactive structural clean on tip except curriculum residual LPT-677; SoftPulse explain successors via LPT-669 content-driven; guided is `deal.mode` `none` outcome tiles — do not file handFamily.


## Fold 2026-10-14bu (f25ed146 discovery multiway-ranges split children)

- Tip-stable `f25ed146` (#2268 SPR learnings). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232** flat; densify-tap still **0** — no LPT-628 reopen. Open Medium catalog parent **none**.
- Discovery NEVER multiway-ranges children:
  - `lesson-05-01-01-01-nut-potential`: first-child `act-05-01-01-explain` SoftPulse NUTTED→AIR→DOMINATION content-driven + `explainGrading`; guided SoftPulse `nfd` densify PRESENT (`deal.mode` `none` — outcome tiles, no handFamily); checkpoint SoftPulse `nuts` hintless cue kind `none` densify PRESENT.
  - `lesson-05-01-01-02-tighten-speculative`: `act-05-01-01-02-explain-speculative` SoftPulse MULTIWAY→OOP→FOLD content-driven; scaffolded SoftPulse `fold-76` one-per-press PRESENT (`7h/6h` +2 suit variants matching Dart).
  - `lesson-05-01-01-03-thick-value`: `act-05-01-01-03-explain-value` SoftPulse CALLERS→SET→BET content-driven; unguided SoftPulse `bet-set` one-per-press PRESENT (`9h/9d`·`9s/8c/7h` +2 variants).
- Do **not** reopen LPT-669. Curriculum **LPT-224** Done — do not clone; no residual (checkpoint nuts-priority matches Prefer nut potential).
- Tip-commented LPT-224 + Done-ack LPT-222/223/456/595/600/593/513/625/627/628/635/667/669.
- Prefer bullet tightened: next NEVER → `lesson-05-02-01-*` deep-stack children.
- next: NEVER `lesson-05-02-01-01/02/03` / S5–S6 NEVER / Low curriculum.
- act-05-01-01-*: interactive structural clean on tip; SoftPulse explain successors via LPT-669 content-driven; guided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14bv (5a721bbf deep-stack NEVER)

- Tip-stable `5a721bbf` (#2269). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER deep-stack children (`lesson-05-02-01-01/02/03`): SoftPulse explain successors content-driven (do not reopen LPT-669); guided SoftPulse `impl` densify PRESENT; scaffolded `Ad/9c`·`As/Th/7h` SoftPulse `fold-tp` one-per-press OK; unguided SoftPulse `plan` densify PRESENT; checkpoint SoftPulse `pos` hintless densify PRESENT.
- Curriculum **LPT-227** Done — do not clone; residual rewards-synthesis under Plan-high-SPR filed **LPT-680** (needs-human).
- Tip-commented LPT-227/680 + Done-ack LPT-225/226/457/514/404/417 + catalog LPT-624/625/627/628/635/667/669.
- Prefer bullet tightened: next NEVER → `lesson-05-03-01-*` implied-odds children.
- next: NEVER `lesson-05-03-01-01/02/03` / S5–S6 NEVER / Low curriculum.
- act-05-02-01-*: interactive structural clean on tip; SoftPulse explain successors via LPT-669 content-driven; guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14bw (a8361500 implied-odds NEVER)

- Tip-stable `a8361500` (#2270). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER implied-odds children (`lesson-05-03-01-01/02/03`):
  - `lesson-05-03-01-01-estimate-implied`: `act-05-03-01-explain` SoftPulse IMPLIED→REVERSE→SECOND + Dart `impliedOdds` still pre-split under Estimate; guided SoftPulse `call-io` PRESENT (`Jh/9d`·`8s/7c/2d` +2 suit variants; stackLabel 400); checkpoint SoftPulse `depth-pay` hintless densify PRESENT — checkpoint OK.
  - `lesson-05-03-01-02-reverse-implied`: `act-05-03-01-02-explain-reverse` SoftPulse REVERSE→DOMINATED→FOLD content-driven; scaffolded SoftPulse `rio` one-per-press PRESENT (`Kh/Jd`·`As/Th/8h` +2 variants).
  - `lesson-05-03-01-03-skip-dominated-draws`: `act-05-03-01-03-explain-draws` SoftPulse NON-NUT→MULTIWAY→SKIP content-driven; unguided SoftPulse `nonut` one-per-press PRESENT (`7h/6h`·`Kh/9h/2c` +2 variants).
- Do **not** reopen LPT-669. Curriculum **LPT-230** Done — do not clone; residual Estimate SoftPulse REVERSE/SECOND filed **LPT-681** (needs-human).
- Tip-commented LPT-230 + Done-ack LPT-228/229/393/458/515/605/606/607.
- Prefer bullet tightened: next NEVER → `lesson-05-04-01-*` thin-value children.
- next: NEVER `lesson-05-04-01-01/02/03` / S5–S6 NEVER / Low curriculum.
- act-05-03-01-*: interactive structural clean on tip; SoftPulse explain successors via LPT-669 content-driven; checkpoint is `deal.mode` `none` rise tiles — do not file handFamily.


## Fold 2026-10-14bx (ea625203 thin-value NEVER)

- Tip-stable `ea625203` (#2271). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER thin-value children (`lesson-05-04-01-01/02/03`):
  - `lesson-05-04-01-01-thin-value`: `act-05-04-01-explain` SoftPulse THIN→CATCH→BARRELS + Dart `ThinValueDemo` still pre-split under thin-value-only → **LPT-682**; guided SoftPulse `tv` PRESENT (`Jh/9d`·`Kc/9s/4h/2d/7c` +2 suit variants); checkpoint SoftPulse `read` meta-read densify PRESENT under Thin → **LPT-683**.
  - `lesson-05-04-01-02-wider-catches`: `act-05-04-01-02-explain-catch` SoftPulse MANIAC→BARREL→CALL content-driven; scaffolded SoftPulse `call-m` one-per-press PRESENT (same hero/board +2 variants).
  - `lesson-05-04-01-03-skip-thin-overfolders`: `act-05-04-01-03-explain-overfold` SoftPulse NIT→FOLDS→CHECK content-driven; unguided SoftPulse `check-nit` one-per-press PRESENT.
- Do **not** reopen LPT-669. Curriculum **LPT-233** Done — do not clone; residuals SoftPulse + checkpoint filed **LPT-682**/**LPT-683** (needs-human).
- Tip-commented LPT-233/682/683 + Done-ack LPT-231/232/459/516/608/609/614 + Meet Nit LPT-198 / LPT-216 + open residuals LPT-676/677/680/681.
- Prefer bullet tightened: next NEVER → `lesson-05-05-01-*` lines-and-probes children.
- next: NEVER `lesson-05-05-01-*` / S5–S6 NEVER / Low curriculum.
- act-05-04-01-*: interactive structural clean on tip; SoftPulse explain successors via LPT-669 content-driven; poker_action_sizing densify N/A; checkpoint is `deal.mode` `none` read tiles — do not file handFamily.

## Fold 2026-10-14by (1babb319 lines-and-probes NEVER)

- Tip-stable `1babb319` (#2272). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER lines-and-probes children (`lesson-05-05-01-01/02/03`):
  - `lesson-05-05-01-01-read-check-raises`: `act-05-05-01-explain` SoftPulse X/R→PROBE→DELAY→DONK + Dart `LineStoriesDemo` still pre-split under check-raises-only → **LPT-684**; guided SoftPulse `strong` densify PRESENT (`linesNitXrOutcomes`).
  - `lesson-05-05-01-02-probes-and-delays`: `act-05-05-01-02-explain-probe` SoftPulse PROBE→DELAY→PLAN content-driven; scaffolded SoftPulse `probe` one-per-press PRESENT (`9h/8d`·`Kc/9s/3h` +2 suit variants); checkpoint SoftPulse `delay` kind `none` densify PRESENT (approved probes+delays grouping).
  - `lesson-05-05-01-03-donk-bets`: `act-05-05-01-03-explain-donk` SoftPulse DONK→STRONG→AIR content-driven; unguided SoftPulse `polar` one-per-press densify PRESENT.
- Do **not** reopen LPT-669. Curriculum **LPT-236** Done — do not clone; residual SoftPulse filed **LPT-684** (needs-human).
- Tip-commented LPT-236/684 + Done-ack LPT-234/235/460/517/610/624/625/627/628/635/667/669 + open residuals LPT-676/677/680/681/682/683.
- Prefer bullet tightened: next NEVER → `lesson-05-06-01-*` line-reading children.
- next: NEVER `lesson-05-06-01-*` / S5–S6 NEVER / Low curriculum.
- act-05-05-01-*: interactive structural clean on tip; SoftPulse explain successors via LPT-669 content-driven; checkpoint delay under probes-and-delays matches approved grouping — do not file handFamily.

## Fold 2026-10-14bz (29559dd8 line-reading NEVER)

- Tip-stable `29559dd8` (#2274). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER line-reading children (`lesson-05-06-01-01/02/03`):
  - `lesson-05-06-01-01-update-each-street`: `act-05-06-01-explain` SoftPulse ACTION→REWRITE→UPDATE + Dart `RangeRewriteDemo` matches update-each-street — **no residual**; unguided SoftPulse `update` densify PRESENT (`lineReadRebuildOutcomes`).
  - `lesson-05-06-01-02-capped-lines`: `act-05-06-01-02-explain-capped` SoftPulse CHECK→CAPPED→UNCAPPED content-driven; guided SoftPulse `capped` densify PRESENT; checkpoint SoftPulse `uncap` kind `none` densify PRESENT (approved capped+uncapped grouping).
  - `lesson-05-06-01-03-drop-stale-stories`: `act-05-06-01-03-explain-stale` SoftPulse FLOP→TURN→RE-PRICE content-driven; scaffolded SoftPulse `repr` one-per-press PRESENT (`7h/6h`·`Kh/9h/2c/3d` +2 suit variants matching Dart).
- Do **not** reopen LPT-669. Curriculum **LPT-239** Done — do not clone; structural clean (no new residual).
- Tip-commented LPT-239 + Done-ack LPT-237/238/461/518/624/625/627/628/635/667/669 + open residuals LPT-676/677/680/681/682/683/684.
- Prefer bullet tightened: next NEVER → `lesson-05-07-01-*` timing-sizing children.
- next: NEVER `lesson-05-07-01-*` / S5–S6 NEVER / Low curriculum.
- act-05-06-01-*: interactive structural clean on tip; SoftPulse explain successors via LPT-669 content-driven; guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14cb (e36af944 table-dynamics NEVER)

- Tip-stable `e36af944` (#2276). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER table-dynamics children post LPT-247: first-child SoftPulse STUCK→TILTED→GEARS residual **LPT-686**; fresh-samples checkpoint under gear-changes residual **LPT-687**; successors content-driven; densify/pressHints/SoftPulse-map structural clean.
- next: NEVER `lesson-05-09-01-*` session-discipline / S5–S6 NEVER / Low curriculum.

## Fold 2026-10-14cc (3ce8732e session-discipline NEVER)

- Tip-stable `3ce8732e` (#2277). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER session-discipline children (`lesson-05-09-01-01/02/03`):
  - `lesson-05-09-01-01-stop-loss`: `act-05-09-01-explain` SoftPulse QUIT→GUARD→FIRST + Dart `GuardrailsDemo` still pre-split ladder under stop-loss-only → **LPT-690**; guided SoftPulse `stop` densify PRESENT.
  - `lesson-05-09-01-02-bankroll-stakes`: `act-05-09-01-02-explain-bankroll` SoftPulse BANKROLL→STAKES→DECLINE content-driven; scaffolded SoftPulse `decline` one-per-press PRESENT.
  - `lesson-05-09-01-03-end-sessions`: `act-05-09-01-03-explain-quit` SoftPulse TIRED→WILD→CASH OUT content-driven; unguided SoftPulse `cash` one-per-press PRESENT; checkpoint SoftPulse `edge` under end-sessions → **LPT-691**.
- Do **not** reopen LPT-669. Curriculum **LPT-250** Done — do not clone.
- Tip-commented LPT-690/691 + Done-ack LPT-248/249/250/466/521/617 + open residuals LPT-676…687 + parents.
- Prefer bullet tightened: next NEVER → `lesson-06-01-01-*` range-nut-advantage children.
- next: NEVER `lesson-06-01-01-*` / S6 NEVER / Low curriculum.
- act-05-09-01-*: interactive structural clean on tip aside from residuals; SoftPulse explain successors via LPT-669 content-driven; outcome tiles are `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-14cd (41d1f091 range-nut NEVER)

- Tip-stable `41d1f091` (#2279). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER range-nut children (`lesson-06-01-01-01/02/03`):
  - `lesson-06-01-01-01-range-advantage`: `act-06-01-01-explain` SoftPulse RANGE→NUT→ADVANTAGE + Dart `RangeAdvantageDemo` still pre-split ladder under range-advantage-only → **LPT-692**; guided SoftPulse `pfr` densify PRESENT.
  - `lesson-06-01-01-02-nut-advantage`: `act-06-01-01-02-explain-nuts` SoftPulse NUTS→PAIRED→CALLER content-driven; scaffolded SoftPulse `caller-nuts` one-per-press PRESENT.
  - `lesson-06-01-01-03-press-both`: `act-06-01-01-03-explain-press` SoftPulse RANGE→NUTS→BET content-driven; unguided SoftPulse `cbet` map PRESENT (AhKd/Kc7s2d + variants); checkpoint SoftPulse `press` matches press-both — no companion residual.
- Do **not** reopen LPT-669. Curriculum **LPT-254** Done — do not clone.
- Tip-commented LPT-254/692 + Done-ack LPT-252/253 + Meet Nit LPT-198 / LPT-216 + open residuals LPT-676…691 + parents.
- Prefer bullet tightened: next NEVER → `lesson-06-02-01-*` equity-realization children.
- next: NEVER `lesson-06-02-01-*` / S6 NEVER / Low curriculum.
- act-06-01-01-*: interactive structural clean on tip aside from LPT-692; SoftPulse explain successors via LPT-669 content-driven; guided/scaffolded/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14ce (7d928fa9 equity-realization NEVER)

- Tip-stable `7d928fa9` (#2280). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER equity-realization children (`lesson-06-02-01-01/02/03`):
  - `lesson-06-02-01-01-prefer-ip`: `act-06-02-01-explain` SoftPulse EQUITY→CASH→POS + Dart `EquityRealizeDemo` POS-led Prefer-IP framing OK; guided SoftPulse `ip` densify PRESENT; checkpoint SoftPulse `pos` grades Position + initiative under Prefer-IP-only → **LPT-693**.
  - `lesson-06-02-01-02-discount-oop`: `act-06-02-01-02-explain-oop` SoftPulse OOP→BARRELS→DISCOUNT content-driven; scaffolded SoftPulse `discount` one-per-press PRESENT.
  - `lesson-06-02-01-03-aggression-realizes`: `act-06-02-01-03-explain-aggro` SoftPulse SEMI-BLUFF→FOLDS→OUTS content-driven; unguided SoftPulse `realize` one-per-press PRESENT.
- Do **not** reopen LPT-669. Curriculum **LPT-257** Done — do not clone.
- Tip-commented LPT-257/693 + Done-ack LPT-255/256/469/524 + open residuals LPT-676…692 + parents + LPT-192.
- Prefer bullet tightened: next NEVER → `lesson-06-03-01-*` capped-uncapped children.
- next: NEVER `lesson-06-03-01-*` / S6 NEVER / Low curriculum.
- act-06-02-01-*: interactive structural clean on tip aside from LPT-693; SoftPulse explain successors via LPT-669 content-driven; all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14cf (05df1191 capped-uncapped NEVER)

- Tip-stable `05df1191` (#2281). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER capped-uncapped children (`lesson-06-03-01-01/02/03`):
  - `lesson-06-03-01-01-spot-caps`: `act-06-03-01-explain` SoftPulse CAPPED→UNCAPPED→NUTS + Dart `CappedUncappedDemo` still pre-split ladder under spot-caps-only → **LPT-694** (race clone LPT-695 Done); guided SoftPulse `cap` densify PRESENT.
  - `lesson-06-03-01-02-respect-uncapped`: `act-06-03-01-02-explain-uncapped` SoftPulse RAISE→BET→RESPECT content-driven; unguided SoftPulse `uncap` one-per-press PRESENT.
  - `lesson-06-03-01-03-attack-caps`: `act-06-03-01-03-explain-attack` SoftPulse CAPPED→THIN→BLUFF content-driven; scaffolded SoftPulse `bet` one-per-press PRESENT (Jh9d/Kc9s4h2d7c + variants); checkpoint SoftPulse `attack` matches attack-caps — no companion residual.
- Do **not** reopen LPT-669. Curriculum **LPT-260** Done — do not clone.
- Tip-commented LPT-260/694 + Done-ack LPT-258/259 + Meet Nit LPT-198 / LPT-216 + open residuals LPT-676…693 + parents.
- Prefer bullet tightened: next NEVER → `lesson-06-04-01-*` polar-merged children.
- next: NEVER `lesson-06-04-01-*` / S6 NEVER / Low curriculum.
- act-06-03-01-*: interactive structural clean on tip aside from LPT-694; SoftPulse explain successors via LPT-669 content-driven; guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14cg (d7c46bd5 polar-merged NEVER)

- Tip-stable `d7c46bd5` (#2282). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER polar-merged children (`lesson-06-04-01-01/02/03`):
  - `lesson-06-04-01-01-polarized-sizing`: `act-06-04-01-explain` SoftPulse POLAR→MERGED→SIZE + Dart `PolarMergedDemo` / `LessonPolarMergedExplainTable` still pre-split ladder under polarized-sizing-only → **LPT-696**; guided SoftPulse `polar` densify PRESENT (`polarGuidedOutcomes`).
  - `lesson-06-04-01-02-merged-thin-value`: `act-06-04-01-02-explain-merged` SoftPulse MERGED→MEDIUM→VALUE content-driven; scaffolded SoftPulse `mid` one-per-press PRESENT (Jh/Td·Qc/Ts/3h/2d/7c +2 suit variants match Dart LPT-395); checkpoint SoftPulse `thin` kind `none` densify PRESENT under merged-thin-value — matches (no companion residual).
  - `lesson-06-04-01-03-matched-shapes`: `act-06-04-01-03-explain-mismatch` SoftPulse SIZE→SHAPE→MATCH content-driven; unguided SoftPulse `mismatch` densify PRESENT (`polarMismatchOutcomes`).
- Do **not** reopen LPT-669. Curriculum **LPT-264** Done — do not clone.
- Tip-commented LPT-264/696 + Done-ack LPT-262/263/395/471/637 + Meet Nit LPT-198 / LPT-216 + open residuals LPT-676…694 + parents + LPT-192.
- Prefer bullet tightened: next NEVER → `lesson-06-05-01-*` overbets-geometric children.
- next: NEVER `lesson-06-05-01-*` / S6 NEVER / Low curriculum.
- act-06-04-01-*: interactive structural clean on tip aside from LPT-696; SoftPulse explain successors via LPT-669 content-driven; guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants second-pair honesty.

## Fold 2026-10-14ch (b5ebcd9a overbets-geometric NEVER)

- Tip-stable `b5ebcd9a` (#2283). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER overbets-geometric children (`lesson-06-05-01-01/02/03`):
  - `lesson-06-05-01-01-polar-overbets`: `act-06-05-01-explain` SoftPulse OVERBET→POLAR→GEO + Dart `OverbetGeometryDemo` / `LessonOverbetGeometryExplainTable` still pre-split ladder under polar-overbets-only → **LPT-699**; guided SoftPulse `polar-ob` densify PRESENT (`overbetGuidedOutcomes`).
  - `lesson-06-05-01-02-geometric-sizes`: `act-06-05-01-02-explain-geometry` SoftPulse FLOP→TURN→RIVER content-driven; scaffolded SoftPulse `mid` one-per-press PRESENT (As/Kd·Ah/7c/2d/9s +2 suit variants match Dart); checkpoint SoftPulse `multi` kind `none` densify PRESENT under geometric-sizes — matches (no companion residual).
  - `lesson-06-05-01-03-no-random-huge`: `act-06-05-01-03-explain-random` SoftPulse HUGE→MEDIUM→AVOID content-driven; unguided SoftPulse `avoid` densify PRESENT (`overbetAvoidOutcomes`).
- Do **not** reopen LPT-669. Curriculum **LPT-267** Done — do not clone.
- Tip-commented LPT-267/699 + Done-ack LPT-265/266/472/497/638 + Meet Nit LPT-198 / LPT-216 + open residuals LPT-676…696 + parents + LPT-192.
- Prefer bullet tightened: next NEVER → `lesson-06-06-01-*` blockers children.
- next: NEVER `lesson-06-06-01-*` / S6 NEVER / Low curriculum.
- act-06-05-01-*: interactive structural clean on tip aside from LPT-699; SoftPulse explain successors via LPT-669 content-driven; guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants geometric-turn honesty.

## Fold 2026-10-14ci (1e5f1189 blockers NEVER)

- Tip-stable `1e5f1189` (#2285). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-06-06-01-*` blockers children under `unit-06-06-blockers`:
  - first-child `act-06-06-01-explain` SoftPulse BLOCK→USE→NO EV + Dart `BlockersDemo.points` / `LessonBlockersExplainTable` still pre-split under bluff-blockers-only → filed **LPT-700** (needs-human; Relates LPT-270).
  - guided SoftPulse `as` densify PRESENT (`blockersGuidedOutcomes`); Fake-+EV distractor-only OK.
  - successors `act-06-06-01-02-explain-unblock` CATCH→UNBLOCK→BLUFFS + `act-06-06-01-03-explain-ev` TWEAK→NO EV content-driven (do not reopen LPT-669).
  - scaffolded SoftPulse `unblock` + unguided SoftPulse `tweak` one-per-press PRESENT; checkpoint SoftPulse `no` kind `none` under no-fake-ev matches — no companion residual.
- Curriculum **LPT-270** Done — do not clone / do not re-add needs-human. Done-ack LPT-268/269/473/498/639.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK. Open residuals LPT-676…699 tip-commented.
- Prefer next NEVER: `lesson-06-07-01-*` min-defense / remaining S6 NEVER / Low curriculum.

## Fold 2026-10-14cj (c6b4c02e min-defense NEVER)

- Tip-stable `c6b4c02e` (#2286). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER min-defense children (`lesson-06-07-01-01/02/03`):
  - `lesson-06-07-01-01-continue-catchers`: `act-06-07-01-explain` SoftPulse DEFEND→BLUFF→ENOUGH + Dart `DefendEnoughDemo` / `LessonDefendEnoughExplainTable` still pre-split ladder under continue-catchers-only → **LPT-701**; guided SoftPulse `strong` densify PRESENT (`defendGuidedOutcomes`); checkpoint SoftPulse `punish` kind `none` densify PRESENT under continue-catchers → **LPT-702**.
  - `lesson-06-07-01-02-fold-trash`: `act-06-07-01-02-explain-trash` SoftPulse THIRD PAIR→SCARY→FOLD content-driven; scaffolded SoftPulse `fold` one-per-press PRESENT (`9h`/`7d`·`Kc`/`Qh`/`9d`/`4c`/`8s` +2 suit variants match Dart).
  - `lesson-06-07-01-03-no-fake-mdf`: `act-06-07-01-03-explain-mdf` SoftPulse MDF→INTUITION content-driven; unguided SoftPulse `int` one-per-press PRESENT (`defendIntuitionOutcomes`).
- Do **not** reopen LPT-669. Curriculum **LPT-273** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-273/701/702 + Done-ack LPT-271/272/474/499/640 + Meet Nit LPT-198 / LPT-216 + open residuals LPT-676…700 + parents + LPT-192.
- Prefer bullet tightened: next NEVER → `lesson-06-08-01-*` mixed-strategy children.
- next: NEVER `lesson-06-08-01-*` / S6 NEVER / Low curriculum.
- act-06-07-01-*: interactive structural clean on tip aside from LPT-701/702; SoftPulse explain successors via LPT-669 content-driven; guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants third-pair honesty.

## Fold 2026-10-14ck (05b93ac4 mixed-strategy NEVER)

- Tip-stable `05b93ac4` (#2287). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER mixed-strategy children (`lesson-06-08-01-01/02/03`):
  - `lesson-06-08-01-01-mix-strong`: `act-06-08-01-explain` SoftPulse MIX→PURPOSE→STRONG + Dart `MixedStrategyDemo` / `LessonMixedStrategyExplainTable` still pre-split ladder under mix-strong-only → **LPT-703**; guided SoftPulse `protect` PRESENT (`7h`/`7d`·`7c`/`Kd`/`2s` +2 suit variants match Dart).
  - `lesson-06-08-01-02-types-reduce-mixing`: `act-06-08-01-02-explain-types` SoftPulse TYPE→STATION→LESS content-driven; scaffolded SoftPulse `less` one-per-press densify PRESENT (`deal.mode` `none`).
  - `lesson-06-08-01-03-no-pure-random`: `act-06-08-01-03-explain-random` SoftPulse RANDOM→PURPOSE content-driven; unguided SoftPulse `no` one-per-press densify PRESENT; checkpoint SoftPulse `freq` kind `none` densify PRESENT under no-pure-random matches — no companion residual.
- Do **not** reopen LPT-669. Curriculum **LPT-277** Done — do not clone / do not re-add needs-human. Done-ack LPT-275/276/475/500/644.
- Tip-commented LPT-277/703 + Meet Nit LPT-198 / LPT-216 + open residuals LPT-676…702 + parents + LPT-192.
- Prefer bullet tightened: next NEVER → `lesson-06-09-01-*` threebet-fourbet children.
- next: NEVER `lesson-06-09-01-*` / S6 NEVER / Low curriculum.
- act-06-08-01-*: interactive structural clean on tip aside from LPT-703; SoftPulse explain successors via LPT-669 content-driven; scaffolded/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; guided stays fixed+variants set-of-sevens honesty.


## Fold 2026-10-14cl (803ed55f discovery threebet-fourbet NEVER)

- Tip-stable `803ed55f` (#2288). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER threebet-fourbet children (`lesson-06-09-01-01/02/03`):
  - `lesson-06-09-01-01-careful-4bet-pots`: `act-06-09-01-01-explain-fourbet` SoftPulse 4BET→STRONG→CAREFUL content-driven + `explainGrading`; guided SoftPulse `careful` densify PRESENT (`deal.mode` `none`) — concept-aligned (not a residual).
  - `lesson-06-09-01-02-plan-3bet-spr`: `act-06-09-01-explain` SoftPulse 3BET→4BET→DEPTH + Dart `ThreeBetFourBetSprDemo` / `LessonThreeBetFourBetSprExplainTable` still pre-split ladder under plan-3bet-spr → **LPT-704**; scaffolded SoftPulse `small` PRESENT (`Ah`/`Qd`·`8c`/`3h`/`2s` +2 suit variants; `stackLabel` Stacks left 360 match Dart); checkpoint SoftPulse `spr` kind `none` densify PRESENT under plan-3bet-spr matches — no companion residual.
  - `lesson-06-09-01-03-no-ego-4bets`: `act-06-09-01-03-explain-ego` SoftPulse 4BET→EGO→AVOID content-driven; unguided SoftPulse `avoid` one-per-press densify PRESENT (`deal.mode` `none`).
- Do **not** reopen LPT-669. Curriculum **LPT-282** Done — do not clone / do not re-add needs-human. Done-ack LPT-280/281/476/501/645.
- Tip-commented LPT-282/704 + Meet Nit LPT-198 / LPT-216 + open residuals LPT-676…703 + parents + LPT-192.
- Prefer bullet tightened: next NEVER → `lesson-06-10-01-*` difficult-folds children.
- next: NEVER `lesson-06-10-01-*` / S6 NEVER / Low curriculum.
- act-06-09-01-*: interactive structural clean on tip aside from LPT-704; SoftPulse explain successors via LPT-669 content-driven; guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants AQo-miss honesty.

## Fold 2026-10-14cm (885b5b06 discovery difficult-folds NEVER)

- Tip-stable `885b5b06` (#2291). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**. Rescued unfolder threebet learnings from draft #2292 onto this chore branch.
- Discovery NEVER difficult-folds children (`lesson-06-10-01-01/02/03`):
  - `lesson-06-10-01-01-hard-folds`: `act-06-10-01-explain` SoftPulse HARD→COOLER→EGO + Dart `HardFoldCoolerDemo` / `LessonHardFoldCoolerExplainTable` still pre-split ladder under hard-folds-only → **LPT-705**; guided SoftPulse `fold` PRESENT (`Ah`/`9d`·`As`/`7c`/`2h`/`Kd`/`3c` +2 suit variants match Dart).
  - `lesson-06-10-01-02-cooler-or-mistake`: `act-06-10-01-02-explain-cooler` SoftPulse COOLER→MISTAKE→REVIEW content-driven; scaffolded SoftPulse `cooler` one-per-press densify PRESENT (`deal.mode` `none`); checkpoint SoftPulse `ask` kind `none` densify PRESENT under cooler-or-mistake matches — no companion residual.
  - `lesson-06-10-01-03-no-ego-calls`: `act-06-10-01-03-explain-ego` SoftPulse DUE→EGO→FOLD content-driven; unguided SoftPulse `ego` one-per-press densify PRESENT (`deal.mode` `none`).
- Do **not** reopen LPT-669. Curriculum **LPT-285** Done — do not clone / do not re-add needs-human. Done-ack LPT-283/284/477/502.
- Tip-commented LPT-285/705 + Meet Nit LPT-198 / LPT-216 + open residuals LPT-676…704 + LPT-192.
- Prefer bullet tightened: next NEVER → `lesson-06-11-01-*` observe-selective children.
- next: NEVER `lesson-06-11-01-*` / S6 NEVER / Low curriculum.
- act-06-10-01-*: interactive structural clean on tip aside from LPT-705; SoftPulse explain successors via LPT-669 content-driven; scaffolded/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; guided stays fixed+variants TPWK honesty.

## Fold 2026-10-14cn (ee4d7f8b observe-selective NEVER)

- Tip-stable `ee4d7f8b` (#2293) → learnings tip `f8c6579d` (#2294). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**; open Medium catalog parent **none**.
- Discovery NEVER observe-selective children (`lesson-06-11-01-01/02/03`); **LPT-706** filed this run (Relates LPT-288) and re-verified on tip:
  - `lesson-06-11-01-01-selective-entry`: `act-06-11-01-explain` SoftPulse TIGHT→BARREL→SAMPLE + Dart `SelectiveAggressionDemo` / `LessonSelectiveAggressionExplainTable` still pre-split ladder under selective-entry-only → **LPT-706**; guided SoftPulse `sel` densify PRESENT (`deal.mode` `none`; guideRegion `selectivePlanOk`).
  - `lesson-06-11-01-02-disciplined-aggression`: `act-06-11-01-02-explain-discipline` SoftPulse CALLED→GIVES UP content-driven; scaffolded SoftPulse `disc` one-per-press densify PRESENT (`deal.mode` `none`; guideRegion `selectiveDisciplined`).
  - `lesson-06-11-01-03-wait-for-samples`: `act-06-11-01-03-explain-wait` SoftPulse TWO HANDS→NOTE BUNDLE content-driven; unguided SoftPulse `low` one-per-press densify PRESENT (`deal.mode` `none`; guideRegion `selectiveKeepSampling`); checkpoint SoftPulse `bundle` kind `none` densify PRESENT under wait-for-samples matches — no companion residual.
- Do **not** reopen LPT-669. Curriculum **LPT-288** Done — do not clone / do not re-add needs-human. Done-ack LPT-286/287/435/494/647.
- Tip-commented LPT-288/706 + Meet Nit LPT-198 / LPT-216 + open residuals LPT-700…705.
- Prefer bullet tightened: next NEVER → `lesson-06-11-02-*` Meet TAG children.
- next: NEVER `lesson-06-11-02-*` / S6 NEVER / Low curriculum.
- act-06-11-01-*: interactive structural clean on tip aside from LPT-706; SoftPulse explain successors via LPT-669 content-driven; all interactive acts are `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14co (daf7ef0a Meet TAG NEVER)

- Tip-stable `daf7ef0a` (#2296). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-06-11-02-*` Meet TAG children under `unit-06-11-tag`:
  - first-child `act-06-11-02-explain` SoftPulse TIGHT→AGGRO→MODEL + Dart `TagModelDemo` matches Introduce TAG / The TAG model — **concept-aligned** (not SoftPulse residual; same class as careful-4bet).
  - checkpoint SoftPulse `model` kind `none` densify PRESENT grades working-model-vs-insult under Introduce TAG-only → filed **LPT-708** (needs-human; Relates LPT-291).
  - successors FOLDS MOST→PLANNED BARRELS / ENTRY WIDTH→DISCIPLINE content-driven (do not reopen LPT-669); guided/unguided/scaffolded one-per-press densify PRESENT.
- Curriculum **LPT-291** Done — do not clone / do not re-add needs-human. Done-ack LPT-289/290/436/491/648.
- Meet Nit LPT-198 / LPT-216 tip-commented on tip SHA.
- Prefer next NEVER: `lesson-06-11-03-*` adjust-tag / remaining S6 NEVER / Low curriculum.

## Fold 2026-10-14cp (76127e14 Adjust TAG NEVER)

- Tip-stable `76127e14` (#2297). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-06-11-03-*` Adjust TAG children under `unit-06-11-tag`:
  - first-child `act-06-11-03-explain` SoftPulse CREDIT→TIGHTER→NO LIGHT + Dart `VsTagsDemo` / `LessonVsTagsExplainTable` still pre-split under respect-aggression-only → **LPT-709** (needs-human; Relates LPT-294). Race clone LPT-711 Done.
  - checkpoint SoftPulse `cite` kind `none` densify PRESENT under Respect TAG aggression → **LPT-710** (needs-human; Relates LPT-294). Race clone LPT-712 Done.
  - successors CHECK-RAISE→FOLD / RARELY CALLS→CHECK content-driven (do not reopen LPT-669); sizing SoftPulse `fold-k9`/`fold`/`check` one-per-press PRESENT (deals match Dart).
- Curriculum **LPT-294** Done — do not clone / do not re-add needs-human.
- Prefer next NEVER: `lesson-06-12-01-*` observe-wide / remaining S6 NEVER / Low curriculum.

## Fold 2026-10-14cq (9886d4bb Observe wide NEVER)

- Tip-stable `9886d4bb` (#2298). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-06-12-01-*` Observe wide children under `unit-06-12-lag`:
  - first-child `act-06-12-01-explain` SoftPulse WIDE→PRESSURE→SAMPLE + Dart `WidePressureDemo` / `LessonWidePressureExplainTable` still pre-split under Note wide entry → **LPT-713** (needs-human; Relates LPT-297).
  - unguided SoftPulse `wait` Keep sampling under Note sustained pressure → **LPT-714** (needs-human; Relates LPT-297).
  - checkpoint SoftPulse `bundle` kind `none` densify PRESENT under Planned-not-maniac → **LPT-715** (needs-human; Relates LPT-297).
  - successors BARRELS→MANY HANDS / FOLDS SOMETIMES→PLAN content-driven (do not reopen LPT-669); guided SoftPulse `wide` + scaffolded SoftPulse `sep` one-per-press densify PRESENT.
- Curriculum **LPT-297** Done — do not clone / do not re-add needs-human. Done-ack LPT-295/296/438/493.
- Prefer next NEVER: `lesson-06-12-02-*` meet-lag / remaining S6 NEVER / Low curriculum.


## Fold 2026-10-14cr (126220f0 Meet LAG NEVER)

- Tip-stable `126220f0` (#2299). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-06-12-02-*` Meet LAG children under `unit-06-12-lag`:
  - first-child `act-06-12-02-explain` SoftPulse WIDE→PRESSURE→MODEL + Dart `LagModelDemo` / `LessonLagModelExplainTable` matches Introduce LAG / The LAG model — **concept-aligned** (not SoftPulse residual; same class as Meet TAG / careful-4bet).
  - checkpoint SoftPulse `limits` kind `none` densify PRESENT grades sample-limits vs destiny under Introduce LAG-only → filed **LPT-716** (needs-human; Relates LPT-300).
  - successors `act-06-12-02-02-explain-spot` (WIDE OPENS→BARRELS) + `act-06-12-02-03-explain-station` (RAISES→CALLS) content-driven (do not reopen LPT-669); guided SoftPulse `lag` + unguided SoftPulse `lag2` + scaffolded SoftPulse `diff` one-per-press densify PRESENT.
  - scaffolded pressure-vs-passive now under `lesson-06-12-02-03-lag-vs-station` — LPT-300 mismatch **resolved** by split.
- Curriculum **LPT-300** Done — do not clone / do not re-add needs-human. Done-ack LPT-298/439/492.
- Prefer next NEVER: `lesson-06-12-03-*` adjust-lag / remaining S6 NEVER / Low curriculum.

## Fold 2026-10-14cs (b77b6112 Adjust LAG NEVER)

- Tip-stable `b77b6112` (#2300). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-06-12-03-*` Adjust LAG children under `unit-06-12-lag`:
  - first-child `act-06-12-03-explain` SoftPulse CALL→TRAP→FANCY LESS + Dart `VsLagsDemo` / `LessonVsLagsExplainTable` still pre-split under Call-wider → filed **LPT-718** (needs-human; Relates LPT-303). TRAP belongs with trap-more; FANCY LESS with fewer-fancy-bluffs.
  - checkpoint SoftPulse `cite` kind `none` densify PRESENT grades Wide + pressure under Call-wider-only → filed **LPT-719** (needs-human; Relates LPT-303).
  - successors `act-06-12-03-02-explain-trap` (STRONG HAND→LET THEM BET) + `act-06-12-03-03-explain-fancy` (NO BIG BLUFF→LET THEM) content-driven (do not reopen LPT-669); guided SoftPulse `call` + scaffolded SoftPulse `trap` + unguided SoftPulse `avoid` one-per-press densify PRESENT.
- Curriculum **LPT-303** Done — do not clone / do not re-add needs-human. Done-ack LPT-301/302/441/503/651.
- Prefer next NEVER: `lesson-06-13-01-*` mix-five / remaining S6 NEVER / Low curriculum.

## Fold 2026-10-14ct (31a5783e Mix five NEVER)

- Tip-stable `31a5783e` (#2301). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-06-13-01-*` Mix five / Same cards children under `unit-06-13-mix`:
  - first-child `act-06-13-01-explain` SoftPulse CARDS→SEATS→EVIDENCE + Dart `ExploitEvidenceDemo` / `LessonExploitEvidenceExplainTable` still pre-split under Station-thin-only → filed **LPT-721** (needs-human; Relates LPT-306).
  - successors `act-06-13-01-02-explain-nit` (NIT CHECK-RAISE→FOLD) + `act-06-13-01-03-explain-lag` (LAG BARREL→CALL) + `act-06-13-01-04-explain-cite` (TENDENCY→LINE) content-driven (do not reopen LPT-669); guided SoftPulse `cs` + scaffolded SoftPulse `nit` + unguided SoftPulse `lag` one-per-press PRESENT (same-cards deals + suit variants match Dart).
  - checkpoint SoftPulse `tag` under `lesson-06-13-01-04-cite-tendency` matches cite objective — no companion residual. Maniac/baseline never-as-correct notes from LPT-306 resolved by child objectives.
- Curriculum **LPT-306** Done — do not clone / do not re-add needs-human. Done-ack LPT-304/305/442.
- Prefer next NEVER: `lesson-06-13-02-*` S6 checkpoint / remaining S6 NEVER / Low curriculum.

## Fold 2026-10-14cu (594827d8 S6 checkpoint structural)

- Tip-stable `594827d8` (#2303). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery `lesson-06-13-02-section-six-checkpoint`: all five activities scaffolded + `assessmentRole` checkpoint; teachSpec `deal.mode` `none` + cue kind `none` (`ra`/`cap`/`polar`/`tag`/`lag`); no pressHints/hints; densify PRESENT in `selectIdentifyDensifiedCoachLine` + rex. Assessment container — skip curriculum-split. Tip-commented Done LPT-307/444.
- S6 Prefer NEVER path complete (residuals open needs-human through LPT-721). Prefer next: Low curriculum **LPT-192** Adjust Station (still unsplit `lesson-04-06-03-adjust-calling-station`) / oldest unfresh / Low residuals LPT-676…721.

## Fold 2026-10-14cv (9094f561 Adjust Station discovery)

- Tip-stable `9094f561` (#2304). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery `lesson-04-06-03-adjust-calling-station`: explain SoftPulse VALUE→BLUFFS→CITE + `explainGrading`; guided/scaffolded/unguided `poker_action_sizing` fixed+suit variants match Dart SoftPulse maps PRESENT; scaffolded/unguided one-per-press OK; checkpoint `cite-fold` densify PRESENT hintless. Structural clean.
- Curriculum **LPT-192** tip-commented; removed stale `needs-human` (human-approved 2026-10-13 — do not re-add); still To Do until id migration. Done-ack LPT-190/191/399/421/565 + parents LPT-624/625/627/628/635/667/669 + LPT-189/198/216.
- Prefer next: oldest unfresh / In Progress Low curriculum **LPT-668** baseline / **LPT-330**·**333**·**336** / Low residuals LPT-676…721.

## Fold 2026-10-14cw (ccc2b878 In Progress Low curriculum re-check)

- Tip-stable `ccc2b878` (#2305). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery re-check In Progress Low curriculum (leave In Progress — tip does not satisfy id-migration AC):
  - `lesson-02-07-01-baseline-full-hand` / **LPT-668**: explain SoftPulse NINE→SAME→POSITION + `explainGrading`; guided broadway/suited SoftPulse `open-ajs`; scaffolded pair SoftPulse `call-22` one-per-press; unguided-lab SoftPulse `lab-3bet` one-per-press; checkpoint habit densify PRESENT hintless. Multi-concept open / vs-raise / habit still valid.
  - `lesson-07-07-01-same-cards-types` / **LPT-330**: explain SoftPulse CARDS→MODELS→CITE; guided/scaffolded/unguided Ah/Kd·Kc8s3h (+2d) SoftPulse `bet`/`fold`/`call` PRESENT one-per-press; checkpoint densify PRESENT. Nit/Maniac never-as-correct + multi-concept still valid.
  - `lesson-07-08-01-type-board-line` / **LPT-333**: explain SoftPulse TYPE→BOARD→LINE→SIZE; guided SoftPulse `call` now `Jh/Td`·`Kh/Ts/8h/2d` (post LPT-396 — edited stale ticket board `Ts/9h/8c/2d`); scaffolded/unguided match Dart; checkpoint densify PRESENT. Multi-concept + checkpoint meta mismatch still valid. Run-memory historical `Ts9h8c2d` guided cite is STALE — tip truth is `Kh/Ts/8h/2d`.
  - `lesson-07-09-01-leak-review-book` / **LPT-336**: explain SoftPulse LEAK→BOOK→REVIEW; SI outcome tiles densify PRESENT one-per-press; checkpoint hintless. Multi-concept + checkpoint book-purpose vs schedule still valid.
- Tip-commented LPT-668/330/333/336 + LPT-192 (still To Do, no `needs-human` re-add) + residual **LPT-676** still valid + Done parents LPT-624/625/627/628/635/667/669 + Done-ack LPT-135/136/365/383/487/328/331/332/334/335/396/452/453/189/198/216.
- Prefer next: oldest unfresh split children `lesson-01-01-02-01-suits` / `02-ranks` / `03-pairs-and-suited` (retired parent `lesson-01-01-02-suits-and-ranks` MISSING) / Low residuals LPT-676…721 / To Do **LPT-192**.

## Fold 2026-10-14cx (0f48df29 Suits/Ranks/Pairs NEVER)

- Tip-stable `0f48df29` (#2306). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-01-01-02-01/02/03` under `unit-01-01-02-suits-and-ranks`:
  - suits SoftPulse hearts→diamonds→clubs→spades + `explainGrading` concept-aligned; guided/scaffolded/checkpoint `random_in_class` four_suits; scaffolded pressHints 4/4; checkpoint hintless.
  - ranks SoftPulse DEUCE→MIDDLE→ACE concept-aligned; order_sequence SoftPulse rank-2/T/A; scaffolded pressHints 3/3; checkpoint hintless.
  - pairs-and-suited SoftPulse PAIR→SUITED concept-aligned (intentional combined third child from LPT-83); guided/unguided suited + checkpoint pair; variants PRESENT.
- Curriculum **LPT-83** Done — do not clone / do not reopen LPT-669. Done-ack LPT-81/82/353/369/370/571.
- Prefer next: NEVER `lesson-01-01-03-01/02/03` blinds / Low residuals LPT-676…721 / To Do **LPT-192**.

## Fold 2026-10-14cy (f2af0de4 Blinds NEVER)

- Tip-stable `f2af0de4` (#2308). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-01-01-03-01/02/03` under `unit-01-01-03-blinds-and-button`:
  - first-child `act-01-01-03-explain-button` SoftPulse D→SB→BB + blindsSeats role labels still pre-split under Locate-button-only → filed **LPT-724** (needs-human; Relates LPT-87).
  - successors `act-01-01-03-02-explain-blinds` (SB→BB) + `act-01-01-03-03-explain-when` (BLINDS→DEAL) content-driven; guided SoftPulse `D` + scaffolded SoftPulse `BB` + unguided SoftPulse `before-deal` + checkpoint SoftPulse `SB` kind `none` hintless PRESENT.
- Curriculum **LPT-87** Done — do not clone / do not re-add needs-human. Done-ack LPT-85/86.
- Prefer next: oldest unfresh split children / Low residuals LPT-676…724 / To Do **LPT-192**.

## Fold 2026-10-14cz (c121da25 S7 integrate + baseline NEVER)

- Tip-stable `c121da25` (#2309). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER post-split children after LPT-668/330/333/336 Done:
  - baseline `lesson-02-07-01-*`: SoftPulse NINE→SAME→POSITION under full-ring-open **concept-aligned**; successors OPEN→PLAN / COVER→WAIT content-driven; checkpoint under habits matches — no SoftPulse residual.
  - same-cards `lesson-07-07-01-*`: SoftPulse CARDS→MODELS→CITE under Station-value → filed **LPT-725** (needs-human; Relates LPT-330).
  - type-board `lesson-07-08-01-*`: SoftPulse TYPE→BOARD→LINE→SIZE under type-and-board → filed **LPT-726** (needs-human; Relates LPT-333).
  - leak-review `lesson-07-09-01-*`: SoftPulse LEAK→BOOK→REVIEW under name-leaks → filed **LPT-727** (needs-human; Relates LPT-336); prior checkpoint book-vs-schedule mismatch resolved by split home.
- Curriculum LPT-668/330/333/336 Done — do not clone / do not re-add needs-human.
- Prefer next: oldest unfresh split children / Low residuals LPT-676…727 / To Do **LPT-192**.

## Fold 2026-10-14da (0d0d6607 Hand-ranks NEVER + duplicate residual close)

- Tip-stable `0d0d6607` (#2311 after #2309). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-01-02-01-01/02/03` under Hand ranks unit:
  - first-child `act-01-02-01-explain-ladder` SoftPulse you→sam→jo + `explainGrading` "High card, then pair, then flush." **concept-aligned** under Order common hand ranks — no SoftPulse residual (contrast Blinds **LPT-724** / Same-cards **LPT-725**).
  - successors `act-01-02-01-02-explain-spot` PAIR→STRAIGHT→FLUSH + `act-01-02-01-03-explain-compare` FULL HOUSE→TRIPS→TWO PAIR content-driven (do not reopen LPT-669); guided SoftPulse PRESENT; scaffolded/unguided one-per-press OK; checkpoint cue kind `none` hintless; `random_in_class` + handFamily + variants PRESENT.
- Curriculum **LPT-90** Done — do not clone / do not re-add needs-human. Done-ack LPT-88/89.
- Concurrent SoftPulse residual race: closed Duplicate **LPT-728…730** onto **LPT-725…727** (search open residual stems before create).
- Prefer next: NEVER `lesson-01-02-02-*` kickers / Low residuals LPT-676…727 / To Do **LPT-192**.

## Fold 2026-10-14db (21026c57 Kickers NEVER)

- Tip-stable `21026c57` (#2313). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. No open `(catalog)` parents (LPT-624/625/627/628/635/667/669 Done).
- Discovery NEVER `lesson-01-02-02-01/02/03` under `unit-01-02-what-beats-what`:
  - `lesson-01-02-02-01-best-five`: `act-01-02-02-explain-five` SoftPulse hero_pair→…→board_top_kicker + `explainGrading` **wired**; guided-seven SoftPulse five-press densify PRESENT; checkpoint-build one-per-press 1–5 (Hint-enabled, no assessmentRole — LPT-643).
  - `lesson-01-02-02-02-kickers`: SoftPulse SAME PAIR→KICKER + `explainGrading` **concept-aligned**; scaffolded-kicker one-per-press + densify PRESENT + villain weaker-kicker variant.
  - `lesson-01-02-02-03-board-plays`: SoftPulse BOARD→CHOP + `explainGrading` **concept-aligned**; unguided-board one-per-press + densify PRESENT.
- Curriculum **LPT-93** Done — do not clone / do not reopen LPT-669. Tip-commented Done parents + Low residuals LPT-676…727 still valid; **LPT-192** leave In Progress (no `needs-human` re-add).
- Prefer next: NEVER `lesson-01-03-01-*` fold/check/call / Low residuals LPT-676…727 / In Progress **LPT-192**.

## Fold 2026-10-14dc (6d3b0fcc fold/check/call SoftPulse residual)

- Tip-stable `6d3b0fcc` (#2312). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-01-03-01-01/02/03` under `unit-01-03-01-fold-check-call`:
  - first-child `act-01-03-01-explain-passive` SoftPulse FOLD→CHECK→CALL + Dart `PassiveActionsDemo` + `explainGrading` "Fold → Check → Call." under Fold-only → filed **LPT-731** (needs-human; Relates LPT-96).
  - successors `act-01-03-01-02-explain-check` (NO BET→CHECK) + `act-01-03-01-03-explain-call` (BET→CALL) content-driven (do not reopen LPT-669); guided SoftPulse `fold-72` + scaffolded SoftPulse `check-free` + unguided SoftPulse `call-5` + checkpoint SoftPulse `check-illegal` kind `none` hintless PRESENT.
- Curriculum **LPT-96** Done — do not clone / do not re-add needs-human. Tip-commented LPT-96/93/731 + Meet Nit LPT-198 / LPT-216; leave In Progress **LPT-192**.
- Prefer next: NEVER `lesson-01-03-02-*` bet/raise/all-in / Low residuals LPT-676…731 / In Progress **LPT-192**.

## Fold 2026-10-14dd (0384a31f Adjust Station SoftPulse residual post LPT-192)

- Tip-stable `0384a31f` (#2316 after #2315 LPT-192 split). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-06-03-01/02/03` under Adjust Station unit:
  - first-child `act-04-06-03-explain` SoftPulse VALUE→BLUFFS→CITE + `explainGrading` "Value → Bluffs → Cite." under Value-wider-only → filed **LPT-732** (needs-human; Relates LPT-192).
  - successors `act-04-06-03-02-explain-bluffs` (RARELY FOLDS→GIVE UP) + `act-04-06-03-03-explain-cite` (EVIDENCE→UNKNOWN) content-driven; guided SoftPulse `thin-val` + scaffolded SoftPulse `give-up` + unguided SoftPulse `baseline-check` + checkpoint SoftPulse `cite-fold` kind `none` hintless PRESENT.
- Curriculum **LPT-192** Done — do not clone / do not re-add needs-human. Tip-commented LPT-192/732.
- Prefer next: NEVER `lesson-01-03-02-*` bet/raise/all-in / Low residuals LPT-676…732.

## Fold 2026-10-14de (78bd63ca bet/raise/all-in SoftPulse residual)

- Tip-stable `78bd63ca` (#2317). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-01-03-02-01/02/03` under `unit-01-03-02-bet-raise-allin`:
  - first-child `act-01-03-02-explain-aggro` SoftPulse BET→RAISE→ALL-IN + `explainGrading` "Bet → Raise → All-in." under Bet-only → filed **LPT-733** (needs-human; Relates LPT-100).
  - successors `act-01-03-02-02-explain-raise` (FACING BET→RAISE) + `act-01-03-02-03-explain-allin` (STACK→ALL-IN) content-driven; guided SoftPulse `bet-half` + scaffolded SoftPulse `raise-15` + unguided SoftPulse `shove-12` + checkpoint SoftPulse `named-bet` kind `none` hintless PRESENT.
- Curriculum **LPT-100** Done — do not clone / do not re-add needs-human. Tip-commented LPT-100/733 + Meet Nit LPT-198 / LPT-216.
- Prefer next: NEVER `lesson-01-04-01-*` streets/acting-order / Low residuals LPT-676…733.

## Fold 2026-10-14df (ff0b8002 streets checkpoint residual)

- Tip-stable `ff0b8002` (#2318). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-01-04-01-01/02/03` under `unit-01-04-streets`:
  - `act-01-04-01-explain-streets` SoftPulse PREFLOP→FLOP→TURN→RIVER + `explainGrading` **concept-aligned** under Four streets; guided-streets SoftPulse four presses.
  - successors `act-01-04-01-02-explain-order` (BIG BLIND→CLOCKWISE→BUTTON) + `act-01-04-01-03-explain-end` (BETS MATCHED→NEXT STREET) content-driven; scaffolded-order one-per-press 1–4; unguided-end SoftPulse `matched` densify PRESENT.
  - `act-01-04-01-checkpoint-postflop` SoftPulse `sb-first` kind `none` hintless densify PRESENT under Action order (preflop-only objective) → filed **LPT-737** (needs-human; Relates LPT-103).
- Curriculum **LPT-103** Done — do not clone / do not re-add needs-human. Tip-commented LPT-103/737 + Meet Nit LPT-198 / LPT-216 + LPT-733.
- Prefer next: NEVER `lesson-01-05-01-*` winning-pots / Low residuals LPT-676…737.

## Fold 2026-10-14dg (ffec8f7d winning-pots SoftPulse residual)

- Tip-stable `ffec8f7d` (#2319). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-01-05-01-01/02/03` under `unit-01-05-winning-pots`:
  - first-child `act-01-05-01-explain-win` SoftPulse FOLD WIN→SHOWDOWN→SIDE POT + `explainGrading` "Fold win → Showdown → Side pot." under Win-by-fold-only → filed **LPT-738** (needs-human; Relates LPT-106).
  - successors `act-01-05-01-02-explain-showdown` (RIVER CALL→SHOWDOWN→BEST FIVE) + `act-01-05-01-03-explain-pots` (MAIN POT→SIDE POT) content-driven; guided SoftPulse `no-show` + scaffolded SoftPulse `showdown` + unguided SoftPulse `pot-correct` + checkpoint SoftPulse `side-exists` kind `none` hintless PRESENT.
- Curriculum **LPT-106** Done — do not clone / do not re-add needs-human. Tip-commented LPT-106/738 + Meet Nit LPT-198 / LPT-216; streets residual **LPT-737** still open.
- Prefer next: NEVER `lesson-02-01-01-*` position-labels / Low residuals LPT-676…738.

## Fold 2026-10-14dh (121c5995 discovery position-labels — rescued pending)

- Tip-stable `121c5995` (#2321). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER position-labels children:
  - SoftPulse EP→HJ→CO→BTN / SB→BB **concept-aligned** under Seat / Blind labels.
  - `act-02-01-01-guided-btn` SoftPulse `pos-btn` (postflop last actor) under Seat labels → **LPT-739**.
  - Later seats SoftPulse `D` + checkpoint `prefer-btn` OK.
- Curriculum **LPT-114** Done — do not clone / do not re-add needs-human.
- Coverage left `learnings: pending` — rescued onto this chore with acting-order fold.

## Fold 2026-10-14di (b8d4de07 discovery acting-order)

- Tip-stable `b8d4de07` (#2320). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER acting-order children:
  - `lesson-02-01-02-01-preflop-order`: SoftPulse UTG→HJ→CO→BTN **concept-aligned**; guided-pre SoftPulse CO→BTN→SB (`deal.mode` `none`).
  - `lesson-02-01-02-02-postflop-order`: SoftPulse SB→BTN content-driven; scaffolded-post one-per-press OK; checkpoint-full densify PRESENT hintless cue kind `none` (BTN last matches objective).
  - `lesson-02-01-02-03-wait-your-turn`: SoftPulse EARLIER SEATS→YOUR TURN content-driven; unguided-wait one-per-press densify PRESENT.
- No SoftPulse residual; no activity↔objective residual (unlike LPT-739).
- Curriculum **LPT-117** Done — do not clone / do not re-add needs-human. Tip-commented LPT-117/739 + Meet Nit LPT-198 / LPT-216.
- Prefer next: NEVER `lesson-02-02-01-*` hand-families / Low residuals LPT-676…739.

## Fold 2026-10-14dj (77752ef0 hand-families SoftPulse residual)

- Tip-stable `77752ef0` (#2323). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-02-02-01-01/02/03` under hand-families unit:
  - first-child `act-02-02-01-explain-families` SoftPulse Pairs→Broadways→Suited aces→Connectors + `explainGrading` under Pocket-pairs-only → filed **LPT-740** (needs-human; Relates LPT-121).
  - successors `act-02-02-01-02-explain-broadway` (BROADWAY→SUITED ACE) + `act-02-02-01-03-explain-connectors` (CONNECTORS→TRASH) content-driven; guided SoftPulse `hf-pair` + scaffolded SoftPulse `hf-broadway` + unguided SoftPulse `hf-sc` + checkpoint SoftPulse `hf-trash` kind `none` hintless PRESENT.
- Curriculum **LPT-121** Done — do not clone / do not re-add needs-human. Tip-commented LPT-121/740 + Meet Nit LPT-198 / LPT-216; leave open LPT-739/738/737.
- Prefer next: NEVER `lesson-02-03-01-*` open-early / Low residuals LPT-676…740.


## Fold 2026-10-14dk (0431044f discovery open-fold SoftPulse residual)

- Tip-stable `0431044f` (#2325). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-02-03-01-01/02/03` under open-fold unit:
  - first-child `act-02-03-01-explain-open` SoftPulse EARLY→BUTTON→LIVE 3x + `explainGrading` under Fold-early-only → filed **LPT-741** (needs-human; Relates LPT-124).
  - successors `act-02-03-01-02-explain-strong` (STRONG→LIVE SIZE) + `act-02-03-01-03-explain-button` (BUTTON→WIDER) content-driven; guided SoftPulse `fold` + scaffolded SoftPulse `open-qq` + unguided SoftPulse `open-k9s` + checkpoint SoftPulse `open-ato` kind `none` hintless PRESENT.
- Curriculum **LPT-124** Done — do not clone / do not re-add needs-human. Tip-commented LPT-124/741/740 + Meet Nit LPT-198 / LPT-216.
- Prefer next: NEVER `lesson-02-04-01-*` vs-open / Low residuals LPT-676…741.

## Fold 2026-10-14dl (7e8336c1 discovery vs-open SoftPulse residual)

- Tip-stable `7e8336c1` (#2326). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-02-04-01-01/02/03` under facing-raise unit:
  - first-child `act-02-04-01-explain-vs` SoftPulse FOLD→CALL→3-BET + `explainGrading` under Fold-weak-only → filed **LPT-743** (needs-human; Relates LPT-127).
  - successors `act-02-04-01-02-explain-call` (PLAYABLE→IN POSITION→CALL) + `act-02-04-01-03-explain-threebet` (STRONG→3-BET) content-driven; guided SoftPulse `fold-j3` + scaffolded SoftPulse `call-87s` + unguided SoftPulse `3bet-kk` + checkpoint SoftPulse `3bet-aqs` kind `none` hintless PRESENT.
- Curriculum **LPT-127** Done — do not clone / do not re-add needs-human. Tip-commented LPT-127/743/741/740 + Meet Nit LPT-198 / LPT-216 + Done catalog parents (pressHints/deal-variants/explain/nice/map/densify).
- Prefer next: NEVER `lesson-02-05-01-*` stack / Low residuals LPT-676…743.

## Fold 2026-10-14dm (64b08a3b stack SoftPulse residual)

- Tip-stable `64b08a3b` (#2330). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-02-05-01-01/02/03` under effective-stacks unit:
  - first-child `act-02-05-01-explain-bb` SoftPulse CHIPS→BB→SHORTER→DEPTH + `explainGrading` under Convert-chips-only → filed **LPT-748** (needs-human; Relates LPT-130).
  - successors `act-02-05-01-02-explain-eff` (SHORTER→EFFECTIVE) + `act-02-05-01-03-explain-depth` (50BB→100BB→200BB) content-driven; guided SoftPulse `bb-100` + scaffolded SoftPulse `eff-60` + unguided SoftPulse `depth-50` + checkpoint SoftPulse `bb-200` kind `none` hintless PRESENT.
- Curriculum **LPT-130** Done — do not clone / do not re-add needs-human. Tip-commented LPT-130/748 + Meet Nit LPT-198 / LPT-216; leave open LPT-743/741/740….
- Prefer next: NEVER `lesson-02-06-01-*` live-habits / Low residuals LPT-676…748.


## Fold 2026-10-14dn (2efbb166 live-habits SoftPulse residual)

- Tip-stable `2efbb166` (#2331). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-02-06-01-01/02/03` under table-habits unit:
  - first-child `act-02-06-01-explain-habits` SoftPulse WATCH→SAY→COVER→WAIT + `explainGrading` under Follow-action-only → filed **LPT-749** (needs-human; Relates LPT-133).
  - successors `act-02-06-01-02-explain-say` (SAY→CHIPS) + `act-02-06-01-03-explain-protect` (COVER→WAIT) content-driven; guided SoftPulse `watch` + scaffolded SoftPulse `say-raise` + unguided SoftPulse `chip-on-cards` + checkpoint SoftPulse `oot-bad` kind `none` hintless densify PRESENT.
- Curriculum **LPT-133** Done — do not clone / do not re-add needs-human. Tip-commented LPT-133; leave open LPT-748/743/741/740….
- Prefer next: NEVER `lesson-02-07-01-*` baseline / Low residuals LPT-676…749.

## Fold 2026-10-14do (c32322ec discovery baseline SoftPulse concept-aligned)

- Tip-stable `c32322ec` (#2333). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-02-07-01-01/02/03` under baseline unit:
  - first-child `act-02-07-01-explain-full` SoftPulse NINE→SAME→POSITION + `explainGrading` under full-ring-open **concept-aligned** — no SoftPulse residual (do not clone LPT-749-style).
  - successors `act-02-07-01-02-explain-vsraise` (OPEN→PLAN) + `act-02-07-01-03-explain-habits` (COVER→WAIT) content-driven; guided SoftPulse `open-ajs` + scaffolded SoftPulse `call-22` one-per-press + unguided SoftPulse `lab-3bet` one-per-press + checkpoint SoftPulse `cover-wait` kind `none` densify PRESENT.
- Curriculum **LPT-668** Done — do not clone / do not re-add needs-human. Tip-commented LPT-668; leave open LPT-749/748/743/741/740….
- Prefer next: NEVER `lesson-03-01-01-*` table-read / Low residuals LPT-676…749.

## Fold 2026-10-14dp (3704a908 discovery table-read SoftPulse residual)

- Tip-stable `3704a908` (#2334). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-03-01-01-01/02/03` under table-read unit:
  - first-child `act-03-01-01-explain` SoftPulse POT→STACKS→BUTTON→WHO ACTS + `explainGrading` under Pot-and-stacks-only → filed **LPT-750** (needs-human; Relates LPT-140).
  - successors `act-03-01-01-02-explain-seat` (BUTTON→WHO ACTS) + `act-03-01-01-03-explain-verbal` (SAY→BINDING) content-driven; guided SoftPulse `pot-21` + checkpoint SoftPulse `eff-55` kind `none` PRESENT.
- Curriculum **LPT-140** Done — do not clone / do not re-add needs-human. Tip-commented LPT-140/750 + Meet Nit LPT-198 / LPT-216; leave open LPT-750/749/748/743/741/740….
- Prefer next: NEVER `lesson-03-02-01-*` flop-class / Low residuals LPT-676…750.

## Fold 2026-10-14dq (1388b4bc discovery flop-class SoftPulse residual)

- Tip-stable `1388b4bc` (#2336). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-03-02-01-01/02/03` under flop-classes unit:
  - first-child `act-03-02-01-explain` SoftPulse MADE→DRAW→SDV→AIR + `explainGrading` under Made-hands-only → filed **LPT-751** (needs-human; Relates LPT-143).
  - successors `act-03-02-01-02-explain-draws` (DRAW→SHOWDOWN VALUE) + `act-03-02-01-03-explain-air` (AIR→FOLD EQUITY) content-driven; guided SoftPulse `made-tp` + scaffolded SoftPulse `nfd` + unguided SoftPulse `air` + checkpoint SoftPulse `oesd` kind `none` PRESENT; SDV still not a recommended correct answer (LPT-143 AC residual).
- Curriculum **LPT-143** Done — do not clone / do not re-add needs-human. Tip-commented LPT-143/751 + Meet Nit LPT-198 / LPT-216; leave open LPT-751/750/749….
- Prefer next: NEVER `lesson-03-03-01-*` outs-price / Low residuals LPT-676…751.

## Fold 2026-10-14dr (a79e937f discovery outs-price SoftPulse residual)

- Tip-stable `a79e937f` (#2337). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-03-03-01-01/02/03` under outs-price unit:
  - first-child `act-03-03-01-explain` SoftPulse CLEAN→DIRTY→PRICE + `explainGrading` under Clean-outs-only → filed **LPT-752** (needs-human; Relates LPT-146).
  - successors `act-03-03-01-02-explain-price` (PRICE→POT→EQUITY) + `act-03-03-01-03-explain-implied` (DEEP→IMPLIED ODDS) content-driven; guided SoftPulse As→Ad→Ac + scaffolded SoftPulse `call-10` + unguided SoftPulse `call-draw` + checkpoint SoftPulse `implied-yes` kind `none` PRESENT.
- Curriculum **LPT-146** Done — do not clone / do not re-add needs-human. Tip-commented LPT-146/752 + Meet Nit LPT-198 / LPT-216; leave open LPT-752/751/750….
- Prefer next: NEVER `lesson-03-04-01-*` flop-decisions / Low residuals LPT-676…752.

## Fold 2026-10-14ds (2f2a4a94 discovery flop-decisions SoftPulse residual)

- Tip-stable `2f2a4a94` (#2340 after #2339). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-03-04-01-01/02/03` under flop-decisions unit:
  - first-child `act-03-04-01-explain` SoftPulse VALUE→C-BET→CHECK→CALL→FOLD→RAISE + `explainGrading` under Value-bet-only → filed **LPT-753** (needs-human; Relates LPT-151).
  - successors `act-03-04-01-02-explain-cbet` (PREFLOP RAISER→C-BET) + `act-03-04-01-03-explain-plan` (RAISE→CALL→FOLD) content-driven; guided SoftPulse `bet-tp` + scaffolded SoftPulse `cbet` + unguided SoftPulse `raise-set` + checkpoint SoftPulse `fold-bp` kind `none` PRESENT.
- Curriculum **LPT-151** Done — do not clone / do not re-add needs-human; distinct from Advanced lines **LPT-684**. Tip-commented LPT-151/753 + Meet Nit LPT-198 / LPT-216; leave open LPT-753/752/751….
- Prefer next: NEVER `lesson-03-05-01-*` turn-decisions / Low residuals LPT-676…753.

## Fold 2026-10-14dt (6c7948fd discovery turn-decisions SoftPulse residual)

- Tip-stable `6c7948fd` (#2341). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-03-05-01-01/02/03` under turn-decisions unit:
  - first-child `act-03-05-01-explain` SoftPulse BRICK→CHANGE→BARREL→DELAY + `explainGrading` under Brick-or-change-only → filed **LPT-754** (needs-human; Relates LPT-154).
  - successors `act-03-05-01-02-explain-barrel` (BRICK→BARREL) + `act-03-05-01-03-explain-delay` (CHECKED BACK→BET TURN) content-driven; guided SoftPulse `brick` + scaffolded SoftPulse `barrel` + unguided SoftPulse `delay-bet` + checkpoint SoftPulse `give-up` kind `none` densify PRESENT.
- Curriculum **LPT-154** Done — do not clone / do not re-add needs-human; distinct from Advanced lines **LPT-684**. Tip-commented LPT-154/754 + Meet Nit LPT-198 / LPT-216; leave open LPT-754/753/752….
- Prefer next: NEVER `lesson-03-06-01-*` river-decisions / Low residuals LPT-676…754.

## Fold 2026-10-14du (af941fdf discovery river-decisions SoftPulse residual)

- Tip-stable `af941fdf` (#2343). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-03-06-01-01/02/03` under river-decisions unit:
  - first-child `act-03-06-01-explain` SoftPulse VALUE→BLUFF→CATCH→FOLD + `explainGrading` under River-value-only → filed **LPT-755** (needs-human; Relates LPT-157).
  - successors `act-03-06-01-02-explain-bluff` (STORY→BLUFF) + `act-03-06-01-03-explain-catch` (BLUFF-CATCH→FOLD) content-driven; guided SoftPulse `val-bet` + scaffolded SoftPulse `bluff` + unguided SoftPulse `fold-weak` + checkpoint SoftPulse `role-catch` kind `none` PRESENT.
- Curriculum **LPT-157** Done — do not clone / do not re-add needs-human; distinct from flop **LPT-753**. Tip-commented LPT-157/755 + Meet Nit LPT-198 / LPT-216; leave open LPT-755/754/753….
- Prefer next: NEVER `lesson-03-07-01-*` multiway / Low residuals LPT-676…755.

## Fold 2026-10-14dv (240678aa discovery multiway SoftPulse residual)

- Tip-stable `240678aa` (#2344). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-03-07-01-01/02/03` under multiway unit:
  - first-child `act-03-07-01-explain` SoftPulse STRONGER→FEWER→NUTS + `explainGrading` under Stronger-value-only → filed **LPT-756** (needs-human; Relates LPT-160); also checkpoint SoftPulse `obs-many` still under Nut-potential.
  - successors `act-03-07-01-02-explain-crowd` (CROWD→FEWER BLUFFS) + `act-03-07-01-03-explain-nuts` (NUTS→POSITION) content-driven; guided SoftPulse `check-2p` + scaffolded SoftPulse `mw-check` one-per-press + unguided SoftPulse `sc` + checkpoint SoftPulse `obs-many` kind `none` densify PRESENT.
- Curriculum **LPT-160** Done — do not clone / do not re-add needs-human; distinct from river **LPT-755**. Tip-commented LPT-160/756/755 + Meet Nit LPT-198 / LPT-216; leave open LPT-756/755/754….
- Prefer next: NEVER `lesson-03-08-01-*` leak-repair / Low residuals LPT-676…756.

## Fold 2026-10-14dw (a09c96cf discovery leak-repair SoftPulse residual)

- Tip-stable `a09c96cf` (#2346). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-03-08-01-01/02/03` under leak-repair unit:
  - first-child `act-03-08-01-explain` SoftPulse TOP PAIR→PRICES→PASSIVE→CROWDS + `explainGrading` under Weak-top-pair-only → filed **LPT-757** (needs-human; Relates LPT-163); also checkpoint SoftPulse `notes` under Passive-and-crowds objective mismatch.
  - successors `act-03-08-01-02-explain-price` (BAD PRICE→FOLD) + `act-03-08-01-03-explain-passive` (PASSIVE→CROWD) content-driven; guided SoftPulse `careful` + scaffolded SoftPulse `fold-gut` one-per-press + unguided SoftPulse `fold-air` + checkpoint SoftPulse `notes` kind `none` densify PRESENT.
- Curriculum **LPT-163** Done — do not clone / do not re-add needs-human; distinct from Strategy-book **LPT-727** / multiway **LPT-756**. Race clone **LPT-758** Done Relates → LPT-757. Tip-commented LPT-163/757/756 + Meet Nit LPT-198 / LPT-216; leave open LPT-757/756/755….
- Prefer next: NEVER `lesson-04-01-01-*` ranges / Low residuals LPT-676…757.

## Fold 2026-10-14dx (fad43b6a discovery ranges SoftPulse residual)

- Tip-stable `fad43b6a` (#2347). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-01-01-01/02/03` under ranges unit:
  - first-child `act-04-01-01-explain` SoftPulse ONE HAND→RANGE→UPDATE + `explainGrading` under Seat-as-range-only → filed **LPT-759** (needs-human; Relates LPT-169).
  - successors `act-04-01-01-02-explain-move` (RAISE→NARROWER→CALL) + `act-04-01-01-03-explain-exact` (ONE HAND→RANGE) content-driven; guided SoftPulse `strong-narrow` + scaffolded SoftPulse `bb-stronger` one-per-press + unguided SoftPulse `too-exact` + checkpoint SoftPulse `read-drives` kind `none` densify PRESENT.
- Curriculum **LPT-169** Done — do not clone / do not re-add needs-human; distinct from Range-nut **LPT-692** / leak-repair **LPT-757**. Tip-commented LPT-169/759/757 + Meet Nit LPT-198 / LPT-216; leave open LPT-759/757/756….
- Prefer next: NEVER `lesson-04-02-01-*` threebet / Low residuals LPT-676…759.


## Fold 2026-10-14dy (59fe21e0 discovery threebet SoftPulse residual)

- Tip-stable `59fe21e0` (#2349). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-02-01-01/02/03` under threebet unit:
  - first-child `act-04-02-01-explain` SoftPulse 3-BET→RANGES→SQUEEZE + `explainGrading` under Value-3bet-only → filed **LPT-760** (needs-human; Relates LPT-172); also checkpoint SoftPulse `size-18` under Squeeze spots objective mismatch.
  - successors `act-04-02-01-02-explain-facing` (3-BET→FOLD→CONTINUE) + `act-04-02-01-03-explain-squeeze` (OPEN→CALLERS→SQUEEZE) content-driven; guided SoftPulse `3bet-qq` + scaffolded SoftPulse `fold-72` one-per-press + unguided SoftPulse `squeeze` + checkpoint SoftPulse `size-18` kind `none` PRESENT (densify N/A `poker_action_sizing`).
- Curriculum **LPT-172** Done — do not clone / do not re-add needs-human; distinct from Versus **LPT-743** / Ranges **LPT-759**. Tip-commented LPT-172/760/759 + Meet Nit LPT-198 / LPT-216; leave open LPT-760/759/757….
- Prefer next: NEVER `lesson-04-03-01-*` continuation / Low residuals LPT-676…760.

## Fold 2026-10-14dz (f3a92939 discovery continuation SoftPulse concept-aligned)

- Tip-stable `f3a92939`. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-03-01-01/02/03` under continuation unit:
  - first-child `act-04-03-01-explain` SoftPulse FLOP→TURN→RIVER + `explainGrading` under multi-street-plan **concept-aligned** — no SoftPulse residual (do not clone LPT-760-style).
  - successors `act-04-03-01-02-explain-abort` (BOARD CHANGES→STOP) + `act-04-03-01-03-explain-pot` (MEDIUM→SMALL POT) content-driven; guided SoftPulse flop-bet→turn-bet + scaffolded SoftPulse `abort` + unguided SoftPulse `small-pot` + checkpoint SoftPulse `branches` kind `none` PRESENT.
- Curriculum **LPT-176** Done — do not clone / do not re-add needs-human. Tip-commented LPT-176 + Meet Nit LPT-198 / LPT-216; leave open LPT-760/759/757….
- Prefer next: NEVER `lesson-04-04-01-*` sizing / Low residuals LPT-676…760.

## Fold 2026-10-14ea (a0032775 discovery sizing SoftPulse residual re-check)

- Tip-stable `a0032775` (#2352 continuation SoftPulse concept-aligned learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-04-01-01/02/03` under sizing unit:
  - first-child `act-04-04-01-explain` SoftPulse VALUE→PRESSURE→SIZE + `explainGrading` under still-merged Value objective (packs value+polar — expected; not a new SoftPulse residual).
  - successors `act-04-04-01-02-explain-nearby` (NEARBY→STORY) + `act-04-04-01-03-explain-tiny` (TINY→VALUE) content-driven; guided SoftPulse `half` fixed+2 variants (`Ah/Kd`·`As7c2d`) + scaffolded SoftPulse `big` one-per-press (`9h/8h`·`Kh7h2c3dAs` +2 variants) + unguided SoftPulse `soft` densify PRESENT (`deal.mode` `none`) + checkpoint SoftPulse `bad-1` kind `none` hintless.
  - residual polar scaffolded under Nearby stays **LPT-676** (needs-human; Relates LPT-179) — tip-commented; do not reopen Done **LPT-179**.
- Curriculum **LPT-179** Done — do not clone / do not re-add needs-human. Tip-commented LPT-676/179/760 + Meet Nit LPT-198 / LPT-216; leave open LPT-676…760.
- Prefer next: NEVER `lesson-04-05-01-*` SPR / Low residuals LPT-676…760.

## Fold 2026-10-14eb (43daea2a discovery SPR SoftPulse residual re-check)

- Tip-stable `43daea2a` (#2353 sizing SoftPulse residual learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-05-01-01/02/03` under SPR unit:
  - first-child `act-04-05-01-explain` SoftPulse SPR→LOW→HIGH + `explainGrading` under Estimate (packs depth labels — expected; not a new SoftPulse residual).
  - successors `act-04-05-01-02-explain-low` (LOW SPR→COMMIT) + `act-04-05-01-03-explain-high` (HIGH SPR→FLEXIBLE) content-driven; guided SoftPulse `spr-4` densify PRESENT (`deal.mode` `none` chip÷pot — no handFamily) + scaffolded SoftPulse `commit` one-per-press (`Kh/Kd`·`Kc/7s/2d` +2 variants) + unguided SoftPulse `flexible` one-per-press (`Jh/9d`·`Qc/9s/3h` +2 variants) + checkpoint SoftPulse `before` kind `none` hintless (`Ah/Kd`·`Qs/7c/2d/9h` +2 variants).
  - residual weigh-SPR habit checkpoint under Estimate stays **LPT-677** (needs-human; Relates LPT-182) — tip-commented; do not reopen Done **LPT-182**.
- Curriculum **LPT-182** Done — do not clone / do not re-add needs-human. Tip-commented LPT-677/182/676 + Meet Nit LPT-198 / LPT-216; leave open LPT-676…760.
- Prefer next: NEVER `lesson-04-06-01-*` observe-sticky / Low residuals LPT-676…760.
- act-04-05-01-*: interactive structural clean on tip except curriculum residual LPT-677; SoftPulse explain successors content-driven (do not reopen LPT-669); guided is `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14ec (ddb7c781 discovery observe-sticky SoftPulse residual)

- Tip-stable `ddb7c781` (#2354 SPR SoftPulse residual re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-06-01-01/02/03` under Observe sticky unit:
  - first-child `act-04-06-01-explain` SoftPulse ENTERS→CALLS→FOLDS + `explainGrading` under Tag high participation → **LPT-761** (needs-human; Relates LPT-186).
  - successors `act-04-06-01-02-explain-folding` (FOLDS TO BETS→STICKY) + `act-04-06-01-03-explain-certainty` (OBSERVATION→SAMPLES) content-driven; guided SoftPulse `high-part` densify PRESENT (`deal.mode` `none`) + scaffolded SoftPulse `sticky` densify PRESENT + unguided SoftPulse `low-conf` densify PRESENT + checkpoint SoftPulse `bundle` kind `none` hintless (evidence-bundle residual note under Tag low folding on LPT-761).
- Curriculum **LPT-186** Done — do not clone / do not re-add needs-human. Tip-commented LPT-761/186/677 + Meet Nit LPT-198 / LPT-216; leave open LPT-676…761.
- Prefer next: NEVER `lesson-04-06-02-*` Meet Station / Low residuals LPT-676…761.
- act-04-06-01-*: interactive structural clean on tip except SoftPulse residual LPT-761; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive is `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14ed (49e27b42 discovery Meet Station working-model residual)

- Tip-stable `49e27b42` (#2355 observe-sticky SoftPulse residual learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-06-02-01/02/03` under Meet Calling Station unit:
  - first-child `act-04-06-02-explain` SoftPulse STATION→HIGH→LOW + `explainGrading` under Introduce **concept-aligned** (not SoftPulse residual).
  - scaffolded SoftPulse `model` working-model meta under Introduce → **LPT-767** (needs-human; Relates LPT-189; sibling TAG working-model **LPT-708**).
  - successors `act-04-06-02-02-explain-spot` (STICKY CALLS→RARE FOLDS) + `act-04-06-02-03-explain-sample` (SAMPLE→CONFIDENCE) content-driven; guided SoftPulse `pt-station` + unguided SoftPulse `station2` densify PRESENT + checkpoint SoftPulse `low` kind `none` densify PRESENT.
- Curriculum **LPT-189** Done — do not clone / do not re-add needs-human. Race SoftPulse clone **LPT-762** Done Duplicate of **LPT-761**. Tip-commented LPT-767/189/761/708 + Meet Nit LPT-198 / LPT-216; leave open LPT-676…767 (leave ui-agent In Progress LPT-763…766 alone).
- Prefer next: NEVER `lesson-04-07-01-*` observe-narrow / Low residuals LPT-676…767.
- act-04-06-02-*: interactive structural clean on tip except working-model residual LPT-767; SoftPulse explain concept-aligned / successors content-driven (do not reopen LPT-669); interactive is `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14ee (49e27b42 discovery observe-narrow SoftPulse residual)

- Tip-stable `49e27b42` (#2355 tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-07-01-01/02/03` under Observe narrow unit:
  - first-child `act-04-07-01-explain` SoftPulse RARE→ENTER→MEAN IT + `explainGrading` / Dart `TightSeatsDemo` under Tag narrow entry → **LPT-768** (needs-human; Relates LPT-195; sibling Sticky SoftPulse **LPT-761**).
  - successors `act-04-07-01-02-explain-aggression` (RARE ENTRY→BIG AGGRESSION) + `act-04-07-01-03-explain-wait` (TWO FOLDS→MORE HANDS) content-driven; guided SoftPulse `narrow` densify PRESENT + scaffolded SoftPulse `strong-aggr` densify PRESENT + unguided SoftPulse `wait` densify PRESENT + checkpoint SoftPulse `bundle-nit` kind `none` hintless (evidence-bundle residual note under Tag strong aggression on LPT-768).
- Curriculum **LPT-195** Done — do not clone / do not re-add needs-human. Tip-commented LPT-768/195/767 + Meet Nit LPT-198 / LPT-216; leave open LPT-676…768.
- Prefer next: NEVER `lesson-04-07-02-*` Meet Nit / Low residuals LPT-676…768.
- act-04-07-01-*: interactive structural clean on tip except SoftPulse residual LPT-768; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive is `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14ef (1c64dc95 discovery Meet Nit working-model residual)

- Tip-stable `1c64dc95`. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-07-02-01/02` under Meet Nit unit:
  - first-child `act-04-07-02-explain` SoftPulse NIT→NARROW→RESPECT + `explainGrading` under Introduce **concept-aligned** (not SoftPulse residual).
  - checkpoint SoftPulse `model-n` working-model meta under Introduce → **LPT-769** (needs-human; Relates LPT-198; siblings TAG working-model **LPT-708** / Station **LPT-767**).
  - successor Spot `act-04-07-02-02-explain-spot` SoftPulse FEW HANDS→BIG RAISES content-driven; guided SoftPulse `pt-nit` + unguided SoftPulse `nit2` one-per-press densify PRESENT.
- Curriculum **LPT-198** Done — do not clone / do not re-add needs-human. Tip-commented LPT-769/198/768/767/708 + LPT-216; leave open LPT-676…769.
- Prefer next: NEVER `lesson-04-07-03-*` Adjust Nit / Low residuals LPT-676…769.
- act-04-07-02-*: interactive structural clean on tip except working-model residual LPT-769; SoftPulse explain concept-aligned / Spot content-driven (do not reopen LPT-669); interactive is `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14eg (197e9137 discovery Adjust Nit SoftPulse residual)

- Tip-stable `197e9137` (#2358 Meet Nit working-model residual learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-07-03-01/02/03` under Adjust Nit unit:
  - first-child `act-04-07-03-explain` SoftPulse STEAL→CREDIT→EXPLODE + `explainGrading` under Steal-more → **LPT-772** (needs-human; Relates LPT-202).
  - successors `act-04-07-03-02-explain-respect` (NIT RAISES→CREDIT) + `act-04-07-03-03-explain-cite` (EVIDENCE→UNKNOWN) content-driven; guided SoftPulse `steal` + scaffolded SoftPulse `fold-mid` + unguided SoftPulse `tighter` PRESENT; checkpoint SoftPulse `cite-strong` kind `none` (cite residual note under Respect).
- Curriculum **LPT-202** Done — do not clone / do not re-add needs-human. Tip-commented LPT-772/202/769 + Meet Nit LPT-198 / LPT-216; leave open LPT-676…772 (leave ui-agent LPT-770/771 alone).
- Prefer next: NEVER `lesson-04-08-01-*` observe-wild / Low residuals LPT-676…772.
- act-04-07-03-*: interactive structural clean on tip except SoftPulse residual LPT-772; SoftPulse explain successors content-driven (do not reopen LPT-669).

## Fold 2026-10-14eh (b2b96c67 discovery observe-wild SoftPulse residual)

- Tip-stable `b2b96c67` (#2359 Adjust Nit SoftPulse residual learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-08-01-01/02/03` under Observe wild unit:
  - first-child `act-04-08-01-explain` SoftPulse RAISE→BARREL→COUNT + `explainGrading` under Tag extreme entry → **LPT-773** (needs-human; Relates LPT-205).
  - successors `act-04-08-01-02-explain-pressure` (EVERY STREET→WEAK SHOWDOWNS) + `act-04-08-01-03-explain-ego` (FREQUENCIES→NO EGO) content-driven; guided SoftPulse `extreme` + scaffolded SoftPulse `pressure` + unguided SoftPulse `calm` densify PRESENT; checkpoint SoftPulse `bundle-m` kind `none` (evidence-bundle residual note under Constant aggression).
- Curriculum **LPT-205** Done — do not clone / do not re-add needs-human. Tip-commented LPT-773/205/772/768 + Meet Nit LPT-198 / LPT-216; leave open LPT-676…773.
- Prefer next: NEVER `lesson-04-08-02-*` Meet Maniac / Low residuals LPT-676…773.
- act-04-08-01-*: interactive structural clean on tip except SoftPulse residual LPT-773; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive is `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14ei (1e6670fc discovery Meet Maniac mix-discipline residual)

- Tip-stable `1e6670fc` (#2360 observe-wild SoftPulse residual learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-08-02-01/02` under Meet Maniac unit:
  - first-child `act-04-08-02-explain` SoftPulse MANIAC→ENTRY→AGGRO + `explainGrading` under Introduce **concept-aligned** (not SoftPulse residual).
  - checkpoint SoftPulse `three` mix-discipline meta under Introduce → **LPT-774** (needs-human; Relates LPT-208; siblings TAG **LPT-708** / Station **LPT-767** / Nit **LPT-769**).
  - successor Spot `act-04-08-02-02-explain-spot` SoftPulse CONSTANT RAISES→NEVER GIVES UP content-driven; guided SoftPulse `pt-maniac` + unguided SoftPulse `maniac2` densify PRESENT.
- Curriculum **LPT-208** Done — do not clone / do not re-add needs-human. Tip-commented LPT-774/208/773/769 + Meet Nit LPT-198 / LPT-216; leave open LPT-676…774 (leave ui-agent In Progress **LPT-771** alone).
- Prefer next: NEVER `lesson-04-08-03-*` Adjust Maniac / Low residuals LPT-676…774.
- act-04-08-02-*: interactive structural clean on tip except mix-discipline residual LPT-774; SoftPulse explain concept-aligned / Spot content-driven (do not reopen LPT-669); interactive is `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14ej (554d7f24 discovery Adjust Maniac SoftPulse re-check)

- Tip-stable `554d7f24` (#2361 Meet Maniac mix-discipline residual learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-08-03-01/02` under Adjust Maniac unit:
  - first-child `act-04-08-03-explain` SoftPulse WIDER→HANG→EGO + `explainGrading` under still-merged Widen + Avoid-ego objectives (*expected packing* — no SoftPulse residual).
  - successor `act-04-08-03-02-explain-cite` SoftPulse EVIDENCE→UNKNOWN content-driven; guided SoftPulse `call-wider` + scaffolded SoftPulse `val-m` + unguided SoftPulse `baseline-fold` PRESENT; checkpoint SoftPulse `cite-wide` kind `none` under Cite.
- Curriculum **LPT-212** Done — do not clone / do not re-add needs-human. Tip-commented LPT-212/774 + Meet Nit LPT-198 / LPT-216; leave open LPT-676…774 (leave ui-agent In Progress **LPT-771** alone).
- Prefer next: NEVER `lesson-04-09-01-*` Confidence / Low residuals LPT-676…774.
- act-04-08-03-*: interactive structural clean on tip; SoftPulse explain packing expected under dual-objective first child; successors content-driven (do not reopen LPT-669).

## Fold 2026-10-14ek (7d9ff87c discovery Confidence SoftPulse residual)

- Tip-stable `7d9ff87c` (#2362 Adjust Maniac SoftPulse re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-04-09-01-01/02/03` under Confidence unit:
  - first-child `act-04-09-01-explain` SoftPulse OBSERVE→SAMPLES→SHOWDOWNS + `explainGrading` under Observation-not-certainty → **LPT-775** (needs-human; Relates LPT-215).
  - race clone **LPT-776** Done Duplicate of LPT-775.
  - successors `act-04-09-01-02-explain-samples` (SAMPLES→SHOWDOWNS) + `act-04-09-01-03-explain-retire` (NEW EVIDENCE→RETIRE) content-driven; guided SoftPulse `one-note` + scaffolded SoftPulse `rise` + unguided SoftPulse `update` densify PRESENT; checkpoint SoftPulse `limits` kind `none` (sample-limits residual note under Raise confidence).
- Curriculum **LPT-215** Done — do not clone / do not re-add needs-human. Tip-commented LPT-775/215/776/774 + Meet Nit LPT-198 / LPT-216; leave open LPT-676…775.
- Prefer next: NEVER `lesson-04-10-01-*` exploit-checkpoints / Low residuals LPT-676…775.
- act-04-09-01-*: interactive structural clean on tip except SoftPulse residual LPT-775; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive is `deal.mode` `none` observation tiles — do not file handFamily.


## Fold 2026-10-14en (b324cc71 discovery multiway SoftPulse residual re-check)

- Tip-stable `b324cc71` (#2369 Section 4 jump clean Prefer NEVER → multiway). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-05-01-01-01/02/03` under multiway ranges unit:
  - first-child `act-05-01-01-explain` SoftPulse NUTTED→AIR→DOMINATION + `explainGrading` under Prefer nut potential **concept-aligned** (not SoftPulse residual).
  - successors `act-05-01-01-02-explain-speculative` (MULTIWAY→OOP→FOLD) + `act-05-01-01-03-explain-value` (CALLERS→SET→BET) content-driven; guided SoftPulse `nfd` densify PRESENT (`deal.mode` `none`); scaffolded SoftPulse `fold-76` one-per-press PRESENT (`7h/6h` +2 suit variants); unguided SoftPulse `bet-set` one-per-press PRESENT (`9h/9d`·`9s/8c/7h` +2 variants); checkpoint SoftPulse `nuts` kind `none` hintless densify PRESENT.
- Curriculum **LPT-224** Done — do not clone / do not re-add needs-human; no activity↔objective residual (checkpoint nuts-priority matches Prefer nut potential).
- Tip-commented LPT-224/222/680/779/198/216/725/775; leave open LPT-676…779.
- Prefer next: NEVER `lesson-05-02-01-*` deep-stack / Low residuals LPT-676…779 (residual **LPT-680** still To Do).
- act-05-01-01-*: interactive structural clean on tip; SoftPulse explain concept-aligned / successors content-driven (do not reopen LPT-669); guided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14eo (31134c82 discovery deep-stack SoftPulse Prefer re-check)

- Tip-stable `31134c82` (#2370 multiway SoftPulse residual clean Prefer NEVER → deep-stack). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Discovery NEVER `lesson-05-02-01-01/02/03` under deep-stack unit:
  - first-child `act-05-02-01-explain` SoftPulse DEEP→REALIZE→STACK + `explainGrading` under Use-depth-for-speculative-implied-odds **concept-aligned** (no SoftPulse residual).
  - successors `act-05-02-01-02-explain-stack-off` (DEEP→ONE PAIR→FOLD) + `act-05-02-01-03-explain-plan` (SPR→TURN→RIVER) content-driven; guided SoftPulse `impl` densify PRESENT (`deal.mode` `none`); scaffolded SoftPulse `fold-tp` one-per-press PRESENT (`Ad`/`9c`·`As`/`Th`/`7h` +2 suit variants; Dart `stackLabel` Stacks left 500); unguided SoftPulse `plan` densify PRESENT; checkpoint SoftPulse `pos` kind `none` hintless densify PRESENT.
- Curriculum **LPT-227** Done — do not clone / do not re-add needs-human; residual rewards-synthesis checkpoint still under Plan-high-SPR → **LPT-680** still To Do (needs-human).
- Tip-commented LPT-680/227/779/198/216/681/224/725/775/225; leave open LPT-676…779.
- Prefer next: NEVER `lesson-05-03-01-*` implied-odds / Low residuals LPT-676…779 (LPT-680 + LPT-681).
- act-05-02-01-*: interactive structural clean on tip except LPT-680 residual; SoftPulse explain concept-aligned / successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.


## Fold 2026-10-14ep (4ff7eb4e Prefer NEVER implied-odds SoftPulse re-check)

- Tip-stable `4ff7eb4e` (#2371 deep-stack SoftPulse Prefer re-check learnings). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-05-03-01-01/02/03` under implied-odds unit:
  - first-child `act-05-03-01-explain` SoftPulse IMPLIED→REVERSE→SECOND + Dart `impliedOdds` / `ImpliedOddsDemo` still pre-split ladder under Estimate implied odds → residual **LPT-681** still To Do (needs-human).
  - guided SoftPulse `call-io` PRESENT (`Jh`/`9d`·`8s`/`7c`/`2d` +2 suit variants; Dart `stackLabel` Stacks left 400); checkpoint SoftPulse `depth-pay` kind `none` hintless densify PRESENT (non-spoiling stem) — checkpoint OK under Estimate.
  - successors `act-05-03-01-02-explain-reverse` (REVERSE→DOMINATED→FOLD) + `act-05-03-01-03-explain-draws` (NON-NUT→MULTIWAY→SKIP) content-driven; scaffolded SoftPulse `rio` + unguided SoftPulse `nonut` one-per-press PRESENT.
- Curriculum **LPT-230** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-681/230/680/779/198/216/228; leave open LPT-676…779.
- Prefer next: NEVER `lesson-05-04-01-*` thin-value / Low residuals LPT-676…779 (LPT-680 + LPT-681).
- act-05-03-01-*: interactive structural clean on tip except LPT-681 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); checkpoint is `deal.mode` `none` rise tiles — do not file handFamily.

## Fold 2026-10-14eq (ecac848b Prefer NEVER thin-value SoftPulse re-check)

- Tip-stable `ecac848b` (#2372 implied-odds SoftPulse Prefer re-check learnings). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-05-04-01-01/02/03` under thin-value unit:
  - first-child `act-05-04-01-explain` SoftPulse THIN→CATCH→BARRELS + Dart `ThinValueDemo` still pre-split ladder under thin-value-only → residual **LPT-682** still To Do (needs-human); coachMedia still "Thin value needs calls. Bluff-catches need wide barrels."
  - guided SoftPulse `tv` PRESENT (`Jh`/`9d`·`Kc`/`9s`/`4h`/`2d`/`7c` +2 suit variants; SoftPulse maps PRESENT in `poker_action_sizing_activity.dart`); checkpoint SoftPulse `read` kind `none` hintless densify PRESENT — meta-read under Thin sticky callers → residual **LPT-683** still To Do (needs-human).
  - successors `act-05-04-01-02-explain-catch` (MANIAC→BARREL→CALL) + `act-05-04-01-03-explain-overfold` (NIT→FOLDS→CHECK) content-driven; scaffolded SoftPulse `call-m` + unguided SoftPulse `check-nit` one-per-press PRESENT.
- Curriculum **LPT-233** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-682/683/233/680/681/779/198/216; leave open LPT-676…779.
- Prefer next: NEVER `lesson-05-05-01-*` lines-and-probes / Low residuals LPT-676…779 (LPT-680 + LPT-681 + LPT-682 + LPT-683).
- act-05-04-01-*: interactive structural clean on tip except LPT-682 SoftPulse + LPT-683 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); checkpoint is `deal.mode` `none` read tiles — do not file handFamily; poker_action_sizing densify N/A.

## Fold 2026-10-14eu (fe61a7a7 Prefer NEVER table-dynamics SoftPulse re-check)

- Tip-stable `fe61a7a7` (#2379 timing SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-05-08-01-01/02/03` under table-dynamics unit:
  - first-child `act-05-08-01-explain` SoftPulse STUCK→TILTED→GEARS + `explainGrading` "Stuck → Tilted → Gears." + coachMedia gears teaser + Dart `TablesChangeDemo` still pre-split under tilted/stuck-only → residual **LPT-686** still To Do (needs-human).
  - companion `act-05-08-01-checkpoint` SoftPulse `temp` kind `none` densify PRESENT under Gear changes grades fresh-samples vs permanent seats → residual **LPT-687** still To Do (needs-human).
  - successors `act-05-08-01-02-explain-gears` (GEAR→CHANGE→SAMPLE) + `act-05-08-01-03-explain-reset` (COOLER→CHASE→RESET) content-driven; guided SoftPulse `stuck` densify PRESENT; scaffolded SoftPulse `gear` one-per-press PRESENT; unguided SoftPulse `reset` map PRESENT (`Jh`/`Td`·`Kc`/`9s`/`4h`/`2d`/`7c` +2 suit variants).
- Curriculum **LPT-247** Done — do not clone / do not re-add needs-human. Race clones LPT-688/689 Done Duplicate — do not reopen.
- Tip-commented LPT-686/687/247/198/216/685/779; leave open LPT-676…779; leave ui-agent In Progress **LPT-782**/783/784 alone.
- Prefer next: NEVER `lesson-05-09-01-*` session-discipline / Low residuals LPT-676…779 (LPT-680…687 + LPT-690/691).
- act-05-08-01-*: interactive structural clean on tip except LPT-686 SoftPulse + LPT-687 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14ev (8a40468c Prefer NEVER session-discipline SoftPulse re-check)

- Tip-stable `8a40468c` (#2381 table-dynamics SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-05-09-01-01/02/03` under session-discipline unit:
  - first-child `act-05-09-01-explain` SoftPulse QUIT→GUARD→FIRST + `explainGrading` "Quit → Guard → First." + coachMedia "Guardrails first." + Dart `GuardrailsDemo` still pre-split under stop-loss-only → residual **LPT-690** still To Do (needs-human).
  - companion `act-05-09-01-checkpoint` SoftPulse `edge` kind `none` densify PRESENT under End sessions grades Session discipline = Your edge → residual **LPT-691** still To Do (needs-human).
  - successors `act-05-09-01-02-explain-bankroll` (BANKROLL→STAKES→DECLINE) + `act-05-09-01-03-explain-quit` (TIRED→WILD→CASH OUT) content-driven; guided SoftPulse `stop` densify PRESENT; scaffolded SoftPulse `decline` one-per-press PRESENT; unguided SoftPulse `cash` one-per-press PRESENT.
- Curriculum **LPT-250** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-690/691/250/198/216/686/687/692; leave open LPT-676…779; leave ui-agent In Progress alone.
- Prefer next: NEVER `lesson-06-01-01-*` range-nut / Low residuals LPT-676…779 (LPT-680…692).
- act-05-09-01-*: interactive structural clean on tip except LPT-690 SoftPulse + LPT-691 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14ew (76600ad0 Prefer NEVER range-nut SoftPulse re-check)

- Tip-stable `76600ad0` (#2383 SoftPulse-off densify stems; after #2382 session-discipline learnings). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-06-01-01-01/02/03` under range-nut unit:
  - first-child `act-06-01-01-explain` SoftPulse RANGE→NUT→ADVANTAGE + `explainGrading` "Range → Nut → Advantage." + coachMedia names both + Dart `RangeAdvantageDemo` still pre-split under range-advantage-only → residual **LPT-692** still To Do (needs-human).
  - successors `act-06-01-01-02-explain-nuts` (NUTS→PAIRED→CALLER) + `act-06-01-01-03-explain-press` (RANGE→NUTS→BET) content-driven; guided SoftPulse `pfr` densify PRESENT; scaffolded SoftPulse `caller-nuts` one-per-press PRESENT; unguided SoftPulse `cbet` map PRESENT (`Ah`/`Kd`·`Kc`/`7s`/`2d` +2 suit variants); checkpoint SoftPulse `press` kind `none` densify PRESENT (matches pressure-when-own-both — no companion residual).
- Curriculum **LPT-254** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-692/254/198/216/690/691/693; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-02-01-*` equity-realization / Low residuals LPT-676…779 (LPT-680…693).
- act-06-01-01-*: interactive structural clean on tip except LPT-692 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14ex (d8023786 Prefer NEVER equity-realization SoftPulse re-check)

- Tip-stable `d8023786` (#2384 range-nut SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-06-02-01-01/02/03` under equity-realization unit:
  - first-child `act-06-02-01-explain` SoftPulse EQUITY→CASH→POS + `explainGrading` "Equity → Cash → Position." + coachMedia "Position decides realization." + Dart `EquityRealizeDemo` POS-led Prefer-IP framing OK (not a NUT-style successor leak).
  - companion `act-06-02-01-checkpoint` SoftPulse `pos` kind `none` densify PRESENT under Prefer-IP grades Position + initiative → residual **LPT-693** still To Do (needs-human).
  - successors `act-06-02-01-02-explain-oop` (OOP→BARRELS→DISCOUNT) + `act-06-02-01-03-explain-aggro` (SEMI-BLUFF→FOLDS→OUTS) content-driven; guided SoftPulse `ip` densify PRESENT; scaffolded SoftPulse `discount` one-per-press PRESENT; unguided SoftPulse `realize` one-per-press PRESENT.
- Curriculum **LPT-257** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-693/257/198/216/690/691/692/694; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-03-01-*` capped-uncapped / Low residuals LPT-676…779 (LPT-680…694).
- act-06-02-01-*: interactive structural clean on tip except LPT-693 Prefer-IP checkpoint residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14ey (0f3ab3dd Prefer NEVER capped-uncapped SoftPulse re-check)

- Tip-stable `0f3ab3dd` (#2385 equity-realization SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-06-03-01-01/02/03` under capped-uncapped unit:
  - first-child `act-06-03-01-explain` SoftPulse CAPPED→UNCAPPED→NUTS + `explainGrading` "Capped → Uncapped → Nuts." + Dart `CappedUncappedDemo.points` still pre-split under spot-caps-only → residual **LPT-694** still To Do (needs-human; race clone LPT-695 Done).
  - successors `act-06-03-01-02-explain-uncapped` (RAISE→BET→RESPECT) + `act-06-03-01-03-explain-attack` (CAPPED→THIN→BLUFF) content-driven; guided SoftPulse `cap` densify PRESENT; unguided SoftPulse `uncap` one-per-press PRESENT; scaffolded SoftPulse `bet` one-per-press PRESENT (`Jh`/`9d`·`Kc`/`9s`/`4h`/`2d`/`7c` +2 suit variants match Dart); checkpoint SoftPulse `attack` kind `none` densify PRESENT under Attack caps — matches objective (no companion residual).
- Curriculum **LPT-260** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-694/260/693/692/198/216/696; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-04-01-*` polar-merged / Low residuals LPT-676…779 (LPT-680…696).
- act-06-03-01-*: interactive structural clean on tip except LPT-694 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14ez (a6a2ac09 Prefer NEVER polar-merged SoftPulse re-check)

- Tip-stable `a6a2ac09` (#2386 capped SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-06-04-01-01/02/03` under polar-merged unit:
  - first-child `act-06-04-01-explain` SoftPulse POLAR→MERGED→SIZE + `explainGrading` "Polar → Merged → Size." + Dart `PolarMergedDemo` still pre-split under polarized-sizing-only → residual **LPT-696** still To Do (needs-human).
  - successors `act-06-04-01-02-explain-merged` (MERGED→MEDIUM→VALUE) + `act-06-04-01-03-explain-mismatch` (SIZE→SHAPE→MATCH) content-driven; guided SoftPulse `polar` densify PRESENT; scaffolded SoftPulse `mid` one-per-press PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants); unguided SoftPulse `mismatch` densify PRESENT; checkpoint SoftPulse `thin` kind `none` densify PRESENT (matches merged thin value — no companion residual).
- Curriculum **LPT-264** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-696/264/198/216/694/693/699; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-05-01-*` overbets-geometric / Low residuals LPT-676…779 (LPT-680…699).
- act-06-04-01-*: interactive structural clean on tip except LPT-696 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14fa (e916ff9f Prefer NEVER overbets SoftPulse re-check)

- Tip-stable `e916ff9f` (#2387 polar SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-06-05-01-01/02/03` under overbets-geometric unit:
  - first-child `act-06-05-01-explain` SoftPulse OVERBET→POLAR→GEO + `explainGrading` + Dart `OverbetGeometryDemo` / `LessonOverbetGeometryExplainTable` still pre-split under polar-overbets-only → residual **LPT-699** still To Do (needs-human).
  - successors `act-06-05-01-02-explain-geometry` (FLOP→TURN→RIVER) + `act-06-05-01-03-explain-random` (HUGE→MEDIUM→AVOID) content-driven; guided SoftPulse `polar-ob` densify PRESENT; scaffolded SoftPulse `mid` one-per-press PRESENT (`As`/`Kd`·`Ah`/`7c`/`2d`/`9s` +2 suit variants match Dart); unguided SoftPulse `avoid` densify PRESENT; checkpoint SoftPulse `multi` kind `none` densify PRESENT (matches geometric-sizes — no companion residual).
- Curriculum **LPT-267** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-699/267/198/216/696/694/700; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-06-01-*` blockers / Low residuals LPT-676…779 (LPT-680…700).
- act-06-05-01-*: interactive structural clean on tip except LPT-699 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants geometric-turn honesty.

## Fold 2026-10-14fb (4a31a129 Prefer NEVER blockers SoftPulse re-check)

- Tip-stable `4a31a129` (#2389 after #2387 polar SoftPulse Prefer re-check; rescues unfolder overbet fold from draft #2388). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-06-06-01-01/02/03` under blockers unit:
  - first-child `act-06-06-01-explain` SoftPulse BLOCK→USE→NO EV + `explainGrading` "Block → Use → No EV." + Dart `BlockersDemo.points` BLOCK/USE/NO EV / `LessonBlockersExplainTable` still pre-split under bluff-blockers-only → residual **LPT-700** still To Do (needs-human).
  - successors `act-06-06-01-02-explain-unblock` (CATCH→UNBLOCK→BLUFFS) + `act-06-06-01-03-explain-ev` (TWEAK→NO EV) content-driven; guided SoftPulse `as` densify PRESENT (`blockersGuidedOutcomes`); scaffolded SoftPulse `unblock` one-per-press PRESENT; unguided SoftPulse `tweak` one-per-press PRESENT; checkpoint SoftPulse `no` kind `none` densify PRESENT (matches no-fake-ev — no companion residual).
- Curriculum **LPT-270** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-700/270/198/216/699/696/701; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-07-01-*` min-defense / Low residuals LPT-676…779 (LPT-680…701).
- act-06-06-01-*: interactive structural clean on tip except LPT-700 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.


## Fold 2026-10-14

## Fold 2026-10-14fc (1c6fcd76 Prefer NEVER min-defense SoftPulse re-check)

- Tip-stable `1c6fcd76` (#2390 blockers SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-06-07-01-01/02/03` under min-defense unit:
  - first-child `act-06-07-01-explain` SoftPulse DEFEND→BLUFF→ENOUGH + `explainGrading` "Defend → Bluff → Enough." + Dart `DefendEnoughDemo` / `LessonDefendEnoughExplainTable` still pre-split under continue-catchers-only → residual **LPT-701** still To Do (needs-human).
  - companion `act-06-07-01-checkpoint` SoftPulse `punish` kind `none` densify PRESENT under Continue with stronger catchers → residual **LPT-702** still To Do (needs-human).
  - successors `act-06-07-01-02-explain-trash` (THIRD PAIR→SCARY→FOLD) + `act-06-07-01-03-explain-mdf` (MDF→INTUITION) content-driven; guided SoftPulse `strong` densify PRESENT; scaffolded SoftPulse `fold` one-per-press PRESENT (`9h`/`7d`·`Kc`/`Qh`/`9d`/`4c`/`8s` +2 suit variants match Dart); unguided SoftPulse `int` one-per-press PRESENT.
- Curriculum **LPT-273** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-701/702/273/198/216/700/699/703; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-08-01-*` mix / Low residuals LPT-676…779 (LPT-680…703).
- act-06-07-01-*: interactive structural clean on tip except LPT-701 SoftPulse + LPT-702 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants third-pair honesty.

## Fold 2026-10-14fd (83adc4c9 Prefer NEVER mixed-strategy SoftPulse re-check)

- Tip-stable `83adc4c9` (#2391 min-defense SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-06-08-01-01/02/03` under mixed-strategy unit:
  - first-child `act-06-08-01-explain` SoftPulse MIX→PURPOSE→STRONG + `explainGrading` "Mix → Purpose → Strong." + Dart `MixedStrategyDemo` still pre-split under mix-strong-only → residual **LPT-703** still To Do (needs-human).
  - successors `act-06-08-01-02-explain-types` (TYPE→STATION→LESS) + `act-06-08-01-03-explain-random` (RANDOM→PURPOSE) content-driven; guided SoftPulse `protect` PRESENT (`7h`/`7d`·`7c`/`Kd`/`2s` +2 suit variants); scaffolded SoftPulse `less` densify PRESENT; unguided SoftPulse `no` densify PRESENT; checkpoint SoftPulse `freq` kind `none` densify PRESENT (matches no-pure-random — no companion residual).
- Curriculum **LPT-277** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-703/277/198/216/701/702/704; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-09-01-*` threebet-fourbet / Low residuals LPT-676…779 (LPT-680…704).
- act-06-08-01-*: interactive structural clean on tip except LPT-703 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); scaffolded/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14fe (200e7122 Prefer NEVER threebet-fourbet SoftPulse re-check)

- Tip-stable `200e7122` (#2392 mixed-strategy SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-06-09-01-01/02/03` under threebet-fourbet unit:
  - careful-4bet `act-06-09-01-01-explain-fourbet` SoftPulse 4BET→STRONG→CAREFUL content-driven + `explainGrading` "4-bet → Strong → Careful." + guided SoftPulse `careful` densify PRESENT (`deal.mode` `none`) — concept-aligned.
  - **middle-child** `act-06-09-01-explain` SoftPulse 3BET→4BET→DEPTH + `explainGrading` "3-bet → 4-bet → Depth." + Dart `ThreeBetFourBetSprDemo.points` 3BET/4BET/DEPTH / `LessonThreeBetFourBetSprExplainTable` still pre-split under plan-3bet-spr → residual **LPT-704** still To Do (needs-human).
  - scaffolded SoftPulse `small` one-per-press PRESENT (`Ah`/`Qd`·`8c`/`3h`/`2s` +2 suit variants; `stackLabel` Stacks left 360 match Dart); checkpoint SoftPulse `spr` kind `none` densify PRESENT under plan-3bet-spr matches — no companion residual.
  - ego `act-06-09-01-03-explain-ego` SoftPulse 4BET→EGO→AVOID content-driven; unguided SoftPulse `avoid` one-per-press densify PRESENT (`deal.mode` `none`).
- Curriculum **LPT-282** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-704/282/198/216/703/701/702/705; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-10-01-*` difficult-folds / Low residuals LPT-676…779 (LPT-680…705).
- act-06-09-01-*: interactive structural clean on tip except LPT-704 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants AQo-miss honesty.

## Fold 2026-10-14ff (d3d5c0bb Prefer NEVER difficult-folds SoftPulse re-check)

- Tip-stable `d3d5c0bb` (#2394 threebet SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery NEVER `lesson-06-10-01-01/02/03` under difficult-folds unit:
  - first-child `act-06-10-01-explain` SoftPulse HARD→COOLER→EGO + `explainGrading` "Hard → Cooler → Ego." + Dart `HardFoldCoolerDemo` still pre-split under hard-folds-only → residual **LPT-705** still To Do (needs-human).
  - successors `act-06-10-01-02-explain-cooler` (COOLER→MISTAKE→REVIEW) + `act-06-10-01-03-explain-ego` (DUE→EGO→FOLD) content-driven; guided SoftPulse `fold` PRESENT (`Ah`/`9d`·`As`/`7c`/`2h`/`Kd`/`3c` +2 suit variants); scaffolded SoftPulse `cooler` densify PRESENT; unguided SoftPulse `ego` densify PRESENT; checkpoint SoftPulse `ask` kind `none` densify PRESENT (matches cooler-or-mistake — no companion residual).
- Curriculum **LPT-285** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-705/285/198/216/704/703/706; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-11-01-*` observe-selective / Low residuals LPT-676…779 (LPT-680…706).
- act-06-10-01-*: interactive structural clean on tip except LPT-705 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); scaffolded/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14fg (d3d5c0bb Prefer NEVER observe-selective SoftPulse re-check)

- Tip-stable `d3d5c0bb` (#2394 threebet SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-06-11-01-01/02/03` under observe-selective unit:
  - first-child `act-06-11-01-explain` SoftPulse TIGHT→BARREL→SAMPLE + `explainGrading` "Tight → Barrel → Sample." + Dart `SelectiveAggressionDemo` / `LessonSelectiveAggressionExplainTable` still pre-split under selective-entry-only → residual **LPT-706** still To Do (needs-human).
  - successors `act-06-11-01-02-explain-discipline` (CALLED→GIVES UP) + `act-06-11-01-03-explain-wait` (TWO HANDS→NOTE BUNDLE) content-driven; guided SoftPulse `sel` densify PRESENT (`deal.mode` `none`; guideRegion `selectivePlanOk`); scaffolded SoftPulse `disc` one-per-press densify PRESENT (guideRegion `selectiveDisciplined`); unguided SoftPulse `low` one-per-press densify PRESENT (guideRegion `selectiveKeepSampling`); checkpoint SoftPulse `bundle` kind `none` densify PRESENT under wait-for-samples matches — no companion residual.
- Curriculum **LPT-288** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-706/288/705/704/703/198/216/708; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-11-02-*` Meet TAG / Low residuals LPT-676…779 (LPT-680…708).
- act-06-11-01-*: interactive structural clean on tip except LPT-706 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14fh (a087d302 Prefer NEVER Meet TAG SoftPulse re-check)

- Tip-stable `a087d302` (#2397 observe-selective SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-06-11-02-01/02/03` under Meet TAG unit:
  - first-child `act-06-11-02-explain` SoftPulse TIGHT→AGGRO→MODEL + `explainGrading` "Tight → Aggro → Model." + Dart `TagModelDemo` / `LessonTagModelExplainTable` matches Introduce TAG / The TAG model — **concept-aligned** (not SoftPulse residual; same class as careful-4bet).
  - checkpoint SoftPulse `model` kind `none` densify PRESENT (prompt "TAG is?" / Working model vs Insult) still under Introduce TAG-only → residual **LPT-708** still To Do (needs-human; Relates LPT-291).
  - successors `act-06-11-02-02-explain-spot` (FOLDS MOST→PLANNED BARRELS) + `act-06-11-02-03-explain-maniac` (ENTRY WIDTH→DISCIPLINE) content-driven; guided SoftPulse `tag` densify PRESENT (`deal.mode` `none`); scaffolded SoftPulse `diff` one-per-press densify PRESENT; unguided SoftPulse `tag2` one-per-press densify PRESENT.
- Curriculum **LPT-291** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-708/291/706/709/710/198/216/705; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-11-03-*` Adjust TAG / Low residuals LPT-676…779 (LPT-680…710).
- act-06-11-02-*: interactive structural clean on tip except LPT-708 working-model residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` player-type tiles — do not file handFamily.

## Fold 2026-10-14fi (ba2a9867 Prefer NEVER Adjust TAG SoftPulse re-check)

- Tip-stable `ba2a9867` (#2398 Meet TAG SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-06-11-03-01/02/03` under Adjust TAG unit:
  - first-child `act-06-11-03-explain` SoftPulse CREDIT→TIGHTER→NO LIGHT + `explainGrading` "Credit → Tighter → No light." + Dart `VsTagsDemo` / `LessonVsTagsExplainTable` still pre-split under Respect-TAG-aggression-only → residual **LPT-709** still To Do (needs-human; Relates LPT-294).
  - checkpoint SoftPulse `cite` kind `none` densify PRESENT (`tagRespectCiteOutcomes` / guideRegion) still under Respect-only → residual **LPT-710** still To Do (needs-human; Relates LPT-294).
  - successors `act-06-11-03-02-explain-checkraise` (CHECK-RAISE→FOLD) + `act-06-11-03-03-explain-thin` (RARELY CALLS→CHECK) content-driven; guided SoftPulse `fold` PRESENT (`Jh`/`9d`·`Qc`/`9s`/`3h` +2 suit variants match Dart); scaffolded SoftPulse `fold-k9` one-per-press PRESENT (`Kh`/`9d` +2 suit variants); unguided SoftPulse `check` one-per-press PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants).
- Curriculum **LPT-294** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-709/710/294/708/706/198/216; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-12-01-*` observe-wide / Low residuals LPT-676…779 (LPT-680…715).
- act-06-11-03-*: interactive structural clean on tip except LPT-709 SoftPulse + LPT-710 cite residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive sizing acts are `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` cite tiles — do not file handFamily.

## Fold 2026-10-14fj (3b72a004 Prefer NEVER Observe wide SoftPulse re-check)

- Tip-stable `3b72a004` (#2399 Adjust TAG SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-06-12-01-01/02/03` under Observe wide unit:
  - first-child `act-06-12-01-explain` SoftPulse WIDE→PRESSURE→SAMPLE + `explainGrading` "Wide → Pressure → Sample." + Dart WidePressure / `LessonWidePressureExplainTable` still pre-split under Note-wide-entry-only → residual **LPT-713** still To Do (needs-human; Relates LPT-297).
  - unguided SoftPulse `wait` Keep sampling under Note sustained pressure → residual **LPT-714** still To Do (needs-human; Relates LPT-297).
  - checkpoint SoftPulse `bundle` kind `none` densify PRESENT under Planned-not-maniac → residual **LPT-715** still To Do (needs-human; Relates LPT-297).
  - successors `act-06-12-01-02-explain-pressure` (BARRELS→MANY HANDS) + `act-06-12-01-03-explain-plan` (FOLDS SOMETIMES→PLAN) content-driven; guided SoftPulse `wide` densify PRESENT; scaffolded SoftPulse `sep` one-per-press densify PRESENT.
- Curriculum **LPT-297** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-713/714/715/297/198/216/709/710; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-12-02-*` meet-lag / Low residuals LPT-676…779 (LPT-680…715).
- act-06-12-01-*: interactive structural clean on tip except LPT-713 SoftPulse + LPT-714 unguided + LPT-715 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14fk (5f051e18 Prefer NEVER Meet LAG SoftPulse re-check)

- Tip-stable `5f051e18` (#2400 Observe wide SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-06-12-02-01/02/03` under Meet LAG unit:
  - first-child `act-06-12-02-explain` SoftPulse WIDE→PRESSURE→MODEL + `explainGrading` "Wide → Pressure → Model." + Dart LagModel / `LessonVsLagsExplainTable` matches Introduce LAG / The LAG model — **concept-aligned** (not SoftPulse residual; same class as Meet TAG).
  - checkpoint SoftPulse `limits` kind `none` densify PRESENT grades sample-limits under Introduce LAG-only → residual **LPT-716** still To Do (needs-human; Relates LPT-300).
  - successors `act-06-12-02-02-explain-spot` (WIDE OPENS→BARRELS) + `act-06-12-02-03-explain-station` (RAISES→CALLS) content-driven; guided SoftPulse `lag` densify PRESENT; unguided SoftPulse `lag2` densify PRESENT; scaffolded SoftPulse `diff` one-per-press densify PRESENT.
- Curriculum **LPT-300** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-716/300/198/216/713/714/715; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-12-03-*` adjust-lag / Low residuals LPT-676…779 (LPT-680…719).
- act-06-12-02-*: interactive structural clean on tip except LPT-716 sample-limits residual; SoftPulse explain concept-aligned + successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` player-type tiles — do not file handFamily.

## Fold 2026-10-14fl (8538413e Prefer NEVER Adjust LAG SoftPulse re-check)

- Tip-stable `8538413e` (#2401 Meet LAG SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-06-12-03-01/02/03` under Adjust LAG unit:
  - first-child `act-06-12-03-explain` SoftPulse CALL→TRAP→FANCY LESS + `explainGrading` "Call → Trap → Fancy less." + Dart `VsLagsDemo` still pre-split under Call-wider-only → residual **LPT-718** still To Do (needs-human; Relates LPT-303).
  - checkpoint SoftPulse `cite` kind `none` densify PRESENT under Call-wider-only → residual **LPT-719** still To Do (needs-human; Relates LPT-303).
  - successors `act-06-12-03-02-explain-trap` (STRONG HAND→LET THEM BET) + `act-06-12-03-03-explain-fancy` (NO BIG BLUFF→LET THEM) content-driven; guided SoftPulse `call` PRESENT (`Jh`/`9d`·`Qc`/`9s`/`3h`/`2d`/`7c` + suit variants); scaffolded SoftPulse `trap` PRESENT (`As`/`Ad`·`Ac`/`7s`/`2h` + suit variants); unguided SoftPulse `avoid` densify PRESENT.
- Curriculum **LPT-303** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-718/719/303/198/216/716; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-13-01-*` mix-five / Low residuals LPT-676…779 (LPT-680…721).
- act-06-12-03-*: interactive structural clean on tip except LPT-718 SoftPulse + LPT-719 cite residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded sizing `fixed`+variants — do not reopen LPT-627; unguided/checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-14fm (05b341f4 Prefer NEVER Mix five SoftPulse re-check)

- Tip-stable `05b341f4` (#2402 Adjust LAG SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-06-13-01-01/02/03/04` under Mix five / Same cards unit:
  - first-child `act-06-13-01-explain` SoftPulse CARDS→SEATS→EVIDENCE + `explainGrading` "Cards → Seats → Evidence." + Dart `ExploitEvidenceDemo` / `LessonExploitEvidenceExplainTable` still pre-split under Station-thin-only → residual **LPT-721** still To Do (needs-human; Relates LPT-306).
  - successors `act-06-13-01-02-explain-nit` (NIT CHECK-RAISE→FOLD) + `act-06-13-01-03-explain-lag` (LAG BARREL→CALL) + `act-06-13-01-04-explain-cite` (TENDENCY→LINE) content-driven; guided SoftPulse `cs` PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` + suit variants); scaffolded SoftPulse `nit` one-per-press PRESENT; unguided SoftPulse `lag` one-per-press PRESENT.
  - checkpoint SoftPulse `tag` under `lesson-06-13-01-04-cite-tendency` matches cite objective — no companion residual.
- Curriculum **LPT-306** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-721/306/718/719/716/198/216; leave open LPT-676…779; leave ui-agent alone.
- Prefer next: NEVER `lesson-06-13-02-*` S6 checkpoint / Low curriculum LPT-192 / Low residuals LPT-676…779 (LPT-680…721).
- act-06-13-01-*: interactive structural clean on tip except LPT-721 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded/unguided sizing `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` cite tiles — do not file handFamily.

## Fold 2026-10-14fn (58a3067f Prefer NEVER S6 checkpoint clean)

- Tip-stable `58a3067f` (#2403 Mix five SoftPulse Prefer re-check learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-06-13-02-section-six-checkpoint`:
  - all five `act-06-13-02-cp-adv/cap/polar/tag/lag` scaffolded + `assessmentRole` checkpoint; teachSpec `deal.mode` `none` + SoftPulse cues `ra`/`cap`/`polar`/`tag`/`lag` kind `none`; densify PRESENT in `selectIdentifyDensifiedCoachLine`; hintless.
  - structural **clean** — assessment container (skip curriculum-split / no SoftPulse residual / no needs-human multi-objective split).
- Tip-commented Done LPT-307/444 + Meet Nit LPT-198 / LPT-216 + adjacent LPT-721 + Done LPT-192; leave open LPT-676…779; leave ui-agent alone.
- LPT-192 Adjust Station Done — Prefer next no longer routes through unsplit Adjust Station.
- S6 Prefer NEVER SoftPulse path complete through Mix five residual **LPT-721**.
- Prefer next: NEVER `lesson-07-01-01-*` preflop-to-flop / Low residuals LPT-676…779 (LPT-680…721) / Low curriculum LPT-351.

## Fold 2026-10-14fo (0bbe821c Prefer NEVER preflop SoftPulse residual)

- Tip-stable `0bbe821c` (#2404 S6 checkpoint Prefer NEVER clean learnings on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-07-01-01-01/02/03` under Carry preflop plan unit:
  - first-child `act-07-01-01-explain` SoftPulse REASON→CONFIRM→CANCEL + `explainGrading` "Reason → Confirm → Cancel." + Dart `PreflopFlopPlanDemo` still pre-split under thesis-only → residual **LPT-790** filed (needs-human; Relates LPT-310).
  - successors `act-07-01-01-02-explain-update` (TEXTURE→CONFIRM OR CANCEL) + `act-07-01-01-03-explain-abandon` (DEAD PLAN→LET GO) content-driven; guided SoftPulse `dead` densify PRESENT; scaffolded SoftPulse `value` densify PRESENT; unguided SoftPulse `thesis` densify PRESENT; checkpoint SoftPulse `abandon` kind `none` densify PRESENT under abandon matches — no companion residual.
- Curriculum **LPT-310** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-790/310/198/216/721; leave open LPT-676…790; leave ui-agent alone.
- Prefer next: NEVER `lesson-07-02-01-*` flop-to-turn-map / Low residuals LPT-676…790 / Low curriculum LPT-351.
- act-07-01-01-*: interactive structural clean on tip except LPT-790 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14fp (eb362a79 Prefer NEVER Map SoftPulse residual)

- Tip-stable `eb362a79` (#2407 densify tip after #2405 preflop SoftPulse Prefer residual; Prefer NEVER Map SoftPulse re-check). Catalog re-check matched LPT-794 still To Do. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-07-02-01-01/02/03` under Map turn barrels unit (`unit-07-02-turn-map`):
  - first-child `act-07-02-01-explain` SoftPulse BARREL→GIVE-UP→MAP + `explainGrading` "Barrel → Give-up → Map." + Dart `TurnMapDemo` still pre-split under continue-cards-only → residual **LPT-794** filed (needs-human; Relates LPT-314).
  - successors `act-07-02-01-02-explain-giveup` (BRICK→GIVE UP) + `act-07-02-01-03-explain-map` (CONTINUE→GIVE-UP→MAP) content-driven; guided SoftPulse `ok` densify PRESENT; scaffolded SoftPulse `give` one-per-press densify PRESENT; unguided SoftPulse `avoid` one-per-press densify PRESENT; checkpoint SoftPulse `list` kind `none` densify PRESENT under map-definition matches — no companion residual.
- Curriculum **LPT-314** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-794/314/790/198/216/721; leave open LPT-676…794; leave ui-agent alone.
- Prefer next: NEVER `lesson-07-03-01-*` compose-river / Low residuals LPT-676…794 / Low curriculum LPT-351.
- act-07-02-01-*: interactive structural clean on tip except LPT-794 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded atmosphere stays LPT-394 Done `Jh`/`9d`·`Ks`/`Tc`/`2d`/`3s`.

## Fold 2026-10-14fq (6fb789b6 Prefer NEVER Compose SoftPulse + rule-checkpoint residuals)

- Tip-stable `6fb789b6` (#2406 Map SoftPulse Prefer residual on tip after #2407 densify). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-07-03-01-01/02/03` under Compose river unit:
  - first-child `act-07-03-01-explain` SoftPulse VALUE→BLUFF→HOLD + `explainGrading` "Value → Bluff → Hold." + Dart `RiverCompositionDemo` still pre-split under value-only → residual **LPT-795** filed (needs-human; Relates LPT-317).
  - checkpoint `act-07-03-01-checkpoint` SoftPulse `rule` kind `none` densify PRESENT under Choose-river-value-only → residual **LPT-796** filed (needs-human; Relates LPT-317/795).
  - successors `act-07-03-01-02-explain-blockers` (BLOCKER→FEWER CALLS) + `act-07-03-01-03-explain-check` (NO STORY→CHECK) content-driven; guided SoftPulse `val` densify N/A (`poker_action_sizing` fixed+variants); scaffolded SoftPulse `block` one-per-press densify PRESENT; unguided SoftPulse `check` one-per-press densify PRESENT.
- Curriculum **LPT-317** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-795/796/317/794/790/721; leave open LPT-676…796; leave ui-agent alone.
- Prefer next: NEVER `lesson-07-04-01-*` pot-type-plans / Low residuals LPT-676…796 / Low curriculum LPT-351.
- act-07-03-01-*: interactive structural clean on tip except LPT-795 SoftPulse + LPT-796 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); scaffolded/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; guided fixed+variants — do not reopen LPT-627.

## Fold 2026-10-14fr (dafb448c Prefer NEVER pot-type SoftPulse + Ranges-SPR checkpoint residuals)

- Tip-stable `dafb448c` (#2408 Compose SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-07-04-01-01/02/03` under Plans by pot type unit (`unit-07-04-pot-types`):
  - first-child `act-07-04-01-explain` SoftPulse LIMPED→SRP→3-4BET + `explainGrading` "Limped → SRP → 3-bet/4-bet." + Dart `PotTypePlansDemo` still pre-split under limped-only → residual **LPT-798** filed (needs-human; Relates LPT-320).
  - checkpoint `act-07-04-01-checkpoint` SoftPulse `both` kind `none` densify PRESENT ("Ranges and SPR" / prompt "Pot type changes?") under Plan 3-bet/4-bet-only → residual **LPT-799** filed (needs-human; Relates LPT-320/798).
  - successors `act-07-04-01-02-explain-srp` (HEADS-UP→C-BET) + `act-07-04-01-03-explain-bigpots` (LOW SPR→COMMIT) content-driven; guided SoftPulse `nuts` densify PRESENT; scaffolded SoftPulse `cb` one-per-press densify PRESENT; unguided SoftPulse `commit` one-per-press densify PRESENT.
- Curriculum **LPT-320** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-798/799/320/795/796/318; leave open LPT-676…799; leave ui-agent alone.
- Prefer next: NEVER `lesson-07-05-01-*` hu-vs-multiway / Low residuals LPT-676…799 / Low curriculum LPT-351.
- act-07-04-01-*: interactive structural clean on tip except LPT-798 SoftPulse + LPT-799 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14fs (a88f3eb2 Prefer NEVER HU SoftPulse + player-count checkpoint residuals)

- Tip-stable `a88f3eb2` (#2410 pot-type SoftPulse Prefer residuals on tip after #2408). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-07-05-01-01/02/03` under Heads-up versus multiway unit (`unit-07-05-hu-mw`):
  - first-child `act-07-05-01-explain` SoftPulse FEWER→THICKER→WIDEN + `explainGrading` "Fewer → Thicker → Widen." + Dart `HuVsMultiwayDemo` still pre-split under bluff-less-only → residual **LPT-800** filed (needs-human; Relates LPT-323).
  - checkpoint `act-07-05-01-checkpoint` SoftPulse `input` kind `none` densify PRESENT ("Player count is?" / tile "A first-class planning input") under Bluff-less-only → residual **LPT-801** filed (needs-human; Relates LPT-323/800).
  - successors `act-07-05-01-02-explain-value` (MULTIWAY→THICK VALUE) + `act-07-05-01-03-explain-hu` (HEADS-UP→STEAL MORE) content-driven; guided SoftPulse `no` densify PRESENT; unguided SoftPulse `thick` one-per-press densify PRESENT; scaffolded SoftPulse `higher` one-per-press densify PRESENT.
- Curriculum **LPT-323** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-800/801/323/798/799/795/796/351/318; leave open LPT-676…801; leave ui-agent alone.
- Prefer next: NEVER `lesson-07-06-01-*` stack-depth-plans / Low residuals LPT-676…801 / Low curriculum LPT-351.
- act-07-05-01-*: interactive structural clean on tip except LPT-800 SoftPulse + LPT-801 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14ft (459a7565 Prefer NEVER stack SoftPulse residual LPT-802)

- Tip-stable `459a7565` (#2411 HU SoftPulse Prefer residuals on tip after #2410). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-07-06-01-01/02/03` under Rewrite plans when stacks change unit:
  - first-child `act-07-06-01-explain` SoftPulse SHORT→DEEP→EFFECTIVE + `explainGrading` "Short → Deep → Effective." + Dart `StackDepthPlansDemo` / `LessonStackDepthPlansExplainTable` still pre-split under commit-short-only → residual **LPT-802** filed (needs-human; Relates LPT-326).
  - checkpoint `act-07-06-01-checkpoint` SoftPulse `every` kind `none` densify PRESENT ("Stack depth is?" / "Recalculated every hand") under recalc-effective matches — *no companion residual*.
  - successors `act-07-06-01-02-explain-deep` (DEEP→IMPLIED ODDS) + `act-07-06-01-03-explain-effective` (SHORTER STACK→PLAN) content-driven; guided SoftPulse `commit` densify PRESENT; scaffolded SoftPulse `yes` one-per-press densify PRESENT; unguided SoftPulse `40` one-per-press densify PRESENT.
- Curriculum **LPT-326** Done — do not clone / do not re-add needs-human. Distinct from S2 residual **LPT-748** (BbStackDepthDemo).
- Tip-commented LPT-802/326/198/216/800/801/748/351; leave open LPT-676…802; leave ui-agent **LPT-797** alone.
- Prefer next: NEVER `lesson-07-07-01-*` same-cards-types / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-06-01-*: interactive structural clean on tip except LPT-802 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14fu (71095593 Prefer NEVER same-cards SoftPulse residual LPT-725 re-check)

- Tip-stable `71095593` (#2412 stack SoftPulse Prefer residual LPT-802 on tip after #2411). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-07-07-01-01/02/03/04` under Same-hand / Replay-by-type unit:
  - first-child `act-07-07-01-explain` SoftPulse CARDS→MODELS→CITE + `explainGrading` "Cards → Models → Cite." still pre-split under station-value (objective still unit string) → residual **LPT-725** still To Do (needs-human; Relates LPT-330; do not clone Duplicate LPT-728).
  - checkpoint `act-07-07-01-checkpoint` SoftPulse `base` kind `none` under baseline-without-evidence matches — *no companion residual*.
  - successors TAG CHECK-RAISE→CAREFUL / LAG BARREL→CALL / NO EVIDENCE→BASELINE content-driven; guided SoftPulse `bet` fixed+variants; scaffolded SoftPulse `fold`; unguided SoftPulse `call`.
- Curriculum **LPT-330** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-725/330/198/216/802; leave open LPT-676…802; leave ui-agent **LPT-797** alone.
- Prefer next: NEVER `lesson-07-08-01-*` type-board / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-07-01-*: interactive structural clean on tip except LPT-725 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669).

## Fold 2026-10-14fv (d6f2c68a Prefer NEVER type-board SoftPulse residual LPT-726 re-check)

- Tip-stable `d6f2c68a` (#2413 same-cards SoftPulse Prefer re-check on tip after #2412). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-07-08-01-01/02/03` under Integrate type/board/line/sizing unit:
  - first-child `act-07-08-01-explain` SoftPulse TYPE→BOARD→LINE→SIZE + `explainGrading` still pre-split under type-and-board-only → residual **LPT-726** still To Do (needs-human; Relates LPT-333; do not clone Duplicate LPT-729).
  - successors LINE→SIZE / FOUR INPUTS→ONE ACTION content-driven; guided SoftPulse `call` fixed+variants; scaffolded SoftPulse `raise`; unguided SoftPulse `fold`; checkpoint SoftPulse `four` kind `none` under one-coherent-action — no new companion clone.
- Curriculum **LPT-333** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-726/333/198/216/725; leave open LPT-676…802; leave ui-agent **LPT-797** alone.
- Prefer next: NEVER `lesson-07-09-01-*` leak-review-book / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-08-01-*: interactive structural clean on tip except LPT-726 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669).

## Fold 2026-10-14fw (1636d664 Prefer NEVER leak SoftPulse residual LPT-727 re-check)

- Tip-stable `1636d664` (#2415 after #2414 type-board SoftPulse Prefer re-check). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-07-09-01-01/02/03` under Strategy-book / leak-review unit:
  - first-child `act-07-09-01-explain` SoftPulse LEAK→BOOK→REVIEW + `explainGrading` still pre-split under name-leaks-only → residual **LPT-727** still To Do (needs-human; Relates LPT-336; do not clone Duplicate LPT-730).
  - successors COMMON SPOT→DEFAULT / AFTER SESSION→REVIEW content-driven; guided SoftPulse `spec` densify PRESENT; scaffolded SoftPulse `book`; unguided SoftPulse `sched`; checkpoint SoftPulse `base` under default-lines — no new companion clone.
- Curriculum **LPT-336** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-727/336/198/216/726; leave open LPT-676…802; leave ui-agent alone (LPT-797 #2415).
- Prefer next: NEVER Capstone `lesson-07-10-0*` / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-09-01-*: interactive structural clean on tip except LPT-727 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669).

## Fold 2026-10-14fx (8e376e17 Prefer NEVER Capstone lesson-07-10-0* clean)

- Tip-stable `8e376e17` (#2416 leak SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER Capstone `lesson-07-10-01-capstone-srp` / `02-capstone-3bet` / `03-capstone-multiway-deep` / `04-capstone-limped` / `05-capstone-4bet`:
  - explains SoftPulse + `explainGrading` concept-aligned (PLAN→UPDATE→FINISH / SPR→TURN→CLOSE / NUTS→DEEP→NO-BLUFF / NUTS→VALUE→THIN / SPR→COMMIT→NO HERO); `deal.mode` `none`.
  - hands `authored_multi_step_hand` scaffolded + `assessmentRole` `transfer` + empty pressHints in `NO_HINT_ACTIVITY_IDS` — **LPT-348** Done (do not reopen LPT-626/667).
  - `deal.mode` `fixed` + 2 suit variants match Dart `resolveToyHandStepSpot` (Ah/Qd·Kc7s2h2d9c; Ah/Qd·Qs8h3d2d7c; Ah/Qh·Jh8h2c3d9c; Ah/Kh·Kd9c4h2s8d; Kh/Kd·Qs8h3d2dAd).
  - Synthesis containers in `unit-07-10-capstones` — skip curriculum-split; no SoftPulse residual (not a post-split child leak).
- Tip-commented Done-ack LPT-348/337/339/341/345/347 + leave-open LPT-351/727; leave open LPT-676…802; leave ui-agent alone.
- Prefer next: NEVER `lesson-07-11-01-*` live-warmup / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-10-0*: structural **clean** on tip (transfer policy + deal honesty hold).

## Fold 2026-10-14fy (9d5adca8 Prefer NEVER live-warmup + Final clean; S7 SoftPulse path complete)

- Tip-stable `9d5adca8` (#2418 after #2417 Capstone Prefer NEVER clean). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Discovery Prefer NEVER `lesson-07-11-01-live-warmup-prep`: still one lesson id (not split) — SoftPulse CHECKLIST→DEFAULTS→ONE HAND + `explainGrading` matches packed three objectives; *SoftPulse residual N/A* until curriculum **LPT-351** lands children; guided/scaffolded/unguided/checkpoint densify PRESENT; teachSpec **LPT-349** Done.
- Curriculum **LPT-351** still To Do (needs-human) — tip-commented; do not clone SoftPulse residual stem pre-split.
- Discovery Prefer NEVER `lesson-07-12-01-five-type-final`: all seven acts scaffolded + `assessmentRole` checkpoint; SoftPulse cues kind `none`; densify PRESENT; hintless — structural **clean** (assessment container; skip curriculum-split; **LPT-352** Done).
- Tip-commented LPT-351/349/352/348/198/216/727; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER oldest open SoftPulse residual re-check (LPT-676…802) / Low curriculum LPT-351.
- S7 Prefer NEVER SoftPulse residual path complete through Capstone + warm-up + Final.

## Fold 2026-10-14fz (a7f410bd Prefer NEVER Estimate SoftPulse residual LPT-681 re-check)

- Tip-stable `a7f410bd` (#2419 after S7 Prefer NEVER SoftPulse path complete). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER oldest SoftPulse residual re-check `lesson-05-03-01-01/02/03`: first-child SoftPulse IMPLIED→REVERSE→SECOND still pre-split under estimate-only → residual **LPT-681** still To Do (needs-human; Relates LPT-230); successors content-driven; curriculum **LPT-230** Done.
- Tip-commented LPT-681/230/198/216; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Thin SoftPulse residual **LPT-682** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14ga (d34c81b3 Prefer NEVER Thin SoftPulse residual LPT-682 re-check)

- Tip-stable `d34c81b3` (#2420 Estimate SoftPulse Prefer re-check LPT-681 on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Thin SoftPulse residual re-check `lesson-05-04-01-01/02/03`:
  - first-child SoftPulse THIN→CATCH→BARRELS + Dart `ThinValueDemo` / `CoachDialogueVisualKind.thinValue` still pre-split under thin-value-only → residual **LPT-682** still To Do (needs-human; Relates LPT-233).
  - companion checkpoint SoftPulse `read` meta-read densify PRESENT under Thin → residual **LPT-683** still To Do (needs-human).
  - successors MANIAC→BARREL→CALL / NIT→FOLDS→CHECK content-driven (do not reopen LPT-669).
  - guided SoftPulse `tv` PRESENT (`Jh`/`9d`·`Kc`/`9s`/`4h`/`2d`/`7c` +2 suit variants; maps PRESENT); scaffolded SoftPulse `call-m` + unguided SoftPulse `check-nit` one-per-press PRESENT.
- Curriculum **LPT-233** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-682/683/233/198/216/681/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Lines SoftPulse residual **LPT-684** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-04-01-*: interactive structural clean on tip except LPT-682 SoftPulse + LPT-683 checkpoint residuals.

## Fold 2026-10-14gb (e5286022 Prefer NEVER Lines SoftPulse residual LPT-684 re-check)

- Tip-stable `e5286022` (#2422 after #2421 Thin SoftPulse Prefer re-check). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Lines SoftPulse residual re-check `lesson-05-05-01-01/02/03`: first-child SoftPulse X/R→PROBE→DELAY→DONK + Dart `LineStoriesDemo` still pre-split under check-raises-only → residual **LPT-684** still To Do (needs-human; Relates LPT-236); successors content-driven; checkpoint SoftPulse `delay` under probes-and-delays — no companion residual; curriculum **LPT-236** Done.
- Tip-commented LPT-684/236/198/216/682; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Timing SoftPulse residual **LPT-685** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14gc (964cd956 Prefer NEVER Timing SoftPulse residual LPT-685 re-check)

- Tip-stable `964cd956` (#2423 Lines SoftPulse Prefer re-check). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Timing SoftPulse residual re-check `lesson-05-07-01-01/02/03`: first-child SoftPulse TIMING→SIZING→CLUES + Dart `TimingCluesDemo` still pre-split under timing-soft-only → residual **LPT-685** still To Do (needs-human; Relates LPT-244); successors content-driven; checkpoint SoftPulse `tiny` under timing-soft — no companion residual; curriculum **LPT-244** Done.
- Tip-commented LPT-685/244/198/216/684; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Dynamics SoftPulse residual **LPT-686** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.


## Fold 2026-10-14gd (b36d5d16 Prefer NEVER Dynamics SoftPulse residual LPT-686/687 re-check)

- Tip-stable `b36d5d16` (#2424 Timing SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Dynamics SoftPulse residual re-check `lesson-05-08-01-01/02/03`: first-child SoftPulse STUCK→TILTED→GEARS + Dart `TablesChangeDemo` still pre-split under tilted/stuck-only → residual **LPT-686** still To Do (needs-human; Relates LPT-247); companion checkpoint SoftPulse `temp` kind `none` densify PRESENT under Gear changes → residual **LPT-687** still To Do; successors GEAR→CHANGE→SAMPLE / COOLER→CHASE→RESET content-driven (do not reopen LPT-669); guided SoftPulse `stuck` densify PRESENT; scaffolded SoftPulse `gear` densify PRESENT; unguided SoftPulse `reset` one-per-press PRESENT (`Jh`/`Td`·`Kc`/`9s`/`4h`/`2d`/`7c` +2 suit variants match Dart; SoftPulse map PRESENT); curriculum **LPT-247** Done.
- Tip-commented LPT-686/687/247/198/216/685/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Session SoftPulse residual **LPT-690** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14ge (64190441 Prefer NEVER Session SoftPulse residual LPT-690 re-check)

- Tip-stable `64190441` (#2425 Dynamics SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Session SoftPulse residual re-check `lesson-05-09-01-01/02/03`: first-child SoftPulse QUIT→GUARD→FIRST + Dart `GuardrailsDemo` still pre-split under stop-loss-only → residual **LPT-690** still To Do (needs-human; Relates LPT-250); companion checkpoint SoftPulse `edge` under end-sessions → residual **LPT-691** still To Do; successors content-driven; curriculum **LPT-250** Done.
- Tip-commented LPT-690/691/250/198/216; leave open LPT-676…802 + LPT-351; leave ui-agent alone. Rescued after conflicting draft #2426.
- Prefer next: NEVER Range SoftPulse residual **LPT-692** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14gf (c5f73f71 Prefer NEVER Range SoftPulse residual LPT-692 re-check)

- Tip-stable `c5f73f71` (#2427 Session SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Range SoftPulse residual re-check `lesson-06-01-01-01/02/03`: first-child SoftPulse RANGE→NUT→ADVANTAGE + Dart `RangeAdvantageDemo` still pre-split under range-advantage-only → residual **LPT-692** still To Do (needs-human; Relates LPT-254); successors content-driven; checkpoint SoftPulse `press` under press-both — no companion residual; curriculum **LPT-254** Done.
- Tip-commented LPT-692/254/198/216/690; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Spot-caps SoftPulse residual **LPT-694** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14gg (cf3ba3ee Prefer NEVER Spot-caps SoftPulse residual LPT-694 re-check)

- Tip-stable `cf3ba3ee` (#2428 Range SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Spot-caps SoftPulse residual re-check `lesson-06-03-01-01/02/03`: first-child SoftPulse CAPPED→UNCAPPED→NUTS + Dart `CappedUncappedDemo` / layout "Tap Capped, Uncapped, and Nuts." still pre-split under spot-caps-only → residual **LPT-694** still To Do (needs-human; Relates LPT-260; race clone LPT-695 Done — do not reopen); successors RAISE→BET→RESPECT / CAPPED→THIN→BLUFF content-driven (do not reopen LPT-669); guided SoftPulse `cap` densify PRESENT; unguided SoftPulse `uncap` one-per-press PRESENT; scaffolded SoftPulse `bet` one-per-press PRESENT (Jh9d/Kc9s4h2d7c + 2 suit variants); checkpoint SoftPulse `attack` kind `none` densify PRESENT (matches attack-caps — no companion residual).
- Curriculum **LPT-260** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-694/260/198/216/696/351/692; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Polar SoftPulse residual **LPT-696** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-03-01-*: interactive structural clean on tip except LPT-694 SoftPulse residual; SoftPulse explain successors content-driven; guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14gh (0f5075d8 Prefer NEVER Polar SoftPulse residual LPT-696 re-check)

- Tip-stable `0f5075d8` (#2430 Spot-caps SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Polar SoftPulse residual re-check `lesson-06-04-01-01/02/03`: first-child SoftPulse POLAR→MERGED→SIZE + Dart `PolarMergedDemo` still pre-split under polarized-sizing-only → residual **LPT-696** still To Do (needs-human; Relates LPT-264); successors content-driven; checkpoint SoftPulse `thin` under merged-thin-value — no companion residual; curriculum **LPT-264** Done.
- Tip-commented LPT-696/264/198/216/694; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Overbet SoftPulse residual **LPT-699** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14gi (23915807 Prefer NEVER Overbet SoftPulse residual LPT-699 re-check)

- Tip-stable `23915807` (#2432 Polar SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Overbet SoftPulse residual re-check `lesson-06-05-01-01/02/03`: first-child SoftPulse OVERBET→POLAR→GEO + Dart `OverbetGeometryDemo` still pre-split under polar-overbets-only → residual **LPT-699** still To Do (needs-human; Relates LPT-267; race clone LPT-698 Done); successors content-driven; checkpoint SoftPulse `multi` under geometric-sizes — no companion residual; curriculum **LPT-267** Done.
- Tip-commented LPT-699/267/198/216/696; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Blockers SoftPulse residual **LPT-700** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14gj (7500cbdc Prefer NEVER Blockers SoftPulse residual LPT-700 re-check)

- Tip-stable `7500cbdc` (#2433 Overbet SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Blockers SoftPulse residual re-check `lesson-06-06-01-01/02/03`: first-child SoftPulse BLOCK→USE→NO EV + Dart `BlockersDemo` still pre-split under bluff-blockers-only → residual **LPT-700** still To Do (needs-human; Relates LPT-270); successors content-driven; checkpoint SoftPulse `no` under no-fake-ev — no companion residual; curriculum **LPT-270** Done.
- Tip-commented LPT-700/270/198/216/699; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Defend SoftPulse residual **LPT-701** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14gk (64a2e153 Prefer NEVER Defend SoftPulse residual LPT-701 re-check)

- Tip-stable `64a2e153` (#2434 Blockers SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Defend SoftPulse residual re-check `lesson-06-07-01-01/02/03`: first-child SoftPulse DEFEND→BLUFF→ENOUGH + Dart `DefendEnoughDemo` / `LessonDefendEnoughExplainTable` still pre-split under continue-catchers-only → residual **LPT-701** still To Do (needs-human; Relates LPT-273); companion checkpoint SoftPulse `punish` under continue-catchers → **LPT-702** still To Do; successors THIRD PAIR→SCARY→FOLD / MDF→INTUITION content-driven; guided SoftPulse `strong` densify PRESENT; scaffolded SoftPulse `fold` one-per-press PRESENT (`9h`/`7d`·`Kc`/`Qh`/`9d`/`4c`/`8s` +2 suit variants match Dart); unguided SoftPulse `int` densify PRESENT; curriculum **LPT-273** Done.
- Tip-commented LPT-701/702/273/198/216/700/703; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Mix SoftPulse residual **LPT-703** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-07-01-*: interactive structural clean on tip except LPT-701 SoftPulse + LPT-702 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants third-pair honesty.

## Fold 2026-10-14gl (fb309084 Prefer NEVER Mix SoftPulse residual LPT-703 re-check)

- Tip-stable `fb309084` (#2435 Defend SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Mix SoftPulse residual re-check `lesson-06-08-01-01/02/03`: first-child SoftPulse MIX→PURPOSE→STRONG + Dart `MixedStrategyDemo` still pre-split under mix-strong-only → residual **LPT-703** still To Do (needs-human; Relates LPT-277); successors content-driven; checkpoint SoftPulse `freq` under no-pure-random — no companion residual; curriculum **LPT-277** Done.
- Tip-commented LPT-703/277/198/216/701; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Plan-3bet SoftPulse residual **LPT-704** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14gm (684d8b10 Prefer NEVER Plan-3bet SoftPulse residual LPT-704 re-check)

- Tip-stable `684d8b10` (#2436 Mix SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Plan-3bet SoftPulse residual re-check `lesson-06-09-01-01/02/03`: careful-4bet SoftPulse 4BET→STRONG→CAREFUL content-driven + guided SoftPulse `careful` densify PRESENT; **middle-child** `act-06-09-01-explain` SoftPulse 3BET→4BET→DEPTH + Dart `ThreeBetFourBetSprDemo.points` 3BET/4BET/DEPTH still pre-split under plan-3bet-spr → residual **LPT-704** still To Do (needs-human; Relates LPT-282); scaffolded SoftPulse `small` one-per-press PRESENT (`Ah`/`Qd`·`8c`/`3h`/`2s` +2 suit variants; Dart `stackLabel` Stacks left 360 match); checkpoint SoftPulse `spr` kind `none` densify PRESENT under plan-3bet-spr — no companion residual; ego SoftPulse 4BET→EGO→AVOID content-driven + unguided SoftPulse `avoid` one-per-press densify PRESENT (do not reopen LPT-669); curriculum **LPT-282** Done.
- Tip-commented LPT-704/282/198/216/703/705/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Hard-folds SoftPulse residual **LPT-705** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-09-01-*: interactive structural clean on tip except LPT-704 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants AQo-miss honesty.

## Fold 2026-10-14gn (4d09e7c2 Prefer NEVER Hard-folds SoftPulse residual LPT-705 re-check)

- Tip-stable `4d09e7c2` (#2438 SoftPulse-off densify after #2437 Plan-3bet Prefer on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Hard-folds SoftPulse residual re-check `lesson-06-10-01-01/02/03`: first-child SoftPulse HARD→COOLER→EGO + Dart `HardFoldCoolerDemo` still pre-split under hard-folds-only → residual **LPT-705** still To Do (needs-human; Relates LPT-285 — do not re-add needs-human on curriculum); successors content-driven; checkpoint SoftPulse `ask` under cooler-or-mistake — no companion residual; curriculum **LPT-285** Done.
- Tip-commented LPT-705/285/198/216/704; leave open LPT-676…802 + LPT-351; leave ui-agent LPT-803/804/805 alone.
- Prefer next: NEVER Selective SoftPulse residual **LPT-706** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.


## Fold 2026-10-14go (46f3e682 Prefer NEVER Selective SoftPulse residual LPT-706 re-check)

- Tip-stable `46f3e682` (#2439 Hard-folds SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Selective SoftPulse residual re-check `lesson-06-11-01-01/02/03`: first-child SoftPulse TIGHT→BARREL→SAMPLE + Dart `SelectiveAggressionDemo.points` TIGHT/BARREL/SAMPLE still pre-split under selective-entry-only → residual **LPT-706** still To Do (needs-human; Relates LPT-288 — do not re-add needs-human on curriculum); successors content-driven; checkpoint SoftPulse `bundle` under wait-for-samples — no companion residual; curriculum **LPT-288** Done.
- Tip-commented LPT-706/288/198/216/705/708; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Meet-TAG working-model residual **LPT-708** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-01-*: interactive structural clean on tip except LPT-706 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` observation tiles — do not file handFamily.


## Fold 2026-10-14gp (b26f0f32 Prefer NEVER Meet-TAG working-model residual LPT-708 re-check)

- Tip-stable `b26f0f32` (#2440 Selective SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Meet-TAG working-model residual re-check `lesson-06-11-02-01/02/03`: SoftPulse TIGHT→AGGRO→MODEL + Dart `TagModelDemo.points` TIGHT/AGGRO/MODEL **concept-aligned** under Introduce TAG / The TAG model (not SoftPulse residual); checkpoint SoftPulse `model` kind `none` densify PRESENT (prompt "TAG is?" / Working model vs Insult) still grades working-model-vs-insult under Introduce TAG-only → residual **LPT-708** still To Do (needs-human; Relates LPT-291 — do not re-add needs-human on curriculum); successors FOLDS MOST→PLANNED BARRELS / ENTRY WIDTH→DISCIPLINE content-driven; guided SoftPulse `tag` densify PRESENT; scaffolded SoftPulse `diff` one-per-press densify PRESENT; unguided SoftPulse `tag2` one-per-press densify PRESENT; curriculum **LPT-291** Done.
- Tip-commented LPT-708/291/198/216/706/709/710/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Adjust-TAG SoftPulse residual **LPT-709** (+ cite **LPT-710**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-02-*: interactive structural clean on tip except LPT-708 working-model residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` player-type tiles — do not file handFamily.


## Fold 2026-10-14gq (1c267bb1 Prefer NEVER Adjust-TAG SoftPulse residual LPT-709 re-check)

- Tip-stable `1c267bb1` (#2441 Meet-TAG working-model Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Adjust-TAG SoftPulse residual re-check `lesson-06-11-03-01/02/03`: first-child SoftPulse CREDIT→TIGHTER→NO LIGHT + `explainGrading` "Credit → Tighter → No light." + Dart `VsTagsDemo` / `LessonVsTagsExplainTable` (NO LIGHT "Skip fancy XR") still pre-split under Respect-TAG-aggression-only → residual **LPT-709** still To Do (needs-human; Relates LPT-294 — do not re-add needs-human on curriculum); checkpoint SoftPulse `cite` kind `none` densify PRESENT (`tagRespectCiteOutcomes` / helper "Versus TAG — pick the cite.") still under Respect-only → residual **LPT-710** still To Do (needs-human; Relates LPT-294); successors CHECK-RAISE→FOLD / RARELY CALLS→CHECK content-driven; guided SoftPulse `fold` PRESENT (`Jh`/`9d`·`Qc`/`9s`/`3h` +2 suit variants); scaffolded SoftPulse `fold-k9` one-per-press PRESENT (`Kh`/`9d` +2 suit variants); unguided SoftPulse `check` one-per-press PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants); curriculum **LPT-294** Done.
- Tip-commented LPT-709/710/294/708/713/351/198/216; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Observe-wide SoftPulse residual **LPT-713** (+ **LPT-714** / **LPT-715**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-03-*: interactive structural clean on tip except LPT-709 SoftPulse + LPT-710 cite residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive sizing acts are `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` cite tiles — do not file handFamily.

## Fold 2026-10-14gr (bfac7fcb Prefer NEVER Observe-wide SoftPulse residual LPT-713 re-check)

- Tip-stable `bfac7fcb` (#2442 Adjust-TAG SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Observe-wide SoftPulse residual re-check `lesson-06-12-01-01/02/03`: first-child SoftPulse WIDE→PRESSURE→SAMPLE + `explainGrading` "Wide → Pressure → Sample." + Dart `WidePressureDemo` / `LessonWidePressureExplainTable` (PRESSURE "Barrels with a plan" / SAMPLE "Count first") still pre-split under Note-wide-entry-only → residual **LPT-713** still To Do (needs-human; Relates LPT-297 — do not re-add needs-human on curriculum); companion unguided SoftPulse `wait` Keep sampling (`lagObserveSampleOutcomes`) under Note sustained pressure → residual **LPT-714** still To Do; companion checkpoint SoftPulse `bundle` kind `none` densify PRESENT (`lagObserveBundleOutcomes`) under Planned-not-maniac → residual **LPT-715** still To Do; successors BARRELS→MANY HANDS / FOLDS SOMETIMES→PLAN content-driven; guided SoftPulse `wide` densify PRESENT (`lagObserveGuidedOutcomes`); scaffolded SoftPulse `sep` one-per-press densify PRESENT (`lagObserveDiscOutcomes`); curriculum **LPT-297** Done.
- Tip-commented LPT-713/714/715/297/198/216/709/716/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone (LPT-803/804/805 Done).
- Prefer next: NEVER Meet-LAG sample-limits residual **LPT-716** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-01-*: interactive structural clean on tip except LPT-713 SoftPulse + LPT-714 unguided + LPT-715 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14gs (250b3599 Prefer NEVER Meet-LAG sample-limits residual LPT-716 re-check)

- Tip-stable `250b3599` (#2443 Observe-wide SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Meet-LAG sample-limits residual re-check `lesson-06-12-02-01/02/03`: SoftPulse WIDE→PRESSURE→MODEL + `explainGrading` "Wide → Pressure → Model." + Dart `LagModelDemo.points` WIDE/PRESSURE/MODEL **concept-aligned** under Introduce LAG / The LAG model (not SoftPulse residual); checkpoint SoftPulse `limits` kind `none` densify PRESENT (prompt "Show beside LAG label?" / Sample limits vs Destiny) still grades sample-limits under Introduce LAG-only → residual **LPT-716** still To Do (needs-human; Relates LPT-300 — do not re-add needs-human on curriculum); successors WIDE OPENS→BARRELS / RAISES→CALLS content-driven; guided SoftPulse `lag` densify PRESENT; scaffolded SoftPulse `diff` one-per-press densify PRESENT; unguided SoftPulse `lag2` one-per-press densify PRESENT; curriculum **LPT-300** Done.
- Tip-commented LPT-716/300/198/216/713/718/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Adjust-LAG SoftPulse residual **LPT-718** (+ cite **LPT-719**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-02-*: interactive structural clean on tip except LPT-716 sample-limits checkpoint residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` player-type tiles — do not file handFamily.

## Fold 2026-10-14gt (0b2a8264 Prefer NEVER Adjust-LAG SoftPulse residual LPT-718 re-check)

- Tip-stable `0b2a8264` (#2444 Meet-LAG sample-limits Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Adjust-LAG SoftPulse residual re-check `lesson-06-12-03-01/02/03`: first-child SoftPulse CALL→TRAP→FANCY LESS + `explainGrading` "Call → Trap → Fancy less." + Dart `VsLagsDemo` / `LessonVsLagsExplainTable` still pre-split under Call-wider-only → residual **LPT-718** still To Do (needs-human; Relates LPT-303 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `cite` kind `none` densify PRESENT under Call-wider → residual **LPT-719** still To Do; successors STRONG HAND→LET THEM BET / NO BIG BLUFF→LET THEM content-driven; guided SoftPulse `call` PRESENT; scaffolded SoftPulse `trap` one-per-press PRESENT; unguided SoftPulse `avoid` one-per-press densify PRESENT; curriculum **LPT-303** Done.
- Tip-commented LPT-718/719/303/198/216/716/721/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Mix-five SoftPulse residual **LPT-721** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-03-*: interactive structural clean on tip except LPT-718 SoftPulse + LPT-719 cite residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded sizing acts match Dart deal honesty — do not reopen LPT-627.

## Fold 2026-10-14gu (2aa5692d Mix-five SoftPulse Prefer re-check)

- Tip-stable `2aa5692d` (#2445 Adjust-LAG SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232** flat (densify-tap still **0** — no LPT-628 reopen). Catalog parents Done — no open-parent sync.
- Grep `act-06-13-01-*` / `lesson-06-13-01-*` before file: Mix five / Same cards post **LPT-306** Done; SoftPulse residual **LPT-721**; deal.mode none explain + fixed+variants interactives; checkpoint cite tiles.
- Discovery Prefer NEVER `lesson-06-13-01-01/02/03/04`:
  - first-child `act-06-13-01-explain` SoftPulse CARDS→SEATS→EVIDENCE + Dart `ExploitEvidenceDemo` / `LessonExploitEvidenceExplainTable` still under Station-thin-only → **LPT-721** still To Do (needs-human; Relates LPT-306 — do not re-add needs-human on curriculum).
  - successors `act-06-13-01-02-explain-nit` NIT CHECK-RAISE→FOLD + `act-06-13-01-03-explain-lag` LAG BARREL→CALL + `act-06-13-01-04-explain-cite` TENDENCY→LINE content-driven (do not reopen LPT-669).
  - guided SoftPulse `cs` SoftPulse map PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants match Dart); scaffolded SoftPulse `nit` one-per-press SoftPulse map PRESENT; unguided SoftPulse `lag` one-per-press SoftPulse map PRESENT (poker_action_sizing — densify N/A); checkpoint SoftPulse `tag` kind `none` densify PRESENT under cite-tendency — no companion residual.
- Curriculum **LPT-306** Done — do not clone. Tip-commented LPT-721/306/198/216/718/790/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER preflop-to-flop SoftPulse residual **LPT-790** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14gv (f01c7700 Prefer NEVER preflop-to-flop SoftPulse residual LPT-790 re-check)

- Tip-stable `f01c7700` (#2446 Mix-five SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER preflop-to-flop SoftPulse residual re-check `lesson-07-01-01-01/02/03`: first-child SoftPulse REASON→CONFIRM→CANCEL + `explainGrading` "Reason → Confirm → Cancel." + Dart `PreflopFlopPlanDemo` / `LessonPreflopFlopPlanExplainTable` still pre-split under State-a-preflop-thesis-only → residual **LPT-790** still To Do (needs-human; Relates LPT-310 — do not re-add needs-human on curriculum); successors TEXTURE→CONFIRM OR CANCEL / DEAD PLAN→LET GO content-driven; guided SoftPulse `dead` densify PRESENT; scaffolded SoftPulse `value` densify PRESENT; unguided SoftPulse `thesis` densify PRESENT; checkpoint SoftPulse `abandon` kind `none` densify PRESENT under abandon — no companion residual; curriculum **LPT-310** Done.
- Tip-commented LPT-790/310/198/216/721/794/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Map SoftPulse residual **LPT-794** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-01-01-*: interactive structural clean on tip except LPT-790 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); interactives `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-14gw (1be57926 Prefer NEVER Map SoftPulse residual LPT-794 re-check)

- Tip-stable `1be57926` (#2448 preflop-to-flop SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Map SoftPulse residual re-check `lesson-07-02-01-01/02/03`: first-child SoftPulse BARREL→GIVE-UP→MAP + `explainGrading` "Barrel → Give-up → Map." + Dart `TurnMapDemo` / `LessonTurnMapExplainTable` still pre-split under List-turn-continue-cards-only → residual **LPT-794** still To Do (needs-human; Relates LPT-314 — do not re-add needs-human on curriculum); successors BRICK→GIVE UP / CONTINUE→GIVE-UP→MAP content-driven; guided SoftPulse `ok` densify PRESENT; scaffolded SoftPulse `give` one-per-press densify PRESENT; unguided SoftPulse `avoid` one-per-press densify PRESENT; checkpoint SoftPulse `list` kind `none` densify PRESENT under map — no companion residual; curriculum **LPT-314** Done.
- Tip-commented LPT-794/314/198/216/790/795/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Compose SoftPulse residual **LPT-795** (+ rule **LPT-796**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-02-01-*: interactive structural clean on tip except LPT-794 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); interactives `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-14gx (6fbd04c9 Prefer NEVER Compose SoftPulse residual LPT-795 re-check)

- Tip-stable `6fbd04c9` (#2449 Map SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Compose SoftPulse residual re-check `lesson-07-03-01-01/02/03`: first-child SoftPulse VALUE→BLUFF→HOLD + `explainGrading` "Value → Bluff → Hold." + Dart `RiverCompositionDemo` still pre-split under Choose-river-value-only → residual **LPT-795** still To Do (needs-human; Relates LPT-317 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `rule` kind `none` densify PRESENT under value-only → **LPT-796** still To Do; successors BLOCKER→FEWER CALLS / NO STORY→CHECK content-driven; guided SoftPulse `val` PRESENT (poker_action_sizing densify N/A); scaffolded SoftPulse `block` one-per-press densify PRESENT; unguided SoftPulse `check` one-per-press densify PRESENT; curriculum **LPT-317** Done.
- Tip-commented LPT-795/796/317/198/216/794/798/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Pot SoftPulse residual **LPT-798** (+ ranges/SPR **LPT-799**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-03-01-*: interactive structural clean on tip except LPT-795 SoftPulse + LPT-796 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); scaffolded/unguided/checkpoint `deal.mode` `none` — do not file handFamily; guided fixed+variants — do not reopen LPT-627.

## Fold 2026-10-14gy (ac925bfc Prefer NEVER Pot SoftPulse residual LPT-798 re-check)

- Tip-stable `ac925bfc` (#2450 Compose SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Pot SoftPulse residual re-check `lesson-07-04-01-01/02/03`: first-child SoftPulse LIMPED→SRP→3-4BET + `explainGrading` "Limped → SRP → 3-bet/4-bet." + Dart `PotTypePlansDemo` still pre-split under Plan-limped-pots-only → residual **LPT-798** still To Do (needs-human; Relates LPT-320 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `both` kind `none` densify PRESENT ("Ranges and SPR" / prompt "Pot type changes?") under Plan 3-bet/4-bet-only → **LPT-799** still To Do; successors HEADS-UP→C-BET / LOW SPR→COMMIT content-driven; guided SoftPulse `nuts` densify PRESENT; scaffolded SoftPulse `cb` one-per-press densify PRESENT; unguided SoftPulse `commit` one-per-press densify PRESENT; curriculum **LPT-320** Done.
- Tip-commented LPT-798/799/320/795/351/800; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER HU SoftPulse residual **LPT-800** (+ player-count **LPT-801**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-04-01-*: interactive structural clean on tip except LPT-798 SoftPulse + LPT-799 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14gz (403179b7 Prefer NEVER HU SoftPulse residual LPT-800 re-check)

- Tip-stable `403179b7` (#2451 Pot SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER HU SoftPulse residual re-check `lesson-07-05-01-01/02/03`: first-child SoftPulse FEWER→THICKER→WIDEN + `explainGrading` "Fewer → Thicker → Widen." + Dart `HuVsMultiwayDemo` still pre-split under Bluff-less-multiway-only → residual **LPT-800** still To Do (needs-human; Relates LPT-323 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `input` kind `none` densify PRESENT ("Player count is?") under bluff-less-only → residual **LPT-801** still To Do; successors MULTIWAY→THICK VALUE / HEADS-UP→STEAL MORE content-driven; guided SoftPulse `no` densify PRESENT; unguided SoftPulse `thick` one-per-press densify PRESENT; scaffolded SoftPulse `higher` one-per-press densify PRESENT; curriculum **LPT-323** Done.
- Tip-commented LPT-800/801/323/198/216/798/802/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Stack SoftPulse residual **LPT-802** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-05-01-*: interactive structural clean on tip except LPT-800 SoftPulse + LPT-801 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14ha (5908fbcd Prefer NEVER Stack SoftPulse residual LPT-802 re-check)

- Tip-stable `5908fbcd` (#2453 HU SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Stack SoftPulse residual re-check `lesson-07-06-01-01/02/03`: first-child SoftPulse SHORT→DEEP→EFFECTIVE + `explainGrading` "Short → Deep → Effective." + Dart `StackDepthPlansDemo` / `LessonStackDepthPlansExplainTable` still pre-split under Commit-earlier-short-only → residual **LPT-802** still To Do (needs-human; Relates LPT-326 — do not re-add needs-human on curriculum); successors DEEP→IMPLIED ODDS / SHORTER STACK→PLAN content-driven; guided SoftPulse `commit` densify PRESENT; scaffolded SoftPulse `yes` densify PRESENT; unguided SoftPulse `40` densify PRESENT; checkpoint SoftPulse `every` kind `none` densify PRESENT under recalc — no companion residual; distinct from S2 **LPT-748**; curriculum **LPT-326** Done.
- Tip-commented LPT-802/326/198/216/800/725/748/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Same-cards SoftPulse residual **LPT-725** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-06-01-*: interactive structural clean on tip except LPT-802 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14hb (eb1b009c Prefer NEVER Same-cards SoftPulse residual LPT-725 re-check)

- Tip-stable `eb1b009c` (#2454 Stack SoftPulse Prefer re-check fold on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Same-cards SoftPulse residual re-check `lesson-07-07-01-01/02/03/04`: first-child SoftPulse CARDS→MODELS→CITE + `explainGrading` "Cards → Models → Cite." + Dart `SameCardsTypesDemo` still pre-split under station-value (objective still unit string "Change lines by type with citations") → residual **LPT-725** still To Do (needs-human; Relates LPT-330 — do not re-add needs-human on curriculum); successors TAG CHECK-RAISE→CAREFUL / LAG BARREL→CALL / NO EVIDENCE→BASELINE content-driven; guided SoftPulse `bet` fixed Ah/Kd·Kc8s3h +2 suit variants match Dart; scaffolded SoftPulse `fold` one-per-press; unguided SoftPulse `call`; checkpoint SoftPulse `base` kind `none` densify PRESENT under baseline-without-evidence — no companion residual; curriculum **LPT-330** Done.
- Tip-commented LPT-725/330/726/802/351/800/801/198/216; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Type-board SoftPulse residual **LPT-726** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-07-01-*: interactive structural clean on tip except LPT-725 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); explain/checkpoint `deal.mode` `none` — do not file handFamily; guided/scaffolded/unguided fixed+variants — do not reopen LPT-627.


## Fold 2026-10-14hc (58c02969 Prefer NEVER Type-board SoftPulse residual LPT-726 re-check)

- Tip-stable `58c02969` (#2456 SoftPulse-off densify after #2455 Same-cards Prefer on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Type-board SoftPulse residual re-check `lesson-07-08-01-01/02/03`: first-child SoftPulse TYPE→BOARD→LINE→SIZE + `explainGrading` "Type → Board → Line → Size." + Dart `TypeBoardLineDemo` / `LessonTypeBoardLineExplainTable` still pre-split under type-and-board-only → residual **LPT-726** still To Do (needs-human; Relates LPT-333 — do not re-add needs-human on curriculum); successors LINE→SIZE / FOUR INPUTS→ONE ACTION content-driven; guided SoftPulse `call` fixed Jh/Td·Kh/Ts/8h/2d +2 suit variants match Dart; scaffolded SoftPulse `raise` one-per-press; unguided SoftPulse `fold` one-per-press; checkpoint SoftPulse `four` kind `none` densify PRESENT under one-coherent-action — no companion residual; curriculum **LPT-333** Done.
- Tip-commented LPT-726/333/727/725/351/802/198/216; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Leak SoftPulse residual **LPT-727** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-08-01-*: interactive structural clean on tip except LPT-726 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); explain/checkpoint `deal.mode` `none` — do not file handFamily; guided/scaffolded/unguided fixed+variants — do not reopen LPT-627.

## Fold 2026-10-14hd (61abd1b6 Prefer NEVER Leak SoftPulse residual LPT-727 re-check)

- Tip-stable `61abd1b6` (#2457 Type-board SoftPulse Prefer re-check on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Leak SoftPulse residual re-check `lesson-07-09-01-01/02/03`: first-child SoftPulse LEAK→BOOK→REVIEW + `explainGrading` "Leak → Book → Review." + Dart `LeakReviewBookDemo` / `LessonLeakReviewBookExplainTable` still pre-split under Name-leaks-only → residual **LPT-727** still To Do (needs-human; Relates LPT-336 — do not re-add needs-human on curriculum); successors COMMON SPOT→DEFAULT / AFTER SESSION→REVIEW content-driven; guided SoftPulse `spec` densify PRESENT; scaffolded SoftPulse `book` densify PRESENT; unguided SoftPulse `sched` densify PRESENT; checkpoint SoftPulse `base` kind `none` densify PRESENT under default-lines — no companion residual; curriculum **LPT-336** Done.
- Tip-commented LPT-727/336/198/216/726/725/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Capstone `lesson-07-10-0*` (synthesis clean) / live-warmup curriculum **LPT-351** / Low residuals LPT-676…802.
- act-07-09-01-*: interactive structural clean on tip except LPT-727 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); interactives densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-14he tip 7fd3a515 (#2458 Leak Prefer → Capstone/warmup/Final Prefer)

- Tip-stable `7fd3a515` after #2458 Leak SoftPulse Prefer re-check. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Prefer NEVER Capstone `lesson-07-10-01…05` re-check: SoftPulse walks concept-aligned under synthesis containers; hands transfer + noHintIds — **LPT-348** Done; no SoftPulse residual; skip curriculum-split.
- Prefer NEVER live-warmup: SoftPulse CHECKLIST→DEFAULTS→ONE HAND matches packed objectives (residual N/A until **LPT-351**); densify PRESENT; LPT-349 Done; **LPT-351** still To Do needs-human.
- Prefer NEVER Final: seven checkpoint cues kind `none` densify PRESENT — clean (LPT-352 Done).
- S7 Prefer NEVER SoftPulse residual re-check path complete through Capstone + warm-up + Final. next: oldest open SoftPulse residual re-check (LPT-676…802) / Low curriculum LPT-351.

## Fold 2026-10-14hf tip 055747ce (#2459 Capstone Prefer → Sizing LPT-676 Prefer)

- Tip-stable `055747ce` after #2459 Capstone/warmup/Final SoftPulse Prefer. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Prefer NEVER Sizing placement residual **LPT-676** re-check: SoftPulse VALUE→PRESSURE→SIZE under Value concept-aligned; polar scaffolded SoftPulse `big` still under Nearby — still To Do needs-human (Relates LPT-179). Successors content-driven; densify PRESENT; curriculum LPT-179 Done — do not clone.
- next: NEVER Estimate SoftPulse residual **LPT-681** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14hg tip 005a144a (#2460 Sizing Prefer → Estimate LPT-681 Prefer)

- Tip-stable `005a144a` after #2460 Sizing placement Prefer LPT-676. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Prefer NEVER Estimate SoftPulse residual **LPT-681** re-check: IMPLIED→REVERSE→SECOND still under estimate-only — still To Do needs-human (Relates LPT-230). Successors content-driven; densify PRESENT; curriculum LPT-230 Done — do not clone.
- next: NEVER Thin SoftPulse residual **LPT-682** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14hh tip 5c40b53d (#2461 Estimate Prefer → Thin LPT-682 Prefer)

- Tip-stable `5c40b53d` after #2461 Estimate SoftPulse Prefer LPT-681. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Prefer NEVER Thin SoftPulse residual **LPT-682** re-check: THIN→CATCH→BARRELS still under thin-value-only — still To Do needs-human (Relates LPT-233). Successors content-driven; densify PRESENT; curriculum LPT-233 Done — do not clone.
- next: NEVER Lines SoftPulse residual **LPT-684** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14hi tip f1127ea6 (#2462 Thin Prefer → Lines LPT-684 Prefer)

- Tip-stable `f1127ea6` after #2462 Thin SoftPulse Prefer LPT-682. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Prefer NEVER Lines SoftPulse residual **LPT-684** re-check: X/R→PROBE→DELAY→DONK still under check-raises-only — still To Do needs-human (Relates LPT-236). Successors content-driven; densify PRESENT; curriculum LPT-236 Done — do not clone.
- next: NEVER Timing SoftPulse residual **LPT-685** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14hj tip 90c78cb2 (#2463 Lines Prefer → Timing LPT-685 Prefer)

- Tip-stable `90c78cb2` after #2463 Lines SoftPulse Prefer LPT-684. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Prefer NEVER Timing SoftPulse residual **LPT-685** re-check: TIMING→SIZING→CLUES still under timing-soft-only — still To Do needs-human (Relates LPT-244). Successors content-driven; densify PRESENT; curriculum LPT-244 Done — do not clone.
- next: NEVER Dynamics SoftPulse residual **LPT-686** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14hk tip 86fce9be (#2464 Timing Prefer → Dynamics LPT-686 Prefer)

- Tip-stable `86fce9be` after #2464 Timing SoftPulse Prefer LPT-685. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Dynamics SoftPulse residual **LPT-686** re-check (`lesson-05-08-01-01/02/03` / `act-05-08-01-*`): first-child SoftPulse STUCK→TILTED→GEARS + Dart `TablesChangeDemo` + coachMedia gears teaser + `explainGrading` "Stuck → Tilted → Gears." still under tilted/stuck-only → still To Do needs-human (Relates LPT-247). Companion `act-05-08-01-checkpoint` SoftPulse `temp` kind `none` densify PRESENT under Gear changes grades Fresh samples → **LPT-687** still To Do. Successors GEAR→CHANGE→SAMPLE / COOLER→CHASE→RESET content-driven (do not reopen LPT-669). Guided SoftPulse `stuck` densify PRESENT; scaffolded SoftPulse `gear` densify PRESENT; unguided SoftPulse `reset` map PRESENT (`Jh`/`Td`·`Kc`/`9s`/`4h`/`2d`/`7c` +2 suit variants match Dart). Curriculum **LPT-247** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-686/687/247/685/690/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- next: NEVER Session SoftPulse residual **LPT-690** (+LPT-691) / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14hl tip 2feb5ca2 (#2465 Dynamics Prefer → Session LPT-690 Prefer)

- Tip-stable `2feb5ca2` after #2465 Dynamics SoftPulse Prefer LPT-686. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Prefer NEVER Session SoftPulse residual **LPT-690** re-check: QUIT→GUARD→FIRST still under stop-loss-only — still To Do needs-human (Relates LPT-250). Companion checkpoint **LPT-691** still To Do. Successors content-driven; densify PRESENT; curriculum LPT-250 Done — do not clone.
- next: NEVER Range SoftPulse residual **LPT-692** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14hm tip 79225d4f (#2467 Session Prefer → Range LPT-692 Prefer)

- Tip-stable `79225d4f` after #2467 Session SoftPulse Prefer LPT-690. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**.
- Prefer NEVER Range SoftPulse residual **LPT-692** re-check: RANGE→NUT→ADVANTAGE still under range-advantage-only — still To Do needs-human (Relates LPT-254). Successors content-driven; densify PRESENT; curriculum LPT-254 Done — do not clone.
- next: NEVER Spot-caps SoftPulse residual **LPT-694** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14hn tip 17eeda21 (Spot-caps SoftPulse Prefer LPT-694)

- Tip-stable `17eeda21` after #2468 Range SoftPulse Prefer on tip. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Spot-caps SoftPulse residual **LPT-694** re-check (`lesson-06-03-01-01/02/03` / `act-06-03-01-*`): first-child SoftPulse CAPPED→UNCAPPED→NUTS + Dart `CappedUncappedDemo` + layout "Tap Capped, Uncapped, and Nuts." still under spot-caps-only → still To Do needs-human (Relates LPT-260). Race clone LPT-695 Done — do not reopen. Successors RAISE→BET→RESPECT / CAPPED→THIN→BLUFF content-driven (do not reopen LPT-669). Guided SoftPulse `cap` densify PRESENT; unguided SoftPulse `uncap` densify PRESENT; scaffolded SoftPulse `bet` map PRESENT (`Jh`/`9d`·`Kc`/`9s`/`4h`/`2d`/`7c` +2 suit variants); checkpoint SoftPulse `attack` kind `none` densify PRESENT.
- Curriculum **LPT-260** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-694/260/692/696/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- next: NEVER Polar SoftPulse residual **LPT-696** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-03-01-*: interactive structural clean on tip except LPT-694 SoftPulse residual; guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded is fixed+variants poker_action_sizing.

## Fold 2026-10-14ho tip 4c574cdf (Polar SoftPulse Prefer LPT-696)

- Tip-stable `4c574cdf` after #2469 Spot-caps SoftPulse Prefer on tip. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **232**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Polar SoftPulse residual **LPT-696** re-check (`lesson-06-04-01-01/02/03` / `act-06-04-01-*`): first-child SoftPulse POLAR→MERGED→SIZE + `explainGrading` "Polar → Merged → Size." + Dart `PolarMergedDemo.points` still under polarized-sizing-only → still To Do needs-human (Relates LPT-264). Successors MERGED→MEDIUM→VALUE / SIZE→SHAPE→MATCH content-driven (do not reopen LPT-669). Guided SoftPulse `polar` densify PRESENT; scaffolded SoftPulse `mid` one-per-press PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants match Dart LPT-395); unguided SoftPulse `mismatch` densify PRESENT; checkpoint SoftPulse `thin` kind `none` densify PRESENT under merged-thin-value — no companion residual.
- Curriculum **LPT-264** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-696/264/699/694/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- next: NEVER Overbet SoftPulse residual **LPT-699** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-04-01-*: interactive structural clean on tip except LPT-696 SoftPulse residual; guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded is fixed+variants poker_action_sizing (second-pair honesty).

## Fold 2026-10-14hp tip f381fe92 (#2470 Polar Prefer → Overbet LPT-699 Prefer)

- Tip-stable `f381fe92` after #2471 densify stem + #2470 Polar SoftPulse Prefer LPT-696. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Prefer NEVER Overbet SoftPulse residual **LPT-699** re-check: OVERBET→POLAR→GEO still under polar-overbets-only — still To Do (Relates LPT-267; race LPT-698 Done). Successors content-driven; densify PRESENT; curriculum LPT-267 Done — do not clone.
- next: NEVER Blockers SoftPulse residual **LPT-700** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14hq tip 675cc433 (#2472 Overbet Prefer → Blockers LPT-700 Prefer)

- Tip-stable `675cc433` after #2472 Overbet SoftPulse Prefer LPT-699. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Prefer NEVER Blockers SoftPulse residual **LPT-700** re-check: BLOCK→USE→NO EV still under bluff-blockers-only — still To Do (Relates LPT-270). Successors content-driven; densify PRESENT; curriculum LPT-270 Done — do not clone.
- next: NEVER Defend SoftPulse residual **LPT-701** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14hr tip b630f923 (#2473 Blockers Prefer → Defend LPT-701 Prefer)

- Tip-stable `b630f923` after #2473 Blockers SoftPulse Prefer LPT-700. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Defend SoftPulse residual re-check `lesson-06-07-01-01/02/03`: first-child SoftPulse DEFEND→BLUFF→ENOUGH + Dart `DefendEnoughDemo` / `LessonDefendEnoughExplainTable` still pre-split under continue-catchers-only → residual **LPT-701** still To Do (needs-human; Relates LPT-273); companion checkpoint SoftPulse `punish` under continue-catchers → **LPT-702** still To Do; successors THIRD PAIR→SCARY→FOLD / MDF→INTUITION content-driven; guided SoftPulse `strong` densify PRESENT; scaffolded SoftPulse `fold` one-per-press PRESENT (`9h`/`7d`·`Kc`/`Qh`/`9d`/`4c`/`8s` +2 suit variants match Dart); unguided SoftPulse `int` densify PRESENT; curriculum **LPT-273** Done.
- Tip-commented LPT-701/702/273/700/703/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Mix SoftPulse residual **LPT-703** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-07-01-*: interactive structural clean on tip except LPT-701 SoftPulse + LPT-702 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants third-pair honesty.


## Fold 2026-10-14hs tip 50c98ec0 (#2474 Defend Prefer → Mix LPT-703 Prefer)

- Tip-stable `50c98ec0` after #2474 Defend SoftPulse Prefer LPT-701. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Mix SoftPulse residual re-check `lesson-06-08-01-01/02/03` / `act-06-08-01-*`: first-child SoftPulse MIX→PURPOSE→STRONG + `explainGrading` "Mix → Purpose → Strong." + Dart `MixedStrategyDemo.points` MIX/PURPOSE/STRONG (captions With a reason / Not coin-flip / Mix sometimes) + layout "Tap Mix, then Purpose, then Strong." still pre-split under mix-strong-only → residual **LPT-703** still To Do (needs-human; Relates LPT-277); successors TYPE→STATION→LESS / RANDOM→PURPOSE content-driven (do not reopen LPT-669); guided SoftPulse `protect` one-per-press PRESENT (`7h`/`7d`·`7c`/`Kd`/`2s` +2 suit variants match Dart); scaffolded SoftPulse `less` densify PRESENT; unguided SoftPulse `no` densify PRESENT; checkpoint SoftPulse `freq` kind `none` densify PRESENT under no-pure-random — no companion residual.
- Curriculum **LPT-277** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-703/277/704/701/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Plan-3bet SoftPulse residual **LPT-704** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-08-01-*: interactive structural clean on tip except LPT-703 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); scaffolded/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; guided stays fixed+variants set-of-sevens honesty.

## Fold 2026-10-14hu tip 08567641 (#2475/#2476 → Hard-folds LPT-705 Prefer)

- Tip-stable `08567641` after #2476 Suits Hint + #2475 Mix Prefer (Plan-3bet Prefer already on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Prefer NEVER Hard-folds SoftPulse residual **LPT-705** re-check: HARD→COOLER→EGO still under hard-folds-only — still To Do (Relates LPT-285). Successors content-driven; densify PRESENT; curriculum LPT-285 Done — do not clone.
- next: NEVER Selective SoftPulse residual **LPT-706** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.

## Fold 2026-10-14ht tip 44739c0b→ee7b93ca (Plan-3bet LPT-704 Prefer rescue after #2478)

- Independent Prefer NEVER Plan-3bet SoftPulse residual re-check raced Hard-folds #2478; tip-comments landed on `44739c0b`; fold rescued onto tip `ee7b93ca`. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Plan-3bet SoftPulse residual re-check `lesson-06-09-01-01/02/03` / `act-06-09-01-*`: careful-4bet SoftPulse 4BET→STRONG→CAREFUL content-driven + guided SoftPulse `careful` densify PRESENT (`deal.mode` `none`); **middle-child** SoftPulse 3BET→4BET→DEPTH + `explainGrading` "3-bet → 4-bet → Depth." + Dart `ThreeBetFourBetSprDemo.points` 3BET/4BET/DEPTH still pre-split under plan-3bet-spr → residual **LPT-704** still To Do (needs-human; Relates LPT-282); scaffolded SoftPulse `small` one-per-press PRESENT (`Ah`/`Qd`·`8c`/`3h`/`2s` +2 suit variants; Dart `stackLabel` Stacks left 360 match); checkpoint SoftPulse `spr` kind `none` densify PRESENT under plan-3bet-spr — no companion residual; ego SoftPulse 4BET→EGO→AVOID content-driven + unguided SoftPulse `avoid` one-per-press densify PRESENT (do not reopen LPT-669).
- Curriculum **LPT-282** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-704/282/705/703/198/216/351 on audit tip; residual re-confirmed on `ee7b93ca`.
- Prefer next already advanced by #2478 → NEVER Selective SoftPulse residual **LPT-706** / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-09-01-*: interactive structural clean on tip except LPT-704 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants AQo-miss honesty.

## Fold 2026-10-14hv tip d345e904 (Prefer NEVER Selective SoftPulse residual LPT-706)

- Tip-stable `d345e904` after #2477 Plan-3bet Prefer fold (#2478 Hard-folds already on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Selective SoftPulse residual re-check `lesson-06-11-01-01/02/03` / `act-06-11-01-*`: first-child SoftPulse TIGHT→BARREL→SAMPLE + `explainGrading` "Tight → Barrel → Sample." + Dart `SelectiveAggressionDemo.points` TIGHT/BARREL/SAMPLE (captions Selective entry / With a plan / Count first) still pre-split under selective-entry-only → residual **LPT-706** still To Do (needs-human; Relates LPT-288 — do not re-add needs-human on curriculum); successors SoftPulse CALLED→GIVES UP / TWO HANDS→NOTE BUNDLE content-driven (do not reopen LPT-669); guided SoftPulse `sel` densify PRESENT (`deal.mode` `none`; guideRegion `selectivePlanOk`); scaffolded SoftPulse `disc` one-per-press densify PRESENT; unguided SoftPulse `low` one-per-press densify PRESENT; checkpoint SoftPulse `bundle` kind `none` densify PRESENT under wait-for-samples — no companion residual.
- Curriculum **LPT-288** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-706/288/705/704/708/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Meet-TAG working-model residual **LPT-708** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-01-*: interactive structural clean on tip except LPT-706 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14hw tip e4192ff3 (Prefer NEVER Meet-TAG working-model residual LPT-708)

- Tip-stable `e4192ff3` after #2480 Selective SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Meet-TAG working-model residual re-check `lesson-06-11-02-01/02/03` / `act-06-11-02-*`: SoftPulse TIGHT→AGGRO→MODEL + `explainGrading` + Dart `TagModelDemo.points` TIGHT/AGGRO/MODEL (captions Tight in / Aggressive after / Working model) **concept-aligned** under Introduce TAG / The TAG model (not SoftPulse residual); checkpoint SoftPulse `model` kind `none` densify PRESENT (prompt "TAG is?" / Working model vs Insult) still grades working-model-vs-insult under Introduce TAG-only → residual **LPT-708** still To Do (needs-human; Relates LPT-291 — do not re-add needs-human on curriculum); successors SoftPulse FOLDS MOST→PLANNED BARRELS / ENTRY WIDTH→DISCIPLINE content-driven (do not reopen LPT-669); guided SoftPulse `tag` densify PRESENT (`deal.mode` `none`); scaffolded SoftPulse `diff` one-per-press densify PRESENT; unguided SoftPulse `tag2` one-per-press densify PRESENT.
- Curriculum **LPT-291** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-708/291/706/709/710/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Adjust-TAG SoftPulse residual **LPT-709** (+ cite **LPT-710**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-02-*: interactive structural clean on tip except LPT-708 working-model residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` player-type tiles — do not file handFamily.

## Fold 2026-10-14hx tip 1367e19d (#2481 Meet-TAG Prefer → Adjust-TAG LPT-709 Prefer)

- Tip-stable `1367e19d` after #2479 S1–S2 SoftPulse residual product land + #2481 Meet-TAG Prefer. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Adjust-TAG SoftPulse residual re-check `lesson-06-11-03-01/02/03` / `act-06-11-03-*`: first-child SoftPulse CREDIT→TIGHTER→NO LIGHT + `explainGrading` "Credit → Tighter → No light." + Dart `VsTagsDemo` / `LessonVsTagsExplainTable` (NO LIGHT "Skip fancy XR"; layout "Tap Credit, then Tighter, then No light.") still pre-split under Respect-TAG-aggression-only → residual **LPT-709** still To Do (needs-human; Relates LPT-294 — do not re-add needs-human on curriculum); checkpoint SoftPulse `cite` kind `none` densify PRESENT (`tagRespectCiteOutcomes` / helper "Versus TAG — pick the cite.") still under Respect-only → residual **LPT-710** still To Do (needs-human; Relates LPT-294); successors SoftPulse CHECK-RAISE→FOLD / RARELY CALLS→CHECK content-driven (do not reopen LPT-669); guided SoftPulse `fold` PRESENT (`Jh`/`9d`·`Qc`/`9s`/`3h` +2 suit variants match Dart); scaffolded SoftPulse `fold-k9` one-per-press PRESENT (`Kh`/`9d` +2 suit variants); unguided SoftPulse `check` one-per-press PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants).
- Curriculum **LPT-294** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-709/710/294/708/713/351/198/216 (independent audit also tip-commented on `0dfdd982`); leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 SoftPulse residuals LPT-724…749 alone (#2479); leave ui-agent alone.
- Prefer next: NEVER Observe-wide SoftPulse residual **LPT-713** (+ **LPT-714** / **LPT-715**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-03-*: interactive structural clean on tip except LPT-709 SoftPulse + LPT-710 cite residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive sizing acts are `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` cite tiles — do not file handFamily.

## Fold 2026-10-14hy tip ae098436 (#2483 Adjust-TAG Prefer → Observe-wide LPT-713 Prefer)

- Tip-stable `ae098436` after #2483 Adjust-TAG SoftPulse Prefer enrich + #2484. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Observe-wide SoftPulse residual re-check `lesson-06-12-01-01/02/03` / `act-06-12-01-*`: first-child SoftPulse WIDE→PRESSURE→SAMPLE + `explainGrading` "Wide → Pressure → Sample." + Dart `WidePressureDemo` / `LessonWidePressureExplainTable` (PRESSURE "Barrels with a plan" / SAMPLE "Count first") still pre-split under Note-wide-entry-only → residual **LPT-713** still To Do (needs-human; Relates LPT-297 — do not re-add needs-human on curriculum); companion unguided SoftPulse `wait` Keep sampling (`lagObserveSampleOutcomes` / helper "One wide open — pick the confidence.") under Note sustained pressure → residual **LPT-714** still To Do; companion checkpoint SoftPulse `bundle` kind `none` densify PRESENT (`lagObserveBundleOutcomes`) under Planned-not-maniac → residual **LPT-715** still To Do; successors SoftPulse BARRELS→MANY HANDS / FOLDS SOMETIMES→PLAN content-driven (do not reopen LPT-669); guided SoftPulse `wide` densify PRESENT (`lagObserveGuidedOutcomes`); scaffolded SoftPulse `sep` one-per-press densify PRESENT (`lagObserveDiscOutcomes`).
- Curriculum **LPT-297** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-713/714/715/297/709/710/351/198/216/716; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Meet-LAG sample-limits residual **LPT-716** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-01-*: interactive structural clean on tip except LPT-713 SoftPulse + LPT-714 unguided + LPT-715 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-14hz tip 27b7055d (#2485 Observe-wide Prefer → Meet-LAG LPT-716 Prefer)

- Tip-stable `27b7055d` after #2485 Observe-wide SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Meet-LAG sample-limits residual re-check `lesson-06-12-02-01/02/03` / `act-06-12-02-*`: SoftPulse WIDE→PRESSURE→MODEL + `explainGrading` "Wide → Pressure → Model." + Dart `LagModelDemo.points` WIDE/PRESSURE/MODEL **concept-aligned** under Introduce LAG / The LAG model (not SoftPulse residual); checkpoint SoftPulse `limits` kind `none` densify PRESENT (`meetLagLimitsOutcomes` / prompt "Show beside LAG label?" / Sample limits vs Destiny) still grades sample-limits under Introduce LAG-only → residual **LPT-716** still To Do (needs-human; Relates LPT-300 — do not re-add needs-human on curriculum); successors SoftPulse WIDE OPENS→BARRELS / RAISES→CALLS content-driven (do not reopen LPT-669); guided SoftPulse `lag` densify PRESENT (`meetLagVsTagOutcomes`); scaffolded SoftPulse `diff` one-per-press densify PRESENT (`meetLagDiffOutcomes`); unguided SoftPulse `lag2` one-per-press densify PRESENT (`meetLagVsNitOutcomes`).
- Curriculum **LPT-300** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-716/300/718/719/713/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Adjust-LAG SoftPulse residual **LPT-718** (+ cite **LPT-719**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-02-*: interactive structural clean on tip except LPT-716 sample-limits checkpoint residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` player-type tiles — do not file handFamily.

## Fold 2026-10-14ia (ecfa4090 Prefer NEVER Adjust-LAG SoftPulse residual LPT-718 re-check)

- Tip-stable `ecfa4090` after #2487 Meet-LAG sample-limits Prefer on tip. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Adjust-LAG SoftPulse residual re-check `lesson-06-12-03-01/02/03` / `act-06-12-03-*`: first-child SoftPulse CALL→TRAP→FANCY LESS + `explainGrading` "Call → Trap → Fancy less." + Dart `VsLagsDemo` / `LessonVsLagsExplainTable` (CALL "Widen defense" / TRAP "Slow-play value" / FANCY LESS "Skip hero bluffs") still pre-split under Call-wider-only → residual **LPT-718** still To Do (needs-human; Relates LPT-303 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `cite` kind `none` densify PRESENT under Call-wider → residual **LPT-719** still To Do; successors SoftPulse STRONG HAND→LET THEM BET / NO BIG BLUFF→LET THEM content-driven (do not reopen LPT-669); guided SoftPulse `call` PRESENT (`Jh`/`9d`·`Qc`/`9s`/`3h`/`2d`/`7c` +2 suit variants match Dart); scaffolded SoftPulse `trap` one-per-press PRESENT (`As`/`Ad`·`Ac`/`7s`/`2h` +2 suit variants); unguided SoftPulse `avoid` one-per-press densify PRESENT.
- Curriculum **LPT-303** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-718/719/303/198/216/716/721/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Mix-five SoftPulse residual **LPT-721** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-03-*: interactive structural clean on tip except LPT-718 SoftPulse + LPT-719 cite residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded sizing `fixed`+variants — do not reopen LPT-627; unguided/checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-14ib tip 5618be3b (#2489 Adjust-LAG Prefer → Mix-five LPT-721 Prefer)

- Tip-stable `5618be3b` after #2489 Adjust-LAG SoftPulse Prefer enrich. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Mix-five SoftPulse residual re-check `lesson-06-13-01-01/02/03/04` / `act-06-13-01-*`: first-child SoftPulse CARDS→SEATS→EVIDENCE + `explainGrading` "Cards → Seats → Evidence." + Dart `ExploitEvidenceDemo` / `LessonExploitEvidenceExplainTable` (CARDS "Equal holdings" / SEATS "Type differs" / EVIDENCE "Prove before exploit") still pre-split under Station-thin-only → residual **LPT-721** still To Do (needs-human; Relates LPT-306 — do not re-add needs-human on curriculum); successors SoftPulse NIT CHECK-RAISE→FOLD / LAG BARREL→CALL / TENDENCY→LINE content-driven (do not reopen LPT-669); guided SoftPulse `cs` SoftPulse map PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants match Dart); scaffolded SoftPulse `nit` one-per-press SoftPulse map PRESENT; unguided SoftPulse `lag` one-per-press SoftPulse map PRESENT; cite checkpoint SoftPulse `tag` kind `none` densify PRESENT under cite-tendency matches — no companion residual.
- Curriculum **LPT-306** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-721/306/718/790/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER preflop-to-flop SoftPulse residual **LPT-790** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-13-01-*: interactive structural clean on tip except LPT-721 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded/unguided sizing `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` cite tiles — do not file handFamily.

## Fold 2026-10-14ic tip 93a4c252 (#2490 Mix-five Prefer → Carry LPT-790 Prefer)

- Tip-stable `93a4c252` after #2490 Mix-five SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER preflop-to-flop SoftPulse residual re-check `lesson-07-01-01-01/02/03` / `act-07-01-01-*`: first-child SoftPulse REASON→CONFIRM→CANCEL + `explainGrading` "Reason → Confirm → Cancel." + Dart `PreflopFlopPlanDemo` / `LessonPreflopFlopPlanExplainTable` still pre-split under thesis-only → residual **LPT-790** still To Do (needs-human; Relates LPT-310 — do not re-add needs-human on curriculum); successors SoftPulse TEXTURE→CONFIRM OR CANCEL / DEAD PLAN→LET GO content-driven (do not reopen LPT-669); guided SoftPulse `dead` densify PRESENT; scaffolded SoftPulse `value` densify PRESENT; unguided SoftPulse `thesis` densify PRESENT; checkpoint SoftPulse `abandon` kind `none` densify PRESENT under abandon matches — no companion residual.
- Curriculum **LPT-310** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-790/310/721/794/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Map SoftPulse residual **LPT-794** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-01-01-*: interactive structural clean on tip except LPT-790 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` plan tiles — do not file handFamily.

## Fold 2026-10-14id tip 7253a03c (#2491 Carry Prefer → Map LPT-794 Prefer)

- Tip-stable `7253a03c` after #2491 Carry SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Map SoftPulse residual re-check `lesson-07-02-01-01/02/03` / `act-07-02-01-*`: first-child SoftPulse BARREL→GIVE-UP→MAP + `explainGrading` "Barrel → Give-up → Map." + Dart `TurnMapDemo` (BARREL "Cards to continue" / GIVE-UP "Cards to kill" / MAP "Before flop bet") still pre-split under continue-cards-only → residual **LPT-794** still To Do (needs-human; Relates LPT-314 — do not re-add needs-human on curriculum); successors SoftPulse BRICK→GIVE UP / CONTINUE→GIVE-UP→MAP content-driven (do not reopen LPT-669); guided SoftPulse `ok` densify PRESENT; scaffolded SoftPulse `give` one-per-press densify PRESENT; unguided SoftPulse `avoid` one-per-press densify PRESENT; checkpoint SoftPulse `list` kind `none` densify PRESENT under map-definition matches — no companion residual.
- Curriculum **LPT-314** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-794/314/790/795/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Compose SoftPulse residual **LPT-795** (+ rule **LPT-796**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-02-01-*: interactive structural clean on tip except LPT-794 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` map tiles — do not file handFamily.

## Fold 2026-10-14ie tip aff041b2 (#2493 Map Prefer → Compose LPT-795 Prefer)

- Tip-stable `aff041b2` after #2493 Map SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Compose SoftPulse residual re-check `lesson-07-03-01-01/02/03` / `act-07-03-01-*`: first-child SoftPulse VALUE→BLUFF→HOLD + `explainGrading` "Value → Bluff → Hold." + Dart `RiverCompositionDemo` / `LessonRiverCompositionExplainTable` still pre-split under value-only → residual **LPT-795** still To Do (needs-human; Relates LPT-317 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `rule` kind `none` densify PRESENT under value-only → residual **LPT-796** still To Do; successors SoftPulse BLOCKER→FEWER CALLS / NO STORY→CHECK content-driven (do not reopen LPT-669); guided SoftPulse `val` PRESENT (`As`/`Ad`·`Ac`/`9s`/`4h`/`2d`/`7c` +2 suit variants); scaffolded SoftPulse `block` one-per-press densify PRESENT; unguided SoftPulse `check` one-per-press densify PRESENT.
- Curriculum **LPT-317** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-795/796/317/794/798/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Pot SoftPulse residual **LPT-798** (+ ranges/SPR **LPT-799**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-03-01-*: interactive structural clean on tip except LPT-795 SoftPulse + LPT-796 rule residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided sizing `fixed`+variants — do not reopen LPT-627; scaffolded/unguided/checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-14if tip b2c99142 (#2494 Compose Prefer → Pot LPT-798 Prefer)

- Tip-stable `b2c99142` after #2494 Compose SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Pot SoftPulse residual re-check `lesson-07-04-01-01/02/03` / `act-07-04-01-*`: first-child SoftPulse LIMPED→SRP→3-4BET + `explainGrading` "Limped → SRP → 3-bet/4-bet." + Dart `PotTypePlansDemo` (LIMPED "Nut potential" / SRP "C-bet maps" / 3-4BET "High commit") still pre-split under limped-only → residual **LPT-798** still To Do (needs-human; Relates LPT-320 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `both` kind `none` densify PRESENT under 3-bet/4-bet-only → residual **LPT-799** still To Do; successors SoftPulse HEADS-UP→C-BET / LOW SPR→COMMIT content-driven (do not reopen LPT-669); guided SoftPulse `nuts` densify PRESENT; scaffolded SoftPulse `cb` one-per-press densify PRESENT; unguided SoftPulse `commit` one-per-press densify PRESENT.
- Curriculum **LPT-320** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-798/799/320/795/800/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER HU SoftPulse residual **LPT-800** (+ player-count **LPT-801**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-04-01-*: interactive structural clean on tip except LPT-798 SoftPulse + LPT-799 Ranges/SPR residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` pot-type tiles — do not file handFamily.

## Fold 2026-10-14ig tip 9ceb38fe (#2495 Pot Prefer → HU LPT-800 Prefer)

- Tip-stable `9ceb38fe` after #2495 Pot SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER HU SoftPulse residual re-check `lesson-07-05-01-01/02/03` / `act-07-05-01-*`: first-child SoftPulse FEWER→THICKER→WIDEN + `explainGrading` "Fewer → Thicker → Widen." + Dart `HuVsMultiwayDemo` / `LessonHuVsMultiwayExplainTable` (FEWER "Bluff less MW" / THICKER "Value up MW" / WIDEN "HU selected bluffs") still pre-split under Bluff-less-multiway-only → residual **LPT-800** still To Do (needs-human; Relates LPT-323 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `input` kind `none` densify PRESENT ("Player count is?") under bluff-less-only → residual **LPT-801** still To Do; successors SoftPulse MULTIWAY→THICK VALUE / HEADS-UP→STEAL MORE content-driven (do not reopen LPT-669); guided SoftPulse `no` densify PRESENT; unguided SoftPulse `thick` one-per-press densify PRESENT; scaffolded SoftPulse `higher` one-per-press densify PRESENT.
- Curriculum **LPT-323** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-800/801/323/798/802/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Stack SoftPulse residual **LPT-802** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-05-01-*: interactive structural clean on tip except LPT-800 SoftPulse + LPT-801 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-14ih tip a919148b (#2496 HU Prefer → Stack LPT-802 Prefer)

- Tip-stable `a919148b` after #2496 HU SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Stack SoftPulse residual re-check `lesson-07-06-01-01/02/03` / `act-07-06-01-*`: first-child SoftPulse SHORT→DEEP→EFFECTIVE + `explainGrading` "Short → Deep → Effective." + Dart `StackDepthPlansDemo` (SHORT "Commit earlier" / DEEP "Implied odds" / EFFECTIVE "Recalc each hand") still pre-split under commit-short-only → residual **LPT-802** still To Do (needs-human; Relates LPT-326 — do not re-add needs-human on curriculum); successors SoftPulse DEEP→IMPLIED ODDS / SHORTER STACK→PLAN content-driven (do not reopen LPT-669); guided SoftPulse `commit` densify PRESENT; scaffolded SoftPulse `yes` one-per-press densify PRESENT; unguided SoftPulse `40` one-per-press densify PRESENT; checkpoint SoftPulse `every` kind `none` densify PRESENT under recalc-effective matches — no companion residual; distinct from S2 **LPT-748**.
- Curriculum **LPT-326** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-802/326/800/725/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Same-cards SoftPulse residual **LPT-725** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-06-01-*: interactive structural clean on tip except LPT-802 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` stack-depth tiles — do not file handFamily.

## Fold 2026-10-14ii tip 42b5c1d3 (#2497 Stack Prefer → Same-cards LPT-725 Prefer)

- Tip-stable `42b5c1d3` after #2497 Stack SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Same-cards SoftPulse residual re-check `lesson-07-07-01-01/02/03/04` / `act-07-07-01-*`: first-child SoftPulse CARDS→MODELS→CITE + `explainGrading` "Cards → Models → Cite." + Dart `SameCardsTypesDemo` (CARDS "Same holdings" / MODELS "Five types" / CITE "Tendency or baseline") still pre-split under station-value → residual **LPT-725** still To Do (needs-human; Relates LPT-330 — do not re-add needs-human on curriculum); successors SoftPulse TAG CHECK-RAISE→CAREFUL / LAG BARREL→CALL / NO EVIDENCE→BASELINE content-driven (do not reopen LPT-669); guided SoftPulse `bet` PRESENT (fixed+variants); scaffolded SoftPulse `fold` one-per-press PRESENT; unguided SoftPulse `call` one-per-press PRESENT; checkpoint SoftPulse `base` kind `none` densify PRESENT under baseline matches — no companion residual.
- Curriculum **LPT-330** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-725/330/802/726/198/216/351; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Type-board SoftPulse residual **LPT-726** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-07-01-*: interactive structural clean on tip except LPT-725 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded/unguided sizing `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-14ij tip 408eab5e (#2498 Same-cards Prefer → Type-board LPT-726 Prefer)

- Tip-stable `408eab5e` after #2498 Same-cards SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Type-board SoftPulse residual re-check `lesson-07-08-01-01/02/03` / `act-07-08-01-*`: first-child SoftPulse TYPE→BOARD→LINE→SIZE + `explainGrading` "Type → Board → Line → Size." + Dart `TypeBoardLineDemo` (TYPE "Player model" / BOARD "Texture" / LINE "History" / SIZE "One action") still pre-split under type-and-board-only → residual **LPT-726** still To Do (needs-human; Relates LPT-333 — do not re-add needs-human on curriculum); successors SoftPulse LINE→SIZE / FOUR INPUTS→ONE ACTION content-driven (do not reopen LPT-669); guided SoftPulse `call` PRESENT (`Jh`/`Td`·`Kh`/`Ts`/`8h`/`2d` +2 suit variants match Dart); scaffolded SoftPulse `raise` one-per-press PRESENT; unguided SoftPulse `fold` one-per-press PRESENT; checkpoint SoftPulse `four` kind `none` densify PRESENT under one-coherent-action matches — no companion residual.
- Curriculum **LPT-333** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-726/333/727/725/802/351/198/216; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Leak SoftPulse residual **LPT-727** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-08-01-*: interactive structural clean on tip except LPT-726 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded/unguided sizing `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-14ik tip c292c799 (#2499 Type-board Prefer → Leak LPT-727 Prefer)

- Tip-stable `c292c799` after #2499 Type-board SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Leak SoftPulse residual re-check `lesson-07-09-01-01/02/03` / `act-07-09-01-*`: first-child SoftPulse LEAK→BOOK→REVIEW + `explainGrading` "Leak → Book → Review." + Dart `LeakReviewBookDemo` / `LessonLeakReviewBookExplainTable` (LEAK "Specific note" / BOOK "Written defaults" / REVIEW "On a schedule") still pre-split under name-leaks-only → residual **LPT-727** still To Do (needs-human; Relates LPT-336 — do not re-add needs-human on curriculum); successors SoftPulse COMMON SPOT→DEFAULT / AFTER SESSION→REVIEW content-driven (do not reopen LPT-669); guided SoftPulse `spec` densify PRESENT; scaffolded SoftPulse `book` one-per-press densify PRESENT; unguided SoftPulse `sched` one-per-press densify PRESENT; checkpoint SoftPulse `base` kind `none` densify PRESENT under default-lines matches — no companion residual.
- Curriculum **LPT-336** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-727/336/726/725/802/351/198/216; leave open LPT-676…802 + LPT-351; leave ui-agent alone.
- Prefer next: NEVER Capstone `lesson-07-10-0*` (synthesis clean check) / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-09-01-*: interactive structural clean on tip except LPT-727 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive outcome tiles `deal.mode` `none` — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-14il tip 6949375d (#2500 Leak Prefer → Capstone/warmup/Final SoftPulse Prefer)

- Tip-stable `6949375d` after #2500 Leak SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Capstone `lesson-07-10-01…05` / `act-07-10-0*`: all five explains SoftPulse + `explainGrading` concept-aligned (PLAN→UPDATE→FINISH / SPR→TURN→CLOSE / NUTS→DEEP→NO-BLUFF / NUTS→VALUE→THIN / SPR→COMMIT→NO HERO) + Dart Capstone*Demo points match; hands `authored_multi_step_hand` `assessmentRole` `transfer` + empty pressHints in `NO_HINT_ACTIVITY_IDS` — **LPT-348** Done (do not reopen LPT-626/667); fixed+2 suit variants; synthesis containers — skip curriculum-split / no SoftPulse residual.
- Prefer NEVER live-warmup `lesson-07-11-01-live-warmup-prep` / `act-07-11-01-*`: still unsplit — SoftPulse CHECKLIST→DEFAULTS→ONE HAND + Dart `LiveWarmupPrepDemo` matches packed objectives (SoftPulse residual N/A until LPT-351 splits); densify PRESENT; teachSpec **LPT-349** Done; curriculum **LPT-351** still To Do (needs-human) — do not clone.
- Prefer NEVER Final `lesson-07-12-01-five-type-final` / `act-07-12-01-*`: all seven checkpoint SoftPulse cues kind `none` densify PRESENT — structural **clean** (assessment container; skip curriculum-split; **LPT-352** Done).
- Tip-commented LPT-348/351/349/352/727/676/198/216; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER oldest SoftPulse residual **LPT-676** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-10-0* / act-07-11-01-* / act-07-12-01-*: Capstone/warmup/Final SoftPulse Prefer clean on tip; Capstone transfer NO_HINT policy LPT-348 Done; warm-up curriculum LPT-351 open; Final assessment clean LPT-352 Done.

## Fold 2026-10-14im tip 9b735ca7 (#2501 Capstone Prefer → Sizing placement LPT-676 Prefer)

- Tip-stable `9b735ca7` after #2501 Capstone/warmup/Final SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-04-04-01-01/02/03` / `act-04-04-01-*`: SoftPulse VALUE→PRESSURE→SIZE under Value **concept-aligned** (no SoftPulse residual); polar-pressure `act-04-04-01-scaffolded` SoftPulse `big` + pressHint bluff-story (`9h`/`8h`·`Kh`/`7h`/`2c`/`3d`/`As` +2 suit variants) still nested under Nearby → residual **LPT-676** still To Do (Relates LPT-179 — do not re-add needs-human on curriculum); successors SoftPulse NEARBY→STORY / TINY→VALUE content-driven (do not reopen LPT-669); guided SoftPulse `half` densify PRESENT; unguided SoftPulse `soft` densify PRESENT; checkpoint SoftPulse `bad-1` kind `none` under Avoid-tiny — no companion residual.
- Curriculum **LPT-179** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-676/179/681/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Estimate SoftPulse residual **LPT-681** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-04-04-01-*: interactive structural clean on tip except LPT-676 placement residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-14in tip 41ec1524 (#2502 Sizing Prefer → Estimate SoftPulse LPT-681 Prefer)

- Tip-stable `41ec1524` after #2502 SoftPulse residual Prefer LPT-676 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-05-03-01-01/02/03` / `act-05-03-01-*`: first-child SoftPulse IMPLIED→REVERSE→SECOND + `explainGrading` "Implied → Reverse → Second." still pre-split under estimate-only → residual **LPT-681** still To Do (Relates LPT-230 — do not re-add needs-human on curriculum); successors SoftPulse REVERSE→DOMINATED→FOLD / NON-NUT→MULTIWAY→SKIP content-driven (do not reopen LPT-669); guided SoftPulse `call-io` densify PRESENT; scaffolded SoftPulse `rio` densify PRESENT; unguided SoftPulse `nonut` densify PRESENT; checkpoint SoftPulse `depth-pay` kind `none` under Estimate — no companion residual.
- Curriculum **LPT-230** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-681/230/682/676/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Thin SoftPulse residual **LPT-682** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-03-01-*: interactive structural clean on tip except LPT-681 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-14io tip 925f34bd (#2503 Estimate Prefer → Thin SoftPulse LPT-682 Prefer)

- Tip-stable `925f34bd` after #2503 SoftPulse residual Prefer LPT-681 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-05-04-01-01/02/03` / `act-05-04-01-*`: first-child SoftPulse THIN→CATCH→BARRELS + `explainGrading` "Thin → Catch → Barrels." still pre-split under thin-value-only → residual **LPT-682** still To Do (Relates LPT-233 — do not re-add needs-human on curriculum); successors SoftPulse MANIAC→BARREL→CALL / NIT→FOLDS→CHECK content-driven (do not reopen LPT-669); guided SoftPulse `tv` densify PRESENT; scaffolded SoftPulse `call-m` densify PRESENT; unguided SoftPulse `check-nit` densify PRESENT; checkpoint SoftPulse `read` under Thin — companion residual note stays on LPT-682 body (no new clone).
- Curriculum **LPT-233** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-682/233/684/681/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Lines SoftPulse residual **LPT-684** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-04-01-*: interactive structural clean on tip except LPT-682 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-14ip tip 4ca0ccbb (#2504 Thin Prefer → Lines SoftPulse LPT-684 Prefer)

- Tip-stable `4ca0ccbb` after #2504 SoftPulse residual Prefer LPT-682 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-05-05-01-01/02/03` / `act-05-05-01-*`: first-child SoftPulse X/R→PROBE→DELAY→DONK + `explainGrading` "Check-raise → Probe → Delay → Donk." still pre-split under check-raises-only → residual **LPT-684** still To Do (Relates LPT-236 — do not re-add needs-human on curriculum); successors SoftPulse PROBE→DELAY→PLAN / DONK→STRONG→AIR content-driven (do not reopen LPT-669); guided SoftPulse `strong` densify PRESENT; scaffolded SoftPulse `probe` densify PRESENT; unguided SoftPulse `polar` densify PRESENT; checkpoint SoftPulse `delay` kind `none` under probes-and-delays — no companion residual.
- Curriculum **LPT-236** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-684/236/685/682/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Timing SoftPulse residual **LPT-685** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-05-01-*: interactive structural clean on tip except LPT-684 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-14iq tip 18fc5334 (#2505 Lines Prefer → Timing SoftPulse LPT-685 Prefer)

- Tip-stable `18fc5334` after #2505 SoftPulse residual Prefer LPT-684 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-05-07-01-01/02/03` / `act-05-07-01-*`: first-child SoftPulse TIMING→SIZING→CLUES + `explainGrading` "Timing → Sizing → Clues." still pre-split under timing-soft-only → residual **LPT-685** still To Do (Relates LPT-244 — do not re-add needs-human on curriculum); successors SoftPulse TINY→BIG→RANGE / TELL→MYTH→REJECT content-driven (do not reopen LPT-669); guided SoftPulse `soft` densify PRESENT; scaffolded SoftPulse `weakish` densify PRESENT; unguided SoftPulse `reject` densify PRESENT; checkpoint SoftPulse `tiny` kind `none` under timing-soft — no companion residual.
- Curriculum **LPT-244** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-685/244/686/684/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Dynamics SoftPulse residual **LPT-686** (+ **LPT-687**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-07-01-*: interactive structural clean on tip except LPT-685 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-14ir tip c01b437a (#2506 Timing Prefer → Dynamics SoftPulse LPT-686 Prefer)

- Tip-stable `c01b437a` after #2506 SoftPulse residual Prefer LPT-685 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-05-08-01-01/02/03` / `act-05-08-01-*`: first-child SoftPulse STUCK→TILTED→GEARS + `explainGrading` "Stuck → Tilted → Gears." still pre-split under tilted/stuck-only → residual **LPT-686** still To Do (Relates LPT-247 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `temp` kind `none` densify PRESENT under Gear changes → **LPT-687** still To Do; successors SoftPulse GEAR→CHANGE→SAMPLE / COOLER→CHASE→RESET content-driven (do not reopen LPT-669); guided SoftPulse `stuck` densify PRESENT; scaffolded SoftPulse `gear` densify PRESENT; unguided SoftPulse `reset` map PRESENT.
- Curriculum **LPT-247** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-686/687/247/690/685/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Session SoftPulse residual **LPT-690** (+ **LPT-691**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-08-01-*: interactive structural clean on tip except LPT-686/687 SoftPulse residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-14is tip da62c3cc (#2508 Dynamics Prefer → Session SoftPulse LPT-690 Prefer)

- Tip-stable `da62c3cc` after #2508 SoftPulse residual Prefer LPT-686 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-05-09-01-01/02/03` / `act-05-09-01-*`: first-child SoftPulse QUIT→GUARD→FIRST + `explainGrading` "Quit → Guard → First." still pre-split under stop-loss-only → residual **LPT-690** still To Do (Relates LPT-250 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `edge` kind `none` densify PRESENT under End sessions → **LPT-691** still To Do; successors SoftPulse BANKROLL→STAKES→DECLINE / TIRED→WILD→CASH OUT content-driven (do not reopen LPT-669); guided SoftPulse `stop` densify PRESENT; scaffolded SoftPulse `decline` densify PRESENT; unguided SoftPulse `cash` densify PRESENT.
- Curriculum **LPT-250** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-690/691/250/692/686/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Range SoftPulse residual **LPT-692** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-09-01-*: interactive structural clean on tip except LPT-690/691 SoftPulse residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-14it tip e17358dc (#2509 Session Prefer → Range SoftPulse LPT-692 Prefer)

- Tip-stable `e17358dc` after #2509 SoftPulse residual Prefer LPT-690 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-01-01-01/02/03` / `act-06-01-01-*`: first-child SoftPulse RANGE→NUT→ADVANTAGE + `explainGrading` "Range → Nut → Advantage." + Dart `RangeAdvantageDemo` / layout "Tap Range, then Nut, then Advantage." still pre-split under range-advantage-only → residual **LPT-692** still To Do (Relates LPT-254 — do not re-add needs-human on curriculum); successors SoftPulse NUTS→PAIRED→CALLER / RANGE→NUTS→BET content-driven (do not reopen LPT-669); guided SoftPulse `pfr` densify PRESENT; scaffolded SoftPulse `caller-nuts` densify PRESENT; unguided SoftPulse `cbet` map PRESENT (fixed AhKd/Kc7s2d + 2 suit variants); checkpoint SoftPulse `press` kind `none` densify PRESENT under press-both — no companion residual.
- Curriculum **LPT-254** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-692/254/690/694/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Spot-caps SoftPulse residual **LPT-694** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-01-01-*: interactive structural clean on tip except LPT-692 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify/map PRESENT — do not reopen LPT-628.

## Fold 2026-10-14iu tip 729c439f (#2510 Range Prefer → Spot-caps SoftPulse LPT-694 Prefer)

- Tip-stable `729c439f` after #2510 SoftPulse residual Prefer LPT-692 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-03-01-01/02/03` / `act-06-03-01-*`: first-child SoftPulse CAPPED→UNCAPPED→NUTS + `explainGrading` "Capped → Uncapped → Nuts." + Dart `CappedUncappedDemo.points` (CAPPED/UNCAPPED/NUTS) / layout "Tap Capped, then Uncapped, then Nuts." still pre-split under spot-caps-only → residual **LPT-694** still To Do (Relates LPT-260 — do not re-add needs-human on curriculum; race clone LPT-695 Done — do not reopen); successors SoftPulse RAISE→BET→RESPECT / CAPPED→THIN→BLUFF content-driven (do not reopen LPT-669); guided SoftPulse `cap` densify PRESENT; unguided SoftPulse `uncap` densify PRESENT; scaffolded SoftPulse `bet` map PRESENT (fixed Jh9d/Kc9s4h2d7c + 2 suit variants); checkpoint SoftPulse `attack` kind `none` densify PRESENT under attack-caps — no companion residual.
- Curriculum **LPT-260** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-694/260/692/696/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Polar SoftPulse residual **LPT-696** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-03-01-*: interactive structural clean on tip except LPT-694 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded is fixed+variants poker_action_sizing.

## Fold 2026-10-15a tip 72685a3f (#2511 Spot-caps Prefer → Polar SoftPulse LPT-696 Prefer)

- Tip-stable `72685a3f` after #2511 SoftPulse residual Prefer LPT-694 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-04-01-01/02/03` / `act-06-04-01-*`: first-child SoftPulse POLAR→MERGED→SIZE + `explainGrading` "Polar → Merged → Size." + Dart `PolarMergedDemo.points` (POLAR/MERGED/SIZE) still pre-split under polarized-sizing-only → residual **LPT-696** still To Do (Relates LPT-264 — do not re-add needs-human on curriculum); successors SoftPulse MERGED→MEDIUM→VALUE / SIZE→SHAPE→MATCH content-driven (do not reopen LPT-669); guided SoftPulse `polar` densify PRESENT; scaffolded SoftPulse `mid` one-per-press PRESENT (fixed JhTd/QcTs3h2d7c + 2 suit variants match Dart LPT-395); unguided SoftPulse `mismatch` densify PRESENT; checkpoint SoftPulse `thin` kind `none` densify PRESENT under merged-thin-value — no companion residual.
- Curriculum **LPT-264** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-696/264/694/699/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Overbet SoftPulse residual **LPT-699** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-04-01-*: interactive structural clean on tip except LPT-696 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded is fixed+variants poker_action_sizing.

## Fold 2026-10-15b tip 40544d1f (#2512 Polar Prefer → Overbet SoftPulse LPT-699 Prefer)

- Tip-stable `40544d1f` after #2512 SoftPulse residual Prefer LPT-696 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-05-01-01/02/03` / `act-06-05-01-*`: first-child SoftPulse OVERBET→POLAR→GEO + `explainGrading` "Overbet → Polar → Geometry." still pre-split under polar-overbets-only → residual **LPT-699** still To Do (Relates LPT-267 — do not re-add needs-human on curriculum; race clone LPT-698 Done — do not reopen); successors SoftPulse FLOP→TURN→RIVER / HUGE→MEDIUM→AVOID content-driven (do not reopen LPT-669); guided SoftPulse `polar-ob` densify PRESENT; scaffolded SoftPulse `mid` densify PRESENT; unguided SoftPulse `avoid` densify PRESENT; checkpoint SoftPulse `multi` under geometric-sizes — no companion residual.
- Curriculum **LPT-267** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-699/267/700/696/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Blockers SoftPulse residual **LPT-700** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-05-01-*: interactive structural clean on tip except LPT-699 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15c tip 22369b67 (#2513 Overbet Prefer → Blockers SoftPulse LPT-700 Prefer)

- Tip-stable `22369b67` after #2513 SoftPulse residual Prefer LPT-699 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-06-01-01/02/03` / `act-06-06-01-*`: first-child SoftPulse BLOCK→USE→NO EV + `explainGrading` "Block → Use → No EV." still pre-split under bluff-blockers-only → residual **LPT-700** still To Do (Relates LPT-270 — do not re-add needs-human on curriculum); successors SoftPulse CATCH→UNBLOCK→BLUFFS / TWEAK→NO EV content-driven (do not reopen LPT-669); guided SoftPulse `as` densify PRESENT; scaffolded SoftPulse `unblock` densify PRESENT; unguided SoftPulse `tweak` densify PRESENT; checkpoint SoftPulse `no` under no-fake-ev — no companion residual.
- Curriculum **LPT-270** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-700/270/701/699/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S2 LPT-724…749 alone; leave ui-agent alone.
- Prefer next: NEVER Defend SoftPulse residual **LPT-701** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-06-01-*: interactive structural clean on tip except LPT-700 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15d tip e6f2b57d (#2514 Blockers Prefer → Defend SoftPulse LPT-701 Prefer)

- Tip-stable `e6f2b57d` after #2514 SoftPulse residual Prefer LPT-700 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-07-01-01/02/03` / `act-06-07-01-*`: first-child SoftPulse DEFEND→BLUFF→ENOUGH + `explainGrading` "Defend → Bluff → Enough." + Dart `DefendEnoughDemo.points` (DEFEND/BLUFF/ENOUGH; captions Continue enough / Over-bluffs fail / No fake %) / `LessonDefendEnoughExplainTable` still pre-split under continue-catchers-only → residual **LPT-701** still To Do (Relates LPT-273 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `punish` kind `none` densify PRESENT under Continue with stronger catchers → residual **LPT-702** still To Do; successors SoftPulse THIRD PAIR→SCARY→FOLD / MDF→INTUITION content-driven (do not reopen LPT-669); guided SoftPulse `strong` densify PRESENT (`defendGuidedOutcomes`); scaffolded SoftPulse `fold` one-per-press PRESENT (`9h`/`7d`·`Kc`/`Qh`/`9d`/`4c`/`8s` +2 suit variants match Dart); unguided SoftPulse `int` one-per-press densify PRESENT.
- Curriculum **LPT-273** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-701/702/273/700/703/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress S1–S3 SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Mix SoftPulse residual **LPT-703** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-07-01-*: interactive structural clean on tip except LPT-701 SoftPulse + LPT-702 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants third-pair honesty.

## Fold 2026-10-15e tip f05bd828 (#2515 Defend Prefer → Mix SoftPulse LPT-703 Prefer)

- Tip-stable `f05bd828` after #2515 SoftPulse residual Prefer LPT-701 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-08-01-01/02/03` / `act-06-08-01-*`: first-child SoftPulse MIX→PURPOSE→STRONG + `explainGrading` "Mix → Purpose → Strong." still pre-split under mix-strong-only → residual **LPT-703** still To Do (Relates LPT-277 — do not re-add needs-human on curriculum); successors SoftPulse TYPE→STATION→LESS / RANDOM→PURPOSE content-driven (do not reopen LPT-669); guided SoftPulse `protect` one-per-press PRESENT; scaffolded SoftPulse `less` densify PRESENT; unguided SoftPulse `no` densify PRESENT; checkpoint SoftPulse `freq` under no-pure-random — no companion residual.
- Curriculum **LPT-277** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-703/277/704/701/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Plan-3bet SoftPulse residual **LPT-704** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-08-01-*: interactive structural clean on tip except LPT-703 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15f tip 0852d10b (Mix Prefer → Plan-3bet SoftPulse LPT-704 Prefer)

- Tip-stable `0852d10b` after #2518 SoftPulse residual Prefer LPT-703 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Plan-3bet SoftPulse residual re-check `lesson-06-09-01-01/02/03` / `act-06-09-01-*`: careful-4bet SoftPulse 4BET→STRONG→CAREFUL content-driven + guided SoftPulse `careful` densify PRESENT (`deal.mode` `none`); **middle-child** SoftPulse 3BET→4BET→DEPTH + `explainGrading` "3-bet → 4-bet → Depth." + Dart `ThreeBetFourBetSprDemo.points` 3BET/4BET/DEPTH (captions Shrink ranges / Lower SPR / Decides commit) / `LessonThreeBetFourBetSprExplainTable` still pre-split under plan-3bet-spr → residual **LPT-704** still To Do (Relates LPT-282 — do not re-add needs-human on curriculum); scaffolded SoftPulse `small` one-per-press PRESENT (`Ah`/`Qd`·`8c`/`3h`/`2s` +2 suit variants; Dart `stackLabel` Stacks left 360 match); checkpoint SoftPulse `spr` kind `none` densify PRESENT under plan-3bet-spr — no companion residual; ego SoftPulse 4BET→EGO→AVOID content-driven + unguided SoftPulse `avoid` one-per-press densify PRESENT (do not reopen LPT-669).
- Curriculum **LPT-282** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-704/282/705/703/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Hard-folds SoftPulse residual **LPT-705** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-09-01-*: interactive structural clean on tip except LPT-704 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants AQo-miss honesty.

## Fold 2026-10-15g tip 438b1746 (Plan-3bet Prefer → Hard-folds SoftPulse LPT-705 Prefer)

- Tip-stable `438b1746` after #2520 SoftPulse-quiet densify / #2519 Plan-3bet Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Hard-folds SoftPulse residual re-check `lesson-06-10-01-01/02/03` / `act-06-10-01-*`: first-child SoftPulse HARD→COOLER→EGO + `explainGrading` "Hard → Cooler → Ego." + coachMedia + Dart `HardFoldCoolerDemo.points` HARD/COOLER/EGO (captions Save buy-ins / Not a leak / Call mistake) / `LessonHardFoldCoolerExplainTable` still pre-split under hard-folds-only → residual **LPT-705** still To Do (Relates LPT-285 — do not re-add needs-human on curriculum); successors SoftPulse COOLER→MISTAKE→REVIEW / DUE→EGO→FOLD content-driven (do not reopen LPT-669); guided SoftPulse `fold` PRESENT (`Ah`/`9d`·`As`/`7c`/`2h`/`Kd`/`3c` +2 suit variants match Dart); scaffolded SoftPulse `cooler` densify PRESENT; unguided SoftPulse `ego` densify PRESENT; checkpoint SoftPulse `ask` kind `none` densify PRESENT under cooler-or-mistake — no companion residual.
- Curriculum **LPT-285** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-705/285/706/704/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Selective SoftPulse residual **LPT-706** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-10-01-*: interactive structural clean on tip except LPT-705 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); scaffolded/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily; guided stays fixed+variants hard-fold honesty.

## Fold 2026-10-15h tip 2be3458b (#2521 Hard-folds Prefer → Selective SoftPulse LPT-706 Prefer)

- Tip-stable `2be3458b` after #2521 SoftPulse residual Prefer LPT-705 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-11-01-01/02/03` / `act-06-11-01-*`: first-child SoftPulse TIGHT→BARREL→SAMPLE + `explainGrading` "Tight → Barrel → Sample." still pre-split under selective-entry-only → residual **LPT-706** still To Do (Relates LPT-288 — do not re-add needs-human on curriculum); successors SoftPulse CALLED→GIVES UP / TWO HANDS→NOTE BUNDLE content-driven (do not reopen LPT-669); guided SoftPulse `sel` densify PRESENT; scaffolded SoftPulse `disc` densify PRESENT; unguided SoftPulse `low` densify PRESENT; checkpoint SoftPulse `bundle` under wait-for-samples — no companion residual.
- Curriculum **LPT-288** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-706/288/708/705/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Meet-TAG working-model residual **LPT-708** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-01-*: interactive structural clean on tip except LPT-706 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15j tip a3bc0fbb (#2523 Meet-TAG Prefer → Adjust-TAG SoftPulse LPT-709 Prefer)

- Tip-stable `a3bc0fbb` after #2523 Meet-TAG working-model Prefer LPT-708 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Adjust-TAG SoftPulse residual re-check `lesson-06-11-03-01/02/03` / `act-06-11-03-*`: first-child SoftPulse CREDIT→TIGHTER→NO LIGHT + `explainGrading` "Credit → Tighter → No light." + Dart `VsTagsDemo.points` CREDIT/TIGHTER/NO LIGHT (captions Believe their heat / Narrow steals / Skip fancy XR) / `LessonVsTagsExplainTable` / layout "Tap Credit, then Tighter, then No light." still pre-split under Respect-TAG-aggression-only → residual **LPT-709** still To Do (needs-human; Relates LPT-294 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `cite` kind `none` densify PRESENT (`tagRespectCiteOutcomes` / helper "Versus TAG — pick the cite.") still under Respect-only → residual **LPT-710** still To Do (needs-human; Relates LPT-294); successors SoftPulse CHECK-RAISE→FOLD / RARELY CALLS→CHECK content-driven (do not reopen LPT-669); guided SoftPulse `fold` PRESENT (`Jh`/`9d`·`Qc`/`9s`/`3h` +2 suit variants match Dart); scaffolded SoftPulse `fold-k9` one-per-press PRESENT (`Kh`/`9d` +2 suit variants); unguided SoftPulse `check` one-per-press PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants).
- Curriculum **LPT-294** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-709/710/294/708/713/706/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Observe-wide SoftPulse residual **LPT-713** (+ LPT-714/715) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-03-*: interactive structural clean on tip except LPT-709 SoftPulse + LPT-710 cite residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive sizing acts are `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` cite tiles — do not file handFamily.

## Fold 2026-10-14

## Fold 2026-10-15k tip a4efec2d (#2524 Adjust-TAG Prefer → Observe-wide SoftPulse LPT-713 Prefer)

- Tip-stable `a4efec2d` after #2524 SoftPulse residual Prefer LPT-709 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-12-01-01/02/03` / `act-06-12-01-*`: first-child SoftPulse WIDE→PRESSURE→SAMPLE + `explainGrading` "Wide → Pressure → Sample." + Dart `WidePressureDemo.points` / `LessonWidePressureExplainTable` still pre-split under Note-wide-entry-only → residual **LPT-713** still To Do (Relates LPT-297 — do not re-add needs-human on curriculum); companion unguided SoftPulse `wait` Keep-sampling under Note sustained pressure → **LPT-714** still To Do; companion checkpoint SoftPulse `bundle` under Planned-not-maniac → **LPT-715** still To Do; successors SoftPulse BARRELS→MANY HANDS / FOLDS SOMETIMES→PLAN content-driven (do not reopen LPT-669); guided SoftPulse `wide` densify PRESENT; scaffolded SoftPulse `sep` densify PRESENT.
- Curriculum **LPT-297** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-713/714/715/297/709/716/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Meet-LAG sample-limits residual **LPT-716** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-01-*: interactive structural clean on tip except LPT-713 SoftPulse residual + LPT-714/715 companions; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15l tip 2945290a (#2525 Observe-wide Prefer → Meet-LAG sample-limits LPT-716 Prefer)

- Tip-stable `2945290a` after #2525 SoftPulse residual Prefer LPT-713 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Meet-LAG sample-limits residual re-check `lesson-06-12-02-01/02/03` / `act-06-12-02-*`: SoftPulse WIDE→PRESSURE→MODEL + `explainGrading` "Wide → Pressure → Model." + Dart `LagModelDemo.points` WIDE/PRESSURE/MODEL (captions Wide in / Pressure on / Working model) **concept-aligned** under Introduce LAG / The LAG model (not SoftPulse residual; same class as Meet TAG); checkpoint SoftPulse `limits` kind `none` densify PRESENT (prompt "Show beside LAG label?" / Sample limits vs Destiny; helper "Beside LAG label — pick what to show.") still grades sample-limits under Introduce LAG-only → residual **LPT-716** still To Do (needs-human; Relates LPT-300 — do not re-add needs-human on curriculum); successors SoftPulse WIDE OPENS→BARRELS / RAISES→CALLS content-driven (do not reopen LPT-669); guided SoftPulse `lag` densify PRESENT; scaffolded SoftPulse `diff` one-per-press densify PRESENT; unguided SoftPulse `lag2` one-per-press densify PRESENT.
- Curriculum **LPT-300** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-716/300/718/719/713/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Adjust-LAG SoftPulse residual **LPT-718** (+ cite **LPT-719**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-02-*: interactive structural clean on tip except LPT-716 sample-limits checkpoint residual; SoftPulse explain concept-aligned / successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` observation / player-read tiles — do not file handFamily.

## Fold 2026-10-15m tip 9b474bcf (#2527 Meet-LAG Prefer → Adjust-LAG SoftPulse LPT-718 Prefer)

- Tip-stable `9b474bcf` after #2527 SoftPulse residual Prefer LPT-716 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Adjust-LAG SoftPulse residual re-check `lesson-06-12-03-01/02/03` / `act-06-12-03-*`: first-child SoftPulse CALL→TRAP→FANCY LESS + `explainGrading` "Call → Trap → Fancy less." + Dart `VsLagsDemo.points` CALL/TRAP/FANCY LESS (captions Widen defense / Slow-play value / Skip hero bluffs) / `LessonVsLagsExplainTable` + coachMedia "Versus LAG: trap more, call wider, fancy less." still pre-split under Call-wider-only → residual **LPT-718** still To Do (needs-human; Relates LPT-303 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `cite` kind `none` densify PRESENT (prompt "LAG exploit cites?" / Wide + pressure vs Vibes; helper via densify PRESENT) under Call-wider → residual **LPT-719** still To Do; successors SoftPulse STRONG HAND→LET THEM BET / NO BIG BLUFF→LET THEM content-driven (do not reopen LPT-669); guided SoftPulse `call` map PRESENT (`Jh`/`9d`·`Qc`/`9s`/`3h`/`2d`/`7c` +2 suit variants match Dart); scaffolded SoftPulse `trap` one-per-press PRESENT (`As`/`Ad`·`Ac`/`7s`/`2h` +2 suit variants); unguided SoftPulse `avoid` one-per-press densify PRESENT.
- Curriculum **LPT-303** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-718/719/303/716/721/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Mix-five SoftPulse residual **LPT-721** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-03-*: interactive structural clean on tip except LPT-718 SoftPulse + LPT-719 cite residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded sizing `fixed`+variants — do not reopen LPT-627; unguided/checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15n tip fae539b9 (Adjust-LAG Prefer → Mix-five SoftPulse LPT-721 Prefer)

- Tip-stable `fae539b9` after Adjust-LAG SoftPulse Prefer fold on tip. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Mix-five SoftPulse residual re-check `lesson-06-13-01-01/02/03/04` / `act-06-13-01-*`: first-child SoftPulse CARDS→SEATS→EVIDENCE + `explainGrading` "Cards → Seats → Evidence." + Dart `ExploitEvidenceDemo.points` CARDS/SEATS/EVIDENCE (captions Equal holdings / Type differs / Prove before exploit) / `LessonExploitEvidenceExplainTable` + coachMedia "Five models. Same cards. Change only with evidence." still pre-split under Station-thin-only → residual **LPT-721** still To Do (needs-human; Relates LPT-306 — do not re-add needs-human on curriculum); successors SoftPulse NIT CHECK-RAISE→FOLD / LAG BARREL→CALL / TENDENCY→LINE content-driven (do not reopen LPT-669); guided SoftPulse `cs` SoftPulse map PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants match Dart); scaffolded SoftPulse `nit` one-per-press SoftPulse map PRESENT; unguided SoftPulse `lag` one-per-press SoftPulse map PRESENT; checkpoint SoftPulse `tag` kind `none` densify PRESENT under cite-tendency — no companion residual.
- Curriculum **LPT-306** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-721/306/718/719/790/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER preflop-to-flop SoftPulse residual **LPT-790** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-13-01-*: interactive structural clean on tip except LPT-721 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded/unguided sizing `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15o tip 87ff0c49 (#2530 Mix-five Prefer → preflop-to-flop SoftPulse LPT-790 Prefer)

- Tip-stable `87ff0c49` after #2530 SoftPulse residual Prefer LPT-721 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-07-01-01-01/02/03` / `act-07-01-01-*`: first-child SoftPulse REASON→CONFIRM→CANCEL + `explainGrading` "Reason → Confirm → Cancel." + Dart `PreflopFlopPlanDemo.points` / `LessonPreflopFlopPlanExplainTable` still pre-split under thesis-only → residual **LPT-790** still To Do (Relates LPT-310 — do not re-add needs-human on curriculum); successors SoftPulse TEXTURE→CONFIRM OR CANCEL / DEAD PLAN→LET GO content-driven (do not reopen LPT-669); guided SoftPulse `dead` densify PRESENT; scaffolded SoftPulse `value` densify PRESENT; unguided SoftPulse `thesis` densify PRESENT; checkpoint SoftPulse `abandon` under abandon-dead-plans — no companion residual.
- Curriculum **LPT-310** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-790/310/721/794/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Map SoftPulse residual **LPT-794** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-01-01-*: interactive structural clean on tip except LPT-790 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15p tip 504b974a (#2531 preflop-to-flop Prefer → Map SoftPulse LPT-794 Prefer)

- Tip-stable `504b974a` after #2531 SoftPulse residual Prefer LPT-790 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Map SoftPulse residual re-check `lesson-07-02-01-01/02/03` / `act-07-02-01-*`: first-child SoftPulse BARREL→GIVE-UP→MAP + `explainGrading` "Barrel → Give-up → Map." + Dart `TurnMapDemo.points` BARREL/GIVE-UP/MAP (captions Cards to continue / Cards to kill / Before flop bet) / layout "Tap Barrel, then Give-up, then Map." still pre-split under List-turn-continue-cards-only → residual **LPT-794** still To Do (needs-human; Relates LPT-314 — do not re-add needs-human on curriculum); successors SoftPulse BRICK→GIVE UP / CONTINUE→GIVE-UP→MAP content-driven (do not reopen LPT-669); guided SoftPulse `ok` densify PRESENT; scaffolded SoftPulse `give` one-per-press densify PRESENT; unguided SoftPulse `avoid` one-per-press densify PRESENT; checkpoint SoftPulse `list` kind `none` densify PRESENT under map-definition matches — no companion residual.
- Curriculum **LPT-314** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-794/314/790/795/796/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Compose SoftPulse residual **LPT-795** (+ rule **LPT-796**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-02-01-*: interactive structural clean on tip except LPT-794 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; outcome-tile `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15q tip cc736101 (#2532 Map Prefer → Compose SoftPulse LPT-795 Prefer)

- Tip-stable `cc736101` after #2532 SoftPulse residual Prefer LPT-794 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Compose SoftPulse residual re-check `lesson-07-03-01-01/02/03` / `act-07-03-01-*`: first-child SoftPulse VALUE→BLUFF→HOLD + `explainGrading` "Value → Bluff → Hold." + Dart `RiverCompositionDemo.points` VALUE/BLUFF/HOLD (captions Needs calls / Needs folds / Check trash) / `LessonRiverCompositionExplainTable` still pre-split under Choose-river-value-only → residual **LPT-795** still To Do (needs-human; Relates LPT-317 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `rule` kind `none` densify PRESENT under value-only → residual **LPT-796** still To Do; successors SoftPulse BLOCKER→FEWER CALLS / NO STORY→CHECK content-driven (do not reopen LPT-669); guided SoftPulse `val` PRESENT (`As`/`Ad`·`Ac`/`9s`/`4h`/`2d`/`7c` +2 suit variants; poker_action_sizing densify N/A); scaffolded SoftPulse `block` one-per-press densify PRESENT; unguided SoftPulse `check` one-per-press densify PRESENT.
- Curriculum **LPT-317** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-795/796/317/794/798/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Pot SoftPulse residual **LPT-798** (+ ranges/SPR **LPT-799**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-03-01-*: interactive structural clean on tip except LPT-795 SoftPulse + LPT-796 rule residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided sizing `fixed`+variants — do not reopen LPT-627; scaffolded/unguided/checkpoint `deal.mode` `none` — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-14

## Fold 2026-10-15r tip 9f67745a (#2533 Compose Prefer → Pot SoftPulse LPT-798 Prefer)

- Tip-stable `9f67745a` after #2533 SoftPulse residual Prefer LPT-795 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-07-04-01-01/02/03` / `act-07-04-01-*`: first-child SoftPulse LIMPED→SRP→3-4BET + `explainGrading` "Limped → SRP → 3-bet/4-bet." + Dart `PotTypePlansDemo.points` / `LessonPotTypePlansExplainTable` still pre-split under limped-pots-only → residual **LPT-798** still To Do (Relates LPT-320 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `both` under Plan 3-bet/4-bet → **LPT-799** still To Do; successors SoftPulse HEADS-UP→C-BET / LOW SPR→COMMIT content-driven (do not reopen LPT-669); guided SoftPulse `nuts` densify PRESENT; scaffolded SoftPulse `cb` densify PRESENT; unguided SoftPulse `commit` densify PRESENT.
- Curriculum **LPT-320** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-798/799/320/795/800/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER HU SoftPulse residual **LPT-800** (+ player-count **LPT-801**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-04-01-*: interactive structural clean on tip except LPT-798 SoftPulse residual + LPT-799 companion; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15s tip 5c2c3e03 (#2534 Pot Prefer → HU SoftPulse LPT-800 Prefer)

- Tip-stable `5c2c3e03` after #2534 SoftPulse residual Prefer LPT-798 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER HU SoftPulse residual re-check `lesson-07-05-01-01/02/03` / `act-07-05-01-*`: first-child SoftPulse FEWER→THICKER→WIDEN + `explainGrading` "Fewer → Thicker → Widen." + Dart `HuVsMultiwayDemo.points` FEWER/THICKER/WIDEN (captions Bluff less MW / Value up MW / HU selected bluffs) / `LessonHuVsMultiwayExplainTable` still pre-split under bluff-less-only → residual **LPT-800** still To Do (needs-human; Relates LPT-323 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `input` kind `none` densify PRESENT ("Player count is?" / tile "A first-class planning input") under bluff-less-only → residual **LPT-801** still To Do; successors SoftPulse MULTIWAY→THICK VALUE / HEADS-UP→STEAL MORE content-driven (do not reopen LPT-669); guided SoftPulse `no` densify PRESENT; unguided SoftPulse `thick` one-per-press densify PRESENT; scaffolded SoftPulse `higher` one-per-press densify PRESENT.
- Curriculum **LPT-323** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-800/801/323/798/802/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Stack SoftPulse residual **LPT-802** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-05-01-*: interactive structural clean on tip except LPT-800 SoftPulse + LPT-801 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; outcome-tile `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15t tip ca4f734c (#2535 HU Prefer → Stack SoftPulse LPT-802 Prefer)

- Tip-stable `ca4f734c` after #2535 HU SoftPulse Prefer re-check LPT-800 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Stack SoftPulse residual re-check `lesson-07-06-01-01/02/03` / `act-07-06-01-*`: first-child SoftPulse SHORT→DEEP→EFFECTIVE + `explainGrading` "Short → Deep → Effective." + Dart `StackDepthPlansDemo.points` SHORT/DEEP/EFFECTIVE (captions Commit earlier / Implied odds / Recalc each hand) / `LessonStackDepthPlansExplainTable` still pre-split under commit-short-only → residual **LPT-802** still To Do (needs-human; Relates LPT-326 — do not re-add needs-human on curriculum); coachMedia still "Effective stack rewrites the plan every hand."; checkpoint SoftPulse `every` kind `none` densify PRESENT under recalc-effective matches — no companion residual; successors SoftPulse DEEP→IMPLIED ODDS / SHORTER STACK→PLAN content-driven (do not reopen LPT-669); guided SoftPulse `commit` densify PRESENT; scaffolded SoftPulse `yes` one-per-press densify PRESENT; unguided SoftPulse `40` one-per-press densify PRESENT; distinct from S2 **LPT-748**.
- Curriculum **LPT-326** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-802/326/800/725/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Same-cards SoftPulse residual **LPT-725** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-06-01-*: interactive structural clean on tip except LPT-802 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; outcome-tile `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15u tip 454a9175 (#2536 Stack Prefer → Same-cards SoftPulse LPT-725 Prefer)

- Tip-stable `454a9175` after #2536 Stack SoftPulse Prefer re-check LPT-802 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Same-cards SoftPulse residual re-check `lesson-07-07-01-01/02/03/04` / `act-07-07-01-*`: first-child SoftPulse CARDS→MODELS→CITE + `explainGrading` "Cards → Models → Cite." + Dart `SameCardsTypesDemo.points` CARDS/MODELS/CITE (captions Same holdings / Five types / Tendency or baseline) / `LessonSameCardsTypesExplainTable` still pre-split under station-value (objective still unit string "Change lines by type with citations") → residual **LPT-725** still To Do (needs-human; Relates LPT-330 — do not re-add needs-human on curriculum); successors SoftPulse TAG CHECK-RAISE→CAREFUL / LAG BARREL→CALL / NO EVIDENCE→BASELINE content-driven (do not reopen LPT-669); guided SoftPulse `bet` PRESENT (`Ah`/`Kd`·`Kc`/`8s`/`3h` +2 suit variants; poker_action_sizing densify N/A); scaffolded SoftPulse `fold` one-per-press PRESENT; unguided SoftPulse `call` one-per-press PRESENT (turn +`2d`); checkpoint SoftPulse `base` kind `none` densify PRESENT under baseline-without-evidence matches — no companion residual.
- Curriculum **LPT-330** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-725/330/802/726/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Type-board SoftPulse residual **LPT-726** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-07-01-*: interactive structural clean on tip except LPT-725 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded/unguided sizing `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15v tip 17803faf (#2537 Same-cards Prefer → Type-board SoftPulse LPT-726 Prefer)

- Tip-stable `17803faf` after #2537 SoftPulse residual Prefer LPT-725 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-07-08-01-01/02/03` / `act-07-08-01-*`: first-child SoftPulse TYPE→BOARD→LINE→SIZE + `explainGrading` "Type → Board → Line → Size." + Dart `TypeBoardLineDemo.points` / `LessonTypeBoardLineExplainTable` still pre-split under type-and-board-only → residual **LPT-726** still To Do (Relates LPT-333 — do not re-add needs-human on curriculum; Duplicate LPT-729 — do not reopen); successors SoftPulse LINE→SIZE / FOUR INPUTS→ONE ACTION content-driven (do not reopen LPT-669); guided SoftPulse `call` SoftPulse map PRESENT; scaffolded SoftPulse `raise` SoftPulse map PRESENT; unguided SoftPulse `fold` SoftPulse map PRESENT; checkpoint SoftPulse `four` under one-coherent-action — no companion residual.
- Curriculum **LPT-333** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-726/333/725/727/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Leak SoftPulse residual **LPT-727** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-08-01-*: interactive structural clean on tip except LPT-726 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); SoftPulse map PRESENT — do not reopen LPT-628.

## Fold 2026-10-15w tip 17c46a63 (#2538 Type-board Prefer → Leak SoftPulse LPT-727 Prefer)

- Tip-stable `17c46a63` after #2538 SoftPulse residual Prefer LPT-726 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Leak SoftPulse residual re-check `lesson-07-09-01-01/02/03` / `act-07-09-01-*`: first-child SoftPulse LEAK→BOOK→REVIEW + `explainGrading` "Leak → Book → Review." + Dart `LeakReviewBookDemo.points` LEAK/BOOK/REVIEW (captions Specific note / Written defaults / On a schedule) / `LessonLeakReviewBookExplainTable` / layout "Tap Leak, Book, and Review." still pre-split under name-leaks-only → residual **LPT-727** still To Do (needs-human; Relates LPT-336 — do not re-add needs-human on curriculum; Duplicate LPT-730 — do not reopen); successors SoftPulse COMMON SPOT→DEFAULT / AFTER SESSION→REVIEW content-driven (do not reopen LPT-669); guided SoftPulse `spec` densify PRESENT; scaffolded SoftPulse `book` one-per-press densify PRESENT; unguided SoftPulse `sched` one-per-press densify PRESENT; checkpoint SoftPulse `base` kind `none` densify PRESENT under default-lines matches — no companion residual.
- Curriculum **LPT-336** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-727/336/726/725/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Capstone `lesson-07-10-0*` synthesis clean check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-09-01-*: interactive structural clean on tip except LPT-727 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive outcome tiles `deal.mode` `none` — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15x tip 71f37021 (#2539 Leak Prefer → Capstone lesson-07-10-0* Prefer)

- Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen). Catalog parents Done — no open-parent sync.
- Prefer NEVER Capstone `lesson-07-10-01-capstone-srp` / `02-capstone-3bet` / `03-capstone-multiway-deep` / `04-capstone-limped` / `05-capstone-4bet` / `act-07-10-0*`: all five explains SoftPulse + `explainGrading` concept-aligned (PLAN→UPDATE→FINISH / SPR→TURN→CLOSE / NUTS→DEEP→NO-BLUFF / NUTS→VALUE→THIN / SPR→COMMIT→NO HERO) + Dart Capstone*Demo points match; hands `authored_multi_step_hand` `assessmentRole` `transfer` + empty pressHints in `NO_HINT_ACTIVITY_IDS` / Dart `noHintIds` — **LPT-348** Done (do not reopen LPT-626/667); fixed+2 suit variants match Dart `resolveToyHandStepSpot` (Ah/Qd·Kc7s2h2d9c / Ah/Qd·Qs8h3d2d7c / Ah/Qh·Jh8h2c3d9c / Ah/Kh·Kd9c4h2s8d / Kh/Kd·Qs8h3d2dAd); synthesis containers — skip curriculum-split / no SoftPulse residual.
- Prefer NEVER live-warmup `lesson-07-11-01-live-warmup-prep`: still unsplit — SoftPulse CHECKLIST→DEFAULTS→ONE HAND residual N/A until **LPT-351** splits (still To Do needs-human; teachSpec **LPT-349** Done — do not clone). Prefer NEVER Final `lesson-07-12-01-five-type-final`: assessment container — **LPT-352** Done.
- Tip-commented LPT-348/351/349/352/676/727/198/216; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER SoftPulse residual **LPT-676** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-10-0*: Capstone structural clean on tip; SoftPulse explains content-driven/wired; transfer hands intentional no-Hint — do not reopen LPT-626/667/348.

## Fold 2026-10-14

## Fold 2026-10-15z tip f6d561d6 (#2542 SoftPulse LPT-676 Prefer → weigh-SPR residual LPT-677 Prefer)

- Tip-stable `f6d561d6` after #2542 SoftPulse residual Prefer LPT-676 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER residual re-check `lesson-04-05-01-01/02/03` / `act-04-05-01-*`: SoftPulse SPR→LOW→HIGH under Estimate SPR **concept-aligned**; weigh-SPR habit checkpoint SoftPulse `before` still under Estimate SPR-only → residual **LPT-677** still To Do (Relates LPT-182 — do not re-add needs-human on curriculum); successors SoftPulse LOW SPR→COMMIT / HIGH SPR→FLEXIBLE content-driven (do not reopen LPT-669); guided SoftPulse `spr-4` densify PRESENT; scaffolded SoftPulse `commit` SoftPulse map PRESENT; unguided SoftPulse `flexible` SoftPulse map PRESENT.
- Curriculum **LPT-182** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-677/182/676/681/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Estimate SoftPulse residual **LPT-681** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-04-05-01-*: interactive structural clean on tip except LPT-677 checkpoint placement residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15aa tip 545ee706 (#2543 weigh-SPR Prefer → Estimate SoftPulse LPT-681 Prefer)

- Tip-stable `545ee706` after #2543 weigh-SPR Prefer LPT-677 fold (tip also advanced #2544 ui-agent). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Estimate SoftPulse residual re-check `lesson-05-03-01-01/02/03` / `act-05-03-01-*`: first-child SoftPulse IMPLIED→REVERSE→SECOND + `explainGrading` "Implied → Reverse → Second." + Dart `ImpliedOddsDemo` / `CoachDialogueVisualKind.impliedOdds` (IMPLIED "They pay later" / REVERSE "You pay later" / SECOND "Trap improves") + coachMedia still defines reverse/second-best still pre-split under estimate-only → residual **LPT-681** still To Do (Relates LPT-230 — do not re-add needs-human on curriculum); successors SoftPulse REVERSE→DOMINATED→FOLD / NON-NUT→MULTIWAY→SKIP content-driven (do not reopen LPT-669); guided SoftPulse `call-io` densify PRESENT (`Jh`/`9d`·`8s`/`7c`/`2d` +2 suit variants); scaffolded SoftPulse `rio` densify PRESENT; unguided SoftPulse `nonut` densify PRESENT; checkpoint SoftPulse `depth-pay` kind `none` densify PRESENT (`ioDepthPay`) under Estimate — no companion residual.
- Curriculum **LPT-230** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-681/230/682/677/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Thin SoftPulse residual **LPT-682** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-03-01-*: interactive structural clean on tip except LPT-681 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); SoftPulse maps PRESENT — do not reopen LPT-625; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15ab tip 2cd50ab6 (#2547 Estimate Prefer → Thin SoftPulse LPT-682 Prefer)

- Tip-stable `2cd50ab6` after #2547 Estimate SoftPulse Prefer Recent fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Thin SoftPulse residual re-check `lesson-05-04-01-01/02/03` / `act-05-04-01-*`: first-child SoftPulse THIN→CATCH→BARRELS + `explainGrading` "Thin → Catch → Barrels." + Dart `ThinValueDemo` / `LessonThinValueExplainTable` (THIN "Extract light" / CATCH "Hero call" / BARRELS "Fire multi-street") + coachMedia "Thin value needs calls. Bluff-catches need wide barrels." still pre-split under thin-value-only → residual **LPT-682** still To Do (needs-human; Relates LPT-233 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `read` kind `none` densify PRESENT ("Same hand, different types — what must change?") under thin-value-only → residual **LPT-683** still To Do; successors SoftPulse MANIAC→BARREL→CALL / NIT→FOLDS→CHECK content-driven (do not reopen LPT-669); guided SoftPulse `tv` PRESENT (`Jh`/`9d`·`Kc`/`9s`/`4h`/`2d`/`7c` +2 suit variants; SoftPulse map PRESENT); scaffolded SoftPulse `call-m` one-per-press PRESENT; unguided SoftPulse `check-nit` one-per-press PRESENT.
- Curriculum **LPT-233** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-682/683/233/684/681/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Lines SoftPulse residual **LPT-684** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-04-01-*: interactive structural clean on tip except LPT-682 SoftPulse + LPT-683 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); poker_action_sizing densify N/A for guided/scaffolded/unguided SoftPulse maps; checkpoint `deal.mode` `none` — do not file handFamily; densify PRESENT on checkpoint — do not reopen LPT-628.

## Fold 2026-10-15ac tip 9b988c0c (#2548 Thin Prefer → Lines SoftPulse LPT-684 Prefer)

- Tip-stable `9b988c0c` after #2548 Thin SoftPulse Prefer LPT-682 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Lines SoftPulse residual re-check `lesson-05-05-01-01/02/03` / `act-05-05-01-*`: first-child SoftPulse X/R→PROBE→DELAY→DONK + `explainGrading` "Check-raise → Probe → Delay → Donk." + Dart `LineStoriesDemo` / `LessonLineStoriesExplainTable` (X/R "Raise after check" / PROBE "Bet into check" / DELAY / DONK "Lead the raiser") + coachMedia "Lines mean ranges. Check-raise, probe, delay, donk — each updates the story." still pre-split under check-raises-only → residual **LPT-684** still To Do (needs-human; Relates LPT-236 — do not re-add needs-human on curriculum); successors SoftPulse PROBE→DELAY→PLAN / DONK→STRONG→AIR content-driven (do not reopen LPT-669); guided SoftPulse `strong` densify PRESENT; scaffolded SoftPulse `probe` one-per-press PRESENT (`9h`/`8d`·`Kc`/`9s`/`3h` +2 suit variants); unguided SoftPulse `polar` densify PRESENT; checkpoint SoftPulse `delay` kind `none` densify PRESENT under probes-and-delays — no companion residual.
- Curriculum **LPT-236** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-684/236/685/682/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Timing SoftPulse residual **LPT-685** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-05-01-*: interactive structural clean on tip except LPT-684 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15ae tip b9f5a676 (#2551 Timing Prefer → Dynamics SoftPulse LPT-686 Prefer)

- Tip-stable `b9f5a676` after #2551 Timing SoftPulse Prefer LPT-685 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Dynamics SoftPulse residual re-check `lesson-05-08-01-01/02/03` / `act-05-08-01-*`: first-child SoftPulse STUCK→TILTED→GEARS + `explainGrading` "Stuck → Tilted → Gears." + coachMedia "Tables change. Stuck, tilted, tired, or shifting gears — update." + Dart `TablesChangeDemo.points` STUCK/TILTED/GEARS still pre-split under tilted/stuck-only → residual **LPT-686** still To Do (Relates LPT-247 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `temp` kind `none` densify PRESENT (prompt "Dynamic reads should be?" / Fresh samples) under Gear changes → residual **LPT-687** still To Do; successors SoftPulse GEAR→CHANGE→SAMPLE / COOLER→CHASE→RESET content-driven (do not reopen LPT-669); guided SoftPulse `stuck` densify PRESENT; scaffolded SoftPulse `gear` one-per-press densify PRESENT; unguided SoftPulse `reset` map PRESENT (`Jh`/`Td`·`Kc`/`9s`/`4h`/`2d`/`7c` +2 suit variants).
- Curriculum **LPT-247** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-686/687/247/690/685/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Session SoftPulse residual **LPT-690** (+ **LPT-691**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-08-01-*: interactive structural clean on tip except LPT-686 SoftPulse + LPT-687 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/scaffolded/checkpoint outcome-tile `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15ad tip 0ed4c6ce (#2548/#2550 Lines Prefer → Timing SoftPulse LPT-685 Prefer)

- Tip-stable `0ed4c6ce` after #2548/#2550 Lines SoftPulse Prefer LPT-684 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Timing SoftPulse residual re-check `lesson-05-07-01-01/02/03` / `act-05-07-01-*`: first-child SoftPulse TIMING→SIZING→CLUES + `explainGrading` "Timing → Sizing → Clues." + Dart `TimingCluesDemo.points` TIMING/SIZING/CLUES (captions How fast they act / How much they bet / Nudge the model) / `LessonTimingCluesExplainTable` + coachMedia "Timing and sizing are clues, not mind-reading. Small updates only." still pre-split under timing-soft-only → residual **LPT-685** still To Do (needs-human; Relates LPT-244 — do not re-add needs-human on curriculum); successors SoftPulse TINY→BIG→RANGE / TELL→MYTH→REJECT content-driven (do not reopen LPT-669); guided SoftPulse `soft` densify PRESENT; scaffolded SoftPulse `weakish` one-per-press densify PRESENT; unguided SoftPulse `reject` one-per-press densify PRESENT; checkpoint SoftPulse `tiny` kind `none` densify PRESENT under timing-soft — no companion residual.
- Curriculum **LPT-244** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-685/244/686/684/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Dynamics SoftPulse residual **LPT-686** (+ **LPT-687**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-07-01-*: interactive structural clean on tip except LPT-685 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; outcome-tile `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15af tip ce7cbd1e (#2552 Dynamics Prefer → Session SoftPulse LPT-690 Prefer)

- Tip-stable `ce7cbd1e` after #2552 Dynamics SoftPulse Prefer LPT-686 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Session SoftPulse residual re-check `lesson-05-09-01-01/02/03` / `act-05-09-01-*`: first-child SoftPulse QUIT→GUARD→FIRST + `explainGrading` "Quit → Guard → First." + coachMedia "…Guardrails first." + Dart `GuardrailsDemo.points` QUIT/GUARD/FIRST still pre-split under stop-loss-only → residual **LPT-690** still To Do (Relates LPT-250 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `edge` kind `none` densify PRESENT (prompt "Session discipline is part of?" / Your edge) under End sessions → residual **LPT-691** still To Do; successors SoftPulse BANKROLL→STAKES→DECLINE / TIRED→WILD→CASH OUT content-driven (do not reopen LPT-669); guided SoftPulse `stop` densify PRESENT; scaffolded SoftPulse `decline` one-per-press densify PRESENT; unguided SoftPulse `cash` one-per-press densify PRESENT.
- Curriculum **LPT-250** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-690/691/250/692/686/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Range SoftPulse residual **LPT-692** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-05-09-01-*: interactive structural clean on tip except LPT-690 SoftPulse + LPT-691 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/scaffolded/unguided/checkpoint outcome-tile `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15ag tip 7d58c26a (#2553 Session Prefer → Range SoftPulse LPT-692 Prefer)

- Tip-stable `7d58c26a` after #2553 SoftPulse residual Prefer LPT-690 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-01-01-01/02/03` / `act-06-01-01-*`: first-child SoftPulse RANGE→NUT→ADVANTAGE + `explainGrading` "Range → Nut → Advantage." + Dart `RangeAdvantageDemo.points` / `LessonRangeAdvantageExplainTable` still pre-split under range-advantage-only → residual **LPT-692** still To Do (Relates LPT-254 — do not re-add needs-human on curriculum); SoftPulse Prefer path catch-up Dynamics LPT-686 (+LPT-687) / Session LPT-690 (+LPT-691) still To Do; successors SoftPulse NUTS→PAIRED→CALLER / RANGE→NUTS→BET content-driven (do not reopen LPT-669); guided SoftPulse `pfr` densify PRESENT; scaffolded SoftPulse `caller-nuts` densify PRESENT; unguided SoftPulse `cbet` SoftPulse map PRESENT; checkpoint SoftPulse `press` under press-both — no companion residual.
- Curriculum **LPT-254** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-692/254/690/694/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Spot-caps SoftPulse residual **LPT-694** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-01-01-*: interactive structural clean on tip except LPT-692 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15ah tip f86d40a1 (#2554 Range Prefer → Spot-caps SoftPulse LPT-694 Prefer)

- Tip-stable `f86d40a1` after #2554 SoftPulse residual Prefer LPT-692 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-03-01-01/02/03` / `act-06-03-01-*`: first-child SoftPulse CAPPED→UNCAPPED→NUTS + `explainGrading` "Capped → Uncapped → Nuts." + Dart `CappedUncappedDemo.points` (CAPPED/UNCAPPED/NUTS) / layout "Tap Capped, then Uncapped, then Nuts." still pre-split under spot-caps-only → residual **LPT-694** still To Do (Relates LPT-260 — do not re-add needs-human on curriculum; race clone LPT-695 Done — do not reopen); successors SoftPulse RAISE→BET→RESPECT / CAPPED→THIN→BLUFF content-driven (do not reopen LPT-669); guided SoftPulse `cap` densify PRESENT; unguided SoftPulse `uncap` densify PRESENT; scaffolded SoftPulse `bet` map PRESENT (fixed Jh9d/Kc9s4h2d7c + 2 suit variants); checkpoint SoftPulse `attack` kind `none` densify PRESENT under attack-caps — no companion residual.
- Curriculum **LPT-260** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-694/260/696/692/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Polar SoftPulse residual **LPT-696** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-03-01-*: interactive structural clean on tip except LPT-694 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/unguided/checkpoint outcome-tile `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-14


## Fold 2026-10-15ai tip c1a82425 (#2555 Spot-caps Prefer → Polar SoftPulse LPT-696 Prefer; mid-run #2556)

- Tip-stable `c1a82425` after #2555 Spot-caps SoftPulse Prefer LPT-694 fold (mid-run #2556 SoftPulse-quiet densify; polar residual unchanged). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-04-01-01/02/03` / `act-06-04-01-*`: first-child SoftPulse POLAR→MERGED→SIZE + `explainGrading` "Polar → Merged → Size." + Dart `PolarMergedDemo.points` (POLAR/MERGED/SIZE) / layout "Tap Polar, then Merged, then Size." still pre-split under polarized-sizing-only → residual **LPT-696** still To Do (Relates LPT-264 — do not re-add needs-human on curriculum); successors SoftPulse MERGED→MEDIUM→VALUE / SIZE→SHAPE→MATCH content-driven (do not reopen LPT-669); guided SoftPulse `polar` densify PRESENT; scaffolded SoftPulse `mid` one-per-press PRESENT (fixed JhTd/QcTs3h2d7c + 2 suit variants match Dart LPT-395); unguided SoftPulse `mismatch` densify PRESENT; checkpoint SoftPulse `thin` kind `none` densify PRESENT under merged-thin-value — no companion residual.
- Curriculum **LPT-264** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-696/264/699/694/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Overbet SoftPulse residual **LPT-699** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-04-01-*: interactive structural clean on tip except LPT-696 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/unguided/checkpoint outcome-tile `deal.mode` `none` — do not file handFamily; scaffolded stays fixed+variants second-pair honesty.


## Fold 2026-10-14


## Fold 2026-10-15aj tip 885142d5 (#2557 Polar Prefer → Overbet SoftPulse LPT-699 Prefer)

- Tip-stable `885142d5` after #2557 Polar SoftPulse Prefer LPT-696 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-05-01-01/02/03` / `act-06-05-01-*`: first-child SoftPulse OVERBET→POLAR→GEO + `explainGrading` "Overbet → Polar → Geometry." + Dart `OverbetGeometryDemo.points` (OVERBET/POLAR/GEO) / `LessonOverbetGeometryExplainTable` still pre-split under polar-overbets-only → residual **LPT-699** still To Do (Relates LPT-267 — do not re-add needs-human on curriculum; race clone LPT-698 Done — do not reopen); successors SoftPulse FLOP→TURN→RIVER / HUGE→MEDIUM→AVOID content-driven (do not reopen LPT-669); guided SoftPulse `polar-ob` densify PRESENT; scaffolded SoftPulse `mid` one-per-press PRESENT (fixed As/Kd·Ah/7c/2d/9s + 2 suit variants match Dart); unguided SoftPulse `avoid` densify PRESENT; checkpoint SoftPulse `multi` kind `none` densify PRESENT under geometric-sizes — no companion residual.
- Curriculum **LPT-267** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-699/267/700/696/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Blockers SoftPulse residual **LPT-700** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-05-01-*: interactive structural clean on tip except LPT-699 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/unguided/checkpoint outcome-tile `deal.mode` `none` — do not file handFamily; scaffolded stays fixed+variants geometric-turn honesty.

## Fold 2026-10-14

## Fold 2026-10-15ak tip e08ce374 (#2558 Overbet Prefer → Blockers SoftPulse LPT-700 Prefer)

- Tip-stable `e08ce374` after #2558 SoftPulse residual Prefer LPT-699 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-06-01-01/02/03` / `act-06-06-01-*`: first-child SoftPulse BLOCK→USE→NO EV + `explainGrading` "Block → Use → No EV." + Dart `BlockersDemo.points` / `LessonBlockersExplainTable` still pre-split under bluff-blockers-only → residual **LPT-700** still To Do (Relates LPT-270 — do not re-add needs-human on curriculum); successors SoftPulse CATCH→UNBLOCK→BLUFFS / TWEAK→NO EV content-driven (do not reopen LPT-669); guided SoftPulse `as` densify PRESENT; scaffolded SoftPulse `unblock` densify PRESENT; unguided SoftPulse `tweak` densify PRESENT; checkpoint SoftPulse `no` under no-fake-ev — no companion residual.
- Curriculum **LPT-270** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-700/270/699/701/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Defend SoftPulse residual **LPT-701** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-06-01-*: interactive structural clean on tip except LPT-700 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15al tip 8e19f24b (#2559 Blockers Prefer → Defend SoftPulse LPT-701 Prefer)

- Tip-stable `8e19f24b` after #2559 SoftPulse residual Prefer LPT-700 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-07-01-01/02/03` / `act-06-07-01-*`: first-child SoftPulse DEFEND→BLUFF→ENOUGH + `explainGrading` "Defend → Bluff → Enough." + Dart `DefendEnoughDemo.points` DEFEND/BLUFF/ENOUGH (captions Continue enough / Over-bluffs fail / No fake %) / `LessonDefendEnoughExplainTable` still pre-split under continue-catchers-only → residual **LPT-701** still To Do (Relates LPT-273 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `punish` kind `none` densify PRESENT (prompt "Minimum defense goal?" / Punish over-bluffs) under Continue with stronger catchers → residual **LPT-702** still To Do; successors SoftPulse THIRD PAIR→SCARY→FOLD / MDF→INTUITION content-driven (do not reopen LPT-669); guided SoftPulse `strong` densify PRESENT; scaffolded SoftPulse `fold` one-per-press PRESENT (`9h`/`7d`·`Kc`/`Qh`/`9d`/`4c`/`8s` +2 suit variants match Dart); unguided SoftPulse `int` one-per-press densify PRESENT.
- Curriculum **LPT-273** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-701/702/273/700/703/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Mix SoftPulse residual **LPT-703** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-07-01-*: interactive structural clean on tip except LPT-701 SoftPulse + LPT-702 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/unguided/checkpoint outcome-tile `deal.mode` `none` — do not file handFamily; scaffolded stays fixed+variants third-pair honesty.

## Fold 2026-10-15am tip 243fb1b8 (#2560 Defend Prefer → Mix SoftPulse LPT-703 Prefer + SoftPulse Prefer path catch-up)

- Tip-stable `243fb1b8` after #2560 SoftPulse residual Prefer LPT-701 fold (diary-only; SoftPulse Prefer path lagged — catch-up this fold). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- SoftPulse Prefer path catch-up: tip `8e19f24b` Prefer NEVER SoftPulse residual **LPT-701** still To Do (DEFEND→BLUFF→ENOUGH under continue-catchers-only; companion **LPT-702**) before Mix Prefer.
- Prefer NEVER SoftPulse residual re-check `lesson-06-08-01-01/02/03` / `act-06-08-01-*`: first-child SoftPulse MIX→PURPOSE→STRONG + `explainGrading` "Mix → Purpose → Strong." + Dart `MixedStrategyDemo.points` (MIX/PURPOSE/STRONG; captions With a reason / Not coin-flip / Mix sometimes) / `LessonMixedStrategyExplainTable` / layout "Tap Mix, then Purpose, then Strong." still pre-split under mix-strong-only → residual **LPT-703** still To Do (Relates LPT-277 — do not re-add needs-human on curriculum); successors SoftPulse TYPE→STATION→LESS / RANDOM→PURPOSE content-driven (do not reopen LPT-669); guided SoftPulse `protect` one-per-press PRESENT (`7h`/`7d`·`7c`/`Kd`/`2s` +2 suit variants match Dart); scaffolded SoftPulse `less` densify PRESENT; unguided SoftPulse `no` densify PRESENT; checkpoint SoftPulse `freq` kind `none` densify PRESENT under no-pure-random — no companion residual.
- Curriculum **LPT-277** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-703/277/701/702/704/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Plan-3bet SoftPulse residual **LPT-704** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-08-01-*: interactive structural clean on tip except LPT-703 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; scaffolded/unguided/checkpoint outcome-tile `deal.mode` `none` — do not file handFamily; guided stays fixed+variants set-of-sevens honesty.

## Fold 2026-10-15an tip 2e99156c (#2561 Mix Prefer → Plan-3bet SoftPulse LPT-704 Prefer)

- Tip-stable `2e99156c` after #2561 SoftPulse residual Prefer LPT-703 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-09-01-01/02/03` / `act-06-09-01-*`: middle-child SoftPulse 3BET→4BET→DEPTH + `explainGrading` "3-bet → 4-bet → Depth." + Dart `ThreeBetFourBetSprDemo.points` (3BET/4BET/DEPTH; captions Shrink ranges / Lower SPR / Decides commit) / `LessonThreeBetFourBetSprExplainTable` / layout "Tap 3-Bet, then 4-Bet, then Depth." still pre-split under plan-3bet-spr → residual **LPT-704** still To Do (Relates LPT-282 — do not re-add needs-human on curriculum; reused explain is middle-child, not first-child); careful-4bet SoftPulse 4BET→STRONG→CAREFUL + ego SoftPulse 4BET→EGO→AVOID content-driven (do not reopen LPT-669); guided SoftPulse `careful` densify PRESENT; scaffolded SoftPulse `small` one-per-press PRESENT (`Ah`/`Qd`·`8c`/`3h`/`2s` +2 suit variants match Dart); unguided SoftPulse `avoid` densify PRESENT; checkpoint SoftPulse `spr` kind `none` densify PRESENT under plan-3bet-spr — no companion residual.
- Curriculum **LPT-282** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-704/282/703/705/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Hard-folds SoftPulse residual **LPT-705** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-09-01-*: interactive structural clean on tip except LPT-704 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/unguided/checkpoint outcome-tile `deal.mode` `none` — do not file handFamily; scaffolded stays fixed+variants deep AQo miss honesty.

## Fold 2026-10-15ao tip 12c2f724 (#2563 Plan-3bet Prefer → Hard-folds SoftPulse LPT-705 Prefer)

- Tip-stable `12c2f724` after #2563 SoftPulse residual Prefer LPT-704 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-10-01-01/02/03` / `act-06-10-01-*`: first-child SoftPulse HARD→COOLER→EGO + `explainGrading` "Hard → Cooler → Ego." + Dart `HardFoldCoolerDemo.points` (HARD/COOLER/EGO; captions Save buy-ins / Not a leak / Call mistake) / `LessonHardFoldCoolerExplainTable` / layout "Tap Hard, then Cooler, then Ego." still pre-split under hard-folds-only → residual **LPT-705** still To Do (Relates LPT-285 — do not re-add needs-human on curriculum); successors SoftPulse COOLER→MISTAKE→REVIEW / DUE→EGO→FOLD content-driven (do not reopen LPT-669); guided SoftPulse `fold` one-per-press PRESENT (`Ah`/`9d`·`As`/`7c`/`2h`/`Kd`/`3c` +2 suit variants match Dart); scaffolded SoftPulse `cooler` densify PRESENT; unguided SoftPulse `ego` densify PRESENT; checkpoint SoftPulse `ask` kind `none` densify PRESENT under cooler-or-mistake — no companion residual.
- Curriculum **LPT-285** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-705/285/704/706/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Selective SoftPulse residual **LPT-706** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-10-01-*: interactive structural clean on tip except LPT-705 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; scaffolded/unguided/checkpoint outcome-tile `deal.mode` `none` — do not file handFamily; guided stays fixed+variants top-pair-weak-kicker honesty.

## Fold 2026-10-15ap tip bf3b858c (#2565 → Selective SoftPulse LPT-706 Prefer)

- Tip-stable `bf3b858c` after #2565 ui-agent motion video (non-content). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER SoftPulse residual re-check `lesson-06-11-01-01/02/03` / `act-06-11-01-*`: first-child SoftPulse TIGHT→BARREL→SAMPLE + `explainGrading` "Tight → Barrel → Sample." + Dart `SelectiveAggressionDemo.points` (TIGHT/BARREL/SAMPLE; captions Selective entry / With a plan / Count first) / `LessonSelectiveAggressionExplainTable` + coachMedia "Before labels: who enters tight, then barrels with a plan? Count samples." still pre-split under selective-entry-only → residual **LPT-706** still To Do (Relates LPT-288 — do not re-add needs-human on curriculum); successors SoftPulse CALLED→GIVES UP / TWO HANDS→NOTE BUNDLE content-driven (do not reopen LPT-669); guided SoftPulse `sel` densify PRESENT (`deal.mode` `none`; guideRegion `selectivePlanOk`); scaffolded SoftPulse `disc` one-per-press densify PRESENT (guideRegion `selectiveDisciplined`); unguided SoftPulse `low` one-per-press densify PRESENT (guideRegion `selectiveKeepSampling`); checkpoint SoftPulse `bundle` kind `none` densify PRESENT under wait-for-samples — no companion residual.
- Curriculum **LPT-288** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-706/288/708/705/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Meet-TAG working-model residual **LPT-708** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-01-*: interactive structural clean on tip except LPT-706 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; all interactive acts are `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-15aq tip 916ef421 (#2566 Selective Prefer → Meet-TAG working-model LPT-708 Prefer)

- Tip-stable `916ef421` after #2566 SoftPulse residual Prefer LPT-706 fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Meet-TAG residual re-check `lesson-06-11-02-01/02/03` / `act-06-11-02-*`: first-child SoftPulse TIGHT→AGGRO→MODEL + `explainGrading` "Tight → Aggro → Model." + Dart `TagModelDemo.points` (TIGHT/AGGRO/MODEL) under Introduce TAG — **concept-aligned** (not a SoftPulse residual); companion checkpoint SoftPulse `model` kind `none` densify PRESENT (prompt "TAG is?" / Working model vs Insult) still under Introduce TAG-only → residual **LPT-708** still To Do (Relates LPT-291 — do not re-add needs-human on curriculum); successors SoftPulse FOLDS MOST→PLANNED BARRELS / ENTRY WIDTH→DISCIPLINE content-driven (do not reopen LPT-669); guided SoftPulse `tag` densify PRESENT; scaffolded SoftPulse `diff` densify PRESENT; unguided SoftPulse `tag2` densify PRESENT.
- Curriculum **LPT-291** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-708/291/706/709/710/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Adjust-TAG SoftPulse residual **LPT-709** (+ **LPT-710**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-02-*: interactive structural clean on tip except LPT-708 working-model checkpoint residual; SoftPulse explain concept-aligned / successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; outcome-tile `deal.mode` `none` — do not file handFamily.


## Fold 2026-10-15ar tip 0900148d (#2567 Meet-TAG Prefer → Adjust-TAG SoftPulse LPT-709 Prefer)

- Tip-stable `0900148d` after #2567 Meet-TAG Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Adjust-TAG SoftPulse residual re-check `lesson-06-11-03-01/02/03` / `act-06-11-03-*`: first-child SoftPulse CREDIT→TIGHTER→NO LIGHT + `explainGrading` "Credit → Tighter → No light." + Dart `VsTagsDemo.points` CREDIT/TIGHTER/NO LIGHT (captions Believe their heat / Narrow steals / Skip fancy XR) / `LessonVsTagsExplainTable` / layout "Tap Credit, then Tighter, then No light." still pre-split under Respect-TAG-aggression-only → residual **LPT-709** still To Do (needs-human; Relates LPT-294 — do not re-add needs-human on curriculum); companion checkpoint SoftPulse `cite` kind `none` densify PRESENT (`tagRespectCiteOutcomes` / helper "Versus TAG — pick the cite.") still under Respect-only → residual **LPT-710** still To Do (needs-human; Relates LPT-294); successors SoftPulse CHECK-RAISE→FOLD / RARELY CALLS→CHECK content-driven (do not reopen LPT-669); guided SoftPulse `fold` PRESENT (`Jh`/`9d`·`Qc`/`9s`/`3h` +2 suit variants match Dart); scaffolded SoftPulse `fold-k9` one-per-press PRESENT (`Kh`/`9d` +2 suit variants); unguided SoftPulse `check` one-per-press PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants).
- Curriculum **LPT-294** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-709/710/294/708/713/706/198/216/351; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Observe-wide SoftPulse residual **LPT-713** (+ **LPT-714** / **LPT-715**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-11-03-*: interactive structural clean on tip except LPT-709 SoftPulse + LPT-710 cite residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive sizing acts are `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` cite tiles — do not file handFamily.

## Fold 2026-10-15as tip 0de89b00 (#2568 Adjust-TAG Prefer → Observe-wide SoftPulse LPT-713 Prefer)

- Tip-stable `0de89b00` after #2568 Adjust-TAG SoftPulse Prefer fold. Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Observe-wide SoftPulse residual re-check `lesson-06-12-01-01/02/03` / `act-06-12-01-*`: first-child SoftPulse WIDE→PRESSURE→SAMPLE + `explainGrading` "Wide → Pressure → Sample." + Dart `WidePressureDemo.points` WIDE/PRESSURE/SAMPLE (captions Many opens / Barrels with a plan / Count first) / `LessonWidePressureExplainTable` (authored-demo filter still yields all three cues) still pre-split under Note-wide-entry-only → residual **LPT-713** still To Do (needs-human; Relates LPT-297 — do not re-add needs-human on curriculum); companion unguided SoftPulse `wait` Keep sampling (prompt "Label after one wide open?"; `lagObserveSampleOutcomes` densify PRESENT) under Note sustained pressure → residual **LPT-714** still To Do; companion checkpoint SoftPulse `bundle` kind `none` densify PRESENT (prompt "Best pre-label note bundle?"; `lagObserveBundleOutcomes`) under Planned-not-maniac → residual **LPT-715** still To Do; successors SoftPulse BARRELS→MANY HANDS / FOLDS SOMETIMES→PLAN content-driven (do not reopen LPT-669); guided SoftPulse `wide` densify PRESENT (`lagObserveGuidedOutcomes`); scaffolded SoftPulse `sep` one-per-press densify PRESENT (`lagObserveDiscOutcomes`).
- Curriculum **LPT-297** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-713/714/715/297/716/351/709/710/198/216; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Meet-LAG sample-limits residual **LPT-716** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-01-*: interactive structural clean on tip except LPT-713 SoftPulse + LPT-714/715 companions; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; all interactive acts are `deal.mode` `none` observation tiles — do not file handFamily.

## Fold 2026-10-15at (ea0a1156 Meet-LAG sample-limits Prefer)

- Tip-stable `ea0a1156` (#2571 ui-agent motion video on tip; non-content). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Catalog parents Done — no open-parent sync.
- Prefer NEVER Meet-LAG sample-limits residual **LPT-716** re-check (`lesson-06-12-02-01/02/03`):
  - SoftPulse WIDE→PRESSURE→MODEL + `explainGrading` "Wide → Pressure → Model." + Dart `LagModelDemo.points` WIDE/PRESSURE/MODEL / `LessonLagModelExplainTable` **concept-aligned** under Introduce LAG / The LAG model (not SoftPulse residual).
  - checkpoint SoftPulse `limits` kind `none` densify PRESENT (prompt "Show beside LAG label?" / Sample limits vs Destiny) still under Introduce LAG-only → **LPT-716** still To Do (needs-human; Relates LPT-300).
  - successors WIDE OPENS→BARRELS / RAISES→CALLS content-driven (do not reopen LPT-669); guided SoftPulse `lag` densify PRESENT; scaffolded SoftPulse `diff` one-per-press densify PRESENT; unguided SoftPulse `lag2` one-per-press densify PRESENT.
- Curriculum **LPT-300** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-716/300/718/719/713/351.
- Prefer next: NEVER Adjust-LAG SoftPulse residual **LPT-718** (+ **LPT-719**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-02-*: interactive structural clean on tip except LPT-716 sample-limits checkpoint residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-15au tip b13f674e (#2572 Meet-LAG Prefer → Adjust-LAG SoftPulse LPT-718 Prefer)

- Tip-stable `b13f674e` (#2572 Meet-LAG sample-limits Prefer on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Catalog parents Done — no open-parent sync.
- SoftPulse Prefer path catch-up: Observe-wide **LPT-713** (+ **LPT-714** / **LPT-715**) + Meet-LAG sample-limits **LPT-716** still To Do advanced through Prefer SoftPulse path (was lagged at Observe-wide next after #2570/#2572 diaries).
- Prefer NEVER Adjust-LAG SoftPulse residual **LPT-718** re-check (`lesson-06-12-03-01/02/03`):
  - first-child SoftPulse CALL→TRAP→FANCY LESS + `explainGrading` "Call → Trap → Fancy less." + Dart `VsLagsDemo.points` CALL/TRAP/FANCY LESS / `LessonVsLagsExplainTable` + coachMedia unit framing still pre-split under Call-wider-only → **LPT-718** still To Do (needs-human; Relates LPT-303).
  - companion checkpoint SoftPulse `cite` kind `none` densify PRESENT under Call-wider → **LPT-719** still To Do.
  - successors STRONG HAND→LET THEM BET / NO BIG BLUFF→LET THEM content-driven (do not reopen LPT-669); guided SoftPulse `call` PRESENT; scaffolded SoftPulse `trap` one-per-press PRESENT; unguided SoftPulse `avoid` one-per-press densify PRESENT.
- Curriculum **LPT-303** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-718/719/303/721/716/713/351/198/216.
- Prefer next: NEVER Mix-five SoftPulse residual **LPT-721** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-12-03-*: interactive structural clean on tip except LPT-718 SoftPulse + LPT-719 cite companions; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15av tip 643b2f0d (#2574 Adjust-LAG Prefer → Mix-five SoftPulse LPT-721 Prefer)

- Tip-stable `643b2f0d` (#2574 Adjust-LAG SoftPulse Prefer on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Catalog parents Done — no open-parent sync.
- Prefer NEVER Mix-five SoftPulse residual **LPT-721** re-check (`lesson-06-13-01-01/02/03/04`):
  - first-child SoftPulse CARDS→SEATS→EVIDENCE + `explainGrading` "Cards → Seats → Evidence." + Dart `ExploitEvidenceDemo.points` CARDS/SEATS/EVIDENCE / `LessonExploitEvidenceExplainTable` + coachMedia unit framing still pre-split under Station-thin-only → **LPT-721** still To Do (needs-human; Relates LPT-306).
  - successors SoftPulse NIT CHECK-RAISE→FOLD / LAG BARREL→CALL / TENDENCY→LINE content-driven (do not reopen LPT-669); guided SoftPulse `cs` SoftPulse map PRESENT; scaffolded SoftPulse `nit` one-per-press SoftPulse map PRESENT; unguided SoftPulse `lag` one-per-press SoftPulse map PRESENT; cite checkpoint SoftPulse `tag` densify PRESENT under Cite — matches (no companion residual).
- Curriculum **LPT-306** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-721/306/790/718/351/198/216.
- Prefer next: NEVER preflop-to-flop SoftPulse residual **LPT-790** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-06-13-01-*: interactive structural clean on tip except LPT-721 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.


## Fold 2026-10-15aw tip 509dea34 (#2575 Mix-five Prefer → preflop-to-flop SoftPulse LPT-790 Prefer)

- Tip-stable `509dea34` (#2575 Mix-five SoftPulse Prefer on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Catalog parents Done — no open-parent sync.
- Prefer NEVER preflop-to-flop SoftPulse residual **LPT-790** re-check (`lesson-07-01-01-01/02/03`):
  - first-child SoftPulse REASON→CONFIRM→CANCEL + `explainGrading` "Reason → Confirm → Cancel." + Dart `PreflopFlopPlanDemo.points` REASON/CONFIRM/CANCEL (captions Enter with why / Flop agrees / Flop kills it) / `LessonPreflopFlopPlanExplainTable` / layout "Tap Reason, then Confirm, then Cancel." + coachMedia "Enter with a reason. Flop confirms or cancels." still pre-split under State-a-preflop-thesis-only → **LPT-790** still To Do (needs-human; Relates LPT-310).
  - successors SoftPulse TEXTURE→CONFIRM OR CANCEL / DEAD PLAN→LET GO content-driven (do not reopen LPT-669); guided SoftPulse `dead` densify PRESENT; scaffolded SoftPulse `value` one-per-press densify PRESENT; unguided SoftPulse `thesis` one-per-press densify PRESENT; checkpoint SoftPulse `abandon` kind `none` densify PRESENT under Abandon — matches (no companion residual).
- Curriculum **LPT-310** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-790/310/794/721/351/198/216.
- Prefer next: NEVER Map SoftPulse residual **LPT-794** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-01-01-*: interactive structural clean on tip except LPT-790 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; all interactive acts are `deal.mode` `none` plan tiles — do not file handFamily.

## Fold 2026-10-15ax tip 07bd03fc (#2579 → Map SoftPulse LPT-794 Prefer)

- Tip-stable `07bd03fc` (#2579 felt street-bets on tip after #2578 preflop-to-flop SoftPulse Prefer fold). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**. Catalog parents Done — no open-parent sync.
- Prefer NEVER Map SoftPulse residual **LPT-794** re-check (`lesson-07-02-01-01/02/03` / `act-07-02-01-*`):
  - first-child SoftPulse BARREL→GIVE-UP→MAP + `explainGrading` "Barrel → Give-up → Map." + Dart `TurnMapDemo.points` BARREL/GIVE-UP/MAP (captions Cards to continue / Cards to kill / Before flop bet) / `LessonTurnMapExplainTable` / layout "Tap Barrel, then Give-up, then Map." still pre-split under List-turn-continue-cards-only → **LPT-794** still To Do (needs-human; Relates LPT-314 — do not re-add needs-human on curriculum).
  - successors SoftPulse BRICK→GIVE UP / CONTINUE→GIVE-UP→MAP content-driven (do not reopen LPT-669); guided SoftPulse `ok` densify PRESENT; scaffolded SoftPulse `give` one-per-press densify PRESENT; unguided SoftPulse `avoid` one-per-press densify PRESENT; checkpoint SoftPulse `list` kind `none` densify PRESENT under map-definition matches — no companion residual.
- Curriculum **LPT-314** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-794/314/795/790/351/198/216; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Compose SoftPulse residual **LPT-795** (+ rule **LPT-796**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-02-01-*: interactive structural clean on tip except LPT-794 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; all interactive acts are `deal.mode` `none` map tiles — do not file handFamily.

## Fold 2026-10-15ay tip f134ad74 (#2581 Map Prefer → Compose SoftPulse LPT-795 Prefer)

- Tip-stable `f134ad74` (#2581 Map SoftPulse Prefer on tip). Catalog `--counts` all **0**; softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Catalog parents Done — no open-parent sync.
- Prefer NEVER Compose SoftPulse residual **LPT-795** re-check (`lesson-07-03-01-01/02/03`):
  - first-child SoftPulse VALUE→BLUFF→HOLD + `explainGrading` "Value → Bluff → Hold." + Dart `RiverCompositionDemo.points` VALUE/BLUFF/HOLD / `LessonRiverCompositionExplainTable` still pre-split under Choose-river-value-candidates-only → **LPT-795** still To Do (needs-human; Relates LPT-317).
  - companion checkpoint SoftPulse `rule` kind `none` densify PRESENT under Choose-river-value → **LPT-796** still To Do.
  - successors SoftPulse BLOCKER→FEWER CALLS / NO STORY→CHECK content-driven (do not reopen LPT-669); guided SoftPulse `val` PRESENT; scaffolded SoftPulse `block` one-per-press densify PRESENT; unguided SoftPulse `check` one-per-press densify PRESENT.
- Curriculum **LPT-317** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-795/796/317/798/794/351/198/216.
- Prefer next: NEVER Pot SoftPulse residual **LPT-798** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-03-01-*: interactive structural clean on tip except LPT-795 SoftPulse + LPT-796 rule companions; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.


## Fold 2026-10-15ba tip 11a7d2a9 (#2576 short-ladder → Pot SoftPulse LPT-798 Prefer)

- Tip-stable `11a7d2a9` (#2576 short-ladder LPT-829 on tip after #2584). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** short-ladder tip-synced (checklist flat **224**); other parents Done.

- Prefer NEVER Pot SoftPulse residual **LPT-798** re-check (`lesson-07-04-01-01/02/03` / `act-07-04-01-*`):
  - first-child SoftPulse LIMPED→SRP→3-4BET + `explainGrading` "Limped → SRP → 3-bet/4-bet." + Dart `PotTypePlansDemo.points` LIMPED/SRP/3-4BET (captions Nut potential / C-bet maps / High commit) / `LessonPotTypePlansExplainTable` / layout "Tap Limped, then SRP, then 3-4bet." + coachMedia "Pot type sets ranges and SPR. Plan accordingly." still pre-split under Plan-limped-pots-only → **LPT-798** still To Do (needs-human; Relates LPT-320 — do not re-add needs-human on curriculum).
  - companion checkpoint SoftPulse `both` kind `none` densify PRESENT (prompt "Pot type changes?"; tile "Ranges and SPR") under Plan 3-bet/4-bet-only → **LPT-799** still To Do.
  - successors SoftPulse HEADS-UP→C-BET / LOW SPR→COMMIT content-driven (do not reopen LPT-669); guided SoftPulse `nuts` densify PRESENT; scaffolded SoftPulse `cb` one-per-press densify PRESENT; unguided SoftPulse `commit` one-per-press densify PRESENT.
- Curriculum **LPT-320** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-798/799/320/795/351/800; leave open LPT-676…802 + LPT-351; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER HU SoftPulse residual **LPT-800** (+ player-count **LPT-801**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351.
- act-07-04-01-*: interactive structural clean on tip except LPT-798 SoftPulse + LPT-799 Ranges/SPR companions; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/scaffolded/unguided/checkpoint are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-15bb tip 552b5151 (#2585 → HU SoftPulse LPT-800 Prefer)

- Tip-stable `552b5151` (#2585 densify stem on tip after #2583 Pot SoftPulse Prefer). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER HU SoftPulse residual **LPT-800** re-check (`lesson-07-05-01-01/02/03`):
  - first-child SoftPulse FEWER→THICKER→WIDEN + `explainGrading` "Fewer → Thicker → Widen." + Dart `HuVsMultiwayDemo.points` FEWER/THICKER/WIDEN / `LessonHuVsMultiwayExplainTable` still pre-split under Bluff-less-multiway-only → **LPT-800** still To Do (needs-human; Relates LPT-323).
  - companion checkpoint SoftPulse `input` kind `none` densify PRESENT under Bluff-less-multiway → **LPT-801** still To Do.
  - successors SoftPulse MULTIWAY→THICK VALUE / HEADS-UP→STEAL MORE content-driven (do not reopen LPT-669); guided SoftPulse `no` densify PRESENT; scaffolded SoftPulse `higher` one-per-press densify PRESENT; unguided SoftPulse `thick` one-per-press densify PRESENT.
- Curriculum **LPT-323** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-800/801/323/802/798/829/351/198/216.
- Prefer next: NEVER Stack SoftPulse residual **LPT-802** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-07-05-01-*: interactive structural clean on tip except LPT-800 SoftPulse + LPT-801 player-count companions; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; outcome-tile `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15bc tip a1388cbb (#2586 → Stack SoftPulse LPT-802 Prefer)

- Tip-stable `a1388cbb` (#2586 HU SoftPulse Prefer LPT-800 on tip after #2585). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Stack SoftPulse residual **LPT-802** re-check (`lesson-07-06-01-01/02/03` / `act-07-06-01-*`):
  - first-child SoftPulse SHORT→DEEP→EFFECTIVE + `explainGrading` "Short → Deep → Effective." + Dart `StackDepthPlansDemo.points` SHORT/DEEP/EFFECTIVE (captions Commit earlier / Implied odds / Recalc each hand) / `LessonStackDepthPlansExplainTable` / layout "Tap Short, then Deep, then Effective." + coachMedia "Effective stack rewrites the plan every hand." still pre-split under Commit-earlier-short-only → **LPT-802** still To Do (needs-human; Relates LPT-326 — do not re-add needs-human on curriculum).
  - checkpoint SoftPulse `every` kind `none` densify PRESENT (prompt "Stack depth is?") under recalc-effective matches — no companion residual.
  - successors SoftPulse DEEP→IMPLIED ODDS / SHORTER STACK→PLAN content-driven (do not reopen LPT-669); guided SoftPulse `commit` densify PRESENT; scaffolded SoftPulse `yes` one-per-press densify PRESENT; unguided SoftPulse `40` one-per-press densify PRESENT.
  - Distinct from S2 residual **LPT-748** (BbStackDepthDemo SHORTER/DEPTH).
- Curriculum **LPT-326** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-802/326/800/801/829/351/748/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Same-cards SoftPulse residual **LPT-725** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-07-06-01-*: interactive structural clean on tip except LPT-802 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; outcome-tile `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15bd tip 260bef47 (#2587 → Same-cards SoftPulse LPT-725 Prefer)

- Tip-stable `260bef47` (#2587 Stack SoftPulse Prefer LPT-802 on tip after #2586). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Same-cards SoftPulse residual **LPT-725** re-check (`lesson-07-07-01-01/02/03/04` / `act-07-07-01-*`):
  - first-child SoftPulse CARDS→MODELS→CITE + `explainGrading` "Cards → Models → Cite." + Dart `SameCardsTypesDemo.points` CARDS/MODELS/CITE (captions Same holdings / Five types / Tendency or baseline) / `LessonSameCardsTypesExplainTable` / coachMedia "Same cards. Five models. Cite the tendency." still pre-split under station-value (objective still unit string "Change lines by type with citations"; title Same hand: bet value versus a Station) → **LPT-725** still To Do (needs-human; Relates LPT-330 — do not re-add needs-human on curriculum).
  - checkpoint SoftPulse `base` kind `none` densify PRESENT (prompt "No type evidence yet. Default?"; helper "No type evidence — pick the default.") under baseline-without-evidence matches — no companion residual.
  - successors SoftPulse TAG CHECK-RAISE→CAREFUL / LAG BARREL→CALL / NO EVIDENCE→BASELINE content-driven (do not reopen LPT-669); guided SoftPulse `bet` PRESENT (`Ah`/`Kd`·`Kc`/`8s`/`3h` +2 suit variants; poker_action_sizing densify N/A); scaffolded SoftPulse `fold` one-per-press PRESENT; unguided SoftPulse `call` one-per-press PRESENT (turn +`2d`).
- Curriculum **LPT-330** Done — do not clone / do not re-add needs-human; do not clone Duplicate **LPT-728**.
- Tip-commented LPT-725/330/726/802/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Type-board SoftPulse residual **LPT-726** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-07-07-01-*: interactive structural clean on tip except LPT-725 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/scaffolded/unguided sizing `fixed`+variants — do not reopen LPT-627; explain/checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15bt tip bda08b46 (#2607 → Defend SoftPulse residual LPT-701 Prefer)

- Tip-stable `bda08b46` (#2607 Blockers SoftPulse Prefer LPT-700 on tip after #2606). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Defend SoftPulse residual **LPT-701** (+ companion **LPT-702**) re-check (`lesson-06-07-01-01/02/03` / `act-06-07-01-*`):
  - first-child SoftPulse DEFEND→BLUFF→ENOUGH + Dart `DefendEnoughDemo.points` DEFEND/BLUFF/ENOUGH still pre-split under continue-catchers-only → **LPT-701** still To Do (needs-human; Relates LPT-273 — do not re-add needs-human on curriculum).
  - companion checkpoint SoftPulse `punish` kind `none` densify PRESENT (prompt "Minimum defense goal?" / Punish over-bluffs) under Continue with stronger catchers → **LPT-702** still To Do.
  - successors SoftPulse THIRD PAIR→SCARY→FOLD / MDF→INTUITION content-driven; guided SoftPulse `strong` densify PRESENT; scaffolded SoftPulse `fold` one-per-press PRESENT; unguided SoftPulse `int` one-per-press densify PRESENT.
- Curriculum **LPT-273** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-701/702/273/700/703/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Mix SoftPulse residual **LPT-703** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-07-01-*: interactive structural clean on tip except LPT-701/702 SoftPulse residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; scaffolded sizing `fixed`+variants — do not reopen LPT-627.

## Fold 2026-10-15bu tip 863eb69c (#2608 → Mix SoftPulse residual LPT-703 Prefer)

- Tip-stable `863eb69c` (#2608 Defend SoftPulse Prefer LPT-701 on tip after #2607). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Mix SoftPulse residual **LPT-703** re-check (`lesson-06-08-01-01/02/03` / `act-06-08-01-*`):
  - first-child SoftPulse MIX→PURPOSE→STRONG + Dart `MixedStrategyDemo.points` MIX/PURPOSE/STRONG still pre-split under mix-strong-only → **LPT-703** still To Do (needs-human; Relates LPT-277 — do not re-add needs-human on curriculum).
  - successors SoftPulse TYPE→STATION→LESS / RANDOM→PURPOSE content-driven; guided SoftPulse `protect` PRESENT (`7h`/`7d`·`7c`/`Kd`/`2s` +2 suit variants); scaffolded SoftPulse `less` one-per-press densify PRESENT; unguided SoftPulse `no` one-per-press densify PRESENT; checkpoint SoftPulse `freq` kind `none` densify PRESENT under no-pure-random — no companion residual.
- Curriculum **LPT-277** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-703/277/701/702/704/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Plan-3bet SoftPulse residual **LPT-704** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-08-01-*: interactive structural clean on tip except LPT-703 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided sizing `fixed`+variants — do not reopen LPT-627; scaffolded/unguided/checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15bx tip 0449e707 (#2613/#2614 → Selective SoftPulse residual LPT-706 Prefer)

- Tip-stable `0449e707` (#2614 SoftPulse-quiet Wait densify after #2613 Hard-folds Prefer on tip). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Selective SoftPulse residual **LPT-706** re-check (`lesson-06-11-01-01/02/03` / `act-06-11-01-*`):
  - first-child SoftPulse TIGHT→BARREL→SAMPLE + `explainGrading` "Tight → Barrel → Sample." + Dart `SelectiveAggressionDemo.points` TIGHT/BARREL/SAMPLE (captions Selective entry / With a plan / Count first) / `LessonSelectiveAggressionExplainTable` / layout "Tap Tight, then Barrel, then Sample." + coachMedia "Before labels: who enters tight, then barrels with a plan? Count samples." still pre-split under selective-entry-only → **LPT-706** still To Do (needs-human; Relates LPT-288 — do not re-add needs-human on curriculum).
  - successors SoftPulse CALLED→GIVES UP / TWO HANDS→NOTE BUNDLE content-driven (do not reopen LPT-669); guided SoftPulse `sel` densify PRESENT; scaffolded SoftPulse `disc` one-per-press densify PRESENT; unguided SoftPulse `low` one-per-press densify PRESENT; checkpoint SoftPulse `bundle` kind `none` densify PRESENT under wait-for-samples — no companion residual.
- Curriculum **LPT-288** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-706/288/708/705/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Meet-TAG working-model residual **LPT-708** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-11-01-*: interactive structural clean on tip except LPT-706 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-15bw tip 85293f3c (#2612 → Hard-folds SoftPulse residual LPT-705 Prefer)

- Tip-stable `85293f3c` (#2612 Plan-3bet SoftPulse Prefer LPT-704 on tip after #2611). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- SoftPulse Prefer path catch-up: Plan-3bet SoftPulse residual **LPT-704** still To Do advanced through Prefer SoftPulse path this fold.
- Prefer NEVER Hard-folds SoftPulse residual **LPT-705** re-check (`lesson-06-10-01-01/02/03` / `act-06-10-01-*`):
  - first-child SoftPulse HARD→COOLER→EGO + Dart `HardFoldCoolerDemo.points` HARD/COOLER/EGO still pre-split under hard-folds-only → **LPT-705** still To Do (needs-human; Relates LPT-285 — do not re-add needs-human on curriculum).
  - successors SoftPulse COOLER→MISTAKE→REVIEW / DUE→EGO→FOLD content-driven; guided SoftPulse `fold` one-per-press PRESENT; scaffolded SoftPulse `cooler` densify PRESENT; unguided SoftPulse `ego` densify PRESENT; checkpoint SoftPulse `ask` under cooler-or-mistake — no companion residual.
- Curriculum **LPT-285** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-705/285/704/706/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Selective SoftPulse residual **LPT-706** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-10-01-*: interactive structural clean on tip except LPT-705 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided sizing `fixed`+variants — do not reopen LPT-627.

## Fold 2026-10-15bv tip 68983138 (#2611 → Plan-3bet SoftPulse residual LPT-704 Prefer)

- Tip-stable `68983138` (#2611 Mix SoftPulse Prefer LPT-703 on tip after #2610/#2609). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Plan-3bet SoftPulse residual **LPT-704** re-check (`lesson-06-09-01-01/02/03` / `act-06-09-01-*`):
  - careful-4bet SoftPulse 4BET→STRONG→CAREFUL content-driven + guided SoftPulse `careful` densify PRESENT (`deal.mode` `none`) — concept-aligned.
  - **middle-child** SoftPulse 3BET→4BET→DEPTH + `explainGrading` "3-bet → 4-bet → Depth." + Dart `ThreeBetFourBetSprDemo.points` 3BET/4BET/DEPTH (captions Shrink ranges / Lower SPR / Decides commit) / `LessonThreeBetFourBetSprExplainTable` / layout "Tap 3-Bet, then 4-Bet, then Depth." + coachMedia "3-bet and 4-bet pots shrink ranges and SPR. Depth decides commitment." still pre-split under plan-3bet-spr → **LPT-704** still To Do (needs-human; Relates LPT-282 — do not re-add needs-human on curriculum; reused explain is middle-child, not first-child).
  - scaffolded SoftPulse `small` one-per-press PRESENT (`Ah`/`Qd`·`8c`/`3h`/`2s` +2 suit variants; Dart `stackLabel` Stacks left 360 match); checkpoint SoftPulse `spr` kind `none` densify PRESENT under plan-3bet-spr — no companion residual.
  - ego SoftPulse 4BET→EGO→AVOID content-driven + unguided SoftPulse `avoid` one-per-press densify PRESENT (do not reopen LPT-669).
- Curriculum **LPT-282** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-704/282/703/705/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Hard-folds SoftPulse residual **LPT-705** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-09-01-*: interactive structural clean on tip except LPT-704 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/checkpoint `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded stays fixed+variants AQo-miss honesty; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15br tip 50e4dc56 (#2605 → Overbet SoftPulse residual LPT-699 Prefer)

- Tip-stable `50e4dc56` (#2605 Polar SoftPulse Prefer LPT-696 on tip after #2604). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Overbet SoftPulse residual **LPT-699** re-check (`lesson-06-05-01-01/02/03` / `act-06-05-01-*`):
  - first-child SoftPulse OVERBET→POLAR→GEO + Dart `OverbetGeometryDemo.points` OVERBET/POLAR/GEO still pre-split under polar-overbets-only → **LPT-699** still To Do (needs-human; Relates LPT-267 — do not re-add needs-human on curriculum).
  - successors SoftPulse FLOP→TURN→RIVER / HUGE→MEDIUM→AVOID content-driven; guided SoftPulse `polar-ob` densify PRESENT; scaffolded SoftPulse `mid` one-per-press PRESENT; unguided SoftPulse `avoid` densify PRESENT; checkpoint SoftPulse `multi` under geometric-sizes — no companion residual.
- Curriculum **LPT-267** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-699/267/700/696/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Blockers SoftPulse residual **LPT-700** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-05-01-*: interactive structural clean on tip except LPT-699 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15bq tip 1c7f76e7 (#2604 → Polar SoftPulse residual LPT-696 Prefer)

- Tip-stable `1c7f76e7` (#2604 Spot-caps SoftPulse Prefer LPT-694 on tip after #2603). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Polar SoftPulse residual **LPT-696** re-check (`lesson-06-04-01-01/02/03` / `act-06-04-01-*`):
  - first-child SoftPulse POLAR→MERGED→SIZE + `explainGrading` "Polar → Merged → Size." + Dart `PolarMergedDemo.points` POLAR/MERGED/SIZE (captions Nuts or air / Medium-strong / Size accordingly) / layout "Tap Polar, then Merged, then Size." + coachMedia "Polar: nuts or air. Merged: many medium-strong hands. Size accordingly." still pre-split under polarized-sizing-only → **LPT-696** still To Do (needs-human; Relates LPT-264 — do not re-add needs-human on curriculum).
  - successors SoftPulse MERGED→MEDIUM→VALUE / SIZE→SHAPE→MATCH content-driven (do not reopen LPT-669); guided SoftPulse `polar` densify PRESENT; scaffolded SoftPulse `mid` one-per-press PRESENT (Jh/Td·Qc/Ts/3h/2d/7c +2 suit variants match Dart LPT-395); unguided SoftPulse `mismatch` densify PRESENT; checkpoint SoftPulse `thin` kind `none` densify PRESENT under merged-thin-value — no companion residual.
- Curriculum **LPT-264** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-696/264/699/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Overbet SoftPulse residual **LPT-699** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-04-01-*: interactive structural clean on tip except LPT-696 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/unguided/checkpoint `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded sizing `fixed`+variants — do not reopen LPT-627.

## Fold 2026-10-15bp tip 892b570f (#2603 → Spot-caps SoftPulse residual LPT-694 Prefer)

- Tip-stable `892b570f` (#2603 Range SoftPulse Prefer LPT-692 on tip after #2602). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Spot-caps SoftPulse residual **LPT-694** re-check (`lesson-06-03-01-01/02/03` / `act-06-03-01-*`):
  - first-child SoftPulse CAPPED→UNCAPPED→NUTS + `explainGrading` "Capped → Uncapped → Nuts." + Dart `CappedUncappedDemo.points` CAPPED/UNCAPPED/NUTS (captions Nuts unlikely / Nuts still live / Know which) / layout "Tap Capped, then Uncapped, then Nuts." + coachMedia "Capped = nuts unlikely. Uncapped = nuts still live." still pre-split under spot-caps-only → **LPT-694** still To Do (needs-human; Relates LPT-260 — do not re-add needs-human on curriculum; race clone LPT-695 Done — do not reopen).
  - successors SoftPulse RAISE→BET→RESPECT / CAPPED→THIN→BLUFF content-driven (do not reopen LPT-669); guided SoftPulse `cap` densify PRESENT; unguided SoftPulse `uncap` one-per-press densify PRESENT; scaffolded SoftPulse `bet` one-per-press SoftPulse map PRESENT (fixed Jh9d/Kc9s4h2d7c + 2 suit variants); checkpoint SoftPulse `attack` kind `none` densify PRESENT under attack-caps — no companion residual.
- Curriculum **LPT-260** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-694/260/696/692/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Polar SoftPulse residual **LPT-696** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-03-01-*: interactive structural clean on tip except LPT-694 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify/SoftPulse map PRESENT — do not reopen LPT-628/625; guided/unguided/checkpoint `deal.mode` `none` outcome tiles — do not file handFamily; scaffolded sizing `fixed`+variants — do not reopen LPT-627.

## Fold 2026-10-15bo tip abe81fab (#2602 → Range SoftPulse residual LPT-692 Prefer)

- Tip-stable `abe81fab` (#2602 Session SoftPulse Prefer LPT-690 on tip after #2601). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- SoftPulse Prefer path catch-up: Timing **LPT-685** + Dynamics **LPT-686** (+ **LPT-687**) + Session **LPT-690** (+ **LPT-691**) still To Do advanced through Prefer SoftPulse path this fold.
- Prefer NEVER Range SoftPulse residual **LPT-692** re-check (`lesson-06-01-01-01/02/03` / `act-06-01-01-*`):
  - first-child SoftPulse RANGE→NUT→ADVANTAGE + Dart `RangeAdvantageDemo.points` RANGE/NUT/ADVANTAGE still pre-split under range-advantage-only → **LPT-692** still To Do (needs-human; Relates LPT-254 — do not re-add needs-human on curriculum).
  - successors SoftPulse NUTS→PAIRED→CALLER / RANGE→NUTS→BET content-driven; guided SoftPulse `pfr` densify PRESENT; scaffolded SoftPulse `caller-nuts` densify PRESENT; unguided SoftPulse `cbet` SoftPulse map PRESENT; checkpoint SoftPulse `press` under press-both — no companion residual.
- Curriculum **LPT-254** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-692/254/694/690/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Spot-caps SoftPulse residual **LPT-694** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-01-01-*: interactive structural clean on tip except LPT-692 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify/SoftPulse map PRESENT — do not reopen LPT-628/625.

## Fold 2026-10-15bn tip 2bb86192 (#2601 → Session SoftPulse residual LPT-690 Prefer)

- Tip-stable `2bb86192` (#2601 LPT-836 densify on tip after #2600 Dynamics SoftPulse Prefer). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Session SoftPulse residual **LPT-690** re-check (`lesson-05-09-01-01/02/03` / `act-05-09-01-*`):
  - first-child SoftPulse QUIT→GUARD→FIRST + `explainGrading` "Quit → Guard → First." + Dart `GuardrailsDemo.points` QUIT/GUARD/FIRST (captions Know when / Guardrails first / Win long-term) / coachMedia "Winning 1/2 includes knowing when to quit. Guardrails first." still pre-split under stop-loss-only → **LPT-690** still To Do (needs-human; Relates LPT-250 — do not re-add needs-human on curriculum).
  - companion checkpoint SoftPulse `edge` kind `none` densify PRESENT (prompt "Session discipline is part of?" / Your edge) under End sessions → **LPT-691** still To Do (needs-human) — leave open; do not clone.
  - successors SoftPulse BANKROLL→STAKES→DECLINE / TIRED→WILD→CASH OUT content-driven (do not reopen LPT-669); guided SoftPulse `stop` densify PRESENT; scaffolded SoftPulse `decline` one-per-press densify PRESENT; unguided SoftPulse `cash` one-per-press densify PRESENT.
- Curriculum **LPT-250** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-690/691/250/686/687/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Range SoftPulse residual **LPT-692** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-05-09-01-*: interactive structural clean on tip except LPT-690 SoftPulse + LPT-691 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/scaffolded/unguided/checkpoint `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-15bm tip 0933e4ab (#2599 → Dynamics SoftPulse residual LPT-686 Prefer)

- Tip-stable `0933e4ab` (#2599 Timing SoftPulse Prefer LPT-685 on tip after #2597). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Dynamics SoftPulse residual **LPT-686** re-check (`lesson-05-08-01-01/02/03` / `act-05-08-01-*`):
  - first-child SoftPulse STUCK→TILTED→GEARS + `explainGrading` "Stuck → Tilted → Gears." + Dart `TablesChangeDemo.points` STUCK/TILTED/GEARS (captions Same old gear / Emotion leak / Shifting play) / coachMedia "Tables change. Stuck, tilted, tired, or shifting gears — update." still pre-split under tilted/stuck-only → **LPT-686** still To Do (needs-human; Relates LPT-247 — do not re-add needs-human on curriculum).
  - companion checkpoint SoftPulse `temp` kind `none` densify PRESENT (prompt "Dynamic reads should be?" / Fresh samples) under Gear changes → **LPT-687** still To Do (needs-human) — leave open; do not clone.
  - successors SoftPulse GEAR→CHANGE→SAMPLE / COOLER→CHASE→RESET content-driven (do not reopen LPT-669); guided SoftPulse `stuck` densify PRESENT; scaffolded SoftPulse `gear` one-per-press densify PRESENT; unguided SoftPulse `reset` one-per-press PRESENT (`Jh`/`Td`·`Kc`/`9s`/`4h`/`2d`/`7c` +2 suit variants; SoftPulse map PRESENT).
- Curriculum **LPT-247** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-686/687/247/685/690/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Session SoftPulse residual **LPT-690** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-05-08-01-*: interactive structural clean on tip except LPT-686 SoftPulse + LPT-687 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/scaffolded/checkpoint `deal.mode` `none` outcome tiles — do not file handFamily; unguided sizing `fixed`+variants — do not reopen LPT-627.

## Fold 2026-10-15bl tip 31868b66 (#2597 → Timing SoftPulse residual LPT-685 Prefer)

- Tip-stable `31868b66` (#2597 Lines SoftPulse Prefer LPT-684 on tip after #2596). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Timing SoftPulse residual **LPT-685** re-check (`lesson-05-07-01-01/02/03` / `act-05-07-01-*`):
  - first-child SoftPulse TIMING→SIZING→CLUES + `explainGrading` "Timing → Sizing → Clues." + Dart `TimingCluesDemo.points` TIMING/SIZING/CLUES (captions How fast they act / How much they bet / Nudge the model) / `LessonTimingCluesExplainTable` + coachMedia "Timing and sizing are clues, not mind-reading. Small updates only." still pre-split under timing-soft-only → **LPT-685** still To Do (needs-human; Relates LPT-244 — do not re-add needs-human on curriculum).
  - successors SoftPulse TINY→BIG→RANGE / TELL→MYTH→REJECT content-driven (do not reopen LPT-669); guided SoftPulse `soft` densify PRESENT; scaffolded SoftPulse `weakish` one-per-press densify PRESENT; unguided SoftPulse `reject` one-per-press densify PRESENT; checkpoint SoftPulse `tiny` kind `none` densify PRESENT under timing-soft — no companion residual.
- Curriculum **LPT-244** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-685/244/686/684/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Dynamics SoftPulse residual **LPT-686** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-05-07-01-*: interactive structural clean on tip except LPT-685 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; deal.mode `none` outcome tiles — do not file handFamily.

## Fold 2026-10-15bk tip 8679c3a7 (#2596 → Lines SoftPulse residual LPT-684 Prefer)

- Tip-stable `8679c3a7` (#2596 Thin SoftPulse Prefer LPT-682 on tip after #2595). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Lines SoftPulse residual **LPT-684** re-check (`lesson-05-05-01-01/02/03` / `act-05-05-01-*`):
  - first-child SoftPulse X/R→PROBE→DELAY→DONK + `explainGrading` "Check-raise → Probe → Delay → Donk." + Dart `LineStoriesDemo.points` X/R/PROBE/DELAY/DONK / `LessonLineStoriesExplainTable` / layout "Tap X/R, then Probe, then Delay, then Donk." still pre-split under check-raises-only → **LPT-684** still To Do (needs-human; Relates LPT-236 — do not re-add needs-human on curriculum).
  - successors SoftPulse PROBE→DELAY→PLAN / DONK→STRONG→AIR content-driven; guided SoftPulse `strong` densify PRESENT; scaffolded SoftPulse `probe` one-per-press PRESENT; unguided SoftPulse `polar` one-per-press densify PRESENT; checkpoint SoftPulse `delay` under probes-and-delays — no meta-read residual.
- Curriculum **LPT-236** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-684/236/685/682/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Timing SoftPulse residual **LPT-685** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-05-05-01-*: interactive structural clean on tip except LPT-684 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15bj tip c20589d3 (#2595 → Thin SoftPulse residual LPT-682 Prefer)

- Tip-stable `c20589d3` (#2595 Estimate SoftPulse Prefer LPT-681 on tip after #2594). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Thin SoftPulse residual **LPT-682** re-check (`lesson-05-04-01-01/02/03` / `act-05-04-01-*`):
  - first-child SoftPulse THIN→CATCH→BARRELS + `explainGrading` "Thin → Catch → Barrels." + Dart `ThinValueDemo` / `LessonThinValueExplainTable` (THIN "Extract light" / CATCH "Hero call" / BARRELS "Fire multi-street") / layout "Tap Thin, Catch, and Barrels." + coachMedia "Thin value needs calls. Bluff-catches need wide barrels." still pre-split under thin-value-only → **LPT-682** still To Do (needs-human; Relates LPT-233 — do not re-add needs-human on curriculum).
  - companion checkpoint SoftPulse `read` kind `none` densify PRESENT ("Same hand, different types — what must change?") under thin-value-only → **LPT-683** still To Do (needs-human) — leave open; do not clone.
  - successors SoftPulse MANIAC→BARREL→CALL / NIT→FOLDS→CHECK content-driven (do not reopen LPT-669); guided SoftPulse `tv` PRESENT (`Jh`/`9d`·`Kc`/`9s`/`4h`/`2d`/`7c` +2 suit variants; SoftPulse map PRESENT; poker_action_sizing densify N/A); scaffolded SoftPulse `call-m` one-per-press PRESENT; unguided SoftPulse `check-nit` one-per-press PRESENT.
- Curriculum **LPT-233** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-682/683/233/681/684/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Lines SoftPulse residual **LPT-684** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-05-04-01-*: interactive structural clean on tip except LPT-682 SoftPulse + LPT-683 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/scaffolded/unguided sizing `fixed`+variants — do not reopen LPT-627; explain/checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15bi tip eec34032 (#2594 → Estimate SoftPulse residual LPT-681 Prefer)

- Tip-stable `eec34032` (#2594 weigh-SPR SoftPulse Prefer LPT-677 on tip after #2593). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Estimate SoftPulse residual **LPT-681** re-check (`lesson-05-03-01-01/02/03` / `act-05-03-01-*`):
  - first-child SoftPulse IMPLIED→REVERSE→SECOND + `explainGrading` "Implied → Reverse → Second." + Dart `ImpliedOddsDemo.points` IMPLIED/REVERSE/SECOND (captions They pay later / You pay later / Trap improves) / `CoachDialogueVisualKind.impliedOdds` / layout "Tap Implied, Reverse, and Second." + coachMedia "Implied odds: future money. Reverse implied: future losses when second-best." still pre-split under estimate-only → **LPT-681** still To Do (needs-human; Relates LPT-230 — do not re-add needs-human on curriculum).
  - checkpoint SoftPulse `depth-pay` kind `none` densify PRESENT (prompt "Implied odds rise most when?") under Estimate matches — no companion residual.
  - successors SoftPulse REVERSE→DOMINATED→FOLD / NON-NUT→MULTIWAY→SKIP content-driven (do not reopen LPT-669); guided SoftPulse `call-io` PRESENT (`Jh`/`9d`·`8s`/`7c`/`2d` +2 suit variants; poker_action_sizing densify N/A); scaffolded SoftPulse `rio` one-per-press PRESENT; unguided SoftPulse `nonut` one-per-press PRESENT.
- Curriculum **LPT-230** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-681/230/682/677/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Thin SoftPulse residual **LPT-682** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-05-03-01-*: interactive structural clean on tip except LPT-681 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/scaffolded/unguided sizing `fixed`+variants — do not reopen LPT-627; explain/checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15bh tip 870c93bf (#2593 → weigh-SPR SoftPulse residual LPT-677 Prefer)

- Tip-stable `870c93bf` (#2593 Capstone Prefer + SoftPulse residual LPT-676 on tip after #2591). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER weigh-SPR SoftPulse residual **LPT-677** re-check (`lesson-04-05-01-01/02/03` / `act-04-05-01-*`):
  - first-child SoftPulse SPR→LOW→HIGH concept-aligned; guided SoftPulse `spr-4` densify PRESENT.
  - checkpoint SoftPulse `before` kind `none` densify PRESENT (choice "Weigh SPR first") still under Estimate objective → **LPT-677** still To Do (needs-human; Relates LPT-182 — do not re-add needs-human on curriculum).
  - successors SoftPulse LOW SPR→COMMIT / HIGH SPR→FLEXIBLE content-driven; scaffolded SoftPulse `commit` one-per-press PRESENT; unguided SoftPulse `flexible` one-per-press PRESENT.
- Curriculum **LPT-182** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-677/182/681/676/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Estimate SoftPulse residual **LPT-681** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-04-05-01-*: interactive structural clean on tip except LPT-677 nesting residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15bg tip 43d6fa43 (#2591 → Capstone + SoftPulse residual LPT-676 Prefer)

- Tip-stable `43d6fa43` (#2591 Leak SoftPulse Prefer LPT-727 on tip after #2590). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Capstone `lesson-07-10-01…05`: all five explains SoftPulse + `explainGrading` concept-aligned; hands `assessmentRole` `transfer` + empty pressHints in Dart `noHintIds` — **LPT-348** Done; synthesis — skip curriculum-split / no SoftPulse residual.
- Prefer NEVER SoftPulse residual **LPT-676** re-check (`lesson-04-04-01-01/02/03` / `act-04-04-01-*`):
  - first-child SoftPulse VALUE→PRESSURE→SIZE concept-aligned; guided SoftPulse `half` PRESENT; scaffolded SoftPulse `big` + pressHint polar bluff-story + Dart felt "Sell polar pressure" still under Nearby → **LPT-676** still To Do (needs-human; Relates LPT-179 — do not re-add needs-human on curriculum).
  - unguided SoftPulse `soft` densify PRESENT; successors NEARBY→STORY / TINY→VALUE content-driven; checkpoint SoftPulse `bad-1` under no-tiny-sizes — no companion residual.
- Curriculum **LPT-179** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-676/179/348/677/727/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER weigh-SPR SoftPulse residual **LPT-677** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-04-04-01-*: interactive structural clean on tip except LPT-676 nesting residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15bf tip 577126b0 (#2590 → Leak SoftPulse LPT-727 Prefer)

- Tip-stable `577126b0` (#2590 Type-board SoftPulse Prefer LPT-726 on tip after #2589). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Leak SoftPulse residual **LPT-727** re-check (`lesson-07-09-01-01/02/03` / `act-07-09-01-*`):
  - first-child SoftPulse LEAK→BOOK→REVIEW + `explainGrading` "Leak → Book → Review." + Dart `LeakReviewBookDemo.points` LEAK/BOOK/REVIEW (captions Specific note / Written defaults / On a schedule) / `LessonLeakReviewBookExplainTable` / layout "Tap Leak, Book, and Review." still pre-split under name-leaks-only → **LPT-727** still To Do (needs-human; Relates LPT-336 — do not re-add needs-human on curriculum).
  - successors SoftPulse COMMON SPOT→DEFAULT / AFTER SESSION→REVIEW content-driven (do not reopen LPT-669); guided SoftPulse `spec` densify PRESENT; scaffolded SoftPulse `book` densify PRESENT; unguided SoftPulse `sched` densify PRESENT; checkpoint SoftPulse `base` kind `none` densify PRESENT under default-lines — no companion residual.
- Curriculum **LPT-336** Done — do not clone / do not re-add needs-human; do not clone Duplicate **LPT-730**.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-727/336/726/725/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Capstone SoftPulse Prefer / SoftPulse residual **LPT-676** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-07-09-01-*: interactive structural clean on tip except LPT-727 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; explain/checkpoint/guided/scaffolded/unguided `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15be tip 38b5014d (#2589 → Type-board SoftPulse LPT-726 Prefer)

- Tip-stable `38b5014d` (#2589 Seat labels densify stem on tip after #2588 Same-cards SoftPulse Prefer). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233**; densify-tap **0**.
- Open catalog parent **LPT-829** tip-synced flat **224** (rebuilt from `--gap short-ladder --markdown`); other parents Done — no open-parent sync.
- Prefer NEVER Type-board SoftPulse residual **LPT-726** re-check (`lesson-07-08-01-01/02/03` / `act-07-08-01-*`):
  - first-child SoftPulse TYPE→BOARD→LINE→SIZE + `explainGrading` "Type → Board → Line → Size." + Dart `TypeBoardLineDemo.points` TYPE/BOARD/LINE/SIZE (captions Player model / Texture / History / One action) / `LessonTypeBoardLineExplainTable` / layout "Tap Type, then Board, then Line, then Size." still pre-split under type-and-board-only → **LPT-726** still To Do (needs-human; Relates LPT-333 — do not re-add needs-human on curriculum).
  - checkpoint SoftPulse `four` kind `none` densify PRESENT (helper "Integrated decision — pick the input set.") under one-coherent-action matches — no companion residual.
  - successors SoftPulse LINE→SIZE / FOUR INPUTS→ONE ACTION content-driven (do not reopen LPT-669); guided SoftPulse `call` PRESENT (`Jh`/`Td`·`Kh`/`Ts`/`8h`/`2d` +2 suit variants match Dart; poker_action_sizing densify N/A); scaffolded SoftPulse `raise` one-per-press PRESENT; unguided SoftPulse `fold` one-per-press PRESENT.
- Curriculum **LPT-333** Done — do not clone / do not re-add needs-human; do not clone Duplicate **LPT-729**.
- Tip-commented LPT-726/333/727/725/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Leak SoftPulse residual **LPT-727** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-07-08-01-*: interactive structural clean on tip except LPT-726 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); densify PRESENT — do not reopen LPT-628; guided/scaffolded/unguided sizing `fixed`+variants — do not reopen LPT-627; explain/checkpoint `deal.mode` `none` — do not file handFamily.

## Fold 2026-10-15bs (7a44af6c Prefer NEVER Blockers SoftPulse residual LPT-700 re-check)

- Tip-stable `7a44af6c` (#2606 Overbet SoftPulse Prefer LPT-699 on tip after #2605). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224**; other parents Done — no open-parent sync.
- Prefer NEVER Blockers SoftPulse residual re-check `lesson-06-06-01-01/02/03` / `act-06-06-01-*`:
  - first-child `act-06-06-01-explain` SoftPulse BLOCK→USE→NO EV + `explainGrading` "Block → Use → No EV." + Dart `BlockersDemo.points` BLOCK/USE/NO EV (captions Remove hands / Apply blockers / Skip decimals) / `LessonBlockersExplainTable` / layout "Tap Block, then Use, then No EV." + coachMedia "Blockers remove hands. Use them; do not invent EV decimals." still pre-split under bluff-blockers-only (`lesson-06-06-01-01-bluff-blockers` objective "Choose bluffs that block call-downs") → residual **LPT-700** still To Do (needs-human; Relates LPT-270 — do not re-add needs-human on curriculum).
  - successors `act-06-06-01-02-explain-unblock` CATCH→UNBLOCK→BLUFFS + `act-06-06-01-03-explain-ev` TWEAK→NO EV content-driven (do not reopen LPT-669); guided SoftPulse `as` densify PRESENT; scaffolded SoftPulse `unblock` one-per-press densify PRESENT; unguided SoftPulse `tweak` one-per-press densify PRESENT; checkpoint SoftPulse `no` kind `none` densify PRESENT under no-fake-ev — no companion residual.
- Curriculum **LPT-270** Done — do not clone / do not re-add needs-human.
- Tip-commented LPT-700/270/701/702/699/829/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Defend SoftPulse residual **LPT-701** (+ companion **LPT-702**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-06-01-*: interactive structural clean on tip except LPT-700 SoftPulse residual; all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily.

## Fold 2026-10-15bz tip 06406225 (#2618 Meet-TAG Prefer → Adjust-TAG SoftPulse LPT-709 Prefer)

- Tip-stable `06406225` (#2618 Meet-TAG Prefer LPT-708 on tip after #2616). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (body rebuilt from `--gap short-ladder --markdown`); other parents Done — no open-parent sync.
- Prefer NEVER Adjust-TAG SoftPulse residual re-check `lesson-06-11-03-01/02/03` / `act-06-11-03-*`:
  - first-child SoftPulse CREDIT→TIGHTER→NO LIGHT + `explainGrading` "Credit → Tighter → No light." + Dart `VsTagsDemo.points` CREDIT/TIGHTER/NO LIGHT (captions Believe their heat / Narrow steals / Skip fancy XR) / `LessonVsTagsExplainTable` / layout "Tap Credit, then Tighter, then No light." still pre-split under Respect-TAG-aggression-only (`lesson-06-11-03-01-respect-aggression` objective "Respect TAG aggression") → residual **LPT-709** still To Do (needs-human; Relates LPT-294 — do not re-add needs-human on curriculum).
  - companion checkpoint SoftPulse `cite` kind `none` densify PRESENT (`tagRespectCiteOutcomes` / helper "Versus TAG — pick the cite.") still under Respect-only → residual **LPT-710** still To Do (needs-human; Relates LPT-294).
  - successors SoftPulse CHECK-RAISE→FOLD / RARELY CALLS→CHECK content-driven (do not reopen LPT-669); guided SoftPulse `fold` PRESENT (`Jh`/`9d`·`Qc`/`9s`/`3h` +2 suit variants); scaffolded SoftPulse `fold-k9` one-per-press PRESENT (`Kh`/`9d` +2 suit variants); unguided SoftPulse `check` one-per-press PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants).
- Curriculum **LPT-294** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-709/710/294/829/713/708/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Observe-wide SoftPulse residual **LPT-713** (+ cite **LPT-714** / **LPT-715**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-11-03-*: interactive structural clean on tip except LPT-709 SoftPulse + LPT-710 cite residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); interactive sizing acts are `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` cite tiles — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15by tip 2c015455 (#2616 Selective Prefer → Meet-TAG working-model LPT-708 Prefer)

- Tip-stable `2c015455` (#2616 Selective SoftPulse Prefer LPT-706 on tip after #2614/#2615). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (body rebuilt from `--gap short-ladder --markdown`); other parents Done — no open-parent sync.
- Prefer NEVER Meet-TAG working-model residual re-check `lesson-06-11-02-01/02/03` / `act-06-11-02-*`:
  - SoftPulse TIGHT→AGGRO→MODEL + `explainGrading` "Tight → Aggro → Model." + Dart `TagModelDemo.points` TIGHT/AGGRO/MODEL (captions Tight in / Aggressive after / Working model) under Introduce TAG / The TAG model — **concept-aligned** (not a SoftPulse residual).
  - companion checkpoint SoftPulse `model` kind `none` densify PRESENT (prompt "TAG is?" / Working model vs Insult; `meetTagModelOutcomes`) still under Introduce TAG-only (`lesson-06-11-02-01-tag-model` objective "Introduce TAG") → residual **LPT-708** still To Do (needs-human; Relates LPT-291 — do not re-add needs-human on curriculum).
  - successors SoftPulse FOLDS MOST→PLANNED BARRELS / ENTRY WIDTH→DISCIPLINE content-driven (do not reopen LPT-669); guided SoftPulse `tag` densify PRESENT; scaffolded SoftPulse `diff` one-per-press densify PRESENT; unguided SoftPulse `tag2` one-per-press densify PRESENT.
- Curriculum **LPT-291** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-708/291/829/709/710/706/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Adjust-TAG SoftPulse residual **LPT-709** (+ cite **LPT-710**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-11-02-*: interactive structural clean on tip except LPT-708 working-model residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` player-type tiles — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15ca tip 714e21cd (#2619 Adjust-TAG Prefer → Observe-wide SoftPulse LPT-713 Prefer)

- Tip-stable `714e21cd` (#2619 Adjust-TAG SoftPulse Prefer LPT-709 on tip after #2618). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (body rebuilt from `--gap short-ladder --markdown`); other parents Done — no open-parent sync.
- Prefer NEVER Observe-wide SoftPulse residual re-check `lesson-06-12-01-01/02/03` / `act-06-12-01-*`:
  - first-child SoftPulse WIDE→PRESSURE→SAMPLE + `explainGrading` "Wide → Pressure → Sample." + Dart `WidePressureDemo.points` WIDE/PRESSURE/SAMPLE (captions Many opens / Barrels with a plan / Count first) / `LessonWidePressureExplainTable` / layout "Tap Wide, then Pressure, then Sample." still pre-split under Note-wide-entry-only (`lesson-06-12-01-01-wide-entry` objective "Note wide entry") → residual **LPT-713** still To Do (needs-human; Relates LPT-297 — do not re-add needs-human on curriculum).
  - companion unguided SoftPulse `wait` Keep sampling (prompt "Label after one wide open?"; densify helper "One wide open — pick the confidence."; `lagObserveSampleOutcomes`) under Note sustained pressure → residual **LPT-714** still To Do (needs-human; Relates LPT-297).
  - companion checkpoint SoftPulse `bundle` kind `none` densify PRESENT (helper "Best pre-label notes — pick the evidence pack."; `lagObserveBundleOutcomes`) under Planned-not-maniac → residual **LPT-715** still To Do (needs-human; Relates LPT-297).
  - successors SoftPulse BARRELS→MANY HANDS / FOLDS SOMETIMES→PLAN content-driven (do not reopen LPT-669); guided SoftPulse `wide` densify PRESENT; scaffolded SoftPulse `sep` one-per-press densify PRESENT.
- Curriculum **LPT-297** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-713/714/715/297/829/716/351/198/216/709; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Meet-LAG sample-limits residual **LPT-716** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-12-01-*: interactive structural clean on tip except LPT-713 SoftPulse + LPT-714 unguided + LPT-715 checkpoint residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` observation tiles — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15cb tip c1ae38f7 (#2620 Observe-wide Prefer → Meet-LAG sample-limits LPT-716 Prefer)

- Tip-stable `c1ae38f7` (#2620 Observe-wide SoftPulse Prefer LPT-713 on tip after #2619). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — description PUT hits Jira 32,767 limit; do not claim body rebuilt); other parents Done — no open-parent sync.
- SoftPulse Prefer path catch-up: Selective SoftPulse residual **LPT-706** still To Do + Meet-TAG working-model residual **LPT-708** still To Do + Adjust-TAG SoftPulse residual **LPT-709** (+ **LPT-710**) still To Do + Observe-wide SoftPulse residual **LPT-713** (+ **LPT-714** / **LPT-715**) still To Do advanced through Prefer SoftPulse path this fold.
- Prefer NEVER Meet-LAG sample-limits residual re-check `lesson-06-12-02-01/02/03` / `act-06-12-02-*`:
  - SoftPulse WIDE→PRESSURE→MODEL + `explainGrading` "Wide → Pressure → Model." + Dart `LagModelDemo.points` WIDE/PRESSURE/MODEL (captions Wide in / Pressure on / Working model) / layout "Tap Wide, then Pressure, then Model." under Introduce LAG / The LAG model — **concept-aligned** (not SoftPulse residual).
  - companion checkpoint SoftPulse `limits` kind `none` densify PRESENT (prompt "Show beside LAG label?" / Sample limits vs Destiny; helper "Beside LAG label — pick what to show.") still under Introduce LAG-only (`lesson-06-12-02-01-lag-model` objective "Introduce LAG") → residual **LPT-716** still To Do (needs-human; Relates LPT-300 — do not re-add needs-human on curriculum).
  - successors SoftPulse WIDE OPENS→BARRELS / RAISES→CALLS content-driven (do not reopen LPT-669); guided SoftPulse `lag` densify PRESENT; scaffolded SoftPulse `diff` one-per-press densify PRESENT; unguided SoftPulse `lag2` one-per-press densify PRESENT.
- Curriculum **LPT-300** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-716/300/829/718/719/713/351/198/216/709 on tip `c1ae38f7` this tick (fold text prepared earlier; Jira SHA hits were *0* until comments landed); leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Adjust-LAG SoftPulse residual **LPT-718** (+ cite **LPT-719**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-12-02-*: interactive structural clean on tip except LPT-716 sample-limits residual; SoftPulse explain concept-aligned + successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` player-type tiles — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15cc tip 0d4720cd (#2622 Meet-LAG Prefer → Adjust-LAG SoftPulse LPT-718 Prefer)

- Tip-stable `0d4720cd` (#2622 Meet-LAG sample-limits Prefer LPT-716 accuracy on tip after #2621). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — description PUT hits Jira 32,767 limit; do not claim body rebuilt); other parents Done — no open-parent sync.
- Prefer NEVER Adjust-LAG SoftPulse residual re-check `lesson-06-12-03-01/02/03` / `act-06-12-03-*`:
  - first-child SoftPulse CALL→TRAP→FANCY LESS + `explainGrading` "Call → Trap → Fancy less." + Dart `VsLagsDemo.points` CALL/TRAP/FANCY LESS (captions Widen defense / Slow-play value / Skip hero bluffs) / `LessonVsLagsExplainTable` / layout "Tap Call, then Trap, then Fancy less." + coachMedia "Versus LAG: trap more, call wider, fancy less." still pre-split under Call-wider-only (`lesson-06-12-03-01-call-wider` objective "Widen bluff-catches versus LAG") → residual **LPT-718** still To Do (needs-human; Relates LPT-303 — do not re-add needs-human on curriculum).
  - companion checkpoint SoftPulse `cite` kind `none` densify PRESENT (prompt "LAG exploit cites?"; helper "LAG exploit cites — pick the cite."; `lagAdjustCiteOutcomes`) still under Call-wider → residual **LPT-719** still To Do (needs-human; Relates LPT-303).
  - successors SoftPulse STRONG HAND→LET THEM BET / NO BIG BLUFF→LET THEM content-driven (do not reopen LPT-669); guided SoftPulse `call` PRESENT (`Jh`/`9d`·`Qc`/`9s`/`3h`/`2d`/`7c` +2 suit variants match Dart); scaffolded SoftPulse `trap` one-per-press PRESENT (`As`/`Ad`·`Ac`/`7s`/`2h` +2 suit variants); unguided SoftPulse `avoid` one-per-press densify PRESENT.
- Curriculum **LPT-303** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- SoftPulse Prefer path catch-up: Selective SoftPulse residual **LPT-706** still To Do + Meet-TAG working-model residual **LPT-708** still To Do + Adjust-TAG SoftPulse residual **LPT-709** (+ **LPT-710**) still To Do + Observe-wide SoftPulse residual **LPT-713** (+ **LPT-714** / **LPT-715**) still To Do + Meet-LAG sample-limits residual **LPT-716** still To Do advanced through Prefer SoftPulse path this fold.
- Tip-commented LPT-718/719/303/829/721/716/351/198/216/713; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Mix-five SoftPulse residual **LPT-721** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-12-03-*: interactive structural clean on tip except LPT-718 SoftPulse + LPT-719 cite residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded sizing `fixed`+variants — do not reopen LPT-627; unguided/checkpoint `deal.mode` `none` — do not file handFamily; densify PRESENT on unguided/checkpoint — do not reopen LPT-628.

## Fold 2026-10-15cd tip 412f8206 (#2625 LPT-840 → Mix-five SoftPulse LPT-721 Prefer)

- Tip-stable `412f8206` (#2625 LPT-840 gold SoftPulse Semantics on tip after #2624 Adjust-LAG enrich). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — description PUT hits Jira 32,767 limit; do not claim body rebuilt); other parents Done — no open-parent sync.
- SoftPulse Prefer path catch-up: Selective SoftPulse residual **LPT-706** still To Do + Meet-TAG working-model residual **LPT-708** still To Do + Adjust-TAG SoftPulse residual **LPT-709** (+ **LPT-710**) still To Do + Observe-wide SoftPulse residual **LPT-713** (+ **LPT-714** / **LPT-715**) still To Do + Meet-LAG sample-limits residual **LPT-716** still To Do + Adjust-LAG SoftPulse residual **LPT-718** (+ **LPT-719**) still To Do advanced through Prefer SoftPulse path this fold.
- Prefer NEVER Mix-five SoftPulse residual re-check `lesson-06-13-01-01/02/03/04` / `act-06-13-01-*`:
  - first-child SoftPulse CARDS→SEATS→EVIDENCE + `explainGrading` "Cards → Seats → Evidence." + Dart `ExploitEvidenceDemo.points` CARDS/SEATS/EVIDENCE (captions Equal holdings / Type differs / Prove before exploit) / `LessonExploitEvidenceExplainTable` / layout "Tap Cards, then Seats, then Evidence." + coachMedia "Five models. Same cards. Change only with evidence." still pre-split under Station-thin-only (`lesson-06-13-01-01-station-thin-value` objective "Value thin versus a Calling Station") → residual **LPT-721** still To Do (needs-human; Relates LPT-306 — do not re-add needs-human on curriculum).
  - successors SoftPulse NIT CHECK-RAISE→FOLD / LAG BARREL→CALL / TENDENCY→LINE content-driven (do not reopen LPT-669); guided SoftPulse `cs` SoftPulse map PRESENT (`Jh`/`Td`·`Qc`/`Ts`/`3h`/`2d`/`7c` +2 suit variants match Dart); scaffolded SoftPulse `nit` one-per-press SoftPulse map PRESENT; unguided SoftPulse `lag` one-per-press SoftPulse map PRESENT (poker_action_sizing — densify N/A); checkpoint SoftPulse `tag` kind `none` densify PRESENT under cite-tendency — no companion residual.
- Curriculum **LPT-306** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-721/306/829/790/718/351/198/216/716; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Carry SoftPulse residual **LPT-790** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-06-13-01-*: interactive structural clean on tip except LPT-721 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded/unguided sizing `fixed`+variants — do not reopen LPT-627; checkpoint `deal.mode` `none` cite tiles — do not file handFamily; densify PRESENT on checkpoint — do not reopen LPT-628.

## Fold 2026-10-15ce tip 8f158c1c (#2626 Mix-five Prefer → Carry SoftPulse LPT-790 Prefer)

- Tip-stable `8f158c1c` (#2626 Mix-five SoftPulse Prefer LPT-721 on tip after #2625). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — description PUT hits Jira 32,767 limit; do not claim body rebuilt); other parents Done — no open-parent sync.
- SoftPulse Prefer path catch-up: Selective SoftPulse residual **LPT-706** still To Do + Meet-TAG working-model residual **LPT-708** still To Do + Adjust-TAG SoftPulse residual **LPT-709** (+ **LPT-710**) still To Do + Observe-wide SoftPulse residual **LPT-713** (+ **LPT-714** / **LPT-715**) still To Do + Meet-LAG sample-limits residual **LPT-716** still To Do + Adjust-LAG SoftPulse residual **LPT-718** (+ **LPT-719**) still To Do + Mix-five SoftPulse residual **LPT-721** still To Do advanced through Prefer SoftPulse path this fold.
- Prefer NEVER Carry SoftPulse residual re-check `lesson-07-01-01-01/02/03` / `act-07-01-01-*`:
  - first-child SoftPulse REASON→CONFIRM→CANCEL + `explainGrading` "Reason → Confirm → Cancel." + Dart `PreflopFlopPlanDemo.points` REASON/CONFIRM/CANCEL (captions Enter with why / Flop agrees / Flop kills it) / `LessonPreflopFlopPlanExplainTable` / layout "Tap Reason, then Confirm, then Cancel." + coachMedia "Enter with a reason. Flop confirms or cancels." still pre-split under State-a-preflop-thesis-only (`lesson-07-01-01-01-preflop-thesis` objective "State a preflop thesis") → residual **LPT-790** still To Do (needs-human; Relates LPT-310 — do not re-add needs-human on curriculum).
  - successors SoftPulse TEXTURE→CONFIRM OR CANCEL / DEAD PLAN→LET GO content-driven (do not reopen LPT-669); guided SoftPulse `dead` densify PRESENT; scaffolded SoftPulse `value` one-per-press densify PRESENT; unguided SoftPulse `thesis` one-per-press densify PRESENT; checkpoint SoftPulse `abandon` kind `none` densify PRESENT under Abandon dead plans — matches (no companion residual).
- Curriculum **LPT-310** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-790/310/829/794/721/351/198/216/718; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Map SoftPulse residual **LPT-794** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-07-01-01-*: interactive structural clean on tip except LPT-790 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` plan tiles — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15cf tip e88d750f (#2627 Carry Prefer → Map SoftPulse LPT-794 Prefer)

- Tip-stable `e88d750f` (#2627 Carry SoftPulse Prefer LPT-790 on tip after #2626). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — description PUT hits Jira 32,767 limit; do not claim body rebuilt); other parents Done — no open-parent sync.
- Prefer NEVER Map SoftPulse residual re-check `lesson-07-02-01-01/02/03` / `act-07-02-01-*`:
  - first-child SoftPulse BARREL→GIVE-UP→MAP + `explainGrading` "Barrel → Give-up → Map." + Dart `TurnMapDemo.points` BARREL/GIVE-UP/MAP (captions Cards to continue / Cards to kill / Before flop bet) / `LessonTurnMapExplainTable` / layout "Tap Barrel, then Give-up, then Map." + coachMedia "Flop bet needs a turn map. Continue or kill." still pre-split under continue-cards-only (`lesson-07-02-01-01-continue-cards` objective "List turn continue cards") → residual **LPT-794** still To Do (needs-human; Relates LPT-314 — do not re-add needs-human on curriculum).
  - successors SoftPulse BRICK→GIVE UP / CONTINUE→GIVE-UP→MAP content-driven (do not reopen LPT-669); guided SoftPulse `ok` densify PRESENT; scaffolded SoftPulse `give` one-per-press densify PRESENT; unguided SoftPulse `avoid` one-per-press densify PRESENT; checkpoint SoftPulse `list` kind `none` densify PRESENT under map-definition — no companion residual.
- Curriculum **LPT-314** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-794/314/829/795/790/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Compose SoftPulse residual **LPT-795** (+ cite **LPT-796**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-07-02-01-*: interactive structural clean on tip except LPT-794 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` plan tiles — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15ck tip 20069b98 (#2633 Stack Prefer → Low curriculum LPT-351 Prefer)

- Tip-stable `20069b98` (#2633 Stack SoftPulse Prefer LPT-802 on tip after #2632). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — description PUT hits Jira 32,767 limit; do not claim body rebuilt); other parents Done — no open-parent sync.
- SoftPulse Prefer NEVER residual walk through Stack complete this pass.
- Prefer NEVER Low curriculum warm-up split re-check `lesson-07-11-01-live-warmup-prep` / `act-07-11-01-*`:
  - still packs three objectives (List warm-up checklist items / Carry defaults into Live / Stay inside live cash NLH scope) + SoftPulse CHECKLIST→DEFAULTS→ONE HAND + `explainGrading` "Checklist → Defaults → One hand." + coachMedia "Live warm-up: short checklist, then play. Plan 10 wires the bridge."
  - guided SoftPulse `list` densify PRESENT; scaffolded SoftPulse `defaults` one-per-press densify PRESENT; unguided SoftPulse `scope` one-per-press densify PRESENT; checkpoint SoftPulse `one` kind `none` densify PRESENT (prompt "Warm-up goal?") still under "Carry defaults into Live" — objective mismatch.
  - residual **LPT-351** still To Do (needs-human; gates `lesson-07-12-01-five-type-final` — do not remove needs-human / do not clone).
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-351/829/802/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Capstone SoftPulse Prefer / SoftPulse residual **LPT-676** re-check / Low residuals LPT-676…802 / open catalog LPT-829.
- act-07-11-01-*: interactive structural clean on tip except multi-concept curriculum LPT-351; densify PRESENT — do not reopen LPT-628; pressHints PRESENT on scaffolded/unguided — do not reopen LPT-667; checkpoint hintless OK.

## Fold 2026-10-15cj tip cab77102 (#2632 HU Prefer → Stack SoftPulse LPT-802 Prefer)

- Tip-stable `cab77102` (#2632 HU SoftPulse Prefer LPT-800 on tip after #2630). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — description PUT hits Jira 32,767 limit; do not claim body rebuilt); other parents Done — no open-parent sync.
- Prefer NEVER Stack SoftPulse residual re-check `lesson-07-06-01-01/02/03` / `act-07-06-01-*`:
  - first-child SoftPulse SHORT→DEEP→EFFECTIVE + `explainGrading` "Short → Deep → Effective." + Dart `StackDepthPlansDemo.points` SHORT/DEEP/EFFECTIVE (captions Commit earlier / Implied odds / Recalc each hand) / `LessonStackDepthPlansExplainTable` / layout "Tap Short, then Deep, then Effective." + coachMedia "Effective stack rewrites the plan every hand." still pre-split under Commit-earlier-short-only (`lesson-07-06-01-01-commit-short` objective "Commit earlier short") → residual **LPT-802** still To Do (needs-human; Relates LPT-326 — do not re-add needs-human on curriculum).
  - successors SoftPulse DEEP→IMPLIED ODDS / SHORTER STACK→PLAN content-driven (do not reopen LPT-669); guided SoftPulse `commit` densify PRESENT; scaffolded SoftPulse `yes` one-per-press densify PRESENT; unguided SoftPulse `40` one-per-press densify PRESENT; checkpoint SoftPulse `every` kind `none` densify PRESENT under recalc-effective — concept-aligned (no companion residual).
- Curriculum **LPT-326** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-802/326/829/800/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829 (SoftPulse Prefer NEVER residual walk through Stack complete this pass).
- act-07-06-01-*: interactive structural clean on tip except LPT-802 SoftPulse residual; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/scaffolded/unguided/checkpoint densify PRESENT; `deal.mode` `none` — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15ci tip c4dccacd (#2630 Pot Prefer → HU SoftPulse LPT-800 Prefer)

- Tip-stable `c4dccacd` (#2630 Pot SoftPulse Prefer LPT-798 on tip after #2629). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — description PUT hits Jira 32,767 limit; do not claim body rebuilt); other parents Done — no open-parent sync.
- Prefer NEVER HU SoftPulse residual re-check `lesson-07-05-01-01/02/03` / `act-07-05-01-*`:
  - first-child SoftPulse FEWER→THICKER→WIDEN + `explainGrading` "Fewer → Thicker → Widen." + Dart `HuVsMultiwayDemo.points` FEWER/THICKER/WIDEN (captions Bluff less MW / Value up MW / HU selected bluffs) / `LessonHuVsMultiwayExplainTable` / layout "Tap Fewer, then Thicker, then Widen." + coachMedia "More players: fewer bluffs, thicker value." still pre-split under Bluff-less-multiway-only (`lesson-07-05-01-01-bluff-less-multiway` objective "Bluff less multiway") → residual **LPT-800** still To Do (needs-human; Relates LPT-323 — do not re-add needs-human on curriculum).
  - companion checkpoint SoftPulse `input` kind `none` densify PRESENT (prompt "Player count is?"; helper "Player count — pick how it ranks."; tile "A first-class planning input") under Bluff-less-multiway → **LPT-801** still To Do.
  - successors SoftPulse MULTIWAY→THICK VALUE / HEADS-UP→STEAL MORE content-driven (do not reopen LPT-669); guided SoftPulse `no` densify PRESENT; unguided SoftPulse `thick` one-per-press densify PRESENT; scaffolded SoftPulse `higher` one-per-press densify PRESENT.
- Curriculum **LPT-323** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-800/801/323/829/802/798/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Stack SoftPulse residual **LPT-802** re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-07-05-01-*: interactive structural clean on tip except LPT-800 SoftPulse + LPT-801 player-count residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided/unguided/scaffolded/checkpoint densify PRESENT; checkpoint `deal.mode` `none` — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15cg tip ff346c93 (#2628 Map Prefer → Compose SoftPulse LPT-795 Prefer)

- Tip-stable `ff346c93` (#2628 Map SoftPulse Prefer LPT-794 on tip after #2627). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — description PUT hits Jira 32,767 limit; do not claim body rebuilt); other parents Done — no open-parent sync.
- Prefer NEVER Compose SoftPulse residual re-check `lesson-07-03-01-01/02/03` / `act-07-03-01-*`:
  - first-child SoftPulse VALUE→BLUFF→HOLD + `explainGrading` "Value → Bluff → Hold." + Dart `RiverCompositionDemo.points` VALUE/BLUFF/HOLD (captions Needs calls / Needs folds / Check trash) / `LessonRiverCompositionExplainTable` / layout "Tap Value, then Bluff, then Hold." + coachMedia "River: value if they call worse; bluff if they fold better." still pre-split under Choose-river-value-candidates-only (`lesson-07-03-01-01-river-value` objective "Choose river value candidates") → residual **LPT-795** still To Do (needs-human; Relates LPT-317 — do not re-add needs-human on curriculum).
  - companion checkpoint SoftPulse `rule` kind `none` densify PRESENT (prompt "River composition rule?"; helper "River rule — pick the composition check.") under value-only → **LPT-796** still To Do.
  - successors SoftPulse BLOCKER→FEWER CALLS / NO STORY→CHECK content-driven (do not reopen LPT-669); guided SoftPulse `val` PRESENT (`As`/`Ad`·`Ac`/`9s`/`4h`/`2d`/`7c` +2 suit variants; poker_action_sizing densify N/A); scaffolded SoftPulse `block` one-per-press densify PRESENT; unguided SoftPulse `check` one-per-press densify PRESENT.
- Curriculum **LPT-317** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-795/796/317/829/794/790/351/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER Pot SoftPulse residual **LPT-798** (+ cite **LPT-799**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-07-03-01-*: interactive structural clean on tip except LPT-795 SoftPulse + LPT-796 rule residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); guided sizing `fixed`+variants — do not reopen LPT-627; scaffolded/unguided/checkpoint `deal.mode` `none` — do not file handFamily; densify PRESENT — do not reopen LPT-628.

## Fold 2026-10-15ch tip d51206a6 (#2629 Compose Prefer → Pot SoftPulse LPT-798 Prefer)

- Tip-stable `d51206a6` (#2629 Compose SoftPulse Prefer LPT-795 fold on tip after #2628). Catalog `--counts` short-ladder **224** (other JSON gaps **0**); softpulseMapArms **92** / densifyHelperArms **233** flat (densify-tap still **0** — no LPT-628 reopen).
- Open catalog parent **LPT-829** tip-synced flat **224** (checklist tip-comment only — description PUT hits Jira 32,767 limit; do not claim body rebuilt); other parents Done — no open-parent sync.
- Prefer NEVER Pot SoftPulse residual re-check `lesson-07-04-01-01/02/03` / `act-07-04-01-*`:
  - first-child SoftPulse LIMPED→SRP→3-4BET + `explainGrading` "Limped → SRP → 3-bet/4-bet." + Dart `PotTypePlansDemo.points` LIMPED/SRP/3-4BET (captions Nut potential / C-bet maps / High commit) / `LessonPotTypePlansExplainTable` / layout "Tap Limped, then SRP, then 3-4bet." + coachMedia "Pot type sets ranges and SPR. Plan accordingly." still pre-split under Plan-limped-pots-only (`lesson-07-04-01-01-limped-pots` objective "Plan limped pots") → residual **LPT-798** still To Do (needs-human; Relates LPT-320 — do not re-add needs-human on curriculum).
  - companion checkpoint SoftPulse `both` kind `none` densify PRESENT (prompt "Pot type changes?"; densify "Pot type — pick what changes."; tile "Ranges and SPR") under Plan 3-bet/4-bet-only (`lesson-07-04-01-03-threebet-fourbet-pots`) → **LPT-799** still To Do.
  - successors SoftPulse HEADS-UP→C-BET / LOW SPR→COMMIT content-driven (do not reopen LPT-669); guided SoftPulse `nuts` densify PRESENT; scaffolded SoftPulse `cb` one-per-press densify PRESENT; unguided SoftPulse `commit` one-per-press densify PRESENT.
- Curriculum **LPT-320** Done — do not clone / do not re-add needs-human.
- Meet Nit LPT-198 / LPT-216 Done re-verify OK.
- Tip-commented LPT-798/799/320/829/795/351/800/198/216; leave open LPT-676…802 + LPT-351 + LPT-829; leave In Progress SoftPulse residuals alone; leave ui-agent alone.
- Prefer next: NEVER HU SoftPulse residual **LPT-800** (+ cite **LPT-801**) re-check / Low residuals LPT-676…802 / Low curriculum LPT-351 / open catalog LPT-829.
- act-07-04-01-*: interactive structural clean on tip except LPT-798 SoftPulse + LPT-799 Ranges-SPR residuals; SoftPulse explain successors content-driven (do not reopen LPT-669); all interactive acts are `deal.mode` `none` outcome tiles — do not file handFamily; densify PRESENT — do not reopen LPT-628.

