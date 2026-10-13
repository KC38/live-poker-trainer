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

Optional `assessmentRole`: `checkpoint` | `jump_test` on scaffolded → **no
Hint**. Home path node kinds and jump-test placement use this role (not a
separate stage). Legacy catalogs map explain→guided; unguided→scaffolded;
old checkpoint/jump_test stages→scaffolded+role.

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
single-raised pot (LPT-337), Capstone: 3-bet pot (LPT-339). Content gaps are
audited by [11 — Lesson content agent](11-lesson-content-agent.md).

`deal.handFamily` (and `deal.variants[].handFamily`) must be a value in the
`teach_spec.schema.json` enum. Besides showdown ranks and starting-hand
families, the enum includes the flop action classes `top_pair`, `air`,
`weak_draw`, and `strong_draw`, as used by Fold, check, call and Bet,
raise, all-in. These match `HandClassifier` snake-case names.
`validate_course.mjs` rejects unknown hand or suit families (LPT-166).

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
