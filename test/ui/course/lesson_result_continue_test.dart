/// Lesson result CONTINUE must leave the screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/screens/lesson_result_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

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
    expect(find.text('LESSON COMPLETE'), findsOneWidget);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'CONTINUE'));
    await tester.tap(find.widgetWithText(FilledButton, 'CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.text('LESSON COMPLETE'), findsNothing);
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
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.widgetWithText(FilledButton, 'CONTINUE'));
    await tester.pump();

    // Sole-route escape is handled by PokerLabApp remounting on saveProgress
    // and by onboarding pushing (not replacing) the runner.
    expect(find.text('LESSON COMPLETE'), findsOneWidget);
  });
}
