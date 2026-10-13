// LPT-656: Carry a preflop plan densified asks reach the frame bubble
// through selectIdentifyDensifiedCoachLine, never catalog quiz copy plus the
// generic "Tap the best answer." footer.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _lines = <String, String>{
  'act-07-01-01-guided': 'AQo 3-bet · 872tt — pick the plan update.',
  'act-07-01-01-scaffolded': 'BTN steal KTo · KT2r — pick the plan update.',
  'act-07-01-01-unguided': 'Best habit — pick what to do before flop act.',
  'act-07-01-01-checkpoint': 'Dead plan — pick the response.',
};

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final MapEntry(key: id, value: line) in _lines.entries) {
    test('$id frame speech is the densified ask (LPT-656)', () {
      expect(selectIdentifyDensifiedCoachLine(id), line);
      final activity = catalog.activityById(id);
      expect(activity, isNotNull, reason: id);
      final speech = lessonFrameSpeech(activity!);
      expect(speech, isNot(contains('Tap the best answer')));
      expect(speech, contains(line.split(' — ').first));
    });
  }
}
