/// Normalized hand-history input for hero profiling.
///
/// The profiler never talks to the database directly: it consumes
/// [HeroHandSample]s, which are plain value objects. That keeps the metric
/// math pure (and unit-testable from synthetic histories) and lets the storage
/// layer evolve — today the samples are hydrated from the `hands` /
/// `hand_actions` log, tomorrow they could come from an import.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// One betting action, normalized across the engine's action labels.
enum HandActionKind {
  /// Forced blind post — never counts as voluntary money.
  blind,
  fold,
  check,
  call,
  bet,
  raise,

  /// Treated as aggression: in this trainer an all-in is almost always a shove
  /// rather than a short-stack call.
  allIn;

  /// Bets, raises, and shoves.
  bool get isAggressive =>
      this == HandActionKind.bet ||
      this == HandActionKind.raise ||
      this == HandActionKind.allIn;

  /// Chips went in by choice (blinds excluded).
  bool get isVoluntaryMoney =>
      this == HandActionKind.call || isAggressive;

  /// A decision the player actually made (blind posts are not decisions).
  bool get isDecision => this != HandActionKind.blind;

  /// Parses an engine / database action label such as `ALL-IN` or `Raise`.
  static HandActionKind? tryParse(String raw) {
    final key = raw.trim().toUpperCase().replaceAll(RegExp('[^A-Z]'), '');
    return switch (key) {
      'BLIND' || 'POST' || 'SB' || 'BB' || 'ANTE' => HandActionKind.blind,
      'FOLD' => HandActionKind.fold,
      'CHECK' => HandActionKind.check,
      'CALL' => HandActionKind.call,
      'BET' => HandActionKind.bet,
      'RAISE' => HandActionKind.raise,
      'ALLIN' => HandActionKind.allIn,
      _ => null,
    };
  }
}

/// A single action inside a recorded hand.
@immutable
class HandActionSample {
  /// Creates an action sample.
  const HandActionSample({
    required this.seat,
    required this.street,
    required this.kind,
    this.isHero = false,
    this.archetype = PlayerArchetype.tag,
    this.amountBb = 0,
  });

  final int seat;
  final Street street;
  final HandActionKind kind;
  final bool isHero;

  /// Archetype of the acting seat; [PlayerArchetype.hero] for the hero.
  final PlayerArchetype archetype;

  /// Chips committed by this action, in big blinds.
  final double amountBb;
}

/// One dealt hand from the hero's point of view.
@immutable
class HeroHandSample {
  /// Creates a hand sample.
  const HeroHandSample({
    required this.handId,
    required this.playedAt,
    required this.actions,
    this.heroSeat = 0,
    this.wentToShowdown = false,
    this.heroWon = false,
    this.heroNetBb = 0,
  });

  /// Row id of the hand (only used for stable ordering / dedup).
  final int handId;

  final DateTime playedAt;

  /// Every action in the hand, in order, blinds included.
  final List<HandActionSample> actions;

  final int heroSeat;

  /// Whether the hand was decided at showdown rather than by folds.
  final bool wentToShowdown;

  /// Whether the hero was awarded chips.
  final bool heroWon;

  /// Hero stack change over the hand, in big blinds.
  final double heroNetBb;

  /// Hero actions on [street], in order, blinds included.
  Iterable<HandActionSample> heroActionsOn(Street street) =>
      actions.where((a) => a.isHero && a.street == street);

  /// Every hero decision (blind posts excluded).
  Iterable<HandActionSample> get heroDecisions =>
      actions.where((a) => a.isHero && a.kind.isDecision);

  /// Whether any seat acted on [street].
  bool reached(Street street) => actions.any((a) => a.street == street);

  /// Whether the hero folded on [street].
  bool heroFoldedOn(Street street) =>
      heroActionsOn(street).any((a) => a.kind == HandActionKind.fold);

  /// Whether the hero folded at any point up to and including [street].
  bool heroFoldedBy(Street street) => actions.any(
        (a) =>
            a.isHero &&
            a.kind == HandActionKind.fold &&
            a.street.index <= street.index,
      );

  /// Hero put chips in preflop by choice.
  bool get heroVpip => heroActionsOn(Street.preflop)
      .any((a) => a.kind.isVoluntaryMoney);

  /// Hero raised (or shoved) preflop.
  bool get heroRaisedPreflop =>
      heroActionsOn(Street.preflop).any((a) => a.kind.isAggressive);

  /// Hero was still live when the flop came out.
  bool get heroSawFlop =>
      reached(Street.flop) && !heroFoldedBy(Street.preflop);

  /// Seat that made the last aggressive preflop action before the hero's first
  /// voluntary decision, or null when the hero was first in.
  HandActionSample? get preflopOpener {
    for (final action in actions) {
      if (action.street != Street.preflop) break;
      if (action.isHero) return null;
      if (action.kind.isAggressive) return action;
    }
    return null;
  }

  /// The last aggressor of the hand before [index], hero excluded.
  HandActionSample? villainAggressorBefore(int index) {
    for (var i = index - 1; i >= 0; i--) {
      final action = actions[i];
      if (!action.isHero && action.kind.isAggressive) return action;
    }
    return null;
  }

  /// The villain the hero was effectively playing against for the action at
  /// [index]: the most recent aggressor, else the most recent villain to act.
  PlayerArchetype? villainArchetypeFor(int index) {
    final aggressor = villainAggressorBefore(index);
    if (aggressor != null) return aggressor.archetype;
    for (var i = index - 1; i >= 0; i--) {
      final action = actions[i];
      if (!action.isHero && action.kind != HandActionKind.blind) {
        return action.archetype;
      }
    }
    return null;
  }
}
