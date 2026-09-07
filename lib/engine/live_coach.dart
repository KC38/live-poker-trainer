/// Lightweight exploit grading for live full-hand training.
library;

import 'dart:math';

import 'package:live_poker_trainer/engine/deck_evaluator.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Result of a live coaching grade for one Hero action.
class LiveCoachGrade {
  /// Creates a live coach grade.
  const LiveCoachGrade({
    required this.verdict,
    required this.message,
    this.optimalAction,
    this.optimalSizingBb = 0,
    this.evDeltaBb = 0,
  });

  final CoachVerdict verdict;
  final String message;
  final ExploitAction? optimalAction;
  final double optimalSizingBb;
  final double evDeltaBb;
}

/// Grades Hero actions against archetype leaks during full-hand play.
class LiveCoach {
  LiveCoach._();

  /// Grades [action] in the current [state] before it is applied.
  static LiveCoachGrade grade({
    required GameState state,
    required PokerAction action,
  }) {
    final hero = state.hero;
    final callAmt = state.callAmountFor(hero);
    final villain = _primaryVillain(state);
    final arch = villain?.archetype ?? PlayerArchetype.tag;
    final pot = state.totalPot;
    final bb = state.bigBlind;
    final cards = [...hero.holeCards, ...state.community];
    final strength = cards.length >= 5
        ? DeckEvaluator.evaluate7Cards(cards).score
        : _preflopStrength(hero);

    final suggested = _suggest(
      street: state.street,
      archetype: arch,
      callAmount: callAmt,
      pot: pot,
      bigBlind: bb,
      handStrength: strength,
      hasBoard: state.community.isNotEmpty,
    );

    if (suggested == null) {
      return LiveCoachGrade(
        verdict: CoachVerdict.none,
        message: _punchyFallback(arch, action),
      );
    }

    final mapped = _mapAction(action, callAmt);
    var correct = mapped == suggested.action;
    if (!correct &&
        suggested.action == ExploitAction.call &&
        mapped == ExploitAction.check &&
        callAmt <= 0) {
      correct = true;
    }
    if (!correct &&
        suggested.action == ExploitAction.check &&
        mapped == ExploitAction.call &&
        callAmt <= 0) {
      correct = true;
    }

    var sizingError = 0.0;
    if (suggested.action == ExploitAction.raise &&
        mapped == ExploitAction.raise &&
        suggested.sizingBb > 0) {
      final sizingBb = action.amount / bb;
      sizingError = (sizingBb - suggested.sizingBb).abs();
      final band = max(1.0, suggested.sizingBb * 0.45);
      correct = sizingError <= band;
    }

    final evDeltaBb = correct
        ? max(0.2, suggested.sizingBb * 0.04)
        : -max(0.35, callAmt / max(bb, 1) * 0.12);

    final message = correct
        ? suggested.correctLine
        : 'Better: ${suggested.action.label}'
            '${suggested.sizingBb > 0 ? ' ~${suggested.sizingBb.toStringAsFixed(0)} BB' : ''}. '
            '${suggested.reason}';

    return LiveCoachGrade(
      verdict: correct ? CoachVerdict.correct : CoachVerdict.incorrect,
      message: message,
      optimalAction: suggested.action,
      optimalSizingBb: suggested.sizingBb,
      evDeltaBb: evDeltaBb,
    );
  }

  static PlayerModel? _primaryVillain(GameState state) {
    if (state.lastAggressor != null) {
      final p = state.players[state.lastAggressor!];
      if (!p.isHero && !p.folded) return p;
    }
    for (final p in state.players) {
      if (!p.isHero && !p.folded) return p;
    }
    return null;
  }

  static ExploitAction _mapAction(PokerAction action, double callAmt) {
    return switch (action.type) {
      PokerActionType.fold => ExploitAction.fold,
      PokerActionType.check => ExploitAction.check,
      PokerActionType.call => ExploitAction.call,
      PokerActionType.bet ||
      PokerActionType.raise ||
      PokerActionType.allIn =>
        ExploitAction.raise,
    };
  }

  static int _preflopStrength(PlayerModel hero) {
    if (hero.holeCards.length < 2) return 0;
    final a = hero.holeCards[0];
    final b = hero.holeCards[1];
    final high = max(a.rank, b.rank);
    final low = min(a.rank, b.rank);
    final pair = a.rank == b.rank;
    final suited = a.suit == b.suit;
    if (pair && high >= 10) return 2500000;
    if (pair) return 1500000;
    if (high == 14 && low >= 12) return 2200000;
    if (high == 14 && suited) return 1600000;
    if (high >= 12 && low >= 10) return 1400000;
    if (suited && high - low <= 2 && high >= 10) return 1100000;
    return high * 50000 + low * 1000;
  }

