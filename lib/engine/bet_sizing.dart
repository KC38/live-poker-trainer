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

  /// A pot-fraction sizing clamped into the legal range.
  ///
  /// [pot] is the total pot including bets already on the street, so
  /// `fraction * pot` is a classic "bet 2/3 pot" sizing.
  double forFraction(double fraction, {required double pot, required double heroBet}) {
    return clamp(pot * fraction + heroBet);
  }
}
