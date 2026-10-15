// LPT-835: SoftPulse-quiet densify stem must not spoil Top pair / best
// kicker while same-concept SoftPulse stays off until Hint (SoftPulse
// LPT-653; same class as LPT-833 / LPT-834 / LPT-814).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-01-02-02-guided-seven';
const _line = 'Tap the five cards that make your best hand.';

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
    expect(speech, isNot(contains('Top pair')));
    expect(speech, isNot(contains('best kicker')));
    expect(speech, isNot(contains('pick ')));
    expect(lessonFrameSoftPulseQuietByDefault(activity), isTrue);
  });
}
