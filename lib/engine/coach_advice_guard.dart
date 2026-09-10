/// Post-process guard so coach copy never contradicts the graded decision.
///
/// Claude (and occasionally offline leak prefixes) can urge the wrong action,
/// invent aggressors, mis-quote equity, or drift off the curriculum spine.
/// Every line shown or spoken goes through [CoachAdviceGuard.reconcile] first.
library;

import 'package:live_poker_trainer/engine/coach_lines.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/scenario_model.dart';

/// Validates and rewrites coach advice against a graded decision.
class CoachAdviceGuard {
  CoachAdviceGuard._();

  /// Returns [advice] when it agrees with the grade; otherwise [fallback].
  ///
  /// Ungraded spots keep [advice] unless it is internally contradictory
  /// (e.g. "call most of the time" and "fold always" in one line), in which
  /// case [fallback] is used.
  ///
  /// Optional narration facts ([street], [equityPercent], aggressor flag,
  /// [reasonCodes], [villainArchetype]) tighten checks beyond action verbs —
  /// wrong street / equity, invented aggression, or missing curriculum phrases
  /// fall back to the offline line.
  static String reconcile({
    required String advice,
    required String fallback,
    required ExploitAction? bestAction,
    required CoachVerdict verdict,
    Street? street,
    int? equityPercent,
    int? requiredEquityPercent,
    int? villainAirPercent,
    bool? villainIsAggressor,
    List<CoachReasonCode> reasonCodes = const [],
    PlayerArchetype? villainArchetype,
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

    if (_contradictsFacts(
      cleaned,
      street: street,
      equityPercent: equityPercent,
      requiredEquityPercent: requiredEquityPercent,
      villainAirPercent: villainAirPercent,
      villainIsAggressor: villainIsAggressor,
      reasonCodes: reasonCodes,
      villainArchetype: villainArchetype,
    )) {
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

  /// True when [text] misstates grade facts or drops the curriculum spine.
  ///
  /// Null / empty optional facts skip that check so callers without a full
  /// grade stay on the action-verb path only.
  static bool contradictsFacts(
    String text, {
    Street? street,
    int? equityPercent,
    int? requiredEquityPercent,
    int? villainAirPercent,
    bool? villainIsAggressor,
    List<CoachReasonCode> reasonCodes = const [],
    PlayerArchetype? villainArchetype,
  }) =>
      _contradictsFacts(
        text,
        street: street,
        equityPercent: equityPercent,
        requiredEquityPercent: requiredEquityPercent,
        villainAirPercent: villainAirPercent,
        villainIsAggressor: villainIsAggressor,
        reasonCodes: reasonCodes,
        villainArchetype: villainArchetype,
      );

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

  static bool _contradictsFacts(
    String text, {
    Street? street,
    int? equityPercent,
    int? requiredEquityPercent,
    int? villainAirPercent,
    bool? villainIsAggressor,
    List<CoachReasonCode> reasonCodes = const [],
    PlayerArchetype? villainArchetype,
  }) {
    final lower = text.toLowerCase();

    if (street != null && _wrongStreet(lower, street)) return true;

    if (equityPercent != null &&
        _equityFactsFail(
          lower,
          equityPercent: equityPercent,
          requiredEquityPercent: requiredEquityPercent,
          villainAirPercent: villainAirPercent,
        )) {
      return true;
    }

    if (villainIsAggressor == false && _inventsAggressor(lower)) {
      return true;
    }

    if (reasonCodes.isNotEmpty && !_mentionsReason(lower, reasonCodes)) {
      return true;
    }

    if (villainArchetype != null &&
        villainArchetype != PlayerArchetype.hero &&
        !_mentionsArchetype(lower, villainArchetype)) {
      return true;
    }

    return false;
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

  /// Graded street missing, or a different street named.
  static bool _wrongStreet(String lower, Street graded) {
    final mentioned = <Street>{};
    if (_preflopRe.hasMatch(lower)) mentioned.add(Street.preflop);
    // Strip preflop so "flop" inside "preflop" is not double-counted.
    final withoutPre = lower.replaceAll(_preflopRe, ' ');
    if (_flopRe.hasMatch(withoutPre)) mentioned.add(Street.flop);
    if (_turnRe.hasMatch(lower)) mentioned.add(Street.turn);
    if (_riverRe.hasMatch(lower)) mentioned.add(Street.river);
    if (_showdownRe.hasMatch(lower)) mentioned.add(Street.showdown);

    if (mentioned.isEmpty) return true;
    if (!mentioned.contains(graded)) return true;
    // Any other street named alongside the graded one is a drift.
    if (mentioned.any((s) => s != graded)) return true;
    return false;
  }

  /// Missing equity/price quote, or a `%` that is not a locked grade number.
  static bool _equityFactsFail(
    String lower, {
    required int equityPercent,
    int? requiredEquityPercent,
    int? villainAirPercent,
  }) {
    if (!_hasPercent(lower, equityPercent)) return true;
    if (requiredEquityPercent != null &&
        requiredEquityPercent > 0 &&
        !_hasPercent(lower, requiredEquityPercent)) {
      return true;
    }

    final allowed = <int>{equityPercent};
    if (requiredEquityPercent != null && requiredEquityPercent > 0) {
      allowed.add(requiredEquityPercent);
    }
    if (villainAirPercent != null) {
      allowed.add(villainAirPercent);
    }
    for (final match in _percentRe.allMatches(lower)) {
      final raw = match.group(1);
      if (raw == null) continue;
      final value = int.tryParse(raw);
      if (value == null) continue;
      if (!allowed.contains(value)) return true;
    }
    return false;
  }

  static bool _hasPercent(String lower, int value) =>
      RegExp('\\b$value\\s*(?:%|percent\\b)').hasMatch(lower);

  /// Language that invents a voluntary bet/raise when the villain did not.
  static bool _inventsAggressor(String lower) {
    for (final pattern in _aggressorCue) {
      if (pattern.hasMatch(lower)) return true;
    }
    return false;
  }

  /// At least one curriculum [phrase] or [CoachReasonCode.id] appears.
  static bool _mentionsReason(
    String lower,
    List<CoachReasonCode> codes,
  ) {
    for (final code in codes) {
      if (lower.contains(code.phrase.toLowerCase())) return true;
      final idAsWords = code.id.replaceAll('_', ' ');
      if (lower.contains(idAsWords)) return true;
      if (lower.contains(code.id)) return true;
    }
    return false;
  }

  static bool _mentionsArchetype(String lower, PlayerArchetype archetype) {
    return switch (archetype) {
      PlayerArchetype.nit => lower.contains('nit'),
      PlayerArchetype.lag =>
        lower.contains('lag') ||
            lower.contains('loose-aggressive') ||
            lower.contains('loose aggressive'),
      PlayerArchetype.tag =>
        RegExp(r'\btag\b').hasMatch(lower) ||
            lower.contains('solid player') ||
            lower.contains('solid players'),
      PlayerArchetype.callingStation =>
        lower.contains('station') || lower.contains('calling station'),
      PlayerArchetype.maniac => lower.contains('maniac'),
      PlayerArchetype.hero => true,
    };
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

  static final _aggressorCue = <RegExp>[
    RegExp(r'\b(?:fired|firing|fires)\b'),
    RegExp(r'\b(?:led|leads|leading)\s+(?:into|out|at|the)\b'),
    RegExp(
      r'\b(?:they|villain|opponent|nit|lag|tag|station|maniac)\s+'
      r'(?:bet|bets|betting|raised|raises|raising)\b',
    ),
    RegExp(r'\b(?:bet|raised)\s+(?:into\s+you|you)\b'),
  ];

  static final _preflopRe = RegExp(r'\bpre-?\s*flop\b');
  static final _flopRe = RegExp(r'\bflop\b');
  static final _turnRe = RegExp(r'\bturn\b');
  static final _riverRe = RegExp(r'\briver\b');
  static final _showdownRe = RegExp(r'\bshowdown\b');
  // `%` is non-word, so do not require a trailing \b after it (breaks "22%.").
  static final _percentRe = RegExp(r'\b(\d{1,3})\s*(?:%|percent\b)');
}
