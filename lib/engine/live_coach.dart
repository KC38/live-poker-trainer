/// Lightweight exploit grading for live full-hand training.
library;

import 'dart:math';

import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/engine/deck_evaluator.dart';
import 'package:live_poker_trainer/engine/poker_engine.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Result of a live coaching grade for one Hero action.
class LiveCoachGrade {
  /// Creates a live coach grade.
  const LiveCoachGrade({
    required this.verdict,
    required this.message,
    required this.villainArchetype,
    required this.villainName,
    required this.street,
    required this.heroActionLabel,
    required this.mismatch,
    this.optimalAction,
    this.optimalSizingBb = 0,
    this.evDeltaBb = 0,
    this.heroAction = ExploitAction.check,
    this.heroSizingBb = 0,
    this.villainPosition = '',
    this.heroPosition = '',
    this.villainIsAggressor = false,
    this.callAmount = 0,
  });

  final CoachVerdict verdict;

  /// Spot-specific coaching copy naming the street, villain, and better line.
  final String message;

  /// Archetype the grade was reasoned against.
  final PlayerArchetype villainArchetype;
  final String villainName;
  final Street street;
  final String heroActionLabel;

  /// How the hero's action differed from the recommended line.
  final CoachMismatch mismatch;

  final ExploitAction? optimalAction;
  final double optimalSizingBb;
  final double evDeltaBb;

  /// Hero action mapped onto the exploit vocabulary.
  final ExploitAction heroAction;

  /// Hero bet / raise size in big blinds (0 for passive actions).
  final double heroSizingBb;

  /// Villain seat position label (BB / SB / BTN / …).
  final String villainPosition;

  /// Hero seat position label.
  final String heroPosition;

  /// True only when the villain voluntarily bet or raised this street.
  final bool villainIsAggressor;

  /// Chips hero must add to call (snapshot at grade time).
  final double callAmount;

  /// Stable leak classification of this decision (null when ungraded).
  MistakePattern? get pattern {
    final best = optimalAction;
    if (!verdict.isGraded || best == null) return null;
    return MistakePattern.derive(
      street: street,
      archetype: villainArchetype,
      taken: heroAction,
      best: best,
      mismatch: mismatch,
      heroSizingBb: heroSizingBb,
      bestSizingBb: optimalSizingBb,
    );
  }

  /// Structured prompt for the Claude coach.
  ///
  /// Position and aggressor status are explicit so the model cannot invent
  /// "BB is the aggressor" when they only posted blinds.
  String toPrompt(
    GameState game, {
    RepeatInfo? repeat,
    ImprovementInfo? improvement,
  }) {
    final history = StringBuffer();
    if (repeat != null && repeat.isRepeat) {
      history.write(' Leak history: this is occurrence #${repeat.displayCount} '
          'of the pattern "${repeat.pattern.primaryTag.label}" '
          '(${repeat.pattern.key}), ${repeat.sessionCount} in this session. '
          'Explicitly say it is a repeated mistake, quote the count, and name '
          'the pattern.');
    }
    if (improvement != null) {
      history.write(' Leak history: the player previously '
          '${_pastTense(improvement.lastWrongAction)} in this spot '
          '${improvement.priorMistakes} times '
          '("${improvement.tag.label}") and just got it right, '
          'streak ${improvement.streak}. Explicitly acknowledge the fix and '
          'what they used to do.');
    }
    final board = game.community.map((c) => c.code).join(' ');
    final hole = game.hero.holeCards.map((c) => c.code).join(' ');
    final bestLabel = optimalAction?.label ?? 'no clear exploit';
    final endorse = switch (optimalAction) {
      ExploitAction.fold =>
        'Endorse folding only. Never tell the player to call, defend, or continue.',
      ExploitAction.call =>
        'Endorse calling only. Never tell the player to fold.',
      ExploitAction.check =>
        'Endorse checking only. Never tell the player to fold or inflate the pot.',
      ExploitAction.raise =>
        'Endorse raising/betting only. Never tell the player to fold.',
      null => 'No graded exploit — stay neutral; do not invent a verdict.',
    };
    final aggressorLine = villainIsAggressor
        ? 'Villain role: voluntary aggressor (they bet or raised this street).'
        : 'Villain role: NOT the aggressor '
            '(posted blinds and/or called only — do NOT say they fired, bet, '
            'raised, or led).';
    return 'Street being graded: ${street.label}. '
        'Hero position: ${heroPosition.isEmpty ? 'unknown' : heroPosition}. '
        'Hero hole cards: ${hole.isEmpty ? 'unknown' : hole}. '
        'Board: ${board.isEmpty ? 'none' : board}. '
        'Pot: ${ChipFormat.dollars(game.totalPot)} '
        '(${(game.totalPot / max(game.bigBlind, 1)).toStringAsFixed(0)} BB). '
        'Call amount facing hero: ${ChipFormat.dollars(callAmount)}. '
        'Primary villain: $villainName at '
        '${villainPosition.isEmpty ? 'unknown' : villainPosition}, '
        'archetype ${villainArchetype.label} '
        '(VPIP ${villainArchetype.vpip.toStringAsFixed(0)}, '
        'PFR ${villainArchetype.pfr.toStringAsFixed(0)}). '
        '$aggressorLine '
        'Hero action: $heroActionLabel. '
        'Recommended: $bestLabel'
        '${optimalSizingBb > 0 ? ' ~${optimalSizingBb.toStringAsFixed(0)} BB' : ''}. '
        'Verdict: ${verdict.name}. Error type: ${mismatch.name}. '
        '$endorse '
        'In one or two sentences, tell the player specifically why '
        '$heroActionLabel '
        '${verdict == CoachVerdict.correct ? 'works' : 'is worse than the recommended line'} '
        'against a ${villainArchetype.label} on the ${street.label}. '
        'Reference the archetype tendency by name. Do not give generic advice.'
        '$history';
  }

