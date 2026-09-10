/// Coach CORRECT / INCORRECT verdict for training decisions.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Whether the hero matched the optimal exploit line.
enum CoachVerdict {
  correct,
  incorrect,
  pending,
  none;

  /// Whether this verdict represents a real graded decision.
  bool get isGraded =>
      this == CoachVerdict.correct || this == CoachVerdict.incorrect;
}

/// Coach feedback shown in the coach shelf and EV audit.
@immutable
class CoachFeedback {
  /// Creates coach feedback.
  const CoachFeedback({
    this.verdict = CoachVerdict.none,
    this.message = '',
    this.optimalAction,
    this.optimalSizingBb = 0,
    this.heroAction,
    this.heroSizingBb = 0,
    this.evDeltaBb = 0,
    this.repeatCount = 0,
    this.improvementStreak = 0,
    this.patternLabel,
    this.decisionStreet,
    this.isHistorical = false,
  });

  final CoachVerdict verdict;
  final String message;
  final ExploitAction? optimalAction;
  final double optimalSizingBb;
  final String? heroAction;

  /// Hero bet / raise size in big blinds (0 for passive actions).
  final double heroSizingBb;
  final double evDeltaBb;

  /// How many times this INCORRECT pattern has now occurred (0 / 1 = not a
  /// repeat, so no indicator is shown).
  final int repeatCount;

  /// Consecutive fixes of a previously-repeated leak (0 = not an improvement).
  final int improvementStreak;

  /// Coarse leak name for the repeat / improvement indicator.
  final String? patternLabel;

  /// Street the graded decision belonged to (null for deal intros).
  final Street? decisionStreet;

  /// True when this grade is from an earlier street and must not look like
  /// live advice for the current act.
  final bool isHistorical;

  bool get hasVerdict =>
      verdict == CoachVerdict.correct || verdict == CoachVerdict.incorrect;

  /// Live CORRECT/INCORRECT for the action just taken (not shelved).
  bool get isLiveGrade => hasVerdict && !isHistorical;

  /// Whether the shelf has post-action coaching to show.
  bool get hasAdvice => message.isNotEmpty || hasVerdict;

  /// Whether the shelf should show a "Repeat ×N" indicator.
  bool get isRepeat =>
      !isHistorical && verdict == CoachVerdict.incorrect && repeatCount >= 2;

  /// Whether the shelf should show an "Improved" indicator.
  bool get isImprovement =>
      !isHistorical && verdict == CoachVerdict.correct && improvementStreak >= 1;

  /// Marks this feedback as a previous decision (keeps stats, softens UI).
  CoachFeedback asHistorical() => copyWith(isHistorical: true);

  CoachFeedback copyWith({
    CoachVerdict? verdict,
    String? message,
    ExploitAction? optimalAction,
    double? optimalSizingBb,
    String? heroAction,
    double? heroSizingBb,
    double? evDeltaBb,
    int? repeatCount,
    int? improvementStreak,
    String? patternLabel,
    Street? decisionStreet,
    bool clearDecisionStreet = false,
    bool? isHistorical,
  }) {
    return CoachFeedback(
      verdict: verdict ?? this.verdict,
      message: message ?? this.message,
      optimalAction: optimalAction ?? this.optimalAction,
      optimalSizingBb: optimalSizingBb ?? this.optimalSizingBb,
      heroAction: heroAction ?? this.heroAction,
      heroSizingBb: heroSizingBb ?? this.heroSizingBb,
      evDeltaBb: evDeltaBb ?? this.evDeltaBb,
      repeatCount: repeatCount ?? this.repeatCount,
      improvementStreak: improvementStreak ?? this.improvementStreak,
      patternLabel: patternLabel ?? this.patternLabel,
      decisionStreet: clearDecisionStreet
          ? null
          : (decisionStreet ?? this.decisionStreet),
      isHistorical: isHistorical ?? this.isHistorical,
    );
  }
}
