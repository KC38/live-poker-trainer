// LPT-814: SoftPulse-off densify stems must not spoil Hearts/diamonds/
// clubs/spades while assessment cues stay kind: none and guided same-concept
// SoftPulse stays quiet until Hint (SoftPulse LPT-653; same class as LPT-808).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _line = 'Tap one community card of each suit.';
const _ids = <String>[
  'act-01-01-02-guided-suits',
  'act-01-01-02-01-scaffolded-suits',
  'act-01-01-02-01-checkpoint-suits',
];

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final id in _ids) {
    test('$id SoftPulse-off densify stem is non-spoiling', () {
      expect(selectIdentifyDensifiedCoachLine(id), _line);
      final activity = catalog.activityById(id);
      expect(activity, isNotNull, reason: id);
      final speech = lessonFrameSpeech(activity!);
      expect(speech, _line);
      expect(speech, isNot(contains('Tap the best answer')));
      expect(speech, isNot(contains('Hearts, diamonds, clubs, spades')));
      expect(speech, isNot(contains('Hearts')));
      expect(speech, isNot(contains('diamonds')));
      expect(speech, isNot(contains('clubs')));
      expect(speech, isNot(contains('spades')));
    });
  }
}
