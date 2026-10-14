// LPT-809 / LPT-810 / LPT-811: SoftPulse-off densify stems must not spoil
// the correct tile (Attack / Bundle / Low conf) while assessments keep
// teachSpec.cues.kind: none (SoftPulse LPT-653).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _lines = <String, String>{
  // LPT-809
  'act-06-03-01-checkpoint': 'Caps are for — tap the matching plan.',
  // LPT-810
  'act-04-06-01-checkpoint':
      'Before you label — tap what evidence to gather.',
  // LPT-811
  'act-04-06-02-checkpoint':
      'Only two hands so far — tap how confident you are.',
};

const _forbidden = <String, String>{
  'act-06-03-01-checkpoint': 'Attack',
  'act-04-06-01-checkpoint': 'Bundle',
  'act-04-06-02-checkpoint': 'Low conf',
};

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final MapEntry(key: id, value: line) in _lines.entries) {
    test('$id SoftPulse-off densify stem is non-spoiling', () {
      expect(selectIdentifyDensifiedCoachLine(id), line);
      final activity = catalog.activityById(id);
      expect(activity, isNotNull, reason: id);
      final speech = lessonFrameSpeech(activity!);
      expect(speech, isNot(contains('Tap the best answer')));
      expect(speech, contains(line.split(' — ').first));
      expect(speech, isNot(contains(_forbidden[id]!)));
    });
  }
}
