/// Home landing and section locks after a passed jump test (placement).
///
/// Passing the Section N jump test credits every lesson in Sections < N
/// (`jumpTestPlacementCreditLessonIds` on the server). Home must land on
/// Section N's first lesson with Section N current and unlocked, and Sections
/// N+1 and later locked. The jump test is the last node of Section N and the
/// first prerequisite of Section N+1, so a placement pass must not count as a
/// completed node (LPT-1032: a Section 4 placement also unlocked Section 5).
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/course_home_models.dart';
import 'package:live_poker_trainer/models/course/lesson_split_map.dart';
import 'package:live_poker_trainer/ui/home/course_section_picker.dart';

const _jumpId = 'lesson-04-10-02-section-four-jump-test';
const _sec4FirstId = 'lesson-04-01-01-01-seat-as-range';

CourseProfileView _profile(List<String> completed, {String? recommended}) =>
    CourseProfileView(
      lifetimeXp: 0,
      gems: 0,
      currentStreak: 0,
      acceptedAccuracy: 0,
      completedLessonIds: completed,
      masteryByLessonId: {recommended ?? _jumpId: 1.0},
      catalogVersion: '2.0.0',
      recommendedLessonId: recommended ?? _jumpId,
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
  List<String> sectionIds(int index) => [
    for (final unit in catalog.sections[index].units)
      for (final lesson in unit.lessons) lesson.id,
  ];
  final jumps = <(int, String)>[
    for (var i = 0; i < catalog.sections.length; i++)
      for (final unit in catalog.sections[i].units)
        for (final lesson in unit.lessons)
          if (lesson.activities.any(
            (a) => a.assessmentRole == AssessmentRole.jumpTest,
          ))
            (i, lesson.id),
  ];

  CourseHomeSnapshot home(List<String> completed, String jumpId) =>
      buildCourseHomeSnapshot(
        catalog: catalog,
        flags: flags,
        available: true,
        profile: _profile(completed, recommended: jumpId),
        reviewLessonIds: [jumpId],
      );

  void expectPlacedAt(CourseHomeSnapshot snap, int sectionIndex) {
    final order = sectionIndex + 1;
    final sectionId = catalog.sections[sectionIndex].id;
    expect(snap.status, CourseHomeLoadStatus.ready);
    expect(snap.nextLessonId, sectionIds(sectionIndex).first);
    expect(resolveHomePathSectionId(snap), sectionId);
    final rows = buildSectionProgress(snap);
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (i < sectionIndex) {
        expect(row.isComplete, isTrue, reason: 'section ${i + 1} complete');
      } else if (i == sectionIndex) {
        expect(row.isCurrent, isTrue, reason: 'section $order current');
        expect(row.isUnlocked, isTrue, reason: 'section $order unlocked');
        expect(row.completed, 0, reason: 'section $order not credited');
      } else {
        expect(row.isUnlocked, isFalse, reason: 'section ${i + 1} locked');
        expect(row.isCurrent, isFalse);
      }
    }
    for (final node in snap.nodes) {
      final index = catalog.sections.indexWhere((s) => s.id == node.sectionId);
      if (index > sectionIndex) {
        expect(
          node.state,
          CourseNodeState.locked,
          reason: '${node.lessonId} locked after Section $order placement',
        );
      }
      if (index == sectionIndex) {
        expect(node.hasCompleted, isFalse, reason: node.lessonId);
        expect(node.state, isNot(CourseNodeState.reviewDue));
      }
    }
  }

  test('Sections 1-4 publish jump tests', () {
    expect([for (final j in jumps) j.$1 + 1], [1, 2, 3, 4]);
  });

  for (final (sectionIndex, jumpId) in jumps) {
    final order = sectionIndex + 1;
    final credit = orderedIds.sublist(
      0,
      orderedIds.indexOf(sectionIds(sectionIndex).first),
    );

    test('Section $order jump pass: earlier done, $order current, '
        'later locked', () {
      expectPlacedAt(home(credit, jumpId), sectionIndex);
    });

    test('Section $order: a profile that also stores the jump id '
        '(pre-LPT-1032 server write) is still placed at Section $order', () {
      expectPlacedAt(home([...credit, jumpId], jumpId), sectionIndex);
    });

    test('Section $order: the jump test after finishing the section opens '
        'the next one', () {
      final finished = [...credit, ...sectionIds(sectionIndex)];
      final snap = home(finished, jumpId);
      expect(snap.nextLessonId, sectionIds(sectionIndex + 1).first);
    });
  }

  test('placement credit lands Home on Section 4, not Section 1', () {
    final credit = orderedIds.sublist(0, orderedIds.indexOf(_sec4FirstId));
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: flags,
      available: true,
      profile: _profile(credit),
    );
    expect(snap.nextLessonId, _sec4FirstId);
    expect(resolveHomePathSectionId(snap), 'sec-04-regular-live');
    final first = snap.nodes.firstWhere(
      (n) => n.lessonId == 'lesson-01-01-01-your-two-cards',
    );
    expect(first.state, CourseNodeState.completed);
  });

  test('jump test alone (pre-PR-2949 server write) stays in Section 1', () {
    final snap = buildCourseHomeSnapshot(
      catalog: catalog,
      flags: flags,
      available: true,
      profile: _profile(const [_jumpId]),
    );
    expect(snap.nextLessonId, 'lesson-01-01-01-your-two-cards');
    expect(resolveHomePathSectionId(snap), 'sec-01-never-played');
  });

  test('placementAwareCompletedLessonIds keeps a jump the learner built on',
      () {
    final credit = orderedIds.sublist(0, orderedIds.indexOf(_sec4FirstId));
    final sec5First = sectionIds(4).first;
    final kept = placementAwareCompletedLessonIds(
      [...credit, _jumpId, sec5First],
      catalog: catalog,
    );
    expect(kept, containsAll([_jumpId, sec5First]));
    final dropped = placementAwareCompletedLessonIds(
      [...credit, _jumpId],
      catalog: catalog,
    );
    expect(dropped.contains(_jumpId), isFalse);
  });
}
