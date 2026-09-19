/// Maps hero [PokerAction]s onto [HeroActionEdge]s from the current node.
library;

import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/situation_model.dart';

/// Resolves an exact authored edge for a hero decision.
class SituationActionKeys {
  SituationActionKeys._();

  /// Returns the edge whose kind and authored commitment match [action].
  ///
  /// Passive actions match by kind. Chip actions additionally require an
  /// exact `amountTo` match within [Money.epsilon]; calls compare the hero's
  /// total street commitment after calling.
  static HeroActionEdge? resolveEdge({
    required HeroDecisionNode node,
    required GameState state,
    required PokerAction action,
  }) {
    final wantKind = _kindFor(action);
    if (wantKind == SituationActionKind.fold ||
        wantKind == SituationActionKind.check) {
      for (final edge in node.actions) {
        if (edge.kind == wantKind) return edge;
      }
      return null;
    }

    final hero = state.hero;
    final targetTo =
        action.type == PokerActionType.call
            ? Money.round(hero.currentBet + state.callAmountFor(hero))
            : Money.round(action.amount);
    for (final edge in node.actions) {
      if (edge.kind == wantKind &&
          edge.amountTo != null &&
          _hasCentPrecision(edge.amountTo!) &&
          Money.same(edge.amountTo!, targetTo)) {
        return edge;
      }
    }
    return null;
  }

  static bool _hasCentPrecision(double amount) {
    if (!amount.isFinite) return false;
    final cents = amount * 100;
    return (cents - cents.roundToDouble()).abs() <= 1e-9;
  }

  /// Convenience: returns the chosen [HeroActionEdge.actionKey].
  static String resolve({
    required HeroDecisionNode node,
    required GameState state,
    required PokerAction action,
  }) {
    return resolveEdge(node: node, state: state, action: action)?.actionKey ??
        action.label;
  }

  static SituationActionKind _kindFor(PokerAction action) {
    return switch (action.type) {
      PokerActionType.fold => SituationActionKind.fold,
      PokerActionType.check => SituationActionKind.check,
      PokerActionType.call => SituationActionKind.call,
      PokerActionType.bet => SituationActionKind.bet,
      PokerActionType.raise => SituationActionKind.raise,
      PokerActionType.allIn => SituationActionKind.allIn,
    };
  }

  /// Builds a dock [PokerAction] from a chosen edge (for tests / autoplay).
  static PokerAction pokerActionForEdge(GameState state, HeroActionEdge edge) {
    final hero = state.hero;
    switch (edge.kind) {
      case SituationActionKind.fold:
        return const PokerAction(type: PokerActionType.fold);
      case SituationActionKind.check:
        return const PokerAction(type: PokerActionType.check);
      case SituationActionKind.call:
        return PokerAction(
          type: PokerActionType.call,
          amount: state.callAmountFor(hero),
        );
      case SituationActionKind.allIn:
        return PokerAction(
          type: PokerActionType.allIn,
          amount: _requiredAmountTo(edge),
        );
      case SituationActionKind.bet:
        return PokerAction(
          type: PokerActionType.bet,
          amount: _requiredAmountTo(edge),
        );
      case SituationActionKind.raise:
        return PokerAction(
          type: PokerActionType.raise,
          amount: _requiredAmountTo(edge),
        );
      default:
        throw ArgumentError.value(
          edge.kind,
          'edge.kind',
          'Not a hero action kind',
        );
    }
  }

  static double _requiredAmountTo(HeroActionEdge edge) {
    final amount = edge.amountTo;
    if (amount == null) {
      throw StateError('${edge.kind.wire} edge is missing amountTo');
    }
    return amount;
  }
}
