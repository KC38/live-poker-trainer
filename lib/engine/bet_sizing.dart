/// Legal bet / raise range math for the hero action dock.
library;

import 'dart:math' as math;

import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/models/game_state.dart';

/// The legal aggressive-action range for a player on the current street.
///
/// All amounts are *total bet on this street* (i.e. "raise to"), matching
/// [PokerAction.amount].
class RaiseRange {
  /// Creates a raise range.
  const RaiseRange({
    required this.min,
    required this.max,
    required this.allowed,
    required this.isAllInOnly,
  });

  /// Lowest legal "raise to" amount. Equals [max] when only all-in is legal.
  final double min;

  /// Highest legal "raise to" amount (hero all-in total).
  final double max;

  /// Whether any bet / raise is legal at all.
  final bool allowed;

  /// Whether a full min-raise is unaffordable, leaving all-in as the only
  /// aggressive option.
  final bool isAllInOnly;

  /// Whether the range has room for the user to pick a size.
  bool get hasSpread => allowed && max - min > Money.epsilon;

  /// Computes the hero's legal range for [game].
  ///
  /// Short stacks are the interesting case: when the hero cannot cover a full
  /// min-raise, the range collapses to a single all-in amount instead of
  /// producing an inverted `min > max` range.
  static RaiseRange forHero(GameState game) {
    final hero = game.hero;
    final maxTo = Money.roundNonNegative(hero.stack + hero.currentBet);
    final increment = math.max(game.minRaise, game.bigBlind);
    final desiredMin = Money.roundNonNegative(game.highestBet + increment);

    // Cannot put in more than the current bet — no aggression available.
    if (maxTo <= game.highestBet + Money.epsilon) {
      return RaiseRange(
        min: maxTo,
        max: maxTo,
        allowed: false,
        isAllInOnly: false,
      );
    }

    if (desiredMin >= maxTo - Money.epsilon) {
      // A full min-raise is unaffordable (or exactly all-in): all-in only.
      return RaiseRange(
        min: maxTo,
        max: maxTo,
        allowed: true,
        isAllInOnly: true,
      );
    }

    return RaiseRange(
      min: desiredMin,
      max: maxTo,
      allowed: true,
      isAllInOnly: false,
    );
  }

  /// Clamps [amount] into this range, safe against inverted / NaN input.
  double clamp(double amount) => Money.clamp(Money.round(amount), min, max);

  /// Snaps [amount] onto a 1-BB grid measured from [min].
  ///
  /// Used by the bet/raise slider so each thumb movement changes the size by
  /// one big blind. [min] and [max] stay reachable so the legal min-raise and
  /// all-in are never lost when they are not exact BB multiples past [min].
  double snapToBb(double amount, double bigBlind) {
    if (!allowed) return clamp(amount);
    final bb = bigBlind > Money.epsilon ? bigBlind : 1.0;
    final clamped = clamp(amount);
    if (!hasSpread) return clamped;
    if (Money.same(clamped, min)) return min;
    if (Money.same(clamped, max)) return max;

    final maxSteps = ((max - min) / bb).floor();
    final rawSteps = ((clamped - min) / bb).round().clamp(0, maxSteps);
    final gridAmount = clamp(Money.round(min + rawSteps * bb));

    // When all-in sits between BB ticks, treat it as an extra stop and pick
    // whichever of {grid, max} is closer to the thumb.
    if ((clamped - max).abs() <= (clamped - gridAmount).abs() + Money.epsilon) {
      return max;
    }
    return gridAmount;
  }

  /// A pot-fraction sizing clamped into the legal range.
  ///
  /// [pot] is the total pot including bets already on the street, so
  /// `fraction * pot` is a classic "bet 2/3 pot" sizing.
  double forFraction(double fraction, {required double pot, required double heroBet}) {
    return clamp(pot * fraction + heroBet);
  }
}
