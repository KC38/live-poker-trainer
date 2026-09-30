/// Your start can rewind to Meet Rex, Daily goal, and Your experience.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/main.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/course_flags_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/firestore/course_flags_repository.dart';
import 'package:live_poker_trainer/ui/screens/lesson_runner_screen.dart';
import 'package:live_poker_trainer/ui/screens/onboarding_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _flags = CourseFlags(
  courseEnabled: true,
  courseStartsEnabled: true,
  guestCourseEnabled: true,
  placementTestsEnabled: true,
  catalogVersion: '2.0.0',
  minimumClientVersion: '2.0.0',
);

final _catalog = CourseCatalog(
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
              id: kFirstCourseLessonId,
              order: 1,
              title: 'Your two cards',
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

class _ReadyFlagsRepository extends CourseFlagsRepository {
  @override
  Future<CourseFlags> load({String? clientVersion}) async => _flags;
}

class _YourStartOnboarding extends OnboardingController {
  _YourStartOnboarding() : super(null) {
    state = const OnboardingDraft(
      step: OnboardingStep.recommendedStart,
      experienceBand: ExperienceBand.neverPlayed,
      dailyGoalMinutes: 10,
      recommendedLessonId: kFirstCourseLessonId,
    );
  }
}

bool _tileSelected(WidgetTester tester, String label) {
  final material = tester.widget<Material>(
    find.ancestor(of: find.text(label), matching: find.byType(Material)).first,
  );
  final shape = material.shape;
  return shape is RoundedRectangleBorder && shape.side.color == AppColors.gold;
}

Future<void> _pumpGuest(
  WidgetTester tester, {
  required List<Override> overrides,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appAuthProvider.overrideWith(
          (ref) => const AsyncData(AppAuthSnapshot()),
        ),
        userDocProvider.overrideWith((ref) async => null),
        analyticsServiceProvider.overrideWithValue(
          AnalyticsService(enabled: false),
        ),
        courseFlagsRepositoryProvider.overrideWithValue(
          _ReadyFlagsRepository(),
        ),
        courseCatalogProvider.overrideWith((ref) async => _catalog),
        ...overrides,
      ],
      child: const PokerLabApp(),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Future<void> _tapLabel(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _tapContinue(WidgetTester tester) async {
  final finder = find.widgetWithText(FilledButton, 'Continue');
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('back from Your start rewinds band and goal without Home', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final onboarding = _YourStartOnboarding();
    await _pumpGuest(
      tester,
      overrides: [
        onboardingControllerProvider.overrideWith((ref) => onboarding),
      ],
    );

    expect(find.text('Your start'), findsOneWidget);
    expect(find.text('Start lesson'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.textContaining('Step '), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Meet Rex'), findsOneWidget);
    expect(find.text('Your coach'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Your start'), findsNothing);
    expect(onboarding.state.dailyGoalMinutes, 10);
    expect(onboarding.state.experienceBand, ExperienceBand.neverPlayed);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Daily goal'), findsOneWidget);
    expect(find.text('Meet Rex'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(_tileSelected(tester, '10 minutes'), isTrue);
    expect(_tileSelected(tester, '5 minutes'), isFalse);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Your experience'), findsOneWidget);
    expect(find.text('Daily goal'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(_tileSelected(tester, 'New to poker'), isTrue);

    await _tapLabel(tester, 'Know the rules / home games');
    expect(find.text('Daily goal'), findsNothing);
    await _tapContinue(tester);
    expect(find.text('Daily goal'), findsOneWidget);
    expect(_tileSelected(tester, '10 minutes'), isTrue);

    await _tapLabel(tester, '10 minutes');
    expect(find.text('Meet Rex'), findsNothing);
    await _tapContinue(tester);
    expect(find.text('Meet Rex'), findsOneWidget);
    expect(find.text('Your live-reg coach'), findsOneWidget);

    await _tapContinue(tester);

    expect(find.text(MotivationHookScreen.speech), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('Your start'), findsNothing);
    expect(find.text('Start lesson'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(onboarding.state.experienceBand, ExperienceBand.rulesKnown);
    expect(onboarding.state.step, OnboardingStep.motivationHook);

    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text(MotivationPitchScreen.speech), findsOneWidget);
    expect(onboarding.state.step, OnboardingStep.motivationPitch);

    await tester.tap(find.text('CONTINUE'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(LessonRunnerScreen), findsOneWidget);
    expect(
      tester
          .widget<LessonRunnerScreen>(find.byType(LessonRunnerScreen))
          .lessonId,
      kFirstCourseLessonId,
    );
    expect(find.text('Home'), findsNothing);
  });

  testWidgets('relaunch on Your start keeps the screen and back', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({
      'onboarding_draft_v1': jsonEncode(
        const OnboardingDraft(
          step: OnboardingStep.recommendedStart,
          experienceBand: ExperienceBand.neverPlayed,
          dailyGoalMinutes: 10,
          recommendedLessonId: kFirstCourseLessonId,
        ).toPrefs(),
      ),
    });

    await _pumpGuest(tester, overrides: const []);
    await tester.pumpAndSettle();

    expect(find.text('Your start'), findsOneWidget);
    expect(find.text('Start lesson'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Meet Rex'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Your start'), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Daily goal'), findsOneWidget);
    expect(_tileSelected(tester, '10 minutes'), isTrue);
  });
}
