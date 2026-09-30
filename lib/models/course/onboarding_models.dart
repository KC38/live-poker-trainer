/// Lesson-first onboarding choices and recommendation helpers.
library;

import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';

/// Experience bands matching course section `experienceBand` values.
enum ExperienceBand {
  /// Brand-new to poker.
  neverPlayed('never_played', 'New to poker'),

  /// Knows rules / home games.
  rulesKnown('rules_known', 'Know the rules / home games'),

  /// First casino sessions.
  firstCasino('first_casino', 'First casino sessions'),

  /// Regular live cash player.
  regularLive('regular_live', 'Regular live cash player');

  const ExperienceBand(this.wireValue, this.label);

  /// Catalog / Firestore wire value.
  final String wireValue;

  /// UI label.
  final String label;

  /// Parses a wire value; null when unknown.
  static ExperienceBand? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final band in ExperienceBand.values) {
      if (band.wireValue == value) return band;
    }
    return null;
  }
}

/// Daily study goal options (minutes).
const kDailyGoalChoices = <int>[5, 10, 15, 20];

/// Streak commitment options after the first lesson (days).
const kStreakGoalChoices = <int>[7, 14, 30, 50];

/// XP target for the first-day daily quest card.
const kDailyQuestXpTarget = 10;

/// Gems granted when the daily quest chest opens.
const kDailyQuestGemReward = 5;

/// Duolingo-style intensity label for a daily goal choice.
///
/// Returns an empty string for unknown minute values.
String dailyGoalIntensityLabel(int minutes) {
  return switch (minutes) {
    5 => 'Casual',
    10 => 'Regular',
    15 => 'Serious',
    20 => 'Intense',
    _ => '',
  };
}

/// Intensity label for a streak-goal choice.
///
/// Returns an empty string for unknown day values.
String streakGoalIntensityLabel(int days) {
  return switch (days) {
    7 => 'Good',
    14 => 'Great',
    30 => 'Incredible',
    50 => 'Unstoppable',
    _ => '',
  };
}

/// Recommendation computed from catalog + flags for an experience band.
class OnboardingRecommendation {
  /// Creates a recommendation.
  const OnboardingRecommendation({
    required this.experienceBand,
    required this.startLessonId,
    required this.jumpTestOffered,
    this.jumpTestLessonId,
    this.sectionTitle,
  });

  final ExperienceBand experienceBand;

  /// Lesson the learner actually starts (never a missing node).
  final String startLessonId;

  /// Whether UI should offer an optional jump-test entry.
  final bool jumpTestOffered;

  /// Published jump-test lesson id when offered.
  final String? jumpTestLessonId;

  /// Matching section title when present.
  final String? sectionTitle;
}

/// Resolves recommended start + optional jump test without linking to missing nodes.
OnboardingRecommendation resolveOnboardingRecommendation({
  required ExperienceBand band,
  required CourseCatalog catalog,
  required CourseFlags flags,
}) {
  CourseSection? section;
  for (final candidate in catalog.sections) {
    if (candidate.experienceBand == band.wireValue) {
      section = candidate;
      break;
    }
  }

  final jumpId = _publishedPlacementJumpLessonId(section);
  final offerJump = band == ExperienceBand.regularLive &&
      flags.placementTestsEnabled &&
      jumpId != null &&
      catalog.lessonById(jumpId) != null;

  return OnboardingRecommendation(
    experienceBand: band,
    // Until content waves publish band-specific entry lessons, everyone starts
    // at the production first lesson. Regular may optionally jump when published.
    startLessonId: offerJump ? jumpId! : kFirstCourseLessonId,
    jumpTestOffered: offerJump,
    jumpTestLessonId: offerJump ? jumpId : null,
    sectionTitle: section?.title,
  );
}

/// Placement jump nodes use an explicit id convention and live in-band.
/// Coverage/seed lessons are never treated as placement tests.
String? _publishedPlacementJumpLessonId(CourseSection? section) {
  if (section == null) return null;
  for (final unit in section.units) {
    for (final lesson in unit.lessons) {
      final id = lesson.id;
      if (id.contains('-seed') || id.contains('coverage')) continue;
      final looksLikePlacement = id.contains('placement') ||
          id.contains('jump-test') ||
          id.contains('jump_test');
      final hasJumpStage = lesson.activities.any(
        (activity) => activity.stage == ActivityStage.jumpTest,
      );
      if (looksLikePlacement && hasJumpStage) {
        return id;
      }
    }
  }
  return null;
}

/// Durable onboarding draft stored locally until linked.
class OnboardingDraft {
  /// Creates a draft.
  const OnboardingDraft({
    this.step = OnboardingStep.welcome,
    this.experienceBand,
    this.dailyGoalMinutes,
    this.streakGoalDays,
    this.recommendedLessonId,
    this.jumpTestOffered = false,
    this.firstLessonCompleted = false,
    this.pendingSaveProgress = false,
    this.lastLessonTitle,
    this.lastXpAwarded,
    this.lastMastery,
    this.lastStreak,
    this.lastGemsAwarded,
    this.gems = 0,
  });

  final OnboardingStep step;
  final ExperienceBand? experienceBand;
  final int? dailyGoalMinutes;

