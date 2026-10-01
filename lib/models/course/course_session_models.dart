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

  /// True when every activity was accepted and completeLesson should run.
  bool isReadyToComplete(int activityCount) =>
      activityCount > 0 &&
      (activityIndex >= activityCount || acceptedCount >= activityCount);

  factory CourseAttemptSnapshot.fromJson(Map<String, dynamic> json) {
    return CourseAttemptSnapshot(
      attemptId: json['attemptId'] as String,
      lessonId: json['lessonId'] as String,
      catalogVersion: json['catalogVersion'] as String? ?? '',
      status: json['status'] as String? ?? 'in_progress',
      activityIndex: (json['activityIndex'] as num?)?.toInt() ?? 0,
      currentActivityId: json['currentActivityId'] as String? ?? '',
      livesRemaining: (json['livesRemaining'] as num?)?.toInt() ?? 0,
      livesMax: (json['livesMax'] as num?)?.toInt() ?? 5,
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
    this.livesNextRefillAtMs,
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

  /// Epoch ms when the next passive heart arrives, after this step.
  final int? livesNextRefillAtMs;

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
      livesNextRefillAtMs: (json['livesNextRefillAtMs'] as num?)?.toInt(),
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
    this.lessonXpAwarded,
    required this.mastery,
    required this.streak,
    required this.acceptedAccuracy,
    required this.liveTrainingGranted,
    required this.duplicate,
    this.resume,
    this.gemsAwarded = 0,
    this.gems = 0,
    this.heartsRestored = 0,
    this.livesRemaining,
    this.livesMax,
    this.livesNextRefillAtMs,
  });

  final String attemptId;
  final String lessonId;
  final int xpAwarded;

  /// Step XP plus the completion bonus, when the server recorded both.
  ///
  /// Null on completions from a function that only returns the bonus in
  /// [xpAwarded].
  final int? lessonXpAwarded;
  final double mastery;
  final int streak;
  final double acceptedAccuracy;
  final bool liveTrainingGranted;
  final bool duplicate;
  final CourseResumePointer? resume;

  /// Gems granted for completing today's daily quest (0 when already claimed).
  final int gemsAwarded;

  /// Wallet balance after this completion.
  final int gems;

  /// Hearts restored by completing a practice/replay lesson.
  final int heartsRestored;

  /// Profile hearts after completion when the server returned them.
  final int? livesRemaining;
  final int? livesMax;
  final int? livesNextRefillAtMs;

  factory CompleteCourseLessonResult.fromJson(Map<String, dynamic> json) {
    final resumeRaw = json['resume'];
    return CompleteCourseLessonResult(
      attemptId: json['attemptId'] as String,
      lessonId: json['lessonId'] as String,
      xpAwarded: (json['xpAwarded'] as num?)?.toInt() ?? 0,
      lessonXpAwarded: (json['lessonXpAwarded'] as num?)?.toInt(),
      mastery: (json['mastery'] as num?)?.toDouble() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      acceptedAccuracy: (json['acceptedAccuracy'] as num?)?.toDouble() ?? 0,
      liveTrainingGranted: json['liveTrainingGranted'] as bool? ?? false,
      duplicate: json['duplicate'] as bool? ?? false,
      resume: resumeRaw is Map
          ? CourseResumePointer.fromJson(Map<String, dynamic>.from(resumeRaw))
          : null,
      gemsAwarded: (json['gemsAwarded'] as num?)?.toInt() ?? 0,
      gems: (json['gems'] as num?)?.toInt() ?? 0,
      heartsRestored: (json['heartsRestored'] as num?)?.toInt() ?? 0,
      livesRemaining: (json['livesRemaining'] as num?)?.toInt(),
      livesMax: (json['livesMax'] as num?)?.toInt(),
      livesNextRefillAtMs: (json['livesNextRefillAtMs'] as num?)?.toInt(),
    );
  }
}

/// Heart refill callable result.
class RefillCourseHeartsResult {
  /// Creates a refill result.
  const RefillCourseHeartsResult({
    required this.method,
    required this.livesRemaining,
    required this.livesMax,
    required this.heartsRestored,
    required this.gems,
    required this.gemsSpent,
    required this.duplicate,
    this.livesNextRefillAtMs,
    this.nextAdClaimAtMs,
    this.adClaimsRemainingToday = 0,
  });

  final String method;
  final int livesRemaining;
  final int livesMax;
  final int heartsRestored;
  final int gems;
  final int gemsSpent;
  final bool duplicate;
  final int? livesNextRefillAtMs;
  final int? nextAdClaimAtMs;
  final int adClaimsRemainingToday;

  /// Parses refillCourseHearts JSON.
  factory RefillCourseHeartsResult.fromJson(Map<String, dynamic> json) {
    return RefillCourseHeartsResult(
      method: json['method']?.toString() ?? '',
      livesRemaining: (json['livesRemaining'] as num?)?.toInt() ?? 0,
      livesMax: (json['livesMax'] as num?)?.toInt() ?? 5,
      heartsRestored: (json['heartsRestored'] as num?)?.toInt() ?? 0,
      gems: (json['gems'] as num?)?.toInt() ?? 0,
      gemsSpent: (json['gemsSpent'] as num?)?.toInt() ?? 0,
      duplicate: json['duplicate'] as bool? ?? false,
      livesNextRefillAtMs: (json['livesNextRefillAtMs'] as num?)?.toInt(),
      nextAdClaimAtMs: (json['nextAdClaimAtMs'] as num?)?.toInt(),
      adClaimsRemainingToday:
          (json['adClaimsRemainingToday'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Matches `XP_PER_ACCEPTED_STEP` in `functions/src/course_session.ts`.
const kXpPerAcceptedStep = 10;

/// Matches `XP_LESSON_COMPLETE` in `functions/src/course_session.ts`.
const kXpLessonComplete = 25;

/// Perfect-run XP preview for a lesson with [activityCount] steps.
///
/// Mirrors server `lessonXpTotal(activityCount * XP_PER_ACCEPTED_STEP)`:
/// every accepted step plus the one-time completion bonus.
int previewLessonXp(int activityCount) {
  final steps = activityCount > 0 ? activityCount : 0;
  return steps * kXpPerAcceptedStep + kXpLessonComplete;
}

/// XP shown on the Home path REVIEW CTA (25% of a perfect-run preview).
///
/// Matches server `reviewLessonXp`: the end-of-lesson total for a replay is
/// 25% of what that run actually earned; this preview is 25% of a perfect run.
int reviewLessonXp(int previewXp) {
  if (previewXp <= 0) return 0;
  return (previewXp * 0.25).round();
}

/// XP to show for a finished lesson.
///
/// [completionBonus] is the completion grant in
/// [CompleteCourseLessonResult.xpAwarded] (first run: completion bonus only;
/// review: the full review-scaled total). [stepXpAwarded] is the sum of
/// accepted-step grants in this session (0 on reviews — steps defer to
/// completion). [lessonXpFromServer] is the attempt total when stored,
/// including steps from before a resume. The larger figure is what Nice work
/// and Home share for a guest with no earlier course XP.
int displayedLessonXp({
  required int stepXpAwarded,
  required int completionBonus,
  int? lessonXpFromServer,
}) {
  final local = stepXpAwarded + completionBonus;
  final server = lessonXpFromServer;
  if (server == null || server < local) return local;
  return server;
}
