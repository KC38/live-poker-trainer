// LPT-881: SoftPulse-quiet densify stem must not spoil Call / Fold / Raise
// tile verbs while SoftPulse stays off until Hint (SoftPulse LPT-653; same
// class as LPT-882 / LPT-880 / LPT-878 / LPT-877).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-03-03-01-unguided';
const _line = 'Getting 3:1 with real outs — tap the matching price plan.';

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
    expect(speech, isNot(contains('Call, Fold, or Raise')));
    expect(speech, isNot(contains('tap Call')));
    expect(speech, isNot(contains('pick Call')));
    expect(speech, isNot(contains('pick ')));
  });
}
