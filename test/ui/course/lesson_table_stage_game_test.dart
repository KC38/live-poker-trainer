/// Street, pot, and seat labels for the shared lesson felt.
///
/// Your start and the lesson stage both build a hand through
/// [lessonBandGame]. A wrong street or a blind that does not wrap
/// teaches the wrong seat.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/poker_table_bands.dart';

void main() {
  test('an empty board is preflop with the blinds in the pot', () {
    final game = lessonBandGame();

    expect(game.street, Street.preflop);
    expect(game.smallBlind, 1);
    expect(game.bigBlind, 2);
    expect(game.mainPot, 3);
    expect(game.hero.currentBet, 0);
    expect(game.community, isEmpty);
    expect(game.players, hasLength(1));
    expect(game.hero.holeCards.map((card) => card.code), ['Ah', 'Kd']);
    expect(game.dealerIndex, 0);
    expect(game.sbIndex, 0);
    expect(game.bbIndex, 0);
    expect(game.waitingForHero, isFalse);
    expect(game.mode, GameMode.training);
  });

  test('Your start flop is three cards and a five big blind pot', () {
    final game = lessonBandGame(
      heroCodes: const ['Ah', 'Kd'],
      boardCodes: const ['Qs', 'Jh', '2c'],
      villainSeatCount: 1,
      waitingForHero: true,
    );

    expect(game.street, Street.flop);
    expect(game.mainPot, 10);
    expect(game.players.every((p) => p.currentBet == 0), isTrue);
    expect(game.community.map((card) => card.code), ['Qs', 'Jh', '2c']);
    expect(game.players, hasLength(2));
    expect(game.players[1].isHero, isFalse);
    expect(game.players[1].holeCards, isEmpty);
    expect(game.bbIndex, 1);
    expect(game.waitingForHero, isTrue);
    expect(game.hero.holeCards.map((card) => card.code), ['Ah', 'Kd']);
  });

  test('turn and river follow the board length', () {
    final turn = lessonBandGame(boardCodes: const ['Qs', 'Jh', '2c', '9d']);
    final river = lessonBandGame(
      boardCodes: const ['Qs', 'Jh', '2c', '9d', '4s'],
    );
    final extra = lessonBandGame(
      boardCodes: const ['Qs', 'Jh', '2c', '9d', '4s', 'Ac'],
    );

    expect(turn.street, Street.turn);
    expect(turn.mainPot, 10);
    expect(river.street, Street.river);
    expect(extra.street, Street.river);
    expect(extra.community, hasLength(6));
  });

  test('the stage names villains and shows only a full first hand', () {
    final hidden = lessonTableStageGame(villainCodes: const ['As']);
    final shown = lessonTableStageGame(
      villainCodes: const ['As', 'Kd', 'Qc'],
      villainCount: 6,
    );

    expect(hidden.players.map((player) => player.name), [
      'You',
      'Sam',
      'Jo',
      'Rio',
    ]);
    expect(hidden.players[1].holeCards, isEmpty);
    expect(hidden.dealerIndex, 0);
    expect(hidden.activePlayerIndex, 0);

    expect(shown.players.map((player) => player.name), [
      'You',
      'Sam',
      'Jo',
      'Rio',
      'Max',
      'Kai',
      'Sam',
    ]);
    expect(shown.players[1].holeCards.map((card) => card.code), ['As', 'Kd']);
    expect(shown.players[2].holeCards, isEmpty);
  });

  test('button and blinds wrap clockwise and do not glow a seat', () {
    final laidOut = lessonTableStageGame(
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
    );

    expect(laidOut.players, hasLength(6));
    expect(laidOut.dealerIndex, lessonBlindsButtonIndex);
    expect(laidOut.sbIndex, lessonBlindsSmallBlindIndex);
    expect(laidOut.bbIndex, lessonBlindsBigBlindIndex);
    expect(laidOut.positionLabel(lessonBlindsButtonIndex), 'BTN');
    expect(laidOut.positionLabel(lessonBlindsSmallBlindIndex), 'SB');
    expect(laidOut.positionLabel(lessonBlindsBigBlindIndex), 'BB');
    expect(laidOut.positionLabel(lessonBlindsRightOfButtonIndex), 'MP');
    expect(laidOut.activePlayerIndex, -1);

    final wrapped = lessonTableStageGame(villainCount: 5, dealerIndex: 5);
    expect(wrapped.sbIndex, 0);
    expect(wrapped.bbIndex, 1);
    expect(wrapped.positionLabel(5), 'BTN');
    expect(wrapped.positionLabel(0), 'SB');
    expect(wrapped.positionLabel(1), 'BB');
  });

  test('position labels replace villain names around the ring', () {
    final game = lessonTableStageGame(
      villainCount: lessonBlindsVillainCount,
      positionLabels: true,
    );

    expect(game.players.map((player) => player.name), [
      'EP',
      'HJ',
      'CO',
      'BTN',
      'SB',
      'BB',
    ]);
    expect(game.hero.holeCards.map((card) => card.code), ['Ah', 'Kd']);
  });

  test('action-order seat names label UTG around the ring', () {
    final game = lessonTableStageGame(
      villainCount: lessonBlindsVillainCount,
      seatNames: lessonActionOrderSeatNames,
    );

    expect(game.players.map((player) => player.name), [
      'UTG',
      'HJ',
      'CO',
      'BTN',
      'SB',
      'BB',
    ]);
    expect(lessonActionOrderSeatIndex('UTG'), 0);
    expect(lessonActionOrderSeatIndex('ep'), 0);
    expect(lessonActionOrderSeatIndex('CO'), 2);
    expect(lessonActionOrderSeatIndex('BTN'), 3);
    expect(lessonActionOrderSeatIndex('SB'), 4);
    expect(lessonActionOrderSeatIndex('unknown'), isNull);
  });

  test('late-seat order tables fold UTG and HJ before CO acts', () {
    expect(lessonSeatOrderFoldedIndexes('act-02-01-02-guided-pre'), [0, 1]);
    expect(
      lessonSeatOrderFoldedIndexes('act-02-01-02-scaffolded-post'),
      [0, 1, 2, 5],
    );
    expect(lessonSeatOrderFoldedIndexes('act-01-04-01-scaffolded-order'), isEmpty);

    final pre = lessonTableStageGame(
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: lessonBlindsSmallBlindIndex,
      bbIndex: lessonBlindsBigBlindIndex,
      seatNames: lessonActionOrderSeatNames,
      foldedSeatIndexes: lessonSeatOrderFoldedIndexes('act-02-01-02-guided-pre'),
    );
    expect(pre.players[0].name, 'UTG');
    expect(pre.players[0].folded, isTrue);
    expect(pre.players[1].folded, isTrue);
    expect(pre.players[0].lastActionLabel, 'FOLD');
    expect(pre.players[1].lastActionLabel, 'FOLD');
    expect(pre.players[2].folded, isFalse);
    expect(pre.players[5].folded, isFalse);
  });

  test('explicit blinds replace the clockwise default', () {
    final game = lessonTableStageGame(
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: 1,
      bbIndex: 2,
      activeSeatIndex: 2,
    );

    expect(game.dealerIndex, lessonBlindsButtonIndex);
    expect(game.sbIndex, 1);
    expect(game.bbIndex, 2);
    expect(game.activePlayerIndex, 2);
    expect(game.positionLabel(1), 'SB');
    expect(game.positionLabel(2), 'BB');
  });

  test('preflop posts the blinds in front of the two blind seats', () {
    final game = lessonTableStageGame(
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
    );

    final sb = game.players[lessonBlindsSmallBlindIndex];
    final bb = game.players[lessonBlindsBigBlindIndex];
    expect(sb.currentBet, 1);
    expect(sb.stack, 199);
    expect(bb.currentBet, 2);
    expect(bb.stack, 198);
    expect(game.mainPot, 0);
    expect(game.displayPot, 3);
    expect(game.players.where((p) => p.currentBet > 0).map((p) => p.id), [
      sb.id,
      bb.id,
    ]);
  });

  test('postBigBlind false leaves only the small blind out', () {
    final game = lessonTableStageGame(
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: lessonBlindsSmallBlindIndex,
      bbIndex: lessonBlindsBigBlindIndex,
      postBigBlind: false,
    );

    final sb = game.players[lessonBlindsSmallBlindIndex];
    final bb = game.players[lessonBlindsBigBlindIndex];
    expect(sb.currentBet, 1);
    expect(bb.currentBet, 0);
    expect(bb.stack, 200);
    expect(game.bbIndex, lessonBlindsBigBlindIndex);
    expect(game.displayPot, 1);
    expect(game.highestBet, 1);
  });

  test('postSmallBlind false leaves both blinds unposted', () {
    final game = lessonTableStageGame(
      villainCount: lessonBlindsVillainCount,
      dealerIndex: lessonBlindsButtonIndex,
      sbIndex: lessonBlindsSmallBlindIndex,
      bbIndex: lessonBlindsBigBlindIndex,
      postSmallBlind: false,
      postBigBlind: false,
    );

    final sb = game.players[lessonBlindsSmallBlindIndex];
    final bb = game.players[lessonBlindsBigBlindIndex];
    expect(sb.currentBet, 0);
    expect(bb.currentBet, 0);
    expect(sb.stack, 200);
    expect(bb.stack, 200);
    expect(game.displayPot, 0);
    expect(game.highestBet, 0);
  });

  test('a step can teach other stakes; stacks stay 100 big blinds', () {
    final game = lessonTableStageGame(smallBlind: 0.5, bigBlind: 1);

    expect(game.smallBlind, 0.5);
    expect(game.bigBlind, 1);
    expect(game.players[1].currentBet, 0.5);
    expect(game.players[2].currentBet, 1);
    expect(game.hero.stack, 100);
    expect(game.displayPot, 1.5);
  });

  test('heads-up the button posts the small blind', () {
    final game = lessonBandGame(villainSeatCount: 1);

    expect(game.sbIndex, 0);
    expect(game.bbIndex, 1);
    expect(game.hero.currentBet, 1);
    expect(game.players[1].currentBet, 2);
  });

  test('opponents carry player types only when the step names them', () {
    final plain = lessonTableStageGame();
    final typed = lessonTableStageGame(
      villainArchetypes: const [PlayerArchetype.nit, PlayerArchetype.maniac],
    );

    expect(plain.players[1].archetype, PlayerArchetype.tag);
    expect(typed.players.skip(1).map((p) => p.archetype), [
      PlayerArchetype.nit,
      PlayerArchetype.maniac,
      PlayerArchetype.nit,
    ]);
  });

  test('heroStackChips overrides only the hero remaining stack', () {
    final game = lessonTableStageGame(
      villainCount: 1,
      boardCodes: const ['Td', '8s', '2c'],
      heroStackChips: 12,
    );

    expect(game.hero.stack, 12);
    expect(game.players[1].stack, 200);
  });

  test('villainStackChips overrides every non-hero seat', () {
    final game = lessonTableStageGame(
      villainCount: 2,
      heroStackChips: 55,
      villainStackChips: 55,
    );

    expect(game.players.map((p) => p.stack), [55, 55, 55]);
  });

  test('winnerIds credits the pot to those seats and ends the hand', () {
    final open = lessonTableStageGame(villainCount: 0);
    final awarded = lessonTableStageGame(
      villainCount: 0,
      winnerIds: const [0],
    );

    expect(open.isHandOver, isFalse);
    expect(open.displayPot, 3);
    expect(open.hero.stack, 200);
    expect(awarded.isHandOver, isTrue);
    expect(awarded.winnerIds, [0]);
    expect(awarded.awardedPot, 3);
    expect(awarded.displayPot, 3);
    expect(awarded.hero.stack, 203);
    expect(awarded.awardShareFor(0), 3);
    expect(awarded.mainPot, 0);
  });

  test('lessonPotAwardWinnerIds is the hero after Take pot', () {
    expect(
      lessonPotAwardWinnerIds(
        activityId: 'act-01-05-01-guided-fold-win',
        selectedId: 'no-show',
      ),
      [0],
    );
    expect(
      lessonPotAwardWinnerIds(
        activityId: 'act-01-05-01-guided-fold-win',
        selectedId: 'must-show',
      ),
      isEmpty,
    );
    expect(
      lessonPotAwardWinnerIds(
        activityId: 'act-01-05-01-scaffolded-showdown',
        selectedId: 'no-show',
      ),
      isEmpty,
    );
  });
}
