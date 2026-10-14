// LPT-812: SoftPulse-off densify stem must not spoil Weigh SPR first or
// append the poker-action dock footer while assessment cues stay kind: none
// (SoftPulse LPT-653; same class as LPT-809).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-04-05-01-checkpoint';
const _line = 'About to put stacks in — tap the matching plan.';

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
    expect(speech, isNot(contains('below the table')));
    expect(speech, isNot(contains('Weigh SPR first')));
    expect(speech, isNot(contains('Weigh SPR')));
  });
}
