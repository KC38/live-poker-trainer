/// LPT-667: scaffolded multi-press steps author one teachSpec.pressHints
/// entry per SoftPulse cue press (not merely a non-empty array).
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';

const _expected = <String, List<String>>{
  'act-01-02-01-scaffolded-spot': [
    'Start with the weakest hand class.',
    'Keep climbing the class ladder.',
    'Finish with the strongest class.',
  ],
  'act-01-02-01-unguided-compare': [
    'Start with the strongest finished hand.',
    'Next comes the middle class.',
    'Finish with the weakest of the three.',
  ],
  'act-01-02-02-checkpoint-build': [
    "Look for three of a kind — that's the trips half.",
    'Keep collecting matching trip cards.',
    'Add the board card that matches your trips.',
    'Pair the trips with a board pair.',
    'Finish the five-card full house.',
  ],
  'act-01-04-01-scaffolded-order': [
    'Preflop, the first seat left of the big blind starts.',
    'Then move one seat to the left.',
    'Keep going left, toward the button.',
    'The button acts last before the blinds.',
  ],
  'act-01-06-01-scaffolded-multi': [
    'The call closes preflop. Move on to the flop first.',
    'You hit top pair. Bet to get value from worse hands.',
  ],
  'act-02-01-02-scaffolded-post': [
    'After the flop, the seat left of the button acts first.',
    'The button acts last on every street after the flop.',
  ],
};

/// Hand-ranks compare_rank seats use deal-aware [showdownOrderHintSpeech]
/// over static pressHints[0] (LPT-54 / LPT-626).
const _showdownDealAware = <String>{
  'act-01-02-01-scaffolded-spot',
  'act-01-02-01-unguided-compare',
};

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  for (final MapEntry(key: id, value: texts) in _expected.entries) {
    test('$id authors one pressHint per SoftPulse cue (LPT-667)', () {
      final a = catalog.activityById(id);
      expect(a, isNotNull, reason: id);
      expect(a!.assessmentRole, isNull);
      final hints = [
        for (final e in a.teachSpec!['pressHints'] as List<dynamic>)
          Map<String, dynamic>.from(e as Map),
      ];
      expect([for (final h in hints) h['press']], [
        for (var i = 1; i <= texts.length; i++) i,
      ]);
      expect([for (final h in hints) h['text']], texts);
      final cues = (a.teachSpec!['cues'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .where((c) => c['kind'] == 'soft_pulse')
          .toList();
      expect(hints.length, cues.length);
      final spoken = lessonFrameHintFallback(a);
      expect(spoken, isNotNull);
      if (_showdownDealAware.contains(id)) {
        expect(spoken, startsWith('Showdown — tap'));
      } else {
        expect(spoken, texts.first);
      }
    });
  }
}
