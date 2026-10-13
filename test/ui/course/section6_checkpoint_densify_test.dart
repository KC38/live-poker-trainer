// LPT-655: Section 6 checkpoint densified asks reach the frame bubble
// through selectIdentifyDensifiedCoachLine, never catalog quiz copy plus the
// generic "Tap the best answer." footer.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _lines = <String, String>{
  'act-06-13-02-cp-adv':
      'PFR on dry A-high — pick what they often have.',
  'act-06-13-02-cp-cap':
      'Check-back turn — pick how river range shifts.',
  'act-06-13-02-cp-polar':
      'River overbet shape — pick the range story.',
  'act-06-13-02-cp-tag':
      'Tight entry, planned barrels — pick the label.',
  'act-06-13-02-cp-lag':
      'Wide entry, sustained pressure — pick the label.',
};

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final MapEntry(key: id, value: line) in _lines.entries) {
    test('$id frame speech is the densified ask (LPT-655)', () {
      expect(selectIdentifyDensifiedCoachLine(id), line);
      final activity = catalog.activityById(id);
      expect(activity, isNotNull, reason: id);
      final speech = lessonFrameSpeech(activity!);
      expect(speech, isNot(contains('Tap the best answer')));
      expect(speech, contains(line.split(' — ').first));
    });
  }
}
