/// Course progress shown on Profile. Distinct from Live Training stats.
library;

import 'package:live_poker_trainer/models/course/course_catalog.dart';

/// Server course aggregates. Never includes coaching spots or net result.
class CourseProgress {
  /// Creates course progress.
  const CourseProgress({
    required this.loaded,
    required this.available,
    required this.lifetimeXp,
    required this.currentStreak,
    required this.acceptedAccuracy,
    required this.mastery,
    required this.reviewsDue,
    this.currentSectionId,
    this.currentSectionTitle,
    this.legacyLifetimeXp,
  });

  /// Course entry is off or the read failed. Live Training stays usable.
  const CourseProgress.unavailable()
    : loaded = false,
      available = false,
      lifetimeXp = 0,
      currentStreak = 0,
      acceptedAccuracy = 0,
      mastery = 0,
      reviewsDue = 0,
      currentSectionId = null,
      currentSectionTitle = null,
      legacyLifetimeXp = null;

  /// Parsed from `getCourseState`. [catalog] resolves the current section.
  factory CourseProgress.fromState(
    Map<String, dynamic> state,
    CourseCatalog catalog,
  ) {
    final profileRaw = state['profile'];
    final profile =
        profileRaw is Map
            ? Map<String, dynamic>.from(profileRaw)
            : const <String, dynamic>{};
    final masteryRaw = profile['masteryByLessonId'];
    final masteryValues = <double>[];
    if (masteryRaw is Map) {
      for (final value in masteryRaw.values) {
        if (value is num) masteryValues.add(value.toDouble());
      }
    }
    final mastery =
        masteryValues.isEmpty
            ? 0.0
            : masteryValues.reduce((a, b) => a + b) / masteryValues.length;
    final lessonId =
        _string(profile['currentLessonId']) ??
        _resumeLessonId(profile['resume']) ??
        _string(profile['recommendedLessonId']);
    final section =
        lessonId == null ? null : catalog.sectionForLesson(lessonId);
    final reviewsRaw = state['reviewsDue'];
    final legacy = profile['legacyLifetimeXp'];
    final legacyLabel = profile['legacyXpLabel'];
    return CourseProgress(
      loaded: true,
      available: state['available'] == true,
      lifetimeXp: (profile['lifetimeXp'] as num?)?.toInt() ?? 0,
      currentStreak: (profile['currentStreak'] as num?)?.toInt() ?? 0,
      acceptedAccuracy: (profile['acceptedAccuracy'] as num?)?.toDouble() ?? 0,
      mastery: mastery,
      reviewsDue: reviewsRaw is List ? reviewsRaw.length : 0,
      currentSectionId: section?.id,
      currentSectionTitle: section?.title,
      legacyLifetimeXp:
          legacyLabel == 'legacy_academy' && legacy is num
              ? legacy.toInt()
              : null,
    );
  }

  final bool loaded;
  final bool available;
  final int lifetimeXp;
  final int currentStreak;
  final double acceptedAccuracy;
  final double mastery;
  final int reviewsDue;
  final String? currentSectionId;
  final String? currentSectionTitle;

  /// Academy XP kept only as labeled metadata. Not added to [lifetimeXp].
  final int? legacyLifetimeXp;

  static String? _string(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return value;
  }

  static String? _resumeLessonId(Object? resume) {
    if (resume is! Map) return null;
    return _string(resume['lessonId']);
  }
}
