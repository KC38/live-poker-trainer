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
    required this.gems,
    required this.currentStreak,
    required this.acceptedAccuracy,
    required this.mastery,
    required this.reviewsDue,
    this.currentSectionId,
    this.currentSectionOrder,
    this.currentSectionTitle,
    this.currentUnitOrder,
    this.currentUnitTitle,
    this.legacyLifetimeXp,
  });

  /// Course entry is off or the read failed. Live Training stays usable.
  const CourseProgress.unavailable()
    : loaded = false,
      available = false,
      lifetimeXp = 0,
      gems = 0,
      currentStreak = 0,
      acceptedAccuracy = 0,
      mastery = 0,
      reviewsDue = 0,
      currentSectionId = null,
      currentSectionOrder = null,
      currentSectionTitle = null,
      currentUnitOrder = null,
      currentUnitTitle = null,
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
    final unit = lessonId == null ? null : catalog.unitForLesson(lessonId);
    final reviewsRaw = state['reviewsDue'];
    final legacy = profile['legacyLifetimeXp'];
    final legacyLabel = profile['legacyXpLabel'];
    return CourseProgress(
      loaded: true,
      available: state['available'] == true,
      lifetimeXp: (profile['lifetimeXp'] as num?)?.toInt() ?? 0,
      gems: (profile['gems'] as num?)?.toInt() ?? 0,
      currentStreak: (profile['currentStreak'] as num?)?.toInt() ?? 0,
      acceptedAccuracy: (profile['acceptedAccuracy'] as num?)?.toDouble() ?? 0,
      mastery: mastery,
      reviewsDue: reviewsRaw is List ? reviewsRaw.length : 0,
      currentSectionId: section?.id,
      currentSectionOrder: section?.order,
      currentSectionTitle: section?.title,
      currentUnitOrder: unit?.order,
      currentUnitTitle: unit?.title,
      legacyLifetimeXp:
          legacyLabel == 'legacy_academy' && legacy is num
              ? legacy.toInt()
              : null,
    );
  }

  final bool loaded;
  final bool available;
  final int lifetimeXp;
  final int gems;
  final int currentStreak;
  final double acceptedAccuracy;
  final double mastery;
  final int reviewsDue;
  final String? currentSectionId;

  /// Catalog section order (1-based), when a current lesson resolves.
  final int? currentSectionOrder;

  /// Experience-band section title from the catalog. Prefer [coursePlaceEyebrow]
  /// and [coursePlaceTitle] for UI.
  final String? currentSectionTitle;

  /// Catalog unit order within the section, when a current lesson resolves.
  final int? currentUnitOrder;

  /// Current unit title from the catalog (Home banner body).
  final String? currentUnitTitle;

  /// Academy XP kept only as labeled metadata. Not added to [lifetimeXp].
  final int? legacyLifetimeXp;

  /// Home-style place eyebrow: `SECTION N, UNIT M`.
  String? get coursePlaceEyebrow {
    final sectionOrder = currentSectionOrder;
    final unitOrder = currentUnitOrder;
    if (sectionOrder == null || unitOrder == null) return null;
    return 'SECTION $sectionOrder, UNIT $unitOrder';
  }

  /// Unit title under [coursePlaceEyebrow], matching the Home unit banner.
  String? get coursePlaceTitle => currentUnitTitle;

  static String? _string(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return value;
  }

  static String? _resumeLessonId(Object? resume) {
    if (resume is! Map) return null;
    return _string(resume['lessonId']);
  }
}
