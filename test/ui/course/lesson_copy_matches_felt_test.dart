/// Copy ↔ felt matches for two Task-B follow-ups:
/// * SB multiway 76s ("medium connectors") never deals 32s / T9s.
/// * The BB probe is a turn lead after the raiser checked back the flop —
///   no seat has acted on the turn yet (a BTN CHECK tag on a flop board with
///   the BB still to act was out of turn).
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_felt_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';

CourseActivity _act(String id) {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  for (final s in catalog.sections) {
    for (final u in s.units) {
      for (final l in u.lessons) {
        for (final a in l.activities) {
          if (a.id == id) return a;
        }
      }
    }
  }
  throw StateError('missing $id');
}

void main() {
  test('connector band: low / medium / high', () {
    expect(lessonConnectorRankBand(['3s', '2s']), 'low');
    expect(lessonConnectorRankBand(['7h', '6h']), 'medium');
    expect(lessonConnectorRankBand(['9d', '8c']), 'medium');
    expect(lessonConnectorRankBand(['Ts', '9s']), 'high');
    expect(lessonConnectorRankBand(['Ah', 'Kd']), isNull);
  });

  test('SB multiway 76s deals stay medium suited connectors', () {
    final activity = _act('act-05-01-01-scaffolded');
    for (var g = 0; g < 300; g++) {
      final spot = dealtLessonActionSpot(
        activity,
        generation: g,
        random: Random(g),
      )!;
      expect(
        lessonConnectorRankBand(spot.heroCodes),
        'medium',
        reason: 'generation $g dealt ${spot.heroCodes}',
      );
      expect(spot.heroCodes[0][1], spot.heroCodes[1][1]);
    }
  });

  test('BB probe sits on the turn with no turn action yet', () {
    final activity = _act('act-05-05-01-scaffolded');
    expect(activity.prompt, contains('checked back the flop'));
    expect(activity.prompt, contains('Turn'));
    final spot = resolveLessonActionSpot(activity)!;
    expect(spot.boardCodes, hasLength(4));
    final layout = resolveLessonActionFeltLayout(spot);
    expect(layout.villainSeatIndex, isNot(0));
    expect(layout.foldedSeatIndexes, isNot(contains(layout.villainSeatIndex)));
    expect(
      layout.seatActionLabels.values.where((l) => l.toUpperCase() == 'CHECK'),
      isEmpty,
    );
    final checkLabel = activity.choices.firstWhere((c) => c.id == 'never').label;
    expect(checkLabel, 'Check');
  });

  test('multiway pot count: 19 is the answer the felt adds up to', () {
    final activity = _act('act-03-01-01-guided');
    expect(activity.choices.map((c) => c.id), ['pot-19', 'pot-21', 'pot-18']);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.potChipsNineteen,
        choices: activity.choices,
      ),
      'pot-19',
    );
  });
}
