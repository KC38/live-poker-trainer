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

  Future<void> tapLabel(WidgetTester tester, String label) async {
    final finder = find.text(label);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapContinue(WidgetTester tester) async {
    final finder = find.widgetWithText(FilledButton, 'Continue');
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapCoachContinue(WidgetTester tester) async {
    final finder = find.widgetWithText(FilledButton, 'CONTINUE');
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

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
    final appName = tester.widget<Text>(find.text('Exploitative\nPoker Lab'));
    expect(appName.textAlign, TextAlign.center);
    _expectElevatedMetrics(tester, 'Get started');
    _expectOutlinedMetrics(tester, 'I already have an account');
  });

  testWidgets('coach intro continue uses the elevated button metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const CoachIntroScreen(pageIndex: 0),
        ),
      ),
    );
    _expectElevatedMetrics(tester, 'CONTINUE');
    expect(find.byType(RexMascot), findsOneWidget);
    expect(find.text("Hi — I'm Rex, your coach."), findsOneWidget);
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
    expect(find.text('Where are you starting?'), findsOneWidget);
    expect(find.byType(RexMascot), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
          .onPressed,
      isNull,
    );

    await tester.tap(find.text('New to poker'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
          .onPressed,
      isNotNull,
    );
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
    expect(find.text('How much time per day?'), findsOneWidget);
    expect(find.byType(RexMascot), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Continue'), findsOneWidget);
  });

  testWidgets('get started shows two coach screens before experience', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
    expect(find.text("Hi — I'm Rex, your coach."), findsOneWidget);
    expect(find.byType(RexMascot), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Where are you starting?'), findsNothing);

    await tapCoachContinue(tester);
    expect(find.text("Let's find where you should start."), findsOneWidget);
    expect(find.text("Hi — I'm Rex, your coach."), findsNothing);

    await tapCoachContinue(tester);
    expect(find.text('Where are you starting?'), findsOneWidget);
    expect(find.text("Let's find where you should start."), findsNothing);
    expect(
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
      1 / kOnboardingProgressSteps,
    );
  });

  testWidgets('daily goal continue skips Meet Rex', (tester) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
    await tapCoachContinue(tester);
    await tapCoachContinue(tester);
    await tapLabel(tester, 'New to poker');
    await tapContinue(tester);
    await tapLabel(tester, '10 minutes');
    await tapContinue(tester);

    expect(find.text('Meet Rex'), findsNothing);
    expect(find.text('Your coach'), findsNothing);
    expect(find.text('Your live-reg coach'), findsNothing);
    // Recommendation remounts via AppRoot; in this isolated navigator the
    // draft advances and Meet Rex is no longer pushed.
    expect(find.text('How much time per day?'), findsOneWidget);
  });

  test('legacy Meet Rex drafts hydrate as daily goal', () {
    final draft = OnboardingDraft.fromPrefs({
      'step': 'rexIntro',
      'experienceBand': 'never_played',
      'dailyGoalMinutes': 10,
    });
    expect(draft.step, OnboardingStep.dailyGoal);
    expect(draft.experienceBand, ExperienceBand.neverPlayed);
    expect(draft.dailyGoalMinutes, 10);
  });

  testWidgets('onboarding back returns one screen without step labels', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(RexMascot), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text("Hi — I'm Rex, your coach."), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Step 2 of 4'), findsNothing);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.bySemanticsLabel('Back'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    expect(find.text("Hi — I'm Rex, your coach."), findsNothing);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tapCoachContinue(tester);
    expect(find.text("Let's find where you should start."), findsOneWidget);
    await tapCoachContinue(tester);
    expect(find.text('Where are you starting?'), findsOneWidget);
    expect(
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
      1 / kOnboardingProgressSteps,
    );

    await tester.tap(find.text('New to poker'));
    await tester.pumpAndSettle();
    expect(find.text('How much time per day?'), findsNothing);
    expect(find.byType(RexMascot), findsWidgets);
    expect(find.text('Where are you starting?'), findsOneWidget);
    await tapContinue(tester);
    expect(find.text('How much time per day?'), findsOneWidget);
    expect(find.text('Daily goal'), findsNothing);
    expect(
      find.textContaining('A small daily habit'),
      findsNothing,
    );
    expect(find.text('Step 3 of 4'), findsNothing);
    expect(
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator)).value,
      2 / kOnboardingProgressSteps,
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Where are you starting?'), findsOneWidget);
    expect(find.text('New to poker'), findsOneWidget);

    await tapLabel(tester, 'Know the rules / home games');
    expect(find.text('How much time per day?'), findsNothing);
    await tapContinue(tester);
    expect(find.text('How much time per day?'), findsOneWidget);

    await tapLabel(tester, '10 minutes');
    expect(find.text('Your live-reg coach'), findsNothing);
    await tapContinue(tester);
    expect(find.text('Meet Rex'), findsNothing);
    expect(find.text('Your live-reg coach'), findsNothing);
    expect(find.text('How much time per day?'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('experience screen keeps the coach bubble without helper copy', (
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
    expect(find.text('Where are you starting?'), findsOneWidget);
    expect(find.byType(RexMascot), findsOneWidget);
    expect(find.text('Your experience'), findsNothing);
    expect(
      find.textContaining('never unlocks content alone'),
      findsNothing,
    );
    expect(
      find.bySemanticsLabel('Onboarding progress 25 percent'),
      findsOneWidget,
    );
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
    expect(find.byKey(const ValueKey('felt-board-row')), findsOneWidget);
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
    // The first lesson teaches cards, not blinds or chips: the preview of it
    // leaves out the pot, the blinds, the pucks, the bets, and the stacks.
    final board = tester.getRect(find.byType(CommunityCardsView));
    expect(find.textContaining('POT'), findsNothing);
    expect(find.textContaining('Blinds'), findsNothing);
    expect(find.text('BB'), findsNothing);
    expect(find.text('D'), findsNothing);
    expect(find.textContaining(r'$'), findsNothing);
    for (final seat in find.byType(PlayerSeatWidget).evaluate()) {
      final rect = tester.getRect(find.byWidget(seat.widget));
      expect(rect.overlaps(board), isFalse, reason: 'a seat covers the board');
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
    expect(find.text('Time to create a profile!'), findsOneWidget);
    expect(find.text('CREATE A PROFILE'), findsOneWidget);
    expect(find.text('LATER'), findsOneWidget);
    expect(find.textContaining('can be lost'), findsOneWidget);
    expect(find.byType(RexMascot), findsOneWidget);
    _expectElevatedMetrics(tester, 'CREATE A PROFILE');
    _expectOutlinedMetrics(tester, 'LATER');
    final account = tester.widget<Text>(
      find.text('I already have an account'),
    );
    expect(account.style?.color, AppColors.goldBright);
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
    expect(find.text('Your two cards'), findsOneWidget);
    expect(find.text('+75 XP'), findsOneWidget);
    expect(find.text('streak 1'), findsOneWidget);
    expect(find.text('Time to create a profile!'), findsOneWidget);
    expect(find.text('CREATE A PROFILE'), findsOneWidget);
    expect(find.text('LATER'), findsOneWidget);
    expect(find.text('I already have an account'), findsOneWidget);
    _expectElevatedMetrics(tester, 'CREATE A PROFILE');
    _expectOutlinedMetrics(tester, 'LATER');
    final niceWork = tester.widget<Text>(find.text('Nice work'));
    expect(niceWork.style?.color, AppColors.goldBright);
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
