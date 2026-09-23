/// Widget coverage for lesson activity shells and grade feedback.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/course/activities/authored_multi_step_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/full_table_hand_lab_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/numeric_pot_price_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/order_sequence_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/poker_action_sizing_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/guardrails_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/range_advantage_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/equity_realize_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/capped_uncapped_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/polar_merged_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/overbet_geometry_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/blockers_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/defend_enough_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/mixed_strategy_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/three_bet_four_bet_spr_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/hard_fold_cooler_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/selective_aggression_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/tag_model_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_best_five.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_choice_visuals.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_feedback_sheet.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_hand_examples.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_pots.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_streets.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_toy_hand.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

CourseActivity _activity({
  String id = 'act-test',
  required ActivityRenderer renderer,
  ActivityStage stage = ActivityStage.guided,
  List<CourseChoice> choices = const [],
  List<CourseChoice> sequenceItems = const [],
  String? numericQuestion,
  String? numericUnit,
}) {
  return CourseActivity(
    id: id,
    order: 1,
    stage: stage,
    renderer: renderer,
    estimatedSeconds: 30,
    accessibilityText: 'Test activity',
    acceptedGrades: const [SoftGrade.recommended],
    prompt: 'Prompt',
    choices: choices,
    sequenceItems: sequenceItems,
    numericQuestion: numericQuestion,
    numericUnit: numericUnit,
    coachMedia: const [
      CoachMediaRef(id: 'm1', kind: 'dialogue', text: 'Rex line'),
    ],
  );
}

