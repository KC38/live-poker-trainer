/// Action spots that claim deep stacks paint that depth on every seat
/// (LPT-417).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';

CourseActivity _act(String id, ActivityRenderer renderer) => CourseActivity(
  id: id,
  order: 2,
  stage: ActivityStage.scaffolded,
  renderer: renderer,
  estimatedSeconds: 50,
  accessibilityText: 'Deep stack spot.',
  acceptedGrades: const [SoftGrade.recommended],
  prompt: 'Deep stack spot.',
);

void main() {
  const expected = {
    'act-05-02-01-scaffolded': 500,
    'act-05-03-01-guided': 400,
    'act-06-09-01-scaffolded': 360,
    'act-04-10-01-checkpoint': 400,
  };

  test('deep-stack claims paint matching shared stacks (LPT-417)', () {
    for (final entry in expected.entries) {
      final renderer = entry.key == 'act-04-10-01-checkpoint'
          ? ActivityRenderer.fullTableHandLab
          : ActivityRenderer.pokerActionSizing;
      final spot = resolveLessonActionSpot(_act(entry.key, renderer))!;
      expect(spot.stackLabel, 'Stacks left ${entry.value}', reason: entry.key);
      expect(spot.heroStackAmount, entry.value, reason: entry.key);
      expect(spot.appliesStackToVillains, isTrue, reason: entry.key);
      expect(spot.villainStackChips, entry.value.toDouble());
      expect(spot.isShortStack, isFalse, reason: entry.key);
    }
  });

  test('short stacks still read as short (LPT-417)', () {
    expect(
      const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        stackLabel: 'Stack 12',
      ).isShortStack,
      isTrue,
    );
    expect(
      const LessonActionSpot(
        heroCodes: ['Ah', 'Kd'],
        stackLabel: 'Stacks left 60',
      ).isShortStack,
      isTrue,
    );
    expect(
      const LessonActionSpot(heroCodes: ['Ah', 'Kd']).isShortStack,
      isFalse,
    );
  });
}
