/// Unit tests for lesson XP preview / display helpers.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';

void main() {
  test('previewLessonXp matches server perfect-run total', () {
    expect(previewLessonXp(0), kXpLessonComplete);
    expect(previewLessonXp(-3), kXpLessonComplete);
    expect(previewLessonXp(1), kXpPerAcceptedStep + kXpLessonComplete);
    expect(previewLessonXp(5), 5 * kXpPerAcceptedStep + kXpLessonComplete);
  });

  test('reviewLessonXp is one quarter of the perfect-run preview', () {
    expect(reviewLessonXp(0), 0);
    expect(reviewLessonXp(40), 10);
    expect(reviewLessonXp(25), 6);
    expect(reviewLessonXp(35), 9);
  });

  test('displayedLessonXp prefers the larger local or server total', () {
    expect(
      displayedLessonXp(stepXpAwarded: 20, completionBonus: 25),
      45,
    );
    expect(
      displayedLessonXp(
        stepXpAwarded: 10,
        completionBonus: 25,
        lessonXpFromServer: 55,
      ),
      55,
    );
    expect(
      displayedLessonXp(
        stepXpAwarded: 40,
        completionBonus: 25,
        lessonXpFromServer: 50,
      ),
      65,
    );
  });
}
