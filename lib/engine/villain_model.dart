/// How each archetype acts with each class of hand.
///
/// This is the behavioural half of the opponent model. The chart says which
/// hands an archetype shows up with; this says what they *do* with them, which
/// is what lets the coach narrow a range from an observed bet instead of
/// treating "vs a LAG" as a lookup key for a fixed threshold.
///
/// Every number is a deliberate, editable estimate of a live-player tendency,
/// not a solver output. They are collected in one table so that tuning the
/// coach means editing frequencies here rather than hunting constants through
/// the grader.
library;

import 'dart:math';

import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// One archetype's action frequencies with one class of hand.
class ActionProfile {
  /// Creates a profile.
  const ActionProfile({
    required this.bet,
    required this.call,
    required this.raise,
  });

  /// Probability of betting when checked to, or leading out.
  final double bet;

  /// Probability of calling a roughly half-pot bet.
  final double call;

  /// Probability of raising a roughly half-pot bet.
  final double raise;
}

/// Action frequencies keyed by archetype and [HandClass].
class VillainModel {
  VillainModel._();

  /// Bet size, as a fraction of pot, that the raw table numbers describe.
  /// Sizes either side of this are adjusted rather than taken literally.
  static const double referenceBetToPot = 0.5;

  /// Probability [archetype] bets [handClass] for [betToPot] of the pot.
  ///
  /// Bigger bets are more polarised: medium-strength hands check more as the
  /// size grows, while air bluffs slightly more often.
  static double betFrequency(
    PlayerArchetype archetype,
    HandClass handClass, {
    double betToPot = referenceBetToPot,
  }) {
    final base = profileFor(archetype, handClass).bet;
    final excess = betToPot - 0.6;
    // Polarisation cuts both ways. As the size grows, the medium hands drop
    // out and *both* tails bet more — the bluffs and the monsters. Lifting
    // only the air tail would tell the coach that the bigger someone bets the
    // weaker they are, which is backwards and invites a hero re-raise with
    // nothing.
    final polarisation = switch (handClass) {
      HandClass.air => _bluffTail(excess, 0.20),
      HandClass.weakDraw => _bluffTail(excess, 0.10),
      HandClass.strongDraw => 1.0,
      HandClass.weakPair => 1.0 - 0.55 * excess,
      HandClass.topPair => 1.0 - 0.30 * excess,
      HandClass.strongMade => 1.0 + 0.15 * excess,
      HandClass.monster => 1.0 + 0.25 * excess,
    };
    return (base * polarisation.clamp(0.25, 1.6)).clamp(0.0, 1.0);
  }

  /// Probability [archetype] calls a bet costing [priceToPot] of the pot.
  ///
  /// Weak holdings are far more price-sensitive than strong ones. The response
  /// to size has to fall away steeply rather than linearly: against a huge
  /// overbet a real player continues with close to the nuts and nothing else,
  /// and a model that merely tapers linearly will happily believe a solid
  /// regular calls off twenty pots with second-best two pair. That belief is
  /// worth an enormous amount of fake expected value to any overbet, and it
  /// is exactly how a coach ends up recommending an absurd shove.
  static double callFrequency(
    PlayerArchetype archetype,
    HandClass handClass, {
    double priceToPot = referenceBetToPot,
  }) {
    final base = profileFor(archetype, handClass).call;
    return (base * _sizeFactor(priceToPot, _priceSensitivity(handClass)))
        .clamp(0.0, 1.0);
  }

  /// Probability [archetype] raises a bet costing [priceToPot] of the pot.
  static double raiseFrequency(
    PlayerArchetype archetype,
    HandClass handClass, {
    double priceToPot = referenceBetToPot,
  }) {
    final base = profileFor(archetype, handClass).raise;
    // Raising back is even more size-sensitive than calling: the bigger the
    // bet faced, the smaller the range that can profitably put in more.
    final sensitivity = _priceSensitivity(handClass) * 1.2;
    return (base * _sizeFactor(priceToPot, sensitivity)).clamp(0.0, 1.0);
  }

  /// Bet size at which bluffing peaks, as pot fraction above the reference.
  ///
  /// Around one and a half times the pot. Past that a bluff is risking too
  /// much to win too little for anyone to do it often.
  static const double _bluffPeakExcess = 0.9;

  /// How a bluffing frequency responds to size: up to a peak, then away.
  ///
  /// The rise is the familiar one — bigger bets are more polarised. The fall
  /// matters more, and only shows up at sizes the frequency table was never
  /// built to describe. A model that keeps extrapolating the rise concludes
  /// that the bigger someone fires the weaker they are, and will then happily
  /// advise re-raising a huge overbet with bottom pair. Nobody overbets four
  /// times the pot with air; at that size they are representing the nuts, and
  /// mostly have them.
  static double _bluffTail(double excess, double slope) {
    if (excess <= _bluffPeakExcess) return 1.0 + slope * excess;
    final peak = 1.0 + slope * _bluffPeakExcess;
    return peak - slope * 2.2 * (excess - _bluffPeakExcess);
  }

  /// How sharply this class of hand reacts to the size it is facing.
  static double _priceSensitivity(HandClass handClass) => switch (handClass) {
        HandClass.air => 2.00,
        HandClass.weakDraw => 1.70,
        HandClass.strongDraw => 1.00,
        HandClass.weakPair => 1.30,
        HandClass.topPair => 0.90,
        HandClass.strongMade => 0.35,
        HandClass.monster => 0.08,
      };

  /// Multiplier on a base frequency for facing [priceToPot] instead of the
  /// reference half-pot bet.
  ///
  /// A power law in the ratio of the two sizes, so doubling the bet always
  /// costs the same proportion of the range regardless of where you start.
  static double _sizeFactor(double priceToPot, double sensitivity) {
    final ratio = referenceBetToPot / max(priceToPot, 0.02);
    return pow(ratio, sensitivity).toDouble().clamp(0.0, 2.5);
  }

