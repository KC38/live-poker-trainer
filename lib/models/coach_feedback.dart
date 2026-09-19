/// Coach feedback shown in the coach shelf (server edge coaching).
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/exploit_action.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/situation_model.dart';

/// Whether the hero matched an optimal line (optional; edges carry text only).
enum CoachVerdict {
  correct,
  incorrect,
  close,
  pending,
  none;

  bool get isGraded =>
      this == CoachVerdict.correct ||
      this == CoachVerdict.incorrect ||
      this == CoachVerdict.close;
}

/// Coach feedback shown in the coach shelf.
@immutable
class CoachFeedback {
  /// Creates coach feedback.
  const CoachFeedback({
    this.verdict = CoachVerdict.none,
    this.message = '',
    this.optimalAction,
    this.optimalActionLabel,
    this.optimalSizingBb = 0,
    this.heroAction,
    this.heroSizingBb = 0,
    this.evDeltaBb = 0,
    this.decisionStreet,
    this.isHistorical = false,
  });

  final CoachVerdict verdict;
  final String message;
  final ExploitAction? optimalAction;
  final String? optimalActionLabel;
  final double optimalSizingBb;
  final String? heroAction;
  final double heroSizingBb;
  final double evDeltaBb;
  final Street? decisionStreet;
  final bool isHistorical;

  bool get hasVerdict =>
      verdict == CoachVerdict.correct ||
      verdict == CoachVerdict.incorrect ||
      verdict == CoachVerdict.close;

  bool get isLiveGrade => hasVerdict && !isHistorical;

  bool get hasAdvice => message.isNotEmpty || hasVerdict;

  CoachFeedback asHistorical() => copyWith(isHistorical: true);

  /// Builds shelf feedback from a server [HeroActionEdge].
  factory CoachFeedback.fromHeroEdge({
    required HeroActionEdge edge,
    Street? street,
  }) {
    return CoachFeedback(
      verdict: switch (edge.verdict) {
        HeroActionVerdict.correct => CoachVerdict.correct,
        HeroActionVerdict.incorrect => CoachVerdict.incorrect,
        HeroActionVerdict.close => CoachVerdict.close,
      },
      message: edge.coaching,
      optimalAction: ExploitAction.fromString(edge.optimalActionKey),
      optimalActionLabel: edge.optimalActionKey,
      heroAction: edge.actionKey,
      evDeltaBb: edge.evDeltaBb,
      decisionStreet: street,
      isHistorical: false,
    );
  }

  CoachFeedback copyWith({
    CoachVerdict? verdict,
    String? message,
    ExploitAction? optimalAction,
    String? optimalActionLabel,
    double? optimalSizingBb,
    String? heroAction,
    double? heroSizingBb,
    double? evDeltaBb,
    Street? decisionStreet,
    bool clearDecisionStreet = false,
    bool? isHistorical,
  }) {
    return CoachFeedback(
      verdict: verdict ?? this.verdict,
      message: message ?? this.message,
      optimalAction: optimalAction ?? this.optimalAction,
      optimalActionLabel: optimalActionLabel ?? this.optimalActionLabel,
      optimalSizingBb: optimalSizingBb ?? this.optimalSizingBb,
      heroAction: heroAction ?? this.heroAction,
      heroSizingBb: heroSizingBb ?? this.heroSizingBb,
      evDeltaBb: evDeltaBb ?? this.evDeltaBb,
      decisionStreet:
          clearDecisionStreet ? null : (decisionStreet ?? this.decisionStreet),
      isHistorical: isHistorical ?? this.isHistorical,
    );
  }
}
