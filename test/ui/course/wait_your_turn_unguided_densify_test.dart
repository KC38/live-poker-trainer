// LPT-838: SoftPulse-quiet densify stem must not spoil Wait while SoftPulse
// stays off until Hint (SoftPulse LPT-653; same class as LPT-837 / LPT-833 /
// LPT-834).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-02-01-02-unguided-wait';
const _line = 'Action is on UTG. You are on the button. Tap what you should do.';

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
    expect(speech, isNot(contains('Wait')));
    expect(speech, isNot(contains('do not act yet')));
    expect(speech, isNot(contains('pick ')));
  });
}
