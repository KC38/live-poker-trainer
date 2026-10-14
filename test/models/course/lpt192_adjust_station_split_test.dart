import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';

/// LPT-192: Adjust versus Calling Station splits one lesson per concept
/// (adjust-nit pattern, LPT-202). Each step grades its lesson's objective.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CourseCatalog catalog;

  setUpAll(() async {
    catalog = CourseCatalog.fromJson(
      jsonDecode(await rootBundle.loadString('assets/course/v2/catalog.json'))
          as Map<String, dynamic>,
    );
  });

  const retired = 'lesson-04-06-03-adjust-calling-station';
  const value = 'lesson-04-06-03-01-value-wider';
  const bluff = 'lesson-04-06-03-02-bluff-less';
  const cite = 'lesson-04-06-03-03-cite-sticky-call';

  test('retired id maps to three live successors', () {
    expect(catalog.lessonById(retired), isNull);
    expect(catalog.lessonSplitMap[retired], [value, bluff, cite]);
  });

  test('unlock chain runs confidence → value → bluff → cite → Nit unit', () {
    expect(catalog.lessonById(value)!.prerequisites, [
      'lesson-04-06-02-03-station-confidence',
    ]);
    expect(catalog.lessonById(bluff)!.prerequisites, [value]);
    expect(catalog.lessonById(cite)!.prerequisites, [bluff]);
    expect(
      catalog.lessonById('lesson-04-07-01-01-narrow-entry')!.prerequisites,
      [cite],
    );
  });

  test('each lesson has one objective and its steps grade it', () {
    final expected = {
      value: (
        'Value wider versus Calling Station',
        ['act-04-06-03-explain', 'act-04-06-03-guided'],
      ),
      bluff: (
        'Bluff less without equity',
        [
          'act-04-06-03-02-explain-bluffs',
          'act-04-06-03-scaffolded',
          'act-04-06-03-checkpoint',
        ],
      ),
      cite: (
        'Cite the sticky-call tendency',
        ['act-04-06-03-03-explain-cite', 'act-04-06-03-unguided'],
      ),
    };
    for (final MapEntry(key: id, value: (objective, steps))
        in expected.entries) {
      final lesson = catalog.lessonById(id)!;
      expect(lesson.objectives, [objective], reason: id);
      final acts = catalog.activitiesForLesson(id);
      expect(acts.map((a) => a.id).toList(), steps, reason: id);
      for (final a in acts) {
        expect(a.objectives, [objective], reason: a.id);
      }
    }
  });
}
