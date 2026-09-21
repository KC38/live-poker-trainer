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
  bool get canStartCourse => courseEnabled && courseStartsEnabled;

  /// Whether anonymous users may initialize/start course attempts.
  bool get canStartAsGuest => canStartCourse && guestCourseEnabled;

  /// Fail closed when this client is older than [minimumClientVersion].
  ///
  /// `courseEnabled` is the kill switch: turning it off hides course entry
  /// and guest onboarding without changing Live Training or Profile.
  CourseFlags gatedForClient(String clientVersion) {
    if (clientMeetsMinimum(clientVersion)) return this;
    return CourseFlags(
      courseEnabled: false,
      courseStartsEnabled: false,
      guestCourseEnabled: false,
      placementTestsEnabled: false,
      catalogVersion: catalogVersion,
      minimumClientVersion: minimumClientVersion,
    );
  }

  /// True when [clientVersion] is greater than or equal to the minimum.
  bool clientMeetsMinimum(String clientVersion) =>
      _compareVersions(clientVersion, minimumClientVersion) >= 0;

  /// Combines fetch outcome, parse, and minimum-client gating.
  ///
  /// Fetch failure, malformed documents, and too-old clients all disable
  /// the course. Live Training is unaffected.
  static CourseFlags resolve({
    required bool fetched,
    Map<String, dynamic>? data,
    required String clientVersion,
  }) {
    if (!fetched) return CourseFlags.disabled();
    return CourseFlags.fromMap(data).gatedForClient(clientVersion);
  }

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

int _compareVersions(String left, String right) {
  List<int> parse(String value) {
    final parts = value.split('.');
    return List<int>.generate(3, (index) {
      if (index >= parts.length) return 0;
      return int.tryParse(parts[index]) ?? 0;
    });
  }

  final a = parse(left);
  final b = parse(right);
  for (var index = 0; index < 3; index++) {
    if (a[index] != b[index]) return a[index] - b[index];
  }
  return 0;
}
