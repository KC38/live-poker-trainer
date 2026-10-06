/// Locks starting-hand copy rewrite: chart labels, spoken names, boundaries.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_starting_hand_copy.dart';

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
