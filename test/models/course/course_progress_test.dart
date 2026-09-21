import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_progress.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';

void main() {
  final catalog = CourseCatalog(
    catalogVersion: '2.0.0',
    minClientVersion: '2.0.0',
    scope: 'live_cash_nlh',
    coachId: 'rex',
    contentChecksum: 'test',
    playerTypes: const [],
    sections: [
      CourseSection(
        id: 'section-1',
        order: 1,
        title: 'Foundations',
        summary: 'Basics',
        experienceBand: 'never_played',
        units: [
          CourseUnit(
            id: 'unit-1',
            order: 1,
            title: 'Cards',
            summary: 'Cards',
            lessons: [
              CourseLesson(
                id: 'lesson-a',
                order: 1,
                title: 'Two cards',
                summary: 'Start',
                objectives: const [],
                prerequisites: const [],
                remediationLessonIds: const [],
                estimatedMinutes: 4,
                difficultyBand: 1,
                playerTypeRefs: const [],
                introducesPlayerTypes: const [],
                activities: const [],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  test('course progress stays separate from live coaching stats', () {
    const live = UserStatsModel(totalSpots: 10, correctSpots: 8, netEvBb: 4.5);
    final course = CourseProgress.fromState({
      'available': true,
      'profile': {
        'lifetimeXp': 30,
        'currentStreak': 3,
        'acceptedAccuracy': 0.8,
        'currentLessonId': 'lesson-a',
        'masteryByLessonId': {'lesson-a': 0.5},
        'legacyLifetimeXp': 90,
        'legacyXpLabel': 'legacy_academy',
      },
      'reviewsDue': [
        {'id': 'review-1'},
      ],
    }, catalog);

    expect(course.lifetimeXp, 30);
    expect(course.legacyLifetimeXp, 90);
    expect(course.currentSectionTitle, 'Foundations');
    expect(course.reviewsDue, 1);
    expect(course.acceptedAccuracy, 0.8);
    expect(live.totalSpots, 10);
    expect(live.netEvBb, 4.5);
    expect(live.accuracyPct, 80);
  });

  test('unlabeled legacy xp is ignored', () {
    final course = CourseProgress.fromState({
      'available': false,
      'profile': {
        'lifetimeXp': 0,
        'legacyLifetimeXp': 12,
        'legacyXpLabel': 'not-a-label',
      },
    }, catalog);
    expect(course.loaded, isTrue);
    expect(course.available, isFalse);
    expect(course.legacyLifetimeXp, isNull);
  });
}
