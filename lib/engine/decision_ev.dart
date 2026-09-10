/// Expected-value model for a single hero decision.
///
/// Every line the coach can recommend is priced in chips against the same
/// baseline — folding is worth zero, and everything else is worth what it wins
/// from the pot minus what it costs to find out. The recommendation is then
/// simply the highest number, and the size of a mistake is the gap between two
/// numbers rather than a constant.
///
/// The model is one street deep: it prices the current decision against the
/// range in front of it and the cards still to come, but it does not solve the
/// betting that follows. That approximation is handled honestly rather than
/// hidden — [DecisionAnalysis.margin] carries how far apart the top two lines
/// are, and the grader refuses to call a decision wrong when that gap is
/// inside the model's own uncertainty.
library;

import 'dart:math';

import 'package:live_poker_trainer/engine/equity.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/engine/hand_range.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// One opponent as the decision model sees them.
class VillainView {
  /// Creates a villain view.
  const VillainView({
    required this.archetype,
    required this.name,
    required this.position,
    required this.range,
    this.currentBet = 0,
    this.stack = 0,
    this.isAggressor = false,
  });

  final PlayerArchetype archetype;
  final String name;
  final String position;

  /// The villain's range at this point in the hand, already narrowed.
  final HandRange range;

  final double currentBet;
  final double stack;

  /// Whether they voluntarily bet or raised on this street.
  final bool isAggressor;
}

/// Everything the model needs about the spot being graded.
class SpotView {
  /// Creates a spot view.
  const SpotView({
    required this.heroCards,
    required this.board,
    required this.street,
    required this.pot,
    required this.callAmount,
    required this.heroCurrentBet,
    required this.heroStack,
    required this.bigBlind,
    required this.villains,
    required this.heroInPosition,
    required this.seed,
  });

  /// Hero hole cards in [FastEvaluator] coding.
  final List<int> heroCards;

  /// Board cards in [FastEvaluator] coding.
  final List<int> board;

  final Street street;

  /// Total chips in the middle including every live bet on this street.
  final double pot;

  /// Chips hero must add to continue. Zero when checking is free.
  final double callAmount;

  final double heroCurrentBet;
  final double heroStack;
  final double bigBlind;
  final List<VillainView> villains;

  /// Whether hero acts after the primary villain on later streets.
  final bool heroInPosition;

  /// Deterministic seed so the same spot always grades the same way.
  final int seed;

  /// Largest villain stack hero can actually win or lose against.
  double get effectiveStack {
    var largest = 0.0;
    for (final v in villains) {
      final reachable = v.stack + v.currentBet;
      if (reachable > largest) largest = reachable;
    }
    return min(heroStack + heroCurrentBet, largest);
  }

  /// Streets left after this one.
  int get streetsRemaining => switch (street) {
        Street.preflop => 3,
        Street.flop => 2,
        Street.turn => 1,
        Street.river || Street.showdown => 0,
      };
}

/// One candidate line, priced.
class ActionEv {
  /// Creates a priced action.
  const ActionEv({
    required this.action,
    required this.ev,
    this.totalBet = 0,
    this.investment = 0,
    this.foldEquity = 0,
    this.equityUsed = 0,
  });

  final ExploitAction action;

  /// Expected chips gained, with folding as the zero baseline.
  final double ev;

  /// Total amount hero's bet reaches on this street (raise lines only).
  final double totalBet;

  /// Chips hero adds to the pot to take this line.
  final double investment;

  /// Share of the villain range that folds to this line.
  final double foldEquity;

  /// Hero equity this line was priced with.
  final double equityUsed;

  /// Size in big blinds, for display.
  double sizingBb(double bigBlind) =>
      bigBlind <= 0 ? 0 : totalBet / bigBlind;
}

/// The priced result of one decision.
class DecisionAnalysis {
  /// Creates an analysis.
  const DecisionAnalysis({
    required this.options,
    required this.best,
    required this.margin,
    required this.rawEquity,
    required this.realizedEquity,
    required this.requiredEquity,
    required this.heroClass,
    required this.villainComposition,
    required this.uncertainty,
  });

  /// Every line considered, best first.
  final List<ActionEv> options;

