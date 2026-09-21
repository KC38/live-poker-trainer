/// Home course map state from getCourseState + bundled catalog.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';

/// Loads and derives the Home course map for the signed-in user.
final courseHomeProvider =
    AsyncNotifierProvider<CourseHomeController, CourseHomeSnapshot>(
  CourseHomeController.new,
);

/// Fetches server course state and builds a [CourseHomeSnapshot].
class CourseHomeController extends AsyncNotifier<CourseHomeSnapshot> {
  @override
  Future<CourseHomeSnapshot> build() async {
    final uid = ref.watch(authUidProvider);
    final catalog = await ref.watch(courseCatalogProvider.future);
    if (uid == null || uid.isEmpty) {
      return CourseHomeSnapshot(
        status: CourseHomeLoadStatus.error,
        nodes: const [],
        sections: catalog.sections,
        errorMessage: 'Sign in to load your course path.',
        rexLine: 'Sign in so I can load your path.',
      );
    }
    final service = ref.watch(courseServiceProvider);
    try {
      final raw = await service.getCourseState(
        catalogVersion: catalog.catalogVersion,
      );
      return snapshotFromCourseState(catalog: catalog, raw: raw);
    } on CourseServiceException catch (error) {
      final offline = error.code == 'unavailable' ||
          error.code == 'deadline-exceeded';
      return buildCourseHomeSnapshot(
        catalog: catalog,
        flags: CourseFlags.disabled(catalogVersion: catalog.catalogVersion),
        available: false,
        offline: offline,
        errorMessage: error.message,
      );
    }
  }

  /// Reloads course state from the server.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

/// Pure mapping from getCourseState JSON → Home snapshot (tests inject this).
CourseHomeSnapshot snapshotFromCourseState({
  required CourseCatalog catalog,
  required Map<String, dynamic> raw,
}) {
  final available = raw['available'] == true;
  final flagsRaw = raw['flags'];
  final flags = flagsRaw is Map
      ? CourseFlags.fromMap(Map<String, dynamic>.from(flagsRaw))
      : CourseFlags.disabled(catalogVersion: catalog.catalogVersion);

  CourseProfileView? profile;
  final profileRaw = raw['profile'];
  if (profileRaw is Map) {
    profile = CourseProfileView.fromJson(
      Map<String, dynamic>.from(profileRaw),
    );
  }

  CourseAttemptSnapshot? openAttempt;
  final openRaw = raw['openAttempt'];
  if (openRaw is Map) {
    openAttempt = CourseAttemptSnapshot.fromJson(
      Map<String, dynamic>.from(openRaw),
    );
  }

  final reviewIds = <String>[];
  final reviewsRaw = raw['reviewsDue'];
  if (reviewsRaw is List) {
    for (final item in reviewsRaw) {
      if (item is Map) {
        final lessonId = item['lessonId']?.toString();
        if (lessonId != null && lessonId.isNotEmpty) {
          reviewIds.add(lessonId);
        }
      }
    }
  }

  return buildCourseHomeSnapshot(
    catalog: catalog,
    flags: flags,
    available: available,
    profile: profile,
    openAttempt: openAttempt,
    reviewLessonIds: reviewIds,
  );
}
