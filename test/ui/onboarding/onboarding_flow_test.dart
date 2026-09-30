/// Onboarding recommendation + screen smoke tests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/screens/auth_screen.dart';
import 'package:live_poker_trainer/ui/screens/onboarding_screens.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/action_dock_widget.dart';
import 'package:live_poker_trainer/ui/widgets/community_cards_view.dart';
import 'package:live_poker_trainer/ui/widgets/brand_logo.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';
import 'package:live_poker_trainer/ui/widgets/coach_shelf_widget.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';
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
    expect(find.text('Step 1 of 4'), findsNothing);
    expect(
      find.text(
        'Learn live cash No-Limit Hold\'em by doing — one short lesson at a time.',
      ),
      findsNothing,
    );
    expect(find.byType(RexMascot), findsOneWidget);
    expect(find.byType(BrandLogo), findsOneWidget);
    _expectElevatedMetrics(tester, 'Get started');
    _expectOutlinedMetrics(tester, 'I already have an account');
  });

  testWidgets('meet rex continue uses the elevated button metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const RexIntroScreen(),
        ),
      ),
    );
    _expectElevatedMetrics(tester, 'Continue');
    expect(find.byType(RexMascot), findsOneWidget);
  });

  testWidgets('existing account Back returns to Welcome without signing in', (
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
    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
    expect(find.text('Sign in to continue training.'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    expect(fields, isNotEmpty);
    for (final field in fields) {
      expect(field.controller?.text ?? '', isEmpty);
    }

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsNothing);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
  });

  testWidgets('experience choices cover all bands with leading icons', (
    tester,
  ) async {
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
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.casino_outlined), findsOneWidget);
    expect(find.byIcon(Icons.style_outlined), findsOneWidget);
  });

  testWidgets('daily goal choices render with intensity labels', (
    tester,
  ) async {
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
      expect(find.text(dailyGoalIntensityLabel(minutes)), findsOneWidget);
    }
    expect(find.text('Casual'), findsOneWidget);
    expect(find.text('Regular'), findsOneWidget);
    expect(find.text('Serious'), findsOneWidget);
    expect(find.text('Intense'), findsOneWidget);
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

  testWidgets('onboarding back returns one screen without step labels', (
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
    expect(find.text('Step 1 of 4'), findsNothing);
    expect(find.byTooltip('Back'), findsNothing);
    expect(find.byType(RexMascot), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Your experience'), findsOneWidget);
    expect(find.text('Step 2 of 4'), findsNothing);
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
    expect(find.text('Step 3 of 4'), findsNothing);

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
    expect(find.text('Step 4 of 4'), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Daily goal'), findsOneWidget);
    expect(find.text('Meet Rex'), findsNothing);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('your start preview does not ask for a tap on this screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          heroIdentityProvider.overrideWithValue(const HeroIdentity()),
        ],
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
    expect(find.byType(FeltTableView), findsOneWidget);
    final heroSeat = find.byWidgetPredicate(
      (w) => w is PlayerSeatWidget && w.player.isHero,
    );
    expect(heroSeat, findsOneWidget);
    expect(find.byType(CoachShelfWidget), findsOneWidget);
    expect(find.byType(ActionDockWidget), findsNothing);
    expect(find.byType(LessonTableContext), findsNothing);
    expect(find.text('Tap your cards'), findsNothing);
    expect(find.textContaining('Tap them'), findsNothing);
    expect(find.textContaining('in the lesson'), findsOneWidget);
    expect(find.textContaining('FLOP'), findsOneWidget);
    expect(find.text('TAG'), findsNothing, reason: 'Section 1 has no types');
    expect(
      find.text('Qs Jh 2c on the flop. Your cards sit at the bottom of the table.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 400));
    final rail = tester.getRect(heroSeat);
    final shelf = tester.getRect(
      find.text('Qs Jh 2c on the flop. Your cards sit at the bottom of the table.'),
    );
    final button = tester.getRect(find.text('Start lesson'));
    expect(rail.bottom, lessThanOrEqualTo(shelf.top + 1));
    expect(shelf.bottom, lessThanOrEqualTo(button.top));
    expect(rail.bottom, lessThan(button.top));
    final board = tester.getRect(find.byType(CommunityCardsView));
    final pot = tester.getRect(find.textContaining(r'POT $10'));
    final bb = tester.getRect(find.text('BB'));
    expect(pot.overlaps(bb), isFalse, reason: 'BB covers the pot');
    expect(board.overlaps(bb), isFalse, reason: 'BB covers the board');
    for (final element in find.text(r'$200').evaluate()) {
      final stack = tester.getRect(find.byWidget(element.widget));
      expect(stack.overlaps(board), isFalse, reason: 'stack covers the board');
      expect(stack.overlaps(pot), isFalse, reason: 'stack covers the pot');
    }
    _expectElevatedMetrics(tester, 'Start lesson');
    expect(find.byType(RexMascot), findsOneWidget);
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

  testWidgets('motivation screens show Rex speech and CONTINUE', (
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
          home: const MotivationHookScreen(),
        ),
      ),
    );
    expect(find.text(MotivationHookScreen.speech), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.byType(RexMascot), findsOneWidget);
    expect(find.text('Start lesson'), findsNothing);
    _expectElevatedMetrics(tester, 'CONTINUE');

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
          home: const MotivationPitchScreen(),
        ),
      ),
    );
    expect(find.text(MotivationPitchScreen.speech), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.byType(RexMascot), findsOneWidget);
    expect(find.text('Start lesson'), findsNothing);
  });

  test('setRecommendation routes to motivation unless jump test offered',
      () async {
    final controller = OnboardingController(null);
    await controller.setRecommendation(
      lessonId: kFirstCourseLessonId,
      jumpTestOffered: false,
    );
    expect(controller.state.step, OnboardingStep.motivationHook);

    await controller.advanceMotivationHook();
    expect(controller.state.step, OnboardingStep.motivationPitch);

    await controller.setRecommendation(
      lessonId: 'lesson-jump',
      jumpTestOffered: true,
    );
    expect(controller.state.step, OnboardingStep.recommendedStart);
  });

  testWidgets('Nice work shows the lesson XP total and streak', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingControllerProvider.overrideWith((ref) => _AwardedDraft()),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const SaveProgressScreen(),
        ),
      ),
    );
    expect(find.text('Nice work'), findsOneWidget);
    expect(find.text('Your two cards'), findsOneWidget);
    expect(find.text('+75 XP · streak 1'), findsOneWidget);
  });
}

