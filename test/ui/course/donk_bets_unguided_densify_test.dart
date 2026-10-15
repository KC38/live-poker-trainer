// LPT-861: SoftPulse-quiet densify stem must not spoil Often polarized —
// strong or bluff while SoftPulse stays off until Hint
// (SoftPulse LPT-653; same class as LPT-860 / LPT-859 / LPT-858 / LPT-857 /
// LPT-853).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-05-05-01-unguided';
const _line =
    'BB donks large on A-high dry flop into PFR. Meaning — tap the matching read.';

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
    expect(speech, isNot(contains('Often polarized')));
    expect(speech, isNot(contains('strong or bluff')));
    expect(speech, isNot(contains('pick ')));
  });
}
