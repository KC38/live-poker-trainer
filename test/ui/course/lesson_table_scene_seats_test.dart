/// Locks felt scenes that must not invent a face-down Them rail.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';

CourseActivity _activity(String id) {
  return CourseActivity(
    id: id,
    order: 1,
    stage: ActivityStage.guided,
    renderer: ActivityRenderer.selectIdentify,
    estimatedSeconds: 30,
    accessibilityText: 'Seat regression',
    acceptedGrades: const [SoftGrade.recommended],
  );
}

void main() {
  test('outcome felts that teach no villain stay clear of Them', () {
    const clear = <String>[
      'act-04-01-01-guided',
      'act-04-01-01-scaffolded',
      'act-04-05-01-guided',
      'act-06-09-01-guided',
      'act-06-09-01-unguided',
      'act-06-09-01-checkpoint',
    ];
    for (final id in clear) {
      expect(
        resolveLessonTableScene(_activity(id))?.villainSeatCount,
        0,
        reason: id,
      );
    }
  });

  test('range spots that show a real opponent keep one Them seat', () {
    const withOpponent = <String>[
      'act-04-01-01-unguided',
      'act-04-01-01-checkpoint',
    ];
    for (final id in withOpponent) {
      expect(
        resolveLessonTableScene(_activity(id))?.villainSeatCount,
        1,
        reason: id,
      );
    }
  });
}
