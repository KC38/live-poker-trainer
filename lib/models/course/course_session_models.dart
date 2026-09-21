/// DTOs for course attempt callables (Plan 03 wire contract).
library;

import 'package:live_poker_trainer/models/course/course_catalog.dart';

/// Resume pointer returned by start/submit/complete/getCourseState.
class CourseResumePointer {
  /// Creates a resume pointer.
  const CourseResumePointer({
    required this.attemptId,
    required this.lessonId,
    required this.activityId,
    required this.activityIndex,
  });

  final String attemptId;
  final String lessonId;
  final String activityId;
  final int activityIndex;

  factory CourseResumePointer.fromJson(Map<String, dynamic> json) {
    return CourseResumePointer(
      attemptId: json['attemptId'] as String,
      lessonId: json['lessonId'] as String,
      activityId: json['activityId'] as String,
      activityIndex: (json['activityIndex'] as num).toInt(),
    );
  }
}

/// In-progress or completed lesson attempt snapshot.
class CourseAttemptSnapshot {
  /// Creates an attempt snapshot.
  const CourseAttemptSnapshot({
    required this.attemptId,
    required this.lessonId,
    required this.catalogVersion,
    required this.status,
    required this.activityIndex,
    required this.currentActivityId,
    required this.livesRemaining,
    required this.livesMax,
    required this.acceptedCount,
    required this.scoredCount,
    required this.stepCount,
    this.jumpTestPassed = false,
  });

  final String attemptId;
  final String lessonId;
  final String catalogVersion;
  final String status;
  final int activityIndex;
  final String currentActivityId;
  final int livesRemaining;
  final int livesMax;
  final int acceptedCount;
  final int scoredCount;
  final int stepCount;
  final bool jumpTestPassed;

  bool get isComplete => status == 'completed';
  bool get needsRemediation => status == 'remediation';

  factory CourseAttemptSnapshot.fromJson(Map<String, dynamic> json) {
    return CourseAttemptSnapshot(
      attemptId: json['attemptId'] as String,
      lessonId: json['lessonId'] as String,
      catalogVersion: json['catalogVersion'] as String? ?? '',
      status: json['status'] as String? ?? 'in_progress',
      activityIndex: (json['activityIndex'] as num?)?.toInt() ?? 0,
      currentActivityId: json['currentActivityId'] as String? ?? '',
      livesRemaining: (json['livesRemaining'] as num?)?.toInt() ?? 0,
      livesMax: (json['livesMax'] as num?)?.toInt() ?? 3,
      acceptedCount: (json['acceptedCount'] as num?)?.toInt() ?? 0,
      scoredCount: (json['scoredCount'] as num?)?.toInt() ?? 0,
      stepCount: (json['stepCount'] as num?)?.toInt() ?? 0,
      jumpTestPassed: json['jumpTestPassed'] as bool? ?? false,
    );
  }
}

/// Result of [CourseService.startLesson].
class StartCourseLessonResult {
  /// Creates a start result.
  const StartCourseLessonResult({
    required this.attempt,
    required this.resume,
    required this.duplicate,
  });

  final CourseAttemptSnapshot attempt;
  final CourseResumePointer resume;
  final bool duplicate;

  factory StartCourseLessonResult.fromJson(Map<String, dynamic> json) {
    return StartCourseLessonResult(
      attempt: CourseAttemptSnapshot.fromJson(
        Map<String, dynamic>.from(json['attempt'] as Map),
      ),
      resume: CourseResumePointer.fromJson(
        Map<String, dynamic>.from(json['resume'] as Map),
      ),
      duplicate: json['duplicate'] as bool? ?? false,
    );
  }
}

/// Soft-graded step outcome from the server.
class SubmitCourseStepResult {
  /// Creates a submit result.
  const SubmitCourseStepResult({
    required this.attemptId,
    required this.activityId,
    required this.grade,
    required this.feedback,
    required this.accepted,
    required this.lifeLost,
    required this.livesRemaining,
    required this.xpAwarded,
    required this.remediationRequired,
    required this.resume,
    required this.duplicate,
    this.betterChoiceId,
    this.reversalRead,
    this.masteryWeight = 0,
  });

  final String attemptId;
  final String activityId;
  final SoftGrade grade;
  final String feedback;
  final bool accepted;
  final bool lifeLost;
  final int livesRemaining;
  final int xpAwarded;
  final bool remediationRequired;
  final CourseResumePointer resume;
  final bool duplicate;
  final String? betterChoiceId;
  final String? reversalRead;
  final double masteryWeight;

  factory SubmitCourseStepResult.fromJson(Map<String, dynamic> json) {
    return SubmitCourseStepResult(
      attemptId: json['attemptId'] as String,
      activityId: json['activityId'] as String,
      grade: softGradeFromWire(json['grade'] as String),
      feedback: json['feedback'] as String? ?? '',
      accepted: json['accepted'] as bool? ?? false,
      lifeLost: json['lifeLost'] as bool? ?? false,
      livesRemaining: (json['livesRemaining'] as num?)?.toInt() ?? 0,
      xpAwarded: (json['xpAwarded'] as num?)?.toInt() ?? 0,
      remediationRequired: json['remediationRequired'] as bool? ?? false,
      resume: CourseResumePointer.fromJson(
        Map<String, dynamic>.from(json['resume'] as Map),
      ),
      duplicate: json['duplicate'] as bool? ?? false,
      betterChoiceId: json['betterChoiceId'] as String?,
      reversalRead: json['reversalRead'] as String?,
      masteryWeight: (json['masteryWeight'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Lesson completion payload.
class CompleteCourseLessonResult {
  /// Creates a complete result.
  const CompleteCourseLessonResult({
    required this.attemptId,
    required this.lessonId,
    required this.xpAwarded,
    required this.mastery,
    required this.streak,
    required this.acceptedAccuracy,
    required this.liveTrainingGranted,
    required this.duplicate,
    this.resume,
  });

  final String attemptId;
  final String lessonId;
  final int xpAwarded;
  final double mastery;
  final int streak;
  final double acceptedAccuracy;
  final bool liveTrainingGranted;
  final bool duplicate;
  final CourseResumePointer? resume;

  factory CompleteCourseLessonResult.fromJson(Map<String, dynamic> json) {
    final resumeRaw = json['resume'];
    return CompleteCourseLessonResult(
      attemptId: json['attemptId'] as String,
      lessonId: json['lessonId'] as String,
      xpAwarded: (json['xpAwarded'] as num?)?.toInt() ?? 0,
      mastery: (json['mastery'] as num?)?.toDouble() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      acceptedAccuracy: (json['acceptedAccuracy'] as num?)?.toDouble() ?? 0,
      liveTrainingGranted: json['liveTrainingGranted'] as bool? ?? false,
      duplicate: json['duplicate'] as bool? ?? false,
      resume: resumeRaw is Map
          ? CourseResumePointer.fromJson(Map<String, dynamic>.from(resumeRaw))
          : null,
    );
  }
}
