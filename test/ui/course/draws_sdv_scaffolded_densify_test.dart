// LPT-847: SoftPulse-quiet densify stem must not spoil Strong draw / nut
// flush draw while SoftPulse stays off until Hint (SoftPulse LPT-653;
// same class as LPT-846 / LPT-845 / LPT-844).
// Remap honesty: board/hole tokens rewrite via alignLessonTableCopy
// (LPT-851 / LPT-806 class).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-03-02-01-scaffolded';
const _line =
    'Board Jh 8h 3c. You hold Ah 9h. Class — tap the matching label.';

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  test('$_id SoftPulse-quiet densify stem is non-spoiling', () {
    expect(selectIdentifyDensifiedCoachLine(_id), _line);
    final activity = catalog.activityById(_id);
    expect(activity, isNotNull, reason: _id);
    final speech = lessonFrameSpeech(activity!);
    expect(speech, isNot(contains('Tap the best answer')));
    expect(speech, isNot(contains('Strong draw')));
    expect(speech, isNot(contains('nut flush draw')));
    expect(speech, isNot(contains('pick Strong')));
    expect(speech, isNot(contains('pick ')));
    expect(speech.toLowerCase(), contains('board'));
    expect(speech.toLowerCase(), contains('you hold'));
    expect(speech, contains('tap the matching label'));
  });
}
