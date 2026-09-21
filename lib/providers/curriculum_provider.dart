/// Providers for the bundled curriculum catalog.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/curriculum/curriculum_models.dart';
import 'package:live_poker_trainer/services/learning/curriculum_catalog_loader.dart';

/// Shared catalog loader instance.
final curriculumCatalogLoaderProvider = Provider<CurriculumCatalogLoader>(
  (ref) => CurriculumCatalogLoader(),
);

/// Async curriculum catalog from the bundled asset.
final curriculumCatalogProvider = FutureProvider<CurriculumCatalog>((ref) {
  return ref.watch(curriculumCatalogLoaderProvider).load();
});
