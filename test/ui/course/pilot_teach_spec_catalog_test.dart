// LPT-558: the Your two cards pilot keeps its full teachSpec in the catalog
// (the wave helper now authors the same contract; node test compares them).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';

void main() {
  test('pilot activities author teachSpec; checkpoint has no pressHints', () {
    final catalog = CourseCatalog.fromJson(
      jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    final lesson = catalog.lessonById('lesson-01-01-01-your-two-cards')!;
    expect(lesson.activities, hasLength(5));
    for (final a in lesson.activities) {
      expect(a.teachSpec, isNotNull, reason: a.id);
      expect(a.teachSpec!['deal'], isNotNull, reason: a.id);
    }
    final checkpoint = lesson.activities.last;
    expect(checkpoint.id, 'act-01-01-01-checkpoint-table');
    expect(checkpoint.teachSpec!.containsKey('pressHints'), isFalse);
  });
}