Widget _wrap(Widget child) {
  final base = buildPokerTheme();
  return MaterialApp(
    theme: base.copyWith(
      // Flutter 3.47 + Impeller/SkSL mismatch crashes ink_sparkle in tests.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    ),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

SubmitCourseStepResult _result({
  required SoftGrade grade,
  required bool accepted,
  required bool lifeLost,
}) {
  return SubmitCourseStepResult(
    attemptId: 'a1',
    activityId: 'act-test',
    grade: grade,
    feedback: 'Feedback for $grade',
    accepted: accepted,
    lifeLost: lifeLost,
    livesRemaining: lifeLost ? 2 : 3,
    xpAwarded: accepted ? 10 : 0,
    remediationRequired: false,
    resume: const CourseResumePointer(
      attemptId: 'a1',
      lessonId: 'l1',
      activityId: 'act-test',
      activityIndex: 0,
    ),
    duplicate: false,
  );
}

void main() {
  testWidgets('hole-card explain shows demonstration cards', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-01-01-explain-hole-cards',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'These two are yours alone.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'These two are yours alone. Nobody else sees them.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.byType(MiniCard), findsNWidgets(2));
    expect(find.text('Rex'), findsWidgets);
    expect(find.text('Tap your two cards on the felt.'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('suits explain shows suits — not hole-card Ah/Kd demo', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-02-explain-suits',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Four suits, thirteen ranks. Ace is high here.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Four suits, thirteen ranks. Ace is high here.',
        ),
      ],
      objectives: const ['Name the four suits'],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.byType(SuitGlyphRow), findsOneWidget);
    expect(find.text('Thirteen ranks — ace high'), findsOneWidget);
    expect(find.byType(MiniCard), findsNothing);
    expect(
      find.text('Tap Continue when you have looked at your two cards.'),
      findsNothing,
    );
    expect(find.text('Tap each of the four suits.'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('position explain taps BTN on felt instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-01-01-explain-pos',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Later seats see more action.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Later seats see more action before they decide.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(LessonTableContext), findsOneWidget);
    expect(
      find.text('Tap the button (BTN) — the latest seat.'),
      findsOneWidget,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);

    // Soft-pulse runs while guidance is on — taps must still land on BTN.
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump(const Duration(milliseconds: 450));
    await tester.tap(
      find.descendant(
        of: find.byType(LessonTableContext),
        matching: find.text('BTN'),
      ),
    );
    await tester.pump();
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('soft-pulse glow does not block hole-card felt acknowledge', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-01-explain-hole-cards',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'These two are yours alone.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'These two are yours alone. Nobody else sees them.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(LessonTableContext), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 450));
    await tester.pump(const Duration(milliseconds: 450));

    final heroRail = find.byWidgetPredicate(
      (w) => w is MiniCard && w.size == MiniCardSize.hero,
    );
    expect(heroRail, findsAtLeastNWidgets(2));
    await tester.tap(heroRail.first);
    await tester.pump();
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('hand-ladder explain taps every rung instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-02-01-explain-ladder',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Pair beats high card. Flush beats a pair.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Pair beats high card. Flush beats a pair.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(HandRankLadderDemo), findsOneWidget);
    expect(find.text('Tap each rung from high card to flush.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);

    await tester.tap(find.text('High card'));
    await tester.pump();
    expect(feltAck, 0);
    await tester.tap(find.text('One pair'));
    await tester.pump();
    expect(feltAck, 0);
    await tester.tap(find.text('Flush'));
    await tester.pump();
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('best-five explain taps each highlighted card instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-02-02-explain-five',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Only five of seven cards play.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'You use five cards. Two are leftovers.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(BestFiveDemo), findsOneWidget);
    expect(
      find.text('Tap each highlighted card — those five count'),
      findsOneWidget,
    );
    // No duplicate gold hint under the felt (demo embeds the instruction).
    expect(
      find.text('Tap each highlighted card — only five of seven play.'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);

    final playing = find.byWidgetPredicate(
      (w) => w is SelectableBestFiveCard && w.enabled,
    );
    expect(playing, findsNWidgets(5));
    expect(
      find.byWidgetPredicate(
        (w) => w is SelectableBestFiveCard && w.highlighted && w.enabled,
      ),
      findsNWidgets(5),
    );
    for (final el in playing.evaluate()) {
      await tester.tap(find.byWidget(el.widget));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('passive explain taps Fold Check Call instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-03-01-explain-passive',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Fold, check, and call.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Fold gives up. Check passes free. Call matches.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(PassiveActionsDemo), findsOneWidget);
    expect(find.text('Tap Fold, Check, and Call.'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(feltAck, 0);
    await tester.tap(find.text('CHECK'));
    await tester.pump();
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('aggressive explain taps Bet Raise All-in instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-03-02-explain-aggro',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Bet, raise, and all-in.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Bet opens. Raise reopens. All-in commits.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(AggressiveActionsDemo), findsOneWidget);
    expect(find.text('Tap Bet, Raise, and All-in.'), findsOneWidget);
    await tester.tap(find.text('BET'));
    await tester.pump();
    await tester.tap(find.text('RAISE'));
    await tester.pump();
    await tester.tap(find.text('ALL-IN'));
    await tester.pump();
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('streets explain taps each street instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-04-01-explain-streets',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Four streets of a hand.',
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
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(StreetsTimelineDemo), findsOneWidget);
    for (final title in ['PREFLOP', 'FLOP', 'TURN', 'RIVER']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('winning-paths explain taps each path instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-05-01-explain-win',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'How a pot is won.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Fold win, showdown, side pot.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(WinningPathsDemo), findsOneWidget);
    for (final title in ['FOLD WIN', 'SHOWDOWN', 'SIDE POT']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('toy-hand explain taps each step instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-06-01-explain-run',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'One short hand.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Blinds, you act, ending.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(ToyHandRunDemo), findsOneWidget);
    for (final title in ['BLINDS', 'YOU ACT', 'ENDING']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  test('resolveCoachDialogueVisual is content-driven', () {
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-01-01-02-explain-suits',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Four suits',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.suitsRanks,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-02-01-02-explain-order',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Preflop starts left of the big blind. Postflop starts left of the button.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.actionOrder,
    );
    // "whole edge" must not match substring "hole"; later-seats → position demo.
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-generic-pos-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Later seats see more. That is the whole edge.',
          acceptedGrades: const [SoftGrade.recommended],
          objectives: const ['Prefer later seats when choosing hands'],
        ),
      ).kind,
      CoachDialogueVisualKind.positionLabels,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-generic-button-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Button marks the dealer. Blinds sit left of it.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.dealerButton,
    );
    // Families / open-range explains teach by tapping tiles (not suits/button).
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-02-02-01-explain-families',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Pairs, broadways, suited aces, connectors — trash is everything else.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.handFamilies,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-02-03-01-explain-open',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Early: strong only. Button: wider. Live opens often look like 3x.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.openRange,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-02-04-01-explain-vs',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Weak hands fold. Playable hands call. Strong hands make it more.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.vsOpenResponse,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-02-05-01-explain-bb',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Count stacks in big blinds. The shorter stack sets the ceiling.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.bbStackDepth,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-02-06-01-explain-habits',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Watch the action. Say your action. Cover your cards. Wait your turn.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.tableHabits,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-02-07-01-explain-full',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Nine seats. Same rules. Position still runs the show.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.fullRing,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-03-01-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Before cards, read pot, stacks, button, and who acts. Words count live.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.tableRead,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-03-02-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Flop first: made, draw, showdown value, or air. Label before you bet.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.flopLabel,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-03-03-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Clean outs help. Dirty outs improve you into second-best. Price the call.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.outsPrice,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-03-04-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Flop lines: value, c-bet, check back, call, fold, raise. One plan.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.flopLines,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-03-05-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Turn cards either brick or change the story. Barrel or delay with intent.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.turnStory,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-03-06-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'River is binary: value, bluff, bluff-catch, or fold. No mystery floats.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.riverBinary,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-03-07-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'More players: stronger value, fewer bluffs, chase nuts not second-best.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.multiwayPlan,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-03-08-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Common leaks: worship top pair, chase bad prices, call too passive, bluff crowds.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.commonLeaks,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-04-01-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'You never know one hand. You know a range — then update it.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.rangeUpdate,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-04-02-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              '3-bets define ranges. Squeezes punish multiway limps and flatting.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.threeBetSqueeze,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-generic-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Listen up.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.none,
    );
    // Safer value/bluff routing — later explains must not steal river/multiway/BB demos.
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-04-08-03-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Versus maniacs: call wider for value, let them hang themselves, no ego.',
          objectives: const ['Widen value and bluff-catch'],
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.vsManiacs,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-generic-maniac-only',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'A maniac sat down.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.none,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-05-04-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Thin value needs calls. Bluff-catches need wide barrels.',
          objectives: const ['Choose thin value versus sticky callers'],
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.thinValue,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-04-06-03-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Versus stations: thicker value, fewer pure bluffs. Cite their calling.',
          objectives: const ['Value wider versus Calling Station'],
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.vsStation,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-04-07-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Some seats almost never enter. When they do, they mean it. Note both.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.tightSeats,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-generic-enter-only',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Enter the pot carefully.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.none,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-04-05-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'SPR = effective stack / pot. Low SPR: commit. High SPR: maneuver.',
          objectives: const ['Estimate stack-to-pot ratio'],
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.sprDepth,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-04-06-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Before labels: who enters pots, who calls, who folds. Count samples.',
          objectives: const ['Tag high participation'],
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.playerObserve,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-04-06-02-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Calling Station is a working model: high participation, low folding.',
          objectives: const ['Introduce Calling Station'],
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.callingStation,
    );
    // Generic multiway / river copy without an authored id still resolves correctly.
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-generic-multiway-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'More players: stronger value, fewer bluffs, chase nuts not second-best.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.multiwayPlan,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-generic-river-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'River is binary: value, bluff, bluff-catch, or fold. No mystery floats.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.riverBinary,
    );
  });

  testWidgets('action-order explain taps UTG HJ BTN instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-01-02-explain-order',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Preflop starts left of the big blind. Postflop starts left of the button.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Preflop starts left of the big blind. Postflop starts left of the button.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(ActionOrderDemo), findsOneWidget);
    expect(find.text('Tap UTG, then HJ, then BTN.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    await tester.tap(find.text('UTG'));
    await tester.pump();
    expect(feltAck, 0);
    await tester.tap(find.text('HJ'));
    await tester.pump();
    expect(feltAck, 0);
    await tester.tap(find.text('BTN'));
    await tester.pump();
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('hand-families explain taps each family instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-02-01-explain-families',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Pairs, broadways, suited aces, connectors — trash is everything else.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Pairs, broadways, suited aces, connectors — trash is everything else.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(HandFamiliesDemo), findsOneWidget);
    expect(find.text('Tap each starting-hand family.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['Pairs', 'Broadways', 'Suited aces', 'Connectors']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('open-range explain taps Early Button Live 3x instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-03-01-explain-open',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Early: strong only. Button: wider. Live opens often look like 3x.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Early: strong only. Button: wider. Live opens often look like 3x.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(OpenRangeDemo), findsOneWidget);
    expect(find.text('Tap Early, Button, and Live 3x.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['EARLY', 'BUTTON', 'LIVE 3x']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('vs-open explain taps Fold Call 3-Bet instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-04-01-explain-vs',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Weak hands fold. Playable hands call. Strong hands make it more.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Weak hands fold. Playable hands call. Strong hands make it more.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(VsOpenResponseDemo), findsOneWidget);
    expect(find.text('Tap Fold, Call, and 3-Bet.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['FOLD', 'CALL', '3-BET']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('bb-stack explain taps Chips→BB Shorter Depth instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-05-01-explain-bb',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Count stacks in big blinds. The shorter stack sets the ceiling.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Count stacks in big blinds. The shorter stack sets the ceiling.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(BbStackDepthDemo), findsOneWidget);
    expect(find.text('Tap Chips→BB, Shorter, and Depth.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['CHIPS→BB', 'SHORTER', 'DEPTH']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('table-habits explain taps Watch Say Cover Wait instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-06-01-explain-habits',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Watch the action. Say your action. Cover your cards. Wait your turn.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Watch the action. Say your action. Cover your cards. Wait your turn.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(TableHabitsDemo), findsOneWidget);
    expect(find.text('Tap Watch, Say, Cover, and Wait.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['WATCH', 'SAY', 'COVER', 'WAIT']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('full-ring explain taps Nine Same Position instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-07-01-explain-full',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Nine seats. Same rules. Position still runs the show.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Nine seats. Same rules. Position still runs the show.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(FullRingDemo), findsOneWidget);
    expect(find.text('Tap Nine, Same, and Position.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['NINE', 'SAME', 'POSITION']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('table-read explain taps Pot Stacks Button Who Acts instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-01-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Before cards, read pot, stacks, button, and who acts. Words count live.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Before cards, read pot, stacks, button, and who acts. Words count live.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(TableReadDemo), findsOneWidget);
    expect(
      find.text('Tap Pot, Stacks, Button, and Who Acts.'),
      findsOneWidget,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['POT', 'STACKS', 'BUTTON', 'WHO ACTS']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('flop-label explain taps Made Draw SDV Air instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-02-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Flop first: made, draw, showdown value, or air. Label before you bet.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Flop first: made, draw, showdown value, or air. Label before you bet.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(FlopLabelDemo), findsOneWidget);
    expect(find.text('Tap Made, Draw, SDV, and Air.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['MADE', 'DRAW', 'SDV', 'AIR']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('outs-price explain taps Clean Dirty Price instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-03-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Clean outs help. Dirty outs improve you into second-best. Price the call.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Clean outs help. Dirty outs improve you into second-best. Price the call.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(OutsPriceDemo), findsOneWidget);
    expect(find.text('Tap Clean, Dirty, and Price.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['CLEAN', 'DIRTY', 'PRICE']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('flop-lines explain taps each line instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-04-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Flop lines: value, c-bet, check back, call, fold, raise. One plan.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Flop lines: value, c-bet, check back, call, fold, raise. One plan.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(FlopLinesDemo), findsOneWidget);
    expect(find.text('Tap each flop line once.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['VALUE', 'C-BET', 'CHECK', 'CALL', 'FOLD', 'RAISE']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('turn-story explain taps Brick Change Barrel Delay instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-05-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Turn cards either brick or change the story. Barrel or delay with intent.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Turn cards either brick or change the story. Barrel or delay with intent.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(TurnStoryDemo), findsOneWidget);
    expect(
      find.text('Tap Brick, Change, Barrel, and Delay.'),
      findsOneWidget,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['BRICK', 'CHANGE', 'BARREL', 'DELAY']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('river-binary explain taps Value Bluff Catch Fold instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-06-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'River is binary: value, bluff, bluff-catch, or fold. No mystery floats.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'River is binary: value, bluff, bluff-catch, or fold. No mystery floats.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(RiverBinaryDemo), findsOneWidget);
    expect(find.text('Tap Value, Bluff, Catch, and Fold.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['VALUE', 'BLUFF', 'CATCH', 'FOLD']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('common-leaks explain taps each leak instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-08-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Common leaks: worship top pair, chase bad prices, call too passive, bluff crowds.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Common leaks: worship top pair, chase bad prices, call too passive, bluff crowds.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(CommonLeaksDemo), findsOneWidget);
    expect(find.text('Tap each common leak once.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['TOP PAIR', 'PRICES', 'PASSIVE', 'CROWDS']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('range-update explain taps One Hand Range Update instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-01-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'You never know one hand. You know a range — then update it.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'You never know one hand. You know a range — then update it.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(RangeUpdateDemo), findsOneWidget);
    expect(find.text('Tap One Hand, Range, and Update.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['ONE HAND', 'RANGE', 'UPDATE']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('threebet-squeeze explain taps 3-Bet Ranges Squeeze instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-02-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          '3-bets define ranges. Squeezes punish multiway limps and flatting.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              '3-bets define ranges. Squeezes punish multiway limps and flatting.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(ThreeBetSqueezeDemo), findsOneWidget);
    expect(find.text('Tap 3-Bet, Ranges, and Squeeze.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['3-BET', 'RANGES', 'SQUEEZE']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('multistreet-plan explain taps Flop Turn River instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-03-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Every flop choice should answer: what do I do on turn and river?',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Every flop choice should answer: what do I do on turn and river?',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(MultiStreetPlanDemo), findsOneWidget);
    expect(find.text('Tap Flop, Turn, and River.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['FLOP', 'TURN', 'RIVER']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('sizing-language explain taps Value Pressure Size instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-04-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Size is language. Value looks like value; pressure looks like pressure.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Size is language. Value looks like value; pressure looks like pressure.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(SizingLanguageDemo), findsOneWidget);
    expect(find.text('Tap Value, Pressure, and Size.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['VALUE', 'PRESSURE', 'SIZE']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('spr explain taps SPR Low High instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-05-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'SPR = effective stack / pot. Low SPR: commit. High SPR: maneuver.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'SPR = effective stack / pot. Low SPR: commit. High SPR: maneuver.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(SprDepthDemo), findsOneWidget);
    expect(find.text('Tap SPR, Low, and High.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['SPR', 'LOW', 'HIGH']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('player-observe explain taps Enters Calls Folds instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Before labels: who enters pots, who calls, who folds. Count samples.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Before labels: who enters pots, who calls, who folds. Count samples.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(PlayerObserveDemo), findsOneWidget);
    expect(find.text('Tap Enters, Calls, and Folds.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['ENTERS', 'CALLS', 'FOLDS']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('calling-station explain taps Station High Low instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-02-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Calling Station is a working model: high participation, low folding.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Calling Station is a working model: high participation, low folding.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(CallingStationDemo), findsOneWidget);
    expect(find.text('Tap Station, High, and Low.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['STATION', 'HIGH', 'LOW']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('vs-station explain taps Value Bluffs Cite instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-03-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Versus stations: thicker value, fewer pure bluffs. Cite their calling.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Versus stations: thicker value, fewer pure bluffs. Cite their calling.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(VsStationDemo), findsOneWidget);
    expect(find.text('Tap Value, Bluffs, and Cite.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['VALUE', 'BLUFFS', 'CITE']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('tight-seats explain taps Rare Enter Mean It instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-07-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Some seats almost never enter. When they do, they mean it. Note both.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Some seats almost never enter. When they do, they mean it. Note both.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(TightSeatsDemo), findsOneWidget);
    expect(find.text('Tap Rare, Enter, and Mean It.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['RARE', 'ENTER', 'MEAN IT']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('nit-model explain taps Nit Narrow Respect instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-07-02-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Nit means narrow entry and respect for their heavy action.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Nit means narrow entry and respect for their heavy action.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(NitModelDemo), findsOneWidget);
    expect(find.text('Tap Nit, Narrow, and Respect.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['NIT', 'NARROW', 'RESPECT']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets(
    'vs-nits explain taps Steal Credit Explode instead of Continue',
    (tester) async {
    final activity = CourseActivity(
      id: 'act-04-07-03-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Versus nits: steal blinds more; give credit when they explode.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Versus nits: steal blinds more; give credit when they explode.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(VsNitsDemo), findsOneWidget);
    expect(find.text('Tap Steal, Credit, and Explode.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['STEAL', 'CREDIT', 'EXPLODE']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('extreme-entry explain taps Raise Barrel Count instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-08-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Some seats raise and barrel seemingly forever. Count it calmly.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Some seats raise and barrel seemingly forever. Count it calmly.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(ExtremeEntryDemo), findsOneWidget);
    expect(find.text('Tap Raise, Barrel, and Count.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['RAISE', 'BARREL', 'COUNT']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('maniac-model explain taps Maniac Entry Aggro instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-08-02-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Maniac means extreme entry and aggression — a model, not an insult.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Maniac means extreme entry and aggression — a model, not an insult.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(ManiacModelDemo), findsOneWidget);
    expect(find.text('Tap Maniac, Entry, and Aggro.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['MANIAC', 'ENTRY', 'AGGRO']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets(
    'vs-maniacs explain taps Wider Hang Ego instead of Continue',
    (tester) async {
    final activity = CourseActivity(
      id: 'act-04-08-03-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Versus maniacs: call wider for value, let them hang themselves, no ego.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Versus maniacs: call wider for value, let them hang themselves, no ego.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(VsManiacsDemo), findsOneWidget);
    expect(find.text('Tap Wider, Hang, and Ego.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['WIDER', 'HANG', 'EGO']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets(
    'observation-certainty explain taps Observe Samples Showdowns instead of Continue',
    (tester) async {
    final activity = CourseActivity(
      id: 'act-04-09-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Observation ≠ certainty. Confidence grows with samples and showdowns.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Observation ≠ certainty. Confidence grows with samples and showdowns.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(ObservationCertaintyDemo), findsOneWidget);
    expect(find.text('Tap Observe, Samples, and Showdowns.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['OBSERVE', 'SAMPLES', 'SHOWDOWNS']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('exploit-evidence explain taps Cards Seats Evidence instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-10-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Same cards. Different seats. Exploits change only with evidence.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Same cards. Different seats. Exploits change only with evidence.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(ExploitEvidenceDemo), findsOneWidget);
    expect(find.text('Tap Cards, Seats, and Evidence.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['CARDS', 'SEATS', 'EVIDENCE']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('multiway-nuts explain taps Nutted Air Domination instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-01-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Multiway: nutted hands up, air down. Domination hurts more.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Multiway: nutted hands up, air down. Domination hurts more.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(MultiwayNutsDemo), findsOneWidget);
    expect(find.text('Tap Nutted, Air, and Domination.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['NUTTED', 'AIR', 'DOMINATION']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('deep-stacks explain taps Deep Realize Stack instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-02-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Deep: more room to realize. Also more room to lose a stack.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Deep: more room to realize. Also more room to lose a stack.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(DeepStacksDemo), findsOneWidget);
    expect(find.text('Tap Deep, Realize, and Stack.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['DEEP', 'REALIZE', 'STACK']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets(
    'implied-odds explain taps Implied Reverse Second instead of Continue',
    (tester) async {
    final activity = CourseActivity(
      id: 'act-05-03-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Implied odds: future money. Reverse implied: future losses when second-best.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Implied odds: future money. Reverse implied: future losses when second-best.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(ImpliedOddsDemo), findsOneWidget);
    expect(find.text('Tap Implied, Reverse, and Second.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['IMPLIED', 'REVERSE', 'SECOND']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('thin-value explain taps Thin Catch Barrels instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-04-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Thin value needs calls. Bluff-catches need wide barrels.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Thin value needs calls. Bluff-catches need wide barrels.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(ThinValueDemo), findsOneWidget);
    expect(find.text('Tap Thin, Catch, and Barrels.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['THIN', 'CATCH', 'BARRELS']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('line-stories explain taps X/R Probe Delay Donk instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-05-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Lines mean ranges. Check-raise, probe, delay, donk — each updates the story.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Lines mean ranges. Check-raise, probe, delay, donk — each updates the story.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(LineStoriesDemo), findsOneWidget);
    expect(find.text('Tap X/R, Probe, Delay, and Donk.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['X/R', 'PROBE', 'DELAY', 'DONK']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('range-rewrite explain taps Action Rewrite Update instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-06-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Each action rewrites the range. Keep updating.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Each action rewrites the range. Keep updating.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(RangeRewriteDemo), findsOneWidget);
    expect(find.text('Tap Action, Rewrite, and Update.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['ACTION', 'REWRITE', 'UPDATE']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('timing-clues explain taps Timing Sizing Clues instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-07-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Timing and sizing are clues, not mind-reading. Small updates only.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Timing and sizing are clues, not mind-reading. Small updates only.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(TimingCluesDemo), findsOneWidget);
    expect(find.text('Tap Timing, Sizing, and Clues.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['TIMING', 'SIZING', 'CLUES']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets('tables-change explain taps Stuck Tilted Gears instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-08-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Tables change. Stuck, tilted, tired, or shifting gears — update.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Tables change. Stuck, tilted, tired, or shifting gears — update.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(TablesChangeDemo), findsOneWidget);
    expect(find.text('Tap Stuck, Tilted, and Gears.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['STUCK', 'TILTED', 'GEARS']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });


  testWidgets('guardrails explain taps Quit Guard First instead of Continue', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-09-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Winning 1/2 includes knowing when to quit. Guardrails first.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Winning 1/2 includes knowing when to quit. Guardrails first.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(GuardrailsDemo), findsOneWidget);
    expect(find.text('Tap Quit, Guard, and First.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['QUIT', 'GUARD', 'FIRST']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets(
    'range-advantage explain taps Range Nut Advantage instead of Continue',
    (tester) async {
    final activity = CourseActivity(
      id: 'act-06-01-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Range advantage: more strong hands overall. Nut advantage: more of the nuts.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Range advantage: more strong hands overall. Nut advantage: more of the nuts.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(RangeAdvantageDemo), findsOneWidget);
    expect(find.text('Tap Range, Nut, and Advantage.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['RANGE', 'NUT', 'ADVANTAGE']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets(
    'equity-realize explain taps Equity Cash Pos instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-02-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Equity on a chart is not cash. Position decides realization.',
        acceptedGrades: const [SoftGrade.recommended],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text:
                'Equity on a chart is not cash. Position decides realization.',
          ),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      var feltAck = 0;
      await tester.pumpWidget(
        _wrap(
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => feltAck += 1,
          ),
        ),
      );
      expect(find.byType(EquityRealizeDemo), findsOneWidget);
      expect(find.text('Tap Equity, Cash, and Pos.'), findsOneWidget);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      for (final title in ['EQUITY', 'CASH', 'POS']) {
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(feltAck, 1);
      controller.dispose();
    },
  );


  testWidgets(
    'capped-uncapped explain taps Capped Uncapped Nuts instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-03-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Capped = nuts unlikely. Uncapped = nuts still live.',
        acceptedGrades: const [SoftGrade.recommended],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Capped = nuts unlikely. Uncapped = nuts still live.',
          ),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      var feltAck = 0;
      await tester.pumpWidget(
        _wrap(
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => feltAck += 1,
          ),
        ),
      );
      expect(find.byType(CappedUncappedDemo), findsOneWidget);
      expect(find.text('Tap Capped, Uncapped, and Nuts.'), findsOneWidget);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      for (final title in ['CAPPED', 'UNCAPPED', 'NUTS']) {
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(feltAck, 1);
      controller.dispose();
    },
  );


  testWidgets(
    'polar-merged explain taps Polar Merged Size instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-04-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Polar: nuts or air. Merged: many medium-strong hands. Size accordingly.',
        acceptedGrades: const [SoftGrade.recommended],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text:
                'Polar: nuts or air. Merged: many medium-strong hands. Size accordingly.',
          ),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      var feltAck = 0;
      await tester.pumpWidget(
        _wrap(
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => feltAck += 1,
          ),
        ),
      );
      expect(find.byType(PolarMergedDemo), findsOneWidget);
      expect(find.text('Tap Polar, Merged, and Size.'), findsOneWidget);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      for (final title in ['POLAR', 'MERGED', 'SIZE']) {
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(feltAck, 1);
      controller.dispose();
    },
  );


  testWidgets(
    'overbet-geometry explain taps Overbet Polar Geo instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-05-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Overbets need a polar story. Geometry links flop-turn-river sizes.',
        acceptedGrades: const [SoftGrade.recommended],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text:
                'Overbets need a polar story. Geometry links flop-turn-river sizes.',
          ),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      var feltAck = 0;
      await tester.pumpWidget(
        _wrap(
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => feltAck += 1,
          ),
        ),
      );
      expect(find.byType(OverbetGeometryDemo), findsOneWidget);
      expect(find.text('Tap Overbet, Polar, and Geo.'), findsOneWidget);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      for (final title in ['OVERBET', 'POLAR', 'GEO']) {
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(feltAck, 1);
      controller.dispose();
    },
  );


  testWidgets(
    'blockers explain taps Block Use No EV instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-06-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Blockers remove hands. Use them; do not invent EV decimals.',
        acceptedGrades: const [SoftGrade.recommended],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text:
                'Blockers remove hands. Use them; do not invent EV decimals.',
          ),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      var feltAck = 0;
      await tester.pumpWidget(
        _wrap(
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => feltAck += 1,
          ),
        ),
      );
      expect(find.byType(BlockersDemo), findsOneWidget);
      expect(find.text('Tap Block, Use, and No EV.'), findsOneWidget);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      for (final title in ['BLOCK', 'USE', 'NO EV']) {
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets(
    'multiway explain taps Stronger Fewer Nuts instead of Continue',
    (tester) async {
    final activity = CourseActivity(
      id: 'act-03-07-01-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'More players: stronger value, fewer bluffs, chase nuts not second-best.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'More players: stronger value, fewer bluffs, chase nuts not second-best.',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var feltAck = 0;
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () => feltAck += 1,
        ),
      ),
    );
    expect(find.byType(MultiwayPlanDemo), findsOneWidget);
    expect(find.text('Tap Stronger, Fewer, and Nuts.'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    for (final title in ['STRONGER', 'FEWER', 'NUTS']) {
      await tester.tap(find.text(title));
      await tester.pump();
    }
    expect(feltAck, 1);
    controller.dispose();
  });

  testWidgets(
    'defend-enough explain taps Defend Bluff Enough instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-07-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Defend enough that over-bluffing fails. No fake percentages.',
        acceptedGrades: const [SoftGrade.recommended],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text:
                'Defend enough that over-bluffing fails. No fake percentages.',
          ),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      var feltAck = 0;
      await tester.pumpWidget(
        _wrap(
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => feltAck += 1,
          ),
        ),
      );
      expect(find.byType(DefendEnoughDemo), findsOneWidget);
      expect(find.text('Tap Defend, Bluff, and Enough.'), findsOneWidget);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      for (final title in ['DEFEND', 'BLUFF', 'ENOUGH']) {
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(feltAck, 1);
      controller.dispose();
    },
  );



  testWidgets(
    'mix-strategy explain taps Mix Purpose Strong instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-08-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Mixing is frequency with a purpose — not coin-flip theater.',
        acceptedGrades: const [SoftGrade.recommended],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text:
                'Mixing is frequency with a purpose — not coin-flip theater.',
          ),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      var feltAck = 0;
      await tester.pumpWidget(
        _wrap(
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => feltAck += 1,
          ),
        ),
      );
      expect(find.byType(MixedStrategyDemo), findsOneWidget);
      expect(find.text('Tap Mix, Purpose, and Strong.'), findsOneWidget);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      for (final title in ['MIX', 'PURPOSE', 'STRONG']) {
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets(
    '3-bet/4-bet SPR explain taps 3BET 4BET DEPTH instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-09-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            '3-bet and 4-bet pots shrink ranges and SPR. Depth decides commitment.',
        acceptedGrades: const [SoftGrade.recommended],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text:
                '3-bet and 4-bet pots shrink ranges and SPR. Depth decides commitment.',
          ),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      var feltAck = 0;
      await tester.pumpWidget(
        _wrap(
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => feltAck += 1,
          ),
        ),
      );
      expect(find.byType(ThreeBetFourBetSprDemo), findsOneWidget);
      expect(find.text('Tap 3-Bet, 4-Bet, and Depth.'), findsOneWidget);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      for (final title in ['3BET', '4BET', 'DEPTH']) {
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets(
    'hard-fold-cooler explain taps Hard Cooler Ego instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-10-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Hard folds save buy-ins. Coolers happen; ego call-downs are mistakes.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Fold dominated one-pair in heat'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text:
                'Hard folds save buy-ins. Coolers happen; ego call-downs are mistakes.',
          ),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      var feltAck = 0;
      await tester.pumpWidget(
        _wrap(
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => feltAck += 1,
          ),
        ),
      );
      expect(find.byType(HardFoldCoolerDemo), findsOneWidget);
      expect(find.text('Tap Hard, Cooler, and Ego.'), findsOneWidget);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      for (final title in ['HARD', 'COOLER', 'EGO']) {
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets(
    'selective-aggression explain taps Tight Barrel Sample instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-11-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Before labels: who enters tight, then barrels with a plan? Count samples.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Note selective entry'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text:
                'Before labels: who enters tight, then barrels with a plan? Count samples.',
          ),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      var feltAck = 0;
      await tester.pumpWidget(
        _wrap(
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => feltAck += 1,
          ),
        ),
      );
      expect(find.byType(SelectiveAggressionDemo), findsOneWidget);
      expect(find.text('Tap Tight, Barrel, and Sample.'), findsOneWidget);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      for (final title in ['TIGHT', 'BARREL', 'SAMPLE']) {
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets(
    'TAG explain taps Tight Aggro Model instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-11-02-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'TAG: tight in, aggressive after — a working model.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Introduce TAG'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'TAG: tight in, aggressive after — a working model.',
          ),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      var feltAck = 0;
      await tester.pumpWidget(
        _wrap(
          CoachDialogueActivity(
            activity: activity,
            controller: controller,
            showGuidance: true,
            onFeltAcknowledge: () => feltAck += 1,
          ),
        ),
      );
      expect(find.byType(TagModelDemo), findsOneWidget);
      expect(find.text('Tap Tight, Aggro, and Model.'), findsOneWidget);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      for (final title in ['TIGHT', 'AGGRO', 'MODEL']) {
        await tester.tap(find.text(title));
        await tester.pump();
      }
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('select identify selects a choice', (tester) async {
    final activity = _activity(
      renderer: ActivityRenderer.selectIdentify,
      choices: const [
        CourseChoice(
          id: 'c1',
          label: 'Hole cards',
          accessibilityText: 'Pick hole cards',
        ),
        CourseChoice(id: 'c2', label: 'Board'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.tap(find.text('Hole cards'));
    await tester.pump();
    expect(controller.draft.choiceId, 'c1');
    controller.dispose();
  });

  testWidgets('first-lesson privacy select taps hole cards on the table', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-01-scaffolded-private',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap your private hole cards.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the cards only you can see.',
      choices: const [
        CourseChoice(id: 'choice-only-you', label: 'Only you'),
        CourseChoice(id: 'choice-whole-table', label: 'Everyone at the table'),
        CourseChoice(id: 'choice-dealer-only', label: 'Only the dealer'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );

    expect(find.text('Tap the cards only you can see.'), findsOneWidget);
    expect(find.text('Tap the cards only you can see.'), findsOneWidget);
    expect(find.byType(LessonTableContext), findsOneWidget);
    expect(find.byType(MiniCard), findsAtLeastNWidgets(2));
    expect(find.text('Only you'), findsNothing);
    expect(find.text('Everyone at the table'), findsNothing);

    final heroRail = find.byWidgetPredicate(
      (w) => w is MiniCard && w.size == MiniCardSize.hero,
    );
    expect(heroRail, findsAtLeastNWidgets(2));
    await tester.tap(heroRail.first);
    await tester.pump();
    expect(controller.draft.choiceId, 'choice-only-you');
    controller.dispose();
  });

  testWidgets('Button and blinds guided tap selects dealer button on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-03-guided-button',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the seat that has the dealer button chip.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the dealer button on the table.',
      choices: const [
        CourseChoice(id: 'btn-seat', label: 'The seat with the D chip'),
        CourseChoice(id: 'bb-seat', label: 'The seat that posted 2 chips'),
        CourseChoice(id: 'empty-seat', label: 'Any empty seat'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );

    expect(find.text('Tap the dealer button on the table.'), findsOneWidget);
    expect(find.byType(LessonTableContext), findsOneWidget);
    expect(find.text('The seat with the D chip'), findsNothing);
    // Identify steps hide role word labels — chips alone teach.
    expect(find.text('Button'), findsNothing);
    expect(find.text('Small blind'), findsNothing);
    expect(find.text('Big blind'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(LessonTableContext),
        matching: find.text('D'),
      ),
    );
    await tester.pump();
    expect(controller.draft.choiceId, 'btn-seat');

    // Big blind is the stacked chips labeled "2" (no word spoiler).
    await tester.tap(
      find
          .descendant(
            of: find.byType(LessonTableContext),
            matching: find.text('2'),
          )
          .first,
    );
    await tester.pump();
    expect(controller.draft.choiceId, 'bb-seat');
    controller.dispose();
  });

  testWidgets('Position labels guided tap selects BTN on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-02-01-01-guided-btn',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the button seat — last to act after the flop.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap who acts last postflop.',
      choices: const [
        CourseChoice(id: 'pos-btn', label: 'BTN'),
        CourseChoice(id: 'pos-bb', label: 'BB'),
        CourseChoice(id: 'pos-ep', label: 'EP'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );

    expect(find.text('Tap who acts last postflop.'), findsOneWidget);
    expect(find.byType(LessonTableContext), findsOneWidget);
    // Choice prose buttons are hidden — labels live on the felt chips.
    expect(find.text('On the button'), findsNothing);

    await tester.tap(
      find.descendant(
        of: find.byType(LessonTableContext),
        matching: find.text('BTN'),
      ),
    );
    await tester.pump();
    expect(controller.draft.choiceId, 'pos-btn');

    await tester.tap(
      find.descendant(
        of: find.byType(LessonTableContext),
        matching: find.text('EP'),
      ),
    );
    await tester.pump();
    expect(controller.draft.choiceId, 'pos-ep');
    controller.dispose();
  });

  testWidgets('Button and blinds timing tap selects before deal', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-03-unguided-when',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the hand phase when blinds are posted.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap when the blinds go in.',
      choices: const [
        CourseChoice(
          id: 'before-deal',
          label: 'Before any hole cards are dealt',
        ),
        CourseChoice(id: 'after-flop', label: 'After the flop'),
        CourseChoice(
          id: 'only-showdown',
          label: 'Only if the hand reaches showdown',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: false,
        ),
      ),
    );

    expect(find.text('Before deal'), findsOneWidget);
    await tester.tap(find.text('Before deal'));
    await tester.pump();
    expect(controller.draft.choiceId, 'before-deal');
    controller.dispose();
  });

  test('resolveLessonTableScene covers first-lesson select activities', () {
    final privacy = CourseActivity(
      id: 'act-01-01-01-scaffolded-private',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'a11y',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the cards only you can see.',
    );
    final scene = resolveLessonTableScene(privacy);
    expect(scene, isNotNull);
    expect(scene!.heroCodes, ['Ah', 'Kd']);
    expect(scene.boardCodes, ['Qs', 'Jh', '2c']);
    expect(scene.highlight, LessonTableHighlight.none);
    expect(scene.showDealerChip, isTrue);
    expect(scene.caption, 'You');

    final suits = CourseActivity(
      id: 'act-01-01-02-guided-suits',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Pick suits',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap every suit in a standard deck.',
      choices: const [
        CourseChoice(
          id: 'suits-full',
          label: 'Hearts, diamonds, clubs, spades',
        ),
      ],
    );
    expect(resolveLessonTableScene(suits), isNull);
    expect(
      resolveSelectIdentifyPresentation(suits),
      SelectIdentifyPresentation.suitTapPicker,
    );

    final checkpoint = CourseActivity(
      id: 'act-01-01-02-checkpoint-pair',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Tap the pocket nines among the hole-card options.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the pocket pair.',
      choices: const [
        CourseChoice(id: 'pocket-pair', label: '9h 9d'),
        CourseChoice(id: 'suited-nine', label: 'Ah Kh'),
        CourseChoice(id: 'two-high', label: 'Ah Kd'),
      ],
    );
    // Choices are the visual — no invented felt (would spoil the puzzle).
    expect(resolveLessonTableScene(checkpoint), isNull);
    expect(
      resolveSelectIdentifyPresentation(checkpoint),
      SelectIdentifyPresentation.holeCards,
    );

    final suited = CourseActivity(
      id: 'act-01-01-02-unguided-suited',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the hole-card pair that shares a suit.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the suited hole cards.',
      choices: const [
        CourseChoice(id: 'suited-ah-kh', label: 'Ah Kh'),
        CourseChoice(id: 'offsuit-ah-kd', label: 'Ah Kd'),
        CourseChoice(id: 'pair-77', label: '7c 7d'),
      ],
    );
    expect(resolveLessonTableScene(suited), isNull);
  });

  test('table region mapping covers Your two cards activities', () {
    const holeChoices = [
      CourseChoice(id: 'choice-hero-holes', label: 'Ah Kd in front of you'),
      CourseChoice(id: 'choice-board', label: 'The flop cards in the middle'),
      CourseChoice(
        id: 'choice-villain',
        label: 'Face-down cards at another seat',
      ),
    ];
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-01-01-guided-find-holes',
        region: LessonTableRegion.hero,
        choices: holeChoices,
      ),
      'choice-hero-holes',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-01-01-guided-find-holes',
        region: LessonTableRegion.board,
        choices: holeChoices,
      ),
      'choice-board',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-01-01-scaffolded-private',
        region: LessonTableRegion.dealer,
        choices: const [
          CourseChoice(id: 'choice-only-you', label: 'Only you'),
          CourseChoice(id: 'choice-whole-table', label: 'Everyone'),
          CourseChoice(id: 'choice-dealer-only', label: 'Dealer'),
        ],
      ),
      'choice-dealer-only',
    );
  });

  test('table region mapping covers Button and blinds activities', () {
    const buttonChoices = [
      CourseChoice(id: 'btn-seat', label: 'The seat with the D chip'),
      CourseChoice(id: 'bb-seat', label: 'The seat that posted 2 chips'),
      CourseChoice(id: 'empty-seat', label: 'Any empty seat'),
    ];
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-01-03-guided-button',
        region: LessonTableRegion.button,
        choices: buttonChoices,
      ),
      'btn-seat',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-01-03-guided-button',
        region: LessonTableRegion.bigBlind,
        choices: buttonChoices,
      ),
      'bb-seat',
    );

    const blindsChoices = [
      CourseChoice(id: 'bb-two', label: 'BB'),
      CourseChoice(id: 'sb-one', label: 'SB'),
      CourseChoice(id: 'btn-posts', label: 'Button'),
    ];
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-01-03-scaffolded-blinds',
        region: LessonTableRegion.bigBlind,
        choices: blindsChoices,
      ),
      'bb-two',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-01-03-scaffolded-blinds',
        region: LessonTableRegion.smallBlind,
        choices: blindsChoices,
      ),
      'sb-one',
    );

    const whenChoices = [
      CourseChoice(id: 'before-deal', label: 'Before'),
      CourseChoice(id: 'after-flop', label: 'After'),
      CourseChoice(id: 'only-showdown', label: 'Showdown'),
    ];
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-01-03-unguided-when',
        region: LessonTableRegion.beforeDeal,
        choices: whenChoices,
      ),
      'before-deal',
    );

    const layoutChoices = [
      CourseChoice(id: 'sb-seat0', label: 'Seat 0'),
      CourseChoice(id: 'sb-seat4', label: 'Seat 4'),
      CourseChoice(id: 'sb-seat1', label: 'Seat 1'),
    ];
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-01-03-checkpoint-layout',
        region: LessonTableRegion.smallBlind,
        seatIndex: 0,
        choices: layoutChoices,
      ),
      'sb-seat0',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-01-03-checkpoint-layout',
        region: LessonTableRegion.bigBlind,
        seatIndex: 1,
        choices: layoutChoices,
      ),
      'sb-seat1',
    );
    expect(blindsSmallBlindSeat(buttonSeat: 5, seatCount: 6), 0);
    expect(blindsBigBlindSeat(buttonSeat: 5, seatCount: 6), 1);
  });

  test('table region mapping covers Position labels activities', () {
    const btnChoices = [
      CourseChoice(id: 'pos-btn', label: 'BTN'),
      CourseChoice(id: 'pos-bb', label: 'BB'),
      CourseChoice(id: 'pos-ep', label: 'EP'),
    ];
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-02-01-01-guided-btn',
        region: LessonTableRegion.button,
        choices: btnChoices,
      ),
      'pos-btn',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-02-01-01-guided-btn',
        region: LessonTableRegion.earlyPosition,
        choices: btnChoices,
      ),
      'pos-ep',
    );

    const blindsChoices = [
      CourseChoice(id: 'sb-bb', label: 'SB or BB'),
      CourseChoice(id: 'btn-bb', label: 'BTN'),
      CourseChoice(id: 'ep-only', label: 'EP'),
    ];
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-02-01-01-scaffolded-blinds',
        region: LessonTableRegion.smallBlind,
        choices: blindsChoices,
      ),
      'sb-bb',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-02-01-01-scaffolded-blinds',
        region: LessonTableRegion.bigBlind,
        choices: blindsChoices,
      ),
      'sb-bb',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-02-01-01-scaffolded-blinds',
        region: LessonTableRegion.button,
        choices: blindsChoices,
      ),
      'btn-bb',
    );

    const cutoffChoices = [
      CourseChoice(id: 'label-co', label: 'Cutoff (CO)'),
      CourseChoice(id: 'label-hj', label: 'Hijack (HJ)'),
      CourseChoice(id: 'label-ep', label: 'Early position'),
    ];
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-02-01-01-unguided-co',
        region: LessonTableRegion.cutoff,
        choices: cutoffChoices,
      ),
      'label-co',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-02-01-01-unguided-co',
        region: LessonTableRegion.hijack,
        choices: cutoffChoices,
      ),
      'label-hj',
    );

    const edgeChoices = [
      CourseChoice(id: 'prefer-btn', label: 'On the button'),
      CourseChoice(id: 'prefer-ep', label: 'Under the gun'),
      CourseChoice(id: 'same-always', label: 'Seat never matters'),
    ];
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-02-01-01-checkpoint-edge',
        region: LessonTableRegion.button,
        choices: edgeChoices,
      ),
      'prefer-btn',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-02-01-01-checkpoint-edge',
        region: LessonTableRegion.seatNeverMatters,
        choices: edgeChoices,
      ),
      'same-always',
    );

    expect(positionEarlySeat(buttonSeat: 3, seatCount: 6), 0);
    expect(positionHijackSeat(buttonSeat: 3, seatCount: 6), 1);
    expect(positionCutoffSeat(buttonSeat: 3, seatCount: 6), 2);
    expect(
      positionRoleForSeat(seatIndex: 3, buttonSeat: 3, seatCount: 6),
      LessonTableRegion.button,
    );
    expect(
      positionRoleForSeat(seatIndex: 2, buttonSeat: 3, seatCount: 6),
      LessonTableRegion.cutoff,
    );
  });

  test('street and pot mapping helpers stay covered', () {
    const streetEndChoices = [
      CourseChoice(id: 'matched', label: 'Bets matched'),
      CourseChoice(id: 'three-cards', label: 'Flop appears'),
      CourseChoice(id: 'someone-folds', label: 'Someone folds'),
    ];
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-04-01-unguided-end',
        region: LessonTableRegion.streetActionMatched,
        choices: streetEndChoices,
      ),
      'matched',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-04-01-checkpoint-postflop',
        region: LessonTableRegion.smallBlind,
        choices: const [
          CourseChoice(id: 'sb-first', label: 'SB'),
          CourseChoice(id: 'btn-first', label: 'BTN'),
          CourseChoice(id: 'bb-first-always', label: 'BB'),
        ],
      ),
      'sb-first',
    );
    expect(
      resolveLessonTableScene(
        CourseActivity(
          id: 'act-01-04-01-unguided-end',
          order: 4,
          stage: ActivityStage.unguided,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'end',
          acceptedGrades: const [SoftGrade.recommended],
          choices: streetEndChoices,
        ),
      )?.layout,
      LessonTableLayout.streetEndPhases,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-01-04-01-explain-streets',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Four streets',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.streetsTimeline,
    );
    expect(
      isStreetSequenceActivity(
        CourseActivity(
          id: 'act-01-04-01-guided-streets',
          order: 2,
          stage: ActivityStage.guided,
          renderer: ActivityRenderer.orderSequence,
          estimatedSeconds: 40,
          accessibilityText: 'streets',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ),
      isTrue,
    );
    expect(
      isSeatOrderSequenceActivity(
        CourseActivity(
          id: 'act-01-04-01-scaffolded-order',
          order: 3,
          stage: ActivityStage.scaffolded,
          renderer: ActivityRenderer.orderSequence,
          estimatedSeconds: 40,
          accessibilityText: 'seats',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ),
      isTrue,
    );
    expect(
      resolveLessonTableScene(
        CourseActivity(
          id: 'act-01-04-01-checkpoint-postflop',
          order: 5,
          stage: ActivityStage.checkpoint,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'postflop',
          acceptedGrades: const [SoftGrade.recommended],
          choices: const [
            CourseChoice(id: 'sb-first', label: 'SB'),
            CourseChoice(id: 'btn-first', label: 'BTN'),
            CourseChoice(id: 'bb-first-always', label: 'BB'),
          ],
        ),
      )?.caption,
      'Postflop · tap who acts first',
    );

    const foldWinChoices = [
      CourseChoice(id: 'no-show', label: 'Take pot'),
      CourseChoice(id: 'must-show', label: 'Must show'),
      CourseChoice(id: 'dealer-shows', label: 'Dealer shows'),
    ];
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-05-01-guided-fold-win',
        region: LessonTableRegion.potTakeQuiet,
        choices: foldWinChoices,
      ),
      'no-show',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-05-01-scaffolded-showdown',
        region: LessonTableRegion.potShowdown,
        choices: const [
          CourseChoice(id: 'showdown', label: 'Showdown'),
          CourseChoice(id: 'last-bet-wins', label: 'Last bettor'),
          CourseChoice(id: 'chop-default', label: 'Always chop'),
        ],
      ),
      'showdown',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-05-01-checkpoint-side',
        region: LessonTableRegion.potSideForms,
        choices: const [
          CourseChoice(id: 'side-exists', label: 'Side pot'),
          CourseChoice(id: 'you-win-all', label: 'Win all'),
          CourseChoice(id: 'hand-void', label: 'Hand dead'),
        ],
      ),
      'side-exists',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: 'act-01-05-01-unguided-pot',
        region: LessonTableRegion.potChipsNine,
        choices: const [
          CourseChoice(id: 'pot-9', label: '9 chips'),
          CourseChoice(id: 'pot-7', label: '7 chips'),
          CourseChoice(id: 'pot-12', label: '12 chips'),
        ],
      ),
      'pot-9',
    );
    expect(
      resolveLessonTableScene(
        CourseActivity(
          id: 'act-01-05-01-unguided-pot',
          order: 4,
          stage: ActivityStage.unguided,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'pot size',
          acceptedGrades: const [SoftGrade.recommended],
          choices: const [
            CourseChoice(id: 'pot-9', label: '9 chips'),
            CourseChoice(id: 'pot-7', label: '7 chips'),
            CourseChoice(id: 'pot-12', label: '12 chips'),
          ],
        ),
      )?.layout,
      LessonTableLayout.potOpenSizeOutcomes,
    );
    expect(
      resolveLessonTableScene(
        CourseActivity(
          id: 'act-01-05-01-guided-fold-win',
          order: 2,
          stage: ActivityStage.guided,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'fold win',
          acceptedGrades: const [SoftGrade.recommended],
          choices: foldWinChoices,
        ),
      )?.layout,
      LessonTableLayout.potFoldWinOutcomes,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-01-05-01-explain-win',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Folds win pots',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.winningPaths,
    );
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-01-06-01-explain-run',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'One short hand. Blinds post, you act, we reach an ending.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.toyHandRun,
    );
    expect(
      resolveToyHandStepSpot(
        activityId: 'act-01-06-01-guided-steps',
        stepId: 'step-01-06-pre',
      )?.openPot,
      isTrue,
    );
    expect(
      resolveToyHandStepSpot(
        activityId: 'act-01-06-01-scaffolded-multi',
        stepId: 'step-01-06-flop-cbet',
      )?.boardCodes,
      ['As', '7c', '2d'],
    );
    expect(
      resolveLessonActionSpot(
        CourseActivity(
          id: 'act-01-06-01-unguided-lab',
          order: 4,
          stage: ActivityStage.unguided,
          renderer: ActivityRenderer.fullTableHandLab,
          estimatedSeconds: 90,
          accessibilityText: 'bb',
          acceptedGrades: const [SoftGrade.recommended],
          choices: const [
            CourseChoice(id: 'fold-bb', label: 'Fold', action: 'FOLD'),
          ],
        ),
      )?.facingBet,
      isTrue,
    );
    expect(
      isLessonActionTableActivity(
        CourseActivity(
          id: 'act-01-06-01-guided-steps',
          order: 2,
          stage: ActivityStage.guided,
          renderer: ActivityRenderer.authoredMultiStepHand,
          estimatedSeconds: 70,
          accessibilityText: 'guided',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ),
      isTrue,
    );
    expect(
      isHandExampleSequenceActivity(
        CourseActivity(
          id: 'act-01-06-02-jump-ranks',
          order: 1,
          stage: ActivityStage.jumpTest,
          renderer: ActivityRenderer.compareRank,
          estimatedSeconds: 40,
          accessibilityText: 'ranks',
          acceptedGrades: const [SoftGrade.recommended],
          sequenceItems: const [
            CourseChoice(id: 'j-flush', label: 'Flush'),
            CourseChoice(id: 'j-straight', label: 'Straight'),
            CourseChoice(id: 'j-two', label: 'Two pair'),
          ],
        ),
      ),
      isTrue,
    );
    expect(
      isSeatOrderSequenceActivity(
        CourseActivity(
          id: 'act-01-06-02-jump-order',
          order: 2,
          stage: ActivityStage.jumpTest,
          renderer: ActivityRenderer.orderSequence,
          estimatedSeconds: 40,
          accessibilityText: 'order',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ),
      isTrue,
    );
    expect(
      resolveLessonActionSpot(
        CourseActivity(
          id: 'act-01-06-02-jump-legal',
          order: 3,
          stage: ActivityStage.jumpTest,
          renderer: ActivityRenderer.pokerActionSizing,
          estimatedSeconds: 40,
          accessibilityText: 'legal',
          acceptedGrades: const [SoftGrade.recommended],
          choices: const [
            CourseChoice(id: 'j-check', label: 'Check', action: 'CHECK'),
          ],
        ),
      )?.identifyUnavailable,
      isTrue,
    );
    expect(
      resolveToyHandStepSpot(
        activityId: 'act-01-06-02-jump-hand',
        stepId: 'j-hand-open',
      )?.heroCodes,
      ['Ah', 'Th'],
    );
    expect(
      isLessonActionTableActivity(
        CourseActivity(
          id: 'act-01-06-02-jump-hand',
          order: 4,
          stage: ActivityStage.jumpTest,
          renderer: ActivityRenderer.authoredMultiStepHand,
          estimatedSeconds: 70,
          accessibilityText: 'hand',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ),
      isTrue,
    );
    expect(
      resolveSelectIdentifyPresentation(
        CourseActivity(
          id: 'act-01-05-01-checkpoint-side',
          order: 5,
          stage: ActivityStage.checkpoint,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'side',
          acceptedGrades: const [SoftGrade.recommended],
          choices: const [CourseChoice(id: 'side-exists', label: 'Side pot')],
        ),
      ),
      SelectIdentifyPresentation.tableRegionTap,
    );

    final guided = CourseActivity(
      id: 'act-01-01-03-guided-button',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap button',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the dealer button on the table.',
      choices: const [
        CourseChoice(id: 'btn-seat', label: 'The seat with the D chip'),
        CourseChoice(id: 'bb-seat', label: 'The seat that posted 2 chips'),
        CourseChoice(id: 'empty-seat', label: 'Any empty seat'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(guided),
      SelectIdentifyPresentation.tableRegionTap,
    );
    final scene = resolveLessonTableScene(guided);
    expect(scene, isNotNull);
    expect(scene!.layout, LessonTableLayout.blindsSeats);

    final positionGuided = CourseActivity(
      id: 'act-02-01-01-guided-btn',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap BTN',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap who acts last postflop.',
      choices: const [
        CourseChoice(id: 'pos-btn', label: 'BTN'),
        CourseChoice(id: 'pos-bb', label: 'BB'),
        CourseChoice(id: 'pos-ep', label: 'EP'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(positionGuided),
      SelectIdentifyPresentation.tableRegionTap,
    );
    final positionScene = resolveLessonTableScene(positionGuided);
    expect(positionScene?.layout, LessonTableLayout.positionLabels);
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-02-01-01-explain-pos',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Later seats',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.positionLabels,
    );
  });

  test('suit tap mapping covers full / missing / extra', () {
    const choices = [
      CourseChoice(id: 'suits-full', label: 'Hearts, diamonds, clubs, spades'),
      CourseChoice(id: 'suits-missing', label: 'Hearts, diamonds, clubs'),
      CourseChoice(
        id: 'suits-extra',
        label: 'Hearts, diamonds, clubs, spades, stars',
      ),
    ];
    expect(
      mapSuitTapSelectionToChoiceId(
        selected: {
          LessonSuitToken.hearts,
          LessonSuitToken.diamonds,
          LessonSuitToken.clubs,
          LessonSuitToken.spades,
        },
        choices: choices,
      ),
      'suits-full',
    );
    expect(
      mapSuitTapSelectionToChoiceId(
        selected: {
          LessonSuitToken.hearts,
          LessonSuitToken.diamonds,
          LessonSuitToken.clubs,
        },
        choices: choices,
      ),
      'suits-missing',
    );
    expect(
      mapSuitTapSelectionToChoiceId(
        selected: {
          LessonSuitToken.hearts,
          LessonSuitToken.diamonds,
          LessonSuitToken.clubs,
          LessonSuitToken.spades,
          LessonSuitToken.stars,
        },
        choices: choices,
      ),
      'suits-extra',
    );
    expect(
      mapSuitTapSelectionToChoiceId(
        selected: {LessonSuitToken.hearts},
        choices: choices,
      ),
      isNull,
    );
  });

  testWidgets('suit tap picker auto-submits when four suits selected', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-02-guided-suits',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Pick suits',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap every suit in a standard deck.',
      choices: const [
        CourseChoice(
          id: 'suits-full',
          label: 'Hearts, diamonds, clubs, spades',
        ),
        CourseChoice(id: 'suits-missing', label: 'Hearts, diamonds, clubs'),
        CourseChoice(
          id: 'suits-extra',
          label: 'Hearts, diamonds, clubs, spades, stars',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.byType(SuitTapPicker), findsOneWidget);
    expect(find.text('Hearts, diamonds, clubs, spades'), findsNothing);

    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    await tester.tap(find.text('Hearts'));
    await tester.pump();
    await tester.tap(find.text('Diamonds'));
    await tester.pump();
    await tester.tap(find.text('Clubs'));
    await tester.pump();
    expect(controller.draft.choiceId, 'suits-missing');
    expect(autoSubmits, 0);

    await tester.tap(find.text('Spades'));
    await tester.pump();
    expect(controller.draft.choiceId, 'suits-full');
    expect(autoSubmits, 1);
    controller.dispose();
  });

  testWidgets('suit tap picker cold-starts empty after activity rebind', (
    tester,
  ) async {
    final guided = CourseActivity(
      id: 'act-01-01-02-guided-suits',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Pick suits',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap every suit in a standard deck.',
      choices: const [
        CourseChoice(
          id: 'suits-full',
          label: 'Hearts, diamonds, clubs, spades',
        ),
        CourseChoice(id: 'suits-missing', label: 'Hearts, diamonds, clubs'),
        CourseChoice(
          id: 'suits-extra',
          label: 'Hearts, diamonds, clubs, spades, stars',
        ),
      ],
    );
    final controller = LessonActivityController(activity: guided);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: guided,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.tap(find.text('Hearts'));
    await tester.pump();
    expect(
      find.text('Keep tapping — include every real suit.'),
      findsOneWidget,
    );

    // Simulate lesson resume onto a fresh controller bind of the same step.
    controller.bindActivity(guided);
    await tester.pump();
    expect(controller.draft.choiceId, isNull);
    expect(find.text('Tap suits to build your answer.'), findsOneWidget);
    expect(find.byType(SuitTapPicker), findsOneWidget);

    await tester.tap(find.text('Hearts'));
    await tester.pump();
    await tester.tap(find.text('Diamonds'));
    await tester.pump();
    await tester.tap(find.text('Clubs'));
    await tester.pump();
    await tester.tap(find.text('Spades'));
    await tester.pump();
    expect(controller.draft.choiceId, 'suits-full');
    expect(find.text('Checking…'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('hole-card choices render MiniCard faces', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-01-02-unguided-suited',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'suited',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Which hole cards are suited?',
      choices: const [
        CourseChoice(id: 'suited-ah-kh', label: 'Ah Kh'),
        CourseChoice(id: 'offsuit-ah-kd', label: 'Ah Kd'),
        CourseChoice(id: 'pair-77', label: '7c 7d'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: false,
        ),
      ),
    );
    expect(find.byType(HoleCardChoiceButton), findsNWidgets(3));
    expect(find.byType(MiniCard), findsAtLeastNWidgets(6));
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;
    await tester.tap(find.byType(HoleCardChoiceButton).first);
    await tester.pump();
    expect(controller.draft.choiceId, 'suited-ah-kh');
    expect(autoSubmits, 1);
    controller.dispose();
  });

  test('appendOrderedId auto-submits only on the last sequence tap', () {
    final activity = _activity(
      renderer: ActivityRenderer.orderSequence,
      sequenceItems: const [
        CourseChoice(id: 'a', label: 'UTG'),
        CourseChoice(id: 'b', label: 'BTN'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;

    appendOrderedId(
      controller: controller,
      activity: activity,
      ordered: const [],
      id: 'a',
    );
    expect(controller.draft.orderedIds, ['a']);
    expect(autoSubmits, 0);

    appendOrderedId(
      controller: controller,
      activity: activity,
      ordered: controller.draft.orderedIds,
      id: 'b',
    );
    expect(controller.draft.orderedIds, ['a', 'b']);
    expect(autoSubmits, 1);
    controller.dispose();
  });

  test(
    'select/identify and player-read shells auto-submit; numeric does not',
    () {
      expect(
        isAutoSubmitSelectIdentify(
          _activity(renderer: ActivityRenderer.selectIdentify),
        ),
        isTrue,
      );
      expect(
        isAutoSubmitSelectIdentify(
          _activity(renderer: ActivityRenderer.playerReadClassify),
        ),
        isTrue,
      );
      expect(
        isAutoSubmitSelectIdentify(
          _activity(renderer: ActivityRenderer.numericPotPrice),
        ),
        isFalse,
      );
      expect(
        isAutoSubmitSelectIdentify(
          _activity(renderer: ActivityRenderer.orderSequence),
        ),
        isFalse,
      );
    },
  );

  testWidgets('order sequence supports undo', (tester) async {
    final activity = _activity(
      renderer: ActivityRenderer.orderSequence,
      sequenceItems: const [
        CourseChoice(id: 'a', label: 'UTG'),
        CourseChoice(id: 'b', label: 'BTN'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.tap(find.text('UTG'));
    await tester.pump();
    await tester.tap(find.text('Undo last'));
    await tester.pump();
    expect(controller.draft.orderedIds, isEmpty);
    controller.dispose();
  });

  testWidgets('order sequence auto-submits when the last item is tapped', (
    tester,
  ) async {
    final activity = _activity(
      renderer: ActivityRenderer.compareRank,
      sequenceItems: const [
        CourseChoice(id: 'a', label: 'UTG'),
        CourseChoice(id: 'b', label: 'BTN'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;
    await tester.pumpWidget(
      _wrap(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    await tester.tap(find.text('UTG'));
    await tester.pump();
    expect(autoSubmits, 0);
    await tester.tap(find.text('BTN'));
    await tester.pump();
    expect(controller.draft.orderedIds, ['a', 'b']);
    expect(autoSubmits, 1);
    controller.dispose();
  });

  testWidgets('rank order shows prompt once in Rex, not duplicated below', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-02-scaffolded-ranks',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 40,
      accessibilityText: 'Order ranks',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Order these ranks from lowest to highest.',
      sequenceItems: const [
        CourseChoice(id: 'r2', label: '2'),
        CourseChoice(id: 'rT', label: 'T'),
        CourseChoice(id: 'rA', label: 'A'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(
      find.text('Order these ranks from lowest to highest.'),
      findsOneWidget,
    );
    expect(find.text('Tap ranks from lowest to highest.'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is RexCoachLine &&
            w.text == 'Order these ranks from lowest to highest.',
      ),
      findsOneWidget,
    );
    controller.dispose();
  });

  testWidgets('rank order palette is shuffled, not authored ascending', (
    tester,
  ) async {
    const items = [
      CourseChoice(id: 'r2', label: '2'),
      CourseChoice(id: 'rT', label: 'T'),
      CourseChoice(id: 'rA', label: 'A'),
    ];
    final activity = CourseActivity(
      id: 'act-01-01-02-scaffolded-ranks',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 40,
      accessibilityText: 'Order ranks',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Order these ranks from lowest to highest.',
      sequenceItems: items,
    );
    final expectedPalette =
        shuffledSequencePalette(
          activityId: activity.id,
          items: items,
        ).map((item) => item.label.toUpperCase()).toList(growable: false);
    expect(expectedPalette, isNot(['2', 'T', 'A']));

    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );

    List<String> paletteByPosition() {
      final entries = <({String label, Offset pos})>[];
      for (final label in ['2', 'T', 'A']) {
        entries.add((
          label: label,
          pos: tester.getTopLeft(find.text(label)),
        ));
      }
      entries.sort((a, b) {
        final dy = a.pos.dy.compareTo(b.pos.dy);
        if (dy != 0) return dy;
        return a.pos.dx.compareTo(b.pos.dx);
      });
      return entries.map((e) => e.label).toList(growable: false);
    }

    final first = paletteByPosition();
    expect(first, expectedPalette);
    expect(first, isNot(['2', 'T', 'A']));

    await tester.pumpWidget(
      _wrap(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(paletteByPosition(), first);

    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('T'));
    await tester.pump();
    await tester.tap(find.text('A'));
    await tester.pump();
    expect(controller.draft.orderedIds, ['r2', 'rT', 'rA']);
    controller.dispose();
  });

  testWidgets('suit identify shows prompt once in Rex, not duplicated below', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-02-guided-suits',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Pick suits',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap every suit in a standard deck.',
      choices: const [
        CourseChoice(
          id: 'suits-full',
          label: 'Hearts, diamonds, clubs, spades',
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('Tap every suit in a standard deck.'), findsOneWidget);
    expect(
      find.text('Tap every suit that belongs in a standard deck.'),
      findsNothing,
    );
    controller.dispose();
  });

  testWidgets('streets guided order taps street tiles with board cards', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-04-01-guided-streets',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 40,
      accessibilityText: 'streets',
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
    await tester.pumpWidget(
      _wrap(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('PREFLOP'), findsOneWidget);
    expect(find.text('FLOP'), findsOneWidget);
    expect(find.text('TURN'), findsOneWidget);
    expect(find.text('RIVER'), findsOneWidget);
    await tester.tap(find.text('PREFLOP'));
    await tester.pump();
    await tester.tap(find.text('FLOP'));
    await tester.pump();
    expect(controller.draft.orderedIds, ['st-pre', 'st-flop']);
    controller.dispose();
  });

  testWidgets('streets unguided end taps bets matched on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-04-01-unguided-end',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'end',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Flop betting is live. Tap when this street ends.',
      choices: const [
        CourseChoice(id: 'matched', label: 'Bets matched'),
        CourseChoice(id: 'three-cards', label: 'Flop appears'),
        CourseChoice(id: 'someone-folds', label: 'Someone folds'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: false,
        ),
      ),
    );
    expect(find.text('Bets matched'), findsWidgets);
    await tester.tap(find.text('Bets matched').first);
    await tester.pump();
    expect(controller.draft.choiceId, 'matched');
    controller.dispose();
  });

  testWidgets('toy hand guided step opens on action dock', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-06-01-guided-steps',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'guided',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-01-06-pre',
          street: 'preflop',
          prompt: 'Button with A9s. Folds to you.',
          choices: [
            CourseChoice(id: 'open-6', label: 'Raise to 6', action: 'RAISE'),
            CourseChoice(id: 'limp-a9', label: 'Limp', action: 'CALL'),
            CourseChoice(id: 'fold-a9', label: 'Fold', action: 'FOLD'),
          ],
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.textContaining('Preflop · Button'), findsOneWidget);
    expect(find.text('RAISE TO 6'), findsOneWidget);
    await tester.tap(find.text('RAISE TO 6'));
    await tester.pump();
    expect(controller.draft.choiceId, 'open-6');
    controller.dispose();
  });

  testWidgets('jump check legal docks illegal Check on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-06-02-jump-legal',
      order: 3,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 40,
      accessibilityText: 'legal',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'A bet faces you. Tap the action you cannot take.',
      choices: const [
        CourseChoice(id: 'j-check', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'j-call', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'j-raise', label: 'Raise', action: 'RAISE'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        PokerActionSizingActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.textContaining('Villain bets 8'), findsOneWidget);
    expect(find.text('CHECK (off)'), findsOneWidget);
    await tester.tap(find.text('CHECK (off)'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j-check');
    controller.dispose();
  });

  testWidgets('jump check hand opens steal on action dock', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-06-02-jump-hand',
      order: 4,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'hand',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'j-hand-open',
          street: 'preflop',
          prompt: 'Button with ATs. Folds to you.',
          choices: [
            CourseChoice(id: 'j-open', label: 'Raise to 6', action: 'RAISE'),
            CourseChoice(id: 'j-fold', label: 'Fold', action: 'FOLD'),
          ],
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.textContaining('Preflop · Button'), findsOneWidget);
    expect(find.text('RAISE TO 6'), findsOneWidget);
    await tester.tap(find.text('RAISE TO 6'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j-open');
    controller.dispose();
  });

  testWidgets('how pots fold-win taps take pot on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-05-01-guided-fold-win',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'fold',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You bet. Everyone folds. Tap how you take the pot.',
      choices: const [
        CourseChoice(id: 'no-show', label: 'Take pot'),
        CourseChoice(id: 'must-show', label: 'Must show'),
        CourseChoice(id: 'dealer-shows', label: 'Dealer shows'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('Take pot'), findsWidgets);
    await tester.tap(find.text('Take pot').first);
    await tester.pump();
    expect(controller.draft.choiceId, 'no-show');
    controller.dispose();
  });

  testWidgets('numeric entry updates draft', (tester) async {
    final activity = _activity(
      renderer: ActivityRenderer.numericPotPrice,
      numericQuestion: 'Pot size?',
      numericUnit: 'chips',
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        NumericPotPriceActivity(
          activity: activity,
          controller: controller,
          showGuidance: false,
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '9');
    await tester.pump();
    expect(controller.draft.numericValue, 9);
    controller.dispose();
  });

  testWidgets('numeric keyboard Done auto-submits parsed value', (tester) async {
    final activity = _activity(
      renderer: ActivityRenderer.numericPotPrice,
      numericQuestion: 'Pot size?',
      numericUnit: 'chips',
    );
    final controller = LessonActivityController(activity: activity);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;
    await tester.pumpWidget(
      _wrap(
        NumericPotPriceActivity(
          activity: activity,
          controller: controller,
          showGuidance: false,
        ),
      ),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.textInputAction, TextInputAction.done);

    await tester.enterText(find.byType(TextField), '12.5');
    await tester.pump();
    expect(controller.draft.numericValue, 12.5);
    expect(autoSubmits, 0);

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(controller.draft.numericValue, 12.5);
    expect(autoSubmits, 1);
    controller.dispose();
  });

  testWidgets('poker action sizing exposes action semantics', (tester) async {
    final activity = _activity(
      renderer: ActivityRenderer.pokerActionSizing,
      choices: const [
        CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'raise', label: 'Raise', action: 'RAISE'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        PokerActionSizingActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('Fold'), findsOneWidget);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;
    await tester.tap(find.text('Raise'));
    await tester.pump();
    expect(controller.draft.choiceId, 'raise');
    expect(autoSubmits, 1);
    controller.dispose();
  });

  testWidgets('full table hand lab choice tap auto-submits', (tester) async {
    final activity = _activity(
      id: 'act-01-06-01-unguided-lab',
      renderer: ActivityRenderer.fullTableHandLab,
      choices: const [
        CourseChoice(id: 'fold-bb', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'call-bb', label: 'Call 2', action: 'CALL'),
        CourseChoice(id: 'jam-bb', label: 'All-in', action: 'ALL_IN'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;
    await tester.pumpWidget(
      _wrap(
        FullTableHandLabActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.byType(LessonActionDock), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold-bb');
    expect(autoSubmits, 1);
    controller.dispose();
  });

  test('fold check call spots resolve mini-table dock mode', () {
    final fold = CourseActivity(
      id: 'act-01-03-01-guided-fold',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Fold',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap your action.',
      choices: const [
        CourseChoice(id: 'fold-72', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'call-72', label: 'Call 6', action: 'CALL'),
        CourseChoice(id: 'raise-72', label: 'Raise to 18', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(fold), isTrue);
    final spot = resolveLessonActionSpot(fold)!;
    expect(spot.facingBet, isTrue);
    expect(spot.heroCodes, ['7h', '2d']);

    final checkpoint = CourseActivity(
      id: 'act-01-03-01-checkpoint-legal',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Check',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the action you cannot take.',
      choices: const [
        CourseChoice(id: 'check-illegal', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'call-legal', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-legal', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(resolveLessonActionSpot(checkpoint)!.identifyUnavailable, isTrue);
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-01-03-01-explain-passive',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Fold check call',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Fold ends your hand.',
        ),
      ).kind,
      CoachDialogueVisualKind.passiveActions,
    );
  });

  test('bet raise all-in spots resolve mini-table dock mode', () {
    final bet = CourseActivity(
      id: 'act-01-03-02-guided-bet',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Bet',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap a value size.',
      choices: const [
        CourseChoice(id: 'bet-half', label: 'Bet 5', action: 'BET'),
        CourseChoice(id: 'check-value', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'raise-no-bet', label: 'Raise', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(bet), isTrue);
    final spot = resolveLessonActionSpot(bet)!;
    expect(spot.openPot, isTrue);
    expect(spot.facingBet, isFalse);

    final allIn = CourseActivity(
      id: 'act-01-03-02-unguided-allin',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap All-in',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap what you can put in.',
      choices: const [
        CourseChoice(id: 'shove-12', label: 'All-in 12', action: 'ALL_IN'),
        CourseChoice(id: 'call-20', label: 'Call 20', action: 'CALL'),
        CourseChoice(id: 'fold-only', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(resolveLessonActionSpot(allIn)!.stackLabel, 'Stack 12');
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-01-03-02-explain-aggro',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Bet opens',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Bet opens the betting.',
        ),
      ).kind,
      CoachDialogueVisualKind.aggressiveActions,
    );
  });

  testWidgets('fold check call dock taps Fold on mini-table', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-03-01-guided-fold',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Fold',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap your action.',
      choices: const [
        CourseChoice(id: 'fold-72', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'call-72', label: 'Call 6', action: 'CALL'),
        CourseChoice(id: 'raise-72', label: 'Raise to 18', action: 'RAISE'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        PokerActionSizingActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.byType(LessonActionTable), findsOneWidget);
    expect(find.byType(LessonActionDock), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold-72');
    expect(find.text('Checking…'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('free-check dock shows CHECK with Check free semantics', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-03-01-scaffolded-check',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Check',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the free action.',
      choices: const [
        CourseChoice(
          id: 'check-free',
          label: 'Check free',
          accessibilityText: 'Check free',
          action: 'CHECK',
        ),
        CourseChoice(id: 'call-free', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-free', label: 'Fold', action: 'FOLD'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        PokerActionSizingActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('CHECK'), findsOneWidget);
    expect(find.text('CHECK FREE'), findsNothing);
    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Check free'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Check free'));
    await tester.pump();
    expect(controller.draft.choiceId, 'check-free');
    handle.dispose();
    controller.dispose();
  });

  testWidgets('checkpoint marks Check as off and selectable', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-03-01-checkpoint-legal',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Check',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the action you cannot take.',
      choices: const [
        CourseChoice(id: 'check-illegal', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'call-legal', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-legal', label: 'Fold', action: 'FOLD'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        PokerActionSizingActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('CHECK (off)'), findsOneWidget);
    await tester.tap(find.text('CHECK (off)'));
    await tester.pump();
    expect(controller.draft.choiceId, 'check-illegal');
    controller.dispose();
  });

  testWidgets('bet raise all-in dock taps Bet and All-in on mini-table', (
    tester,
  ) async {
    final bet = CourseActivity(
      id: 'act-01-03-02-guided-bet',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Bet',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap a value size.',
      choices: const [
        CourseChoice(id: 'bet-half', label: 'Bet 5', action: 'BET'),
        CourseChoice(id: 'check-value', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'raise-no-bet', label: 'Raise', action: 'RAISE'),
      ],
    );
    final betController = LessonActivityController(activity: bet);
    await tester.pumpWidget(
      _wrap(
        PokerActionSizingActivity(
          activity: bet,
          controller: betController,
          showGuidance: true,
        ),
      ),
    );
    expect(find.byType(LessonActionTable), findsOneWidget);
    expect(find.text('Pot is open to a bet'), findsOneWidget);
    var autoSubmits = 0;
    betController.onAutoSubmit = () => autoSubmits += 1;
    await tester.tap(find.text('BET 5'));
    await tester.pump();
    expect(betController.draft.choiceId, 'bet-half');
    expect(autoSubmits, 1);
    expect(find.text('Checking…'), findsOneWidget);
    betController.dispose();

    final allIn = CourseActivity(
      id: 'act-01-03-02-unguided-allin',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap All-in',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap what you can put in.',
      choices: const [
        CourseChoice(id: 'shove-12', label: 'All-in 12', action: 'ALL_IN'),
        CourseChoice(id: 'call-20', label: 'Call 20', action: 'CALL'),
        CourseChoice(id: 'fold-only', label: 'Fold', action: 'FOLD'),
      ],
    );
    final allInController = LessonActivityController(activity: allIn);
    await tester.pumpWidget(
      _wrap(
        PokerActionSizingActivity(
          activity: allIn,
          controller: allInController,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('Stack 12'), findsOneWidget);
    expect(find.text('ALL-IN 12'), findsOneWidget);
    await tester.tap(find.text('ALL-IN 12'));
    await tester.pump();
    expect(allInController.draft.choiceId, 'shove-12');
    allInController.dispose();
  });

  testWidgets('feedback sheet never shows life loss for questionable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LessonFeedbackSheet(
          result: _result(
            grade: SoftGrade.questionable,
            accepted: false,
            lifeLost: false,
          ),
          onContinue: () {},
          onRetry: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Life −1'), findsNothing);
    expect(find.text('Think again'), findsOneWidget);
  });

  testWidgets('feedback sheet shows life loss only when server marks it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LessonFeedbackSheet(
          result: _result(
            grade: SoftGrade.clearMistake,
            accepted: false,
            lifeLost: true,
          ),
          onContinue: () {},
          onRetry: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Life −1'), findsOneWidget);
  });

  testWidgets('reasonable grade stays positive without life loss chrome', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LessonFeedbackSheet(
          result: _result(
            grade: SoftGrade.reasonable,
            accepted: true,
            lifeLost: false,
          ),
          onContinue: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Playable'), findsOneWidget);
    expect(find.text('Life −1'), findsNothing);
  });

  testWidgets('preferred recovery renders as a gold callout chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        LessonFeedbackSheet(
          result: _result(
            grade: SoftGrade.questionable,
            accepted: false,
            lifeLost: false,
          ),
          betterChoiceLabel: 'Hole cards',
          showActions: false,
          onContinue: () {},
          onRetry: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Preferred: Hole cards'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Got it'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Try again'), findsNothing);
  });

  testWidgets('rejected feedback shakes horizontally; accepted does not', (
    tester,
  ) async {
    Offset? dxOfTitle(String title) {
      final text = find.text(title);
      if (text.evaluate().isEmpty) return null;
      final transforms = tester.widgetList<Transform>(
        find.ancestor(of: text, matching: find.byType(Transform)),
      );
      for (final t in transforms) {
        final m = t.transform;
        final dx = m.storage[12];
        if (dx.abs() > 0.01) return Offset(dx, m.storage[13]);
      }
      return Offset.zero;
    }

    await tester.pumpWidget(
      _wrap(
        LessonFeedbackSheet(
          result: _result(
            grade: SoftGrade.questionable,
            accepted: false,
            lifeLost: false,
          ),
          onContinue: () {},
          onRetry: () {},
        ),
      ),
    );
    await tester.pump(
      LessonFeedbackSheet.rejectShakeDuration * 0.25,
    );
    final rejectDx = dxOfTitle('Think again');
    expect(rejectDx, isNotNull);
    expect(rejectDx!.dx.abs(), greaterThan(0.5));

    await tester.pumpAndSettle();

    await tester.pumpWidget(
      _wrap(
        LessonFeedbackSheet(
          result: _result(
            grade: SoftGrade.recommended,
            accepted: true,
            lifeLost: false,
          ),
          onContinue: () {},
        ),
      ),
    );
    await tester.pump(
      LessonFeedbackSheet.rejectShakeDuration * 0.25,
    );
    final acceptDx = dxOfTitle('Nice!');
    expect(acceptDx, isNotNull);
    expect(acceptDx!.dx.abs(), lessThan(0.01));
    await tester.pumpAndSettle();
  });

  test('hand ranks presentations resolve to visual modes', () {
    final ladder = CourseActivity(
      id: 'act-01-02-01-guided-ladder',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.compareRank,
      estimatedSeconds: 40,
      accessibilityText: 'Tap high card, then pair, then flush',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap weakest to strongest.',
      sequenceItems: const [
        CourseChoice(id: 'hr-high', label: 'High card'),
        CourseChoice(id: 'hr-pair', label: 'One pair'),
        CourseChoice(id: 'hr-flush', label: 'Flush'),
      ],
    );
    expect(isHandExampleSequenceActivity(ladder), isTrue);
    expect(resolveHandExample(id: 'hr-high')?.codes.length, 5);

    final spot = CourseActivity(
      id: 'act-01-02-01-scaffolded-spot',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap flush',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap what you made.',
      choices: const [
        CourseChoice(id: 'cat-flush', label: 'Flush'),
        CourseChoice(id: 'cat-pair', label: 'One pair'),
        CourseChoice(id: 'cat-straight', label: 'Straight'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(spot),
      SelectIdentifyPresentation.handCategoryTap,
    );
    final scene = resolveLessonTableScene(spot);
    expect(scene?.heroCodes, ['Ac', '3d']);
    expect(scene?.boardCodes, ['Kc', '9c', '4c', '7c', '2s']);
    expect(resolveHandExample(id: 'cat-flush')?.codes, [
      'Ac',
      'Kc',
      '9c',
      '4c',
      '7c',
    ]);

    final showdown = CourseActivity(
      id: 'act-01-02-01-checkpoint-winner',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap who wins',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Showdown — tap who wins.',
      choices: const [
        CourseChoice(id: 'you-win', label: 'You win with the flush'),
        CourseChoice(id: 'they-win', label: 'They win with the straight'),
        CourseChoice(id: 'split', label: 'Chop the pot'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(showdown),
      SelectIdentifyPresentation.showdownTap,
    );

    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-01-02-01-explain-ladder',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Ladder',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Pair beats high card.',
        ),
      ).kind,
      CoachDialogueVisualKind.handLadder,
    );
  });

  testWidgets('hand ranks order taps hand tiles not text chips', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-02-01-guided-ladder',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.compareRank,
      estimatedSeconds: 40,
      accessibilityText: 'Tap weakest to strongest',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap weakest to strongest.',
      sequenceItems: const [
        CourseChoice(id: 'hr-high', label: 'High card'),
        CourseChoice(id: 'hr-pair', label: 'One pair'),
        CourseChoice(id: 'hr-flush', label: 'Flush'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('Tap lowest first'), findsOneWidget);
    expect(find.text('Tap low → high'), findsOneWidget);
    expect(find.byType(HandExampleTile), findsNWidgets(3));
    expect(find.byType(ActionChip), findsNothing);

    await tester.tap(find.text('High card'));
    await tester.pump();
    await tester.tap(find.text('One pair'));
    await tester.pump();
    await tester.tap(find.text('Flush'));
    await tester.pump();
    expect(controller.draft.orderedIds, ['hr-high', 'hr-pair', 'hr-flush']);
    expect(find.text('Checking…'), findsOneWidget);
    // Mid-submit: ignore re-taps / duplicate appends.
    appendOrderedId(
      controller: controller,
      activity: activity,
      ordered: controller.draft.orderedIds,
      id: 'hr-high',
    );
    expect(controller.draft.orderedIds, ['hr-high', 'hr-pair', 'hr-flush']);
    controller.dispose();
  });

  testWidgets('rank order tray shows Tap lowest first and Checking…', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-02-scaffolded-ranks',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 40,
      accessibilityText: 'Order ranks',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Order these ranks from lowest to highest.',
      sequenceItems: const [
        CourseChoice(id: 'r2', label: '2'),
        CourseChoice(id: 'r3', label: '3'),
        CourseChoice(id: 'r4', label: '4'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('Tap lowest first'), findsOneWidget);
    expect(find.text('Tap low → high'), findsOneWidget);
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('4'));
    await tester.pump();
    expect(controller.draft.orderedIds, ['r2', 'r3', 'r4']);
    expect(find.text('Checking…'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('hand category tap selects flush tile for scaffolded spot', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-02-01-scaffolded-spot',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap flush',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap what you made.',
      choices: const [
        CourseChoice(id: 'cat-flush', label: 'Flush'),
        CourseChoice(id: 'cat-pair', label: 'One pair'),
        CourseChoice(id: 'cat-straight', label: 'Straight'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.byType(HandExampleTile), findsNWidgets(3));
    expect(find.byType(LessonTableContext), findsOneWidget);
    expect(
      find.textContaining('Look at the board and your holes'),
      findsOneWidget,
    );
    expect(find.textContaining('Board Kc'), findsNothing);

    await tester.tap(find.text('Flush'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cat-flush');
    controller.dispose();
  });

  testWidgets('showdown tap selects your flush over straight', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-02-01-checkpoint-winner',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap who wins',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Showdown — tap who wins.',
      choices: const [
        CourseChoice(id: 'you-win', label: 'You win with the flush'),
        CourseChoice(id: 'they-win', label: 'They win with the straight'),
        CourseChoice(id: 'split', label: 'Chop the pot'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('Your flush'), findsOneWidget);
    expect(find.text('Their straight'), findsOneWidget);
    expect(find.text('Chop the pot'), findsOneWidget);

    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;
    await tester.tap(find.text('Your flush'));
    await tester.pump();
    expect(controller.draft.choiceId, 'you-win');
    expect(autoSubmits, 1);
    controller.dispose();
  });

  test('best five spots map five-card taps to choice ids', () {
    final guided = CourseActivity(
      id: 'act-01-02-02-guided-seven',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap five',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap your best five.',
      choices: const [
        CourseChoice(id: 'best-pair-k', label: 'Aces with king'),
        CourseChoice(id: 'weak-kickers', label: 'Aces with nine'),
        CourseChoice(id: 'ignore-ace', label: 'King high'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(guided),
      SelectIdentifyPresentation.bestFiveCardTap,
    );
    final spot = resolveBestFiveSpot(guided)!;
    expect(
      mapBestFiveSelectionToChoiceId(
        selected: {'Ah', 'As', 'Kd', '9h', '7c'},
        spot: spot,
        choices: guided.choices,
      ),
      'best-pair-k',
    );
    expect(
      mapBestFiveSelectionToChoiceId(
        selected: {'Kd', '9h', '7c', '3s', '2d'},
        spot: spot,
        choices: guided.choices,
      ),
      'ignore-ace',
    );
    expect(
      mapBestFiveSelectionToChoiceId(
        selected: {'Ah', 'As', 'Kd'},
        spot: spot,
        choices: guided.choices,
      ),
      isNull,
    );

    final checkpoint = CourseActivity(
      id: 'act-01-02-02-checkpoint-build',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap five',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap your best five.',
      choices: const [
        CourseChoice(id: 'fh-eights', label: 'Eights full'),
        CourseChoice(id: 'fh-deuces', label: 'Eights full deuces'),
        CourseChoice(id: 'two-pair-only', label: 'Two pair'),
      ],
    );
    final cpSpot = resolveBestFiveSpot(checkpoint)!;
    expect(
      mapBestFiveSelectionToChoiceId(
        selected: {'8h', '8d', '8c', 'Kd', 'Ks'},
        spot: cpSpot,
        choices: checkpoint.choices,
      ),
      'fh-eights',
    );

    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-01-02-02-explain-five',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Five',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Only five cards count.',
        ),
      ).kind,
      CoachDialogueVisualKind.bestFive,
    );
  });

  testWidgets('best five card picker selects aces with king kicker', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-02-02-guided-seven',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap five',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap your best five.',
      choices: const [
        CourseChoice(id: 'best-pair-k', label: 'Aces with king'),
        CourseChoice(id: 'weak-kickers', label: 'Aces with nine'),
        CourseChoice(id: 'ignore-ace', label: 'King high'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.byType(BestFiveCardPicker), findsOneWidget);
    expect(
      find.text('Only five cards count — tap the ones that play.'),
      findsOneWidget,
    );
    expect(find.textContaining('You hold Ah'), findsNothing);

    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;
    for (final code in ['Ah', 'As', 'Kd', '9h', '7c']) {
      await tester.tap(find.byKey(ValueKey<String>('best-five-$code')));
      await tester.pump();
    }
    expect(controller.draft.choiceId, 'best-pair-k');
    expect(autoSubmits, 1);
    controller.dispose();
  });

  testWidgets('kicker showdown taps you-win tile', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-02-02-scaffolded-kicker',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap who wins',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap who wins.',
      choices: const [
        CourseChoice(id: 'you-kicker', label: 'You win — queen kicker'),
        CourseChoice(id: 'they-kicker', label: 'They win'),
        CourseChoice(id: 'chop-kicker', label: 'Chop'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        SelectIdentifyActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.showdownTap,
    );
    expect(find.text('You — kings, Q kicker'), findsOneWidget);
    expect(
      find.text('Same pair — tap who wins on kickers.'),
      findsOneWidget,
    );
    expect(find.textContaining('Board Kh'), findsNothing);
    final scene = resolveLessonTableScene(activity);
    expect(scene?.villainCodes, ['As', 'Jd']);
    expect(find.text('Them'), findsOneWidget);
    await tester.tap(find.text('You — kings, Q kicker'));
    await tester.pump();
    expect(controller.draft.choiceId, 'you-kicker');
    controller.dispose();
  });
}
