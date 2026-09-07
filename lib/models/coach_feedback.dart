/// Coach CORRECT / INCORRECT verdict for Practice mode.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Whether the hero matched the optimal exploit line.
enum CoachVerdict { correct, incorrect, pending, none }

/// Coach feedback shown in the coach shelf and EV audit.
@immutable
class CoachFeedback {
  /// Creates coach feedback.
  const CoachFeedback({
    this.verdict = CoachVerdict.none,
    this.message = '',
    this.optimalAction,
    this.heroAction,
    this.evDeltaBb = 0,
    this.isSpeaking = false,
  });

  final CoachVerdict verdict;
  final String message;
  final ExploitAction? optimalAction;
  final String? heroAction;
  final double evDeltaBb;
  final bool isSpeaking;

  bool get hasVerdict =>
      verdict == CoachVerdict.correct || verdict == CoachVerdict.incorrect;

  CoachFeedback copyWith({
    CoachVerdict? verdict,
    String? message,
    ExploitAction? optimalAction,
    String? heroAction,
    double? evDeltaBb,
    bool? isSpeaking,
  }) {
    return CoachFeedback(
      verdict: verdict ?? this.verdict,
      message: message ?? this.message,
      optimalAction: optimalAction ?? this.optimalAction,
      heroAction: heroAction ?? this.heroAction,
      evDeltaBb: evDeltaBb ?? this.evDeltaBb,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}
