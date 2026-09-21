/// Onboarding recommendation + screen smoke tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/ui/screens/onboarding_screens.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('regular recommends first lesson when no placement jump exists', () {
    final catalog = CourseCatalog.fromJson({
      'catalogVersion': '2.0.0',
      'minClientVersion': '2.0.0',
      'scope': 'live_cash_nlh',
      'coachId': 'rex',
      'contentChecksum': 'test',
      'sections': [
        {
          'id': 'sec-04-regular-live',
          'order': 4,
          'title': 'Regular',
          'summary': 'Regular',
          'experienceBand': 'regular_live',
          'units': [
            {
              'id': 'unit-04-01',
              'order': 1,
              'title': 'Unit',
              'summary': 'Unit',
              'lessons': [
                {
                  'id': 'lesson-04-01-01-meet-calling-station',
                  'order': 1,
                  'title': 'Meet CS',
                  'summary': 'Meet',
                  'objectives': ['Introduce'],
                  'prerequisites': [],
                  'remediationLessonIds': ['lesson-04-01-01-meet-calling-station'],
                  'estimatedMinutes': 6,
                  'difficultyBand': 3,
                  'playerTypeRefs': [],
                  'activities': [
                    {
                      'id': 'act-1',
                      'order': 1,
                      'stage': 'explain',
                      'renderer': 'coach_dialogue',
                      'estimatedSeconds': 30,
                      'accessibilityText': 'Hi',
                      'acceptedGrades': ['recommended'],
                      'lifeLossEligible': false,
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
      'playerTypes': [],
    });
    final flags = const CourseFlags(
      courseEnabled: true,
      courseStartsEnabled: true,
      guestCourseEnabled: true,
      placementTestsEnabled: true,
      catalogVersion: '2.0.0',
      minimumClientVersion: '2.0.0',
    );
    final recommendation = resolveOnboardingRecommendation(
      band: ExperienceBand.regularLive,
      catalog: catalog,
      flags: flags,
    );
    expect(recommendation.jumpTestOffered, isFalse);
    expect(recommendation.startLessonId, kFirstCourseLessonId);
  });

  testWidgets('welcome offers get started and existing account', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const WelcomeScreen(),
        ),
      ),
    );
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('experience choices cover all bands', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const ExperienceChoiceScreen(),
        ),
      ),
    );
    for (final band in ExperienceBand.values) {
      expect(find.text(band.label), findsOneWidget);
    }
  });

  testWidgets('daily goal choices render', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const DailyGoalScreen(),
        ),
      ),
    );
    for (final minutes in kDailyGoalChoices) {
      expect(find.text('$minutes minutes'), findsOneWidget);
    }
  });

  testWidgets('save progress copy warns about temporary guest data', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const SaveProgressScreen(),
        ),
      ),
    );
    expect(
      find.textContaining('Create an account to save your progress'),
      findsWidgets,
    );
    expect(find.textContaining('can be lost'), findsOneWidget);
  });
}
