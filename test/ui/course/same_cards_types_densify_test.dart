// LPT-664: Replay the same hand versus each type densified checkpoint reaches
// the frame bubble through selectIdentifyDensifiedCoachLine, never catalog
// quiz copy plus the generic "Tap the best answer." footer.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _lines = <String, String>{
  'act-07-07-01-checkpoint': 'No type evidence — pick the default.',
};

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final MapEntry(key: id, value: line) in _lines.entries) {
    test('$id frame speech is the densified ask (LPT-664)', () {
      expect(selectIdentifyDensifiedCoachLine(id), line);
      final activity = catalog.activityById(id);
      expect(activity, isNotNull, reason: id);
      final speech = lessonFrameSpeech(activity!);
      expect(speech, isNot(contains('Tap the best answer')));
      expect(speech, contains(line.split(' — ').first));
    });
  }
}
