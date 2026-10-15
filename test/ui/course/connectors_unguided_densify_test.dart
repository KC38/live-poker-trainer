// LPT-842: SoftPulse-quiet densify stem must not spoil Suited connector while
// SoftPulse stays off until Hint (SoftPulse LPT-653; same class as LPT-841 /
// LPT-839 / LPT-838).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-02-02-01-unguided-sc';
const _line =
    'Same-suit cards next to each other in rank — tap the matching family.';

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
    expect(speech, isNot(contains('Suited connector')));
    expect(speech, isNot(contains('pick Suited')));
    expect(speech, isNot(contains('pick ')));
  });
}
