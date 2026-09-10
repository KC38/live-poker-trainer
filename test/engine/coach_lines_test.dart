/// Tests that coaching copy is specific to the decision and varies.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// The stock string the coach used to emit for every single spot.
const _stockPhrase = 'Trust the exploit — punish their leak.';

CardModel _card(String code) => CardModel.fromCode(code);

GameState _spot({
  required PlayerArchetype archetype,
  required Street street,
  required List<String> hole,
  List<String> board = const [],
  double villainBet = 20,
  double mainPot = 40,
}) {
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: 400,
        isHero: true,
        holeCards: hole.map(_card).toList(),
      ),
      PlayerModel(
        id: 1,
        name: 'Villain',
        archetype: archetype,
        stack: 400,
        currentBet: villainBet,
        holeCards: [_card('2c'), _card('7d')],
      ),
    ],
    mode: GameMode.training,
    community: board.map(_card).toList(),
    mainPot: mainPot,
    street: street,
    highestBet: villainBet,
    minRaise: 2,
    smallBlind: 1,
    bigBlind: 2,
    lastAggressor: 1,
    waitingForHero: true,
  );
}

void main() {
  setUp(CoachLines.resetRotation);

  group('CoachPersona voice', () {
    test('names an original coach and forbids real-author endorsement', () {
      expect(CoachPersona.name, 'Mack Hayes');
      expect(CoachPersona.blurb, contains('blunt live-cash'));
      expect(CoachPersona.styleGuide, contains('Lexical style only'));
      expect(CoachPersona.styleGuide.toLowerCase(), isNot(contains('ed miller')));
      expect(CoachPersona.styleGuide, contains('never claim'));
    });

    test('offline openers use short Mack-style cadence', () {
      final state = _spot(
        archetype: PlayerArchetype.callingStation,
        street: Street.turn,
        hole: ['Ks', 'Jh'],
        board: ['Ac', '7c', '5d', '3h'],
        villainBet: 20,
        mainPot: 300,
      );
      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.raise, amount: 200),
      );
      expect(grade.verdict, CoachVerdict.incorrect);
      // Blunt openers: short clause + hard stop before the better line.
      expect(
        grade.message,
        anyOf(
          contains('Too hot on the turn.'),
          contains('Overplaying it on the turn.'),
        ),
      );
      expect(grade.message, contains(CoachReasonCode.neverBluffStations.phrase));
    });
  });

  group('CoachLines.classify', () {
    test('names the direction of the error', () {
      expect(
        CoachLines.classify(
          best: ExploitAction.call,
          taken: ExploitAction.raise,
          sizingOff: false,
        ),
        CoachMismatch.tooAggressive,
      );
      expect(
        CoachLines.classify(
          best: ExploitAction.raise,
          taken: ExploitAction.call,
          sizingOff: false,
        ),
        CoachMismatch.tooPassive,
      );
      expect(
        CoachLines.classify(
          best: ExploitAction.fold,
          taken: ExploitAction.call,
          sizingOff: false,
        ),
        CoachMismatch.tooLoose,
      );
      expect(
        CoachLines.classify(
          best: ExploitAction.call,
          taken: ExploitAction.fold,
          sizingOff: false,
        ),
        CoachMismatch.tooTight,
      );
      expect(
        CoachLines.classify(
          best: ExploitAction.raise,
          taken: ExploitAction.raise,
          sizingOff: true,
        ),
        CoachMismatch.sizing,
      );
    });
  });

  group('graded coaching copy', () {
    test('an INCORRECT raise-instead-of-call names the street and the read',
        () {
      // Cheap price on the turn with no made hand against a station: calling
      // is the line, and raising bluffs a player who never folds.
      final state = _spot(
        archetype: PlayerArchetype.callingStation,
        street: Street.turn,
        hole: ['Ks', 'Jh'],
        board: ['Ac', '7c', '5d', '3h'],
        villainBet: 20,
        mainPot: 300,
      );
      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.raise, amount: 200),
      );

      expect(grade.verdict, CoachVerdict.incorrect);
      expect(grade.optimalAction, ExploitAction.call);
      expect(grade.mismatch, CoachMismatch.tooAggressive);
      expect(grade.message, isNot(contains(_stockPhrase)));
      expect(grade.message.toLowerCase(), contains('turn'));
      expect(grade.message, contains('Villain'));
      expect(grade.message.toLowerCase(), contains('station'));
    });

    test('a fold against a nit is graded correct with a nit-specific reason',
        () {
      final state = _spot(
        archetype: PlayerArchetype.nit,
        street: Street.river,
        hole: ['7s', '2h'],
        board: ['Ac', 'Kc', 'Qd', '3h', '9s'],
        villainBet: 80,
        mainPot: 120,
      );
      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.fold),
      );

      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.message.toLowerCase(), contains('nit'));
      expect(grade.message.toLowerCase(), contains('river'));
      expect(grade.message, isNot(contains(_stockPhrase)));
    });

    test('advice differs across streets, archetypes, and actions', () {
      final messages = <String>[];
      for (final archetype in ArchetypeRoster.villainPool) {
        for (final street in [Street.flop, Street.turn, Street.river]) {
          for (final action in [
            const PokerAction(type: PokerActionType.fold),
            const PokerAction(type: PokerActionType.call, amount: 40),
            const PokerAction(type: PokerActionType.raise, amount: 200),
          ]) {
            final grade = LiveCoach.grade(
              state: _spot(
                archetype: archetype,
                street: street,
                hole: ['Ks', 'Jh'],
                board: street == Street.flop
                    ? ['Ac', 'Jc', 'Kd']
                    : street == Street.turn
                        ? ['Ac', 'Jc', 'Kd', '3h']
                        : ['Ac', 'Jc', 'Kd', '3h', '9s'],
                villainBet: 40,
                mainPot: 160,
              ),
              action: action,
            );
            messages.add(grade.message);
          }
        }
      }

      expect(messages, isNotEmpty);
      expect(messages.any((m) => m.contains(_stockPhrase)), isFalse);
      // The same sentence must not blanket every spot.
      final distinct = messages.toSet();
      expect(
        distinct.length,
        greaterThan(messages.length ~/ 2),
        reason: 'coaching copy repeats too often: '
            '${distinct.length} distinct of ${messages.length}',
      );
    });

    test('every line mentions the street it applies to', () {
      for (final street in Street.values.where((s) => s != Street.showdown)) {
        final grade = LiveCoach.grade(
          state: _spot(
            archetype: PlayerArchetype.maniac,
            street: street,
            hole: ['As', 'Ah'],
            board: street == Street.preflop ? const [] : ['Ac', '7c', '2d'],
            villainBet: 40,
            mainPot: 100,
          ),
          action: const PokerAction(type: PokerActionType.call, amount: 40),
        );
        final expected = switch (street) {
          Street.preflop => 'preflop',
          Street.flop => 'flop',
          Street.turn => 'turn',
          Street.river => 'river',
          Street.showdown => 'showdown',
        };
        expect(
          grade.message.toLowerCase(),
          contains(expected),
          reason: 'missing street in: ${grade.message}',
        );
      }
    });
  });

  group('Claude coach prompt', () {
    test('carries the full decision context so it cannot answer generically',
        () {
      final state = _spot(
        archetype: PlayerArchetype.lag,
        street: Street.flop,
        hole: ['Qs', 'Qd'],
        board: ['Ac', '7c', '2d'],
      );
      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.call, amount: 20),
      );
      final prompt = grade.toPrompt(state);

      expect(prompt, contains('Street being graded: FLOP'));
      expect(prompt, contains('Narration contract: slot-fill only'));
      expect(prompt, contains('LAG'));
      expect(prompt, contains('Villain'));
      expect(prompt, contains('CALL'));
      expect(prompt, contains('Qs'));
      expect(prompt, contains('Do not give generic advice'));
      expect(prompt, contains('voluntary aggressor'));
      expect(prompt, contains('Curriculum reason codes:'));
      expect(prompt, contains('Required phrases'));
      expect(prompt, contains('prefer those phrases verbatim'));
      expect(grade.reasonCodes, isNotEmpty);
      for (final code in grade.reasonCodes) {
        expect(prompt, contains(code.id));
        expect(prompt, contains(code.phrase));
        expect(grade.message, contains(code.phrase));
      }
    });
  });

  group('CoachReasonCode curriculum spine', () {
    test('fromId round-trips and falls back', () {
      for (final code in CoachReasonCode.values) {
        expect(CoachReasonCode.fromId(code.id), code);
      }
      expect(CoachReasonCode.fromId('nope'), CoachReasonCode.playTheSpot);
    });

    test('paying off a nit tags dont_pay_off_nits and fold_when_price_wrong',
        () {
      final codes = CoachReasonCode.derive(
        archetype: PlayerArchetype.nit,
        mismatch: CoachMismatch.tooLoose,
        best: ExploitAction.fold,
        equityPercent: 20,
        requiredEquityPercent: 40,
        callAmount: 40,
        villainIsAggressor: true,
      );
      expect(codes.first, CoachReasonCode.foldWhenPriceWrong);
      expect(codes, contains(CoachReasonCode.dontPayOffNits));
    });

    test('bluffing a station tags never_bluff_stations', () {
      final codes = CoachReasonCode.derive(
        archetype: PlayerArchetype.callingStation,
        mismatch: CoachMismatch.tooAggressive,
        best: ExploitAction.call,
        equityPercent: 35,
        requiredEquityPercent: 30,
        callAmount: 20,
        villainIsAggressor: true,
      );
      expect(codes, [CoachReasonCode.neverBluffStations]);
    });

    test('missing value vs station tags value_thin_vs_stations', () {
      final codes = CoachReasonCode.derive(
        archetype: PlayerArchetype.callingStation,
        mismatch: CoachMismatch.tooPassive,
        best: ExploitAction.raise,
        equityPercent: 70,
        requiredEquityPercent: 0,
        callAmount: 0,
        villainIsAggressor: false,
      );
      expect(codes, [CoachReasonCode.valueThinVsStations]);
    });

    test('folding too much vs LAG tags defend_vs_loose_aggro', () {
      final codes = CoachReasonCode.derive(
        archetype: PlayerArchetype.lag,
        mismatch: CoachMismatch.tooTight,
        best: ExploitAction.call,
        equityPercent: 45,
        requiredEquityPercent: 30,
        callAmount: 20,
        villainIsAggressor: true,
      );
      expect(codes.first, CoachReasonCode.continueWhenPriced);
      expect(codes, contains(CoachReasonCode.defendVsLooseAggro));
    });

    test('graded offline copy embeds the same phrases as toPrompt', () {
      final state = _spot(
        archetype: PlayerArchetype.callingStation,
        street: Street.turn,
        hole: ['Ks', 'Jh'],
        board: ['Ac', '7c', '5d', '3h'],
        villainBet: 20,
        mainPot: 300,
      );
      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.raise, amount: 200),
      );
      expect(grade.verdict, CoachVerdict.incorrect);
      expect(grade.reasonCodes, contains(CoachReasonCode.neverBluffStations));
      expect(
        grade.message,
        contains(CoachReasonCode.neverBluffStations.phrase),
      );
      expect(
        grade.toPrompt(state),
        contains(CoachReasonCode.neverBluffStations.phrase),
      );
    });

    test('correct fold vs nit aggressor keeps EV judge and explains with codes',
        () {
      final state = _spot(
        archetype: PlayerArchetype.nit,
        street: Street.river,
        hole: ['7s', '2h'],
        board: ['Ac', 'Kc', 'Qd', '3h', '9s'],
        villainBet: 80,
        mainPot: 120,
      );
      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.fold),
      );
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.optimalAction, ExploitAction.fold);
      expect(grade.reasonCodes, isNotEmpty);
      expect(
        grade.reasonCodes,
        anyOf(
          contains(CoachReasonCode.dontPayOffNits),
          contains(CoachReasonCode.foldWhenPriceWrong),
        ),
      );
      for (final code in grade.reasonCodes) {
        expect(grade.message, contains(code.phrase));
      }
    });
  });
}
