/// Street, pot, and seat labels for the shared lesson felt.
///
/// Your start and the lesson stage both build a hand through
/// [lessonBandGame]. A wrong street or a blind that does not wrap
/// teaches the wrong seat.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_state.dart';
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
}
