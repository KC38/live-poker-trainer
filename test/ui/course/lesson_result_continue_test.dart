/// Lesson result CONTINUE must leave the screen.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/models/course/onboarding_models.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/services/auth_service.dart';
import 'package:live_poker_trainer/ui/screens/lesson_result_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';

const _complete = CompleteCourseLessonResult(
  attemptId: 'a1',
  lessonId: 'lesson-01-01-01-your-two-cards',
  xpAwarded: 25,
  mastery: 1,
  streak: 1,
  acceptedAccuracy: 1,
  liveTrainingGranted: false,
  duplicate: false,
);

const _review = CompleteCourseLessonResult(
  attemptId: 'a1-review',
  lessonId: 'lesson-01-01-01-your-two-cards',
  xpAwarded: 10,
  lessonXpAwarded: 10,
  mastery: 1,
  streak: 2,
  acceptedAccuracy: 1,
  liveTrainingGranted: false,
  duplicate: false,
);

const _imperfect = CompleteCourseLessonResult(
  attemptId: 'a2',
  lessonId: 'lesson-01-03-02-bet-raise-allin',
  xpAwarded: 25,
  mastery: 0.8,
  streak: 1,
  acceptedAccuracy: 0.8,
  liveTrainingGranted: false,
  duplicate: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CONTINUE pops when a route sits under the result', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder:
                              (_) => const LessonResultScreen(
                                lessonTitle: 'Your two cards',
                                result: _complete,
                              ),
                        ),
                      );
                    },
                    child: const Text('open-result'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-result'));
    await tester.pumpAndSettle();
    expect(find.text('Lesson Complete!'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'CONTINUE'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text('Lesson Complete!'), findsNothing);
    expect(find.text('open-result'), findsOneWidget);
  });

  testWidgets('CONTINUE is a no-op when the result is the sole route', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const LessonResultScreen(
            lessonTitle: 'Your two cards',
            result: _complete,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
    await tester.pump();

    // Sole-route escape is handled by PokerLabApp remounting on saveProgress
    // and by onboarding pushing (not replacing) the runner.
    expect(find.text('Lesson Complete!'), findsOneWidget);
  });

  testWidgets('ceremony uses Rex face, not a letter R, at phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> pumpResult(String title) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: buildPokerTheme(),
            home: LessonResultScreen(
              lessonTitle: title,
              result: _complete,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
    }

    for (final title in ['Suits and ranks', 'Button and blinds']) {
      await pumpResult(title);
      expect(tester.takeException(), isNull);
      expect(find.text('Lesson Complete!'), findsOneWidget);
      expect(find.text(title), findsOneWidget);
      expect(find.text('TOTAL XP'), findsOneWidget);
      expect(find.text('AMAZING'), findsOneWidget);
      expect(find.text('R'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'CONTINUE'), findsOneWidget);

      final mascot = tester.widget<RexMascot>(find.byType(RexMascot));
      expect(mascot.mood, RexMood.celebrate);
      expect(find.bySemanticsLabel('Rex, celebrating'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == RexMascot.bodyAsset,
        ),
        findsWidgets,
      );
    }
  });

  testWidgets('lesson result shows XP and accuracy side by side', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const LessonResultScreen(
            lessonTitle: 'Suits and ranks',
            result: _complete,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    expect(tester.takeException(), isNull);
    expect(find.text('TOTAL XP'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('AMAZING'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('Daily goal'), findsNothing);
    expect(find.text('Mastery'), findsNothing);
    expect(find.text('Study streak'), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'CONTINUE'), findsOneWidget);

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'CONTINUE'),
    );
    final context = tester.element(
      find.widgetWithText(ElevatedButton, 'CONTINUE'),
    );
    final style =
        button.style ?? Theme.of(context).elevatedButtonTheme.style;
    final shape =
        style!.shape!.resolve(const <WidgetState>{})! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(14));
  });

  testWidgets('lesson result TOTAL XP shows review-scaled award', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const LessonResultScreen(
            lessonTitle: 'Suits and ranks',
            result: _review,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    expect(find.text('TOTAL XP'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('25'), findsNothing);
  });

  testWidgets('lesson result shows imperfect accuracy from the server', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const LessonResultScreen(
            lessonTitle: 'Bet, raise, all-in',
            result: _imperfect,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    expect(tester.takeException(), isNull);
    expect(find.text('GREAT'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('100%'), findsNothing);
    expect(find.text('AMAZING'), findsNothing);
  });

  testWidgets(
    'embedded CONTINUE promotes anonymous Welcome draft to shell (LPT-70)',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final onboarding = OnboardingController(null);
      expect(onboarding.state.step, OnboardingStep.welcome);
      expect(onboarding.state.firstLessonCompleted, isFalse);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingControllerProvider.overrideWith((ref) => onboarding),
            authServiceProvider.overrideWithValue(_AnonymousAuthService()),
          ],
          child: MaterialApp(
            theme: buildPokerTheme(),
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder:
                                (_) => const LessonResultScreen(
                                  lessonTitle: 'Your two cards',
                                  result: _complete,
                                  standalone: false,
                                ),
                          ),
                        );
                      },
                      child: const Text('open-result'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-result'));
      await tester.pumpAndSettle();
      expect(find.text('Lesson Complete!'), findsOneWidget);
      expect(find.text('Get started'), findsNothing);

      await tester.ensureVisible(
        find.widgetWithText(ElevatedButton, 'CONTINUE'),
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
      await tester.pumpAndSettle();

      expect(onboarding.state.step, OnboardingStep.done);
      expect(onboarding.state.firstLessonCompleted, isTrue);
      expect(onboarding.state.pendingSaveProgress, isFalse);
      // Draft promotion remounts AppRoot onto shell in production; here the
      // under-route remains because this harness is not PokerLabApp.
      expect(find.text('Lesson Complete!'), findsNothing);
      expect(find.text('open-result'), findsOneWidget);
      expect(find.text('Get started'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'embedded CONTINUE still pops when guest already finished onboarding',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final onboarding = OnboardingController(null);
      await onboarding.continueLearningAsGuest();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            onboardingControllerProvider.overrideWith((ref) => onboarding),
            authServiceProvider.overrideWithValue(_AnonymousAuthService()),
          ],
          child: MaterialApp(
            theme: buildPokerTheme(),
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder:
                                (_) => const LessonResultScreen(
                                  lessonTitle: 'Suits and ranks',
                                  result: _complete,
                                  standalone: false,
                                ),
                          ),
                        );
                      },
                      child: const Text('open-result'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('open-result'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
      await tester.pumpAndSettle();

      expect(find.text('Lesson Complete!'), findsNothing);
      expect(find.text('open-result'), findsOneWidget);
      expect(onboarding.state.step, OnboardingStep.done);
    },
  );
}

/// Anonymous guest for embedded CONTINUE recovery.
class _AnonymousAuthService implements AuthService {
  @override
  Stream<User?> get authStateChanges => const Stream.empty();

  @override
  User? get currentUser => null;

  @override
  String? get currentUid => 'guest';

  @override
  bool get isAnonymous => true;

  @override
  Future<User> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) =>
      throw UnimplementedError();

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<User> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<User> signInAnonymously() => throw UnimplementedError();

  @override
  Future<User> linkWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) =>
      throw UnimplementedError();

  @override
  Future<User> linkWithGoogle() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}

  @override
  Future<void> signOut() async {}
}
