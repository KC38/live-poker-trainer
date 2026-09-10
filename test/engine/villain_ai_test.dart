/// VillainAi samples align with VillainModel frequencies used by the coach.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/engine/villain_ai.dart';
import 'package:live_poker_trainer/engine/villain_model.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';

CardModel _c(String code) => CardModel.fromCode(code);

/// Flop spot: villain faces a half-pot bet with known hole cards.
GameState _facingHalfPot({
  required PlayerArchetype archetype,
  required List<CardModel> holes,
  required List<CardModel> board,
  double villainStack = 500,
  double callAmount = 50,
  double potBeforeBet = 100,
}) {
  // Hero has bet `callAmount`; pot before villain acts = potBeforeBet + call.
  final highest = callAmount;
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: 450,
        isHero: true,
        currentBet: highest,
        holeCards: [_c('As'), _c('Kd')],
        hasActedThisRound: true,
      ),
      PlayerModel(
        id: 1,
        name: 'Villain',
        archetype: archetype,
        stack: villainStack,
        currentBet: 0,
        holeCards: holes,
      ),
    ],
    mode: GameMode.training,
    community: board,
    mainPot: potBeforeBet,
    street: Street.flop,
    highestBet: highest,
    minRaise: callAmount,
    smallBlind: 1,
    bigBlind: 2,
    lastAggressor: 0,
    activePlayerIndex: 1,
  );
}

GameState _checkedTo({
  required PlayerArchetype archetype,
  required List<CardModel> holes,
  required List<CardModel> board,
  double pot = 100,
}) {
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: 500,
        isHero: true,
        holeCards: [_c('As'), _c('Kd')],
        hasActedThisRound: true,
      ),
      PlayerModel(
        id: 1,
        name: 'Villain',
        archetype: archetype,
        stack: 500,
        holeCards: holes,
      ),
    ],
    mode: GameMode.training,
    community: board,
    mainPot: pot,
    street: Street.flop,
    highestBet: 0,
    minRaise: 2,
    smallBlind: 1,
    bigBlind: 2,
    activePlayerIndex: 1,
  );
}

