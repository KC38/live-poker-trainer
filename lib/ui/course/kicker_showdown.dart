/// Deal-aware grading helpers for the scaffolded kicker showdown activity.
///
/// Felt cards vary via isomorphic remap; authored bank grades always treat
/// `you-kicker` as recommended. Remap the submitted choice to the bank, then
/// rewrite feedback / better-choice so the UI names the deal-correct outcome.
library;

import 'package:live_poker_trainer/engine/deck_evaluator.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';

/// Scaffolded kicker showdown activity id.
const String kickerShowdownActivityId = 'act-01-02-02-scaffolded-kicker';

/// Who takes the pot on the dealt showdown.
enum KickerShowdownWinner {
  /// Hero's five-card hand is strictly best.
  you,

  /// Villain's five-card hand is strictly best.
  they,

  /// Best five-card hands tie.
  chop,
}

/// Choice ids authored for [kickerShowdownActivityId].
abstract final class KickerShowdownChoiceIds {
  /// Hero wins on kickers.
  static const you = 'you-kicker';

  /// Villain wins on kickers.
  static const they = 'they-kicker';

  /// Tied kickers / tied best five.
  static const chop = 'chop-kicker';
}

/// Evaluates who wins given hole and board codes.
KickerShowdownWinner kickerShowdownWinner({
  required List<String> heroCodes,
  required List<String> boardCodes,
  required List<String> villainCodes,
}) {
  if (heroCodes.length < 2 ||
      villainCodes.length < 2 ||
      boardCodes.length < 3) {
    return KickerShowdownWinner.chop;
  }
  final hero = DeckEvaluator.evaluate7Cards([
    for (final code in heroCodes) CardModel.fromCode(code),
    for (final code in boardCodes) CardModel.fromCode(code),
  ]).score;
  final villain = DeckEvaluator.evaluate7Cards([
    for (final code in villainCodes) CardModel.fromCode(code),
    for (final code in boardCodes) CardModel.fromCode(code),
  ]).score;
  if (hero > villain) return KickerShowdownWinner.you;
  if (villain > hero) return KickerShowdownWinner.they;
  return KickerShowdownWinner.chop;
}

/// Deal-correct choice id for the given hole and board codes.
String kickerShowdownCorrectChoiceId({
  required List<String> heroCodes,
  required List<String> boardCodes,
  required List<String> villainCodes,
}) {
  final winner = kickerShowdownWinner(
    heroCodes: heroCodes,
    boardCodes: boardCodes,
    villainCodes: villainCodes,
  );
  return switch (winner) {
    KickerShowdownWinner.you => KickerShowdownChoiceIds.you,
    KickerShowdownWinner.they => KickerShowdownChoiceIds.they,
    KickerShowdownWinner.chop => KickerShowdownChoiceIds.chop,
  };
}

/// Maps a semantic tap onto the bank choice the server grades.
///
/// The bank always recommends [KickerShowdownChoiceIds.you]. Correct taps
/// submit that id; misses submit another clear-mistake bank entry.
String kickerShowdownBankChoiceId({
  required String tappedChoiceId,
  required String correctChoiceId,
}) {
  if (tappedChoiceId == correctChoiceId) {
    return KickerShowdownChoiceIds.you;
  }
  if (tappedChoiceId == KickerShowdownChoiceIds.chop) {
    return KickerShowdownChoiceIds.chop;
  }
  return KickerShowdownChoiceIds.they;
}

/// Generic miss feedback when [correctChoiceId] is the deal winner.
String kickerShowdownMissFeedback(String correctChoiceId) {
  return switch (correctChoiceId) {
    KickerShowdownChoiceIds.you => 'Higher kicker takes it — yours wins.',
    KickerShowdownChoiceIds.they => 'Higher kicker takes it — theirs wins.',
    KickerShowdownChoiceIds.chop => 'Kickers match — this pot chops.',
    _ => 'Kickers decide when pairs match.',
  };
}

/// Rewrites bank feedback so "Try:" names the deal-correct outcome.
SubmitCourseStepResult rewriteKickerShowdownResult({
  required SubmitCourseStepResult result,
  required List<String> heroCodes,
  required List<String> boardCodes,
  required List<String> villainCodes,
}) {
  final correctId = kickerShowdownCorrectChoiceId(
    heroCodes: heroCodes,
    boardCodes: boardCodes,
    villainCodes: villainCodes,
  );
  if (result.accepted) {
    return SubmitCourseStepResult(
      attemptId: result.attemptId,
      activityId: result.activityId,
      grade: result.grade,
      feedback: 'Same pair; higher kicker wins.',
      accepted: result.accepted,
      lifeLost: result.lifeLost,
      livesRemaining: result.livesRemaining,
      xpAwarded: result.xpAwarded,
      remediationRequired: result.remediationRequired,
      resume: result.resume,
      duplicate: result.duplicate,
      betterChoiceId: null,
      reversalRead: result.reversalRead,
      masteryWeight: result.masteryWeight,
      livesNextRefillAtMs: result.livesNextRefillAtMs,
    );
  }
  return SubmitCourseStepResult(
    attemptId: result.attemptId,
    activityId: result.activityId,
    grade: result.grade,
    feedback: kickerShowdownMissFeedback(correctId),
    accepted: result.accepted,
    lifeLost: result.lifeLost,
    livesRemaining: result.livesRemaining,
    xpAwarded: result.xpAwarded,
    remediationRequired: result.remediationRequired,
    resume: result.resume,
    duplicate: result.duplicate,
    betterChoiceId: correctId,
    reversalRead: result.reversalRead,
    masteryWeight: result.masteryWeight,
    livesNextRefillAtMs: result.livesNextRefillAtMs,
  );
}

/// Remaps [semanticChoiceId] for [kickerShowdownActivityId] when codes are set.
String? remapKickerShowdownChoiceId({
  required String activityId,
  required String semanticChoiceId,
  required List<String>? heroCodes,
  required List<String>? boardCodes,
  required List<String>? villainCodes,
}) {
  if (activityId != kickerShowdownActivityId ||
      heroCodes == null ||
      boardCodes == null ||
      villainCodes == null ||
      heroCodes.length < 2 ||
      villainCodes.length < 2 ||
      boardCodes.length < 3) {
    return semanticChoiceId;
  }
  final correct = kickerShowdownCorrectChoiceId(
    heroCodes: heroCodes,
    boardCodes: boardCodes,
    villainCodes: villainCodes,
  );
  return kickerShowdownBankChoiceId(
    tappedChoiceId: semanticChoiceId,
    correctChoiceId: correct,
  );
}
