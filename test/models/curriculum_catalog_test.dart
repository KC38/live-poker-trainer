/// Curriculum catalog parsing and foundation invariant tests.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/curriculum/curriculum_models.dart';
import 'package:live_poker_trainer/models/curriculum/learning_feature_flags.dart';
import 'package:live_poker_trainer/services/learning/curriculum_catalog_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LearningFeatureFlags', () {
    test('defaults are all false', () {
      const flags = LearningFeatureFlags.defaults;
      expect(flags.learningPlatformEnabled, isFalse);
      expect(flags.guestBootstrapEnabled, isFalse);
      expect(flags.curriculumPathEnabled, isFalse);
      expect(flags.adaptivePracticeEnabled, isFalse);
      expect(flags.mediaNarrationEnabled, isFalse);
    });

    test('parses true flags and ignores unknown keys', () {
      final flags = LearningFeatureFlags.fromJson({
        'learningPlatformEnabled': true,
        'guestBootstrapEnabled': 'yes',
        'unknown': true,
      });
      expect(flags.learningPlatformEnabled, isTrue);
      expect(flags.guestBootstrapEnabled, isFalse);
    });
  });

  group('CurriculumCatalog', () {
    test('loads bundled catalog with foundation counts', () async {
      final catalog = await CurriculumCatalogLoader().load();
      expect(catalog.catalogVersion, '1.0.0');
      expect(catalog.minClientVersion, '2.1.0');
      expect(catalog.sections, hasLength(13));
      expect(catalog.unitCount, 61);
      expect(catalog.lessonCount, 183);
      expect(catalog.milestoneGates, isNotEmpty);
      expect(catalog.objectives, isNotEmpty);

      for (final section in catalog.sections) {
        for (final unit in section.units) {
          expect(unit.lessons, hasLength(3));
        }
      }

      final first = catalog.lessonById(
        catalog.sections.first.units.first.lessons.first.id,
      );
      expect(first, isNotNull);
      expect(first!.format, LessonFormat.concept);
    });

    test('marks local-variant simulation claims as conceptual when present',
        () async {
      final catalog = await CurriculumCatalogLoader().load();
      final conceptual = <CurriculumLesson>[];
      for (final section in catalog.sections) {
        for (final unit in section.units) {
          for (final lesson in unit.lessons) {
            if (lesson.simulationClaims == SimulationClaim.conceptualOnly) {
              conceptual.add(lesson);
            }
          }
        }
      }
      expect(conceptual, isNotEmpty);
      expect(
        conceptual.any(
          (lesson) =>
              lesson.id.contains('straddle') ||
              lesson.id.contains('bomb') ||
              lesson.id.contains('run-it') ||
              lesson.title.toLowerCase().contains('straddle') ||
              lesson.title.toLowerCase().contains('bomb') ||
              lesson.title.toLowerCase().contains('run-it'),
        ),
        isTrue,
      );
    });

    test('rejects malformed root objects', () async {
      final bundle = _FakeBundle(jsonEncode(['not-an-object']));
      final loader = CurriculumCatalogLoader(assetBundle: bundle);
      await expectLater(loader.load(), throwsA(isA<FormatException>()));
    });
  });
}

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.payload);

  final String payload;

  @override
  Future<ByteData> load(String key) async {
    final bytes = utf8.encode(payload);
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}
