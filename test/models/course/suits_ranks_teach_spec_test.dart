/// LPT-81: Suits and ranks authors `teachSpec` on every interactive step, and
/// the authored deal classes match what `lesson_card_deal.dart` deals.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';

const _guidedSuits = 'act-01-01-02-guided-suits';
const _ranks = 'act-01-01-02-scaffolded-ranks';
const _suited = 'act-01-01-02-unguided-suited';
const _pair = 'act-01-01-02-checkpoint-pair';

CourseCatalog _catalog() {
  final raw = File('assets/course/v2/catalog.json').readAsStringSync();
  return CourseCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

Map<String, dynamic> _deal(CourseActivity activity) {
  final teach = activity.teachSpec;
  expect(teach, isNotNull, reason: '${activity.id} needs teachSpec');
  final deal = teach!['deal'];
  expect(deal, isA<Map<String, dynamic>>(), reason: '${activity.id} deal');
  return deal as Map<String, dynamic>;
}

String _suit(String code) => code.substring(code.length - 1);
String _rank(String code) => code.substring(0, code.length - 1);

bool _isSuitedNonPair(List<String> codes) =>
    _suit(codes[0]) == _suit(codes[1]) && _rank(codes[0]) != _rank(codes[1]);

bool _isPair(List<String> codes) => _rank(codes[0]) == _rank(codes[1]);

List<List<String>> _seats(HoleHandSeatDeal deal) => [
  deal.heroCodes,
  ...deal.villainHoleCodes,
];

void main() {
  late CourseCatalog catalog;
  setUpAll(() => catalog = _catalog());

  CourseActivity act(String id) {
    final found = catalog.activityById(id);
    expect(found, isNotNull, reason: id);
    return found!;
  }

  test('every interactive Suits and ranks step authors a teachSpec deal', () {
    for (final id in [_guidedSuits, _ranks, _suited, _pair]) {
      final deal = _deal(act(id));
      expect(deal['mode'], 'random_in_class', reason: id);
      expect(
        deal['handFamily'] != null || deal['suitFamily'] != null,
        isTrue,
        reason: '$id random_in_class needs a family',
      );
    }
    expect(_deal(act(_guidedSuits))['suitFamily'], 'four_suits');
    expect(_deal(act(_ranks))['suitFamily'], 'rainbow');
    expect(_deal(act(_suited))['suitFamily'], 'suited');
    expect(_deal(act(_pair))['handFamily'], 'pair');
    expect(act(_ranks).assessmentRole, isNull);
  });

  test('guided suits authors one SoftPulse cue per suit press', () {
    final cues = act(_guidedSuits).teachSpec!['cues'] as List<dynamic>;
    expect(cues, hasLength(4));
    final presses = [for (final c in cues) (c as Map)['press']];
    expect(presses, [1, 2, 3, 4]);
    final targets = {for (final c in cues) (c as Map)['target']};
    expect(targets, hasLength(4), reason: 'one gold target per press');
    for (final c in cues) {
      expect((c as Map)['kind'], 'soft_pulse');
    }
  });

  test('checkpoint pair keeps no pressHints and no Hint media', () {
    final checkpoint = act(_pair);
    expect(checkpoint.assessmentRole, isNotNull);
    expect(checkpoint.teachSpec!.containsKey('pressHints'), isFalse);
    expect(checkpoint.coachMedia.where((m) => m.kind == 'hint'), isEmpty);
    expect(lessonFrameHintsDisabled(checkpoint), isTrue);
    expect(lessonFrameHintFallback(checkpoint), isNull);
  });

  test('suit board deal stays four suits and randomizes ranks', () {
    final boards = <String>{};
    for (var seed = 0; seed < 24; seed++) {
      final board = dealSuitLessonBoard(
        withStarDistractor: true,
        random: Random(seed),
      );
      final real = [
        for (final c in board)
          if (!c.endsWith('*')) c,
      ];
      expect({for (final c in real) _suit(c)}, {'h', 'd', 'c', 's'});
      boards.add(board.join(' '));
    }
    expect(boards.length, greaterThan(1));
  });

  test('rank-order deal stays three distinct ranks on a rainbow board', () {
    final activity = act(_ranks);
    final authored = [
      for (final item in activity.sequenceItems) (id: item.id, label: item.label),
    ];
    final labels = <String>{};
    for (var seed = 0; seed < 24; seed++) {
      final deal = dealRankOrderSpot(
        authoredItems: authored,
        activityId: activity.id,
        random: Random(seed),
      );
      expect({for (final c in deal.boardCodes) _rank(c)}, hasLength(3));
      expect({for (final c in deal.boardCodes) _suit(c)}, hasLength(3));
      expect([for (final i in deal.sequenceItems) i.id], [
        'rank-2',
        'rank-T',
        'rank-A',
      ]);
      labels.add([for (final i in deal.sequenceItems) i.label].join());
    }
    expect(labels.length, greaterThan(1));
  });

  test('seat deals match the authored hand/suit classes and randomize', () {
    for (final id in [_suited, _pair]) {
      final activity = act(id);
      final layouts = <String>{};
      for (var seed = 0; seed < 32; seed++) {
        final plan = dealHoleHandSeatPlan(activity, random: Random(seed))!;
        final seats = _seats(plan);
        final answer = seats[plan.correctSeatIndex];
        final answerChoice = plan.choiceIdsBySeat[plan.correctSeatIndex];
        if (id == _suited) {
          expect(_isSuitedNonPair(answer), isTrue, reason: '$seed $answer');
          expect(answerChoice, 'suited-ah-kh');
        } else {
          expect(_isPair(answer), isTrue, reason: '$seed $answer');
          expect(answerChoice, 'pocket-pair');
        }
        // Distractor seats: one pair / suited and one offsuit non-pair.
        final others = [
          for (var i = 0; i < seats.length; i++)
            if (i != plan.correctSeatIndex) seats[i],
        ];
        final offsuit = others.where(
          (s) => _suit(s[0]) != _suit(s[1]) && !_isPair(s),
        );
        expect(offsuit, hasLength(1), reason: '$id $seed $others');
        // The choice ids are a permutation of the authored choices, so the
        // grade follows whichever seat the deal placed the answer on.
        expect(
          plan.choiceIdsBySeat.toSet(),
          {for (final c in activity.choices) c.id},
        );
        layouts.add('${plan.correctSeatIndex} ${answer.join()}');
      }
      expect(layouts.length, greaterThan(1), reason: '$id randomizes');
    }
  });
}
