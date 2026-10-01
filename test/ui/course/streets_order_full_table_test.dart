/// Streets and action order teaches on the full poker table.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/order_sequence_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_streets.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

Widget _frame(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: buildPokerTheme().copyWith(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: Scaffold(
        body: TableFeaturesScope(
          features: TableFeatures.forLessonId(
            'lesson-01-04-01-streets-and-order',
          ),
          child: LessonFrameScope(onLocalMiss: (_) {}, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('explain taps streets under the full table', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-04-01-explain-streets',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Four streets.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Preflop, flop, turn, river.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    var ack = 0;
    await tester.pumpWidget(
      _frame(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => ack += 1,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LessonStreetsExplainTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byType(StreetsTimelineDemo), findsNothing);

    for (final title in const ['PREFLOP', 'FLOP', 'TURN', 'RIVER']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(ack, 1);
  });

  testWidgets('street chips keep air above the tool row while glowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          backgroundColor: const Color(0xFF0B1220),
          body: LessonScreenLayout(
            progress: 0.2,
            livesRemaining: 4,
            livesMax: 5,
            onClose: () {},
            speech: 'Four streets: preflop, flop, turn, river. Tap each street.',
            expression: LessonMascotExpression.thinking,
            stage: LessonStreetsExplainTable(
              onAllStreetsTapped: () {},
            ),
            onUndo: () {},
            onRedo: () {},
            onHint: () {},
            canUndo: false,
            canRedo: false,
            canHint: true,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(GlowHighlight), findsWidgets);
    final preflopRect = tester.getRect(find.text('PREFLOP'));
    final undoRect = tester.getRect(find.byTooltip('Undo'));
    // Chip label bottom → undo top must clear glow inset + stage clearance.
    expect(
      undoRect.top - preflopRect.bottom,
      greaterThanOrEqualTo(
        LessonAnswerDock.stageGlowInset + LessonAnswerDock.stageClearance,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('aggressive action tiles keep air above the tool row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          backgroundColor: const Color(0xFF0B1220),
          body: LessonScreenLayout(
            progress: 0.3,
            livesRemaining: 4,
            livesMax: 5,
            onClose: () {},
            speech:
                'Three chip-pushing buttons. Tap Bet, then Raise, then All-in.',
            expression: LessonMascotExpression.thinking,
            stage: LessonAggressiveActionsExplainTable(
              onAllActionsTapped: () {},
            ),
            onUndo: () {},
            onRedo: () {},
            onHint: () {},
            canUndo: false,
            canRedo: false,
            canHint: true,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(GlowHighlight), findsWidgets);
    final betRect = tester.getRect(find.text('BET'));
    final raiseRect = tester.getRect(find.text('RAISE'));
    final undoRect = tester.getRect(find.byTooltip('Undo'));
    // SoftPulse cues one tile — gutter clears a single outset.
    expect(
      raiseRect.left - betRect.right,
      greaterThanOrEqualTo(GlowHighlight.gutter),
    );
    // Equal-height SoftPulse row + stage inset/clearance under the face.
    expect(
      undoRect.top - betRect.bottom,
      greaterThanOrEqualTo(
        GlowHighlight.outset +
            LessonAnswerDock.stageGlowInset +
            LessonAnswerDock.stageClearance,
      ),
    );
    Size cardSize(String label) {
      return tester.getSize(
        find
            .ancestor(
              of: find.text(label),
              matching: find.byType(InkWell),
            )
            .first,
      );
    }

    expect(
      cardSize('BET').height,
      moreOrLessEquals(cardSize('RAISE').height, epsilon: 0.5),
    );
    expect(
      cardSize('BET').height,
      moreOrLessEquals(cardSize('ALL-IN').height, epsilon: 0.5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('guided street order uses the full table', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-04-01-guided-streets',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 40,
      accessibilityText: 'Order streets.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the streets from first to last.',
      sequenceItems: const [
        CourseChoice(id: 'st-pre', label: 'Preflop'),
        CourseChoice(id: 'st-flop', label: 'Flop'),
        CourseChoice(id: 'st-turn', label: 'Turn'),
        CourseChoice(id: 'st-river', label: 'River'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    await tester.pumpWidget(
      _frame(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LessonStreetsOrderTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byKey(const ValueKey('street-order-palette')), findsOneWidget);

    // Palette is shuffled — not chronological left-to-right.
    const labels = ['Preflop', 'Flop', 'Turn', 'River'];
    final expectedPalette =
        shuffledSequencePalette(
          activityId: activity.id,
          items: activity.sequenceItems,
        ).map((item) => item.label).toList();
    expect(expectedPalette, isNot(labels));
    final shown = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const ValueKey('street-order-palette')),
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data)
        .toList();
    expect(shown, expectedPalette);

    for (final label in labels) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
    expect(controller.draft.orderedIds, [
      'st-pre',
      'st-flop',
      'st-turn',
      'st-river',
    ]);
    expect(autoSubmits, 1);
  });

  test('shuffledSequencePalette never leaves streets in authored order', () {
    const items = [
      CourseChoice(id: 'st-pre', label: 'Preflop'),
      CourseChoice(id: 'st-flop', label: 'Flop'),
      CourseChoice(id: 'st-turn', label: 'Turn'),
      CourseChoice(id: 'st-river', label: 'River'),
    ];
    final out = shuffledSequencePalette(
      activityId: 'act-01-04-01-guided-streets',
      items: items,
    );
    expect(out.map((item) => item.id).toList(), isNot([
      'st-pre',
      'st-flop',
      'st-turn',
      'st-river',
    ]));
    expect(out.map((item) => item.id).toSet(), {
      'st-pre',
      'st-flop',
      'st-turn',
      'st-river',
    });
    expect(
      shuffledSequencePalette(
        activityId: 'act-01-04-01-guided-streets',
        items: items,
      ).map((item) => item.id).toList(),
      out.map((item) => item.id).toList(),
    );
  });

  testWidgets('scaffolded seat order taps seats on the full table', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final activity = CourseActivity(
      id: 'act-01-04-01-scaffolded-order',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 50,
      accessibilityText: 'Put UTG, HJ, CO, and BTN in preflop action order.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap seats in the order they act preflop after blinds.',
      sequenceItems: const [
        CourseChoice(id: 'seat-utg', label: 'UTG'),
        CourseChoice(id: 'seat-hj', label: 'HJ'),
        CourseChoice(id: 'seat-co', label: 'CO'),
        CourseChoice(id: 'seat-btn', label: 'BTN'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    addTearDown(controller.dispose);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    await tester.pumpWidget(
      _frame(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(LessonSeatOrderSequenceTable), findsOneWidget);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byKey(const ValueKey('seat-order-felt')), findsNothing);
    expect(find.text('Your seat order'), findsNothing);
    expect(find.text('Build order here'), findsNothing);

    await tester.tap(find.text('UTG'));
    await tester.pump();
    await tester.tap(find.text('HJ'));
    await tester.pump();
    await tester.tap(find.text('CO'));
    await tester.pump();
    await tester.tap(find.text('BTN'));
    await tester.pump();

    expect(controller.draft.orderedIds, [
      'seat-utg',
      'seat-hj',
      'seat-co',
      'seat-btn',
    ]);
    expect(autoSubmits, 1);
  });
}
