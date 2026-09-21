/// Client-side learning feature flags.
///
/// Defaults are all false so production auth → Home behavior is unchanged
/// until server flags are enabled.
library;

/// Independent rollout switches for the learning platform.
class LearningFeatureFlags {
  /// Creates feature flags.
  const LearningFeatureFlags({
    this.learningPlatformEnabled = false,
    this.guestBootstrapEnabled = false,
    this.curriculumPathEnabled = false,
    this.adaptivePracticeEnabled = false,
    this.mediaNarrationEnabled = false,
  });

  /// Master switch for Learn/Practice shell routing.
  final bool learningPlatformEnabled;

  /// Anonymous auth + deferred registration.
  final bool guestBootstrapEnabled;

  /// Guided curriculum path UI.
  final bool curriculumPathEnabled;

  /// Objective-aware review and remediation.
  final bool adaptivePracticeEnabled;

  /// Optional lesson narration playback.
  final bool mediaNarrationEnabled;

  /// Safe defaults — production unchanged.
  static const LearningFeatureFlags defaults = LearningFeatureFlags();

  /// Parses a Firestore/remote map; unknown keys ignored.
  factory LearningFeatureFlags.fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaults;
    bool flag(String key) => json[key] == true;
    return LearningFeatureFlags(
      learningPlatformEnabled: flag('learningPlatformEnabled'),
      guestBootstrapEnabled: flag('guestBootstrapEnabled'),
      curriculumPathEnabled: flag('curriculumPathEnabled'),
      adaptivePracticeEnabled: flag('adaptivePracticeEnabled'),
      mediaNarrationEnabled: flag('mediaNarrationEnabled'),
    );
  }

  /// Wire format for tests and debugging.
  Map<String, bool> toJson() => {
        'learningPlatformEnabled': learningPlatformEnabled,
        'guestBootstrapEnabled': guestBootstrapEnabled,
        'curriculumPathEnabled': curriculumPathEnabled,
        'adaptivePracticeEnabled': adaptivePracticeEnabled,
        'mediaNarrationEnabled': mediaNarrationEnabled,
      };
}