  /// Probability [archetype] puts more money in rather than folding.
  static double continueFrequency(
    PlayerArchetype archetype,
    HandClass handClass, {
    double priceToPot = referenceBetToPot,
  }) {
    final total =
        callFrequency(archetype, handClass, priceToPot: priceToPot) +
            raiseFrequency(archetype, handClass, priceToPot: priceToPot);
    return total.clamp(0.0, 1.0);
  }

  /// Probability [archetype] folds [handClass] to a bet of [priceToPot].
  static double foldFrequency(
    PlayerArchetype archetype,
    HandClass handClass, {
    double priceToPot = referenceBetToPot,
  }) =>
      1.0 -
      continueFrequency(archetype, handClass, priceToPot: priceToPot);

  /// The raw profile for one archetype and hand class.
  static ActionProfile profileFor(
    PlayerArchetype archetype,
    HandClass handClass,
  ) {
    final table = switch (archetype) {
      PlayerArchetype.nit => _nit,
      PlayerArchetype.callingStation => _station,
      PlayerArchetype.lag => _lag,
      PlayerArchetype.maniac => _maniac,
      // A hero seat modelled as a villain plays like a solid regular.
      PlayerArchetype.tag || PlayerArchetype.hero => _tag,
    };
    return table[handClass]!;
  }

  /// Only plays premiums; a bet means strength and a fold is cheap to buy.
  static const Map<HandClass, ActionProfile> _nit = {
    HandClass.air: ActionProfile(bet: 0.05, call: 0.02, raise: 0.00),
    HandClass.weakDraw: ActionProfile(bet: 0.08, call: 0.12, raise: 0.00),
    HandClass.strongDraw: ActionProfile(bet: 0.25, call: 0.55, raise: 0.03),
    HandClass.weakPair: ActionProfile(bet: 0.20, call: 0.45, raise: 0.01),
    HandClass.topPair: ActionProfile(bet: 0.70, call: 0.85, raise: 0.10),
    HandClass.strongMade: ActionProfile(bet: 0.85, call: 0.95, raise: 0.45),
    HandClass.monster: ActionProfile(bet: 0.90, call: 0.98, raise: 0.75),
  };

  /// Calls far too much, folds almost never, and rarely takes the lead.
  static const Map<HandClass, ActionProfile> _station = {
    HandClass.air: ActionProfile(bet: 0.05, call: 0.30, raise: 0.00),
    HandClass.weakDraw: ActionProfile(bet: 0.06, call: 0.70, raise: 0.00),
    HandClass.strongDraw: ActionProfile(bet: 0.10, call: 0.92, raise: 0.01),
    HandClass.weakPair: ActionProfile(bet: 0.12, call: 0.88, raise: 0.01),
    HandClass.topPair: ActionProfile(bet: 0.25, call: 0.97, raise: 0.03),
    HandClass.strongMade: ActionProfile(bet: 0.40, call: 0.99, raise: 0.10),
    HandClass.monster: ActionProfile(bet: 0.55, call: 0.99, raise: 0.30),
  };

  /// Solid and balanced; the default when a read is unknown.
  static const Map<HandClass, ActionProfile> _tag = {
    HandClass.air: ActionProfile(bet: 0.35, call: 0.08, raise: 0.04),
    HandClass.weakDraw: ActionProfile(bet: 0.40, call: 0.35, raise: 0.06),
    HandClass.strongDraw: ActionProfile(bet: 0.55, call: 0.75, raise: 0.12),
    HandClass.weakPair: ActionProfile(bet: 0.30, call: 0.55, raise: 0.03),
    HandClass.topPair: ActionProfile(bet: 0.70, call: 0.85, raise: 0.15),
    HandClass.strongMade: ActionProfile(bet: 0.80, call: 0.95, raise: 0.50),
    HandClass.monster: ActionProfile(bet: 0.78, call: 0.97, raise: 0.70),
  };

  /// Wide and aggressive: bets a lot of air, but still folds the worst of it.
  static const Map<HandClass, ActionProfile> _lag = {
    HandClass.air: ActionProfile(bet: 0.55, call: 0.15, raise: 0.10),
    HandClass.weakDraw: ActionProfile(bet: 0.60, call: 0.45, raise: 0.14),
    HandClass.strongDraw: ActionProfile(bet: 0.70, call: 0.80, raise: 0.22),
    HandClass.weakPair: ActionProfile(bet: 0.45, call: 0.62, raise: 0.07),
    HandClass.topPair: ActionProfile(bet: 0.75, call: 0.88, raise: 0.20),
    HandClass.strongMade: ActionProfile(bet: 0.82, call: 0.95, raise: 0.55),
    HandClass.monster: ActionProfile(bet: 0.80, call: 0.97, raise: 0.72),
  };

  /// Bets and raises constantly, so a bet carries almost no information.
  static const Map<HandClass, ActionProfile> _maniac = {
    HandClass.air: ActionProfile(bet: 0.75, call: 0.25, raise: 0.20),
    HandClass.weakDraw: ActionProfile(bet: 0.78, call: 0.50, raise: 0.25),
    HandClass.strongDraw: ActionProfile(bet: 0.82, call: 0.82, raise: 0.35),
    HandClass.weakPair: ActionProfile(bet: 0.65, call: 0.70, raise: 0.15),
    HandClass.topPair: ActionProfile(bet: 0.85, call: 0.90, raise: 0.30),
    HandClass.strongMade: ActionProfile(bet: 0.88, call: 0.95, raise: 0.60),
    HandClass.monster: ActionProfile(bet: 0.85, call: 0.97, raise: 0.75),
  };
}
