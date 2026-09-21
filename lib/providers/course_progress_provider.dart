/// Riverpod access to course progress, isolated from Live Training stats.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/course/course_progress.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/services/firestore/course_progress_repository.dart';

/// Shared course-progress repository.
final courseProgressRepositoryProvider = Provider<CourseProgressRepository>(
  (ref) => CourseProgressRepository(service: ref.watch(courseServiceProvider)),
);

/// Course XP, streak, accuracy, section, mastery, and reviews due.
final courseProgressProvider = FutureProvider<CourseProgress>((ref) async {
  final catalog = await ref.watch(courseCatalogProvider.future);
  return ref.watch(courseProgressRepositoryProvider).load(catalog);
});