  /// Highest-EV line.
  final ActionEv best;

  /// Chips between [best] and the next-best line. Never negative.
  final double margin;

  /// Hero's showdown equity against the villain range.
  final EquityResult rawEquity;

  /// [rawEquity] after the realization discount for position, hand type, and
  /// streets still to be played.
  final double realizedEquity;

  /// Equity hero needs for a call to break even. Zero when nothing is faced.
  final double requiredEquity;

  /// What hero actually holds, relative to the board.
  final HandClass heroClass;

  /// What the villain's range is made of on this board.
  final Map<HandClass, double> villainComposition;

  /// Chips of wobble in the model, from sampling error and one-street depth.
  final double uncertainty;

  /// The priced line for [action], or null when it was not a legal option.
  ActionEv? optionFor(ExploitAction action) {
    for (final o in options) {
      if (o.action == action) return o;
    }
    return null;
  }
}

/// Prices hero's options in chips.
class DecisionModel {
  DecisionModel._();

  /// Raise sizes tried when facing a bet, as multiples of that bet.
  static const List<double> raiseMultiples = [2.5, 3.5];

  /// Bet sizes tried when checked to, as fractions of the pot.
  static const List<double> betFractions = [0.33, 0.66, 1.0];

  /// Monte Carlo iterations behind each candidate bet size.
  ///
  /// Lower than the headline equity on purpose: these numbers never reach the
  /// player, they only rank sizes against each other, and they run once per
  /// candidate.
  static const int candidateIterations = 2500;

  /// Prices every legal line in [spot].
  static DecisionAnalysis analyse(SpotView spot) {
    final ranges = [for (final v in spot.villains) v.range];
    final rawEquity = EquitySimulator.heroEquity(
      heroCards: spot.heroCards,
      board: spot.board,
      villains: ranges,
      seed: spot.seed,
    );

    final heroClass = HandClassifier.classify(
      spot.heroCards[0],
      spot.heroCards[1],
      spot.board,
    );

    final realized = _realize(
      equity: rawEquity.equity,
      spot: spot,
      heroClass: heroClass,
    );

    final pot = spot.pot;
    final call = min(spot.callAmount, spot.heroStack);
    final options = <ActionEv>[];

    if (call > 0) {
      options.add(const ActionEv(action: ExploitAction.fold, ev: 0));
      options.add(
        ActionEv(
          action: ExploitAction.call,
          ev: realized * (pot + call) - call,
          investment: call,
          totalBet: spot.heroCurrentBet + call,
          equityUsed: realized,
        ),
      );
    } else {
      options.add(
        ActionEv(
          action: ExploitAction.check,
          // Checking keeps hero in the pot for free, but a hand that cannot
          // stand a later bet does not get to bank its full share of it.
          ev: realized * pot,
          equityUsed: realized,
        ),
      );
    }

    for (final raise in _raiseCandidates(spot)) {
      options.add(_priceRaise(spot, raise, rawEquity, heroClass));
    }

    options.sort((a, b) => b.ev.compareTo(a.ev));
    final best = options.first;
    final margin =
        options.length > 1 ? max(0.0, best.ev - options[1].ev) : best.ev.abs();

    // Sampling noise moves EV by roughly the pot times the equity error; the
    // one-street horizon is worth a few percent of the pot on top of that.
    final samplingChips = rawEquity.standardError * (pot + call) * 3;
    final horizonChips = spot.streetsRemaining > 0 ? pot * 0.05 : 0.0;

    return DecisionAnalysis(
      options: options,
      best: best,
      margin: margin,
      rawEquity: rawEquity,
      realizedEquity: realized,
      requiredEquity: call > 0 ? call / (pot + call) : 0,
      heroClass: heroClass,
      villainComposition: spot.villains.isEmpty
          ? const {}
          : spot.villains.first.range.composition(spot.board),
      uncertainty: samplingChips + horizonChips,
    );
  }

