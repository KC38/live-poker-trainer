// LPT-848: SoftPulse-quiet densify stem must not spoil Air / little equity
// while SoftPulse stays off until Hint (SoftPulse LPT-653; same class as
// LPT-847 / LPT-846 / LPT-845 / LPT-844).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-03-02-01-unguided';
const _line =
    'Board Qc 7d 2s. You hold 5h 4h multiway. Class — tap the matching label.';

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
    expect(speech, isNot(contains('Air')));
    expect(speech, isNot(contains('little equity')));
    expect(speech, isNot(contains('pick Air')));
    expect(speech, isNot(contains('pick ')));
  });
}
