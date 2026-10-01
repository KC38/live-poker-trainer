/// Unit tests for deal-aware kicker showdown grading.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/course/kicker_showdown.dart';

void main() {
  group('kickerShowdownWinner', () {
    test('authored AQ vs AJ — you win on queen kicker', () {
      expect(
        kickerShowdownWinner(
          heroCodes: const ['Ah', 'Qd'],
          boardCodes: const ['Kh', 'Kd', '7c', '3s', '2d'],
          villainCodes: const ['As', 'Jd'],
        ),
        KickerShowdownWinner.you,
      );
    });

    test('remapped 98 vs AJ — they win on ace kicker', () {
      expect(
        kickerShowdownWinner(
          heroCodes: const ['9d', '8d'],
          boardCodes: const ['Kc', 'Ks', '7d', '3h', '2s'],
          villainCodes: const ['Ah', 'Js'],
        ),
        KickerShowdownWinner.they,
      );
    });

    test('matched kickers chop', () {
      expect(
        kickerShowdownWinner(
          heroCodes: const ['Ah', 'Qd'],
          boardCodes: const ['Kh', 'Kd', '7c', '3s', '2d'],
          villainCodes: const ['As', 'Qh'],
        ),
        KickerShowdownWinner.chop,
      );
    });
  });

  group('bank remap + feedback rewrite', () {
    const hero = ['9d', '8d'];
    const board = ['Kc', 'Ks', '7d', '3h', '2s'];
    const villain = ['Ah', 'Js'];

    test('tapping villain when they win grades as recommended bank id', () {
      final correct = kickerShowdownCorrectChoiceId(
        heroCodes: hero,
        boardCodes: board,
        villainCodes: villain,
      );
      expect(correct, KickerShowdownChoiceIds.they);
      expect(
        kickerShowdownBankChoiceId(
          tappedChoiceId: KickerShowdownChoiceIds.they,
          correctChoiceId: correct,
        ),
        KickerShowdownChoiceIds.you,
      );
      expect(
        kickerShowdownBankChoiceId(
          tappedChoiceId: KickerShowdownChoiceIds.you,
          correctChoiceId: correct,
        ),
        KickerShowdownChoiceIds.they,
      );
    });

    test('rewrite points Try: at deal-correct they-win', () {
      final rewritten = rewriteKickerShowdownResult(
        result: SubmitCourseStepResult(
          attemptId: 'a',
          activityId: kickerShowdownActivityId,
          grade: SoftGrade.clearMistake,
          feedback: 'Queen beats jack as kicker.',
          accepted: false,
          lifeLost: false,
          livesRemaining: 5,
          xpAwarded: 0,
          remediationRequired: false,
          resume: const CourseResumePointer(
            attemptId: 'a',
            lessonId: 'l',
            activityId: kickerShowdownActivityId,
            activityIndex: 0,
          ),
          duplicate: false,
          betterChoiceId: KickerShowdownChoiceIds.you,
        ),
        heroCodes: hero,
        boardCodes: board,
        villainCodes: villain,
      );
      expect(rewritten.betterChoiceId, KickerShowdownChoiceIds.they);
      expect(rewritten.feedback, contains('theirs wins'));
      expect(rewritten.feedback.toLowerCase(), isNot(contains('queen')));
    });
  });
}
