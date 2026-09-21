/// Representative end-to-end walkthrough of the production first lesson.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';

/// In-memory course service that mirrors Plan 03 acceptance for one lesson.
class _ScriptedCourseService extends CourseService {
  _ScriptedCourseService(this.catalog) : super();

  final CourseCatalog catalog;
  final List<String> log = <String>[];
  final Set<String> keys = <String>{};
  late CourseAttemptSnapshot attempt;

  List<CourseActivity> get activities =>
      catalog.activitiesForLesson(kFirstCourseLessonId);

  @override
  Future<void> initializeProfile({
    required String catalogVersion,
    String timezone = 'UTC',
  }) async {
    log.add('init');
  }

  @override
  Future<StartCourseLessonResult> startLesson({
    required String lessonId,
    required String catalogVersion,
    required String startRequestId,
    String timezone = 'UTC',
  }) async {
    log.add('start');
    attempt = CourseAttemptSnapshot(
      attemptId: 'attempt-1',
      lessonId: lessonId,
      catalogVersion: catalogVersion,
      status: 'in_progress',
      activityIndex: 0,
      currentActivityId: activities.first.id,
      livesRemaining: 3,
      livesMax: 3,
      acceptedCount: 0,
      scoredCount: 0,
      stepCount: 0,
    );
    return StartCourseLessonResult(
      attempt: attempt,
      resume: CourseResumePointer(
        attemptId: attempt.attemptId,
        lessonId: lessonId,
        activityId: activities.first.id,
        activityIndex: 0,
      ),
      duplicate: false,
    );
  }

  @override
  Future<SubmitCourseStepResult> submitStep({
    required String attemptId,
    required String activityId,
    required String idempotencyKey,
    String? catalogVersion,
    String? choiceId,
    List<String>? orderedIds,
    double? numericValue,
  }) async {
    final duplicate = !keys.add(idempotencyKey);
    log.add('submit:$activityId');
    final index = activities.indexWhere((a) => a.id == activityId);
    final advanceTo = (index + 1).clamp(0, activities.length - 1);
    final nextId = activities[advanceTo].id;
    attempt = CourseAttemptSnapshot(
      attemptId: attemptId,
      lessonId: attempt.lessonId,
      catalogVersion: attempt.catalogVersion,
      status: 'in_progress',
      activityIndex: advanceTo,
      currentActivityId: nextId,
      livesRemaining: 3,
      livesMax: 3,
      acceptedCount: attempt.acceptedCount + (duplicate ? 0 : 1),
      scoredCount: attempt.scoredCount + (duplicate ? 0 : 1),
      stepCount: attempt.stepCount + (duplicate ? 0 : 1),
    );
    return SubmitCourseStepResult(
      attemptId: attemptId,
      activityId: activityId,
      grade: SoftGrade.recommended,
      feedback: 'Nice.',
      accepted: true,
      lifeLost: false,
      livesRemaining: 3,
      xpAwarded: duplicate ? 0 : 10,
      remediationRequired: false,
      resume: CourseResumePointer(
        attemptId: attemptId,
        lessonId: attempt.lessonId,
        activityId: nextId,
        activityIndex: advanceTo,
      ),
      duplicate: duplicate,
    );
  }

  @override
  Future<CompleteCourseLessonResult> completeLesson({
    required String attemptId,
    required String idempotencyKey,
    String? catalogVersion,
  }) async {
    log.add('complete');
    return CompleteCourseLessonResult(
      attemptId: attemptId,
      lessonId: kFirstCourseLessonId,
      xpAwarded: 25,
      mastery: 1,
      streak: 1,
      acceptedAccuracy: 1,
      liveTrainingGranted: false,
      duplicate: false,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('first lesson show→guided→scaffolded→unguided→checkpoint completes',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final catalog = await container.read(courseCatalogProvider.future);
    final lesson = catalog.lessonById(kFirstCourseLessonId)!;
    expect(lesson.title, 'Your two cards');
    expect(
      lesson.activities.map((a) => a.stage).toList(),
      [
        ActivityStage.explain,
        ActivityStage.guided,
        ActivityStage.scaffolded,
        ActivityStage.unguided,
        ActivityStage.checkpoint,
      ],
    );

    final service = _ScriptedCourseService(catalog);
    await service.initializeProfile(catalogVersion: catalog.catalogVersion);
    final started = await service.startLesson(
      lessonId: kFirstCourseLessonId,
      catalogVersion: catalog.catalogVersion,
      startRequestId: 'start_e2e',
    );

    final answers = <String, String?>{
      'act-01-01-01-explain-hole-cards': null,
      'act-01-01-01-guided-find-holes': 'choice-hero-holes',
      'act-01-01-01-scaffolded-private': 'choice-only-you',
      'act-01-01-01-unguided-mix': 'choice-flop',
      'act-01-01-01-checkpoint-table': 'choice-checkpoint-holes',
    };

    var activityId = started.resume.activityId;
    for (final entry in answers.entries) {
      expect(activityId, entry.key);
      final key = 'step_${entry.key}';
      final first = await service.submitStep(
        attemptId: started.attempt.attemptId,
        activityId: entry.key,
        idempotencyKey: key,
        choiceId: entry.value,
      );
      expect(first.accepted, isTrue);
      expect(first.lifeLost, isFalse);
      final retry = await service.submitStep(
        attemptId: started.attempt.attemptId,
        activityId: entry.key,
        idempotencyKey: key,
        choiceId: entry.value,
      );
      expect(retry.duplicate, isTrue);
      expect(retry.xpAwarded, 0);
      activityId = first.resume.activityId;
    }

    final complete = await service.completeLesson(
      attemptId: started.attempt.attemptId,
      idempotencyKey: 'complete_e2e',
    );
    expect(complete.xpAwarded, 25);
    expect(service.log.where((e) => e.startsWith('submit:')).toSet(), hasLength(5));
    expect(service.log, contains('complete'));
  });
}
