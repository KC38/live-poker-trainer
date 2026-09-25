/// Resume / idempotency helpers for the lesson runner.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';

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
    controller.clearFeedbackForRetry();
    expect(controller.draft.choiceId, isNull);
    expect(controller.draft.handStepIndex, 2);
    expect(controller.lastResult, isNull);
    // SoftPulse gate: unlocked + no selection.
    expect(controller.submitting, isFalse);
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
    controller.revealHint();
    controller.revealHint();
    expect(controller.hintRequests, 2);
    expect(controller.draft.hasAnswer, isFalse);
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
