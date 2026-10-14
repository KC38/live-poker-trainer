import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
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

  test('expandCompletedLessonIds leaves successors locked until the retired id is done', () {
    const map = {
      'retired-a': ['lesson-a', 'lesson-b'],
      'retired-b': ['lesson-c'],
    };
    final expanded = expandCompletedLessonIds([
      'lesson-a',
      'retired-b',
    ], lessonSplitMap: map);
    expect(expanded, {'lesson-a', 'retired-b', 'lesson-c'});
    expect(expanded.contains('lesson-b'), isFalse);
    expect(expandCompletedLessonIds(['lesson-a'], lessonSplitMap: const {}), {
      'lesson-a',
    });
  });

  test('resolveSplitLessonId keeps a live id and fails closed when nothing matches', () {
    const map = {
      'retired': ['missing', 'lesson-b', 'lesson-c'],
      'empty': <String>[],
    };
    bool live(String id) =>
        id == 'lesson-b' || id == 'lesson-c' || id == 'lesson-live';

    expect(
      resolveSplitLessonId(
        'lesson-live',
        lessonSplitMap: map,
        completed: const {},
        lessonExists: live,
      ),
      'lesson-live',
    );
    expect(
      resolveSplitLessonId(
        'unknown',
        lessonSplitMap: map,
        completed: const {},
        lessonExists: live,
      ),
      isNull,
    );
    expect(
      resolveSplitLessonId(
        'empty',
        lessonSplitMap: map,
        completed: const {},
        lessonExists: live,
      ),
      isNull,
    );
    expect(
      resolveSplitLessonId(
        'retired',
        lessonSplitMap: map,
        completed: const {'lesson-b'},
        lessonExists: live,
      ),
      'lesson-c',
    );
    expect(
      resolveSplitLessonId(
        'retired',
        lessonSplitMap: map,
        completed: const {'lesson-b', 'lesson-c'},
        lessonExists: live,
      ),
      'lesson-c',
    );
    expect(
      resolveSplitLessonId(
        'retired',
        lessonSplitMap: const {
          'retired': ['gone'],
        },
        completed: const {'gone'},
        lessonExists: live,
      ),
      isNull,
    );
  });

  test('catalog parse keeps list successors and drops non-lists', () {
    final catalog = CourseCatalog.fromJson({
      'catalogVersion': '2.0.0',
      'minClientVersion': '2.0.0',
      'scope': 'live_cash_nlh',
      'coachId': 'rex',
      'contentChecksum': 'test',
      'playerTypes': <Map<String, dynamic>>[],
      'sections': <Map<String, dynamic>>[],
      'lessonSplitMap': {
        'retired': ['lesson-a', 2],
        'not-a-list': 'lesson-a',
        'also-bad': 3,
      },
    });
    expect(catalog.lessonSplitMap.keys.toList(), ['retired']);
    expect(catalog.lessonSplitMap['retired'], ['lesson-a', '2']);

    final omitted = CourseCatalog.fromJson({
      'catalogVersion': '2.0.0',
      'minClientVersion': '2.0.0',
      'scope': 'live_cash_nlh',
      'coachId': 'rex',
      'contentChecksum': 'test',
      'sections': <Map<String, dynamic>>[],
    });
    expect(omitted.lessonSplitMap, isEmpty);
  });
}