  static ({
    ExploitAction action,
    double sizingBb,
    String reason,
    String correctLine,
  })? _suggest({
    required Street street,
    required PlayerArchetype archetype,
    required double callAmount,
    required double pot,
    required double bigBlind,
    required int handStrength,
    required bool hasBoard,
  }) {
    final potBb = pot / max(bigBlind, 1);
    final callBb = callAmount / max(bigBlind, 1);

    // Free option: checking is always fine; betting depends on archetype.
    if (callAmount <= 0) {
      if (archetype == PlayerArchetype.nit &&
          street.index >= Street.turn.index &&
          handStrength >= 1000000) {
        final size = max(3.0, potBb * 0.55);
        return (
          action: ExploitAction.raise,
          sizingBb: size,
          reason: 'Nits check-fold too often — probe thin value/bluff.',
          correctLine: 'Nice probe — nits bleed folds on later streets.',
        );
      }
      if (archetype == PlayerArchetype.callingStation &&
          handStrength >= 2000000) {
        final size = max(4.0, potBb * 0.7);
        return (
          action: ExploitAction.raise,
          sizingBb: size,
          reason: 'Stations pay off value — size up with the goods.',
          correctLine: 'Value print — stations call too wide.',
        );
      }
      if (handStrength >= 2000000) {
        final size = max(3.0, potBb * 0.6);
        return (
          action: ExploitAction.raise,
          sizingBb: size,
          reason: 'Strong enough to bet for value.',
          correctLine: 'Solid value bet — keep charging.',
        );
      }
      // Ambiguous check/bet — no hard grade.
      return null;
    }

    // Facing a bet/raise.
    switch (archetype) {
      case PlayerArchetype.nit:
        if (callBb >= potBb * 0.45 && handStrength < 2000000) {
          return (
            action: ExploitAction.fold,
            sizingBb: 0,
            reason: 'Nit bets = nutted. Live to fight.',
            correctLine: 'Disciplined fold — nit range is polarized strong.',
          );
        }
        if (handStrength >= 2000000) {
          final size = max(callBb * 2.2, potBb * 0.75);
          return (
            action: ExploitAction.raise,
            sizingBb: size,
            reason: 'When a nit bets and you have it, raise for value.',
            correctLine: 'Raise — punish the nit when you actually have it.',
          );
        }
        return (
          action: ExploitAction.fold,
          sizingBb: 0,
          reason: 'Nit aggression is rarely a bluff.',
          correctLine: 'Good fold vs nit pressure.',
        );
      case PlayerArchetype.callingStation:
        if (handStrength >= 1500000) {
          final size = max(callBb * 2.5, potBb * 0.85);
          return (
            action: ExploitAction.raise,
            sizingBb: size,
            reason: 'Stations overcall — value raise relentlessly.',
            correctLine: 'Value raise — stations hate folding.',
          );
        }
        if (callBb <= potBb * 0.35) {
          return (
            action: ExploitAction.call,
            sizingBb: 0,
            reason: 'Cheap keep vs a station; bluffs rarely work.',
            correctLine: 'Call — bluffing stations is lighting money on fire.',
          );
        }
        return (
          action: ExploitAction.fold,
          sizingBb: 0,
          reason: 'Too expensive without showdown value.',
          correctLine: 'Fold — no need to inflate vs a station without equity.',
        );
      case PlayerArchetype.maniac:
      case PlayerArchetype.lag:
        if (handStrength >= 1000000 || callBb <= potBb * 0.4) {
          return (
            action: ExploitAction.call,
            sizingBb: 0,
            reason: 'Wide aggressors bluff — call lighter, raise stronger hands.',
            correctLine: 'Call lighter vs maniac/LAG pressure.',
          );
        }
        if (handStrength >= 2000000) {
          final size = max(callBb * 2.4, potBb * 0.8);
          return (
            action: ExploitAction.raise,
            sizingBb: size,
            reason: 'Trap or re-raise strong vs spew.',
            correctLine: 'Raise — make the maniac pay with the nuts.',
          );
        }
        return (
          action: ExploitAction.fold,
          sizingBb: 0,
          reason: 'Even maniacs get there sometimes — dump trash.',
          correctLine: 'Fold trash — aggression does not equal call any two.',
        );
      default:
        if (!hasBoard && callBb <= 3 && handStrength >= 1100000) {
          return (
            action: ExploitAction.call,
            sizingBb: 0,
            reason: 'Playable preflop price.',
            correctLine: 'Reasonable continue preflop.',
          );
        }
        if (handStrength >= 2000000) {
          return (
            action: ExploitAction.call,
            sizingBb: 0,
            reason: 'Strong enough to continue.',
            correctLine: 'Continue with the goods.',
          );
        }
        if (callBb >= potBb * 0.55 && handStrength < 1500000) {
          return (
            action: ExploitAction.fold,
            sizingBb: 0,
            reason: 'Price is wrong without a strong holding.',
            correctLine: 'Fold — pot odds and strength do not line up.',
          );
        }
        return null;
    }
  }

  static String _punchyFallback(PlayerArchetype arch, PokerAction action) {
    return switch (arch) {
      PlayerArchetype.nit =>
        'Vs nits: bet when checked to, fold to big heat without the goods.',
      PlayerArchetype.callingStation =>
        'Vs stations: value big, bluff almost never.',
      PlayerArchetype.maniac =>
        'Vs maniacs: call wider, let them hang themselves.',
      PlayerArchetype.lag =>
        'Vs LAGs: tighten value raises, defend more flops.',
      PlayerArchetype.tag =>
        'Vs TAGs: respect ranges; look for thin edges on later streets.',
      PlayerArchetype.hero => 'Stay process-oriented — one street at a time.',
    };
  }
}
