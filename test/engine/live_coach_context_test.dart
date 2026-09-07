/// LiveCoach context: position + aggressor grounding for Claude prompts.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';

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
}
