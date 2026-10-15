// LPT-848: SoftPulse-quiet densify stem must not spoil Air / little equity
// while SoftPulse stays off until Hint (SoftPulse LPT-653; same class as
// LPT-847 / LPT-846 / LPT-845 / LPT-844).
// LPT-851: idle densify coach rewrites board/hole tokens via
// alignLessonTableCopy onto the isomorphic remapped deal (LPT-806 class).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_starting_hand_copy.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

const _id = 'act-03-02-01-unguided';
const _line =
    'Board Qc 7d 2s. You hold 5h 4h multiway. Class — tap the matching label.';
const _templateHero = ['5h', '4h'];
const _templateBoard = ['Qc', '7d', '2s'];

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
    expect(speech, isNot(contains('Tap the best answer')));
    expect(speech, isNot(contains('Air')));
    expect(speech, isNot(contains('little equity')));
    expect(speech, isNot(contains('pick Air')));
    expect(speech, isNot(contains('pick ')));
    expect(speech.toLowerCase(), contains('board'));
    expect(speech.toLowerCase(), contains('you hold'));
    expect(speech, contains('tap the matching label'));
  });

  test('$_id densify idle coach follows remapped board/holes (LPT-851)', () {
    final activity = catalog.activityById(_id);
    expect(activity, isNotNull, reason: _id);
    late int generation;
    late List<String> dealtHero;
    late List<String> dealtBoard;
    for (generation = 0; generation < 64; generation++) {
      final scene = dealtLessonTableScene(activity!, generation: generation);
      expect(scene, isNotNull);
      final sameHero = scene!.heroCodes.join() == _templateHero.join();
      final sameBoard = scene.boardCodes.join() == _templateBoard.join();
      if (!sameHero || !sameBoard) {
        dealtHero = scene.heroCodes;
        dealtBoard = scene.boardCodes;
        break;
      }
    }
    expect(generation, lessThan(64));
    final expected = alignLessonTableCopy(
      text: _line,
      templateHero: _templateHero,
      dealtHero: dealtHero,
      templateBoard: _templateBoard,
      dealtBoard: dealtBoard,
    );
    expect(
      lessonFrameSpeech(activity!, bindGeneration: generation),
      expected,
    );
    expect(expected, isNot(contains('Qc')));
    expect(expected, isNot(contains('5h 4h')));
    for (final code in [...dealtHero, ...dealtBoard]) {
      expect(expected.toLowerCase(), contains(code.toLowerCase()));
    }
  });
}
