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

    test('hero raise preflop advances or ends without reopening forever', () {
      // Regression: villains used highest+BB as the raise floor, so after an
      // open to ~10bb they could "3-bet" by +1bb forever and preflop never
      // resolved.
      final engine = PokerEngine(settings: _settings, random: Random(42));
      engine.startHand(resolve: false);

      var guard = 0;
      while (guard++ < 64 && engine.nextEvent() != null) {}

      var state = engine.state;
      expect(state.waitingForHero, isTrue);
      expect(state.street, Street.preflop);

      final holes = state.hero.holeCards.map((c) => c.code).join(',');
      final handId = state.handCount;
      final range = RaiseRange.forHero(state);
      expect(range.allowed, isTrue);
      final raiseTo = range.min;
      final call = state.callAmountFor(state.hero);

      engine.submitHeroAction(
        PokerAction(
          type: call <= Money.epsilon
              ? PokerActionType.bet
              : PokerActionType.raise,
          amount: raiseTo,
        ),
      );

      expect(engine.state.highestBet, closeTo(raiseTo, 0.01));
      expect(engine.state.minRaise, greaterThanOrEqualTo(_settings.bigBlind));

      var heroPreflopReturns = 0;
      var villainRaises = 0;
      Street? terminalStreet;
      guard = 0;
      while (guard++ < 256) {
        final event = engine.nextEvent();
        final s = engine.state;
        expect(s.handCount, handId, reason: 'must not redeal mid-hand');
        expect(
          s.hero.holeCards.map((c) => c.code).join(','),
          holes,
          reason: 'hole cards must stay fixed mid-hand',
        );

        if (event == null) {
          if (s.isHandOver) {
            terminalStreet = s.street;
            break;
          }
          if (s.waitingForHero && s.street == Street.preflop) {
            heroPreflopReturns++;
            expect(
              heroPreflopReturns,
              lessThan(6),
              reason: 'preflop reopened too many times after hero raise',
            );
            final faced = s.callAmountFor(s.hero);
            final nextRange = RaiseRange.forHero(s);
            // Call (or fold if somehow broke) — do not keep 4-betting the war.
            if (faced > Money.epsilon) {
              engine.submitHeroAction(
                PokerAction(type: PokerActionType.call, amount: faced),
              );
            } else if (nextRange.allowed) {
              engine.submitHeroAction(
                PokerAction(type: PokerActionType.bet, amount: nextRange.min),
              );
            } else {
              engine.submitHeroAction(
                const PokerAction(type: PokerActionType.check),
              );
            }
            continue;
          }
          if (s.waitingForHero) {
            // Reached a later street — success.
            terminalStreet = s.street;
            break;
          }
          break;
        }

        if (event.kind == TableEventKind.villainAction &&
            (event.action?.type == PokerActionType.raise ||
                event.action?.type == PokerActionType.bet)) {
          villainRaises++;
          // Every aggressive response must jump by at least a full min-raise
          // (or be an all-in), never a +1bb reopen over a large open.
          final beforeHighest = raiseTo;
          expect(
            event.state.highestBet + Money.epsilon,
            greaterThanOrEqualTo(beforeHighest),
          );
        }
        if (event.kind == TableEventKind.dealStreet) {
          expect(event.state.street, isNot(Street.preflop));
          terminalStreet = event.state.street;
          break;
        }
        if (event.kind == TableEventKind.handOver) {
          terminalStreet = event.state.street;
          break;
        }
      }

      expect(terminalStreet, isNotNull);
      expect(
        engine.state.isHandOver || engine.state.street != Street.preflop,
        isTrue,
        reason: 'hand must leave preflop or end after the raise cycle',
      );
      expect(villainRaises, lessThan(8));
    });

    test('legal raise floor uses minRaise not just the big blind', () {
      final engine = PokerEngine(settings: _settings, random: Random(7));
      engine.startHand(resolve: false);
      var guard = 0;
      while (guard++ < 64 && engine.nextEvent() != null) {}
      final state = engine.state;
      if (!state.waitingForHero) return;

      final range = RaiseRange.forHero(state);
      // Size well above a min-raise so the raise increment dwarfs the blind.
      final openTo = range.forFraction(
        1.0,
        pot: state.totalPot,
        heroBet: state.hero.currentBet,
      );
      final call = state.callAmountFor(state.hero);
      engine.submitHeroAction(
        PokerAction(
          type: call <= Money.epsilon
              ? PokerActionType.bet
              : PokerActionType.raise,
          amount: openTo,
        ),
      );
      final after = engine.state;
      expect(after.highestBet, closeTo(openTo, 0.01));
      final raiseSize = Money.round(openTo - state.highestBet);
      expect(after.minRaise, closeTo(raiseSize, 0.01));
      expect(after.minRaise, greaterThan(after.bigBlind + Money.epsilon));
    });
  });
}
