/// Widget coverage for post-first-lesson streak / quest / gem beats.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/screens/onboarding_screens.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpCelebration(
    WidgetTester tester, {
    required OnboardingController controller,
    required Widget home,
  }) async {
    final container = ProviderContainer(
      overrides: [
        analyticsServiceProvider.overrideWithValue(
          AnalyticsService(enabled: false),
        ),
        onboardingControllerProvider.overrideWith((ref) => controller),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('day streak CONTINUE advances to streak goal', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = _DraftController(
      const OnboardingDraft(
        step: OnboardingStep.dayStreak,
        firstLessonCompleted: true,
        lastStreak: 1,
        lastXpAwarded: 35,
        lastGemsAwarded: 5,
        gems: 5,
      ),
    );
    await pumpCelebration(
      tester,
      controller: controller,
      home: const DayStreakScreen(),
    );

    expect(find.text('day streak'), findsOneWidget);
    expect(find.text('CONTINUE'), findsOneWidget);
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(controller.state.step, OnboardingStep.streakGoal);
  });

  testWidgets('streak goal requires a choice then advances', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = _DraftController(
      const OnboardingDraft(
        step: OnboardingStep.streakGoal,
        firstLessonCompleted: true,
        lastStreak: 1,
        gems: 5,
      ),
    );
    await pumpCelebration(
      tester,
      controller: controller,
      home: const StreakGoalScreen(),
    );

    expect(find.text('I CAN DO IT!'), findsOneWidget);
    await tester.tap(find.text('I CAN DO IT!'));
    await tester.pumpAndSettle();
    expect(controller.state.step, OnboardingStep.streakGoal);

    await tester.tap(find.text('30 day streak'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I CAN DO IT!'));
    await tester.pumpAndSettle();
    expect(controller.state.step, OnboardingStep.dailyQuests);
    expect(controller.state.streakGoalDays, 30);
  });

  testWidgets('daily quests CONTINUE opens gems reward', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = _DraftController(
      const OnboardingDraft(
        step: OnboardingStep.dailyQuests,
        firstLessonCompleted: true,
        lastXpAwarded: 35,
        lastGemsAwarded: 5,
        gems: 5,
        streakGoalDays: 30,
      ),
    );
    await pumpCelebration(
      tester,
      controller: controller,
      home: const DailyQuestsCompleteScreen(),
    );

    expect(find.text('All Daily Quests complete!'), findsOneWidget);
    expect(find.text('Earn 10 XP'), findsOneWidget);
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(controller.state.step, OnboardingStep.gemsReward);
  });

  testWidgets('gems reward CONTINUE opens save progress', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = _DraftController(
      const OnboardingDraft(
        step: OnboardingStep.gemsReward,
        firstLessonCompleted: true,
        lastGemsAwarded: 5,
        gems: 5,
        streakGoalDays: 30,
      ),
    );
    await pumpCelebration(
      tester,
      controller: controller,
      home: const GemsRewardScreen(),
    );

    expect(find.text('You earned 5 gems!'), findsOneWidget);
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(controller.state.step, OnboardingStep.saveProgress);
    expect(controller.state.pendingSaveProgress, isTrue);
  });
}

class _DraftController extends OnboardingController {
  _DraftController(OnboardingDraft draft) : super(null) {
    state = draft;
  }
}
