/// Golden spots the coach must get right, and guardrails it must never cross.
///
/// These are the contract. Tuning the opponent frequencies or the EV model is
/// fine; breaking one of these is not. Each case is a decision whose answer is
/// settled by arithmetic or by the plainest poker judgement, so a failure here
/// means the coach has started giving advice a player would rightly ignore.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/engine/decision_ev.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

CardModel _c(String code) => CardModel.fromCode(code);

List<CardModel> _cards(String codes) =>
    codes.isEmpty ? const [] : codes.split(' ').map(_c).toList();

/// One opponent in a constructed spot.
class Opponent {
  const Opponent(
    this.name,
    this.archetype, {
    this.bet = 0,
    this.stack = 400,
    this.acted = false,
  });

  final String name;
  final PlayerArchetype archetype;
  final double bet;
  final double stack;
  final bool acted;
}

/// Builds a hero decision. [aggressorIndex] is an index into [villains].
GameState spot({
  required String hero,
  String board = '',
  required List<Opponent> villains,
  Street street = Street.flop,
  double deadPot = 0,
  double heroStack = 400,
  double heroBet = 0,
  double bigBlind = 2,
  int? aggressorIndex,
}) {
  final highest = villains.fold<double>(
    heroBet,
    (m, v) => v.bet > m ? v.bet : m,
  );
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: heroStack,
        isHero: true,
        currentBet: heroBet,
        holeCards: _cards(hero),
      ),
      for (var i = 0; i < villains.length; i++)
        PlayerModel(
          id: i + 1,
          name: villains[i].name,
          archetype: villains[i].archetype,
          stack: villains[i].stack,
          currentBet: villains[i].bet,
          hasActedThisRound: villains[i].acted,
        ),
    ],
    mode: GameMode.training,
    street: street,
    community: _cards(board),
    mainPot: deadPot,
    dealerIndex: villains.length,
    sbIndex: 1,
    bbIndex: 0,
    highestBet: highest,
    bigBlind: bigBlind,
    lastAggressor: aggressorIndex == null ? null : aggressorIndex + 1,
    waitingForHero: true,
  );
}

LiveCoachGrade gradeFold(GameState s) =>
    LiveCoach.grade(state: s, action: const PokerAction(type: PokerActionType.fold));

LiveCoachGrade gradeCall(GameState s) => LiveCoach.grade(
      state: s,
      action: PokerAction(
        type: PokerActionType.call,
        amount: s.callAmountFor(s.hero),
      ),
    );

LiveCoachGrade gradeCheck(GameState s) => LiveCoach.grade(
      state: s,
      action: const PokerAction(type: PokerActionType.check),
    );

LiveCoachGrade gradeBet(GameState s, double amount) => LiveCoach.grade(
      state: s,
      action: PokerAction(type: PokerActionType.bet, amount: amount),
    );

