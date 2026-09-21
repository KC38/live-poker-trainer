/// Riverpod access to `appConfig/courseFlags`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/services/firestore/course_flags_repository.dart';

/// Shared course-flags repository.
final courseFlagsRepositoryProvider = Provider<CourseFlagsRepository>(
  (ref) => CourseFlagsRepository(),
);

/// Course flags for the current auth identity.
///
/// Reloads when the uid changes so a signed-out fail-closed read is not kept
/// after anonymous sign-in. Malformed documents, failed fetches, and too-old
/// clients still resolve to disabled flags.
final courseFlagsProvider = FutureProvider<CourseFlags>((ref) async {
  ref.watch(authUidProvider);
  return ref.watch(courseFlagsRepositoryProvider).load();
});
