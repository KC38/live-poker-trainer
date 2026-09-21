/// Loads course progress from `getCourseState`. Does not read Live stats.
library;

import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_progress.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';

/// Course progress reader. Failures become an unavailable snapshot.
class CourseProgressRepository {
  /// Creates a repository.
  CourseProgressRepository({required CourseService service})
    : _service = service;

  final CourseService _service;

  /// Loads course aggregates. Never throws into Profile.
  Future<CourseProgress> load(CourseCatalog catalog) async {
    try {
      final state = await _service.getCourseState(
        catalogVersion: catalog.catalogVersion,
      );
      return CourseProgress.fromState(state, catalog);
    } catch (_) {
      return const CourseProgress.unavailable();
    }
  }
}
