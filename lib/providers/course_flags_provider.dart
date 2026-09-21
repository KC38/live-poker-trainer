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
///
/// While that reload is in flight, Riverpod reports [AsyncLoading] and
/// [AsyncValue.asData] is null even though the previous value is still held.
/// Root routing must use [courseFlagsForRouting], which keeps that previous
/// value until the new read completes.
final courseFlagsProvider = FutureProvider<CourseFlags>((ref) async {
  ref.watch(authUidProvider);
  return ref.watch(courseFlagsRepositoryProvider).load();
});

/// Flags and readiness for root routing.
class CourseFlagsGate {
  /// Creates a routing view of the flags provider.
  const CourseFlagsGate({required this.flags, required this.ready});

  /// Last successful flags, or null when none are available.
  final CourseFlags? flags;

  /// Whether routing may leave the loading gate.
  ///
  /// True when [flags] is a completed or still-reloading success, and when
  /// the latest read failed. False only while the first read is in flight.
  final bool ready;
}

/// Resolves [courseFlagsProvider] for root routing.
///
/// A uid-change reload keeps the previous successful flags so guests are not
/// treated as flags-ready with null flags. An actual provider error fails
/// closed (`ready` with null flags). Malformed, fetch-failed, and too-old
/// results arrive later as disabled [CourseFlags], not as this error path.
CourseFlagsGate courseFlagsForRouting(AsyncValue<CourseFlags> asyncFlags) {
  if (asyncFlags.hasError) {
    return const CourseFlagsGate(flags: null, ready: true);
  }
  final flags = asyncFlags.valueOrNull;
  return CourseFlagsGate(flags: flags, ready: flags != null);
}
