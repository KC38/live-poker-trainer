import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/lesson_split_map.dart';

void main() {
  test('expandCompletedLessonIds maps retired suits-and-ranks onto successors', () {
    const map = {
      'lesson-01-01-02-suits-and-ranks': [
        'lesson-01-01-02-01-suits',
        'lesson-01-01-02-02-ranks',
        'lesson-01-01-02-03-pairs-and-suited',
      ],
    };
    final expanded = expandCompletedLessonIds(
      ['lesson-01-01-01-your-two-cards', 'lesson-01-01-02-suits-and-ranks'],
      lessonSplitMap: map,
    );
    expect(expanded, contains('lesson-01-01-02-01-suits'));
    expect(expanded, contains('lesson-01-01-02-02-ranks'));
    expect(expanded, contains('lesson-01-01-02-03-pairs-and-suited'));
    expect(expanded, contains('lesson-01-01-02-suits-and-ranks'));
  });

  test('resolveSplitLessonId prefers first incomplete successor', () {
    const map = {
      'lesson-01-01-02-suits-and-ranks': [
        'lesson-01-01-02-01-suits',
        'lesson-01-01-02-02-ranks',
        'lesson-01-01-02-03-pairs-and-suited',
      ],
    };
    final live = {
      'lesson-01-01-02-01-suits',
      'lesson-01-01-02-02-ranks',
      'lesson-01-01-02-03-pairs-and-suited',
    };
    expect(
      resolveSplitLessonId(
        'lesson-01-01-02-suits-and-ranks',
        lessonSplitMap: map,
        completed: {'lesson-01-01-02-01-suits'},
        lessonExists: live.contains,
      ),
      'lesson-01-01-02-02-ranks',
    );
  });
}
