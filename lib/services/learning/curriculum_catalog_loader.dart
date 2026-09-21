/// Loads the bundled curriculum catalog asset.
library;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:live_poker_trainer/models/curriculum/curriculum_models.dart';

/// Asset path for the versioned curriculum catalog.
const String curriculumCatalogAssetPath = 'assets/curriculum/catalog.json';

/// Loads and parses [curriculumCatalogAssetPath].
class CurriculumCatalogLoader {
  /// Creates a loader; [assetBundle] is injectable for tests.
  CurriculumCatalogLoader({AssetBundle? assetBundle})
      : _bundle = assetBundle ?? rootBundle;

  final AssetBundle _bundle;

  CurriculumCatalog? _cached;

  /// Returns the catalog, caching after the first successful load.
  Future<CurriculumCatalog> load({bool forceReload = false}) async {
    if (!forceReload && _cached != null) return _cached!;
    final raw = await _bundle.loadString(curriculumCatalogAssetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Curriculum catalog root must be an object');
    }
    final catalog = CurriculumCatalog.fromJson(decoded);
    _assertFoundationInvariants(catalog);
    _cached = catalog;
    return catalog;
  }

  /// Clears the in-memory cache (tests).
  void clearCache() => _cached = null;
}

void _assertFoundationInvariants(CurriculumCatalog catalog) {
  if (catalog.sections.length != 13) {
    throw StateError(
      'Expected 13 sections, found ${catalog.sections.length}',
    );
  }
  if (catalog.unitCount != 61) {
    throw StateError('Expected 61 units, found ${catalog.unitCount}');
  }
  if (catalog.lessonCount != 183) {
    throw StateError('Expected 183 lessons, found ${catalog.lessonCount}');
  }
  for (final section in catalog.sections) {
    for (final unit in section.units) {
      if (unit.lessons.length != 3) {
        throw StateError(
          'Unit ${unit.id} must have 3 lessons, found ${unit.lessons.length}',
        );
      }
    }
  }
}
