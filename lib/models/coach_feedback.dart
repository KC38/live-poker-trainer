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
  ///
  /// When [node] is provided, BEST uses the optimal edge's kind / sizing so
  /// opaque authored keys (e.g. `act_hero_pf_3bet`) never appear in the UI.
  factory CoachFeedback.fromHeroEdge({
    required HeroActionEdge edge,
    Street? street,
    HeroDecisionNode? node,
    double bigBlind = 0,
  }) {
    final optimalEdge =
        node?.edgeForKey(edge.optimalActionKey) ??
        (edge.optimalActionKey.toUpperCase() == edge.actionKey.toUpperCase()
            ? edge
            : null);
    final optimalKind = optimalEdge?.kind;
    final heroLabel = ActionDisplayLabel.resolve(
      actionKey: edge.actionKey,
      kind: edge.kind,
    );
    final optimalLabel = ActionDisplayLabel.resolve(
      actionKey: edge.optimalActionKey,
      kind: optimalKind,
    );
    final heroSizingBb = _sizingBb(edge.amountTo, bigBlind);
    final optimalSizingBb = _sizingBb(optimalEdge?.amountTo, bigBlind);

    return CoachFeedback(
      verdict: switch (edge.verdict) {
        HeroActionVerdict.correct => CoachVerdict.correct,
        HeroActionVerdict.incorrect => CoachVerdict.incorrect,
        HeroActionVerdict.close => CoachVerdict.close,
      },
      message: edge.coaching,
      optimalAction:
          optimalKind != null
              ? ExploitAction.fromKind(optimalKind)
              : ExploitAction.fromString(edge.optimalActionKey),
      optimalActionLabel: optimalLabel,
      optimalSizingBb: optimalSizingBb,
      heroAction: heroLabel,
      heroSizingBb: heroSizingBb,
      evDeltaBb: edge.evDeltaBb,
      decisionStreet: street,
      isHistorical: false,
    );
  }

  static double _sizingBb(double? amountTo, double bigBlind) {
    if (amountTo == null || amountTo <= 0 || bigBlind <= 0) return 0;
    return amountTo / bigBlind;
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
