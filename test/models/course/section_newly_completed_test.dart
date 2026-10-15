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

  test('one-lesson section completes from an empty history', () {
    final catalog = _catalog(['only']);
    expect(
      catalog.sectionNewlyCompletedByLesson(
        lessonId: 'only',
        completedBefore: {},
      )?.id,
      'sec',
    );
    expect(
      catalog.sectionNewlyCompletedByLesson(
        lessonId: 'only',
        completedBefore: {'only'},
      ),
      isNull,
      reason: 'review of the only lesson is not a new section finish',
    );
  });

  test('unknown and empty lesson ids do not open the ceremony', () {
    final catalog = _catalog(['a']);
    expect(
      catalog.sectionNewlyCompletedByLesson(
        lessonId: 'missing',
        completedBefore: {},
      ),
      isNull,
    );
    expect(
      catalog.sectionNewlyCompletedByLesson(
        lessonId: '',
        completedBefore: {'a'},
      ),
      isNull,
    );
  });

  test('section finish walks every unit, ignoring other sections', () {
    final catalog = _twoSectionCatalog();
    final first = catalog.sections.first;
    expect(first.lessonIds, ['a', 'b', 'c']);
    expect(() => first.lessonIds.add('z'), throwsUnsupportedError);

    expect(
      catalog.sectionNewlyCompletedByLesson(
        lessonId: 'b',
        completedBefore: {'a'},
      ),
      isNull,
      reason: 'finishing unit 1 still leaves c in unit 2',
    );
    expect(
      catalog.sectionNewlyCompletedByLesson(
        lessonId: 'c',
        completedBefore: {'a', 'b', 'd'},
      )?.title,
      'Never Played',
      reason: 'a finished sibling section does not block this one',
    );
    expect(
      catalog.sectionNewlyCompletedByLesson(
        lessonId: 'd',
        completedBefore: {},
      )?.title,
      'Played a Little',
      reason: 'section 2 is one lesson and does not need section 1',
    );
  });
}

CourseCatalog _twoSectionCatalog() {
  CourseUnit unit(String id, List<String> lessons) => CourseUnit(
        id: id,
        order: 1,
        title: id,
        summary: '',
        lessons: [for (final lessonId in lessons) _lesson(lessonId)],
      );
  return CourseCatalog(
    catalogVersion: 't',
    minClientVersion: '0',
    scope: 'test',
    coachId: 'rex',
    contentChecksum: 'x',
    playerTypes: const [],
    sections: [
      CourseSection(
        id: 'sec-a',
        order: 1,
        title: 'Never Played',
        summary: '',
        experienceBand: 'never',
        units: [unit('u1', ['a', 'b']), unit('u2', ['c'])],
      ),
      CourseSection(
        id: 'sec-b',
        order: 2,
        title: 'Played a Little',
        summary: '',
        experienceBand: 'little',
        units: [unit('u3', ['d'])],
      ),
    ],
  );
}