  /// Prices the line hero actually took, at the size they actually chose.
  ///
  /// [DecisionAnalysis.options] only holds the candidate sizes the model
  /// considered, so a hero raise to some other amount has to be priced on
  /// demand rather than snapped to the nearest candidate — otherwise the EV
  /// reported back would not be the EV of the decision that was made.
  static ActionEv priceHeroAction({
    required SpotView spot,
    required DecisionAnalysis analysis,
    required ExploitAction action,
    double totalBet = 0,
  }) {
    final pot = spot.pot;
    final call = min(spot.callAmount, spot.heroStack);

    switch (action) {
      case ExploitAction.fold:
        return const ActionEv(action: ExploitAction.fold, ev: 0);
      case ExploitAction.check:
        // Checking when there is something to call is not a legal line; treat
        // it as the fold it amounts to rather than pricing a fantasy.
        if (call > 0) return const ActionEv(action: ExploitAction.fold, ev: 0);
        return ActionEv(
          action: ExploitAction.check,
          ev: analysis.realizedEquity * pot,
          equityUsed: analysis.realizedEquity,
        );
      case ExploitAction.call:
        if (call <= 0) {
          return ActionEv(
            action: ExploitAction.check,
            ev: analysis.realizedEquity * pot,
            equityUsed: analysis.realizedEquity,
          );
        }
        return ActionEv(
          action: ExploitAction.call,
          ev: analysis.realizedEquity * (pot + call) - call,
          investment: call,
          totalBet: spot.heroCurrentBet + call,
          equityUsed: analysis.realizedEquity,
        );
      case ExploitAction.raise:
        final cap = min(
          spot.heroCurrentBet + spot.heroStack,
          spot.effectiveStack,
        );
        final facing = spot.heroCurrentBet + spot.callAmount;
        final size = totalBet.clamp(0.0, cap);
        if (size <= facing) {
          // Not actually a raise — price it as the call it is worth.
          return priceHeroAction(
            spot: spot,
            analysis: analysis,
            action: call > 0 ? ExploitAction.call : ExploitAction.check,
          );
        }
        return _priceRaise(spot, size, analysis.rawEquity, analysis.heroClass);
    }
  }

  /// Equity hero can expect to actually collect, not just to hold.
  ///
  /// Showdown equity assumes every card gets dealt. In practice a hand that
  /// cannot stand a turn barrel realizes less than its share, and one with a
  /// draw and position realizes more. The adjustment shrinks toward nothing as
  /// streets run out and is exactly nothing on the river, where equity and
  /// showdown are the same thing.
  static double _realize({
    required double equity,
    required SpotView spot,
    required HandClass heroClass,
    bool hasInitiative = false,
    double commitment = 0,
  }) {
    if (spot.streetsRemaining == 0) return equity;

    var deviation = 0.0;
    deviation += spot.heroInPosition ? 0.04 : -0.06;
    // Betting rather than calling buys the option to win without showdown on
    // a later street — but only for a hand that can keep betting. A weak pair
    // that raises stops being a cheap bluff-catcher and starts playing a big
    // pot it cannot defend, and the bigger the raise the worse that gets.
    // Without this the model talks itself into blowing up the pot with bottom
    // pair, because one street of fold equity looks wonderful right up until
    // the turn arrives and the hand cannot call a bet.
    if (hasInitiative) {
      final scaled = commitment.clamp(0.0, 3.0);
      deviation += switch (heroClass) {
        HandClass.strongDraw ||
        HandClass.topPair ||
        HandClass.strongMade ||
        HandClass.monster =>
          0.05,
        HandClass.weakPair => -0.06 - 0.06 * scaled,
        HandClass.air || HandClass.weakDraw => -0.03 * scaled,
      };
    }
    deviation += switch (heroClass) {
      HandClass.air => -0.06,
      HandClass.weakDraw => -0.04,
      HandClass.strongDraw => 0.05,
      HandClass.weakPair => -0.05,
      HandClass.topPair => 0.02,
      HandClass.strongMade || HandClass.monster => 0.03,
    };
    deviation -= 0.04 * (spot.villains.length - 1);

    final scale = min(spot.streetsRemaining, 2) / 2.0;
    final factor = (1.0 + deviation * scale).clamp(0.70, 1.08);
    return (equity * factor).clamp(0.0, 1.0);
  }

