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
      expect(prompt, contains('LAG'));
      expect(prompt, contains('Villain'));
      expect(prompt, contains('CALL'));
      expect(prompt, contains('Qs'));
      expect(prompt, contains('Do not give generic advice'));
      expect(prompt, contains('voluntary aggressor'));
    });
  });

  group('deal intro', () {
    test('names the hero hand and the dominant table type', () {
      final state = _spot(
        archetype: PlayerArchetype.callingStation,
        street: Street.preflop,
        hole: ['As', 'Kd'],
      );
      final intro = CoachLines.dealIntro(state);
      expect(intro, contains('A♠'));
      expect(intro.toLowerCase(), contains('station'));
    });
  });
}
