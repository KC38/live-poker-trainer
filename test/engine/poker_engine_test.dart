/// Engine invariants across many randomized full hands.
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/engine/bet_sizing.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/game_state.dart';

const _settings = GameSettingsModel();

double _chipsInPlay(GameState state) {
  return Money.round(
    state.mainPot +
        state.players.fold<double>(0, (s, p) => s + p.stack + p.currentBet),
  );
}

/// Picks a legal hero action, mixing folds, calls, and raises.
PokerAction _heroAction(GameState state, Random rng) {
  final callAmount = state.callAmountFor(state.hero);
  final range = RaiseRange.forHero(state);
  final roll = rng.nextInt(10);
  if (roll < 3 && range.allowed) {
    return PokerAction(
      type: callAmount <= Money.epsilon
          ? PokerActionType.bet
          : PokerActionType.raise,
      amount: range.forFraction(
        0.75,
        pot: state.totalPot,
        heroBet: state.hero.currentBet,
      ),
    );
  }
  if (callAmount <= Money.epsilon) {
    return const PokerAction(type: PokerActionType.check);
  }
  if (roll < 6) {
    return PokerAction(type: PokerActionType.call, amount: callAmount);
  }
  return const PokerAction(type: PokerActionType.fold);
}

void main() {
  group('PokerEngine full-hand play', () {
    test('plays 200 randomized hands without inconsistent state', () {
      final rng = Random(20260906);
      final engine = PokerEngine(settings: _settings, random: rng);

      for (var hand = 0; hand < 200; hand++) {
        var state = hand == 0
            ? engine.startHand()
            : engine.startHand(existingPlayers: engine.state.players);
        final startingChips = _chipsInPlay(state);

        var guard = 0;
        while (!state.isHandOver && guard < 200) {
          guard++;
          expect(
            state.waitingForHero,
            isTrue,
            reason: 'engine must either finish the hand or wait on the hero',
          );
          expect(state.hero.folded, isFalse);

          // Every legal range offered to the UI must be self-consistent.
          final range = RaiseRange.forHero(state);
          expect(range.min, lessThanOrEqualTo(range.max));

          state = engine.applyHeroAction(_heroAction(state, rng));
        }

        expect(state.isHandOver, isTrue, reason: 'hand $hand never resolved');
        expect(state.waitingForHero, isFalse);
        expect(state.mainPot, 0);
        expect(_chipsInPlay(state), closeTo(startingChips, 0.01));
        for (final p in state.players) {
          expect(p.stack, greaterThanOrEqualTo(0));
          expect(p.currentBet, 0);
        }
      }
    });

    test('hero folding preflop ends the hand immediately', () {
      final engine = PokerEngine(settings: _settings, random: Random(7));
      var state = engine.startHand();
      // Nudge until the hero is actually facing a bet.
      var guard = 0;
      while (state.callAmountFor(state.hero) <= 0 && guard < 20) {
        guard++;
        state = engine.startHand(existingPlayers: state.players);
      }
      state = engine.applyHeroAction(
        const PokerAction(type: PokerActionType.fold),
      );
      expect(state.hero.folded || state.isHandOver, isTrue);
    });

    test('all-in hero never produces a negative stack', () {
      final engine = PokerEngine(settings: _settings, random: Random(99));
      var state = engine.startHand();
      var guard = 0;
      while (!state.isHandOver && guard < 30) {
        guard++;
        state = engine.applyHeroAction(
          const PokerAction(type: PokerActionType.allIn),
        );
      }
      expect(state.isHandOver, isTrue);
      for (final p in state.players) {
        expect(p.stack, greaterThanOrEqualTo(0));
      }
    });

    test('stacks and pots stay cent exact across odd pot splits', () {
      final engine = PokerEngine(
        settings: const GameSettingsModel(smallBlind: 0.5, bigBlind: 1),
        random: Random(1234),
      );
      var state = engine.startHand();
      for (var hand = 0; hand < 40; hand++) {
        var guard = 0;
        while (!state.isHandOver && guard < 200) {
          guard++;
          final callAmount = state.callAmountFor(state.hero);
          state = engine.applyHeroAction(
            callAmount <= Money.epsilon
                ? const PokerAction(type: PokerActionType.check)
                : PokerAction(
                    type: PokerActionType.call,
                    amount: callAmount,
                  ),
          );
        }
        for (final p in state.players) {
          expect(Money.round(p.stack), p.stack);
        }
        state = engine.startHand(existingPlayers: state.players);
      }
    });
  });
}