  /// Largest bet the coach will ever recommend, as a multiple of the pot.
  ///
  /// Deep-stacked overbets beyond this are not a real part of anyone's
  /// strategy, but a one-street EV model will reach for them whenever it can
  /// be talked into a little fold equity: risking twenty pots to win one
  /// prices out beautifully right up until a human has to make the call.
  /// Capping what can be *proposed* is a structural guard that does not depend
  /// on the opponent frequencies being tuned perfectly.
  static const double maxRecommendedPotMultiple = 1.5;

  /// Largest raise the coach will recommend, as a multiple of the bet faced.
  static const double maxRecommendedRaiseMultiple = 4.0;

  /// Total bet amounts worth evaluating for a raise or bet.
  static List<double> _raiseCandidates(SpotView spot) {
    final stackCap =
        min(spot.heroCurrentBet + spot.heroStack, spot.effectiveStack);
    final facing = spot.heroCurrentBet + spot.callAmount;

    // An all-in still gets priced whenever the stacks are shallow enough for
    // it to be a normal-sized bet — that is where shoving genuinely is best.
    final sane = spot.heroCurrentBet +
        max(
          spot.pot * maxRecommendedPotMultiple,
          spot.callAmount * maxRecommendedRaiseMultiple,
        );
    final cap = min(stackCap, sane);

    final raw = <double>[];
    if (spot.callAmount > 0) {
      for (final m in raiseMultiples) {
        raw.add(facing * m);
      }
    } else {
      for (final f in betFractions) {
        raw.add(spot.pot * f);
      }
    }
    raw.add(cap);

    final seen = <int>{};
    final out = <double>[];
    for (final value in raw) {
      final clamped = min(value, cap);
      // Must actually be a raise, and must clear the amount hero is facing.
      if (clamped <= facing + 1e-9) continue;
      final key = (clamped * 100).round();
      if (!seen.add(key)) continue;
      out.add(clamped);
    }
    return out;
  }

  /// Prices a raise (or bet) to a total of [totalBet].
  static ActionEv _priceRaise(
    SpotView spot,
    double totalBet,
    EquityResult rawEquity,
    HandClass heroClass,
  ) {
    final investment = totalBet - spot.heroCurrentBet;
    final pot = spot.pot;

    // Price the raise from the perspective of the player being asked to call
    // it: what it costs them relative to the pot they would be calling into.
    var foldEquity = 1.0;
    final continuing = <HandRange>[];
    for (final v in spot.villains) {
      final theirCall = max(0.0, min(totalBet - v.currentBet, v.stack));
      final priceToPot = theirCall / max(pot + investment, 1e-9);
      foldEquity *= RangeBuilder.foldEquity(
        range: v.range,
        archetype: v.archetype,
        board: spot.board,
        priceToPot: priceToPot,
      );
      continuing.add(
        RangeBuilder.continuingAgainst(
          range: v.range,
          archetype: v.archetype,
          board: spot.board,
          priceToPot: priceToPot,
        ),
      );
    }

    final liveContinuing = [for (final r in continuing) if (!r.isEmpty) r];
    final rawWhenCalled = liveContinuing.isEmpty
        ? rawEquity.equity
        : EquitySimulator.heroEquity(
            heroCards: spot.heroCards,
            board: spot.board,
            villains: liveContinuing,
            // Every candidate size shares a seed, so they are compared on the
            // same sampled runouts. That cancels most of the sampling noise
            // out of the comparison, which is the only thing it feeds.
            seed: spot.seed ^ 0x5bf03635,
            iterations: candidateIterations,
            allowExact: false,
          ).equity;
    final equityWhenCalled = _realize(
      equity: rawWhenCalled,
      spot: spot,
      heroClass: heroClass,
      hasInitiative: true,
      commitment: investment / max(pot, 1e-9),
    );

    var calledPot = pot + investment;
    for (final v in spot.villains) {
      calledPot += max(0.0, min(totalBet - v.currentBet, v.stack));
    }

    final evWhenCalled = equityWhenCalled * calledPot - investment;
    final ev = foldEquity * pot + (1 - foldEquity) * evWhenCalled;

    return ActionEv(
      action: ExploitAction.raise,
      ev: ev,
      totalBet: totalBet,
      investment: investment,
      foldEquity: foldEquity,
      equityUsed: equityWhenCalled,
    );
  }
}
