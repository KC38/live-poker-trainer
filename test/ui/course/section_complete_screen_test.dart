/// Section-end ceremony route and CONTINUE (LPT-793).
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/onboarding_provider.dart';
import 'package:live_poker_trainer/services/auth_service.dart';
import 'package:live_poker_trainer/ui/screens/lesson_result_screen.dart';
import 'package:live_poker_trainer/ui/screens/section_complete_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';

const _complete = CompleteCourseLessonResult(
  attemptId: 'a1',
  lessonId: 'lesson-01-06-02-section-one-jump',
  xpAwarded: 75,
  mastery: 1,
  streak: 1,
  acceptedAccuracy: 1,
  liveTrainingGranted: false,
  duplicate: false,
);

final _section = CourseSection(
  id: 'sec-01-never-played',
  order: 1,
  title: 'Never Played',
  summary: 'Foundations',
  experienceBand: 'never',
  units: const [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('section ceremony shows Rex, title, one CONTINUE at mini', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const SectionCompleteScreen(
            sectionOrder: 1,
            sectionTitle: 'Never Played',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    expect(tester.takeException(), isNull);
    expect(find.text('Section Complete!'), findsOneWidget);
    expect(find.text('SECTION 1'), findsOneWidget);
    expect(find.text('Never Played'), findsOneWidget);
    expect(find.text('R'), findsNothing);
    expect(find.widgetWithText(ElevatedButton, 'CONTINUE'), findsOneWidget);
    final mascot = tester.widget<RexMascot>(find.byType(RexMascot));
    expect(mascot.mood, RexMood.celebrate);
    expect(find.bySemanticsLabel('Rex, celebrating'), findsOneWidget);
  });

  testWidgets('LessonResult CONTINUE opens section ceremony when set', (
    tester,
  ) async {
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
                          builder: (_) => LessonResultScreen(
                            lessonTitle: 'Section 1 jump check',
                            result: _complete,
                            standalone: false,
                            completedSection: _section,
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
    expect(find.text('Section Complete!'), findsOneWidget);
    expect(find.text('SECTION 1'), findsOneWidget);
    expect(find.text('Never Played'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.text('Section Complete!'), findsNothing);
    expect(find.text('open-result'), findsOneWidget);
  });
}

/// Anonymous guest for embedded CONTINUE.
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