void _expectElevatedMetrics(WidgetTester tester, String label) {
  final finder = find.widgetWithText(FilledButton, label);
  final button = tester.widget<FilledButton>(finder);
  final states = const <WidgetState>{};
  expect(tester.getSize(finder).height, 54);
  expect(
    button.style!.backgroundColor!.resolve(states),
    AppColors.gold,
  );
  expect(
    button.style!.foregroundColor!.resolve(states),
    AppColors.bgDark,
  );
  final shape = button.style!.shape!.resolve(states)! as RoundedRectangleBorder;
  expect(shape.borderRadius, BorderRadius.circular(14));
  final textStyle = DefaultTextStyle.of(tester.element(find.text(label))).style;
  expect(textStyle.fontSize, 16);
  expect(textStyle.fontWeight, FontWeight.w800);
  expect(textStyle.fontFamily, contains('Manrope'));
}

void _expectOutlinedMetrics(WidgetTester tester, String label) {
  final finder = find.widgetWithText(OutlinedButton, label);
  final button = tester.widget<OutlinedButton>(finder);
  final states = const <WidgetState>{};
  expect(tester.getSize(finder).height, 50);
  expect(
    button.style!.foregroundColor!.resolve(states),
    AppColors.goldBright,
  );
  final side = button.style!.side!.resolve(states)!;
  expect(side.color, AppColors.goldMuted);
  expect(side.width, 1.2);
  final shape = button.style!.shape!.resolve(states)! as RoundedRectangleBorder;
  expect(shape.borderRadius, BorderRadius.circular(14));
}

class _AwardedDraft extends OnboardingController {
  _AwardedDraft() : super(null) {
    state = state.copyWith(
      lastLessonTitle: 'Your two cards',
      lastXpAwarded: 75,
      lastStreak: 1,
    );
  }
}
