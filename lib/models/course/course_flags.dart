/// Course feature-flag document from `appConfig/courseFlags`.
library;

/// Server-controlled course rollout flags (client read-only).
class CourseFlags {
  /// Creates parsed flags.
  const CourseFlags({
    required this.courseEnabled,
    required this.courseStartsEnabled,
    required this.guestCourseEnabled,
    required this.placementTestsEnabled,
    required this.catalogVersion,
    required this.minimumClientVersion,
  });

  /// Fail-closed defaults when the flag document is missing or unreadable.
  factory CourseFlags.disabled({
    String catalogVersion = '2.0.0',
    String minimumClientVersion = '2.0.0',
  }) {
    return CourseFlags(
      courseEnabled: false,
      courseStartsEnabled: false,
      guestCourseEnabled: false,
      placementTestsEnabled: false,
      catalogVersion: catalogVersion,
      minimumClientVersion: minimumClientVersion,
    );
  }

  /// Parses Firestore map; invalid/missing fields fail closed.
  factory CourseFlags.fromMap(Map<String, dynamic>? data) {
    if (data == null) return CourseFlags.disabled();
    final catalogVersion = data['catalogVersion'];
    final minimumClientVersion = data['minimumClientVersion'];
    if (catalogVersion is! String ||
        catalogVersion.isEmpty ||
        minimumClientVersion is! String ||
        minimumClientVersion.isEmpty) {
      return CourseFlags.disabled();
    }
    return CourseFlags(
      courseEnabled: data['courseEnabled'] == true,
      courseStartsEnabled: data['courseStartsEnabled'] == true,
      guestCourseEnabled: data['guestCourseEnabled'] == true,
      placementTestsEnabled: data['placementTestsEnabled'] == true,
      catalogVersion: catalogVersion,
      minimumClientVersion: minimumClientVersion,
    );
  }

  final bool courseEnabled;
  final bool courseStartsEnabled;
  final bool guestCourseEnabled;
  final bool placementTestsEnabled;
  final String catalogVersion;
  final String minimumClientVersion;

  /// Whether the client may start new course attempts.
  bool get canStartCourse =>
      courseEnabled && courseStartsEnabled;

  /// Whether anonymous users may initialize/start course attempts.
  bool get canStartAsGuest =>
      canStartCourse && guestCourseEnabled;

  @override
  bool operator ==(Object other) {
    return other is CourseFlags &&
        other.courseEnabled == courseEnabled &&
        other.courseStartsEnabled == courseStartsEnabled &&
        other.guestCourseEnabled == guestCourseEnabled &&
        other.placementTestsEnabled == placementTestsEnabled &&
        other.catalogVersion == catalogVersion &&
        other.minimumClientVersion == minimumClientVersion;
  }

  @override
  int get hashCode => Object.hash(
        courseEnabled,
        courseStartsEnabled,
        guestCourseEnabled,
        placementTestsEnabled,
        catalogVersion,
        minimumClientVersion,
      );
}
