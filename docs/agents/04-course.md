# 04 — Course system

## Goal

A Duolingo-style path that teaches live cash poker by doing — tap the
table, not a multiple-choice textbook.

## Content model

- Public catalog: `assets/course/v2/catalog.json` ↔ `lib/models/course/course_catalog.dart`.
- Authoring / validation: `content/course/` + `tools/course/`.
- Private answers and grading keys live only on the server bank. The client
  catalog must never grow secret keys.

First production lesson id: `lesson-01-01-01-your-two-cards`
(`kFirstCourseLessonId`).

## Lesson runtime

1. `LessonRunnerScreen` starts/resumes via course callables
   (`startCourseLesson`, `submitCourseStep`, `completeCourseLesson`, …).
2. Each step is a `CourseActivity` with an `ActivityRenderer`.
3. `ActivityRegistry` maps renderer → widget; unknown → `UnsupportedActivity`
   (never crash the runner).
4. Steps that use the shared frame go through `LessonScreenLayout`
   (chrome → coach band → stage → tools / answer dock).

### Stages (two only)

| Stage | SoftPulse | Hint | Miss |
| --- | --- | --- | --- |
| `guided` | Walks presses | Off while gold SoftPulse on | Free |
| `scaffolded` | After Hint | Authored `teachSpec.pressHints` (one/press) | Heart |

Optional `assessmentRole`: `checkpoint` | `jump_test` | `transfer` on scaffolded → **no
Hint** (`transfer` = Capstone intentional no-Hint assessment, LPT-348). Home path node kinds and jump-test placement use this role (not a
separate stage). Legacy catalogs map explain→guided; unguided→scaffolded;
old checkpoint/jump_test stages→scaffolded+role.

