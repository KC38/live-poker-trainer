/// Live Training access tier from server entitlement / course checkpoints.
library;

/// Lesson that unlocks Rex warm-ups. Matches
/// `LIVE_WARMUP_UNLOCK_LESSON_ID` in Cloud Functions.
const kLiveWarmUpUnlockLessonId = 'lesson-02-07-02-section-two-jump';

/// Catalog path-node title for [kLiveWarmUpUnlockLessonId].
///
/// Locked-tab copy uses this Home path title so learners can match the node.
const kLiveWarmUpUnlockLessonTitle = 'Baseline jump check';

/// Lesson that unlocks unrestricted random Live Training.
const kLiveUnrestrictedUnlockLessonId =
    'lesson-04-10-02-section-four-jump-test';

/// Catalog path-node title for [kLiveUnrestrictedUnlockLessonId].
const kLiveUnrestrictedUnlockLessonTitle = 'Section 4 jump check';

/// Locked-tab sentence. Points at the Home lesson that unlocks warm-ups.
///
/// Signed-in learners only. Anonymous guests use
/// [liveTrainingAnonymousLockedMessage] (LPT-697).
String liveTrainingLockedMessage() {
  return 'Live Training is advanced. Finish $kLiveWarmUpUnlockLessonTitle on '
      'Home to unlock a coached warm-up.';
}

/// Locked-tab sentence for anonymous guests (LPT-697).
///
/// Matches the launch snackbar and `docs/agent-paths.md` → live-training-gate.
/// Do not point guests at Baseline jump check — they cannot open Live until
/// they create an account, even when that lesson is already complete.
String liveTrainingAnonymousLockedMessage() {
  return 'Create an account before Live Training.';
}

/// Snackbar when a locked learner tries to start a table.
String liveTrainingLockedSnack() {
  return 'Live Training unlocks after $kLiveWarmUpUnlockLessonTitle. '
      'Continue on Home.';
}

/// Warm-up hub body when Rex warm-ups are open but random Live is still gated.
String liveTrainingWarmUpHubMessage() {
  return 'Rex warm-ups are open. Random Live Training unlocks after '
      '$kLiveUnrestrictedUnlockLessonTitle.';
}

/// Snackbar when a warm-up learner tries unrestricted random Live.
String liveTrainingWarmUpUnrestrictedSnack() {
  return 'Unrestricted Live Training unlocks after '
      '$kLiveUnrestrictedUnlockLessonTitle. Warm-ups stay on Home.';
}

/// Access level for the Live Training tab and start callables.
enum LiveAccessTier {
  /// Before [kLiveWarmUpUnlockLessonId] — tab explains and links Home.
  locked,

  /// After Baseline jump check — Rex-guided warm-ups only.
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

  /// Anonymous guest — account required before any Live unlock path (LPT-697).
  factory LiveAccessSnapshot.anonymous() => const LiveAccessSnapshot(
        tier: LiveAccessTier.locked,
        source: 'anonymous',
        unrestrictedAccess: false,
        warmUpAvailable: false,
      );

  /// True when the hub must ask for an account instead of a Home lesson.
  bool get requiresAccount => source == 'anonymous';

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
