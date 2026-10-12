// LPT-82: Suits and ranks scaffolded steps author teachSpec.pressHints (one per
// press), and Hint speaks the authored line instead of the a11y fallback.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';

const _hints = <String, List<String>>{
  'act-01-01-02-scaffolded-ranks': [
    'Start with the lowest rank.',
    'Next comes the middle rank.',
    'The highest rank goes last.',
  ],
  'act-01-01-02-unguided-suited': [
    'Look for the two hole cards that share a suit.',
  ],
};

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final MapEntry(key: id, value: texts) in _hints.entries) {
    test('$id authors one pressHint per press (LPT-82)', () {
      final a = catalog.activityById(id);
      expect(a, isNotNull, reason: id);
      expect(a!.assessmentRole, isNull);
      final hints = [
        for (final e in a.teachSpec!['pressHints'] as List<dynamic>)
          Map<String, dynamic>.from(e as Map),
      ];
      expect(
        [for (final h in hints) h['press']],
        [for (var i = 1; i <= texts.length; i++) i],
      );
      expect([for (final h in hints) h['text']], texts);
      final cues = a.teachSpec!['cues'] as List<dynamic>?;
      if (cues != null && cues.isNotEmpty) {
        expect(hints.length, cues.length);
      }
      expect(lessonFrameHintFallback(a), texts.first);
    });
  }
}
