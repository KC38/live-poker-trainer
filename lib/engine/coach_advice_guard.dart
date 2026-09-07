/// Post-process guard so coach copy never contradicts the graded best action.
///
/// Gemini (and occasionally offline leak prefixes) can urge calling while the
/// grade says fold, or fold while the grade says call. Every line shown or
/// spoken goes through [CoachAdviceGuard.reconcile] first.
library;

import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Validates and rewrites coach advice against a graded decision.
class CoachAdviceGuard {
  CoachAdviceGuard._();

  /// Returns [advice] when it agrees with [bestAction]; otherwise [fallback].
  ///
  /// Ungraded spots keep [advice] unless it is internally contradictory
  /// (e.g. "call most of the time" and "fold always" in one line), in which
  /// case [fallback] is used.
  static String reconcile({
    required String advice,
    required String fallback,
    required ExploitAction? bestAction,
    required CoachVerdict verdict,
  }) {
    final cleaned = advice.trim();
    if (cleaned.isEmpty) return fallback.trim().isEmpty ? cleaned : fallback;

    if (_internallyContradictory(cleaned)) {
      return fallback.trim().isEmpty ? cleaned : fallback;
    }

    if (!verdict.isGraded || bestAction == null) {
      return cleaned;
    }

    if (_contradictsBest(cleaned, bestAction)) {
      return fallback.trim().isEmpty ? cleaned : fallback;
    }
    return cleaned;
  }

  /// True when [text] urges an action that conflicts with [best].
  static bool contradictsBest(String text, ExploitAction best) =>
      _contradictsBest(text, best);

  /// True when a single line both urges continuing and folding.
  static bool isInternallyContradictory(String text) =>
      _internallyContradictory(text);

  static bool _contradictsBest(String text, ExploitAction best) {
    final lower = text.toLowerCase();
    final urgesFold = _urges(lower, _foldCue);
    final urgesCall = _urges(lower, _callCue);
    final urgesRaise = _urges(lower, _raiseCue);
    final urgesCheck = _urges(lower, _checkCue);

    switch (best) {
      case ExploitAction.fold:
        // Endorsing call / raise / "defend wider" fights a fold grade.
        return urgesCall || urgesRaise || _urges(lower, _defendCue);
      case ExploitAction.call:
        return urgesFold && !urgesCall;
      case ExploitAction.check:
        // "Don't bet / keep pot small" is fine; urging a raise or fold is not.
        return (urgesFold && !urgesCheck) || (urgesRaise && !urgesCheck);
      case ExploitAction.raise:
        return urgesFold && !urgesRaise;
    }
  }

  static bool _internallyContradictory(String text) {
    final lower = text.toLowerCase();
    final fold = _urges(lower, _foldCue);
    final call = _urges(lower, _callCue);
    final raise = _urges(lower, _raiseCue);
    // Classic reported bug: "call most of the time" AND "fold all the time".
    if (fold && call) return true;
    if (fold && raise) return true;
    return false;
  }

  /// Whether [text] contains an imperative / frequency cue from [patterns].
  static bool _urges(String lower, List<RegExp> patterns) {
    for (final pattern in patterns) {
      if (pattern.hasMatch(lower)) return true;
    }
    return false;
  }

  // Frequency / imperative forms that endorse an action. Mentions like
  // "instead of folding" are handled by negative lookbehind-ish alternation.
  static final _foldCue = <RegExp>[
    RegExp(r'\b(?:just |always |simply |should |must |better to )?fold(?:ing)?\b'),
    RegExp(r'\bgive\s+up\b'),
    RegExp(r'\bmuck\b'),
    RegExp(r'\bfold\s+(?:all|every|most)\b'),
    RegExp(r'\b(?:all|every|most)\s+the\s+time[^.]*fold'),
  ];

  static final _callCue = <RegExp>[
    RegExp(r'\b(?:just |always |simply |should |must |better to )?call(?:ing)?\b'),
    RegExp(r'\bdefend(?:ing)?\s+(?:wider|more)\b'),
    RegExp(r'\bcontinue\b'),
    RegExp(r'\bcall\s+(?:all|every|most)\b'),
    RegExp(r'\b(?:all|every|most)\s+the\s+time[^.]*call'),
  ];

  static final _raiseCue = <RegExp>[
    RegExp(r'\b(?:just |always |simply |should |must |better to )?rais(?:e|ing)\b'),
    RegExp(r'\b(?:just |always |simply |should |must |better to )?bet(?:ting)?\b'),
    RegExp(r'\b3-?bet\b'),
    RegExp(r'\bshove\b'),
  ];

  static final _checkCue = <RegExp>[
    RegExp(r'\b(?:just |always |simply |should |must |better to )?check(?:ing)?\b'),
  ];

  static final _defendCue = <RegExp>[
    RegExp(r'\bdefend(?:ing)?\s+(?:wider|more|here)\b'),
    RegExp(r'\bdo not fold\b'),
    RegExp(r"\bdon't fold\b"),
    RegExp(r'\bnever fold\b'),
  ];
}
