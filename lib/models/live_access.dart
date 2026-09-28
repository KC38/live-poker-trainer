/// Live Training access tier from server entitlement / course checkpoints.
library;

/// Lesson that unlocks Rex warm-ups. Matches
/// `LIVE_WARMUP_UNLOCK_LESSON_ID` in Cloud Functions.
const kLiveWarmUpUnlockLessonId = 'lesson-02-07-02-section-two-jump';

/// Home title for [kLiveWarmUpUnlockLessonId] when the catalog is not loaded.
const kLiveWarmUpUnlockLessonTitle = 'Section 2 jump check';

/// Locked-tab sentence. [lessonTitle] is the Home lesson the learner must finish.
String liveTrainingLockedMessage({String? lessonTitle}) {
  final title = _unlockTitle(lessonTitle);
  return 'Live Training is advanced. Finish $title on Home '
      'to unlock a coached warm-up.';
}

/// Snackbar when a locked learner tries to start a table.
String liveTrainingLockedSnack({String? lessonTitle}) {
  final title = _unlockTitle(lessonTitle);
  return 'Live Training unlocks after $title. Continue on Home.';
}

String _unlockTitle(String? lessonTitle) {
  final trimmed = lessonTitle?.trim() ?? '';
  if (trimmed.isEmpty) return kLiveWarmUpUnlockLessonTitle;
  return trimmed;
}

/// Access level for the Live Training tab and start callables.
enum LiveAccessTier {
  /// Before Section 2 checkpoint — tab explains and links Home.
  locked,

  /// After Section 2 — Rex-guided warm-ups only.
  warmUp,

  /// After Section 4 jump / grandfather / admin — unrestricted Live.
  unrestricted,
}

/// Parsed Live access snapshot (getCourseState.liveAccess / getLiveAccess).
class LiveAccessSnapshot {
  /// Creates a snapshot.
  const LiveAccessSnapshot({
    required this.tier,
    required this.source,
    required this.unrestrictedAccess,
    required this.warmUpAvailable,
    this.nextLessonId,
    this.rolloutCutoffMs,
  });

  final LiveAccessTier tier;
  final String source;
  final bool unrestrictedAccess;
  final bool warmUpAvailable;
  final String? nextLessonId;
  final int? rolloutCutoffMs;

  /// Locked anonymous / missing payload.
  factory LiveAccessSnapshot.locked() => const LiveAccessSnapshot(
        tier: LiveAccessTier.locked,
        source: 'none',
        unrestrictedAccess: false,
        warmUpAvailable: false,
      );

  factory LiveAccessSnapshot.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LiveAccessSnapshot.locked();
    final tierRaw = json['tier']?.toString() ?? 'locked';
    final tier = switch (tierRaw) {
      'unrestricted' => LiveAccessTier.unrestricted,
      'warm_up' => LiveAccessTier.warmUp,
      _ => LiveAccessTier.locked,
    };
    return LiveAccessSnapshot(
      tier: tier,
      source: json['source']?.toString() ?? 'none',
      unrestrictedAccess: json['unrestrictedAccess'] == true,
      warmUpAvailable: json['warmUpAvailable'] == true ||
          tier == LiveAccessTier.warmUp ||
          tier == LiveAccessTier.unrestricted,
      nextLessonId: json['nextLessonId']?.toString(),
      rolloutCutoffMs: (json['rolloutCutoffMs'] as num?)?.toInt(),
    );
  }
}

/// Immutable course context attached to a Live table session.
class CourseLiveContext {
  /// Creates course live context.
  const CourseLiveContext({
    this.attemptId,
    this.activityId,
    this.lessonId,
    this.handLabSpecId,
    this.returnNodeId,
    required this.courseHandId,
    required this.kind,
    this.scaffolding = 'full',
    this.rexPrompt = '',
    this.maxDecisions = 1,
  });

  final String? attemptId;
  final String? activityId;
  final String? lessonId;
  final String? handLabSpecId;
  final String? returnNodeId;
  final String courseHandId;
  final String kind;
  final String scaffolding;
  final String rexPrompt;
  final int maxDecisions;

  factory CourseLiveContext.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CourseLiveContext(courseHandId: '', kind: 'warm_up');
    }
    return CourseLiveContext(
      attemptId: json['attemptId']?.toString(),
      activityId: json['activityId']?.toString(),
      lessonId: json['lessonId']?.toString(),
      handLabSpecId: json['handLabSpecId']?.toString(),
      returnNodeId: json['returnNodeId']?.toString(),
      courseHandId: json['courseHandId']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'warm_up',
      scaffolding: json['scaffolding']?.toString() ?? 'full',
      rexPrompt: json['rexPrompt']?.toString() ?? '',
      maxDecisions: (json['maxDecisions'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toStartTableSetup({
    required String courseKind,
  }) =>
      {
        'mode': 'course',
        'courseKind': courseKind,
        if (courseHandId.isNotEmpty) 'courseHandId': courseHandId,
        if (handLabSpecId != null) 'handLabSpecId': handLabSpecId,
        if (attemptId != null) 'attemptId': attemptId,
        if (activityId != null) 'activityId': activityId,
        if (lessonId != null) 'lessonId': lessonId,
        if (returnNodeId != null) 'returnNodeId': returnNodeId,
      };
}
