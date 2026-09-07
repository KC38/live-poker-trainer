/// Coach CORRECT / INCORRECT verdict for training decisions.
library;

import 'package:flutter/foundation.dart';
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
    this.evDeltaBb = 0,
    this.isSpeaking = false,
    this.voiceNote,
    this.repeatCount = 0,
    this.improvementStreak = 0,
    this.patternLabel,
  });

  final CoachVerdict verdict;
  final String message;
  final ExploitAction? optimalAction;
  final double optimalSizingBb;
  final String? heroAction;
  final double evDeltaBb;
  final bool isSpeaking;

  /// One-shot note when coach voice could not play (missing key, muted, etc.).
  final String? voiceNote;

  /// How many times this INCORRECT pattern has now occurred (0 / 1 = not a
  /// repeat, so no indicator is shown).
  final int repeatCount;

  /// Consecutive fixes of a previously-repeated leak (0 = not an improvement).
  final int improvementStreak;

  /// Coarse leak name for the repeat / improvement indicator.
  final String? patternLabel;

  bool get hasVerdict =>
      verdict == CoachVerdict.correct || verdict == CoachVerdict.incorrect;

  /// Whether the shelf should show a "Repeat ×N" indicator.
  bool get isRepeat => verdict == CoachVerdict.incorrect && repeatCount >= 2;

  /// Whether the shelf should show an "Improved" indicator.
  bool get isImprovement =>
      verdict == CoachVerdict.correct && improvementStreak >= 1;

  CoachFeedback copyWith({
    CoachVerdict? verdict,
    String? message,
    ExploitAction? optimalAction,
    double? optimalSizingBb,
    String? heroAction,
    double? evDeltaBb,
    bool? isSpeaking,
    String? voiceNote,
    bool clearVoiceNote = false,
    int? repeatCount,
    int? improvementStreak,
    String? patternLabel,
  }) {
    return CoachFeedback(
      verdict: verdict ?? this.verdict,
      message: message ?? this.message,
      optimalAction: optimalAction ?? this.optimalAction,
      optimalSizingBb: optimalSizingBb ?? this.optimalSizingBb,
      heroAction: heroAction ?? this.heroAction,
      evDeltaBb: evDeltaBb ?? this.evDeltaBb,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      voiceNote: clearVoiceNote ? null : (voiceNote ?? this.voiceNote),
      repeatCount: repeatCount ?? this.repeatCount,
      improvementStreak: improvementStreak ?? this.improvementStreak,
      patternLabel: patternLabel ?? this.patternLabel,
    );
  }
}