  static String _pastTense(ExploitAction a) => switch (a) {
        ExploitAction.fold => 'folded',
        ExploitAction.check => 'checked',
        ExploitAction.call => 'called',
        ExploitAction.raise => 'raised',
      };
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
    final villainInfo = _primaryVillain(state);
    final villain = villainInfo.player;
    final arch = villain?.archetype ?? PlayerArchetype.tag;
    final villainName = villain?.name ?? 'the field';
    final villainPos = villainInfo.position;
    final heroPos = state.positionLabel(
      state.players.indexWhere((p) => p.isHero),
    );
    final pot = state.totalPot;
    final bb = state.bigBlind < 1 ? 1.0 : state.bigBlind;
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

    final mapped = _mapAction(action);

    if (suggested == null) {
      return LiveCoachGrade(
        verdict: CoachVerdict.none,
        message: CoachLines.ambiguous(
          archetype: arch,
          street: state.street,
          villainName: villainName,
          callAmount: callAmt,
          villainIsAggressor: villainInfo.isAggressor,
        ),
        villainArchetype: arch,
        villainName: villainName,
        street: state.street,
        heroActionLabel: action.label,
        mismatch: CoachMismatch.none,
        villainPosition: villainPos,
        heroPosition: heroPos,
        villainIsAggressor: villainInfo.isAggressor,
        callAmount: callAmt,
      );
    }

    var actionMatches = mapped == suggested.action;
    // Checking and calling are the same decision when calling is free.
    if (!actionMatches && callAmt <= Money.epsilon) {
      const passive = {ExploitAction.check, ExploitAction.call};
      if (passive.contains(mapped) && passive.contains(suggested.action)) {
        actionMatches = true;
      }
    }

    var sizingOff = false;
    final heroSizingBb = action.amount / bb;
    if (actionMatches &&
        suggested.action == ExploitAction.raise &&
        suggested.sizingBb > 0) {
      final band = max(1.0, suggested.sizingBb * 0.45);
      sizingOff = (heroSizingBb - suggested.sizingBb).abs() > band;
    }

    final correct = actionMatches && !sizingOff;
    final mismatch = CoachLines.classify(
      best: suggested.action,
      taken: mapped,
      sizingOff: sizingOff,
    );

    final evDeltaBb = correct
        ? max(0.2, suggested.sizingBb * 0.04)
        : -max(0.35, callAmt / bb * 0.12);

