// LPT-850: SoftPulse-quiet densify stem must not spoil 50bb / 100bb / 200bb
// while SoftPulse stays off until Hint (SoftPulse LPT-653; same class as
// LPT-849 / LPT-845 / LPT-844).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-02-05-01-unguided-depth';
const _line =
    'Which depth plays closest to a short-stack shove game — tap the matching depth.';

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
    expect(speech, isNot(contains('50bb')));
    expect(speech, isNot(contains('100bb')));
    expect(speech, isNot(contains('200bb')));
    expect(speech, isNot(contains('pick ')));
  });
}
