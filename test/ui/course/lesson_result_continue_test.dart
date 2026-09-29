/// Lesson result CONTINUE must leave the screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
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

    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'CONTINUE'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
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

    await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE'));
    await tester.pump();

    // Sole-route escape is handled by PokerLabApp remounting on saveProgress
    // and by onboarding pushing (not replacing) the runner.
    expect(find.text('LESSON COMPLETE'), findsOneWidget);
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
      await tester.pump(const Duration(milliseconds: 600));
    }

    for (final title in ['Suits and ranks', 'Button and blinds']) {
      await pumpResult(title);
      expect(tester.takeException(), isNull);
      expect(find.text('LESSON COMPLETE'), findsOneWidget);
      expect(find.text(title), findsOneWidget);
      expect(find.text('Clean work. That skill sticks.'), findsOneWidget);
      expect(find.text('R'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'CONTINUE'), findsOneWidget);

      final mascot = tester.widget<RexMascot>(find.byType(RexMascot));
      expect(mascot.mood, RexMood.celebrate);
      expect(find.bySemanticsLabel('Rex, celebrating'), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, RexMascot.celebrateAsset);
    }
  });

  testWidgets('lesson result shows this lesson XP and the daily goal', (
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
            dailyGoalMinutes: 10,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.takeException(), isNull);
    expect(find.text('XP earned'), findsOneWidget);
    expect(find.text('+25'), findsOneWidget);
    expect(find.text('Daily goal'), findsOneWidget);
    expect(find.text('10 minutes'), findsOneWidget);
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
}
