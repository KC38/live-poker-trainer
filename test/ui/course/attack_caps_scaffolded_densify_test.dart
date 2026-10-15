// LPT-873: SoftPulse-quiet densify stem must not spoil Bet thin / thin
// value while SoftPulse stays off until Hint (SoftPulse LPT-653; same
// class as LPT-853 / LPT-866 / LPT-867).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-06-03-01-scaffolded';
const _line = 'Villain capped on river — tap your action below the table.';

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
    expect(speech.toLowerCase(), isNot(contains('thin value')));
    expect(speech.toLowerCase(), isNot(contains('bet thin')));
    expect(speech, isNot(contains('pick ')));
  });
}
