/// Lesson frame regions and the first-step peek table.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';

void main() {
  test('lesson mascot expressions map to Rex moods', () {
    expect(LessonMascotExpression.thinking.rexMood, RexMood.calm);
    expect(LessonMascotExpression.happy.rexMood, RexMood.celebrate);
    expect(LessonMascotExpression.wrong.rexMood, RexMood.think);
  });

  test('design record names the six lesson regions', () {
    final text = File('docs/ui/design-record.md').readAsStringSync();
    expect(text, contains('## Lesson screen layout'));
    expect(text, contains('lesson-screen-layout.mdc'));
    final rule =
        File('.cursor/rules/lesson-screen-layout.mdc').readAsStringSync();
    expect(rule, contains('LessonScreenLayout'));
    expect(rule, contains('alwaysApply: false'));
    expect(rule, contains('lib/ui/course/**'));
    expect(rule, contains('test/ui/course/**'));
    expect(File('.cursor/skills/lesson-screen-layout/SKILL.md').existsSync(), isFalse);
    expect(text, contains('These two are your cards alone.'));
    expect(text, contains('LessonScreenLayout'));
    expect(text, contains('LessonTableStage'));
    expect(text, contains('Oops, that\'s not correct'));
  });

  testWidgets('speech bubble top and first line stay put as copy length changes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const short = 'Tap.';
    const long =
        'These two are your cards alone. Nobody else sees them. '
        'Tap your cards to peek. The board in the middle is shared.';

    Future<({double mascot, double bubble, double text, double height})>
    measure(String speech) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme(),
          home: Scaffold(
            body: LessonCoachBand(
              speech: speech,
              expression: LessonMascotExpression.thinking,
            ),
          ),
        ),
      );
      await tester.pump();
      final bubble = find.byKey(const ValueKey<String>('lesson-speech-bubble'));
      return (
        mascot: tester.getTopLeft(find.bySemanticsLabel('Rex, calm')).dy,
        bubble: tester.getTopLeft(bubble).dy,
        text: tester.getTopLeft(find.text(speech)).dy,
        height: tester.getSize(bubble).height,
      );
    }

    final brief = await measure(short);
    final wordy = await measure(long);

    expect(brief.bubble, brief.mascot);
    expect(wordy.bubble, wordy.mascot);
    expect(brief.text - brief.bubble, wordy.text - wordy.bubble);
    expect(wordy.height, greaterThan(brief.height));
    expect(tester.takeException(), isNull);
  });

  testWidgets('frame keeps close, hearts, one bubble, tools, and no title', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: const Scaffold(
          body: LessonScreenLayout(
            progress: 0.2,
            livesRemaining: 3,
            livesMax: 3,
            onClose: _noop,
            speech:
                'These two are your cards alone. Nobody else sees them. '
                'Tap your cards to peek.',
            expression: LessonMascotExpression.thinking,
            stage: SizedBox.expand(),
            onUndo: _noop,
            onRedo: _noop,
            onHint: _noop,
            canUndo: false,
            canRedo: false,
            canHint: true,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.text('Solve the puzzle'), findsNothing);
    expect(find.text('Your two cards'), findsNothing);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(find.textContaining('Tap your cards to peek.'), findsOneWidget);
    expect(find.byType(RexMascot), findsOneWidget);
    expect(find.bySemanticsLabel('Rex, calm'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byTooltip('Redo'), findsOneWidget);
    expect(find.byTooltip('Hint'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accepted answer replaces the tools with Nice and Continue', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonScreenLayout(
            progress: 0.4,
            livesRemaining: 3,
            livesMax: 3,
            onClose: _noop,
            speech: 'Those two stay private.',
            expression: LessonMascotExpression.happy,
            stage: const SizedBox.expand(),
            onUndo: _noop,
            onRedo: _noop,
            onHint: _noop,
            canUndo: false,
            canRedo: false,
            canHint: false,
            onContinue: _noop,
            result: _result(accepted: true, feedback: 'Right.'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Nice!'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.byTooltip('Undo'), findsNothing);
    expect(find.byType(RexMascot), findsOneWidget);
    final mascot = tester.widget<RexMascot>(find.byType(RexMascot));
    expect(mascot.mood, RexMood.celebrate);
    expect(find.bySemanticsLabel('Rex, celebrating'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a miss shows the wrong face and the oops dock', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonScreenLayout(
            progress: 0.2,
            livesRemaining: 2,
            livesMax: 3,
            onClose: _noop,
            speech: 'Those cards belong to someone else.',
            expression: LessonMascotExpression.wrong,
            stage: const SizedBox.expand(),
            onUndo: _noop,
            onRedo: _noop,
            onHint: _noop,
            canUndo: false,
            canRedo: false,
            canHint: false,
            onContinue: _noop,
            result: _result(
              accepted: false,
              feedback: 'Yours are the two at your seat.',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text("Oops, that's not correct"), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.bySemanticsLabel('Rex, thinking'), findsOneWidget);
    final mascot = tester.widget<RexMascot>(find.byType(RexMascot));
    expect(mascot.mood, RexMood.think);
    expect(find.byIcon(Icons.favorite), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('peek turns your cards up and rejects another seat', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var peeks = 0;
    var misses = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonPeekTable(
            onPeek: () => peeks += 1,
            onMiss: () => misses += 1,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('A'), findsNothing);
    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-1')));
    await tester.pump();
    expect(misses, 1);
    expect(peeks, 0);
    expect(find.textContaining('A♥'), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-hero')));
    await tester.pump();
    expect(peeks, 1);
    expect(find.textContaining('A♥'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('blinds clockwise taps count only in button, small, big order', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 500));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var done = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonBlindsClockwiseTable(onComplete: () => done += 1),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('lesson-table-stage')), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('SB'), findsOneWidget);
    expect(find.text('BB'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-4')));
    await tester.pump();
    expect(done, 0);

    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-3')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-4')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-5')));
    await tester.pump();
    expect(done, 1);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}

SubmitCourseStepResult _result({
  required bool accepted,
  required String feedback,
}) {
  return SubmitCourseStepResult(
    attemptId: 'attempt',
    activityId: 'act-01-01-01-explain-hole-cards',
    grade: accepted ? SoftGrade.recommended : SoftGrade.clearMistake,
    feedback: feedback,
    accepted: accepted,
    lifeLost: false,
    livesRemaining: accepted ? 3 : 2,
    xpAwarded: 0,
    remediationRequired: false,
    resume: const CourseResumePointer(
      attemptId: 'attempt',
      lessonId: 'lesson-01-01-01-your-two-cards',
      activityId: 'act-01-01-01-explain-hole-cards',
      activityIndex: 0,
    ),
    duplicate: false,
  );
}