  /// Chosen streak commitment (7 / 14 / 30 / 50).
  final int? streakGoalDays;
  final String? recommendedLessonId;
  final bool jumpTestOffered;
  final bool firstLessonCompleted;
  final bool pendingSaveProgress;
  final String? lastLessonTitle;
  final int? lastXpAwarded;
  final double? lastMastery;
  final int? lastStreak;

  /// Gems granted for the daily-quest chest on this celebration pass.
  final int? lastGemsAwarded;

  /// Guest gem balance until the account is linked.
  final int gems;

  /// True while the post-first-lesson streak / quest / gem beat is showing.
  bool get isPostLessonCelebration => switch (step) {
        OnboardingStep.dayStreak ||
        OnboardingStep.streakGoal ||
        OnboardingStep.dailyQuests ||
        OnboardingStep.gemsReward =>
          true,
        _ => false,
      };

  OnboardingDraft copyWith({
    OnboardingStep? step,
    ExperienceBand? experienceBand,
    int? dailyGoalMinutes,
    int? streakGoalDays,
    String? recommendedLessonId,
    bool? jumpTestOffered,
    bool? firstLessonCompleted,
    bool? pendingSaveProgress,
    String? lastLessonTitle,
    int? lastXpAwarded,
    double? lastMastery,
    int? lastStreak,
    int? lastGemsAwarded,
    int? gems,
    bool clearLessonResult = false,
  }) {
    return OnboardingDraft(
      step: step ?? this.step,
      experienceBand: experienceBand ?? this.experienceBand,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      streakGoalDays: streakGoalDays ?? this.streakGoalDays,
      recommendedLessonId: recommendedLessonId ?? this.recommendedLessonId,
      jumpTestOffered: jumpTestOffered ?? this.jumpTestOffered,
      firstLessonCompleted: firstLessonCompleted ?? this.firstLessonCompleted,
      pendingSaveProgress: pendingSaveProgress ?? this.pendingSaveProgress,
      lastLessonTitle:
          clearLessonResult ? null : (lastLessonTitle ?? this.lastLessonTitle),
      lastXpAwarded:
          clearLessonResult ? null : (lastXpAwarded ?? this.lastXpAwarded),
      lastMastery: clearLessonResult ? null : (lastMastery ?? this.lastMastery),
      lastStreak: clearLessonResult ? null : (lastStreak ?? this.lastStreak),
      lastGemsAwarded: clearLessonResult
          ? null
          : (lastGemsAwarded ?? this.lastGemsAwarded),
      gems: gems ?? this.gems,
    );
  }

  Map<String, Object?> toPrefs() => {
        'step': step.name,
        'experienceBand': experienceBand?.wireValue,
        'dailyGoalMinutes': dailyGoalMinutes,
        'streakGoalDays': streakGoalDays,
        'recommendedLessonId': recommendedLessonId,
        'jumpTestOffered': jumpTestOffered,
        'firstLessonCompleted': firstLessonCompleted,
        'pendingSaveProgress': pendingSaveProgress,
        'lastLessonTitle': lastLessonTitle,
        'lastXpAwarded': lastXpAwarded,
        'lastMastery': lastMastery,
        'lastStreak': lastStreak,
        'lastGemsAwarded': lastGemsAwarded,
        'gems': gems,
      };

  factory OnboardingDraft.fromPrefs(Map<String, Object?> data) {
    final parsedStep = OnboardingStep.values.firstWhere(
      (value) => value.name == data['step'],
      orElse: () => OnboardingStep.welcome,
    );
    // Legacy Meet Rex drafts resume on Daily goal (coach intro moved earlier).
    // Legacy drafts that jumped straight to save progress keep that step.
    final step = parsedStep == OnboardingStep.rexIntro
        ? OnboardingStep.dailyGoal
        : parsedStep;
    return OnboardingDraft(
      step: step,
      experienceBand: ExperienceBand.tryParse(data['experienceBand'] as String?),
      dailyGoalMinutes: data['dailyGoalMinutes'] as int?,
      streakGoalDays: data['streakGoalDays'] as int?,
      recommendedLessonId: data['recommendedLessonId'] as String?,
      jumpTestOffered: data['jumpTestOffered'] == true,
      firstLessonCompleted: data['firstLessonCompleted'] == true,
      pendingSaveProgress: data['pendingSaveProgress'] == true,
      lastLessonTitle: data['lastLessonTitle'] as String?,
      lastXpAwarded: data['lastXpAwarded'] as int?,
      lastMastery: (data['lastMastery'] as num?)?.toDouble(),
      lastStreak: data['lastStreak'] as int?,
      lastGemsAwarded: data['lastGemsAwarded'] as int?,
      gems: (data['gems'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Ordered onboarding steps for root routing.
enum OnboardingStep {
  welcome,
  experience,
  dailyGoal,

  /// Legacy Meet Rex step. Hydration maps this to [dailyGoal].
  rexIntro,

  /// First Duolingo-style Rex motivation beat after daily goal.
  motivationHook,

  /// Second motivation beat; Continue starts the first lesson directly.
  motivationPitch,

  /// Jump-test offer / legacy "Your start" CTA.
  recommendedStart,
  firstLesson,

  /// Flame + weekday streak celebration after the first lesson.
  dayStreak,

  /// Choose a multi-day streak commitment.
  streakGoal,

  /// Daily quest complete card (chest leads to gems).
  dailyQuests,

  /// Gem reward reveal before create-profile.
  gemsReward,

  saveProgress,
  done,
}
