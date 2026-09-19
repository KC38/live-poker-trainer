/// Regression tests for authored-to-live street progression.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/situation_model.dart';

const _boardCodes = ['2c', '7d', 'Jh', '9s', '3h'];

List<CardModel> _boardFor(Street street) {
  final length = switch (street) {
    Street.preflop => 0,
    Street.flop => 3,
    Street.turn => 4,
    Street.river || Street.showdown => 5,
  };
  return _boardCodes
      .take(length)
      .map(CardModel.fromCode)
      .toList(growable: false);
}

SituationModel _situationEndingAfterResponse({
  required Street street,
  required bool heroBets,
  bool directTerminal = false,
}) {
  final heroAmount = heroBets ? 8.0 : 0.0;
  final finalPot = 20 + (heroAmount * 2);
  final finalStacks = heroBets ? const [182.0, 182.0] : const [190.0, 190.0];
  final heroEdge = HeroActionEdge(
    actionKey: heroBets ? 'BET_40' : 'CHECK',
    kind: heroBets ? SituationActionKind.bet : SituationActionKind.check,
    amountTo: heroBets ? heroAmount : null,
    coaching: 'Complete the authored decision before advancing the street.',
    verdict: HeroActionVerdict.correct,
    evDeltaBb: 0,
    optimalActionKey: heroBets ? 'BET_40' : 'CHECK',
    nextNodeId: directTerminal ? 'legacy_showdown' : 'villain_response',
  );

  return SituationModel(
    payloadVersion: 2,
    schemaVersion: 'situation-v2.0',
    setupKey: 'street-progression',
    setupMode: SetupMode.random,
    seatCount: 2,
    smallBlind: 1,
    bigBlind: 2,
    ante: 0,
    startingStack: 200,
    buttonSeat: 0,
    heroSeat: 0,
    lineup: const [
      SituationSeatLineup(
        seat: 0,
        archetype: 'HERO',
        name: 'Hero',
        startingStack: 200,
      ),
      SituationSeatLineup(
        seat: 1,
        archetype: 'TAG',
        name: 'Villain',
        startingStack: 200,
      ),
    ],
    holeCards: [
      SituationHoleCards(
        seat: 0,
        cards: [CardModel.fromCode('As'), CardModel.fromCode('Kd')],
      ),
      SituationHoleCards(
        seat: 1,
        cards: [CardModel.fromCode('Qc'), CardModel.fromCode('Tc')],
      ),
    ],
    heroHand: [CardModel.fromCode('As'), CardModel.fromCode('Kd')],
    runouts: [
      StreetRunout(street: Street.flop, cards: _boardFor(Street.flop)),
      StreetRunout(
        street: Street.turn,
        cards: [CardModel.fromCode(_boardCodes[3])],
      ),
      StreetRunout(
        street: Street.river,
        cards: [CardModel.fromCode(_boardCodes[4])],
      ),
    ],
    rootNodeId: 'hero_decision',
    nodes: {
      'hero_decision': HeroDecisionNode(
        id: 'hero_decision',
        street: street,
        pot: 20,
        stacks: const [190, 190],
        streetBets: const [0, 0],
        board: _boardFor(street),
        foldedSeats: const [],
        toAct: 0,
        callAmount: 0,
        minRaiseTo: 2,
        actions: [heroEdge],
      ),
      if (!directTerminal)
        'villain_response': ScriptedNode(
          id: 'villain_response',
          street: street,
          pot: 20 + heroAmount,
          stacks: [190 - heroAmount, 190],
          streetBets: [heroAmount, 0],
          board: _boardFor(street),
          foldedSeats: const [],
          actions: [
            ScriptedAction(
              seat: 1,
              kind:
                  heroBets
                      ? SituationActionKind.call
                      : SituationActionKind.check,
              amountTo: heroBets ? heroAmount : null,
            ),
          ],
          nextNodeId: 'legacy_showdown',
        ),
      'legacy_showdown': TerminalNode(
        id: 'legacy_showdown',
        street: Street.river,
        reason: TerminalReason.showdown,
        board: _boardFor(Street.river),
        foldedSeats: const [],
        stacks: finalStacks,
        pot: finalPot,
        winnerSeats: const [0],
        heroNetChips: 0,
      ),
    },
  );
}

void main() {
  group('authored street completion', () {
    for (final street in const [Street.preflop, Street.flop, Street.turn]) {
      for (final heroBets in const [false, true]) {
        final line = heroBets ? 'bet-call' : 'check-check';

        test('$line advances exactly once after ${street.name}', () {
          final engine = PokerEngine(
            settings: const GameSettingsModel(seatCount: 2),
            random: Random(7),
          );
          engine.dealSituationHand(
            _situationEndingAfterResponse(street: street, heroBets: heroBets),
          );

          final edge = engine.currentHeroNode!.actions.single;
          engine.applySituationHeroChoice(
            edge: edge,
            action: PokerAction(
              type: heroBets ? PokerActionType.bet : PokerActionType.check,
              amount: heroBets ? 8 : 0,
            ),
          );

          final villainEvent = engine.nextEvent();
          expect(villainEvent?.kind, TableEventKind.villainAction);
          expect(engine.isLiveRemainderPlay, isTrue);

          TableEvent? streetEvent;
          for (var step = 0; step < 3; step++) {
            final event = engine.nextEvent();
            expect(
              event,
              isNotNull,
              reason: 'hero must not receive another ${street.name} action',
            );
            if (event!.state.waitingForHero) {
              expect(event.state.street, isNot(street));
            }
            if (event.kind == TableEventKind.dealStreet) {
              streetEvent = event;
              break;
            }
          }

          expect(streetEvent, isNotNull);
          expect(streetEvent!.street, street.next);
          expect(streetEvent.state.street, street.next);
          expect(
            streetEvent.state.community.length,
            _boardFor(street.next!).length,
          );
        });
      }
    }

    for (final street in const [Street.preflop, Street.flop, Street.turn]) {
      for (final heroBets in const [false, true]) {
        final line = heroBets ? 'bet' : 'check';

        test('direct-terminal $line passes action after ${street.name}', () {
          final engine = PokerEngine(
            settings: const GameSettingsModel(seatCount: 2),
            random: Random(7),
          );
          engine.dealSituationHand(
            _situationEndingAfterResponse(
              street: street,
              heroBets: heroBets,
              directTerminal: true,
            ),
          );

          final edge = engine.currentHeroNode!.actions.single;
          engine.applySituationHeroChoice(
            edge: edge,
            action: PokerAction(
              type: heroBets ? PokerActionType.bet : PokerActionType.check,
              amount: heroBets ? 8 : 0,
            ),
          );

          expect(engine.isLiveRemainderPlay, isTrue);
          expect(engine.state.street, street);
          expect(
            engine.state.waitingForHero,
            isFalse,
            reason: 'live remainder must not skip the responding villain',
          );
          expect(engine.state.activePlayerIndex, 1);

          final response = engine.nextEvent();
          expect(response, isNotNull);
          expect(response!.seatIndex, 1);
        });
      }
    }
  });
}
