/// Riverpod access to `appConfig/courseFlags`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/services/firestore/course_flags_repository.dart';

/// Shared course-flags repository.
final courseFlagsRepositoryProvider = Provider<CourseFlagsRepository>(
  (ref) => CourseFlagsRepository(),
);

/// One-shot course flags. Missing/failed reads yield disabled flags.
final courseFlagsProvider = FutureProvider<CourseFlags>((ref) async {
  return ref.watch(courseFlagsRepositoryProvider).load();
});
