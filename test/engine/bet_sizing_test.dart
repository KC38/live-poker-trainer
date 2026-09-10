/// Tests for hero raise-range math, including the short-stack crash case.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/bet_sizing.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';

GameState _state({
  required double heroStack,
  required double heroBet,
  required double highestBet,
  double minRaise = 2,
  double bigBlind = 2,
}) {
  return GameState(
    players: [
      PlayerModel(
        id: 0,
        name: 'Hero',
        archetype: PlayerArchetype.hero,
        stack: heroStack,
        isHero: true,
        currentBet: heroBet,
      ),
      PlayerModel(
        id: 1,
        name: 'Viktor',
        archetype: PlayerArchetype.maniac,
        stack: 500,
        currentBet: highestBet,
      ),
    ],
    mode: GameMode.training,
    highestBet: highestBet,
    minRaise: minRaise,
    bigBlind: bigBlind,
    smallBlind: bigBlind / 2,
  );
}

void main() {
  group('RaiseRange.forHero', () {
    test('normal stack gets a usable spread above the min raise', () {
      final range = RaiseRange.forHero(
        _state(heroStack: 400, heroBet: 0, highestBet: 20),
      );
      expect(range.allowed, isTrue);
      expect(range.isAllInOnly, isFalse);
      expect(range.min, 22);
      expect(range.max, 400);
      expect(range.hasSpread, isTrue);
    });

    test('short stack that cannot min-raise collapses to all-in only', () {
      // Reproduces "Invalid argument(s): 451.0": highestBet 449 + minRaise 2
      // gives a min-raise-to of 451 while the hero can only reach 450, so the
      // old `clamp(451, 450)` threw ArgumentError(451.0) during build.
      final range = RaiseRange.forHero(
        _state(heroStack: 450, heroBet: 0, highestBet: 449),
      );
      expect(range.allowed, isTrue);
      expect(range.isAllInOnly, isTrue);
      expect(range.min, 450);
      expect(range.max, 450);
      expect(range.hasSpread, isFalse);
      expect(range.clamp(999), 450);
      expect(range.clamp(0), 450);
    });

    test('hero stack short of the current bet cannot raise at all', () {
      final range = RaiseRange.forHero(
        _state(heroStack: 400, heroBet: 0, highestBet: 449),
      );
      expect(range.allowed, isFalse);
      expect(range.hasSpread, isFalse);
    });

    test('hero already covered by the bet cannot raise at all', () {
      final range = RaiseRange.forHero(
        _state(heroStack: 0, heroBet: 100, highestBet: 200),
      );
      expect(range.allowed, isFalse);
      expect(range.hasSpread, isFalse);
    });

    test('pot fraction sizing always lands inside the legal range', () {
      final range = RaiseRange.forHero(
        _state(heroStack: 60, heroBet: 10, highestBet: 40),
      );
      for (final fraction in [1 / 3, 0.5, 0.75, 1.0, 4.0]) {
        final amount =
            range.forFraction(fraction, pot: 500, heroBet: 10);
        expect(amount, greaterThanOrEqualTo(range.min));
        expect(amount, lessThanOrEqualTo(range.max));
      }
    });

    test('sizing is rounded to whole cents', () {
      final range = RaiseRange.forHero(
        _state(heroStack: 1000, heroBet: 0, highestBet: 10),
      );
      final amount = range.forFraction(1 / 3, pot: 100, heroBet: 0);
      expect(amount, 33.33);
    });
  });

  group('RaiseRange.snapToBb', () {
    test('slider movement snaps to whole-BB steps from the min raise', () {
      final range = RaiseRange.forHero(
        _state(heroStack: 400, heroBet: 0, highestBet: 20, bigBlind: 2),
      );
      // Min raise-to is 22; each step adds 1 BB ($2).
      expect(range.snapToBb(22.4, 2), 22);
      expect(range.snapToBb(23.1, 2), 24);
      expect(range.snapToBb(25.9, 2), 26);
      expect(range.snapToBb(30, 2), 30);
    });

    test('all-in remains reachable when max is off the BB grid', () {
      final range = RaiseRange.forHero(
        _state(heroStack: 397, heroBet: 0, highestBet: 20, bigBlind: 2),
      );
      expect(range.max, 397);
      expect(range.snapToBb(396.5, 2), 397);
      expect(range.snapToBb(range.max, 2), 397);
    });

    test('min raise stays selectable', () {
      final range = RaiseRange.forHero(
        _state(heroStack: 400, heroBet: 0, highestBet: 20, bigBlind: 2),
      );
      expect(range.snapToBb(range.min, 2), range.min);
      expect(range.snapToBb(range.min + 0.4, 2), range.min);
    });
  });
}