void main() {
  group('the spot that started this: 32o bottom pair versus a LAG c-bet', () {
    // Hero holds 3d 2h on Qd 3s 5d and faces $21.50 into $39 from Sammy.
    GameState build({required bool multiway}) => spot(
          hero: '3d 2h',
          board: 'Qd 3s 5d',
          deadPot: 17.5,
          heroStack: 1591,
          villains: [
            const Opponent('Sammy', PlayerArchetype.lag, bet: 21.5, acted: true),
            if (multiway) const Opponent('Alex', PlayerArchetype.tag, stack: 2303),
            if (multiway) const Opponent('Viktor', PlayerArchetype.maniac, stack: 320),
          ],
          aggressorIndex: 0,
        );

    test('heads-up the call is right, because bottom pair beats a wide c-bet',
        () {
      final grade = gradeCall(build(multiway: false));
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.optimalAction, ExploitAction.call);
      expect(grade.equityPercent, greaterThan(grade.requiredEquityPercent));
      // The advice has to be checkable, not asserted.
      expect(grade.message, contains('%'));
      expect(grade.message, contains('\$21.50'));
    });

    test('multiway the same call is a fold — the old coach could not tell', () {
      final grade = gradeFold(build(multiway: true));
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.optimalAction, ExploitAction.fold);
      expect(grade.equityPercent, lessThan(grade.requiredEquityPercent));
    });

    test('extra opponents strictly reduce hero equity', () {
      expect(
        gradeFold(build(multiway: true)).equityPercent,
        lessThan(gradeFold(build(multiway: false)).equityPercent),
      );
    });
  });

  group('price decides, not the read', () {
    // The Leak Finder tells players that folding and calling can both be
    // mistakes against the same opponent. That has to actually be true.
    GameState atPrice(double bet) => spot(
          hero: '3d 2h',
          board: 'Qd 3s 5d',
          deadPot: 17.5,
          heroStack: 1591,
          villains: [
            Opponent('Sammy', PlayerArchetype.lag, bet: bet, acted: true, stack: 1591),
          ],
          aggressorIndex: 0,
        );

    test('a cheap stab from the same LAG is a call', () {
      final grade = gradeCall(atPrice(5));
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.optimalAction, isNot(ExploitAction.fold));
    });

    test('a huge overbet from the same LAG with the same hand is a fold', () {
      final grade = gradeFold(atPrice(160));
      expect(grade.optimalAction, ExploitAction.fold);
      expect(grade.verdict, CoachVerdict.correct);
    });

    test('the equity a call needs is exactly its pot odds', () {
      for (final bet in [5.0, 21.5, 60.0, 160.0]) {
        final state = atPrice(bet);
        final grade = gradeFold(state);
        final pot = state.totalPot;
        final call = state.callAmountFor(state.hero);
        expect(
          grade.requiredEquityPercent,
          (call / (pot + call) * 100).round(),
          reason: 'pot odds must be arithmetic, not a threshold, at $bet',
        );
      }
    });
  });

  group('archetype changes the answer in the right direction', () {
    GameState versus(PlayerArchetype archetype) => spot(
          hero: '3d 2h',
          board: 'Qd 3s 5d',
          deadPot: 17.5,
          heroStack: 400,
          villains: [
            Opponent('Villain', archetype, bet: 21.5, acted: true),
          ],
          aggressorIndex: 0,
        );

    test('a nit betting the same amount gets more respect than a LAG', () {
      final vsNit = gradeFold(versus(PlayerArchetype.nit));
      final vsLag = gradeFold(versus(PlayerArchetype.lag));
      expect(
        vsNit.equityPercent,
        lessThan(vsLag.equityPercent),
        reason: 'a nit bets a stronger range, so hero must have less equity',
      );
      expect(vsNit.optimalAction, ExploitAction.fold);
      expect(vsNit.reasonCodes, isNotEmpty);
      expect(
        vsNit.reasonCodes,
        anyOf(
          contains(CoachReasonCode.dontPayOffNits),
          contains(CoachReasonCode.foldWhenPriceWrong),
        ),
      );
    });
  });

  group('hands whose answer is not a matter of opinion', () {
    test('the nut straight on the river is never checked or folded', () {
      final state = spot(
        hero: '9h 8h',
        board: 'Qc Js Th 4d 2s',
        street: Street.river,
        deadPot: 60,
        villains: [const Opponent('Alex', PlayerArchetype.tag, acted: true)],
      );
      final checking = gradeCheck(state);
      expect(checking.verdict, CoachVerdict.incorrect);
      expect(checking.optimalAction, ExploitAction.raise);
      expect(checking.mismatch, CoachMismatch.tooPassive);
      expect(checking.equityPercent, greaterThan(95));
    });

    test('drawing dead on the river is a fold', () {
      // Hero holds the worst possible pair against a board that has a
      // four-card straight flush on it and a villain who has bet big.
      final state = spot(
        hero: '2c 2d',
        board: 'Kh Qh Jh Th 3s',
        street: Street.river,
        deadPot: 40,
        villains: [
          const Opponent('Stan', PlayerArchetype.nit, bet: 40, acted: true),
        ],
        aggressorIndex: 0,
      );
      final grade = gradeFold(state);
      expect(grade.optimalAction, ExploitAction.fold);
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.equityIsExact, isTrue, reason: 'the river enumerates');
    });

    test('aces preflop are never folded to a raise', () {
      final state = spot(
        hero: 'As Ah',
        street: Street.preflop,
        heroBet: 2,
        deadPot: 1,
        villains: [
          const Opponent('Sammy', PlayerArchetype.lag, bet: 8, acted: true),
        ],
        aggressorIndex: 0,
      );
      expect(gradeFold(state).verdict, CoachVerdict.incorrect);
      expect(gradeFold(state).optimalAction, isNot(ExploitAction.fold));
    });
  });

  group('guardrails', () {
    test('never recommends a wildly oversized bet when stacks are deep', () {
      // Two pair on the river with a thousand big blinds behind. A one-street
      // model left unchecked will happily suggest shoving nineteen pots.
      final state = spot(
        hero: 'Ac Kd',
        board: 'Ah Ks 2c 7d 3s',
        street: Street.river,
        deadPot: 20,
        heroStack: 2000,
        villains: [const Opponent('Alex', PlayerArchetype.tag, stack: 2000)],
      );
      final grade = gradeCheck(state);
      final recommendedChips = grade.optimalSizingBb * state.bigBlind;
      expect(
        recommendedChips,
        lessThanOrEqualTo(
          state.totalPot * DecisionModel.maxRecommendedPotMultiple + 0.01,
        ),
        reason: 'a recommendation nobody would make destroys trust',
      );
    });

    test('a good value bet is not marked wrong for being a size off', () {
      final state = spot(
        hero: 'Ac Kd',
        board: 'Ah Ks 2c 7d 3s',
        street: Street.river,
        deadPot: 20,
        villains: [const Opponent('Alex', PlayerArchetype.tag)],
      );
      final grade = gradeBet(state, 14);
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.message.toLowerCase(), contains('bb'));
    });

    test('hopeless air is never turned into a bluff against a station', () {
      final state = spot(
        hero: '3h 2s',
        board: 'Ad Kh Qc',
        deadPot: 20,
        villains: [const Opponent('Fred', PlayerArchetype.callingStation)],
      );
      final grade = gradeCheck(state);
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.optimalAction, ExploitAction.check);
      expect(grade.reasonCodes, contains(CoachReasonCode.neverBluffStations));
      expect(
        grade.message,
        contains(CoachReasonCode.neverBluffStations.phrase),
      );
    });
  });

  group('the EV number is a real expected value', () {
    test('the best line costs exactly nothing', () {
      final state = spot(
        hero: '3d 2h',
        board: 'Qd 3s 5d',
        deadPot: 17.5,
        heroStack: 1591,
        villains: [
          const Opponent('Sammy', PlayerArchetype.lag, bet: 21.5, acted: true),
        ],
        aggressorIndex: 0,
      );
      final grade = gradeCall(state);
      expect(grade.verdict, CoachVerdict.correct);
      expect(grade.evDeltaBb, 0);
    });

    test('a mistake costs a negative amount that depends on the hand', () {
      // The old grader charged a flat 12% of whatever was faced, so these two
      // folds — identical price, wildly different hands — scored the same.
      GameState withHand(String hero) => spot(
            hero: hero,
            board: 'Qd 3s 5d',
            deadPot: 17.5,
            heroStack: 400,
            villains: [
              const Opponent('Sammy', PlayerArchetype.lag, bet: 21.5, acted: true),
            ],
            aggressorIndex: 0,
          );

      final foldingASet = gradeFold(withHand('3c 3h'));
      final foldingBottomPair = gradeFold(withHand('3d 2h'));

      expect(foldingASet.evDeltaBb, lessThan(0));
      expect(foldingBottomPair.evDeltaBb, lessThan(0));
      expect(
        foldingASet.evDeltaBb,
        lessThan(foldingBottomPair.evDeltaBb),
        reason: 'folding a set must cost strictly more than folding a weak pair',
      );
      expect(
        foldingASet.callAmount,
        foldingBottomPair.callAmount,
        reason: 'same price, so any shared EV would prove it is a constant',
      );
    });
  });

  group('consistency', () {
    test('grading the same decision repeatedly never changes the answer', () {
      GameState build() => spot(
            hero: '9d 8d',
            board: 'Qd 3s 5d',
            deadPot: 17.5,
            heroStack: 400,
            villains: [
              const Opponent('Sammy', PlayerArchetype.lag, bet: 21.5, acted: true),
              const Opponent('Alex', PlayerArchetype.tag),
            ],
            aggressorIndex: 0,
          );

      final grades = [for (var i = 0; i < 5; i++) gradeCall(build())];
      for (final g in grades) {
        expect(g.verdict, grades.first.verdict);
        expect(g.optimalAction, grades.first.optimalAction);
        expect(g.evDeltaBb, grades.first.evDeltaBb);
        expect(g.equityPercent, grades.first.equityPercent);
      }
    });
  });
}
