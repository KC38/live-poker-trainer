// LPT-868: SoftPulse-off densify stem must not spoil Brick → barrel /
// flush → abort / brick→barrel while assessment cues stay kind: none
// (SoftPulse LPT-653; same class as LPT-867 / LPT-866 / LPT-812).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-04-03-01-checkpoint';
const _line = 'You have a flop plan — tap the matching street branch.';

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  test('$_id SoftPulse-off densify stem is non-spoiling', () {
    expect(selectIdentifyDensifiedCoachLine(_id), _line);
    final activity = catalog.activityById(_id);
    expect(activity, isNotNull, reason: _id);
    final speech = lessonFrameSpeech(activity!);
    expect(speech, _line);
    expect(speech, isNot(contains('Tap the best answer')));
    expect(speech, isNot(contains('brick→barrel')));
    expect(speech, isNot(contains('Brick → barrel')));
    expect(speech, isNot(contains('flush → abort')));
    expect(speech, isNot(contains('flush→abort')));
  });
}
