/// Wire-contract parsing for course attempt callables (Plan 03/04).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';

void main() {
  group('softGradeFromWire', () {
    test('maps every published grade token', () {
      expect(softGradeFromWire('recommended'), SoftGrade.recommended);
      expect(softGradeFromWire('strong'), SoftGrade.strong);
      expect(softGradeFromWire('reasonable'), SoftGrade.reasonable);
      expect(softGradeFromWire('questionable'), SoftGrade.questionable);
      expect(softGradeFromWire('clear_mistake'), SoftGrade.clearMistake);
    });

    test('rejects unknown tokens so UI cannot invent a grade', () {
      expect(
        () => softGradeFromWire('excellent'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  test('parses nested Maps that are not Map<String, dynamic>', () {
    final json = <dynamic, dynamic>{
      'attemptId': 'att-1',
      'activityId': 'act-1',
      'grade': 'clear_mistake',
      'feedback': 'Not that line',
      'accepted': false,
      'lifeLost': true,
      'livesRemaining': 2,
      'xpAwarded': 0,
      'remediationRequired': true,
      'duplicate': false,
      'betterChoiceId': 'choice-hero-holes',
      'reversalRead': 'When the board pairs',
      'masteryWeight': 0,
      'resume': <dynamic, dynamic>{
        'attemptId': 'att-1',
        'lessonId': 'lesson-1',
        'activityId': 'act-1',
        'activityIndex': 3,
      },
    };

    final result = SubmitCourseStepResult.fromJson(
      Map<String, dynamic>.from(json),
    );
    expect(result.grade, SoftGrade.clearMistake);
    expect(result.accepted, isFalse);
    expect(result.lifeLost, isTrue);
    expect(result.remediationRequired, isTrue);
    expect(result.resume.activityIndex, 3);
    expect(result.betterChoiceId, 'choice-hero-holes');
  });

  test('start result defaults duplicate to false', () {
    final result = StartCourseLessonResult.fromJson(<String, dynamic>{
      'attempt': <String, dynamic>{
        'attemptId': 'att-1',
        'lessonId': 'lesson-1',
        'status': 'in_progress',
        'activityIndex': 0,
        'currentActivityId': 'act-1',
        'livesRemaining': 3,
        'livesMax': 3,
        'acceptedCount': 0,
        'scoredCount': 0,
        'stepCount': 0,
      },
      'resume': <String, dynamic>{
        'attemptId': 'att-1',
        'lessonId': 'lesson-1',
        'activityId': 'act-1',
        'activityIndex': 0,
      },
    });
    expect(result.duplicate, isFalse);
    expect(result.attempt.isComplete, isFalse);
    expect(result.attempt.needsRemediation, isFalse);
    expect(result.attempt.livesMax, 3);
  });

  test('complete result treats missing resume as finished', () {
    final complete = CompleteCourseLessonResult.fromJson(<String, dynamic>{
      'attemptId': 'att-1',
      'lessonId': 'lesson-1',
      'xpAwarded': 25,
      'mastery': 0.85,
      'streak': 2,
      'acceptedAccuracy': 1,
      'liveTrainingGranted': true,
      'duplicate': false,
    });
    expect(complete.resume, isNull);
    expect(complete.liveTrainingGranted, isTrue);
    expect(complete.xpAwarded, 25);
    expect(complete.lessonXpAwarded, isNull);
    expect(complete.heartsRestored, 0);
    expect(complete.gems, 0);
    expect(complete.gemsAwarded, 0);
    expect(complete.livesRemaining, isNull);
    expect(complete.livesMax, isNull);
    expect(complete.livesNextRefillAtMs, isNull);
  });

  test('complete result parses a practice heart restore', () {
    final complete = CompleteCourseLessonResult.fromJson(<String, dynamic>{
      'attemptId': 'att-1',
      'lessonId': 'lesson-1',
      'xpAwarded': 19,
      'lessonXpAwarded': 19,
      'mastery': 1,
      'streak': 1,
      'acceptedAccuracy': 1,
      'liveTrainingGranted': false,
      'duplicate': false,
      'gemsAwarded': 0,
      'gems': 40.8,
      'heartsRestored': 1.9,
      'livesRemaining': 1,
      'livesMax': 5,
      'livesNextRefillAtMs': 900.6,
    });
    expect(complete.heartsRestored, 1);
    expect(complete.gems, 40);
    expect(complete.livesRemaining, 1);
    expect(complete.livesMax, 5);
    expect(complete.livesNextRefillAtMs, 900);
    expect(complete.lessonXpAwarded, 19);
  });

  test('refill result defaults missing heart fields', () {
    final result = RefillCourseHeartsResult.fromJson(<String, dynamic>{
      'method': 'ad',
    });
    expect(result.method, 'ad');
    expect(result.livesRemaining, 0);
    expect(result.livesMax, 5);
    expect(result.heartsRestored, 0);
    expect(result.gems, 0);
    expect(result.gemsSpent, 0);
    expect(result.duplicate, isFalse);
    expect(result.livesNextRefillAtMs, isNull);
    expect(result.nextAdClaimAtMs, isNull);
    expect(result.adClaimsRemainingToday, 0);
  });

  test('refill result truncates fractional counts', () {
    final result = RefillCourseHeartsResult.fromJson(<String, dynamic>{
      'method': 'gems',
      'livesRemaining': 4.9,
      'livesMax': 5,
      'heartsRestored': 3.2,
      'gems': 100.8,
      'gemsSpent': 650,
      'duplicate': true,
      'livesNextRefillAtMs': 12.6,
      'nextAdClaimAtMs': 40.1,
      'adClaimsRemainingToday': 2.7,
    });
    expect(result.method, 'gems');
    expect(result.livesRemaining, 4);
    expect(result.heartsRestored, 3);
    expect(result.gems, 100);
    expect(result.gemsSpent, 650);
    expect(result.duplicate, isTrue);
    expect(result.livesNextRefillAtMs, 12);
    expect(result.nextAdClaimAtMs, 40);
    expect(result.adClaimsRemainingToday, 2);
  });

  test('complete result keeps the server lesson total', () {
    final whole = CompleteCourseLessonResult.fromJson(<String, dynamic>{
      'attemptId': 'att-1',
      'lessonId': 'lesson-1',
      'xpAwarded': 25,
      'lessonXpAwarded': 75,
      'mastery': 1,
      'streak': 1,
      'acceptedAccuracy': 1,
      'liveTrainingGranted': false,
      'duplicate': false,
    });
    final fractional = CompleteCourseLessonResult.fromJson(<String, dynamic>{
      'attemptId': 'att-1',
      'lessonId': 'lesson-1',
      'xpAwarded': 25,
      'lessonXpAwarded': 75.0,
      'mastery': 1,
      'streak': 1,
      'acceptedAccuracy': 1,
      'liveTrainingGranted': false,
      'duplicate': true,
    });
    expect(whole.lessonXpAwarded, 75);
    expect(whole.xpAwarded, 25);
    expect(fractional.lessonXpAwarded, 75);
    expect(fractional.duplicate, isTrue);
  });

  test('displayed lesson XP is step awards plus the completion bonus', () {
    expect(displayedLessonXp(stepXpAwarded: 50, completionBonus: 25), 75);
    expect(
      displayedLessonXp(
        stepXpAwarded: 0,
        completionBonus: 25,
        lessonXpFromServer: 75,
      ),
      75,
    );
    expect(
      displayedLessonXp(
        stepXpAwarded: 50,
        completionBonus: 25,
        lessonXpFromServer: 25,
      ),
      75,
    );
    expect(
      displayedLessonXp(
        stepXpAwarded: 20,
        completionBonus: 25,
        lessonXpFromServer: 75,
      ),
      75,
    );
    expect(
      displayedLessonXp(
        stepXpAwarded: 50,
        completionBonus: 25,
        lessonXpFromServer: 75,
      ),
      75,
    );
  });

  test('attempt snapshot maps remediation status', () {
    final attempt = CourseAttemptSnapshot.fromJson(<String, dynamic>{
      'attemptId': 'att-1',
      'lessonId': 'lesson-1',
      'status': 'remediation',
      'activityIndex': 1,
      'currentActivityId': 'act-2',
      'livesRemaining': 0,
      'acceptedCount': 1,
      'scoredCount': 4,
      'stepCount': 4,
    });
    expect(attempt.needsRemediation, isTrue);
    expect(attempt.isComplete, isFalse);
  });
}