void main() {
  group('VillainAi hand classification', () {
    test('classifies air on a dry flop', () {
      final state = _facingHalfPot(
        archetype: PlayerArchetype.callingStation,
        // Under cards, no draw — not overcards (those are weakDraw).
        holes: [_c('3h'), _c('5d')],
        board: [_c('As'), _c('Kd'), _c('Qc')],
      );
      expect(
        VillainAi.handClassFor(state, state.players[1]),
        HandClass.air,
      );
    });

    test('classifies top pair', () {
      final state = _facingHalfPot(
        archetype: PlayerArchetype.tag,
        holes: [_c('Ah'), _c('Kd')],
        board: [_c('Ac'), _c('7d'), _c('2h')],
      );
      expect(
        VillainAi.handClassFor(state, state.players[1]),
        HandClass.topPair,
      );
    });
  });

  group('VillainAi vs VillainModel frequencies', () {
    test('station with air continues near callFrequency at half-pot', () {
      const arch = PlayerArchetype.callingStation;
      const handClass = HandClass.air;
      final expectedCall = VillainModel.callFrequency(arch, handClass);
      final expectedRaise = VillainModel.raiseFrequency(arch, handClass);
      final expectedFold = VillainModel.foldFrequency(arch, handClass);

      final state = _facingHalfPot(
        archetype: arch,
        holes: [_c('3h'), _c('5d')],
        board: [_c('As'), _c('Kd'), _c('Qc')],
      );
      expect(VillainAi.handClassFor(state, state.players[1]), handClass);

      var folds = 0;
      var calls = 0;
      var raises = 0;
      const trials = 4000;
      for (var i = 0; i < trials; i++) {
        final choice = VillainAi.decide(state, 1, Random(i));
        switch (choice.line) {
          case VillainLine.fold:
            folds++;
          case VillainLine.call:
            calls++;
          case VillainLine.raise:
            raises++;
          case VillainLine.check:
            fail('must not check when facing a bet');
        }
      }

      expect(calls / trials, closeTo(expectedCall, 0.04));
      expect(raises / trials, closeTo(expectedRaise, 0.03));
      expect(folds / trials, closeTo(expectedFold, 0.04));
    });

    test('nit with air almost never continues at half-pot', () {
      const arch = PlayerArchetype.nit;
      final expectedContinue = VillainModel.continueFrequency(
        arch,
        HandClass.air,
      );

      final state = _facingHalfPot(
        archetype: arch,
        holes: [_c('3h'), _c('5d')],
        board: [_c('As'), _c('Kd'), _c('Qc')],
      );
      expect(
        VillainAi.handClassFor(state, state.players[1]),
        HandClass.air,
      );

      var continues = 0;
      const trials = 3000;
      for (var i = 0; i < trials; i++) {
        final choice = VillainAi.decide(state, 1, Random(i));
        if (choice.line != VillainLine.fold) continues++;
      }

      expect(continues / trials, closeTo(expectedContinue, 0.03));
    });

    test('station with top pair almost never folds at half-pot', () {
      const arch = PlayerArchetype.callingStation;
      final expectedFold = VillainModel.foldFrequency(arch, HandClass.topPair);

      final state = _facingHalfPot(
        archetype: arch,
        holes: [_c('Ah'), _c('Kd')],
        board: [_c('Ac'), _c('7d'), _c('2h')],
      );
      expect(
        VillainAi.handClassFor(state, state.players[1]),
        HandClass.topPair,
      );

      var folds = 0;
      const trials = 3000;
      for (var i = 0; i < trials; i++) {
        final choice = VillainAi.decide(state, 1, Random(i));
        if (choice.line == VillainLine.fold) folds++;
      }

      expect(folds / trials, closeTo(expectedFold, 0.03));
    });

    test('maniac bets air near betFrequency when checked to', () {
      const arch = PlayerArchetype.maniac;
      final fraction = VillainAi.betSizeFraction(arch);
      final expectedBet = VillainModel.betFrequency(
        arch,
        HandClass.air,
        betToPot: fraction,
      );

      final state = _checkedTo(
        archetype: arch,
        holes: [_c('3h'), _c('5d')],
        board: [_c('As'), _c('Kd'), _c('Qc')],
      );
      expect(
        VillainAi.handClassFor(state, state.players[1]),
        HandClass.air,
      );

      var bets = 0;
      const trials = 4000;
      for (var i = 0; i < trials; i++) {
        final choice = VillainAi.decide(state, 1, Random(i));
        expect(choice.line, isNot(VillainLine.fold));
        if (choice.line == VillainLine.raise) bets++;
      }

      expect(bets / trials, closeTo(expectedBet, 0.04));
    });

    test('never folds when call amount is zero', () {
      final state = _checkedTo(
        archetype: PlayerArchetype.nit,
        holes: [_c('2h'), _c('7d')],
        board: [_c('As'), _c('Kd'), _c('Qc')],
      );
      for (var i = 0; i < 200; i++) {
        final choice = VillainAi.decide(state, 1, Random(i));
        expect(choice.line, isNot(VillainLine.fold));
      }
    });

    test('short stack facing a bet cannot raise; call/fold only', () {
      final state = _facingHalfPot(
        archetype: PlayerArchetype.lag,
        holes: [_c('Ah'), _c('Kd')],
        board: [_c('Ac'), _c('7d'), _c('2h')],
        villainStack: 50, // exactly the call
        callAmount: 50,
      );
      for (var i = 0; i < 300; i++) {
        final choice = VillainAi.decide(state, 1, Random(i));
        expect(choice.line, isNot(VillainLine.raise));
        expect(
          choice.line == VillainLine.call || choice.line == VillainLine.fold,
          isTrue,
        );
      }
    });

    test('same seed yields the same decision', () {
      final state = _facingHalfPot(
        archetype: PlayerArchetype.tag,
        holes: [_c('Jh'), _c('Td')],
        board: [_c('9c'), _c('8d'), _c('2h')],
      );
      final a = VillainAi.decide(state, 1, Random(99));
      final b = VillainAi.decide(state, 1, Random(99));
      expect(a.line, b.line);
      expect(a.callAmount, b.callAmount);
      expect(a.raiseTo, b.raiseTo);
    });
  });
}
