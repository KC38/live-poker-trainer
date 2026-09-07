/// Tests the step-wise replay stream that drives the live-table animation.
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

/// Drains the replay stream until the hero must act or the hand is over.
List<TableEvent> _drain(PokerEngine engine) {
  final events = <TableEvent>[];
  var guard = 0;
  while (guard++ < 512) {
    final event = engine.nextEvent();
    if (event == null) break;
    events.add(event);
    if (event.kind == TableEventKind.handOver) break;
  }
  expect(guard, lessThan(512), reason: 'replay stream did not terminate');
  return events;
}

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
        0.7,
        pot: state.totalPot,
        heroBet: state.hero.currentBet,
      ),
    );
  }
  if (callAmount <= Money.epsilon) {
    return const PokerAction(type: PokerActionType.check);
  }
  if (roll < 7) {
    return PokerAction(type: PokerActionType.call, amount: callAmount);
  }
  return const PokerAction(type: PokerActionType.fold);
}

void main() {
  group('replay stream', () {
    test('a fresh deal does not resolve the hand instantly', () {
      final engine = PokerEngine(settings: _settings, random: Random(11));
      final dealt = engine.startHand(resolve: false);

      expect(dealt.isHandOver, isFalse);
      expect(dealt.street, Street.preflop);
      expect(dealt.community, isEmpty);
      // Only the blinds are in; nobody has voluntarily acted yet.
      final voluntary = dealt.players
          .where((p) => (p.lastActionLabel ?? 'BLIND') != 'BLIND')
          .toList();
      expect(voluntary, isEmpty);
      expect(dealt.mainPot, 0);
    });

    test('stops as soon as it is the hero turn', () {
      final engine = PokerEngine(settings: _settings, random: Random(12));
      engine.startHand(resolve: false);
      _drain(engine);

      final state = engine.state;
      if (!state.isHandOver) {
        expect(state.waitingForHero, isTrue);
        // The next pull yields nothing while the hero owes an action.
        expect(engine.nextEvent(), isNull);
      }
    });

    test('villain actions arrive one event at a time', () {
      final engine = PokerEngine(settings: _settings, random: Random(13));
      engine.startHand(resolve: false);
      final events = _drain(engine);

      final villainEvents =
          events.where((e) => e.kind == TableEventKind.villainAction).toList();
      expect(villainEvents, isNotEmpty);
      for (final event in villainEvents) {
        expect(event.action, isNotNull);
        expect(event.seatIndex, isNotNull);
        expect(event.state.players[event.seatIndex!].isHero, isFalse);
      }
    });

    test('board cards are revealed street by street, after chips collect', () {
      final rng = Random(14);
      final engine = PokerEngine(settings: _settings, random: rng);
      engine.startHand(resolve: false);

      final boardSizes = <int>[];
      var guard = 0;

      while (guard++ < 200) {
        final events = _drain(engine);
        for (final event in events) {
          if (event.kind != TableEventKind.dealStreet) continue;
          boardSizes.add(event.state.community.length);
          expect(
            event.state.players.every((p) => p.currentBet <= Money.epsilon),
            isTrue,
            reason: 'street dealt while chips were still in front of seats',
          );
        }
        final state = engine.state;
        if (state.isHandOver) break;
        if (state.waitingForHero) {
          // Always continue so the hand reaches later streets.
          final call = state.callAmountFor(state.hero);
          engine.submitHeroAction(
            call <= Money.epsilon
                ? const PokerAction(type: PokerActionType.check)
                : PokerAction(type: PokerActionType.call, amount: call),
          );
        }
      }

      expect(boardSizes, isNotEmpty);
      // Flop first (3), then turn (4), then river (5) — never out of order.
      expect(boardSizes, orderedEquals(boardSizes.toList()..sort()));
      expect(boardSizes.first, 3);
      for (var i = 1; i < boardSizes.length; i++) {
        expect(boardSizes[i] - boardSizes[i - 1], 1);
      }
    });

    test('120 replayed hands conserve chips and always terminate', () {
      final rng = Random(20260906);
      final engine = PokerEngine(settings: _settings, random: rng);

      for (var hand = 0; hand < 120; hand++) {
        final dealt = hand == 0
            ? engine.startHand(resolve: false)
            : engine.startHand(
                existingPlayers: engine.state.players,
                resolve: false,
              );
        final startingChips = _chipsInPlay(dealt);

        var guard = 0;
        while (guard++ < 200) {
          final events = _drain(engine);
          for (final event in events) {
            final chips = _chipsInPlay(event.state);
            expect(
              chips,
              closeTo(startingChips, 0.01),
              reason: 'chips leaked mid-replay on hand $hand',
            );
            for (final p in event.state.players) {
              expect(p.stack, greaterThanOrEqualTo(-Money.epsilon));
            }
          }
          final state = engine.state;
          if (state.isHandOver) break;
          if (state.waitingForHero) {
            engine.submitHeroAction(_heroAction(state, rng));
          }
        }

        expect(guard, lessThan(200), reason: 'hand $hand never finished');
        final finished = engine.state;
        expect(finished.isHandOver, isTrue);
        expect(finished.resultMessage, isNotNull);
        expect(
          _chipsInPlay(finished),
          closeTo(startingChips, 0.01),
          reason: 'chips leaked on hand $hand',
        );
      }
    });

    test('a hero fold ends the hand through the replay stream', () {
      final engine = PokerEngine(settings: _settings, random: Random(15));
      engine.startHand(resolve: false);
      _drain(engine);

      final state = engine.state;
      if (state.isHandOver) return;
      engine.submitHeroAction(const PokerAction(type: PokerActionType.fold));
      final events = _drain(engine);

      expect(engine.state.hero.folded, isTrue);
      expect(engine.state.isHandOver, isTrue);
      expect(
        events.isEmpty || events.last.kind == TableEventKind.handOver,
        isTrue,
      );
    });

    test('runToHeroOrEnd matches the stepwise replay result', () {
      // Same lineup and same deck seed in both engines, so the only variable
      // is whether the villains are stepped or drained.
      final lineup = PokerEngine.buildLineup(
        settings: _settings,
        random: Random(16),
      );

      final fast = PokerEngine(settings: _settings, random: Random(16));
      fast.startHand(existingPlayers: lineup, dealerIndex: 0, resolve: false);
      fast.runToHeroOrEnd();

      final stepped = PokerEngine(settings: _settings, random: Random(16));
      stepped.startHand(
        existingPlayers: lineup,
        dealerIndex: 0,
        resolve: false,
      );
      _drain(stepped);

      expect(fast.state.street, stepped.state.street);
      expect(fast.state.totalPot, closeTo(stepped.state.totalPot, 0.01));
      expect(fast.state.isHandOver, stepped.state.isHandOver);
    });
  });
}
