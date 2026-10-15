// LPT-846: SoftPulse-quiet densify stem must not spoil Raise stands /
// verbal is binding while SoftPulse stays off until Hint (SoftPulse LPT-653;
// same class as LPT-845 / LPT-844 / LPT-843).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-03-01-01-unguided';
const _line =
    'You say "raise" then try to take it back to a call — tap the matching result.';

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
    expect(speech, _line);
    expect(speech, isNot(contains('Tap the best answer')));
    expect(speech, isNot(contains('The raise stands')));
    expect(speech, isNot(contains('Raise stands')));
    expect(speech, isNot(contains('verbal is binding')));
    expect(speech, isNot(contains('pick ')));
  });
}
