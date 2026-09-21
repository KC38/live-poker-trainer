/// Resume / idempotency helpers for the lesson runner.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';

void main() {
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
    // After a non-accepted result, clearFeedback mints a new key next time.
    controller.clearFeedbackForRetry();
    final third = controller.ensureIdempotencyKey(
      () => CourseService.newRequestKey('step'),
    );
    expect(third, isNot(first));
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
    controller.bindActivity(next);
    expect(controller.activity.id, 'b');
    expect(controller.draft.hasAnswer, isFalse);
    expect(controller.lastResult, isNull);
    expect(controller.pendingIdempotencyKey, isNull);
    expect(controller.showTargetCue, isFalse);
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

  test('attempt is ready to complete only after every activity is accepted', () {
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
  });
}
