// LPT-869: SoftPulse-off densify stem must not spoil The two cards at your
// seat / the two at your seat while assessment cues stay kind: none
// (SoftPulse LPT-653; same class as LPT-868 / LPT-867 / LPT-812).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-01-01-01-checkpoint-table';
const _line = 'Private cards on this table — tap the ones only you can see.';

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
    expect(speech, isNot(contains('the two at your seat')));
    expect(speech, isNot(contains('The two cards at your seat')));
    expect(
      speech,
      isNot(contains('pick the two at your seat')),
    );
  });
}
