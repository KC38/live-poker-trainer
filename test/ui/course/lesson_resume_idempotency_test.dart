/// Resume / idempotency helpers for the lesson runner.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('idempotency key is stable across retries for one answer', () {
    UniqueKeySeed.reset();
    final activity = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [CourseChoice(id: 'c1', label: 'One')],
    );
    final controller = LessonActivityController(activity: activity);
    controller.selectChoice('c1');
    final first = controller.ensureIdempotencyKey(
      () => CourseService.newRequestKey('step'),
    );
    final second = controller.ensureIdempotencyKey(
      () => CourseService.newRequestKey('step'),
    );
    expect(first, second);
    controller.beginSubmit(first);
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'att',
        activityId: 'a',
        grade: SoftGrade.questionable,
        feedback: 'try again',
        accepted: false,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 0,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'att',
          lessonId: 'l',
          activityId: 'a',
          activityIndex: 0,
        ),
        duplicate: false,
      ),
    );
    // After a non-accepted result, clearFeedback mints a new key next time
    // and clears the missed draft so SoftPulse / felt selection can restore.
    controller.clearFeedbackForRetry();
    expect(controller.draft.choiceId, isNull);
    expect(controller.lastResult, isNull);
    final third = controller.ensureIdempotencyKey(
      () => CourseService.newRequestKey('step'),
    );
    expect(third, isNot(first));
    controller.dispose();
  });

  test('clearFeedbackForRetry clears felt draft but keeps hand step', () {
    final activity = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [
        CourseChoice(id: 'dealer', label: 'Dealer'),
        CourseChoice(id: 'bb', label: 'Big blind'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.setHandStepIndex(2);
    controller.selectChoice('dealer');
    controller.beginSubmit('k');
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'att',
        activityId: 'a',
        grade: SoftGrade.questionable,
        feedback: 'try again',
        accepted: false,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 0,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'att',
          lessonId: 'l',
          activityId: 'a',
          activityIndex: 0,
        ),
        duplicate: false,
      ),
    );
    expect(controller.draft.choiceId, 'dealer');
    final generation = controller.bindGeneration;
    controller.clearFeedbackForRetry();
    expect(controller.draft.choiceId, isNull);
    expect(controller.draft.handStepIndex, 2);
    expect(controller.lastResult, isNull);
    // SoftPulse gate: unlocked + no selection.
    expect(controller.submitting, isFalse);
    // Retry remounts isomorphic deals (fresh hand in the same family).
    expect(controller.bindGeneration, generation + 1);
    controller.dispose();
  });

  test('clearFeedbackForRetry does not bump generation after an accept', () {
    final activity = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [CourseChoice(id: 'bb', label: 'Big blind')],
    );
    final controller = LessonActivityController(activity: activity);
    controller.selectChoice('bb');
    controller.beginSubmit('k');
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'att',
        activityId: 'a',
        grade: SoftGrade.recommended,
        feedback: 'nice',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'att',
          lessonId: 'l',
          activityId: 'a',
          activityIndex: 0,
        ),
        duplicate: false,
      ),
    );
    final generation = controller.bindGeneration;
    controller.clearFeedbackForRetry();
    expect(controller.bindGeneration, generation);
    expect(controller.lastResult, isNotNull);
    controller.dispose();
  });

  test('hint tracking is separate from correctness draft', () {
    final activity = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(id: 'h', kind: 'hint', text: 'Look at your seat'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    expect(controller.hintRequests, 0);
    expect(controller.hintUsed, isFalse);
    controller.revealHint();
    expect(controller.hintUsed, isTrue);
    controller.revealHint();
    expect(controller.hintRequests, 2);
    expect(controller.draft.hasAnswer, isFalse);
    controller.dispose();
  });

  test('hint stays used for the node after reveal', () {
    final activity = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(id: 'h', kind: 'hint', text: 'Look at your seat'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.revealHint();
    expect(controller.hintUsed, isTrue);
    controller.toggleHint();
    expect(controller.hintVisible, isFalse);
    expect(controller.hintUsed, isTrue);
    controller.dispose();
  });

  test('grading clears Hint so bubble is not stuck under Oops', () {
    final activity = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(id: 'h', kind: 'hint', text: 'Use your pair'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.notifyFeltDealReady(true);
    controller.revealHint();
    expect(controller.hintVisible, isTrue);
    expect(controller.showTargetCue, isTrue);
    const miss = SubmitCourseStepResult(
      attemptId: 'att',
      activityId: 'a',
      grade: SoftGrade.clearMistake,
      feedback: 'try again',
      accepted: false,
      lifeLost: false,
      livesRemaining: 3,
      xpAwarded: 0,
      remediationRequired: false,
      resume: CourseResumePointer(
        attemptId: 'att',
        lessonId: 'l',
        activityId: 'a',
        activityIndex: 0,
      ),
      duplicate: false,
    );
    controller.finishSubmit(miss);
    expect(controller.hintVisible, isFalse);
    expect(controller.showTargetCue, isFalse);
    expect(controller.lastResult?.accepted, isFalse);

    controller.clearFeedbackForRetry();
    controller.notifyFeltDealReady(true);
    controller.revealHint();
    expect(controller.hintVisible, isTrue);
    controller.presentLocalMiss(miss);
    expect(controller.hintVisible, isFalse);
    expect(controller.showTargetCue, isFalse);
    controller.dispose();
  });

  test('binding a new activity clears hint used', () {
    final first = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(id: 'h', kind: 'hint', text: 'Look at your seat'),
      ],
    );
    final second = CourseActivity(
      id: 'b',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'b',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(id: 'h2', kind: 'hint', text: 'Check position'),
      ],
    );
    final controller = LessonActivityController(activity: first);
    controller.revealHint();
    expect(controller.hintUsed, isTrue);
    controller.bindActivity(second);
    expect(controller.hintUsed, isFalse);
    expect(controller.hintVisible, isFalse);
    controller.dispose();
  });

  test('next hand street re-enables Hint on the same activity', () {
    final activity = CourseActivity(
      id: 'multi',
      order: 1,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 60,
      accessibilityText: 'Play two streets',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(id: 'h', kind: 'hint', text: 'Size small'),
      ],
      handSteps: const [
        CourseHandStep(
          id: 'pre',
          street: 'preflop',
          prompt: 'Open',
          choices: [
            CourseChoice(id: 'open', label: 'Open'),
            CourseChoice(id: 'fold', label: 'Fold'),
          ],
        ),
        CourseHandStep(
          id: 'flop',
          street: 'flop',
          prompt: 'C-bet',
          choices: [
            CourseChoice(id: 'bet', label: 'Bet'),
            CourseChoice(id: 'check', label: 'Check'),
          ],
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    expect(controller.currentNodeKey, 'multi#0');
    controller.revealHint();
    expect(controller.hintUsed, isTrue);
    controller.advanceToNextHandStep();
    expect(controller.currentNodeKey, 'multi#1');
    expect(controller.hintUsed, isFalse);
    expect(controller.hintVisible, isFalse);
    controller.revealHint();
    expect(controller.hintUsed, isTrue);
    controller.dispose();
  });

  test('revealing a hint enables tap cues on unguided steps', () {
    final activity = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(id: 'h', kind: 'hint', text: 'Tap the board'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.notifyFeltDealReady(true);
    expect(controller.showTargetCue, isFalse);
    controller.revealHint();
    expect(controller.hintVisible, isTrue);
    expect(controller.showTargetCue, isTrue);
    expect(controller.canRequestHint, isFalse);
    controller.toggleHint();
    expect(controller.hintVisible, isFalse);
    expect(controller.showTargetCue, isFalse);
    controller.dispose();
  });

  test('review run hides teaching cues until Hint', () {
    final activity = CourseActivity(
      id: 'act-01-01-01-guided-find-holes',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'Tap your hole cards on the table.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(id: 'h', kind: 'hint', text: 'Your cards sit at the bottom.'),
      ],
    );
    final firstRun = LessonActivityController(activity: activity);
    firstRun.notifyFeltDealReady(true);
    expect(firstRun.showTargetCue, isTrue);
    firstRun.dispose();

    final review = LessonActivityController(
      activity: activity,
      isReview: true,
    );
    review.notifyFeltDealReady(true);
    expect(review.showTargetCue, isFalse);
    expect(review.canRequestHint, isTrue);
    review.revealHint();
    expect(review.showTargetCue, isTrue);
    expect(review.canRequestHint, isFalse);
    review.dispose();
  });

  test('multi-press SoftPulse only the first wave; Hint stays until done', () {
    final activity = CourseActivity(
      id: 'multi-press',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 40,
      accessibilityText: 'Tap Fold, Check, and Call.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(id: 'h', kind: 'hint', text: 'Start with Fold'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.notifyFeltDealReady(true);
    expect(controller.showTargetCue, isTrue);
    // SoftPulse already teaching — Hint off even before sequential reports
    // (LPT-63; same rule as single-press scaffolded SoftPulse).
    expect(controller.canRequestHint, isFalse);

    controller.notifySequentialPressProgress(remainingPressCount: 3);
    expect(controller.sequentialPressesRemaining, isTrue);
    // SoftPulse already shows the current press — Hint waits for a tap.
    expect(controller.canRequestHint, isFalse);

    controller.consumeSequentialSoftPulse();
    expect(controller.showTargetCue, isFalse);
    expect(controller.canRequestHint, isTrue);

    controller.revealHint();
    expect(controller.hintUsed, isTrue);
    expect(controller.showTargetCue, isTrue);
    expect(controller.canRequestHint, isFalse);

    controller.consumeSequentialSoftPulse();
    expect(controller.showTargetCue, isFalse);
    expect(controller.canRequestHint, isTrue);

    controller.notifySequentialPressProgress(remainingPressCount: 0);
    expect(controller.sequentialPressesRemaining, isFalse);
    expect(controller.canRequestHint, isFalse);
    expect(controller.hintVisible, isFalse);
    controller.dispose();
  });

  test('single-press SoftPulse keeps Hint disabled (LPT-63)', () {
    final activity = CourseActivity(
      id: 'act-01-02-02-scaffolded-kicker',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText:
          'Tap who wins when kickers break a tied pair.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'h',
          kind: 'hint',
          text: 'Tap who wins when kickers break a tied pair.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.notifyFeltDealReady(true);
    expect(controller.showTargetCue, isTrue);
    expect(controller.sequentialPressesRemaining, isFalse);
    expect(controller.canRequestHint, isFalse);
    controller.dispose();
  });

  test('Hint re-opens SoftPulse for the current next press only', () {
    final activity = CourseActivity(
      id: 'scaffolded-multi',
      order: 2,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap each suit.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(id: 'h', kind: 'hint', text: 'Hearts next'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.notifyFeltDealReady(true);
    expect(controller.showTargetCue, isTrue);
    expect(controller.canRequestHint, isFalse);

    controller.notifySequentialPressProgress(remainingPressCount: 4);
    controller.consumeSequentialSoftPulse();
    expect(controller.showTargetCue, isFalse);

    controller.revealHint();
    expect(controller.showTargetCue, isTrue);
    expect(controller.canRequestHint, isFalse);
    controller.consumeSequentialSoftPulse();
    expect(controller.showTargetCue, isFalse);
    expect(controller.canRequestHint, isTrue);
    controller.dispose();
  });

  test('scaffolded sequence SoftPulse stays on because Hint is disabled', () {
    final activity = CourseActivity(
      id: 'act-01-04-01-scaffolded-order',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 50,
      accessibilityText: 'Put UTG, HJ, CO, and BTN in preflop action order.',
      acceptedGrades: const [SoftGrade.recommended],
    );
    final controller = LessonActivityController(activity: activity);
    controller.notifyFeltDealReady(true);
    expect(controller.showTargetCue, isTrue);

    controller.notifySequentialPressProgress(remainingPressCount: 4);
    controller.consumeSequentialSoftPulse();
    expect(controller.showTargetCue, isTrue);

    controller.notifySequentialPressProgress(remainingPressCount: 3);
    controller.consumeSequentialSoftPulse();
    expect(controller.showTargetCue, isTrue);
    controller.dispose();
  });

  test('explain SoftPulse stays on when Hint cannot reopen (LPT-49)', () {
    final activity = CourseActivity(
      id: 'act-01-01-03-explain-button',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Clockwise from the button: small blind, then big blind.',
      acceptedGrades: const [SoftGrade.recommended],
    );
    final controller = LessonActivityController(activity: activity);
    controller.notifyFeltDealReady(true);
    expect(controller.showTargetCue, isTrue);
    // Explain has no fallback hint — SoftPulse must keep teaching.
    expect(lessonFrameHintFallback(activity), isNull);

    controller.notifySequentialPressProgress(remainingPressCount: 3);
    expect(controller.canRequestHint, isFalse);

    controller.consumeSequentialSoftPulse();
    expect(controller.showTargetCue, isTrue);
    expect(controller.canRequestHint, isFalse);

    controller.notifySequentialPressProgress(remainingPressCount: 2);
    controller.consumeSequentialSoftPulse();
    expect(controller.showTargetCue, isTrue);
    expect(controller.canRequestHint, isFalse);

    controller.notifySequentialPressProgress(remainingPressCount: 0);
    expect(controller.sequentialPressesRemaining, isFalse);
    controller.dispose();
  });

  test('duplicate submit result must not animate a fresh life loss', () {
    final result = SubmitCourseStepResult(
      attemptId: 'att',
      activityId: 'a',
      grade: SoftGrade.clearMistake,
      feedback: 'x',
      accepted: false,
      lifeLost: true,
      livesRemaining: 2,
      xpAwarded: 0,
      remediationRequired: false,
      resume: const CourseResumePointer(
        attemptId: 'att',
        lessonId: 'l',
        activityId: 'a',
        activityIndex: 0,
      ),
      duplicate: true,
    );
    // UI rule: life chrome follows server lifeLost, but streak / XP ignore duplicates.
    expect(result.duplicate, isTrue);
    expect(result.lifeLost, isTrue);
    expect(result.xpAwarded, 0);
  });

  test('accepted submit locks the draft; reject can undo and retry', () {
    final activity = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [CourseChoice(id: 'c1', label: 'One')],
    );
    final controller = LessonActivityController(activity: activity);
    expect(controller.showTargetCue, isFalse);

    controller.selectChoice('c1');
    controller.beginSubmit('k1');
    controller.selectChoice('c2');
    expect(controller.draft.choiceId, 'c1');

    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'att',
        activityId: 'a',
        grade: SoftGrade.recommended,
        feedback: 'ok',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'att',
          lessonId: 'l',
          activityId: 'b',
          activityIndex: 1,
        ),
        duplicate: false,
      ),
    );
    controller.undoDraft();
    expect(controller.lastResult, isNotNull);
    expect(controller.draft.choiceId, 'c1');
    controller.dispose();
  });

  test('failSubmit keeps the idempotency key for a network retry', () {
    UniqueKeySeed.reset();
    final activity = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
    );
    final controller = LessonActivityController(activity: activity);
    final key = controller.ensureIdempotencyKey(
      () => CourseService.newRequestKey('step'),
    );
    controller.beginSubmit(key);
    controller.failSubmit();
    expect(controller.submitting, isFalse);
    expect(
      controller.ensureIdempotencyKey(
        () => CourseService.newRequestKey('step'),
      ),
      key,
    );
    controller.dispose();
  });

  test('bindActivity resets draft, feedback, and pending key', () {
    final first = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
    );
    final next = CourseActivity(
      id: 'b',
      order: 2,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'b',
      acceptedGrades: const [SoftGrade.recommended],
    );
    final controller = LessonActivityController(activity: first);
    controller.notifyFeltDealReady(true);
    expect(controller.showTargetCue, isTrue);
    controller.selectChoice('c1');
    controller.ensureIdempotencyKey(() => 'fixed-key');
    final generation = controller.bindGeneration;
    controller.bindActivity(next);
    expect(controller.activity.id, 'b');
    expect(controller.draft.hasAnswer, isFalse);
    expect(controller.lastResult, isNull);
    expect(controller.pendingIdempotencyKey, isNull);
    expect(controller.showTargetCue, isFalse);
    expect(controller.bindGeneration, generation + 1);
    // Rebinding the same activity id still clears provisional state.
    controller.selectChoice('c2');
    controller.bindActivity(next);
    expect(controller.draft.hasAnswer, isFalse);
    expect(controller.bindGeneration, generation + 2);
    controller.dispose();
  });

  test('hand-lab step change clears a prior choice', () {
    final activity = CourseActivity(
      id: 'lab',
      order: 1,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.fullTableHandLab,
      estimatedSeconds: 40,
      accessibilityText: 'lab',
      acceptedGrades: const [SoftGrade.recommended],
    );
    final controller = LessonActivityController(activity: activity);
    controller.selectChoice('fold');
    controller.setHandStepIndex(1);
    expect(controller.draft.choiceId, isNull);
    expect(controller.draft.handStepIndex, 1);
    controller.dispose();
  });

  test('advanceToNextHandStep clears feedback and choice', () {
    final activity = CourseActivity(
      id: 'multi',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 40,
      accessibilityText: 'multi',
      acceptedGrades: const [SoftGrade.recommended],
    );
    final controller = LessonActivityController(activity: activity);
    controller.selectChoice('open-6');
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'att',
        activityId: 'multi',
        grade: SoftGrade.recommended,
        feedback: 'ok',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'att',
          lessonId: 'l',
          activityId: 'multi',
          activityIndex: 0,
        ),
        duplicate: false,
      ),
    );
    controller.advanceToNextHandStep();
    expect(controller.lastResult, isNull);
    expect(controller.draft.choiceId, isNull);
    expect(controller.draft.handStepIndex, 1);
    expect(controller.pendingIdempotencyKey, isNull);
    controller.dispose();
  });

  test('selectChoice accepts the active hand-step id and ignores others', () {
    final activity = CourseActivity(
      id: 'multi',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 40,
      accessibilityText: 'multi',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'flop',
          street: 'flop',
          prompt: 'Flop',
          choices: [
            CourseChoice(id: 'check', label: 'Check'),
            CourseChoice(id: 'bet', label: 'Bet'),
          ],
        ),
        CourseHandStep(
          id: 'turn',
          street: 'turn',
          prompt: 'Turn',
          choices: [CourseChoice(id: 'raise', label: 'Raise')],
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    // Top-level choices are empty; a later-street id must not sneak through.
    controller.selectChoice('raise', autoSubmit: true);
    expect(controller.draft.choiceId, isNull);
    expect(autoSubmits, 0);

    controller.selectChoice('bet', autoSubmit: true);
    expect(controller.draft.choiceId, 'bet');
    expect(autoSubmits, 1);

    controller.setHandStepIndex(1);
    expect(controller.draft.choiceId, isNull);
    controller.selectChoice('bet', autoSubmit: true);
    expect(controller.draft.choiceId, isNull);
    expect(autoSubmits, 1);
    controller.selectChoice('raise', autoSubmit: true);
    expect(controller.draft.choiceId, 'raise');
    expect(controller.draft.handStepIndex, 1);
    expect(autoSubmits, 2);

    // Lookup clamps to the last authored step when the index runs past it.
    controller.setHandStepIndex(9);
    controller.selectChoice('check', autoSubmit: true);
    expect(controller.draft.choiceId, isNull);
    expect(autoSubmits, 2);
    controller.selectChoice('raise');
    expect(controller.draft.choiceId, 'raise');
    expect(controller.draft.handStepIndex, 9);

    controller.beginSubmit('k');
    controller.selectChoice('raise', autoSubmit: true);
    expect(autoSubmits, 2);
    controller.dispose();
  });

  test('selectChoice ignores a choice id from the previous activity', () {
    final guided = CourseActivity(
      id: 'guided',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'guided',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [CourseChoice(id: 'old-raise', label: 'Raise')],
    );
    final next = CourseActivity(
      id: 'scaffolded',
      order: 2,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'next',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [CourseChoice(id: 'new-call', label: 'Call')],
    );
    final controller = LessonActivityController(activity: guided);
    controller.bindActivity(next);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    controller.selectChoice('old-raise', autoSubmit: true);
    expect(controller.draft.hasAnswer, isFalse);
    expect(autoSubmits, 0);

    controller.selectChoice('new-call', autoSubmit: true);
    expect(controller.draft.choiceId, 'new-call');
    expect(autoSubmits, 1);
    controller.dispose();
  });

  test('selectChoice autoSubmit fires only when requested and unlocked', () {
    final activity = CourseActivity(
      id: 'a',
      order: 1,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 30,
      accessibilityText: 'a',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [CourseChoice(id: 'c1', label: 'One')],
    );
    final controller = LessonActivityController(activity: activity);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    controller.selectChoice('c1');
    expect(controller.draft.choiceId, 'c1');
    expect(autoSubmits, 0);

    controller.selectChoice('c1', autoSubmit: true);
    expect(autoSubmits, 1);

    controller.beginSubmit('k1');
    controller.selectChoice('c2', autoSubmit: true);
    expect(controller.draft.choiceId, 'c1');
    expect(autoSubmits, 1);
    controller.dispose();
  });

  test('setOrderedIds autoSubmit fires when the sequence is complete', () {
    final activity = CourseActivity(
      id: 'seq',
      order: 1,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 30,
      accessibilityText: 'seq',
      acceptedGrades: const [SoftGrade.recommended],
      sequenceItems: const [
        CourseChoice(id: 'a', label: 'UTG'),
        CourseChoice(id: 'b', label: 'BTN'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    controller.setOrderedIds(const ['a']);
    expect(autoSubmits, 0);
    controller.setOrderedIds(const ['a', 'b'], autoSubmit: true);
    expect(controller.draft.orderedIds, ['a', 'b']);
    expect(autoSubmits, 1);
    controller.dispose();
  });

  test(
    'attempt is ready to complete only after every activity is accepted',
    () {
      const attemptOnLast = CourseAttemptSnapshot(
        attemptId: 'att',
        lessonId: 'l',
        catalogVersion: '2.0.0',
        status: 'in_progress',
        activityIndex: 4,
        currentActivityId: 'checkpoint',
        livesRemaining: 3,
        livesMax: 3,
        acceptedCount: 4,
        scoredCount: 4,
        stepCount: 6,
      );
      expect(attemptOnLast.isReadyToComplete(5), isFalse);

      const ready = CourseAttemptSnapshot(
        attemptId: 'att',
        lessonId: 'l',
        catalogVersion: '2.0.0',
        status: 'in_progress',
        activityIndex: 5,
        currentActivityId: 'checkpoint',
        livesRemaining: 3,
        livesMax: 3,
        acceptedCount: 5,
        scoredCount: 4,
        stepCount: 5,
      );
      expect(ready.isReadyToComplete(5), isTrue);
    },
  );
}
