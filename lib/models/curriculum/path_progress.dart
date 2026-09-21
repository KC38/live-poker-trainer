/// Unlock rules for the Learn path through the postflop sections.
library;

import 'package:live_poker_trainer/models/curriculum/curriculum_models.dart';
import 'package:live_poker_trainer/models/curriculum/learning_snapshot.dart';

/// Last section shown on the path. Later sections stay off the path until authored.
const int kVisiblePathMaxSectionOrder = 7;

/// First section that requires the Table Ready gate.
const int kPreflopMinSectionOrder = 3;

/// First section that requires the Preflop gate.
const int kPostflopMinSectionOrder = 5;

/// Mastery below this sends a finished path back to review.
const double kReviewMasteryThreshold = 0.8;

/// Lessons in path order for sections 0–7.
List<CurriculumLesson> orderedPathLessons(CurriculumCatalog catalog) {
  final sections = [...catalog.sections]
    ..sort((a, b) => a.order.compareTo(b.order));
  final lessons = <CurriculumLesson>[];
  for (final section in sections) {
    if (section.order > kVisiblePathMaxSectionOrder) continue;
    final units = [...section.units]
      ..sort((a, b) => a.order.compareTo(b.order));
    for (final unit in units) {
      final unitLessons = [...unit.lessons]
        ..sort((a, b) => a.order.compareTo(b.order));
      lessons.addAll(unitLessons);
    }
  }
  return lessons;
}

/// Whether [lessonId] can be started.
///
/// Sections 0–2 unlock in order. Sections 3–4 stay locked until Table Ready
/// passes. Sections 5–7 stay locked until the Preflop gate passes.
bool isPathLessonUnlocked({
  required CurriculumCatalog catalog,
  required LearningSnapshot snapshot,
  required String lessonId,
}) {
  final ordered = orderedPathLessons(catalog);
  final index = ordered.indexWhere((lesson) => lesson.id == lessonId);
  if (index < 0) return false;
  final sectionOrder = _sectionOrder(catalog, lessonId);
  if (sectionOrder == null) return false;
  if (sectionOrder >= kPostflopMinSectionOrder && !snapshot.preflopPassed) {
    return false;
  }
  if (sectionOrder >= kPreflopMinSectionOrder && !snapshot.tableReadyPassed) {
    return false;
  }
  if (index == 0) return true;
  return snapshot.completedLessonIds.contains(ordered[index - 1].id);
}

/// Next new lesson, or the weakest authored lesson once the visible path is done.
CurriculumLesson? nextPracticeLesson({
  required CurriculumCatalog catalog,
  required LearningSnapshot snapshot,
}) {
  final ordered = orderedPathLessons(catalog);
  for (final lessonId in snapshot.dueLessonIds) {
    final due = _findLesson(catalog, lessonId);
    if (due != null) return due;
  }
  for (final lesson in ordered) {
    if (snapshot.completedLessonIds.contains(lesson.id)) continue;
    if (!isPathLessonUnlocked(
      catalog: catalog,
      snapshot: snapshot,
      lessonId: lesson.id,
    )) {
      return null;
    }
    return lesson;
  }

  CurriculumLesson? weakest;
  var weakestScore = kReviewMasteryThreshold;
  for (final lesson in ordered) {
    if (lesson.objectiveIds.isEmpty) continue;
    var score = 1.0;
    for (final objectiveId in lesson.objectiveIds) {
      final mastery = snapshot.masteryByObjectiveId[objectiveId] ?? 0;
      if (mastery < score) score = mastery;
    }
    if (score < weakestScore) {
      weakest = lesson;
      weakestScore = score;
    }
  }
  return weakest;
}

int? _sectionOrder(CurriculumCatalog catalog, String lessonId) {
  for (final section in catalog.sections) {
    for (final unit in section.units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == lessonId) return section.order;
      }
    }
  }
  return null;
}

CurriculumLesson? _findLesson(CurriculumCatalog catalog, String lessonId) {
  for (final section in catalog.sections) {
    for (final unit in section.units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
  }
  return null;
}
