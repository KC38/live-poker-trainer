/// Catalog helper for first-time section completion (LPT-793).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';

CourseLesson _lesson(String id) => CourseLesson(
      id: id,
      order: 1,
      title: id,
      summary: 'summary',
      objectives: const [],
      prerequisites: const [],
      remediationLessonIds: const [],
      estimatedMinutes: 1,
      difficultyBand: 1,
      playerTypeRefs: const [],
      introducesPlayerTypes: const [],
      activities: const [],
    );

CourseSection _section(List<String> ids) => CourseSection(
      id: 'sec',
      order: 1,
      title: 'Never Played',
      summary: '',
      experienceBand: 'never',
      units: [
        CourseUnit(
          id: 'u1',
          order: 1,
          title: 'Unit',
          summary: '',
          lessons: [for (final id in ids) _lesson(id)],
        ),
      ],
    );

CourseCatalog _catalog(List<String> ids) => CourseCatalog(
      catalogVersion: 't',
      minClientVersion: '0',
      scope: 'test',
      coachId: 'rex',
      contentChecksum: 'x',
      playerTypes: const [],
      sections: [_section(ids)],
    );

void main() {
  test('sectionNewlyCompletedByLesson true only on the finishing lesson', () {
    final catalog = _catalog(['a', 'b', 'c']);
    expect(
      catalog.sectionNewlyCompletedByLesson(
        lessonId: 'c',
        completedBefore: {'a', 'b'},
      )?.title,
      'Never Played',
    );
    expect(
      catalog.sectionNewlyCompletedByLesson(
        lessonId: 'b',
        completedBefore: {'a'},
      ),
      isNull,
    );
    expect(
      catalog.sectionNewlyCompletedByLesson(
        lessonId: 'c',
        completedBefore: {'a', 'b', 'c'},
      ),
      isNull,
      reason: 'review of an already-complete section',
    );
  });

  test('empty before-set never completes a multi-lesson section', () {
    final catalog = _catalog(['a', 'b']);
    expect(
      catalog.sectionNewlyCompletedByLesson(
        lessonId: 'b',
        completedBefore: {},
      ),
      isNull,
    );
  });
}
