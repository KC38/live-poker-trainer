/// Locks starting-hand copy rewrite: chart labels, spoken names, boundaries.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_starting_hand_copy.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';

void main() {
  tearDown(() {
    debugFreezeLessonSuitRemap = false;
    lessonDealAttemptSalt = '';
  });

  test('startingHandLabelFromCodes orders ranks and names suitedness', () {
    expect(startingHandLabelFromCodes(const ['9h', 'Kh']), 'K9s');
    expect(startingHandLabelFromCodes(const ['Kd', '9h']), 'K9o');
    expect(startingHandLabelFromCodes(const ['Td', 'Th']), 'TT');
    expect(startingHandLabelFromCodes(const ['Kh']), isEmpty);
    expect(startingHandLabelFromCodes(const []), isEmpty);
  });

  test('alignStartingHandCopy leaves copy alone for the same chart hand', () {
    const text = 'Open king-nine suited on the button with K9s.';
    expect(
      alignStartingHandCopy(
        text: text,
        templateHero: const ['Kh', '9h'],
        dealtHero: const ['Kd', '9d'],
      ),
      text,
    );
    expect(
      alignStartingHandCopy(
        text: '',
        templateHero: const ['Kh', '9h'],
        dealtHero: const ['Th', '8h'],
      ),
      isEmpty,
    );
    expect(
      alignStartingHandCopy(
        text: 'K9s',
        templateHero: const ['Kh'],
        dealtHero: const ['Th', '8h'],
      ),
      'K9s',
    );
    expect(
      alignStartingHandCopy(
        text: 'K9s',
        templateHero: const ['Kh', '9h'],
        dealtHero: const ['8h'],
      ),
      'K9s',
    );
  });

  test('alignStartingHandCopy rewrites decade-compound Seventy-two trash', () {
    expect(
      alignStartingHandCopy(
        text: 'Seventy-two offsuit is not an open from UTG.',
        templateHero: const ['7h', '2d'],
        dealtHero: const ['8c', '5h'],
      ),
      'Eight-five offsuit is not an open from UTG.',
    );
    expect(
      alignStartingHandCopy(
        text: 'seventy-two offsuit folds under the gun.',
        templateHero: const ['7c', '2d'],
        dealtHero: const ['9d', '3c'],
      ),
      'nine-three offsuit folds under the gun.',
    );
  });

  test('alignStartingHandCopy rewrites sixes, case, and bare rank tokens', () {
    expect(
      alignStartingHandCopy(
        text: 'You have pocket sixes. Sixes fold to a 3-bet.',
        templateHero: const ['6h', '6d'],
        dealtHero: const ['Ah', 'Ad'],
      ),
      'You have pocket aces. Aces fold to a 3-bet.',
    );
    expect(
      alignStartingHandCopy(
        text: 'You hold pocket jacks.',
        templateHero: const ['Jh', 'Jd'],
        dealtHero: const ['Th', 'Td'],
      ),
      'You hold pocket tens.',
    );
    expect(
      alignStartingHandCopy(
        text: 'King-nine suited opens.',
        templateHero: const ['Kh', '9h'],
        dealtHero: const ['Th', '8h'],
      ),
      'Ten-eight suited opens.',
    );
    expect(
      alignStartingHandCopy(
        text: 'king-nine offsuit folds.',
        templateHero: const ['Kh', '9d'],
        dealtHero: const ['Th', '8c'],
      ),
      'ten-eight offsuit folds.',
    );
    expect(
      alignStartingHandCopy(
        text: 'Open K9, not only K9s.',
        templateHero: const ['9h', 'Kh'],
        dealtHero: const ['8d', 'Td'],
      ),
      'Open T8, not only T8s.',
    );
  });

  test('alignStartingHandCopy does not rewrite tokens inside longer words', () {
    expect(
      alignStartingHandCopy(
        text: 'XK9sY stays, but K9s opens.',
        templateHero: const ['Kh', '9h'],
        dealtHero: const ['Th', '8h'],
      ),
      'XK9sY stays, but T8s opens.',
    );
    expect(
      alignStartingHandCopy(
        text: 'Fold pocket aces. spaces stays. Aces reopen.',
        templateHero: const ['Ah', 'Ad'],
        dealtHero: const ['Kh', 'Kd'],
      ),
      'Fold pocket kings. spaces stays. Kings reopen.',
    );
    expect(
      alignStartingHandCopy(
        text: 'QQQ stays but QQ opens.',
        templateHero: const ['Qh', 'Qd'],
        dealtHero: const ['Kh', 'Kd'],
      ),
      'QQQ stays but KK opens.',
    );
    expect(
      alignStartingHandCopy(
        text: 'king-nine suitedness stays. king-nine suited opens.',
        templateHero: const ['Kh', '9h'],
        dealtHero: const ['Th', '8h'],
      ),
      'king-nine suitedness stays. ten-eight suited opens.',
    );
  });

  test(
    'alignStartingHandCopy skips pair plurals when the deal is not a pair',
    () {
      const text = 'Queens can mix. Open K9s.';
      expect(
        alignStartingHandCopy(
          text: text,
          templateHero: const ['Qh', 'Qd'],
          dealtHero: const ['Th', '8h'],
        ),
        text,
      );
    },
  );

  test('dealt queens spot rewrites felt and street copy to the dealt pair', () {
    final activity = _activity('act-04-02-01-guided');
    final dealt = _dealUntil(activity, differsFrom: 'QQ');
    final label = startingHandLabelFromCodes(dealt.heroCodes);

    expect(dealt.feltStatusLine, isNot(contains('Queens')));
    expect(dealt.feltStatusLine, isNot(contains('queens')));
    expect(dealt.streetLabel, isNot(contains('QQ')));
    expect(dealt.streetLabel, contains(label));
    expect(
      dealt.feltStatusLine,
      alignStartingHandCopy(
        text: 'Queens — 3-bet value',
        templateHero: const ['Qh', 'Qd'],
        dealtHero: dealt.heroCodes,
      ),
    );
    expect(
      dealt.streetLabel,
      alignStartingHandCopy(
        text: 'Preflop · Button · QQ',
        templateHero: const ['Qh', 'Qd'],
        dealtHero: dealt.heroCodes,
      ),
    );
  });

  test('dealt trash spot rewrites the 72o street token only', () {
    final activity = _activity('act-04-02-01-scaffolded');
    final dealt = _dealUntil(activity, differsFrom: '72o');
    final label = startingHandLabelFromCodes(dealt.heroCodes);

    expect(dealt.streetLabel, contains(label));
    expect(dealt.streetLabel, isNot(contains('72o')));
    expect(dealt.feltStatusLine, 'Trash vs 3-bet — fold');
  });

  test('frozen suit remap keeps authored queens copy', () {
    debugFreezeLessonSuitRemap = true;
    final dealt = dealtLessonActionSpot(_activity('act-04-02-01-guided'));
    expect(dealt, isNotNull);
    expect(startingHandLabelFromCodes(dealt!.heroCodes), 'QQ');
    expect(dealt.feltStatusLine, 'Queens — 3-bet value');
    expect(dealt.streetLabel, 'Preflop · Button · QQ');
  });

  test('graded feedback follows the dealt premium pair', () {
    final activity = _activity('act-02-03-01-scaffolded-qq');
    late int generation;
    late LessonActionSpot dealt;
    for (generation = 0; generation < 64; generation++) {
      final next = dealtLessonActionSpot(activity, generation: generation);
      expect(next, isNotNull);
      if (startingHandLabelFromCodes(next!.heroCodes) != 'QQ') {
        dealt = next;
        break;
      }
    }
    expect(generation, lessThan(64));
    final expected = alignStartingHandCopy(
      text: 'Never fold queens here.',
      templateHero: const ['Qh', 'Qd'],
      dealtHero: dealt.heroCodes,
    );
    final aligned = alignLessonActionSubmitResult(
      activity: activity,
      generation: generation,
      result: SubmitCourseStepResult(
        attemptId: 'attempt',
        activityId: activity.id,
        grade: SoftGrade.clearMistake,
        feedback: 'Never fold queens here.',
        accepted: false,
        lifeLost: true,
        livesRemaining: 0,
        xpAwarded: 0,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'attempt',
          lessonId: 'lesson-02-03-01-open-range',
          activityId: 'act-02-03-01-scaffolded-qq',
          activityIndex: 2,
        ),
        duplicate: false,
      ),
    );
    expect(aligned.feedback, expected);
    expect(aligned.feedback, isNot(contains('queens')));
  });

  test('graded UTG trash Oops follows remapped holes, not Seventy-two', () {
    final activity = _activity('act-02-03-01-guided-utg');
    late int generation;
    late LessonActionSpot dealt;
    for (generation = 0; generation < 64; generation++) {
      final next = dealtLessonActionSpot(activity, generation: generation);
      expect(next, isNotNull);
      if (startingHandLabelFromCodes(next!.heroCodes) != '72o') {
        dealt = next;
        break;
      }
    }
    expect(generation, lessThan(64));
    const bank = 'Seventy-two offsuit is not an open from UTG.';
    final expected = alignStartingHandCopy(
      text: bank,
      templateHero: const ['7h', '2d'],
      dealtHero: dealt.heroCodes,
    );
    final aligned = alignLessonActionSubmitResult(
      activity: activity,
      generation: generation,
      result: SubmitCourseStepResult(
        attemptId: 'attempt',
        activityId: activity.id,
        grade: SoftGrade.clearMistake,
        feedback: bank,
        accepted: false,
        lifeLost: false,
        livesRemaining: 5,
        xpAwarded: 0,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'attempt',
          lessonId: 'lesson-02-03-01-open-fold',
          activityId: 'act-02-03-01-guided-utg',
          activityIndex: 1,
        ),
        duplicate: false,
      ),
    );
    expect(aligned.feedback, expected);
    expect(aligned.feedback.toLowerCase(), isNot(contains('seventy-two')));
    expect(aligned.feedback.toLowerCase(), contains('offsuit'));
  });

  test('hand-families classify Hint follows remapped hero holes', () {
    final activity = CourseActivity(
      id: 'act-02-02-01-unguided-sc',
      order: 4,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText:
          'Look at seven-six suited on the felt — tap Suited connector.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Name the family for your holes.',
    );
    late int generation;
    late List<String> dealtHero;
    for (generation = 0; generation < 64; generation++) {
      final scene = dealtLessonTableScene(activity, generation: generation);
      expect(scene, isNotNull);
      if (startingHandLabelFromCodes(scene!.heroCodes) != '76s') {
        dealtHero = scene.heroCodes;
        break;
      }
    }
    expect(generation, lessThan(64));
    final expected = alignStartingHandCopy(
      text: activity.accessibilityText,
      templateHero: const ['7h', '6h'],
      dealtHero: dealtHero,
    );
    expect(
      alignLessonActionCopy(
        activity,
        activity.accessibilityText,
        generation: generation,
      ),
      expected,
    );
    expect(expected, isNot(contains('seven-six')));
    expect(
      lessonFrameHintFallback(activity, bindGeneration: generation),
      expected,
    );
  });

  test('hand-families checkpoint Hint follows remapped trash holes', () {
    final activity = CourseActivity(
      id: 'act-02-02-01-checkpoint-trash',
      order: 5,
      stage: ActivityStage.scaffolded,
      assessmentRole: AssessmentRole.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText:
          'Look at seven-two offsuit on the felt — tap Offsuit trash.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Name the family for your holes.',
    );
    late int generation;
    late List<String> dealtHero;
    for (generation = 0; generation < 64; generation++) {
      final scene = dealtLessonTableScene(activity, generation: generation);
      expect(scene, isNotNull);
      if (startingHandLabelFromCodes(scene!.heroCodes) != '72o') {
        dealtHero = scene.heroCodes;
        break;
      }
    }
    expect(generation, lessThan(64));
    final expected = alignStartingHandCopy(
      text: activity.accessibilityText,
      templateHero: const ['7c', '2d'],
      dealtHero: dealtHero,
    );
    expect(
      alignLessonActionCopy(
        activity,
        activity.accessibilityText,
        generation: generation,
      ),
      expected,
    );
    expect(expected, isNot(contains('seven-two')));
  });

  test('alignLessonTableCopy rewrites board codes and spoken ranks/suits', () {
    const prompt = 'Board Ks 9d 2c. You hold Kh Qh. Class?';
    const feedback = 'Pair of kings is already showdown-ready.';
    const oops = 'No jack in your hand.';
    const hintSuit = 'You need a heart or sometimes an ace.';
    expect(
      alignLessonTableCopy(
        text: prompt,
        templateHero: const ['Kh', 'Qh'],
        dealtHero: const ['Ac', 'Kc'],
        templateBoard: const ['Ks', '9d', '2c'],
        dealtBoard: const ['As', '8d', '6h'],
      ),
      'Board As 8d 6h. You hold Ac Kc. Class?',
    );
    expect(
      alignLessonTableCopy(
        text: feedback,
        templateHero: const ['Kh', 'Qh'],
        dealtHero: const ['Ac', 'Kc'],
        templateBoard: const ['Ks', '9d', '2c'],
        dealtBoard: const ['As', '8d', '6h'],
      ),
      'Pair of aces is already showdown-ready.',
    );
    expect(
      alignLessonTableCopy(
        text: oops,
        templateHero: const ['Ah', '9h'],
        dealtHero: const ['Qs', '6s'],
        templateBoard: const ['Jh', '8h', '3c'],
        dealtBoard: const ['Ts', '5s', '2h'],
      ),
      'No ten in your hand.',
    );
    expect(
      alignLessonTableCopy(
        text: hintSuit,
        templateHero: const ['Ah', '9h'],
        dealtHero: const ['Qs', '6s'],
        templateBoard: const ['Jh', '8h', '3c'],
        dealtBoard: const ['Ts', '5s', '2h'],
      ),
      'You need a spade or sometimes a queen.',
    );
  });

  test('alignLessonTableCopy rewrites the hero phrase before board ranks', () {
    // Board six→ten would turn "six-five" into "ten-four" if rank words ran
    // first, and the dealt "eight-four" phrase would never land (LPT-261).
    const text = 'six-five offsuit. The six is on the board.';
    expect(
      alignLessonTableCopy(
        text: text,
        templateHero: const ['6h', '5d'],
        dealtHero: const ['8c', '4s'],
        templateBoard: const ['6s', '9d', '2c'],
        dealtBoard: const ['Ts', '9d', '2c'],
      ),
      'eight-four offsuit. The ten is on the board.',
    );
    expect(
      alignLessonTableCopy(
        text: 'Board 6S.',
        templateHero: const ['6h', '5d'],
        dealtHero: const ['8c', '4s'],
        templateBoard: const ['6s', '9d', '2c'],
        dealtBoard: const ['Ts', '9d', '2c'],
      ),
      'Board Ts.',
    );
  });

  test('alignLessonTableCopy fixes a/an after rank words move', () {
    expect(
      alignLessonTableCopy(
        text: 'You need a nine. A nine shows up.',
        templateHero: const ['Kh', 'Qh'],
        dealtHero: const ['Kh', 'Qh'],
        templateBoard: const ['9d'],
        dealtBoard: const ['8d'],
      ),
      'You need an eight. An eight shows up.',
    );
    expect(
      alignLessonTableCopy(
        text: 'You need an eight. An eight shows up.',
        templateHero: const ['Kh', 'Qh'],
        dealtHero: const ['Kh', 'Qh'],
        templateBoard: const ['8d'],
        dealtBoard: const ['9d'],
      ),
      'You need a nine. A nine shows up.',
    );
    expect(
      alignLessonTableCopy(
        text: 'Draw to hearts, not a heart.',
        templateHero: const ['Ah', '9h'],
        dealtHero: const ['As', '9s'],
        templateBoard: const ['Jh', '8h', '3c'],
        dealtBoard: const ['Js', '8s', '3c'],
      ),
      'Draw to spades, not a spade.',
    );
  });

  test(
    'alignLessonTableCopy leaves stray rank words when the board is absent',
    () {
      expect(
        alignLessonTableCopy(
          text: '',
          templateHero: const ['6h', '5d'],
          dealtHero: const ['8c', '4s'],
          templateBoard: const ['6s'],
          dealtBoard: const ['Ts'],
        ),
        isEmpty,
      );
      expect(
        alignLessonTableCopy(
          text: 'six-five offsuit. The six misses.',
          templateHero: const ['6h', '5d'],
          dealtHero: const ['8c', '4s'],
        ),
        'eight-four offsuit. The six misses.',
      );
    },
  );

  test('flop-class guided prompt and Nice follow remapped board+holes', () {
    final activity = CourseActivity(
      id: 'act-03-02-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Top pair is a made hand.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Board Ks 9d 2c. You hold Kh Qh. Class?',
    );
    late int generation;
    late List<String> dealtHero;
    late List<String> dealtBoard;
    for (generation = 0; generation < 64; generation++) {
      final scene = dealtLessonTableScene(activity, generation: generation);
      expect(scene, isNotNull);
      final sameHero = scene!.heroCodes.join() == 'KhQh';
      final sameBoard = scene.boardCodes.join() == 'Ks9d2c';
      if (!sameHero || !sameBoard) {
        dealtHero = scene.heroCodes;
        dealtBoard = scene.boardCodes;
        break;
      }
    }
    expect(generation, lessThan(64));
    final expectedPrompt = alignLessonTableCopy(
      text: activity.prompt!,
      templateHero: const ['Kh', 'Qh'],
      dealtHero: dealtHero,
      templateBoard: const ['Ks', '9d', '2c'],
      dealtBoard: dealtBoard,
    );
    expect(
      alignLessonActionCopy(activity, activity.prompt!, generation: generation),
      expectedPrompt,
    );
    expect(expectedPrompt, isNot(contains('Ks')));
    expect(expectedPrompt, isNot(contains('Kh Qh')));
    for (final code in [...dealtHero, ...dealtBoard]) {
      expect(expectedPrompt.toLowerCase(), contains(code.toLowerCase()));
    }
    const bankNice = 'Pair of kings is already showdown-ready.';
    final expectedNice = alignLessonTableCopy(
      text: bankNice,
      templateHero: const ['Kh', 'Qh'],
      dealtHero: dealtHero,
      templateBoard: const ['Ks', '9d', '2c'],
      dealtBoard: dealtBoard,
    );
    expect(
      alignLessonActionCopy(activity, bankNice, generation: generation),
      expectedNice,
    );
    expect(expectedNice.toLowerCase(), isNot(contains('king')));
    expect(
      lessonFrameSpeech(activity, bindGeneration: generation),
      '$expectedPrompt Tap the best answer.',
    );
  });

  test('flop-class scaffolded Oops follows remapped board rank', () {
    final activity = CourseActivity(
      id: 'act-03-02-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Nut flush draw with overcard equity.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Board Jh 8h 3c. You hold Ah 9h. Class?',
    );
    late int generation;
    late List<String> dealtHero;
    late List<String> dealtBoard;
    for (generation = 0; generation < 128; generation++) {
      final scene = dealtLessonTableScene(activity, generation: generation);
      expect(scene, isNotNull);
      // Need the board jack rank to move so "No jack" must rewrite.
      final board = scene!.boardCodes;
      if (board.isEmpty) continue;
      if (CardModel.fromCode(board[0]).rank == 11) continue;
      dealtHero = scene.heroCodes;
      dealtBoard = board;
      break;
    }
    expect(generation, lessThan(128));
    const bankOops = 'No jack in your hand.';
    final expected = alignLessonTableCopy(
      text: bankOops,
      templateHero: const ['Ah', '9h'],
      dealtHero: dealtHero,
      templateBoard: const ['Jh', '8h', '3c'],
      dealtBoard: dealtBoard,
    );
    expect(
      alignLessonActionCopy(activity, bankOops, generation: generation),
      expected,
    );
    expect(expected.toLowerCase(), isNot(contains('jack')));
    expect(
      alignLessonActionCopy(activity, activity.prompt!, generation: generation),
      isNot(contains('Jh')),
    );
  });
}

CourseActivity _activity(String id) {
  return CourseActivity(
    id: id,
    order: 1,
    stage: ActivityStage.guided,
    renderer: ActivityRenderer.pokerActionSizing,
    estimatedSeconds: 30,
    accessibilityText: 'Action',
    acceptedGrades: const [SoftGrade.recommended],
  );
}

LessonActionSpot _dealUntil(
  CourseActivity activity, {
  required String differsFrom,
}) {
  for (var generation = 0; generation < 64; generation++) {
    final dealt = dealtLessonActionSpot(activity, generation: generation);
    expect(dealt, isNotNull, reason: activity.id);
    if (startingHandLabelFromCodes(dealt!.heroCodes) != differsFrom) {
      return dealt;
    }
  }
  fail('${activity.id} never left $differsFrom');
}
