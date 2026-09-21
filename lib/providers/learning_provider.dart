/// Riverpod providers for curriculum catalog and learning callables.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/curriculum/curriculum_models.dart';
import 'package:live_poker_trainer/models/curriculum/learning_snapshot.dart';
import 'package:live_poker_trainer/services/learning/curriculum_catalog_loader.dart';
import 'package:live_poker_trainer/services/learning/learning_service.dart';

/// Shared catalog loader (cached in-memory after first load).
final curriculumCatalogLoaderProvider = Provider<CurriculumCatalogLoader>(
  (ref) => CurriculumCatalogLoader(),
);

/// Bundled curriculum catalog future.
final curriculumCatalogProvider = FutureProvider<CurriculumCatalog>((ref) {
  return ref.watch(curriculumCatalogLoaderProvider).load();
});

/// Learning HTTPS callable facade.
final learningServiceProvider = Provider<LearningService>(
  (ref) => LearningService(),
);

/// Server learning progress. Falls back to empty if the callable fails.
final learningStateProvider = FutureProvider<LearningSnapshot>((ref) async {
  try {
    final raw = await ref.watch(learningServiceProvider).getLearningState();
    return LearningSnapshot.fromJson(raw);
  } catch (_) {
    return LearningSnapshot.empty;
  }
});
