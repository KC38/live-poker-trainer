/// Home landing after a passed Section 4 jump test (placement credit).
///
/// The server credits every lesson in Sections 1-3 plus the jump test on a
/// passed jump test (`jumpTestPlacementCreditLessonIds`). Home must then land
/// on Section 4's first lesson, not Section 1, Unit 1.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/ui/home/course_section_picker.dart';

const _jumpId = 'lesson-04-10-02-section-four-jump-test';
const _sec4FirstId = 'lesson-04-01-01-01-seat-as-range';

CourseProfileView _profile(List<String> completed) => CourseProfileView(
  lifetimeXp: 0,
  gems: 0,
  currentStreak: 0,
  acceptedAccuracy: 0,
  completedLessonIds: completed,
  masteryByLessonId: const {_jumpId: 1.0},
  catalogVersion: '2.0.0',
  recommendedLessonId: _jumpId,
);

void main() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  final flags = CourseFlags(
    courseEnabled: true,
    courseStartsEnabled: true,
    guestCourseEnabled: true,
    placementTestsEnabled: true,
    catalogVersion: catalog.catalogVersion,
    minimumClientVersion: '2.0.0',
  );
  final orderedIds = [
    for (final section in catalog.sections)
      for (final unit in section.units)
        for (final lesson in unit.lessons) lesson.id,
  ];

  test('placement credit lands Home on Section 4, not Section 1', () {
    final credit = orderedIds.sublist(0, orderedIds.indexOf(_sec4FirstId));
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: flags,
      available: true,
      profile: _profile([...credit, _jumpId]),
    );
    expect(snap.status, CourseHomeLoadStatus.ready);
    expect(snap.nextLessonId, _sec4FirstId);
    expect(resolveHomePathSectionId(snap), 'sec-04-regular-live');
    final first = snap.nodes.firstWhere(
      (n) => n.lessonId == 'lesson-01-01-01-your-two-cards',
    );
    expect(first.state, CourseNodeState.completed);
  });

  test('jump test alone (pre-fix server write) falls back to Section 1', () {
    // Documents the LPT bug: without placement credit Home sends a
    // freshly placed regular back to Section 1, Unit 1.
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: flags,
      available: true,
      profile: _profile(const [_jumpId]),
    );
    expect(snap.nextLessonId, 'lesson-01-01-01-your-two-cards');
    expect(resolveHomePathSectionId(snap), 'sec-01-never-played');
  });
}