Jump-test placement: a jump test may start without its prerequisites
(`missingStartPrerequisite`). Completing (passing) one credits every lesson in
the earlier sections onto `completedLessonIds`
(`jumpTestPlacementCreditLessonIds`, `functions/src/course_catalog.ts`), so
Home lands on the first lesson of the jump test's section — e.g. the Section 4
jump check places a regular at Section 4, Unit 1, not Section 1, Unit 1.
Only Section N opens: each jump test is the last node of its own section and
the first prerequisite of Section N+1, so a placement pass (jump test taken
before its section's lessons) is **not** recorded as a completed lesson
(`completedLessonIdsAfterCompletion`); it is kept in `passedJumpTestLessonIds`
(warm-up unlock still honors a passed Section 2 jump). Reads go through
`effectiveCompletedLessonIds` (client mirror `placementAwareCompletedLessonIds`),
which drops a stored jump id whose own prerequisites are incomplete unless the
learner already finished a lesson that requires it, so pre-fix profiles stop
showing Section N+1 unlocked. LPT-1032.

Curriculum splits: catalog `lessonSplitMap` maps a retired multi-concept lesson id to successor lesson ids. Completed progress on the retired id counts as completed for every listed successor — Home unlocks, `startLesson` prereqs, review XP, zero-heart replay, and resume protection on submit / complete / `getCourseState`. Do not raw-`includes()` the stored id list for those checks; successors are not written back onto the profile until that successor is finished. A start request for a retired id opens the first successor still in the catalog. Gates live in `functions/src/lesson_split_map.ts` (client mirror: `lib/models/course/lesson_split_map.dart`). LPT-83+.
Splits keep the retired lesson's unit as the container (successors `lesson-SS-UU-LL-0N-slug` sit in its place) and reuse its activity ids; `isLessonScreenFrameLesson` and `TableFeatures.forLessonId` resolve successors by their `SS-UU-LL` prefix. LPT-87+.


Every scaffolded non-assessment step authors `pressHints` — one short
class-language nudge per SoftPulse cue press (LPT-626 empty-array floor;
LPT-667 one-per-press). No card codes, no hand shorthand, never the
`accessibilityText` answer line, so Hint stops reading the answer out.
Deal-aware Dart lines (showdown-order seats) still win over the static
press-1 text. `scan_content_gaps --gap pressHints` flags both empty arrays
and SoftPulse cue presses missing a matching `pressHints` entry; a new
scaffolded step ships its full per-press list in the same PR.

### teachSpec

Optional authored deal / hint / cue contract on each activity
(`teach_spec.schema.json`): `deal` (`none` | `fixed` | `random_in_class` +
hand/suit families + `variants`), `pressHints`, `cues`. Pilot: Your two
cards. Lessons that follow it on every interactive step: Suits and ranks
(LPT-81), Button and blinds (LPT-85), Hand ranks (LPT-88), Best five and
kickers (LPT-91), Fold, check, call (LPT-94), Bet, raise, all-in (LPT-98),
Streets and action order (LPT-101), How pots are won (LPT-104), Play a full
toy hand (LPT-108), Section 1 jump check (LPT-110), Position labels
(LPT-112), Acting order (LPT-115), Hand families (LPT-119), Open or fold
baseline (LPT-122), Versus an open (LPT-125), Effective stacks (LPT-128),
Live table habits (LPT-131), Full-ring baseline hand (LPT-135), Baseline
jump check (LPT-137), Read the table first (LPT-138), Name your flop class
(LPT-141), Count outs, pay the right price (LPT-144), Choose a flop line
(LPT-149), Plan the turn card (LPT-152), Close the river correctly
(LPT-155), Play tighter multiway (LPT-158), Patch the common leaks
(LPT-161), Section 3 jump check (LPT-165), Think in ranges (LPT-167),
Navigate 3-bet pots (LPT-170), Plan beyond the flop (LPT-174), Size with a
message (LPT-177), SPR decides commitment (LPT-180), Observe sticky callers
(LPT-184), Meet the Calling Station (LPT-187), Adjust versus Calling Station
(LPT-190), Observe narrow players (LPT-193), Meet the Nit (LPT-196), Adjust
versus Nit (LPT-200), Observe wild aggressors (LPT-203), Meet the Maniac
(LPT-206), Adjust versus Maniac (LPT-210), Confidence and samples (LPT-213),
Same hand, different types (LPT-216), Section 4 jump check (LPT-219), Build
multiway ranges (LPT-222), Play 150–300bb stacks (LPT-225), Implied and
reverse odds (LPT-228), Thin value and bluff-catches (LPT-231),
Street-by-street updates (LPT-237), Advanced flop lines (LPT-234), Live
table dynamics (LPT-245), Keep cash session guardrails (LPT-248), Section 5
checkpoint (LPT-251), Choose polarized or merged betting (LPT-262), Use
overbets and geometric pressure (LPT-265), Use blockers without solver
theater (LPT-268), Navigate 3-bet and 4-bet pots by depth (LPT-280), Make
difficult folds; review coolers fairly (LPT-283), Observe selective
aggression (LPT-286), Meet the TAG (LPT-289), Adjust versus TAG (LPT-292),
Meet the LAG (LPT-298), Same cards, five type models (LPT-304), Section 6
checkpoint (LPT-307), Carry a preflop plan onto the flop (LPT-308), Change
plans by pot type (LPT-318), Switch gears between HU and multiway (LPT-321),
Rewrite plans when stacks change (LPT-324), Replay the same hand versus each
type (LPT-328), Integrate type, board, line, and sizing (LPT-331), Capstone:
single-raised pot (LPT-337), Capstone: 3-bet pot (LPT-339), Capstone:
multiway deep (LPT-341), Capstone: limped pot (LPT-345), Capstone: 4-bet pot
(LPT-347), Prep a coached Live warm-up hand (LPT-349), Final: all five
player types (LPT-352), Soft timing evidence (LPT-242), Spot range advantage
and nut advantage (LPT-252), Realize equity in and out of position
(LPT-255), Recognize capped versus uncapped ranges (LPT-258), Defend enough
without frequency theater (LPT-271), Mix with a reason (LPT-275), Observe
wide sustained pressure (LPT-295), Adjust versus LAG (LPT-301), Map turn
barrels before you bet flop (LPT-312), Compose river value and bluffs
(LPT-315), Write your default strategy book (LPT-334). Content gaps are
audited by [11 — Lesson content agent](11-lesson-content-agent.md).

`deal.handFamily` (and `deal.variants[].handFamily`) must be a value in the
`teach_spec.schema.json` enum. Besides showdown ranks and starting-hand
families, the enum includes the flop action classes `top_pair`, `air`,
`weak_draw`, and `strong_draw`, as used by Fold, check, call and Bet,
raise, all-in. These match `HandClassifier` snake-case names.
`validate_course.mjs` rejects unknown hand or suit families (LPT-166).

Every `deal.mode` `fixed` step authors `deal.variants` (LPT-627). The
catalog default is two suit-rotated isomorphs of the primary `fixedCards`
(`var-<step>-suits-1/2`, label "Same spot, suits rotated (N)"): same ranks,
suitedness, hand class, and draw outs, so cues, choice ids, and grading fit
every variant. `test/models/course/lpt627_fixed_deal_variants_test.dart`
fails on a new fixed step without variants or a variant that changes the
class. Dart does not read `deal.variants` yet; it is catalog contract.

### Activity renderers

| Renderer | Typical use |
| --- | --- |
| `coachDialogue` | Rex speak + acknowledge on felt |
| `selectIdentify` | Tap the right object(s) |
| `orderSequence` | Put seats/actions in order |
| `compareRank` | Which hand wins |
| `numericPotPrice` | Pot / price numbers |
| `pokerActionSizing` | Fixed action / size choice |
| `playerReadClassify` | Player-type reads |
| `authoredMultiStepHand` | Multi-beat authored hand |
| `fullTableHandLab` | Full-table lab / warm-up bridge |

Stages (`guided` / `scaffolded`, plus optional `assessmentRole`) control
SoftPulse and Hint. Reviews hide cues.

## Shared lesson frame (mandatory for new/edited steps)

Contract: `.cursor/rules/lesson-screen-layout.mdc` + design record
"Lesson screen layout".

- **Chrome:** close, progress, hearts — no lesson title row.
- **Coach band:** Rex + one speech bubble (only instruction).
- **Stage:** `LessonTableStage` / same `FeltTableView` as Live.
- **Tools:** undo / redo / hint until graded. Pending frames
  (bootstrap / locked / start error) omit the row (`showToolRow: false`).
- **Answer dock:** Nice! / Oops + Continue (full-bleed).

Reference lesson: Your two cards. Copy it; do not invent a second frame.

## Table features by lesson

`TableFeatures.forLessonId` turns layers on when the course teaches them
(blinds, button, pot, villains types, …). Hide more per step with `features`
on the stage — do not fork a second table widget. Empty board slot outlines
stay off for every lesson (`boardSlots` defaults false / `forLesson` keeps
them false — LPT-80). Live Training uses `TableFeatures.full` when
placeholders are wanted. Do not re-opt lesson stages into `boardSlots: true`.

Default lesson stakes: `$1/$2` NLH unless the step overrides blinds.

Preflop folds-to-you spots (`Pot 3`, no board) keep those blinds posted in
front of SB/BB. `shouldApplyLessonActionFeltMoney` must not paint a zero
street-bet list over them. Completed lines ("BB calls your open", "Blinds
fold") and dealt-board pots still apply the labeled pot (LPT-97).

## Hearts economy

- Five hearts. Non-guided mistakes cost a heart. Guided-stage misses do not
  (`evaluateLifeAndAcceptance` in `functions/src/course_session.ts`, LPT-59).
- Zero hearts blocks the lesson in place; empty hearts breathe; tap → refill
  sheet.
- Practice on a weak finished lesson can earn a heart back.
- Server owns refill / validation (`course_hearts.ts`).

## Home path

`CoursePathView`: one section at a time, sticky unit banner, zig-zag circular
nodes, START/REVIEW bubble on tap. Status strip: streak / gems / hearts.
No Resume card, no Rex+Start box on the path (rejected).

## Soft grades

Shared vocabulary with Live coaching:

`recommended | strong | reasonable | questionable | clear_mistake`

Presented as coach feedback, not EV.

## Kill switch / rollout

Documented in README "Course rollout". Agents: if course entry seems broken,
check `appConfig/courseFlags` and client version before rewriting routing.
