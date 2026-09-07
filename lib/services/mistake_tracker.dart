/// Turns a live-coach grade into persisted mistake / improvement history.
///
/// Sits between `GameController` and `MistakeDao`: every graded hero decision
/// is checked against the user's leak history so the coach can say "that's
/// the third time" or "nice, last time you raised here" before narrating.
library;

import 'package:live_poker_trainer/core/database/mistake_dao.dart';
import 'package:live_poker_trainer/engine/live_coach.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';

/// Outcome of checking one graded decision against leak history.
class LeakCheck {
  /// Creates a leak check result.
  const LeakCheck({this.repeat, this.improvement, this.mistakeId});

  /// Set for INCORRECT verdicts (even first occurrences, so callers can
  /// inspect the count); `repeat.isRepeat` tells whether it recurred.
  final RepeatInfo? repeat;

  /// Set for CORRECT verdicts that fix a previously repeated leak.
  final ImprovementInfo? improvement;

  /// Row id of the persisted mistake (INCORRECT only).
  final int? mistakeId;

  /// Empty result for ungraded spots or storage failures.
  static const none = LeakCheck();
}

/// Persists mistakes, detects repeats, and credits improvements.
class MistakeTracker {
  /// Creates a tracker over [dao].
  MistakeTracker(this.dao);

  final MistakeDao dao;

  /// Records [grade] and returns repeat / improvement context.
  ///
  /// Never throws: leak tracking is best-effort and must not stall play.
  Future<LeakCheck> track({
    required LiveCoachGrade grade,
    required String sessionId,
    required String handId,
    String? decisionId,
    required double bigBlind,
    required double heroAmount,
  }) async {
    final pattern = grade.pattern;
    if (pattern == null) return LeakCheck.none;
    try {
      if (grade.verdict == CoachVerdict.incorrect) {
        final result = await dao.recordMistake(
          sessionId: sessionId,
          handId: handId,
          decisionId: decisionId,
          pattern: pattern,
          heroAmount: heroAmount,
          bestSizingBb: grade.optimalSizingBb,
          evDeltaBb: grade.evDeltaBb,
          evDeltaDollars: grade.evDeltaBb * bigBlind,
          adviceText: grade.message,
        );
        return LeakCheck(repeat: result.repeat, mistakeId: result.id);
      }
      if (grade.verdict == CoachVerdict.correct) {
        final improvement = await dao.findImprovement(pattern: pattern);
        if (improvement == null) return LeakCheck.none;
        await dao.recordImprovement(
          sessionId: sessionId,
          handId: handId,
          decisionId: decisionId,
          improvement: improvement,
          pattern: pattern,
        );
        return LeakCheck(improvement: improvement);
      }
    } catch (_) {
      // Best-effort: a DB hiccup must never block the table.
    }
    return LeakCheck.none;
  }

  /// Stores the final advice text (e.g. the Gemini line) on a mistake row.
  Future<void> saveAdvice(int? mistakeId, String text) async {
    if (mistakeId == null || text.trim().isEmpty) return;
    try {
      await dao.updateAdvice(mistakeId, text);
    } catch (_) {
      // Best-effort.
    }
  }
}
