/// LiveCoach context: position + aggressor grounding for Claude prompts.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

CardModel _c(String code) => CardModel.fromCode(code);

void main() {
  group('position + aggressor context', () {
    test('BB who only posted is not labeled the aggressor in the prompt', () {
      // Hero BTN facing $2 to call with only blinds out — Ned is BB.
      final state = GameState(
        players: [
          PlayerModel(
            id: 0,
            name: 'Hero',
            archetype: PlayerArchetype.hero,
            stack: 398,
            isHero: true,
            holeCards: [_c('Ac'), _c('9s')],
          ),
          PlayerModel(
            id: 1,
            name: 'Stan',
            archetype: PlayerArchetype.nit,
            stack: 399,
            currentBet: 1,
          ),
          PlayerModel(
            id: 2,
            name: 'Ned',
            archetype: PlayerArchetype.nit,
            stack: 398,
            currentBet: 2,
          ),
        ],
        mode: GameMode.training,
        street: Street.preflop,
        dealerIndex: 0,
        sbIndex: 1,
        bbIndex: 2,
        highestBet: 2,
        bigBlind: 2,
        smallBlind: 1,
        // Blind posts must not set lastAggressor.
        lastAggressor: null,
        waitingForHero: true,
      );

      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.call, amount: 2),
      );
      expect(grade.villainName, 'Ned');
      expect(grade.villainPosition, 'BB');
      expect(grade.heroPosition, 'BTN');
      expect(grade.villainIsAggressor, isFalse);
      expect(grade.message.toLowerCase(), isNot(contains('when they fire')));

      final prompt = grade.toPrompt(state);
      expect(prompt, contains('Street being graded: PREFLOP'));
      expect(prompt, contains('Ned at BB'));
      expect(prompt, contains('NOT the aggressor'));
      expect(prompt, isNot(contains('voluntary aggressor')));
    });

    test('voluntary raiser is the aggressor with correct seat label', () {
      final state = GameState(
        players: [
          PlayerModel(
            id: 0,
            name: 'Hero',
            archetype: PlayerArchetype.hero,
            stack: 380,
            isHero: true,
            currentBet: 0,
            holeCards: [_c('Ac'), _c('9s')],
          ),
          PlayerModel(
            id: 1,
            name: 'Sammy',
            archetype: PlayerArchetype.lag,
            stack: 370,
            currentBet: 25.5,
          ),
          PlayerModel(
            id: 2,
            name: 'Ned',
            archetype: PlayerArchetype.nit,
            stack: 390,
            currentBet: 7.5,
          ),
        ],
        mode: GameMode.training,
        street: Street.flop,
        community: [_c('7d'), _c('7h'), _c('2c')],
        mainPot: 40,
        dealerIndex: 0,
        sbIndex: 1,
        bbIndex: 2,
        highestBet: 25.5,
        bigBlind: 2,
        lastAggressor: 1,
        waitingForHero: true,
      );

      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.call, amount: 25.5),
      );
      expect(grade.villainName, 'Sammy');
      expect(grade.villainPosition, 'SB');
      expect(grade.villainIsAggressor, isTrue);
      expect(grade.street, Street.flop);

      final prompt = grade.toPrompt(state);
      expect(prompt, contains('Street being graded: FLOP'));
      expect(prompt, contains('Sammy at SB'));
      expect(prompt, contains('voluntary aggressor'));
      expect(prompt, isNot(contains('Ned at BB')));
    });
  });

  group('historical coach feedback', () {
    test('asHistorical scopes a preflop grade so it is not live advice', () {
      const live = CoachFeedback(
        verdict: CoachVerdict.incorrect,
        message: 'Too loose preflop vs Ned.',
        decisionStreet: Street.preflop,
        isHistorical: false,
        repeatCount: 2,
      );
      final hist = live.asHistorical();
      expect(hist.isHistorical, isTrue);
      expect(hist.decisionStreet, Street.preflop);
      expect(hist.isRepeat, isFalse);
      expect(hist.message, contains('preflop'));
    });
  });

  group('later-street free option grades', () {
    GameState checkedTo({
      required Street street,
      required List<CardModel> hole,
      required List<CardModel> board,
      PlayerArchetype villain = PlayerArchetype.tag,
    }) {
      return GameState(
        players: [
          PlayerModel(
            id: 0,
            name: 'Hero',
            archetype: PlayerArchetype.hero,
            stack: 380,
            isHero: true,
            holeCards: hole,
          ),
          PlayerModel(
            id: 1,
            name: 'Ned',
            archetype: villain,
            stack: 380,
            holeCards: [_c('2c'), _c('3d')],
          ),
        ],
        mode: GameMode.training,
        street: street,
        community: board,
        mainPot: 20,
        dealerIndex: 0,
        sbIndex: 0,
        bbIndex: 1,
        highestBet: 0,
        bigBlind: 2,
        waitingForHero: true,
      );
    }

    test('checking ace high on the flop is never punished', () {
      // A stab is marginally better here — most of a TAG's range has missed
      // K-7-2 — but ace high has showdown value and checking gives up almost
      // nothing. A close spot must not be scored as a mistake.
      final state = checkedTo(
        street: Street.flop,
        hole: [_c('Ac'), _c('9s')],
        board: [_c('Kd'), _c('7h'), _c('2c')],
      );
      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.check),
      );
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.isClose, isTrue);
      expect(grade.evDeltaBb.abs(), lessThan(1.0));
      expect(grade.message.toLowerCase(), contains('close'));
    });

    test('betting air on the turn is graded incorrect', () {
      final state = checkedTo(
        street: Street.turn,
        hole: [_c('Ac'), _c('9s')],
        board: [_c('Kd'), _c('7h'), _c('2c'), _c('3s')],
      );
      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.bet, amount: 12),
      );
      expect(grade.verdict, CoachVerdict.incorrect);
      expect(grade.optimalAction, ExploitAction.check);
      expect(grade.mismatch, CoachMismatch.tooAggressive);
    });

    test('value betting two pair on the river is graded correct', () {
      final state = checkedTo(
        street: Street.river,
        hole: [_c('Ac'), _c('Kd')],
        board: [_c('Ah'), _c('Ks'), _c('2c'), _c('7d'), _c('3s')],
      );
      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.bet, amount: 14),
      );
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.optimalAction, ExploitAction.raise);
    });

    test('checking two pair on the river is graded incorrect (too passive)', () {
      final state = checkedTo(
        street: Street.river,
        hole: [_c('Ac'), _c('Kd')],
        board: [_c('Ah'), _c('Ks'), _c('2c'), _c('7d'), _c('3s')],
      );
      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.check),
      );
      expect(grade.verdict, CoachVerdict.incorrect);
      expect(grade.optimalAction, ExploitAction.raise);
      expect(grade.mismatch, CoachMismatch.tooPassive);
    });

    test('probing a nit on the turn with top pair is not punished', () {
      // Thin value against a range full of better aces. Betting and checking
      // are within a fraction of a big blind of each other, and which one
      // edges it moves with any tuning — so the contract is that the player is
      // not marked wrong either way, not that one of them wins.
      final state = checkedTo(
        street: Street.turn,
        hole: [_c('Ac'), _c('9s')],
        board: [_c('Ad'), _c('7h'), _c('2c'), _c('3s')],
        villain: PlayerArchetype.nit,
      );
      final grade = LiveCoach.grade(
        state: state,
        action: const PokerAction(type: PokerActionType.bet, amount: 12),
      );
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.evDeltaBb.abs(), lessThan(1.0));
      expect(grade.heroClass, HandClass.topPair);
    });
  });
}