    return LiveCoachGrade(
      verdict: correct ? CoachVerdict.correct : CoachVerdict.incorrect,
      message: CoachLines.forGrade(
        correct: correct,
        mismatch: mismatch,
        archetype: arch,
        villainName: villainName,
        street: state.street,
        best: suggested.action,
        taken: mapped,
        bestSizing: suggested.sizingBb,
        heroSizing: heroSizingBb,
        potSize: pot,
        callAmount: callAmt,
        villainIsAggressor: villainInfo.isAggressor,
        villainPosition: villainPos,
      ),
      villainArchetype: arch,
      villainName: villainName,
      street: state.street,
      heroActionLabel: action.label,
      mismatch: mismatch,
      optimalAction: suggested.action,
      optimalSizingBb: suggested.sizingBb,
      evDeltaBb: evDeltaBb,
      heroAction: mapped,
      heroSizingBb: heroSizingBb,
      villainPosition: villainPos,
      heroPosition: heroPos,
      villainIsAggressor: villainInfo.isAggressor,
      callAmount: callAmt,
    );
  }

  /// Picks the primary villain and whether they voluntarily aggressed.
  ///
  /// Blind posts never count as aggression ([GameState.lastAggressor] is only
  /// set on bet/raise). When nobody has raised, the biggest committed live
  /// seat is the reference villain but [isAggressor] stays false.
  static ({PlayerModel? player, String position, bool isAggressor})
      _primaryVillain(GameState state) {
    final aggressor = state.lastAggressor;
    if (aggressor != null &&
        aggressor >= 0 &&
        aggressor < state.players.length) {
      final p = state.players[aggressor];
      if (!p.isHero && !p.folded) {
        return (
          player: p,
          position: state.positionLabel(aggressor),
          isAggressor: true,
        );
      }
    }
    PlayerModel? best;
    var bestIdx = -1;
    for (var i = 0; i < state.players.length; i++) {
      final p = state.players[i];
      if (p.isHero || p.folded) continue;
      if (best == null || p.currentBet > best.currentBet) {
        best = p;
        bestIdx = i;
      }
    }
    if (best == null) {
      return (player: null, position: '', isAggressor: false);
    }
    return (
      player: best,
      position: state.positionLabel(bestIdx),
      isAggressor: false,
    );
  }

  static ExploitAction _mapAction(PokerAction action) {
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

  static ({ExploitAction action, double sizingBb})? _suggest({
    required Street street,
    required PlayerArchetype archetype,
    required double callAmount,
    required double pot,
    required double bigBlind,
    required int handStrength,
    required bool hasBoard,
  }) {
    final potBb = pot / bigBlind;
    final callBb = callAmount / bigBlind;

    // Free option: checking is always fine; betting depends on archetype.
    if (callAmount <= Money.epsilon) {
      if (archetype == PlayerArchetype.nit &&
          street.index >= Street.turn.index &&
          handStrength >= 1000000) {
        return (action: ExploitAction.raise, sizingBb: max(3.0, potBb * 0.55));
      }
      if (archetype == PlayerArchetype.callingStation &&
          handStrength >= 2000000) {
        return (action: ExploitAction.raise, sizingBb: max(4.0, potBb * 0.7));
      }
      if (handStrength >= 2000000) {
        return (action: ExploitAction.raise, sizingBb: max(3.0, potBb * 0.6));
      }
      // Ambiguous check/bet — no hard grade.
      return null;
    }

    // Facing a bet/raise.
    switch (archetype) {
      case PlayerArchetype.nit:
        if (handStrength >= 2000000) {
          return (
            action: ExploitAction.raise,
            sizingBb: max(callBb * 2.2, potBb * 0.75),
          );
        }
        return (action: ExploitAction.fold, sizingBb: 0);
      case PlayerArchetype.callingStation:
        if (handStrength >= 1500000) {
          return (
            action: ExploitAction.raise,
            sizingBb: max(callBb * 2.5, potBb * 0.85),
          );
        }
        if (callBb <= potBb * 0.35) {
          return (action: ExploitAction.call, sizingBb: 0);
        }
        return (action: ExploitAction.fold, sizingBb: 0);
      case PlayerArchetype.maniac:
      case PlayerArchetype.lag:
        if (handStrength >= 2000000) {
          return (
            action: ExploitAction.raise,
            sizingBb: max(callBb * 2.4, potBb * 0.8),
          );
        }
        if (handStrength >= 1000000 || callBb <= potBb * 0.4) {
          return (action: ExploitAction.call, sizingBb: 0);
        }
        return (action: ExploitAction.fold, sizingBb: 0);
      default:
        if (!hasBoard && callBb <= 3 && handStrength >= 1100000) {
          return (action: ExploitAction.call, sizingBb: 0);
        }
        if (handStrength >= 2000000) {
          return (action: ExploitAction.call, sizingBb: 0);
        }
        if (callBb >= potBb * 0.55 && handStrength < 1500000) {
          return (action: ExploitAction.fold, sizingBb: 0);
        }
        return null;
    }
  }
}
