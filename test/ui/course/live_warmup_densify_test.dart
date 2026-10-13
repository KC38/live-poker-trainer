// LPT-663: Prep a coached Live warm-up hand densified asks reach the frame
// bubble through selectIdentifyDensifiedCoachLine, never catalog quiz copy
// plus the generic "Tap the best answer." footer.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _lines = <String, String>{
  'act-07-11-01-guided': 'Warm-up checklist — pick what belongs.',
  'act-07-11-01-scaffolded': 'Carry into Live — pick what travels.',
  'act-07-11-01-unguided': 'Scope reminder — pick the product lane.',
  'act-07-11-01-checkpoint': 'Warm-up goal — pick the finish line.',
};

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final MapEntry(key: id, value: line) in _lines.entries) {
    test('$id frame speech is the densified ask (LPT-663)', () {
      expect(selectIdentifyDensifiedCoachLine(id), line);
      final activity = catalog.activityById(id);
      expect(activity, isNotNull, reason: id);
      final speech = lessonFrameSpeech(activity!);
      expect(speech, isNot(contains('Tap the best answer')));
      expect(speech, contains(line.split(' — ').first));
    });
  }
}
