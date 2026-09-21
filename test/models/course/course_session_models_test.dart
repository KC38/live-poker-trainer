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
