/// Onboarding recommendation + screen smoke tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
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
                  'remediationLessonIds': [
                    'lesson-04-01-01-meet-calling-station',
                  ],
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

  testWidgets('welcome offers get started and existing account', (
    tester,
  ) async {
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

  testWidgets('new to poker Meet Rex says coach, not live-reg', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(enabled: false),
          ),
          onboardingControllerProvider.overrideWith(
            (ref) => OnboardingController(null),
          ),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const WelcomeScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New to poker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10 minutes'));
    await tester.pumpAndSettle();

    expect(find.text('Meet Rex'), findsOneWidget);
    expect(find.text('Your coach'), findsOneWidget);
    expect(find.textContaining('live-reg'), findsNothing);
    expect(
      find.text(
        'One short sentence at a time. No lectures — just the next decision.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('regular Meet Rex keeps the live-reg coach line', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(enabled: false),
          ),
          onboardingControllerProvider.overrideWith(
            (ref) => OnboardingController(null),
          ),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const WelcomeScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Regular live cash player'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10 minutes'));
    await tester.pumpAndSettle();

    expect(find.text('Your live-reg coach'), findsOneWidget);
    expect(
      find.text(
        'One short sentence at a time. No lectures — just the next decision.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('onboarding steps show position and back returns one screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(enabled: false),
          ),
          onboardingControllerProvider.overrideWith(
            (ref) => OnboardingController(null),
          ),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const WelcomeScreen(),
        ),
      ),
    );
    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Your experience'), findsOneWidget);
    expect(find.text('Step 2 of 4'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.text('Your experience'), findsNothing);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Your experience'), findsOneWidget);

    await tester.tap(find.text('New to poker'));
    await tester.pumpAndSettle();
    expect(find.text('Daily goal'), findsOneWidget);
    expect(find.text('Step 3 of 4'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Your experience'), findsOneWidget);
    expect(find.text('New to poker'), findsOneWidget);

    await tester.tap(find.text('Know the rules / home games'));
    await tester.pumpAndSettle();
    expect(find.text('Daily goal'), findsOneWidget);

    await tester.tap(find.text('10 minutes'));
    await tester.pumpAndSettle();
    expect(find.text('Meet Rex'), findsOneWidget);
    expect(find.text('Step 4 of 4'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Daily goal'), findsOneWidget);
    expect(find.text('Meet Rex'), findsNothing);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('your start preview does not ask for a tap on this screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const RecommendedStartScreen(
            recommendation: OnboardingRecommendation(
              experienceBand: ExperienceBand.neverPlayed,
              startLessonId: kFirstCourseLessonId,
              jumpTestOffered: false,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Start lesson'), findsOneWidget);
    expect(find.text('Tap your cards'), findsNothing);
    expect(find.textContaining('Tap them'), findsNothing);
    expect(find.textContaining('in the lesson'), findsOneWidget);
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
