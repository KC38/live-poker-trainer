/// Unit tests for constrained lesson card deals.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/deck_evaluator.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';

bool _isSuited(List<String> codes) {
  final a = CardModel.fromCode(codes[0]);
  final b = CardModel.fromCode(codes[1]);
  return a.suit == b.suit && a.rank != b.rank;
}

bool _isOffsuit(List<String> codes) {
  final a = CardModel.fromCode(codes[0]);
  final b = CardModel.fromCode(codes[1]);
  return a.suit != b.suit && a.rank != b.rank;
}

bool _isPair(List<String> codes) {
  final a = CardModel.fromCode(codes[0]);
  final b = CardModel.fromCode(codes[1]);
  return a.rank == b.rank && a.suit != b.suit;
}

void main() {
  tearDown(() {
    debugLessonCardDealRandom = null;
  });

  test('dealHoleHand preserves attributes across kinds', () {
    final rng = Random(7);
    for (var i = 0; i < 40; i++) {
      expect(_isSuited(dealHoleHand(LessonHoleKind.suitedNonPair, rng)), isTrue);
      expect(_isOffsuit(dealHoleHand(LessonHoleKind.offsuitNonPair, rng)), isTrue);
      expect(_isPair(dealHoleHand(LessonHoleKind.pocketPair, rng)), isTrue);
      final ace = dealHoleHand(LessonHoleKind.suitedAce, rng);
      expect(_isSuited(ace), isTrue);
      expect(ace.any((c) => c.startsWith('A')), isTrue);
      final broadway = dealHoleHand(LessonHoleKind.broadway, rng);
      expect(_isOffsuit(broadway), isTrue);
      for (final code in broadway) {
        expect('TJQKA'.contains(code[0]), isTrue);
      }
    }
  });

  test('suited seat plan shuffles cards and seats but keeps roles', () {
    final activity = CourseActivity(
      id: 'act-01-01-02-unguided-suited',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the seat whose hole cards share a suit.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the suited hole cards.',
      choices: const [
        CourseChoice(id: 'suited-ah-kh', label: 'Ah Kh'),
        CourseChoice(id: 'offsuit-ah-kd', label: 'Ac Kd'),
        CourseChoice(id: 'pair-77', label: '7c 7d'),
      ],
    );

    final deals = [
      for (var seed = 0; seed < 24; seed++)
        dealHoleHandSeatPlan(activity, random: Random(seed))!,
    ];
    expect(deals.map((d) => d.correctSeatIndex).toSet().length, greaterThan(1));
    expect(
      deals.map((d) => d.heroCodes.join(' ')).toSet().length,
      greaterThan(1),
    );

    for (final deal in deals) {
      final byId = <String, List<String>>{
        deal.choiceIdsBySeat[0]: deal.heroCodes,
        deal.choiceIdsBySeat[1]: deal.villainHoleCodes[0],
        deal.choiceIdsBySeat[2]: deal.villainHoleCodes[1],
      };
      expect(_isSuited(byId['suited-ah-kh']!), isTrue);
      expect(_isOffsuit(byId['offsuit-ah-kd']!), isTrue);
      expect(_isPair(byId['pair-77']!), isTrue);
      expect(deal.choiceIdForSeat(deal.correctSeatIndex), 'suited-ah-kh');
      final all = [
        ...deal.heroCodes,
        ...deal.villainHoleCodes[0],
        ...deal.villainHoleCodes[1],
      ];
      expect(all.toSet().length, 6);
    }
  });

  test('pocket-pair seat plan keeps exactly one pair as the answer', () {
    final activity = CourseActivity(
      id: 'act-01-01-02-checkpoint-pair',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Tap the seat with a pocket pair.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the pocket pair.',
      choices: const [
        CourseChoice(id: 'pocket-pair', label: '9h 9d'),
        CourseChoice(id: 'suited-nine', label: 'Ah Kh'),
        CourseChoice(id: 'two-high', label: 'Ac Kd'),
      ],
    );
    for (var seed = 0; seed < 16; seed++) {
      final deal = dealHoleHandSeatPlan(activity, random: Random(seed))!;
      expect(deal.choiceIdForSeat(deal.correctSeatIndex), 'pocket-pair');
      final codes = deal.correctSeatIndex == 0
          ? deal.heroCodes
          : deal.villainHoleCodes[deal.correctSeatIndex - 1];
      expect(_isPair(codes), isTrue);
    }
  });

  test('one-of-each-suit board keeps suit order and unique ranks', () {
    final boards = [
      for (var seed = 0; seed < 20; seed++)
        dealOneOfEachSuitBoard(random: Random(seed)),
    ];
    expect(boards.map((b) => b.join(' ')).toSet().length, greaterThan(1));
    for (final board in boards) {
      expect(board.map((c) => c[c.length - 1]).toList(), ['h', 'd', 'c', 's']);
      expect(board.map((c) => c.substring(0, c.length - 1)).toSet().length, 4);
    }
  });

  test('showdown order deals vary cards but keep category ladder', () {
    const cases = <String, List<String>>{
      'act-01-02-01-unguided-compare': [
        'Full House',
        'Three of a Kind',
        'Two Pair',
      ],
      'act-01-02-01-checkpoint-winner': ['Flush', 'Straight', 'High Card'],
      'act-01-02-01-explain-ladder': ['High Card', 'One Pair', 'Flush'],
      'act-01-02-01-scaffolded-spot': ['One Pair', 'Straight', 'Flush'],
    };

    for (final entry in cases.entries) {
      final deals = [
        for (var seed = 0; seed < 12; seed++)
          dealShowdownOrderCards(entry.key, random: Random(seed))!,
      ];
      expect(
        deals.map((d) => d.boardCodes.join(' ')).toSet().length,
        greaterThan(1),
        reason: entry.key,
      );
      for (final deal in deals) {
        expect(deal.correctOrder, ['you', 'sam', 'jo'], reason: entry.key);
        String name(List<String> holes) {
          final cards = [
            for (final code in [...holes, ...deal.boardCodes])
              CardModel.fromCode(code),
          ];
          return DeckEvaluator.evaluate7Cards(cards).rankName;
        }

        expect(name(deal.heroCodes), entry.value[0], reason: entry.key);
        expect(
          name(deal.villainHoleCodes[0]),
          entry.value[1],
          reason: entry.key,
        );
        expect(
          name(deal.villainHoleCodes[1]),
          entry.value[2],
          reason: entry.key,
        );
      }
    }
  });
}
