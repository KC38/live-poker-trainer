/// Unit coverage for randomized open-pot math deals.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_open_pot_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';

void main() {
  test('open pot deal adds blinds to the open', () {
    final deal = dealLessonOpenPot(random: Random(0));
    expect(kLessonOpenToAmounts, contains(deal.openTo));
    expect(deal.correctPot, deal.smallBlind + deal.bigBlind + deal.openTo);
    expect(deal.missBlindPot, deal.correctPot - deal.smallBlind);
    expect(deal.tooBigPot, deal.openTo * 2);
    expect(deal.missBlindPot, isNot(deal.correctPot));
    expect(deal.tooBigPot, isNot(deal.correctPot));
  });

  test('open pot deal is stable across repeated calls', () {
    final a = dealLessonOpenPot(activityId: kOpenPotActivityId, generation: 3);
    final b = dealLessonOpenPot(activityId: kOpenPotActivityId, generation: 3);
    expect(a.openTo, b.openTo);
    final c = dealLessonOpenPot(activityId: kOpenPotActivityId, generation: 4);
    // Different generation may or may not change; just ensure API is callable.
    expect(kLessonOpenToAmounts, contains(c.openTo));
  });

  test('labeled choices rewrite chip totals', () {
    final deal = const LessonOpenPotDeal(openTo: 6, smallBlind: 1, bigBlind: 2);
    final labeled = deal.labeledChoices(const [
      CourseChoice(id: kOpenPotCorrectChoiceId, label: 'Correct pot'),
      CourseChoice(id: kOpenPotMissBlindChoiceId, label: 'Miss a blind'),
      CourseChoice(id: kOpenPotTooBigChoiceId, label: 'Too big'),
    ]);
    expect(labeled.map((c) => c.label), ['9 chips', '8 chips', '12 chips']);
  });

  test('six-max street bets post blinds and the button open', () {
    final deal = const LessonOpenPotDeal(openTo: 7, smallBlind: 1, bigBlind: 2);
    final bets = deal.streetBetsForSixMax(
      buttonIndex: lessonBlindsButtonIndex,
      smallBlindIndex: lessonBlindsSmallBlindIndex,
      bigBlindIndex: lessonBlindsBigBlindIndex,
    );
    expect(bets.length, 6);
    expect(bets[lessonBlindsButtonIndex], 7);
    expect(bets[lessonBlindsSmallBlindIndex], 1);
    expect(bets[lessonBlindsBigBlindIndex], 2);
    expect(bets[0], 0);
  });

  test('every live open size has three different chip totals', () {
    for (final openTo in kLessonOpenToAmounts) {
      final deal = LessonOpenPotDeal(
        openTo: openTo,
        smallBlind: 1,
        bigBlind: 2,
      );
      expect(
        {deal.correctPot, deal.missBlindPot, deal.tooBigPot},
        hasLength(3),
        reason: 'open-to $openTo',
      );
      expect(deal.correctPot, 1 + 2 + openTo);
    }
  });

  test('street bets ignore seats outside the ring', () {
    const deal = LessonOpenPotDeal(openTo: 5, smallBlind: 1, bigBlind: 2);
    final bets = deal.streetBetsForSixMax(
      buttonIndex: -1,
      smallBlindIndex: 6,
      bigBlindIndex: 2,
    );
    expect(bets, [0, 0, 2, 0, 0, 0]);
    expect(
      deal.streetBetsForSixMax(
        buttonIndex: 0,
        smallBlindIndex: 0,
        bigBlindIndex: 0,
        seatCount: 0,
      ),
      isEmpty,
    );
  });

  test('open pot table folds early seats before the button opens', () {
    final deal = const LessonOpenPotDeal(openTo: 8, smallBlind: 1, bigBlind: 2);
    final game = lessonTableStageGame(
      heroCodes: const [],
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: lessonBlindsSmallBlindIndex,
      bbIndex: lessonBlindsBigBlindIndex,
      activeSeatIndex: lessonBlindsSmallBlindIndex,
      positionLabels: true,
      seatNames: lessonActionOrderSeatNames,
      streetBets: deal.streetBetsForSixMax(
        buttonIndex: lessonBlindsButtonIndex,
        smallBlindIndex: lessonBlindsSmallBlindIndex,
        bigBlindIndex: lessonBlindsBigBlindIndex,
      ),
      potTotal: deal.correctPot.toDouble(),
      foldedSeatIndexes: const [0, 1, 2],
      seatActionLabels: const {lessonBlindsButtonIndex: 'RAISE'},
    );
    expect(game.players[0].folded, isTrue);
    expect(game.players[1].folded, isTrue);
    expect(game.players[2].folded, isTrue);
    expect(game.players[lessonBlindsButtonIndex].folded, isFalse);
    expect(game.players[lessonBlindsButtonIndex].lastActionLabel, 'RAISE');
    expect(game.players[0].lastActionLabel, 'FOLD');
    expect(game.activePlayerIndex, lessonBlindsSmallBlindIndex);
  });
}
