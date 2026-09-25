/// Widget coverage for lesson activity shells and grade feedback.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
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
import 'package:live_poker_trainer/ui/course/widgets/preflop_flop_plan_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/turn_map_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/river_composition_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/pot_type_plans_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/hu_vs_multiway_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/stack_depth_plans_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/same_cards_types_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/type_board_line_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/leak_review_book_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/capstone_srp_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/capstone_3bet_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/capstone_multiway_deep_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/capstone_limped_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/capstone_4bet_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/live_warmup_prep_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/lag_model_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/wide_pressure_demo.dart';
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
    expect(find.text('Tap your cards'), findsOneWidget);
    expect(find.text('Tap your two cards on the felt.'), findsNothing);
    // Solo hero teach fills tall-phone void (~58% height).
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('hole-cards-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
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
    await tester.pump();
    expect(find.byType(SuitTapTile), findsNWidgets(4));
    expect(find.text('Thirteen ranks — ace high'), findsOneWidget);
    expect(find.byType(MiniCard), findsNothing);
    expect(find.text('Tap Hearts'), findsNothing);
    expect(find.text('0 of 4 suits'), findsOneWidget);
    // SoftPulse + Rex own the tip — no Tap Hearts footer mid-teach.
    expect(find.text('Tap each of the four suits.'), findsNothing);
    expect(
      find.text('Tap Continue when you have looked at your two cards.'),
      findsNothing,
    );
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('suits-ranks-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('Hearts'));
    await tester.pump();
    expect(find.text('Tap Diamonds'), findsNothing);
    await tester.tap(find.text('Diamonds'));
    await tester.pump();
    await tester.tap(find.text('Clubs'));
    await tester.pump();
    await tester.tap(find.text('Spades'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Four suits · thirteen ranks'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('suits-ranks-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('button explain SoftPulse cue sits on the felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-01-03-explain-button',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Button marks the dealer. Blinds sit left of it.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Button marks the dealer. Blinds sit left of it.',
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
    await tester.pump();
    // SoftPulse + Rex own the cue — no Tap the dealer button footer.
    expect(find.text('Tap the dealer button'), findsNothing);
    expect(find.text('Tap the dealer button on the table.'), findsNothing);
    // Ambient empties stay mark-only — no thrice-"Seat" unfinished polish.
    expect(find.text('Seat'), findsNothing);
    expect(find.text('Button'), findsOneWidget);
    expect(find.text('Small blind'), findsOneWidget);
    expect(find.text('Big blind'), findsOneWidget);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('blinds-seats-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    // SoftPulse teaches clockwise — button alone is not enough.
    await tester.tap(find.text('D'));
    await tester.pump();
    expect(feltAck, 0);
    await tester.tap(find.text('Small blind'));
    await tester.pump();
    expect(feltAck, 0);
    await tester.tap(find.text('Big blind'));
    await tester.pump();
    expect(feltAck, 1);
    // Densified shell must stay filled after acknowledge (Continue phase).
    expect(
      tester.getSize(find.byKey(const ValueKey('blinds-seats-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    // Role chips grow to fill densified felt — not the old 32px badges.
    final dealer = tester.getSize(find.text('D').first);
    expect(dealer.height, greaterThanOrEqualTo(20));
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
    // SoftPulse + Rex own the cue — no Tap BTN footer stack.
    expect(find.text('Tap BTN — the latest seat'), findsNothing);
    expect(
      find.text('Tap the button (BTN) — the latest seat.'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('position-labels-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

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
    // Densified shell must stay filled after acknowledge (Continue phase).
    expect(
      tester
          .getSize(find.byKey(const ValueKey('position-labels-felt')))
          .height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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

    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('hole-cards-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    final heroRail = find.byWidgetPredicate(
      (w) => w is MiniCard && w.size == MiniCardSize.hero,
    );
    expect(heroRail, findsAtLeastNWidgets(2));
    await tester.tap(heroRail.first);
    await tester.pump();
    expect(feltAck, 1);
    // Densified shell must stay filled after acknowledge.
    expect(
      tester.getSize(find.byKey(const ValueKey('hole-cards-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
      accessibilityText:
          'Pair beats high card. Flush beats straight. Remember the ladder.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Pair beats high card. Flush beats straight. Remember the ladder.',
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
    expect(find.text('Tap High card'), findsNothing);
    expect(find.text('Tap each rung from high card to flush.'), findsNothing);
    expect(find.text('High card → pair → straight → flush'), findsNothing);
    expect(find.text('Straight'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('hand-ladder-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('High card'));
    await tester.pump();
    expect(feltAck, 0);
    expect(find.text('Tap One pair'), findsNothing);
    await tester.tap(find.text('One pair'));
    await tester.pump();
    expect(feltAck, 0);
    await tester.tap(find.text('Straight'));
    await tester.pump();
    expect(feltAck, 0);
    expect(find.text('Tap Flush'), findsNothing);
    await tester.tap(find.text('Flush'));
    await tester.pump();
    expect(feltAck, 1);
    expect(tester.takeException(), isNull);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('High card → pair → straight → flush'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('hand-ladder-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap A♥'), findsNothing);
    expect(
      find.text('Tap each highlighted card — those five count'),
      findsNothing,
    );
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('best-five-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
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
    // Sequential SoftPulse — only the next card is highlighted.
    expect(
      find.byWidgetPredicate(
        (w) => w is SelectableBestFiveCard && w.highlighted && w.enabled,
      ),
      findsOneWidget,
    );
    // Tap in teach order; re-find after each rebuild (evaluate() goes stale).
    for (final code in const ['Ah', 'Kd', 'As', '7c', '9h']) {
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SelectableBestFiveCard && w.code == code,
        ),
      );
      await tester.pump();
    }
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Five play · two leftovers'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('best-five-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    // SoftPulse + Rex own the cue — no Tap Fold footer mid-teach.
    expect(find.text('Tap Fold'), findsNothing);
    expect(find.text('Tap Fold, Check, and Call'), findsNothing);
    expect(find.text('Tap Fold, Check, and Call.'), findsNothing);
    expect(
      find.text('Fold · Check · Call — your three passives'),
      findsNothing,
    );
    final teachHeight =
        tester.getSize(find.byType(PassiveActionsDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(feltAck, 0);
    expect(find.text('Tap Check'), findsNothing);
    await tester.tap(find.text('CHECK'));
    await tester.pump();
    expect(find.text('Tap Call'), findsNothing);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(feltAck, 1);
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    expect(
      find.text('Fold · Check · Call — your three passives'),
      findsNothing,
    );
    expect(
      tester.getSize(find.byType(PassiveActionsDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    // SoftPulse + Rex own the cue — no Tap Bet footer mid-teach.
    expect(find.text('Tap Bet'), findsNothing);
    expect(find.text('Tap Bet, Raise, and All-in'), findsNothing);
    expect(find.text('Tap Bet, Raise, and All-in.'), findsNothing);
    expect(
      find.text('Bet · Raise · All-in — your three aggressives'),
      findsNothing,
    );
    final teachHeight =
        tester.getSize(find.byType(AggressiveActionsDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    await tester.tap(find.text('BET'));
    await tester.pump();
    expect(find.text('Tap Raise'), findsNothing);
    await tester.tap(find.text('RAISE'));
    await tester.pump();
    await tester.tap(find.text('ALL-IN'));
    await tester.pump();
    expect(feltAck, 1);
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    expect(
      find.text('Bet · Raise · All-in — your three aggressives'),
      findsNothing,
    );
    expect(
      tester.getSize(find.byType(AggressiveActionsDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('aggressive explain hides Rex once Nice feedback lands', (
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
          text: 'Bet opens the betting. Raise reopens it. All-in is just size-capped.',
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
    expect(
      find.text(
        'Bet opens the betting. Raise reopens it. All-in is just size-capped.',
      ),
      findsOneWidget,
    );
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'a1',
        activityId: activity.id,
        grade: SoftGrade.recommended,
        feedback:
            'Bet opens the betting. Raise reopens it. All-in is just size-capped.',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: CourseResumePointer(
          attemptId: 'a1',
          lessonId: 'lesson-01-03-02-bet-raise-allin',
          activityId: activity.id,
          activityIndex: 0,
        ),
        duplicate: false,
      ),
    );
    await tester.pump();
    // Feedback sheet is owned by the runner — activity itself must drop Rex.
    expect(
      find.text(
        'Bet opens the betting. Raise reopens it. All-in is just size-capped.',
      ),
      findsNothing,
    );
    controller.dispose();
  });

  testWidgets('open-pot dock status stays generic under Rex coach', (
    tester,
  ) async {
    final activity = CourseActivity(
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
    expect(find.text('The pot is open — tap a bet size.'), findsOneWidget);
    // SoftPulse + Rex own the cue — no third "tap…" line under the dock.
    expect(find.text('Tap your action on the dock.'), findsNothing);
    expect(find.text('Tap Bet to open the pot.'), findsNothing);
    // Generic felt status also suppressed while SoftPulse guides Bet 5.
    expect(find.text('Pot is open to a bet'), findsNothing);
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'a1',
        activityId: activity.id,
        grade: SoftGrade.recommended,
        feedback: 'A half-pot bet asks for value.',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: CourseResumePointer(
          attemptId: 'a1',
          lessonId: 'lesson-01-03-02-bet-raise-allin',
          activityId: activity.id,
          activityIndex: 1,
        ),
        duplicate: false,
      ),
    );
    await tester.pump();
    expect(find.text('The pot is open — tap a bet size.'), findsNothing);
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
    // SoftPulse + Rex own the cue — no Tap Preflop footer mid-teach.
    expect(find.text('Tap Preflop'), findsNothing);
    expect(find.text('Tap each street from preflop to river'), findsNothing);
    expect(find.text('Tap each street from preflop to river.'), findsNothing);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('streets-timeline-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    // Densify lanes grow past the compact 12px title footprint so contain
    // can fill tall-phone green (scaleDown left a void above PREFLOP).
    final preflop = tester.getSize(find.text('PREFLOP'));
    expect(preflop.height, greaterThanOrEqualTo(16));
    // Densified RIVER must not paint a RenderFlex overflow (7 small cards).
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('PREFLOP'));
    await tester.pump();
    expect(find.text('Tap Flop'), findsNothing);
    await tester.tap(find.text('FLOP'));
    await tester.pump();
    expect(find.text('Tap Turn'), findsNothing);
    await tester.tap(find.text('TURN'));
    await tester.pump();
    expect(find.text('Tap River'), findsNothing);
    await tester.tap(find.text('RIVER'));
    await tester.pump();
    expect(feltAck, 1);
    expect(tester.takeException(), isNull);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Preflop → flop → turn → river'), findsOneWidget);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('streets-timeline-felt')))
          .height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('streets explain hides outer tap hint under Nice!', (
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
          text: 'Four streets: preflop, flop, turn, river. Match bets to move on.',
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
          onFeltAcknowledge: () {},
        ),
      ),
    );
    // Interactive felt embeds the only tap cue.
    expect(find.text('Tap Preflop'), findsNothing);
    expect(find.text('Tap each street from preflop to river'), findsNothing);
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'a1',
        activityId: activity.id,
        grade: SoftGrade.recommended,
        feedback:
            'Four streets: preflop, flop, turn, river. Match bets to move on.',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'a1',
          lessonId: 'lesson-01-04-01-streets-and-order',
          activityId: 'act-01-04-01-explain-streets',
          activityIndex: 0,
        ),
        duplicate: false,
      ),
    );
    await tester.pump();
    expect(find.text('Tap each street from preflop to river'), findsNothing);
    expect(find.text('Preflop → flop → turn → river'), findsOneWidget);
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
    // SoftPulse + Rex own the cue — no Tap Fold win footer mid-teach.
    expect(find.text('Tap Fold win'), findsNothing);
    expect(find.text('Tap Fold win, Showdown, and Side pot'), findsNothing);
    expect(find.text('Tap Fold win, Showdown, and Side pot.'), findsNothing);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('winning-paths-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    // Densify titles grow past the compact 12px footprint so contain can
    // fill tall-phone green (scaleDown left a void above FOLD WIN).
    final foldWin = tester.getSize(find.text('FOLD WIN'));
    expect(foldWin.height, greaterThanOrEqualTo(16));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('FOLD WIN'));
    await tester.pump();
    expect(find.text('Tap Showdown'), findsNothing);
    await tester.tap(find.text('SHOWDOWN'));
    await tester.pump();
    expect(find.text('Tap Side pot'), findsNothing);
    await tester.tap(find.text('SIDE POT'));
    await tester.pump();
    expect(feltAck, 1);
    expect(tester.takeException(), isNull);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Fold win · Showdown · Side pot'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('winning-paths-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('winning-paths explain hides outer tap hint under Nice!', (
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
          text:
              'Folds win pots early. Showdown compares hands. Short stacks make side pots.',
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
          onFeltAcknowledge: () {},
        ),
      ),
    );
    // SoftPulse + Rex own the cue — no Tap Fold win footer mid-teach.
    expect(find.text('Tap Fold win'), findsNothing);
    expect(find.text('Tap Fold win, Showdown, and Side pot'), findsNothing);
    expect(find.text('Tap Fold win, Showdown, and Side pot.'), findsNothing);
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'a1',
        activityId: activity.id,
        grade: SoftGrade.recommended,
        feedback:
            'Folds win pots early. Showdown compares hands. Short stacks make side pots.',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'a1',
          lessonId: 'lesson-01-05-01-winning-pots',
          activityId: 'act-01-05-01-explain-win',
          activityIndex: 0,
        ),
        duplicate: false,
      ),
    );
    await tester.pump();
    expect(find.text('Tap Fold win'), findsNothing);
    expect(find.text('Tap Fold win, Showdown, and Side pot'), findsNothing);
    expect(
      find.text('Fold win · Showdown · Side pot'),
      findsOneWidget,
    );
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
    // SoftPulse + Rex own the cue — no Tap Blinds footer stack.
    expect(find.text('Tap Blinds'), findsNothing);
    expect(find.text('Tap Blinds, You act, and Ending'), findsNothing);
    expect(find.text('Tap Blinds, You act, and Ending.'), findsNothing);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('toy-hand-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    await tester.tap(find.text('BLINDS'));
    await tester.pump();
    expect(find.text('Tap You act'), findsNothing);
    await tester.tap(find.text('YOU ACT'));
    await tester.pump();
    expect(find.text('Tap Ending'), findsNothing);
    await tester.tap(find.text('ENDING'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Blinds · You act · Ending'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('toy-hand-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('toy-hand explain hides outer tap hint under Nice!', (
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
          text: 'One short hand. Blinds post, you act, we reach an ending.',
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
          onFeltAcknowledge: () {},
        ),
      ),
    );
    // SoftPulse + Rex own the cue; outer bulk _TapHint suppressed.
    expect(find.text('Tap Blinds'), findsNothing);
    expect(find.text('Tap Blinds, You act, and Ending'), findsNothing);
    expect(find.text('Tap Blinds, You act, and Ending.'), findsNothing);
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'a1',
        activityId: activity.id,
        grade: SoftGrade.recommended,
        feedback:
            'One short hand. Blinds post, you act, we reach an ending.',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'a1',
          lessonId: 'lesson-01-06-01-guided-complete-hand',
          activityId: 'act-01-06-01-explain-run',
          activityIndex: 0,
        ),
        duplicate: false,
      ),
    );
    await tester.pump();
    expect(find.text('Tap Blinds'), findsNothing);
    expect(find.text('Tap Blinds, You act, and Ending'), findsNothing);
    // Locked under Nice! — summary pill, not the mid-teach Tap cue.
    expect(find.text('Blinds · You act · Ending'), findsOneWidget);
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
    // SoftPulse + Rex own the cue — no Tap UTG next footer stack.
    expect(find.text('Tap UTG next'), findsNothing);
    expect(find.text('Tap each seat in preflop order'), findsNothing);
    expect(find.text('Tap UTG, then HJ, then BTN.'), findsNothing);
    expect(find.text('Tap UTG, then HJ, then BTN'), findsNothing);
    expect(find.text('Postflop starts left of the button'), findsNothing);
    expect(find.text('First'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('action-order-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    // Wrong first seat is ignored — teach-by-doing requires order.
    await tester.tap(find.text('BTN'));
    await tester.pump();
    expect(feltAck, 0);
    await tester.tap(find.text('UTG'));
    await tester.pump();
    expect(feltAck, 0);
    expect(find.text('Tap HJ next'), findsNothing);
    await tester.tap(find.text('HJ'));
    await tester.pump();
    expect(feltAck, 0);
    expect(find.text('Tap BTN next'), findsNothing);
    await tester.tap(find.text('BTN'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('UTG → HJ → BTN'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('action-order-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    // SoftPulse + Rex own the cue — no Tap Pairs next footer stack.
    expect(find.text('Tap Pairs next'), findsNothing);
    expect(find.text('Tap each starting-hand family'), findsNothing);
    expect(find.text('Tap each starting-hand family.'), findsNothing);
    expect(
      find.text('Tap each family — trash is everything else'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('hand-families-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('Pairs'));
    await tester.pump();
    expect(find.text('Tap Broadways next'), findsNothing);
    await tester.tap(find.text('Broadways'));
    await tester.pump();
    expect(find.text('Tap Suited aces next'), findsNothing);
    await tester.tap(find.text('Suited aces'));
    await tester.pump();
    expect(find.text('Tap Connectors next'), findsNothing);
    await tester.tap(find.text('Connectors'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Pairs · broadways · suited aces · connectors'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('hand-families-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('hand-families guided taps Pocket pair on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-02-01-guided-pair',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText:
          'Look at pocket eights on the felt — tap Pocket pair.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Name the family for your holes.',
      choices: const [
        CourseChoice(id: 'hf-pair', label: 'Pocket pair'),
        CourseChoice(id: 'hf-suited-ace', label: 'Suited ace'),
        CourseChoice(id: 'hf-broadway', label: 'Broadway'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.handFamilyGuidedOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.heroCodes, ['8h', '8c']);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.handFamilyPair,
        choices: activity.choices,
      ),
      'hf-pair',
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
      find.text('Matching ranks in the hole — tap the family.'),
      findsOneWidget,
    );
    expect(find.text('Name the family for your holes.'), findsNothing);
    expect(find.text('Pocket pair'), findsOneWidget);
    expect(find.text('Matching ranks'), findsOneWidget);
    expect(find.text('Tap Pocket pair.'), findsNothing);
    await tester.tap(find.text('Pocket pair'));
    await tester.pump();
    expect(controller.draft.choiceId, 'hf-pair');
    controller.dispose();
  });

  testWidgets('hand-families scaffolded taps Broadway on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-02-01-scaffolded-broadway',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Look at ace-king on the felt — tap Broadway.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Name the family for your holes.',
      choices: const [
        CourseChoice(id: 'hf-broadway', label: 'Broadway'),
        CourseChoice(id: 'hf-pair', label: 'Pocket pair'),
        CourseChoice(id: 'hf-trash', label: 'Offsuit trash'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.handFamilyScaffoldedOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.heroCodes, ['As', 'Kd']);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.handFamilyScBroadway,
        choices: activity.choices,
      ),
      'hf-broadway',
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
      find.text('Both cards ten-or-better — tap the family.'),
      findsOneWidget,
    );
    expect(find.text('Broadway'), findsOneWidget);
    expect(find.text('Tap Broadway.'), findsNothing);
    await tester.tap(find.text('Broadway'));
    await tester.pump();
    expect(controller.draft.choiceId, 'hf-broadway');
    controller.dispose();
  });

  testWidgets('hand-families unguided taps Suited conn on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-02-01-unguided-sc',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Look at 76s on the felt — tap Suited connector.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Name the family for your holes.',
      choices: const [
        CourseChoice(id: 'hf-sc', label: 'Suited connector'),
        CourseChoice(id: 'hf-offsuit-conn', label: 'Offsuit connector'),
        CourseChoice(id: 'hf-trash', label: 'Offsuit trash'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.handFamilyUnguidedOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.heroCodes, ['7h', '6h']);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.handFamilyUgSc,
        choices: activity.choices,
      ),
      'hf-sc',
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
    expect(find.text('Look at your holes — tap the family.'), findsOneWidget);
    expect(find.text('Suited conn'), findsOneWidget);
    expect(find.text('Tap Suited conn.'), findsNothing);
    await tester.tap(find.text('Suited conn'));
    await tester.pump();
    expect(controller.draft.choiceId, 'hf-sc');
    controller.dispose();
  });

  testWidgets('hand-families checkpoint taps Offsuit trash on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-02-01-checkpoint-trash',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Look at 72o early — tap Offsuit trash.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Name the family for your holes.',
      choices: const [
        CourseChoice(id: 'hf-trash', label: 'Offsuit trash'),
        CourseChoice(id: 'hf-pair', label: 'Pocket pair'),
        CourseChoice(id: 'hf-suited-ace', label: 'Suited ace'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.handFamilyCheckpointOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.heroCodes, ['7c', '2d']);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.handFamilyCpTrash,
        choices: activity.choices,
      ),
      'hf-trash',
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
    expect(
      find.text('Early seat with junk — tap the family.'),
      findsOneWidget,
    );
    expect(find.text('Offsuit trash'), findsOneWidget);
    await tester.tap(find.text('Offsuit trash'));
    await tester.pump();
    expect(controller.draft.choiceId, 'hf-trash');
    controller.dispose();
  });

  test('hand-families identify steps use classify-on-felt presentation', () {
    expect(
      resolveSelectIdentifyPresentation(
        CourseActivity(
          id: 'act-02-02-01-guided-pair',
          order: 2,
          stage: ActivityStage.guided,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'classify',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Name the family for your holes.',
          choices: const [
            CourseChoice(id: 'hf-pair', label: 'Pocket pair'),
          ],
        ),
      ),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(
      resolveSelectIdentifyPresentation(
        CourseActivity(
          id: 'act-02-02-01-scaffolded-broadway',
          order: 3,
          stage: ActivityStage.scaffolded,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'classify',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Name the family for your holes.',
          choices: const [
            CourseChoice(id: 'hf-broadway', label: 'Broadway'),
          ],
        ),
      ),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(
      resolveSelectIdentifyPresentation(
        CourseActivity(
          id: 'act-02-02-01-unguided-sc',
          order: 4,
          stage: ActivityStage.unguided,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'classify',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Name the family for your holes.',
          choices: const [
            CourseChoice(id: 'hf-sc', label: 'Suited connector'),
          ],
        ),
      ),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(
      resolveSelectIdentifyPresentation(
        CourseActivity(
          id: 'act-02-02-01-checkpoint-trash',
          order: 5,
          stage: ActivityStage.checkpoint,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'classify',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Name the family for your holes.',
          choices: const [
            CourseChoice(id: 'hf-trash', label: 'Offsuit trash'),
          ],
        ),
      ),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(
      resolveLessonTableScene(
        CourseActivity(
          id: 'act-02-02-01-unguided-sc',
          order: 4,
          stage: ActivityStage.unguided,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'sc',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Name the family for your holes.',
          choices: const [
            CourseChoice(id: 'hf-sc', label: 'Suited connector'),
          ],
        ),
      )?.heroCodes,
      ['7h', '6h'],
    );
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
    expect(find.text('Tap EARLY next'), findsNothing);
    expect(find.text('Tap Early, Button, and Live 3x'), findsNothing);
    expect(find.text('Tap Early, Button, and Live 3x.'), findsNothing);
    expect(
      find.text('Early tight · button wider · live opens ~3x'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight = tester.getSize(find.byType(OpenRangeDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('EARLY'));
    await tester.pump();
    expect(find.text('Tap BUTTON next'), findsNothing);
    await tester.tap(find.text('BUTTON'));
    await tester.pump();
    expect(find.text('Tap LIVE 3x next'), findsNothing);
    await tester.tap(find.text('LIVE 3x'));
    await tester.pump();
    expect(feltAck, 1);
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    expect(
      find.text('Early tight · button wider · live opens ~3x'),
      findsNothing,
    );
    expect(find.text('Strong only'), findsNothing);
    expect(find.text('Wider'), findsNothing);
    expect(find.text('UTG–MP'), findsOneWidget);
    expect(find.text('Last to act'), findsOneWidget);
    expect(
      tester.getSize(find.byType(OpenRangeDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('open-fold guided docks Fold on UTG felt — no text prompt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-03-01-guided-utg',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Fold seven-two offsuit under the gun.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You are UTG with 72o at 1/2. What do you do?',
      choices: const [
        CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'open-six', label: 'Open to 6', action: 'RAISE'),
        CourseChoice(id: 'limp', label: 'Limp', action: 'CALL'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    expect(
      resolveLessonActionSpot(activity)?.heroCodes,
      ['7h', '2d'],
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
    expect(find.text('Trash UTG — tap Fold.'), findsOneWidget);
    // SoftPulse + Rex own the cue — no third gold felt status.
    expect(find.text('First in — trash folds'), findsNothing);
    expect(
      find.text('You are UTG with 72o at 1/2. What do you do?'),
      findsNothing,
    );
    expect(find.text('FOLD'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold');
    controller.dispose();
  });

  test('open-fold identify steps resolve felt action spots', () {
    expect(
      resolveLessonActionSpot(
        CourseActivity(
          id: 'act-02-03-01-scaffolded-qq',
          order: 3,
          stage: ActivityStage.scaffolded,
          renderer: ActivityRenderer.pokerActionSizing,
          estimatedSeconds: 55,
          accessibilityText: 'qq',
          acceptedGrades: const [SoftGrade.recommended],
          choices: const [],
        ),
      )?.heroCodes,
      ['Qh', 'Qd'],
    );
    expect(
      resolveLessonActionSpot(
        CourseActivity(
          id: 'act-02-03-01-unguided-btn',
          order: 4,
          stage: ActivityStage.unguided,
          renderer: ActivityRenderer.pokerActionSizing,
          estimatedSeconds: 55,
          accessibilityText: 'btn',
          acceptedGrades: const [SoftGrade.recommended],
          choices: const [],
        ),
      )?.heroCodes,
      ['Kh', '9h'],
    );
    expect(
      resolveLessonActionSpot(
        CourseActivity(
          id: 'act-02-03-01-checkpoint-hj',
          order: 5,
          stage: ActivityStage.checkpoint,
          renderer: ActivityRenderer.pokerActionSizing,
          estimatedSeconds: 55,
          accessibilityText: 'hj',
          acceptedGrades: const [SoftGrade.recommended],
          choices: const [],
        ),
      )?.heroCodes,
      ['Ah', 'Td'],
    );
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
    expect(find.text('Tap FOLD next'), findsNothing);
    expect(find.text('Tap Fold, Call, and 3-Bet'), findsNothing);
    expect(find.text('Tap Fold, Call, and 3-Bet.'), findsNothing);
    expect(
      find.text('Weak fold · playable call · strong 3-bet'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(VsOpenResponseDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    // Structural captions — Rex owns weak / playable / strong.
    expect(find.text('Give up'), findsOneWidget);
    expect(find.text('Match open'), findsOneWidget);
    expect(find.text('Reopen'), findsOneWidget);
    expect(find.text('Weak hands'), findsNothing);
    expect(find.text('Playable'), findsNothing);
    expect(find.text('Strong / polar'), findsNothing);

    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(find.text('Tap CALL next'), findsNothing);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(find.text('Tap 3-BET next'), findsNothing);
    await tester.tap(find.text('3-BET'));
    await tester.pump();
    expect(feltAck, 1);
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    expect(
      find.text('Weak fold · playable call · strong 3-bet'),
      findsNothing,
    );
    expect(find.text('Give up'), findsOneWidget);
    expect(find.text('Match open'), findsOneWidget);
    expect(find.text('Reopen'), findsOneWidget);
    expect(
      tester.getSize(find.byType(VsOpenResponseDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('vs-open guided docks Fold on BB felt — no text prompt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-04-01-guided-fold',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Fold jack-three offsuit versus an open.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'UTG opens to 6. You have J3o in the big blind. Action?',
      choices: const [
        CourseChoice(id: 'fold-j3', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'call-j3', label: 'Call', action: 'CALL'),
        CourseChoice(id: '3bet-j3', label: '3-bet to 18', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    expect(
      resolveLessonActionSpot(activity)?.heroCodes,
      ['Jh', '3d'],
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
    expect(
      find.text('Junk in the big blind vs an open — tap Fold.'),
      findsOneWidget,
    );
    // SoftPulse + Rex own the cue — no third gold felt status.
    expect(find.text('Facing an open — junk folds'), findsNothing);
    expect(
      find.text('UTG opens to 6. You have J3o in the big blind. Action?'),
      findsNothing,
    );
    expect(find.text('FOLD'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold-j3');
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'a1',
        activityId: activity.id,
        grade: SoftGrade.recommended,
        feedback: 'No defend with J3o.',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: CourseResumePointer(
          attemptId: 'a1',
          lessonId: 'lesson-02-04-01-facing-raise',
          activityId: activity.id,
          activityIndex: 1,
        ),
        duplicate: false,
      ),
    );
    await tester.pump();
    // SoftPulse ownership persists under Nice! — no Rex-echo felt footer.
    expect(find.text('Facing an open — junk folds'), findsNothing);
    controller.dispose();
  });

  testWidgets('vs-open scaffolded SoftPulse Call — no Rex-echo felt footer', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-04-01-scaffolded-call',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Call with suited connectors on the button.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'CO opens to 6. You have 87s on the button. Action?',
      choices: const [
        CourseChoice(id: 'call-87s', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-87s', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: '3bet-87s', label: '3-bet to 18', action: 'RAISE'),
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
    expect(
      find.text('Suited connector on the button vs a CO open — tap Call.'),
      findsOneWidget,
    );
    // SoftPulse + Rex own the cue — no third gold felt status.
    expect(find.text('Suited connector in position'), findsNothing);
    expect(find.text('CALL'), findsOneWidget);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call-87s');
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'a2',
        activityId: activity.id,
        grade: SoftGrade.recommended,
        feedback: 'Playable in position.',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: CourseResumePointer(
          attemptId: 'a2',
          lessonId: 'lesson-02-04-01-facing-raise',
          activityId: activity.id,
          activityIndex: 2,
        ),
        duplicate: false,
      ),
    );
    await tester.pump();
    expect(find.text('Suited connector in position'), findsNothing);
    controller.dispose();
  });

  testWidgets('vs-open unguided hides hand-strength felt spoiler', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-04-01-unguided-3bet',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Value three-bet kings.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'BTN opens to 6. You have KK in the small blind. Action?',
      choices: const [
        CourseChoice(id: '3bet-kk', label: '3-bet to 18', action: 'RAISE'),
        CourseChoice(id: 'call-kk', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-kk', label: 'Fold', action: 'FOLD'),
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
    expect(
      find.text(
        'Kings in the small blind vs a button open — tap Fold, Call, or 3-bet.',
      ),
      findsOneWidget,
    );
    // Cards + villain line teach — no gold strength spoiler.
    expect(find.text('Premium vs a button open'), findsNothing);
    expect(find.text('A bet faces you'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('vs-open checkpoint hides hand-strength felt spoiler', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-04-01-checkpoint-aq',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Value three-bet ace-queen suited.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'HJ opens to 6. You have AQs on the CO. Action?',
      choices: const [
        CourseChoice(id: '3bet-aqs', label: '3-bet to 18', action: 'RAISE'),
        CourseChoice(id: 'call-aqs', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-aqs', label: 'Fold', action: 'FOLD'),
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
    expect(
      find.text('Strong suited broadway in the CO — tap your action.'),
      findsOneWidget,
    );
    expect(find.text('Strong suited broadway'), findsNothing);
    expect(find.text('A bet faces you'), findsOneWidget);
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
    expect(find.text('Tap CHIPS→BB next'), findsNothing);
    expect(find.text('Tap Chips→BB, Shorter, and Depth'), findsNothing);
    expect(find.text('Tap Chips→BB, Shorter, and Depth.'), findsNothing);
    expect(
      find.text('Count in BB · shorter stack caps the pot'),
      findsNothing,
    );
    expect(find.text('Sets the ceiling'), findsNothing);
    expect(find.text('Min of the two'), findsOneWidget);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(BbStackDepthDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('CHIPS→BB'));
    await tester.pump();
    expect(find.text('Tap SHORTER next'), findsNothing);
    await tester.tap(find.text('SHORTER'));
    await tester.pump();
    expect(find.text('Tap DEPTH next'), findsNothing);
    await tester.tap(find.text('DEPTH'));
    await tester.pump();
    expect(feltAck, 1);
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    expect(
      find.text('Count in BB · shorter stack caps the pot'),
      findsNothing,
    );
    expect(find.text('Sets the ceiling'), findsNothing);
    expect(find.text('Min of the two'), findsOneWidget);
    expect(
      tester.getSize(find.byType(BbStackDepthDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap WATCH next'), findsNothing);
    expect(find.text('Tap Watch, Say, Cover, and Wait'), findsNothing);
    expect(find.text('Tap Watch, Say, Cover, and Wait.'), findsNothing);
    expect(
      find.text('Watch · say · cover · wait your turn'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(TableHabitsDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('WATCH'));
    await tester.pump();
    expect(find.text('Tap SAY next'), findsNothing);
    await tester.tap(find.text('SAY'));
    await tester.pump();
    expect(find.text('Tap COVER next'), findsNothing);
    await tester.tap(find.text('COVER'));
    await tester.pump();
    expect(find.text('Tap WAIT next'), findsNothing);
    await tester.tap(find.text('WAIT'));
    await tester.pump();
    expect(feltAck, 1);
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    expect(
      find.text('Watch · say · cover · wait your turn'),
      findsNothing,
    );
    expect(
      tester.getSize(find.byType(TableHabitsDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('live-habits guided SoftPulse Watch — no Rex-echo felt caption', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-06-01-guided-follow',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Follow earlier actions before choosing yours.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Two seats act before you. What first?',
      choices: const [
        CourseChoice(id: 'watch', label: 'Watch what they do, then decide'),
        CourseChoice(
          id: 'look-away',
          label: 'Stare at your phone until it is your turn',
        ),
        CourseChoice(
          id: 'decide-now',
          label: 'Decide your action before they act',
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
    expect(
      find.text('Two seats act before you — tap what you do first.'),
      findsOneWidget,
    );
    // SoftPulse + Rex own the cue — felt caption stays structural.
    expect(find.text('Two seats still to act · you are next'), findsNothing);
    expect(find.text('Preflop · action above you'), findsOneWidget);
    expect(find.text('Watch first'), findsOneWidget);
    await tester.tap(find.text('Watch first'));
    await tester.pump();
    expect(controller.draft.choiceId, 'watch');
    controller.dispose();
  });

  testWidgets(
    'live-habits unguided protect — no SoftPulse spoilers or gold tip',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-02-06-01-unguided-protect',
        order: 4,
        stage: ActivityStage.unguided,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 40,
        accessibilityText: 'Protect hole cards with a chip or hand.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Your cards sit near the muck. Best habit?',
        choices: const [
          CourseChoice(
            id: 'chip-on-cards',
            label: 'Keep a chip or hand on your cards',
          ),
          CourseChoice(
            id: 'spread-out',
            label: 'Spread them face-up for the camera',
          ),
          CourseChoice(
            id: 'leave-loose',
            label: 'Leave them loose near the dealer',
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
      expect(
        find.text('Cards near the muck — tap how you protect them.'),
        findsOneWidget,
      );
      // Structural felt caption — no muck/discard echo of Rex.
      expect(find.text('Holes near the discard pile'), findsNothing);
      expect(find.text('Live table · your holes'), findsOneWidget);
      // Tile details must not answer or tip the habit.
      expect(find.text('Protected'), findsNothing);
      expect(find.text('Camera bait'), findsNothing);
      expect(find.text('Near muck'), findsNothing);
      expect(find.text('Chip on cards'), findsOneWidget);
      expect(find.text('On top'), findsOneWidget);
      expect(find.text('Face up'), findsOneWidget);
      expect(find.text('No chip'), findsOneWidget);
      // No gold tip icon on the correct tile.
      final tipIcons = tester.widgetList<Icon>(
        find.byIcon(Icons.monetization_on_outlined),
      );
      expect(tipIcons, isNotEmpty);
      for (final icon in tipIcons) {
        expect(icon.color, AppColors.slate);
      }
      await tester.tap(find.text('Chip on cards'));
      await tester.pump();
      expect(controller.draft.choiceId, 'chip-on-cards');
      controller.dispose();
    },
  );

  testWidgets(
    'live-habits checkpoint OOT — no SoftPulse spoilers or gold tip',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-02-06-01-checkpoint-oot',
        order: 5,
        stage: ActivityStage.checkpoint,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 45,
        accessibilityText: 'Recognize acting out of turn.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt:
            'Action is two seats left. You toss in a raise early. Problem?',
        choices: const [
          CourseChoice(id: 'oot-bad', label: 'You acted out of turn'),
          CourseChoice(
            id: 'oot-fine',
            label: 'Acting early is fine if you are faster',
          ),
          CourseChoice(
            id: 'oot-dealer',
            label: 'The dealer should have stopped you',
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
      expect(find.text('Your mistake'), findsNothing);
      expect(find.text('Always reward'), findsNothing);
      expect(find.text('Blame them'), findsNothing);
      expect(find.text('Out of turn'), findsOneWidget);
      expect(find.text('Too soon'), findsOneWidget);
      expect(find.text('Faster OK?'), findsOneWidget);
      expect(find.text('Not you?'), findsOneWidget);
      final tipIcons = tester.widgetList<Icon>(
        find.byIcon(Icons.warning_amber_outlined),
      );
      expect(tipIcons, isNotEmpty);
      for (final icon in tipIcons) {
        expect(icon.color, AppColors.slate);
      }
      await tester.tap(find.text('Out of turn'));
      await tester.pump();
      expect(controller.draft.choiceId, 'oot-bad');
      controller.dispose();
    },
  );

  testWidgets(
    'full-ring checkpoint habit — no SoftPulse spoilers or gold tip',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-02-07-01-checkpoint-habit',
        order: 5,
        stage: ActivityStage.checkpoint,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 45,
        accessibilityText: 'Cover cards and wait your turn.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Full ring. Action two seats left. Your cards are uncovered. Fix?',
        choices: const [
          CourseChoice(
            id: 'cover-wait',
            label: 'Cover your cards and wait your turn',
          ),
          CourseChoice(
            id: 'act-early',
            label: 'Announce your action early',
          ),
          CourseChoice(
            id: 'leave-bare',
            label: 'Leave the cards uncovered',
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
      expect(find.text('Safe'), findsNothing);
      expect(find.text('OOT'), findsNothing);
      expect(find.text('Flash'), findsNothing);
      expect(find.text('Cover + wait'), findsOneWidget);
      expect(find.text('Hand on'), findsOneWidget);
      expect(find.text('Too soon'), findsOneWidget);
      expect(find.text('No cover'), findsOneWidget);
      final tipIcons = tester.widgetList<Icon>(
        find.byIcon(Icons.back_hand_outlined),
      );
      expect(tipIcons, isNotEmpty);
      for (final icon in tipIcons) {
        expect(icon.color, AppColors.slate);
      }
      await tester.tap(find.text('Cover + wait'));
      await tester.pump();
      expect(controller.draft.choiceId, 'cover-wait');
      controller.dispose();
    },
  );


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
    // SoftPulse + Rex own the cue — no mid-teach Tap NINE next footer.
    expect(find.text('Tap NINE next'), findsNothing);
    expect(find.text('Tap Nine, Same, and Position'), findsNothing);
    expect(find.text('Tap Nine, Same, and Position.'), findsNothing);
    expect(
      find.text('Nine seats · same rules · position still matters'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(FullRingDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('NINE'));
    await tester.pump();
    expect(find.text('Tap SAME next'), findsNothing);
    await tester.tap(find.text('SAME'));
    await tester.pump();
    expect(find.text('Tap POSITION next'), findsNothing);
    await tester.tap(find.text('POSITION'));
    await tester.pump();
    expect(feltAck, 1);
    // SoftPulse + Rex own the cue — no summary pill echoing Nice! feedback.
    expect(
      find.text('Nine seats · same rules · position still matters'),
      findsNothing,
    );
    expect(find.text('Still runs the show'), findsNothing);
    expect(find.text('Seat edge'), findsOneWidget);
    expect(
      tester.getSize(find.byType(FullRingDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap POT next'), findsNothing);
    expect(
      find.text('Tap Pot, Stacks, Button, and Who Acts'),
      findsNothing,
    );
    expect(
      find.text('Tap Pot, Stacks, Button, and Who Acts.'),
      findsNothing,
    );
    // SoftPulse + Rex own the teach verb — no duplicate Read… felt title.
    expect(find.text('Read the table before cards'), findsNothing);
    expect(find.text('Four table reads'), findsOneWidget);
    // Structural SoftPulse captions — not Rex’s “Words count live” paraphrase.
    expect(find.text('Whose turn'), findsOneWidget);
    expect(find.text('Words count live'), findsNothing);
    expect(
      find.text('Pot · stacks · button · who acts'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(TableReadDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('POT'));
    await tester.pump();
    expect(find.text('Tap STACKS next'), findsNothing);
    await tester.tap(find.text('STACKS'));
    await tester.pump();
    expect(find.text('Tap BUTTON next'), findsNothing);
    await tester.tap(find.text('BUTTON'));
    await tester.pump();
    expect(find.text('Tap WHO ACTS next'), findsNothing);
    await tester.tap(find.text('WHO ACTS'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Pot · stacks · button · who acts'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(TableReadDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap MADE next'), findsNothing);
    expect(find.text('Tap Made, Draw, SDV, and Air'), findsNothing);
    expect(find.text('Tap Made, Draw, SDV, and Air.'), findsNothing);
    // SoftPulse + Rex own the teach verb — no duplicate Label… felt title.
    expect(find.text('Label the flop before you bet'), findsNothing);
    expect(find.text('Four flop classes'), findsOneWidget);
    // Structural SoftPulse captions — not Rex’s “showdown value” paraphrase.
    expect(find.text('Weak made'), findsOneWidget);
    expect(find.text('Showdown value'), findsNothing);
    expect(
      find.text('Made · draw · showdown value · air'),
      findsNothing,
    );
    expect(
      find.text('Made · draw · SDV · air'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(FlopLabelDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('MADE'));
    await tester.pump();
    expect(find.text('Tap DRAW next'), findsNothing);
    await tester.tap(find.text('DRAW'));
    await tester.pump();
    expect(find.text('Tap SDV next'), findsNothing);
    await tester.tap(find.text('SDV'));
    await tester.pump();
    expect(find.text('Tap AIR next'), findsNothing);
    await tester.tap(find.text('AIR'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Made · draw · SDV · air'),
      findsOneWidget,
    );
    expect(
      find.text('Made · draw · showdown value · air'),
      findsNothing,
    );
    expect(
      tester.getSize(find.byType(FlopLabelDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap CLEAN next'), findsNothing);
    expect(find.text('Tap Clean, Dirty, and Price'), findsNothing);
    expect(find.text('Tap Clean, Dirty, and Price.'), findsNothing);
    // Structural SoftPulse captions — not Rex paraphrases.
    expect(find.text('Best-hand outs'), findsOneWidget);
    expect(find.text('Trap improve'), findsOneWidget);
    expect(find.text('Pot odds'), findsOneWidget);
    expect(find.text('Outs that help'), findsNothing);
    expect(find.text('Second-best risk'), findsNothing);
    expect(find.text('Is the call worth it?'), findsNothing);
    expect(
      find.text('Clean outs · dirty outs · price the call'),
      findsNothing,
    );
    expect(find.text('Clean · dirty · price'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(OutsPriceDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('CLEAN'));
    await tester.pump();
    expect(find.text('Tap DIRTY next'), findsNothing);
    await tester.tap(find.text('DIRTY'));
    await tester.pump();
    expect(find.text('Tap PRICE next'), findsNothing);
    await tester.tap(find.text('PRICE'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Clean · dirty · price'), findsOneWidget);
    expect(
      find.text('Clean outs · dirty outs · price the call'),
      findsNothing,
    );
    expect(
      tester.getSize(find.byType(OutsPriceDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap VALUE next'), findsNothing);
    expect(find.text('Tap each flop line once.'), findsNothing);
    expect(find.text('Tap each flop line once'), findsNothing);
    // SoftPulse + Rex own the teach verb — no duplicate Pick… felt title.
    expect(find.text('Flop lines — pick one plan'), findsNothing);
    expect(find.text('Six flop lines'), findsOneWidget);
    // Structural SoftPulse caption — not Rex’s “check back” paraphrase.
    expect(find.text('Pass the street'), findsOneWidget);
    expect(find.text('Check back'), findsNothing);
    expect(
      find.text('Value · c-bet · check · call · fold · raise'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(FlopLinesDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

await tester.tap(find.text('VALUE'));
    await tester.pump();
    expect(find.text('Tap C-BET next'), findsNothing);
    await tester.tap(find.text('C-BET'));
    await tester.pump();
    expect(find.text('Tap CHECK next'), findsNothing);
    await tester.tap(find.text('CHECK'));
    await tester.pump();
    expect(find.text('Tap CALL next'), findsNothing);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(find.text('Tap FOLD next'), findsNothing);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(find.text('Tap RAISE next'), findsNothing);
    await tester.tap(find.text('RAISE'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Value · c-bet · check · call · fold · raise'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(FlopLinesDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Four turn moves'), findsOneWidget);
    expect(find.text('Turn: brick or change the story'), findsNothing);
    expect(find.text('Tap BRICK next'), findsNothing);
    expect(find.text('Tap Brick, Change, Barrel, and Delay'), findsNothing);
    expect(find.text('Tap Brick, Change, Barrel, and Delay.'), findsNothing);
    // Structural SoftPulse captions — not Rex paraphrases.
    expect(find.text('Blank runout'), findsOneWidget);
    expect(find.text('Board shifts'), findsOneWidget);
    expect(find.text('Hold fire'), findsOneWidget);
    expect(find.text('Story unchanged'), findsNothing);
    expect(find.text('New story'), findsNothing);
    expect(find.text('Intentional pause'), findsNothing);
    expect(
      find.text('Brick · change · barrel · delay with intent'),
      findsNothing,
    );
    expect(find.text('Brick · change · barrel · delay'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(TurnStoryDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('BRICK'));
    await tester.pump();
    expect(find.text('Tap CHANGE next'), findsNothing);
    await tester.tap(find.text('CHANGE'));
    await tester.pump();
    expect(find.text('Tap BARREL next'), findsNothing);
    await tester.tap(find.text('BARREL'));
    await tester.pump();
    expect(find.text('Tap DELAY next'), findsNothing);
    await tester.tap(find.text('DELAY'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Brick · change · barrel · delay'), findsOneWidget);
    expect(
      find.text('Brick · change · barrel · delay with intent'),
      findsNothing,
    );
    expect(
      tester.getSize(find.byType(TurnStoryDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Four river jobs'), findsOneWidget);
    expect(find.text('River is binary'), findsNothing);
    expect(find.text('Tap VALUE next'), findsNothing);
    expect(find.text('Tap Value, Bluff, Catch, and Fold'), findsNothing);
    expect(find.text('Tap Value, Bluff, Catch, and Fold.'), findsNothing);
    expect(find.text('Bluff-catch'), findsNothing);
    expect(find.text('No mystery float'), findsNothing);
    expect(find.text('Snap off air'), findsOneWidget);
    expect(find.text('Quit weak'), findsOneWidget);
    expect(
      find.text('Value · bluff · bluff-catch · fold'),
      findsNothing,
    );
    expect(
      find.text('Value · bluff · catch · fold'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(RiverBinaryDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('VALUE'));
    await tester.pump();
    expect(find.text('Tap BLUFF next'), findsNothing);
    await tester.tap(find.text('BLUFF'));
    await tester.pump();
    expect(find.text('Tap CATCH next'), findsNothing);
    await tester.tap(find.text('CATCH'));
    await tester.pump();
    expect(find.text('Tap FOLD next'), findsNothing);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Value · bluff · bluff-catch · fold'),
      findsNothing,
    );
    expect(
      find.text('Value · bluff · catch · fold'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(RiverBinaryDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Worshipping one pair'), findsNothing);
    expect(find.text('Chase bad prices'), findsNothing);
    expect(find.text('Call too soft'), findsNothing);
    expect(find.text('Bluff multiway'), findsNothing);
    expect(find.text('Overplay pairs'), findsOneWidget);
    expect(find.text('Ignore odds'), findsOneWidget);
    expect(find.text('Never raise'), findsOneWidget);
    expect(find.text('Spew multiway'), findsOneWidget);
    expect(find.text('Tap TOP PAIR next'), findsNothing);
    expect(find.text('Tap each common leak once.'), findsNothing);
    expect(find.text('Tap each common leak once'), findsNothing);
    expect(
      find.text('Top pair · bad prices · passive calls · bluff crowds'),
      findsNothing,
    );
    expect(
      find.text('Top pair · prices · passive · crowds'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(CommonLeaksDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('TOP PAIR'));
    await tester.pump();
    expect(find.text('Tap PRICES next'), findsNothing);
    await tester.tap(find.text('PRICES'));
    await tester.pump();
    expect(find.text('Tap PASSIVE next'), findsNothing);
    await tester.tap(find.text('PASSIVE'));
    await tester.pump();
    expect(find.text('Tap CROWDS next'), findsNothing);
    await tester.tap(find.text('CROWDS'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Top pair · bad prices · passive calls · bluff crowds'),
      findsNothing,
    );
    expect(
      find.text('Top pair · prices · passive · crowds'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(CommonLeaksDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('You never know it'), findsNothing);
    expect(find.text('What they can have'), findsNothing);
    expect(find.text('Each action revises'), findsNothing);
    expect(find.text('Ranges, not one hand'), findsNothing);
    expect(find.text('Single combo'), findsOneWidget);
    expect(find.text('Possible set'), findsOneWidget);
    expect(find.text('Revise on action'), findsOneWidget);
    expect(find.text('Three range moves'), findsOneWidget);
    expect(find.text('Tap ONE HAND next'), findsNothing);
    expect(find.text('Tap One Hand, Range, and Update'), findsNothing);
    expect(find.text('Tap One Hand, Range, and Update.'), findsNothing);
    expect(
      find.text('Never one hand · know a range · then update'),
      findsNothing,
    );
    expect(
      find.text('One hand · range · update'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(RangeUpdateDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('ONE HAND'));
    await tester.pump();
    expect(find.text('Tap RANGE next'), findsNothing);
    await tester.tap(find.text('RANGE'));
    await tester.pump();
    expect(find.text('Tap UPDATE next'), findsNothing);
    await tester.tap(find.text('UPDATE'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Never one hand · know a range · then update'),
      findsNothing,
    );
    expect(
      find.text('One hand · range · update'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(RangeUpdateDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Defines both sides'), findsNothing);
    expect(find.text('Punish multiway flats'), findsNothing);
    expect(find.text('3-bets and squeezes'), findsNothing);
    expect(find.text('Shape both sides'), findsOneWidget);
    expect(find.text('Isolate the open'), findsOneWidget);
    expect(find.text('Three pot reopeners'), findsOneWidget);
    expect(find.text('Tap 3-BET next'), findsNothing);
    expect(find.text('Tap 3-Bet, Ranges, and Squeeze.'), findsNothing);
    expect(find.text('Tap 3-Bet, Ranges, and Squeeze'), findsNothing);
    expect(
      find.text('3-bets define ranges · squeezes punish flats'),
      findsNothing,
    );
    expect(
      find.text('3-bet · ranges · squeeze'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(ThreeBetSqueezeDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('3-BET'));
    await tester.pump();
    expect(find.text('Tap RANGES next'), findsNothing);
    await tester.tap(find.text('RANGES'));
    await tester.pump();
    expect(find.text('Tap SQUEEZE next'), findsNothing);
    await tester.tap(find.text('SQUEEZE'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('3-bets define ranges · squeezes punish flats'),
      findsNothing,
    );
    expect(
      find.text('3-bet · ranges · squeeze'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(ThreeBetSqueezeDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Choose with a plan'), findsNothing);
    expect(find.text('Know your next bet'), findsNothing);
    expect(find.text('Finish the story'), findsNothing);
    expect(find.text('Start the line'), findsOneWidget);
    expect(find.text('Next street ready'), findsOneWidget);
    expect(find.text('Close the line'), findsOneWidget);
    expect(find.text('Tap FLOP next'), findsNothing);
    expect(find.text('Tap Flop, Turn, and River.'), findsNothing);
    expect(find.text('Tap Flop, Turn, and River'), findsNothing);
    expect(
      find.text('Flop choice answers turn and river'),
      findsNothing,
    );
    expect(
      find.text('Flop · turn · river'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(MultiStreetPlanDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('FLOP'));
    await tester.pump();
    expect(find.text('Tap TURN next'), findsNothing);
    await tester.tap(find.text('TURN'));
    await tester.pump();
    expect(find.text('Tap RIVER next'), findsNothing);
    await tester.tap(find.text('RIVER'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Flop choice answers turn and river'),
      findsNothing,
    );
    expect(
      find.text('Flop · turn · river'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(MultiStreetPlanDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Three size stories'), findsOneWidget);
    expect(find.text('Size is language'), findsNothing);
    expect(find.text('Looks like value'), findsNothing);
    expect(find.text('Looks like pressure'), findsNothing);
    expect(find.text('Says which story'), findsNothing);
    expect(find.text('Get paid honestly'), findsOneWidget);
    expect(find.text('Force folds'), findsOneWidget);
    expect(find.text('Pick the story'), findsOneWidget);
    expect(find.text('Tap VALUE next'), findsNothing);
    expect(find.text('Tap Value, Pressure, and Size'), findsNothing);
    expect(find.text('Tap Value, Pressure, and Size.'), findsNothing);
    expect(
      find.text('Value looks like value · pressure looks like pressure'),
      findsNothing,
    );
    expect(
      find.text('Value · pressure · size'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(SizingLanguageDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('VALUE'));
    await tester.pump();
    expect(find.text('Tap PRESSURE next'), findsNothing);
    await tester.tap(find.text('PRESSURE'));
    await tester.pump();
    expect(find.text('Tap SIZE next'), findsNothing);
    await tester.tap(find.text('SIZE'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Value looks like value · pressure looks like pressure'),
      findsNothing,
    );
    expect(
      find.text('Value · pressure · size'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(SizingLanguageDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap SPR next'), findsNothing);
    expect(find.text('Tap SPR, Low, and High'), findsNothing);
    expect(find.text('Tap SPR, Low, and High.'), findsNothing);
    expect(find.text('Commit'), findsNothing);
    expect(find.text('Maneuver'), findsNothing);
    expect(find.text('Near stack-off'), findsOneWidget);
    expect(find.text('Room to play'), findsOneWidget);
    expect(
      find.text('Low SPR: commit · High SPR: maneuver'),
      findsNothing,
    );
    expect(
      find.text('SPR · low · high'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(SprDepthDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('SPR'));
    await tester.pump();
    expect(find.text('Tap LOW next'), findsNothing);
    await tester.tap(find.text('LOW'));
    await tester.pump();
    expect(find.text('Tap HIGH next'), findsNothing);
    await tester.tap(find.text('HIGH'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Low SPR: commit · High SPR: maneuver'),
      findsNothing,
    );
    expect(
      find.text('SPR · low · high'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(SprDepthDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap ENTERS next'), findsNothing);
    expect(find.text('Tap Enters, Calls, and Folds.'), findsNothing);
    expect(find.text('Tap Enters, Calls, and Folds'), findsNothing);
    // SoftPulse + Rex own the teach verb — no duplicate Watch… felt title.
    expect(find.text('Watch before you label'), findsNothing);
    expect(find.text('Observation notes'), findsOneWidget);
    expect(find.text('Who plays pots'), findsNothing);
    expect(find.text('Who sticks around'), findsNothing);
    expect(find.text('Who gives up'), findsNothing);
    expect(find.text('Pots joined'), findsOneWidget);
    expect(find.text('Sticks to bets'), findsOneWidget);
    expect(find.text('Leaves pots'), findsOneWidget);
    expect(find.text('Count samples before you tag'), findsNothing);
    expect(find.text('Enters · calls · folds'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    await tester.tap(find.text('ENTERS'));
    await tester.pump();
    expect(find.text('Tap CALLS next'), findsNothing);
    await tester.tap(find.text('CALLS'));
    await tester.pump();
    expect(find.text('Tap FOLDS next'), findsNothing);
    await tester.tap(find.text('FOLDS'));
    await tester.pump();
    expect(feltAck, 1);
    expect(find.text('Count samples before you tag'), findsNothing);
    expect(find.text('Enters · calls · folds'), findsOneWidget);
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
    expect(find.text('Tap STATION next'), findsNothing);
    expect(find.text('Tap Station, High, and Low.'), findsNothing);
    expect(find.text('Tap Station, High, and Low'), findsNothing);
    expect(find.text('Working model'), findsNothing);
    expect(find.text('Plays many pots'), findsNothing);
    expect(find.text('Rarely folds'), findsNothing);
    expect(find.text('Temp tag'), findsOneWidget);
    expect(find.text('Often in pots'), findsOneWidget);
    expect(find.text('Sticks to heat'), findsOneWidget);
    expect(
      find.text('High participation · low folding'),
      findsNothing,
    );
    expect(find.text('Station · high · low'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);

    await tester.tap(find.text('STATION'));
    await tester.pump();
    expect(find.text('Tap HIGH next'), findsNothing);
    await tester.tap(find.text('HIGH'));
    await tester.pump();
    expect(find.text('Tap LOW next'), findsNothing);
    await tester.tap(find.text('LOW'));
    await tester.pump();
    expect(feltAck, 1);
    expect(
      find.text('High participation · low folding'),
      findsNothing,
    );
    expect(find.text('Station · high · low'), findsOneWidget);
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
    expect(find.text('Three station plans'), findsOneWidget);
    expect(find.text('Versus Calling Stations'), findsNothing);
    expect(find.text('Tap VALUE next'), findsNothing);
    expect(find.text('Tap Value, Bluffs, and Cite'), findsNothing);
    expect(find.text('Tap Value, Bluffs, and Cite.'), findsNothing);
    expect(find.text('Thicker value'), findsNothing);
    expect(find.text('Fewer pure bluffs'), findsNothing);
    expect(find.text('Their calling'), findsNothing);
    expect(find.text('Get paid more'), findsOneWidget);
    expect(find.text('Cut thin air'), findsOneWidget);
    expect(find.text('Name the sample'), findsOneWidget);
    expect(
      find.text('Value wider · bluff less · cite calling'),
      findsNothing,
    );
    expect(find.text('Value · bluffs · cite'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(VsStationDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('VALUE'));
    await tester.pump();
    expect(find.text('Tap BLUFFS next'), findsNothing);
    await tester.tap(find.text('BLUFFS'));
    await tester.pump();
    expect(find.text('Tap CITE next'), findsNothing);
    await tester.tap(find.text('CITE'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Value wider · bluff less · cite calling'),
      findsNothing,
    );
    expect(
      find.text('Value · bluffs · cite'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(VsStationDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap RARE next'), findsNothing);
    expect(find.text('Tap Rare, Enter, and Mean It'), findsNothing);
    expect(find.text('Tap Rare, Enter, and Mean It.'), findsNothing);
    expect(
      find.text('Rare · enter · mean it'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(TightSeatsDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

await tester.tap(find.text('RARE'));
    await tester.pump();
    expect(find.text('Tap ENTER next'), findsNothing);
    await tester.tap(find.text('ENTER'));
    await tester.pump();
    expect(find.text('Tap MEAN IT next'), findsNothing);
    await tester.tap(find.text('MEAN IT'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Rare · enter · mean it'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(TightSeatsDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap NIT next'), findsNothing);
    expect(find.text('Tap Nit, Narrow, and Respect'), findsNothing);
    expect(find.text('Tap Nit, Narrow, and Respect.'), findsNothing);
    expect(
      find.text('Nit · narrow · respect'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(NitModelDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

await tester.tap(find.text('NIT'));
    await tester.pump();
    expect(find.text('Tap NARROW next'), findsNothing);
    await tester.tap(find.text('NARROW'));
    await tester.pump();
    expect(find.text('Tap RESPECT next'), findsNothing);
    await tester.tap(find.text('RESPECT'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Nit · narrow · respect'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(NitModelDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Three nit plans'), findsOneWidget);
    expect(find.text('Versus Nits'), findsNothing);
    expect(find.text('Tap STEAL next'), findsNothing);
    expect(find.text('Tap Steal, Credit, and Explode.'), findsNothing);
    expect(find.text('Tap Steal, Credit, and Explode'), findsNothing);
    expect(
      find.text('Steal · credit · explode'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(VsNitsDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('STEAL'));
    await tester.pump();
    expect(find.text('Tap CREDIT next'), findsNothing);
    await tester.tap(find.text('CREDIT'));
    await tester.pump();
    expect(find.text('Tap EXPLODE next'), findsNothing);
    await tester.tap(find.text('EXPLODE'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Steal · credit · explode'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(VsNitsDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Three aggressor marks'), findsOneWidget);
    expect(find.text('Extreme entry'), findsNothing);
    expect(find.text('Tap RAISE next'), findsNothing);
    expect(find.text('Tap Raise, Barrel, and Count.'), findsNothing);
    expect(find.text('Tap Raise, Barrel, and Count'), findsNothing);
    expect(find.text('Raise · barrel · count'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(ExtremeEntryDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('RAISE'));
    await tester.pump();
    expect(find.text('Tap BARREL next'), findsNothing);
    await tester.tap(find.text('BARREL'));
    await tester.pump();
    expect(find.text('Tap COUNT next'), findsNothing);
    await tester.tap(find.text('COUNT'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Raise · barrel · count'), findsOneWidget);
    expect(
      tester.getSize(find.byType(ExtremeEntryDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap MANIAC next'), findsNothing);
    expect(find.text('Tap Maniac, Entry, and Aggro.'), findsNothing);
    expect(find.text('Tap Maniac, Entry, and Aggro'), findsNothing);
    expect(
      find.text('Maniac · entry · aggro'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(ManiacModelDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('MANIAC'));
    await tester.pump();
    expect(find.text('Tap ENTRY next'), findsNothing);
    await tester.tap(find.text('ENTRY'));
    await tester.pump();
    expect(find.text('Tap AGGRO next'), findsNothing);
    await tester.tap(find.text('AGGRO'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Maniac · entry · aggro'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(ManiacModelDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Three maniac plans'), findsOneWidget);
    expect(find.text('Versus Maniacs'), findsNothing);
    expect(find.text('Tap WIDER next'), findsNothing);
    expect(find.text('Tap Wider, Hang, and Ego.'), findsNothing);
    expect(find.text('Tap Wider, Hang, and Ego'), findsNothing);
    expect(
      find.text('Wider · hang · ego'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(VsManiacsDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('WIDER'));
    await tester.pump();
    expect(find.text('Tap HANG next'), findsNothing);
    await tester.tap(find.text('HANG'));
    await tester.pump();
    expect(find.text('Tap EGO next'), findsNothing);
    await tester.tap(find.text('EGO'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Wider · hang · ego'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(VsManiacsDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Three confidence checks'), findsOneWidget);
    expect(find.text('Observation ≠ certainty'), findsNothing);
    expect(find.text('Tap OBSERVE next'), findsNothing);
    expect(find.text('Tap Observe, Samples, and Showdowns.'), findsNothing);
    expect(find.text('Tap Observe, Samples, and Showdowns'), findsNothing);
    expect(
      find.text('Observe · samples · showdowns'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(ObservationCertaintyDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('OBSERVE'));
    await tester.pump();
    expect(find.text('Tap SAMPLES next'), findsNothing);
    await tester.tap(find.text('SAMPLES'));
    await tester.pump();
    expect(find.text('Tap SHOWDOWNS next'), findsNothing);
    await tester.tap(find.text('SHOWDOWNS'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Observe · samples · showdowns'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(ObservationCertaintyDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap CARDS next'), findsNothing);
    expect(find.text('Tap Cards, Seats, and Evidence.'), findsNothing);
    expect(find.text('Tap Cards, Seats, and Evidence'), findsNothing);
    expect(
      find.text('Same cards · different seats · evidence'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(ExploitEvidenceDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('CARDS'));
    await tester.pump();
    expect(find.text('Tap SEATS next'), findsNothing);
    await tester.tap(find.text('SEATS'));
    await tester.pump();
    expect(find.text('Tap EVIDENCE next'), findsNothing);
    await tester.tap(find.text('EVIDENCE'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Same cards · different seats · evidence'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(ExploitEvidenceDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap NUTTED next'), findsNothing);
    expect(find.text('Tap Nutted, Air, and Domination.'), findsNothing);
    expect(find.text('Tap Nutted, Air, and Domination'), findsNothing);
    expect(
      find.text('Nutted · air · domination'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(MultiwayNutsDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('NUTTED'));
    await tester.pump();
    expect(find.text('Tap AIR next'), findsNothing);
    await tester.tap(find.text('AIR'));
    await tester.pump();
    expect(find.text('Tap DOMINATION next'), findsNothing);
    await tester.tap(find.text('DOMINATION'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Nutted · air · domination'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(MultiwayNutsDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap DEEP next'), findsNothing);
    expect(find.text('Tap Deep, Realize, and Stack.'), findsNothing);
    expect(find.text('Tap Deep, Realize, and Stack'), findsNothing);
    expect(find.text('Deep · realize · stack'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(DeepStacksDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('DEEP'));
    await tester.pump();
    expect(find.text('Tap REALIZE next'), findsNothing);
    await tester.tap(find.text('REALIZE'));
    await tester.pump();
    expect(find.text('Tap STACK next'), findsNothing);
    await tester.tap(find.text('STACK'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Deep · realize · stack'), findsOneWidget);
    expect(
      tester.getSize(find.byType(DeepStacksDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Three odds stories'), findsOneWidget);
    expect(find.text('Implied Odds'), findsNothing);
    expect(find.text('Tap IMPLIED next'), findsNothing);
    expect(find.text('Tap Implied, Reverse, and Second.'), findsNothing);
    expect(find.text('Tap Implied, Reverse, and Second'), findsNothing);
    expect(
      find.text('Implied · reverse · second'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(ImpliedOddsDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('IMPLIED'));
    await tester.pump();
    expect(find.text('Tap REVERSE next'), findsNothing);
    await tester.tap(find.text('REVERSE'));
    await tester.pump();
    expect(find.text('Tap SECOND next'), findsNothing);
    await tester.tap(find.text('SECOND'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Implied · reverse · second'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(ImpliedOddsDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Needs calls'), findsNothing);
    expect(find.text('Bluff-catches'), findsNothing);
    expect(find.text('Need wide barrels'), findsNothing);
    expect(find.text('Extract light'), findsOneWidget);
    expect(find.text('Hero call'), findsOneWidget);
    expect(find.text('Fire multi-street'), findsOneWidget);
    expect(find.text('Tap THIN next'), findsNothing);
    expect(find.text('Tap Thin, Catch, and Barrels.'), findsNothing);
    expect(find.text('Tap Thin, Catch, and Barrels'), findsNothing);
    expect(
      find.text('Thin value needs calls · catches need barrels'),
      findsNothing,
    );
    expect(
      find.text('Thin · catch · barrels'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(ThinValueDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('THIN'));
    await tester.pump();
    expect(find.text('Tap CATCH next'), findsNothing);
    await tester.tap(find.text('CATCH'));
    await tester.pump();
    expect(find.text('Tap BARRELS next'), findsNothing);
    await tester.tap(find.text('BARRELS'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Thin value needs calls · catches need barrels'),
      findsNothing,
    );
    expect(
      find.text('Thin · catch · barrels'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(ThinValueDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Four line updates'), findsOneWidget);
    expect(find.text('Lines mean ranges'), findsNothing);
    expect(find.text('Tap X/R next'), findsNothing);
    expect(find.text('Tap X/R, Probe, Delay, and Donk.'), findsNothing);
    expect(find.text('Tap X/R, Probe, Delay, and Donk'), findsNothing);
    expect(find.text('Each line updates the story'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(LineStoriesDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('X/R'));
    await tester.pump();
    expect(find.text('Tap PROBE next'), findsNothing);
    await tester.tap(find.text('PROBE'));
    await tester.pump();
    expect(find.text('Tap DELAY next'), findsNothing);
    await tester.tap(find.text('DELAY'));
    await tester.pump();
    expect(find.text('Tap DONK next'), findsNothing);
    await tester.tap(find.text('DONK'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Each line updates the story'), findsOneWidget);
    expect(
      tester.getSize(find.byType(LineStoriesDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap ACTION next'), findsNothing);
    expect(find.text('Tap Action, Rewrite, and Update.'), findsNothing);
    expect(find.text('Tap Action, Rewrite, and Update'), findsNothing);
    expect(find.text('Each action rewrites the range'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(RangeRewriteDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('ACTION'));
    await tester.pump();
    expect(find.text('Tap REWRITE next'), findsNothing);
    await tester.tap(find.text('REWRITE'));
    await tester.pump();
    expect(find.text('Tap UPDATE next'), findsNothing);
    await tester.tap(find.text('UPDATE'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Each action rewrites the range'), findsOneWidget);
    expect(
      tester.getSize(find.byType(RangeRewriteDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Three soft clues'), findsOneWidget);
    expect(find.text('Clues, not mind-reading'), findsNothing);
    expect(find.text('Tap TIMING next'), findsNothing);
    expect(find.text('Tap Timing, Sizing, and Clues.'), findsNothing);
    expect(find.text('Tap Timing, Sizing, and Clues'), findsNothing);
    expect(find.text('Small updates only'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(TimingCluesDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('TIMING'));
    await tester.pump();
    expect(find.text('Tap SIZING next'), findsNothing);
    await tester.tap(find.text('SIZING'));
    await tester.pump();
    expect(find.text('Tap CLUES next'), findsNothing);
    await tester.tap(find.text('CLUES'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Small updates only'), findsOneWidget);
    expect(
      tester.getSize(find.byType(TimingCluesDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Three table gears'), findsOneWidget);
    expect(find.text('Tables change'), findsNothing);
    expect(find.text('Tap STUCK next'), findsNothing);
    expect(find.text('Tap Stuck, Tilted, and Gears.'), findsNothing);
    expect(find.text('Tap Stuck, Tilted, and Gears'), findsNothing);
    expect(find.text('Update when the table shifts'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(TablesChangeDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('STUCK'));
    await tester.pump();
    expect(find.text('Tap TILTED next'), findsNothing);
    await tester.tap(find.text('TILTED'));
    await tester.pump();
    expect(find.text('Tap GEARS next'), findsNothing);
    await tester.tap(find.text('GEARS'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Update when the table shifts'), findsOneWidget);
    expect(
      tester.getSize(find.byType(TablesChangeDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap QUIT next'), findsNothing);
    expect(find.text('Tap Quit, Guard, and First.'), findsNothing);
    expect(find.text('Tap Quit, Guard, and First'), findsNothing);
    expect(find.text('Know when to quit'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight = tester.getSize(find.byType(GuardrailsDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('QUIT'));
    await tester.pump();
    expect(find.text('Tap GUARD next'), findsNothing);
    await tester.tap(find.text('GUARD'));
    await tester.pump();
    expect(find.text('Tap FIRST next'), findsNothing);
    await tester.tap(find.text('FIRST'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('Know when to quit'), findsOneWidget);
    expect(
      tester.getSize(find.byType(GuardrailsDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap RANGE next'), findsNothing);
    expect(find.text('Tap Range, Nut, and Advantage.'), findsNothing);
    expect(find.text('Tap Range, Nut, and Advantage'), findsNothing);
    expect(find.text('More strong hands overall'), findsNothing);
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(RangeAdvantageDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('RANGE'));
    await tester.pump();
    expect(find.text('Tap NUT next'), findsNothing);
    await tester.tap(find.text('NUT'));
    await tester.pump();
    expect(find.text('Tap ADVANTAGE next'), findsNothing);
    await tester.tap(find.text('ADVANTAGE'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(find.text('More strong hands overall'), findsOneWidget);
    expect(
      tester.getSize(find.byType(RangeAdvantageDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
      expect(find.text('Tap EQUITY next'), findsNothing);
      expect(find.text('Tap Equity, Cash, and Pos.'), findsNothing);
      expect(find.text('Tap Equity, Cash, and Pos'), findsNothing);
      expect(find.text('Position decides realization'), findsNothing);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight =
          tester.getSize(find.byType(EquityRealizeDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(
          tester.view.physicalSize.height /
              tester.view.devicePixelRatio *
              0.58,
          epsilon: 1,
        ),
      );

      await tester.tap(find.text('EQUITY'));
      await tester.pump();
      expect(find.text('Tap CASH next'), findsNothing);
      await tester.tap(find.text('CASH'));
      await tester.pump();
      expect(find.text('Tap POS next'), findsNothing);
      await tester.tap(find.text('POS'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(find.text('Position decides realization'), findsOneWidget);
      expect(
        tester.getSize(find.byType(EquityRealizeDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
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
      expect(find.text('Tap CAPPED next'), findsNothing);
      expect(find.text('Tap Capped, Uncapped, and Nuts.'), findsNothing);
      expect(find.text('Tap Capped, Uncapped, and Nuts'), findsNothing);
      expect(find.text('Nuts unlikely vs still live'), findsNothing);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight =
          tester.getSize(find.byType(CappedUncappedDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(
          tester.view.physicalSize.height /
              tester.view.devicePixelRatio *
              0.58,
          epsilon: 1,
        ),
      );

      await tester.tap(find.text('CAPPED'));
      await tester.pump();
      expect(find.text('Tap UNCAPPED next'), findsNothing);
      await tester.tap(find.text('UNCAPPED'));
      await tester.pump();
      expect(find.text('Tap NUTS next'), findsNothing);
      await tester.tap(find.text('NUTS'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(find.text('Nuts unlikely vs still live'), findsOneWidget);
      expect(
        tester.getSize(find.byType(CappedUncappedDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
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
      expect(find.text('Tap POLAR next'), findsNothing);
      expect(find.text('Tap Polar, Merged, and Size.'), findsNothing);
      expect(find.text('Tap Polar, Merged, and Size'), findsNothing);
      expect(find.text('Nuts/air vs medium-strong'), findsNothing);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight =
          tester.getSize(find.byType(PolarMergedDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(
          tester.view.physicalSize.height /
              tester.view.devicePixelRatio *
              0.58,
          epsilon: 1,
        ),
      );

      await tester.tap(find.text('POLAR'));
      await tester.pump();
      expect(find.text('Tap MERGED next'), findsNothing);
      await tester.tap(find.text('MERGED'));
      await tester.pump();
      expect(find.text('Tap SIZE next'), findsNothing);
      await tester.tap(find.text('SIZE'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(find.text('Nuts/air vs medium-strong'), findsOneWidget);
      expect(
        tester.getSize(find.byType(PolarMergedDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
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
      expect(find.text('Tap OVERBET next'), findsNothing);
      expect(find.text('Tap Overbet, Polar, and Geo.'), findsNothing);
      expect(find.text('Tap Overbet, Polar, and Geo'), findsNothing);
      expect(find.text('Polar story across streets'), findsNothing);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight =
          tester.getSize(find.byType(OverbetGeometryDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(
          tester.view.physicalSize.height /
              tester.view.devicePixelRatio *
              0.58,
          epsilon: 1,
        ),
      );

      await tester.tap(find.text('OVERBET'));
      await tester.pump();
      expect(find.text('Tap POLAR next'), findsNothing);
      await tester.tap(find.text('POLAR'));
      await tester.pump();
      expect(find.text('Tap GEO next'), findsNothing);
      await tester.tap(find.text('GEO'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(find.text('Polar story across streets'), findsOneWidget);
      expect(
        tester.getSize(find.byType(OverbetGeometryDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
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
      expect(find.text('Tap BLOCK next'), findsNothing);
      expect(find.text('Tap Block, Use, and No EV.'), findsNothing);
      expect(find.text('Tap Block, Use, and No EV'), findsNothing);
      expect(find.text('Remove hands — skip EV decimals'), findsNothing);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight = tester.getSize(find.byType(BlockersDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(
          tester.view.physicalSize.height /
              tester.view.devicePixelRatio *
              0.58,
          epsilon: 1,
        ),
      );

      await tester.tap(find.text('BLOCK'));
      await tester.pump();
      expect(find.text('Tap USE next'), findsNothing);
      await tester.tap(find.text('USE'));
      await tester.pump();
      expect(find.text('Tap NO EV next'), findsNothing);
      await tester.tap(find.text('NO EV'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(find.text('Remove hands — skip EV decimals'), findsOneWidget);
      expect(
        tester.getSize(find.byType(BlockersDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
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
    expect(find.text('Value up'), findsNothing);
    expect(find.text('Bluffs down'), findsNothing);
    expect(find.text('Not second-best'), findsNothing);
    expect(find.text('Tighten value'), findsOneWidget);
    expect(find.text('Cut air'), findsOneWidget);
    expect(find.text('Chase the top'), findsOneWidget);
    expect(find.text('Tap STRONGER next'), findsNothing);
    expect(find.text('Tap Stronger, Fewer, and Nuts.'), findsNothing);
    expect(find.text('Tap Stronger, Fewer, and Nuts'), findsNothing);
    expect(
      find.text('Stronger value · fewer bluffs · chase nuts'),
      findsNothing,
    );
    expect(
      find.text('Stronger · fewer · nuts'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(MultiwayPlanDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('STRONGER'));
    await tester.pump();
    expect(find.text('Tap FEWER next'), findsNothing);
    await tester.tap(find.text('FEWER'));
    await tester.pump();
    expect(find.text('Tap NUTS next'), findsNothing);
    await tester.tap(find.text('NUTS'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Stronger value · fewer bluffs · chase nuts'),
      findsNothing,
    );
    expect(
      find.text('Stronger · fewer · nuts'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(MultiwayPlanDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
      expect(find.text('Tap DEFEND next'), findsNothing);
      expect(find.text('Tap Defend, Bluff, and Enough.'), findsNothing);
      expect(find.text('Tap Defend, Bluff, and Enough'), findsNothing);
      expect(find.text('Defend better hands — skip fake %'), findsNothing);
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight =
          tester.getSize(find.byType(DefendEnoughDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(
          tester.view.physicalSize.height /
              tester.view.devicePixelRatio *
              0.58,
          epsilon: 1,
        ),
      );

      await tester.tap(find.text('DEFEND'));
      await tester.pump();
      expect(find.text('Tap BLUFF next'), findsNothing);
      await tester.tap(find.text('BLUFF'));
      await tester.pump();
      expect(find.text('Tap ENOUGH next'), findsNothing);
      await tester.tap(find.text('ENOUGH'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(find.text('Defend better hands — skip fake %'), findsOneWidget);
      expect(
        tester.getSize(find.byType(DefendEnoughDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
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
      expect(find.text('Tap MIX next'), findsNothing);
      expect(find.text('Tap Mix, Purpose, and Strong.'), findsNothing);
      expect(find.text('Tap Mix, Purpose, and Strong'), findsNothing);
      expect(
        find.text('Frequency with a purpose — not coin-flip'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight =
          tester.getSize(find.byType(MixedStrategyDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(
          tester.view.physicalSize.height /
              tester.view.devicePixelRatio *
              0.58,
          epsilon: 1,
        ),
      );

      await tester.tap(find.text('MIX'));
      await tester.pump();
      expect(find.text('Tap PURPOSE next'), findsNothing);
      await tester.tap(find.text('PURPOSE'));
      await tester.pump();
      expect(find.text('Tap STRONG next'), findsNothing);
      await tester.tap(find.text('STRONG'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(
        find.text('Frequency with a purpose — not coin-flip'),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(MixedStrategyDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
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
      expect(find.text('Tap 3BET next'), findsNothing);
      expect(find.text('Tap 3-Bet, 4-Bet, and Depth.'), findsNothing);
      expect(find.text('Tap 3-Bet, 4-Bet, and Depth'), findsNothing);
      expect(
        find.text('Raised pots shrink ranges — depth decides commitment'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight =
          tester.getSize(find.byType(ThreeBetFourBetSprDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(
          tester.view.physicalSize.height /
              tester.view.devicePixelRatio *
              0.58,
          epsilon: 1,
        ),
      );

      await tester.tap(find.text('3BET'));
      await tester.pump();
      expect(find.text('Tap 4BET next'), findsNothing);
      await tester.tap(find.text('4BET'));
      await tester.pump();
      expect(find.text('Tap DEPTH next'), findsNothing);
      await tester.tap(find.text('DEPTH'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(
        find.text('Raised pots shrink ranges — depth decides commitment'),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(ThreeBetFourBetSprDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
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
      expect(find.text('Tap HARD next'), findsNothing);
      expect(find.text('Tap Hard, Cooler, and Ego.'), findsNothing);
      expect(find.text('Tap Hard, Cooler, and Ego'), findsNothing);
      expect(
        find.text('Hard folds save buy-ins — skip ego call-downs'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('HARD'));
      await tester.pump();
      expect(find.text('Tap COOLER next'), findsNothing);
      await tester.tap(find.text('COOLER'));
      await tester.pump();
      expect(find.text('Tap EGO next'), findsNothing);
      await tester.tap(find.text('EGO'));
      await tester.pump();
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
      expect(find.text('Tap TIGHT next'), findsNothing);
      expect(find.text('Tap Tight, Barrel, and Sample.'), findsNothing);
      expect(find.text('Tap Tight, Barrel, and Sample'), findsNothing);
      expect(
        find.text('Tight entry, then barrels with a plan — count samples'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('TIGHT'));
      await tester.pump();
      expect(find.text('Tap BARREL next'), findsNothing);
      await tester.tap(find.text('BARREL'));
      await tester.pump();
      expect(find.text('Tap SAMPLE next'), findsNothing);
      await tester.tap(find.text('SAMPLE'));
      await tester.pump();
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
      expect(find.text('Tap TIGHT next'), findsNothing);
      expect(find.text('Tap Tight, Aggro, and Model.'), findsNothing);
      expect(find.text('Tap Tight, Aggro, and Model'), findsNothing);
      expect(
        find.text('Tight in, aggressive after — a working model'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('TIGHT'));
      await tester.pump();
      expect(find.text('Tap AGGRO next'), findsNothing);
      await tester.tap(find.text('AGGRO'));
      await tester.pump();
      expect(find.text('Tap MODEL next'), findsNothing);
      await tester.tap(find.text('MODEL'));
      await tester.pump();
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

    expect(find.text('Nobody else can peek at your holes.'), findsOneWidget);
    // Felt-first: Rex owns the teach line — no duplicate prompt/footer.
    expect(find.text('Tap the cards only you can see.'), findsNothing);
    expect(find.text('Tap the answer on the table.'), findsNothing);
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

  testWidgets('guided find-holes SoftPulse densifies multi-rail felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-01-guided-find-holes',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the two private hole cards in front of you.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap your hole cards on the table.',
      choices: const [
        CourseChoice(id: 'choice-hero-holes', label: 'Ah Kd in front of you'),
        CourseChoice(id: 'choice-board', label: 'The flop cards in the middle'),
        CourseChoice(
          id: 'choice-villain',
          label: 'Face-down cards at another seat',
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
    expect(find.text('Tap your cards'), findsOneWidget);
    expect(find.text('Tap your hole cards on the table.'), findsNothing);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('hole-cards-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
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

    expect(find.text('Find the dealer button on the felt.'), findsOneWidget);
    // Felt-first: Rex + SoftPulse own the cue — no prompt / invite / footer stack.
    expect(find.text('Tap the dealer button on the table.'), findsNothing);
    expect(find.text('Tap the dealer button'), findsNothing);
    expect(find.text('Tap the answer on the table.'), findsNothing);
    // Guided finds the D chip — not the SoftPulse clockwise teach line.
    expect(
      find.text('Clockwise: button → small blind → big blind'),
      findsNothing,
    );
    expect(find.text('Dealer button — D chip'), findsOneWidget);
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
    expect(find.text('Postflop closes on the button. Tap BTN.'), findsNothing);
    expect(find.text('Tap on the felt.'), findsOneWidget);
    expect(find.text('Tap the answer on the table.'), findsNothing);
    expect(find.text('Six-max · postflop'), findsOneWidget);
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
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('blinds-timing-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    await tester.tap(find.text('Before deal'));
    await tester.pump();
    expect(controller.draft.choiceId, 'before-deal');
    // Densified shell stays filled through Checking…
    expect(
      tester.getSize(find.byKey(const ValueKey('blinds-timing-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
      isNull,
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
      )?.highlight,
      LessonTableHighlight.none,
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
          id: 'act-01-05-01-unguided-pot',
          order: 4,
          stage: ActivityStage.unguided,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'pot size',
          acceptedGrades: const [SoftGrade.recommended],
          choices: const [
            CourseChoice(id: 'pot-9', label: '9 chips'),
          ],
        ),
      )?.villainSeatCount,
      0,
    );
    expect(
      resolveLessonTableScene(
        CourseActivity(
          id: 'act-01-05-01-checkpoint-side',
          order: 5,
          stage: ActivityStage.checkpoint,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'side pot',
          acceptedGrades: const [SoftGrade.recommended],
          choices: const [
            CourseChoice(id: 'side-exists', label: 'Side pot'),
          ],
        ),
      )?.villainSeatCount,
      0,
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
        activityId: 'act-01-06-01-guided-steps',
        stepId: 'step-01-06-flop',
      )?.feltStatusLine,
      'Uncontested — stack the chips',
    );
    expect(
      resolveToyHandStepSpot(
        activityId: 'act-01-06-01-scaffolded-multi',
        stepId: 'step-01-06-bb-defend',
      )?.feltStatusLine,
      'Call keeps the hand alive',
    );
    expect(
      resolveToyHandStepSpot(
        activityId: 'act-01-06-01-scaffolded-multi',
        stepId: 'step-01-06-flop-cbet',
      )?.boardCodes,
      ['As', '7c', '2d'],
    );
    expect(
      resolveToyHandStepSpot(
        activityId: 'act-01-06-01-scaffolded-multi',
        stepId: 'step-01-06-flop-cbet',
      )?.feltStatusLine,
      'Top pair — bet for value',
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
      )?.feltStatusLine,
      '4 more chips to call the open',
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
      isSeatOrderSequenceActivity(
        CourseActivity(
          id: 'act-02-01-02-guided-pre',
          order: 2,
          stage: ActivityStage.guided,
          renderer: ActivityRenderer.orderSequence,
          estimatedSeconds: 40,
          accessibilityText: 'preflop order',
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
      resolveLessonTableScene(
        CourseActivity(
          id: 'act-02-01-01-scaffolded-blinds',
          order: 3,
          stage: ActivityStage.scaffolded,
          renderer: ActivityRenderer.selectIdentify,
          estimatedSeconds: 40,
          accessibilityText: 'forced',
          acceptedGrades: const [SoftGrade.recommended],
          prompt: 'Tap a seat that posts a forced bet every hand.',
          choices: const [
            CourseChoice(id: 'sb-bb', label: 'SB or BB'),
            CourseChoice(id: 'btn-bb', label: 'BTN'),
            CourseChoice(id: 'ep-only', label: 'EP'),
          ],
        ),
      )?.quietBlindPostCaptions,
      isTrue,
    );
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
    expect(find.text('Tap suits to build your answer.'), findsNothing);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('suit-tap-picker-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    // Densified tiles fill the felt — not the old 64×76 chips.
    final tileSize = tester.getSize(find.byType(SuitTapTile).first);
    expect(tileSize.height, greaterThan(90));
    expect(tileSize.width, greaterThan(60));

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
    // Densified shell stays filled through Checking…
    expect(
      tester.getSize(find.byKey(const ValueKey('suit-tap-picker-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
      find.text('1 of 4 real suits — skip decoys.'),
      findsOneWidget,
    );

    // Simulate lesson resume onto a fresh controller bind of the same step.
    controller.bindActivity(guided);
    await tester.pump();
    expect(controller.draft.choiceId, isNull);
    // Rex owns empty-state cue — no duplicate footer after resume.
    expect(find.text('Tap suits to build your answer.'), findsNothing);
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
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('hole-card-felt-tray')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;
    await tester.tap(find.byType(HoleCardChoiceButton).first);
    await tester.pump();
    expect(controller.draft.choiceId, 'suited-ah-kh');
    expect(autoSubmits, 1);
    // Densified shell stays filled through Checking…
    expect(
      tester.getSize(find.byKey(const ValueKey('hole-card-felt-tray'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Tap the streets from first to last.'), findsOneWidget);
    expect(find.text('Build order here'), findsOneWidget);
    expect(find.text('Tap streets below first → last'), findsNothing);
    expect(find.text('Tap next'), findsNothing);
    expect(find.byKey(const ValueKey('street-order-felt')), findsOneWidget);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('street-order-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    // SoftPulse the chronological next street — Preflop first, not Flop.
    expect(controller.draft.orderedIds, isEmpty);
    await tester.tap(find.text('PREFLOP'));
    await tester.pump();
    expect(controller.draft.orderedIds, ['st-pre']);
    // Mid-build: 3 leftovers — lone TURN centers under FLOP/RIVER (no empty void).
    final flopCenter = tester.getCenter(find.text('FLOP'));
    final riverCenter = tester.getCenter(find.text('RIVER'));
    final turnCenter = tester.getCenter(find.text('TURN'));
    expect(
      turnCenter.dx,
      moreOrLessEquals((flopCenter.dx + riverCenter.dx) / 2, epsilon: 24),
    );
    await tester.tap(find.text('FLOP'));
    await tester.pump();
    expect(controller.draft.orderedIds, ['st-pre', 'st-flop']);
    await tester.tap(find.text('TURN'));
    await tester.pump();
    await tester.tap(find.text('RIVER'));
    await tester.pump();
    expect(controller.draft.orderedIds, [
      'st-pre',
      'st-flop',
      'st-turn',
      'st-river',
    ]);
    expect(
      tester.getSize(find.byKey(const ValueKey('street-order-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'a1',
        activityId: activity.id,
        grade: SoftGrade.recommended,
        feedback: 'Preflop → flop → turn → river.',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'a1',
          lessonId: 'lesson-01-04-01-streets-and-order',
          activityId: 'act-01-04-01-guided-streets',
          activityIndex: 1,
        ),
        duplicate: false,
      ),
    );
    await tester.pump();
    expect(find.text('Tap the streets from first to last.'), findsNothing);
    expect(find.text('Checking…'), findsNothing);
    controller.dispose();
  });

  testWidgets('seat order densifies SoftPulse felt on tall phones', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-04-01-scaffolded-order',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.orderSequence,
      estimatedSeconds: 40,
      accessibilityText: 'Tap seats in the order they act.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap seats in the order they act.',
      sequenceItems: const [
        CourseChoice(id: 'utg', label: 'UTG'),
        CourseChoice(id: 'hj', label: 'HJ'),
        CourseChoice(id: 'btn', label: 'BTN'),
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
    expect(find.byKey(const ValueKey('seat-order-felt')), findsOneWidget);
    expect(find.text('UTG'), findsWidgets);
    expect(find.text('HJ'), findsWidgets);
    expect(find.text('BTN'), findsWidgets);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('seat-order-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    // Densify chips are larger than the compact 96px seat tiles.
    final utgTile = tester.getSize(find.text('Early').first);
    expect(utgTile.width, greaterThanOrEqualTo(50));
    await tester.tap(find.text('UTG').first);
    await tester.pump();
    expect(controller.draft.orderedIds, ['utg']);
    expect(
      tester.getSize(find.byKey(const ValueKey('seat-order-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('jump ranks keeps Rex felt-first and quiets tray/status', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-06-02-jump-ranks',
      order: 1,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.compareRank,
      estimatedSeconds: 40,
      accessibilityText: 'Jump test: tap strongest hand first, then weaker.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap strongest hand first, then weaker.',
      sequenceItems: const [
        CourseChoice(id: 'j-flush', label: 'Flush'),
        CourseChoice(id: 'j-straight', label: 'Straight'),
        CourseChoice(id: 'j-two', label: 'Two pair'),
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
    expect(find.text('Tap strongest hand first, then weaker.'), findsOneWidget);
    expect(find.textContaining('straight, two pair, flush'), findsNothing);
    // Numbered destination slots teach order — not an empty tray blob.
    expect(find.text('1 · Strongest'), findsOneWidget);
    expect(find.text('3 · Weakest'), findsOneWidget);
    expect(find.text('Build order here'), findsNothing);
    expect(find.text('Your order (empty)'), findsNothing);
    expect(find.text('Tap strongest first'), findsNothing);
    expect(find.text('Tap strong → weak'), findsNothing);
    // SoftPulse + Rex own the cue — no Tap to place / Tap LABEL stack.
    expect(find.text('Tap to place'), findsNothing);
    expect(find.text('Tap Flush'), findsNothing);
    expect(find.text('Flush'), findsOneWidget);
    expect(find.text('Straight'), findsOneWidget);
    expect(find.text('Two pair'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('unguided hand compare hides Tap to place under Rex', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-02-01-unguided-compare',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.compareRank,
      estimatedSeconds: 40,
      accessibilityText: 'Tap strongest to weakest',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap strongest to weakest.',
      sequenceItems: const [
        CourseChoice(id: 'hr-trips', label: 'Three of a kind'),
        CourseChoice(id: 'hr-full', label: 'Full house'),
        CourseChoice(id: 'hr-two', label: 'Two pair'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        OrderSequenceActivity(
          activity: activity,
          controller: controller,
          showGuidance: false,
        ),
      ),
    );
    expect(find.text('Tap strongest to weakest.'), findsOneWidget);
    expect(find.text('Tap to place'), findsNothing);
    expect(find.byKey(const ValueKey('hand-order-felt')), findsOneWidget);
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
    expect(find.text('Betting is live. Tap when this street is done.'), findsOneWidget);
    // Felt-first: authored prompt dump stays off when Rex already coaches.
    expect(
      find.text('Flop betting is live. Tap when this street ends.'),
      findsNothing,
    );
    expect(find.text('Bets matched'), findsWidgets);
    expect(find.byKey(const ValueKey('street-end-felt')), findsOneWidget);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('street-end-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    await tester.tap(find.text('Bets matched').first);
    await tester.pump();
    expect(controller.draft.choiceId, 'matched');
    // Densified shell stays filled after the tap.
    expect(
      tester.getSize(find.byKey(const ValueKey('street-end-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('postflop checkpoint densifies blinds seats without SoftPulse', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-04-01-checkpoint-postflop',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'postflop',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Postflop — tap who acts first.',
      choices: const [
        CourseChoice(id: 'sb-first', label: 'SB'),
        CourseChoice(id: 'btn-first', label: 'BTN'),
        CourseChoice(id: 'bb-first-always', label: 'BB'),
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
    expect(find.text('Postflop — tap who acts first.'), findsOneWidget);
    expect(find.byKey(const ValueKey('blinds-seats-felt')), findsOneWidget);
    // Checkpoint must not SoftPulse the answer.
    expect(find.text('Tap the small blind'), findsNothing);
    expect(find.text('Tap the dealer button'), findsNothing);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('blinds-seats-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    await tester.tap(find.text('1').first);
    await tester.pump();
    expect(controller.draft.choiceId, 'sb-first');
    expect(
      tester.getSize(find.byKey(const ValueKey('blinds-seats-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    // Graded/locked clears onRegionTap — densify must still hold for Continue.
    controller.finishSubmit(
      SubmitCourseStepResult(
        attemptId: 'a1',
        activityId: activity.id,
        grade: SoftGrade.recommended,
        feedback: 'Postflop starts left of the button.',
        accepted: true,
        lifeLost: false,
        livesRemaining: 3,
        xpAwarded: 10,
        remediationRequired: false,
        resume: const CourseResumePointer(
          attemptId: 'a1',
          lessonId: 'lesson-01-04-01-streets-and-order',
          activityId: 'act-01-04-01-checkpoint-postflop',
          activityIndex: 4,
        ),
        duplicate: false,
      ),
    );
    await tester.pump();
    expect(
      tester.getSize(find.byKey(const ValueKey('blinds-seats-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(
      find.text('Button toy hand — open, then see if it ends.'),
      findsOneWidget,
    );
    // Felt already shows holes / villain — no A9s prompt dump.
    expect(find.text('Button with A9s. Folds to you.'), findsNothing);
    expect(find.text('RAISE TO 6'), findsOneWidget);
    await tester.tap(find.text('RAISE TO 6'));
    await tester.pump();
    expect(controller.draft.choiceId, 'open-6');
    controller.dispose();
  });

  testWidgets('toy hand checkpoint drops dock tap footer under Rex', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-06-01-checkpoint-finish',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'checkpoint',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-01-06-cp-open',
          street: 'preflop',
          prompt: 'Button with KQo. CO folds.',
          choices: [
            CourseChoice(id: 'open-kq', label: 'Raise to 6', action: 'RAISE'),
            CourseChoice(id: 'fold-kq', label: 'Fold', action: 'FOLD'),
            CourseChoice(id: 'limp-kq', label: 'Limp', action: 'CALL'),
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
          showGuidance: false,
        ),
      ),
    );
    expect(
      find.text('Finish a short button hand without freezing.'),
      findsOneWidget,
    );
    // Rex owns the cue — no third Tap your action on the dock. footer.
    expect(find.text('Tap your action on the dock.'), findsNothing);
    expect(find.text('What happened? Tap below.'), findsNothing);
    expect(find.text('RAISE TO 6'), findsOneWidget);
    await tester.tap(find.text('RAISE TO 6'));
    await tester.pump();
    expect(controller.draft.choiceId, 'open-kq');
    controller.dispose();
  });

  testWidgets('jump check legal docks Check live so identify is not spoiled', (
    tester,
  ) async {
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
    expect(find.text('CHECK (off)'), findsNothing);
    expect(find.text('CHECK'), findsOneWidget);
    await tester.tap(find.text('CHECK'));
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
    expect(find.text('Everyone folded. Tap how you take the pot.'), findsOneWidget);
    expect(
      find.text('You bet. Everyone folds. Tap how you take the pot.'),
      findsNothing,
    );
    // SoftPulse Take pot; Rex owns the teach line — no footer cue stack.
    expect(find.text('Tap your answer on the felt.'), findsNothing);
    expect(find.text('Tap on the felt.'), findsNothing);
    expect(find.text('Take pot'), findsWidgets);
    expect(find.text('Must show'), findsWidgets);
    expect(find.text('Dealer shows'), findsWidgets);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('outcome-phases-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    await tester.tap(find.text('Take pot').first);
    await tester.pump();
    expect(controller.draft.choiceId, 'no-show');
    controller.dispose();
  });

  testWidgets('how pots unguided pot densifies without decoy Them', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-05-01-unguided-pot',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'pot size',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Blinds 1/2. BTN opens to 6. Tap the pot before blinds act.',
      choices: const [
        CourseChoice(id: 'pot-9', label: '9 chips'),
        CourseChoice(id: 'pot-7', label: '7 chips'),
        CourseChoice(id: 'pot-12', label: '12 chips'),
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
    expect(
      find.text('Blinds plus the open — tap the chip total.'),
      findsOneWidget,
    );
    // No decoy face-down villain — chip tiles own the felt.
    expect(find.text('Them'), findsNothing);
    expect(find.text('9 chips'), findsWidgets);
    expect(find.text('Tap your answer on the felt.'), findsNothing);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('outcome-phases-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    await tester.tap(find.text('9 chips').first);
    await tester.pump();
    expect(controller.draft.choiceId, 'pot-9');
    controller.dispose();
  });

  testWidgets('baseline habit checkpoint taps Cover + wait on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-07-01-checkpoint-habit',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Protect cards and wait for action on a full ring.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Full ring. Action two seats left. Your cards are uncovered. Fix?',
      choices: const [
        CourseChoice(
          id: 'cover-wait',
          label: 'Cover your cards and wait your turn',
        ),
        CourseChoice(
          id: 'act-now',
          label: 'Announce fold immediately to speed up',
        ),
        CourseChoice(
          id: 'leave-cards',
          label: 'Leave cards bare so the table can see you are folding',
        ),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.habitCoverOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.habitCoverWait,
        choices: activity.choices,
      ),
      'cover-wait',
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
      find.text('Cards uncovered and action left — tap the safe habit.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Full ring. Action two seats left. Your cards are uncovered. Fix?',
      ),
      findsNothing,
    );
    expect(
      find.text('Cover your cards and wait your turn'),
      findsNothing,
    );
    expect(find.text('Cover + wait'), findsOneWidget);
    expect(find.text('Act early'), findsOneWidget);
    expect(find.text('Leave bare'), findsOneWidget);
    await tester.tap(find.text('Cover + wait'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cover-wait');
    controller.dispose();
  });

  testWidgets('section jump pos taps CO seat on position felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-02-07-02-jump-pos',
      order: 1,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 35,
      accessibilityText: 'Jump test: cutoff label.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Seat right before the button?',
      choices: const [
        CourseChoice(id: 'j2-co', label: 'Cutoff'),
        CourseChoice(id: 'j2-hj', label: 'Hijack'),
        CourseChoice(id: 'j2-sb', label: 'Small blind'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.positionLabels,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.cutoff,
        choices: activity.choices,
      ),
      'j2-co',
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
      find.text('Tap the seat right before the button.'),
      findsOneWidget,
    );
    expect(find.text('Seat right before the button?'), findsNothing);
    // Structural felt caption — no Rex “before the button” echo.
    expect(find.text('Six-max · before the button'), findsNothing);
    expect(find.text('Six-max · seat map'), findsOneWidget);
    expect(find.text('Cutoff'), findsNothing);
    expect(find.text('CO'), findsOneWidget);
    // Tall-phone densify — fill navy void under the seat grid.
    expect(
      tester.getSize(find.byKey(const ValueKey('position-labels-felt'))).height,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    await tester.tap(find.text('CO'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j2-co');
    controller.dispose();
  });

  testWidgets('section jump family taps Suited ace on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-07-02-jump-family',
      order: 2,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 35,
      accessibilityText: 'Jump test: suited ace family.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Ah 5h belongs to which family?',
      choices: const [
        CourseChoice(id: 'j2-sa', label: 'Suited ace'),
        CourseChoice(id: 'j2-pair', label: 'Pocket pair'),
        CourseChoice(id: 'j2-trash', label: 'Offsuit trash'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.jumpFamilyOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.heroCodes, ['Ah', '5h']);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.jumpFamilySuitedAce,
        choices: activity.choices,
      ),
      'j2-sa',
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
      find.text('Look at your holes — tap the family they belong to.'),
      findsOneWidget,
    );
    expect(find.text('Ah 5h belongs to which family?'), findsNothing);
    expect(find.text('Suited ace'), findsOneWidget);
    expect(find.text('Pocket pair'), findsOneWidget);
    expect(find.text('Offsuit trash'), findsOneWidget);
    // Suited-ace tile uses an example (As9s), not hero Ah5h — no visual spoil.
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is MiniCard &&
            w.card.code.toLowerCase() == 'as' &&
            w.size == MiniCardSize.tiny,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is MiniCard &&
            w.card.code.toLowerCase() == '5h' &&
            w.size == MiniCardSize.tiny,
      ),
      findsNothing,
    );
    await tester.tap(find.text('Suited ace'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j2-sa');
    controller.dispose();
  });

  testWidgets('section jump stack taps 55bb effective on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-02-07-02-jump-stack',
      order: 5,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 35,
      accessibilityText: 'Jump test: effective stack is 55bb.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You 120bb, villain 55bb. Effective stack?',
      choices: const [
        CourseChoice(id: 'j2-55', label: '55bb'),
        CourseChoice(id: 'j2-120', label: '120bb'),
        CourseChoice(id: 'j2-175', label: '175bb'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.effectiveStackOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.effectiveStackShort,
        choices: activity.choices,
      ),
      'j2-55',
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
      find.text('You 120bb · villain 55bb — tap effective.'),
      findsOneWidget,
    );
    expect(
      find.text('Effective stack is the shorter one — tap it.'),
      findsNothing,
    );
    expect(
      find.text('You 120bb, villain 55bb. Effective stack?'),
      findsNothing,
    );
    expect(find.text('55bb'), findsOneWidget);
    expect(find.text('Shorter'), findsNothing);
    expect(find.text('Villain'), findsOneWidget);
    // Jump stage: SoftPulse off — no spoiler cue / gold tip.
    expect(find.text('Tap 55bb.'), findsNothing);
    expect(find.text('Tap your answer on the felt.'), findsNothing);
    await tester.tap(find.text('55bb'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j2-55');
    controller.dispose();
  });

  testWidgets('s2 scaffolded eff SoftPulse guides only 60bb', (tester) async {
    final activity = CourseActivity(
      id: 'act-02-05-01-scaffolded-eff',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Choose the shorter stack as effective.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You have 150bb. Villain has 60bb. Effective stack?',
      choices: const [
        CourseChoice(id: 'eff-60', label: '60bb'),
        CourseChoice(id: 'eff-150', label: '150bb'),
        CourseChoice(id: 'eff-210', label: '210bb'),
      ],
    );
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.effectiveStack150Outcomes,
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
      find.text('You 150bb, villain 60bb — tap the effective stack.'),
      findsOneWidget,
    );
    // SoftPulse + Rex own the cue — no Tap 60bb footer mid-teach.
    expect(find.text('Tap 60bb.'), findsNothing);
    expect(find.text('Tap your answer on the felt.'), findsNothing);
    await tester.tap(find.text('60bb'));
    await tester.pump();
    expect(controller.draft.choiceId, 'eff-60');
    controller.dispose();
  });

  testWidgets('s2 unguided depth hides shove spoiler captions', (tester) async {
    final activity = CourseActivity(
      id: 'act-02-05-01-unguided-depth',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Identify 50bb as shallower than 100 or 200.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Which depth plays closest to a short-stack shove game?',
      choices: const [
        CourseChoice(id: 'depth-50', label: '50bb'),
        CourseChoice(id: 'depth-100', label: '100bb'),
        CourseChoice(id: 'depth-200', label: '200bb'),
      ],
    );
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.stackDepthOutcomes,
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
      find.text('Tap the depth that plays closest to a shove game.'),
      findsOneWidget,
    );
    // Felt + tile captions stay structural — no Rex / answer echo.
    expect(find.text('Which depth plays like a shove game?'), findsNothing);
    expect(find.text('Shove game'), findsNothing);
    expect(find.text('Common live depths'), findsOneWidget);
    expect(find.text('Short'), findsOneWidget);
    await tester.tap(find.text('50bb'));
    await tester.pump();
    expect(controller.draft.choiceId, 'depth-50');
    controller.dispose();
  });

  testWidgets('s3 table-read guided taps 21-chip pot on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-03-01-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Add blinds plus three contributions to size the pot.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Blinds 1/2. UTG opens to 6, BTN calls, BB calls. Pot now?',
      choices: const [
        CourseChoice(id: 'pot-21', label: '21'),
        CourseChoice(id: 'pot-18', label: '18'),
        CourseChoice(id: 'pot-12', label: '12'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.potMultiwayOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.potChipsTwentyOne,
        choices: activity.choices,
      ),
      'pot-21',
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
      find.text('Blinds plus three 6s — tap the pot total.'),
      findsOneWidget,
    );
    expect(
      find.text('Blinds 1/2. UTG opens to 6, BTN calls, BB calls. Pot now?'),
      findsNothing,
    );
    expect(find.text('21 chips'), findsOneWidget);
    // SoftPulse must not spoil the pot math / gold-tip the answer.
    expect(find.text('1+2+6+6+6'), findsNothing);
    expect(find.text('Full pot'), findsOneWidget);
    await tester.tap(find.text('21 chips'));
    await tester.pump();
    expect(controller.draft.choiceId, 'pot-21');
    controller.dispose();
  });

  testWidgets('s3 table-read scaffolded taps UTG seat on nine-handed felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-01-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Find UTG left of the big blind.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Nine-handed. Dealer button is on seat 7. Who acts first preflop?',
      choices: const [
        CourseChoice(id: 'utg-first', label: 'Seat left of the big blind (UTG)'),
        CourseChoice(id: 'btn-first', label: 'The button'),
        CourseChoice(id: 'sb-first', label: 'Small blind'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.positionLabels,
    );
    expect(resolveLessonTableScene(activity)?.seatCount, 9);
    expect(resolveLessonTableScene(activity)?.buttonSeat, 7);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.earlyPosition,
        choices: activity.choices,
      ),
      'utg-first',
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
      find.text('Preflop — tap who acts first (left of the BB).'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Nine-handed. Dealer button is on seat 7. Who acts first preflop?',
      ),
      findsNothing,
    );
    // Felt caption is structural — Rex owns the SoftPulse teach verb.
    expect(find.text('Nine-handed · button seat 7'), findsOneWidget);
    expect(
      find.text('Nine-handed · button seat 7 · tap who opens'),
      findsNothing,
    );
    expect(find.text('Seat left of the big blind (UTG)'), findsNothing);
    expect(find.text('UTG'), findsOneWidget);
    expect(find.text('EP'), findsOneWidget);
    await tester.tap(find.text('UTG'));
    await tester.pump();
    expect(controller.draft.choiceId, 'utg-first');
    controller.dispose();
  });

  testWidgets('s3 table-read unguided taps Raise stands on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-01-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Verbal raise binds at a live table.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You say "raise" then try to take it back to a call. Result?',
      choices: const [
        CourseChoice(
          id: 'bound',
          label: 'The raise stands — verbal is binding',
        ),
        CourseChoice(
          id: 'takeback',
          label: 'You can switch to a call freely',
        ),
        CourseChoice(
          id: 'dealer-choice',
          label: 'Only the dealer decides after cards move',
        ),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.verbalBindingOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.verbalRaiseStands,
        choices: activity.choices,
      ),
      'bound',
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
      find.text('You said raise. Tap what counts at a live table.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'You say "raise" then try to take it back to a call. Result?',
      ),
      findsNothing,
    );
    // Felt caption is structural — Rex owns the “You said raise” SoftPulse cue.
    expect(find.text('Live table · verbal action'), findsOneWidget);
    expect(find.textContaining('You said "raise"'), findsNothing);
    expect(
      find.text('The raise stands — verbal is binding'),
      findsNothing,
    );
    expect(find.text('Raise stands'), findsOneWidget);
    await tester.tap(find.text('Raise stands'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bound');
    controller.dispose();
  });

  testWidgets('s3 table-read checkpoint taps 55bb + pot on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-01-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Effective stack is the shorter committed stack.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Hero 140bb, villain 55bb, pot 18. What matters most next?',
      choices: const [
        CourseChoice(id: 'eff-55', label: 'Effective 55bb and the 18 pot'),
        CourseChoice(id: 'hero-140', label: "Only hero's 140bb"),
        CourseChoice(id: 'ignore-pot', label: 'Ignore pot until the river'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.tableReadMattersOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.tableMatterEffAndPot,
        choices: activity.choices,
      ),
      'eff-55',
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
      find.text(
        'Shorter stack caps the matchup — tap what matters with the pot.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Hero 140bb, villain 55bb, pot 18. What matters most next?',
      ),
      findsNothing,
    );
    expect(find.text('Effective 55bb and the 18 pot'), findsNothing);
    expect(find.text('55bb + pot'), findsOneWidget);
    await tester.tap(find.text('55bb + pot'));
    await tester.pump();
    expect(controller.draft.choiceId, 'eff-55');
    controller.dispose();
  });

  testWidgets('s3 flop-class guided taps Made on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-02-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Top pair is a made hand.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Board Ks 9d 2c. You hold Kh Qh. Class?',
      choices: const [
        CourseChoice(id: 'made-tp', label: 'Made hand — top pair'),
        CourseChoice(id: 'draw-tp', label: 'Draw only'),
        CourseChoice(id: 'air-tp', label: 'Air'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.flopClassGuidedOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.heroCodes, ['Kh', 'Qh']);
    expect(
      resolveLessonTableScene(activity)?.boardCodes,
      ['Ks', '9d', '2c'],
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.flopClassMade,
        choices: activity.choices,
      ),
      'made-tp',
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
      find.text('Board pairs your king — tap the flop class.'),
      findsOneWidget,
    );
    expect(
      find.text('Board Ks 9d 2c. You hold Kh Qh. Class?'),
      findsNothing,
    );
    expect(find.text('Made'), findsOneWidget);
    expect(find.text('Strong now'), findsOneWidget);
    // SoftPulse must not spoil with “Top pair” / gold tip.
    expect(find.text('Top pair'), findsNothing);
    // SoftPulse + Rex own the cue — no Tap footer mid-teach.
    expect(find.text('Tap Made.'), findsNothing);
    await tester.tap(find.text('Made'));
    await tester.pump();
    expect(controller.draft.choiceId, 'made-tp');
    controller.dispose();
  });

  testWidgets('s3 flop-class scaffolded taps Draw on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-02-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Nut flush draw with overcard equity.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Board Jh 8h 3c. You hold Ah 9h. Class?',
      choices: const [
        CourseChoice(id: 'nfd', label: 'Strong draw — nut flush draw'),
        CourseChoice(id: 'made-aj', label: 'Made top pair'),
        CourseChoice(id: 'sdv', label: 'Strong showdown value already'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.flopClassScaffoldedOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.heroCodes, ['Ah', '9h']);
    expect(
      resolveLessonTableScene(activity)?.boardCodes,
      ['Jh', '8h', '3c'],
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.flopClassNfd,
        choices: activity.choices,
      ),
      'nfd',
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
      find.text('Two hearts on board with the nut heart — tap the class.'),
      findsOneWidget,
    );
    expect(
      find.text('Board Jh 8h 3c. You hold Ah 9h. Class?'),
      findsNothing,
    );
    expect(find.text('Draw'), findsOneWidget);
    expect(find.text('Needs runout'), findsOneWidget);
    // SoftPulse must not spoil with “Nut flush” / gold tip.
    expect(find.text('Nut flush'), findsNothing);
    expect(find.text('Flop · nut flush draw'), findsNothing);
    expect(find.text('Flop · your holes'), findsOneWidget);
    // SoftPulse + Rex own the cue — no Tap footer mid-teach.
    expect(find.text('Tap Draw.'), findsNothing);
    await tester.tap(find.text('Draw'));
    await tester.pump();
    expect(controller.draft.choiceId, 'nfd');
    controller.dispose();
  });

  testWidgets('s3 flop-class unguided taps Air on densified multiway felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-02-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'No pair and almost no draw — air.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Board Qc 7d 2s. You hold 5h 4h multiway. Class?',
      choices: const [
        CourseChoice(id: 'air', label: 'Air — little equity, no pair'),
        CourseChoice(id: 'sdv-54', label: 'Playable showdown value'),
        CourseChoice(id: 'made-54', label: 'Made hand'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    final scene = resolveLessonTableScene(activity);
    expect(scene?.layout, LessonTableLayout.flopClassUnguidedOutcomes);
    expect(scene?.heroCodes, ['5h', '4h']);
    expect(scene?.boardCodes, ['Qc', '7d', '2s']);
    expect(scene?.villainSeatCount, 2);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.flopClassAirMw,
        choices: activity.choices,
      ),
      'air',
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
    expect(
      find.text('No pair, almost no draw multiway — tap the class.'),
      findsOneWidget,
    );
    expect(find.text('Air'), findsOneWidget);
    expect(find.text('Empty'), findsOneWidget);
    expect(find.text('Little equity'), findsNothing);
    expect(find.text('Tap Air.'), findsNothing);
    await tester.tap(find.text('Air'));
    await tester.pump();
    expect(controller.draft.choiceId, 'air');
    controller.dispose();
  });

  testWidgets('s3 flop-class checkpoint taps Draw on densified open-ender felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-02-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Open-ender with a spade is a draw class.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Board Ts 9s 4d. You hold Js 8d. Best label?',
      choices: const [
        CourseChoice(id: 'oesd', label: 'Draw — open-ended straight draw'),
        CourseChoice(id: 'made-jt', label: 'Made top pair'),
        CourseChoice(id: 'air-j8', label: 'Pure air'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    final scene = resolveLessonTableScene(activity);
    expect(scene?.layout, LessonTableLayout.flopClassCheckpointOutcomes);
    expect(scene?.heroCodes, ['Js', '8d']);
    expect(scene?.boardCodes, ['Ts', '9s', '4d']);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.flopClassOesd,
        choices: activity.choices,
      ),
      'oesd',
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
    expect(
      find.text('Eight or queen completes — tap the class.'),
      findsOneWidget,
    );
    expect(find.text('Draw'), findsOneWidget);
    expect(find.text('Needs runout'), findsOneWidget);
    // SoftPulse must not spoil with “Open-ender” on the correct tile.
    expect(find.text('Open-ender'), findsNothing);
    expect(find.text('Flop · open-ender'), findsNothing);
    expect(find.text('Flop · your holes'), findsOneWidget);
    expect(find.text('Tap Draw.'), findsNothing);
    await tester.tap(find.text('Draw'));
    await tester.pump();
    expect(controller.draft.choiceId, 'oesd');
    controller.dispose();
  });

  testWidgets('s3 outs guided taps remaining aces on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-03-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Three remaining aces are the clean outs.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Board Kc 8h 2d. You hold Ah Qh. Clean outs to the best hand?',
      choices: const [
        CourseChoice(id: 'outs-3', label: 'About 3 — the aces'),
        CourseChoice(id: 'outs-6', label: '6 — aces and queens'),
        CourseChoice(id: 'outs-0', label: '0 — never improve'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.outsCleanAcesTap,
    );
    expect(isTableRegionTapActivity(activity), isFalse);

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
      find.text('King-high board. Tap the remaining aces — your clean outs.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Board Kc 8h 2d. You hold Ah Qh. Clean outs to the best hand?',
      ),
      findsNothing,
    );
    // Teach-by-doing: SoftPulse individual ace cards — not MCQ titles.
    expect(find.text('Remaining aces'), findsNothing);
    expect(find.text('Aces + queens'), findsNothing);
    expect(find.text('Tap every remaining ace'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('outs-ace-As')));
    await tester.pump();
    expect(controller.draft.choiceId, isNull);
    await tester.tap(find.byKey(const ValueKey('outs-ace-Ad')));
    await tester.pump();
    expect(controller.draft.choiceId, isNull);
    await tester.tap(find.byKey(const ValueKey('outs-ace-Ac')));
    await tester.pump();
    expect(controller.draft.choiceId, 'outs-3');
    controller.dispose();
  });

  testWidgets('s3 outs guided dirty queen submits outs-6', (tester) async {
    final activity = CourseActivity(
      id: 'act-03-03-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Three remaining aces are the clean outs.',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [
        CourseChoice(id: 'outs-3', label: 'About 3 — the aces'),
        CourseChoice(id: 'outs-6', label: '6 — aces and queens'),
        CourseChoice(id: 'outs-0', label: '0 — never improve'),
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
    await tester.tap(find.byKey(const ValueKey('outs-ace-Qs')));
    await tester.pump();
    expect(controller.draft.choiceId, 'outs-6');
    controller.dispose();
  });

  testWidgets('s3 outs scaffolded taps 10-chip call on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-03-03-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Calling price is the bet size: 10.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Pot is 20. Villain bets 10. How many chips to call?',
      choices: const [
        CourseChoice(id: 'call-10', label: '10'),
        CourseChoice(id: 'call-20', label: '20'),
        CourseChoice(id: 'call-30', label: '30'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.callPriceOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.callChipsTen,
        choices: activity.choices,
      ),
      'call-10',
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
      find.text('Pot 20, bet 10 — tap how many chips to call.'),
      findsOneWidget,
    );
    expect(
      find.text('Pot is 20. Villain bets 10. How many chips to call?'),
      findsNothing,
    );
    expect(find.text('Call 10'), findsOneWidget);
    expect(find.text('Match the bet'), findsNothing);
    expect(find.text('The pot'), findsNothing);
    expect(find.text('After you call'), findsNothing);
    expect(find.text('Villain bet'), findsOneWidget);
    // SoftPulse + Rex own the cue — no Tap footer mid-teach.
    expect(find.text('Tap how many chips to call.'), findsNothing);
    await tester.tap(find.text('Call 10'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call-10');
    controller.dispose();
  });

  testWidgets('s3 outs unguided taps Call when priced in on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-03-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText:
          'Nine-outish equity is close; with implied odds deep, call is fine.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Pot 20, bet 10 (call 10 into 30). You have ~8 clean outs on the turn. Call?',
      choices: const [
        CourseChoice(
          id: 'call-draw',
          label: 'Call — price is acceptable with outs',
        ),
        CourseChoice(
          id: 'fold-draw',
          label: 'Fold always without a made hand',
        ),
        CourseChoice(id: 'raise-auto', label: 'Raise every draw'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.drawPriceOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.caption, 'Pot 20 · bet 10');
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.drawPriceCall,
        choices: activity.choices,
      ),
      'call-draw',
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
      find.text('Getting 3:1 with real outs — tap what you do.'),
      findsOneWidget,
    );
    expect(find.text('Pot 20 · bet 10'), findsOneWidget);
    // Felt must not spoil the outs count answering Call.
    expect(find.textContaining('~8 clean outs'), findsNothing);
    expect(
      find.text(
        'Pot 20, bet 10 (call 10 into 30). You have ~8 clean outs on the turn. Call?',
      ),
      findsNothing,
    );
    expect(
      find.text('Call — price is acceptable with outs'),
      findsNothing,
    );
    expect(find.text('Call — priced in'), findsNothing);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Priced in'), findsNothing);
    expect(find.text('No made hand'), findsNothing);
    expect(find.text('Every draw'), findsNothing);
    await tester.tap(find.text('Call'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call-draw');
    controller.dispose();
  });

  testWidgets('s3 outs checkpoint taps implied odds on NFD felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-03-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Deep stacks add implied odds versus sticky players.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          '200bb deep. Nut flush draw, pot-sized bet from a sticky caller. Edge?',
      choices: const [
        CourseChoice(
          id: 'implied-yes',
          label: 'Implied odds improve — they pay when you hit',
        ),
        CourseChoice(
          id: 'implied-no',
          label: 'Depth never changes draw price',
        ),
        CourseChoice(
          id: 'fold-nfd',
          label: 'Fold nut flush draws to any bet',
        ),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.outsImpliedOutcomes,
    );
    expect(
      resolveLessonTableScene(activity)?.caption,
      '200bb · pot bet · sticky caller',
    );
    expect(resolveLessonTableScene(activity)?.heroCodes, ['Ah', 'Qh']);
    expect(resolveLessonTableScene(activity)?.boardCodes, ['Kh', '7h', '2c']);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.outsImpliedPay,
        choices: activity.choices,
      ),
      'implied-yes',
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
      find.text('Nut flush draw, deep and sticky — tap Implied.'),
      findsOneWidget,
    );
    expect(
      find.text(
        '200bb deep. Nut flush draw, pot-sized bet from a sticky caller. Edge?',
      ),
      findsNothing,
    );
    expect(
      find.text('Implied odds improve — they pay when you hit'),
      findsNothing,
    );
    expect(find.text('Implied'), findsOneWidget);
    expect(find.text('Fold draw'), findsOneWidget);
    // SoftPulse must not gold-tip or echo NFD on the wrong tile.
    expect(find.text('Fold NFD'), findsNothing);
    expect(find.text('They pay hit'), findsNothing);
    expect(find.text('Price fixed'), findsNothing);
    expect(find.text('Always fold'), findsNothing);
    await tester.tap(find.text('Implied'));
    await tester.pump();
    expect(controller.draft.choiceId, 'implied-yes');
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

  testWidgets('s4 spr guided taps SPR 4 on densified stack÷pot felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-05-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'SPR is 4.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Effective stack 80bb, pot 20bb. SPR?',
      choices: const [
        CourseChoice(id: 'spr-4', label: '4'),
        CourseChoice(id: 'spr-2', label: '2'),
        CourseChoice(id: 'spr-8', label: '8'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.sprGuidedOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.caption, 'Stack 80bb · Pot 20bb');
    expect(resolveLessonTableScene(activity)?.villainSeatCount, 0);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.sprRatioFour,
        choices: activity.choices,
      ),
      'spr-4',
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
      find.text('Effective 80 into pot 20 — tap the SPR.'),
      findsOneWidget,
    );
    expect(find.text('Effective stack 80bb, pot 20bb. SPR?'), findsNothing);
    expect(find.text('Stack 80bb · Pot 20bb'), findsOneWidget);
    expect(find.text('Them'), findsNothing);
    expect(find.text('Stack'), findsOneWidget);
    expect(find.text('Pot'), findsOneWidget);
    expect(find.text('÷'), findsOneWidget);
    expect(find.text('SPR 4'), findsOneWidget);
    // SoftPulse + Rex own the cue — no Tap footer mid-teach.
    expect(find.text('Tap SPR 4.'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('SPR 4'));
    await tester.pump();
    expect(controller.draft.choiceId, 'spr-4');
    controller.dispose();
  });

  testWidgets('s4 jump spr taps SPR 4 on densified 60÷15 felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-04-10-02-jump-spr',
      order: 3,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Jump: SPR 4.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Stack 60bb, pot 15bb. SPR?',
      choices: const [
        CourseChoice(id: 'spr-4', label: '4'),
        CourseChoice(id: 'spr-2', label: '2'),
        CourseChoice(id: 'spr-8', label: '8'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.sprGuidedOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.caption, 'Stack 60bb · Pot 15bb');
    expect(resolveLessonTableScene(activity)?.villainSeatCount, 0);

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
    expect(find.text('Stack 60 into pot 15 — tap the SPR.'), findsOneWidget);
    expect(find.text('Stack 60bb · Pot 15bb'), findsOneWidget);
    expect(find.text('Them'), findsNothing);
    expect(find.text('60'), findsWidgets);
    expect(find.text('15'), findsWidgets);
    expect(find.text('SPR 4'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    // Jump test: no SoftPulse spoiler cue.
    expect(find.text('Tap SPR 4.'), findsNothing);
    await tester.tap(find.text('SPR 4'));
    await tester.pump();
    expect(controller.draft.choiceId, 'spr-4');
    controller.dispose();
  });

  testWidgets('s2 bb convert guided taps 100bb on densified chips÷BB felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-05-01-guided-convert',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Convert 200 chips at 1/2 into big blinds.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Blinds 1/2. You have 200 chips. How many big blinds?',
      choices: const [
        CourseChoice(id: 'bb-100', label: '100bb'),
        CourseChoice(id: 'bb-50', label: '50bb'),
        CourseChoice(id: 'bb-200', label: '200bb'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.bbConvertOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.caption, 'Chips 200 · BB 2');
    expect(resolveLessonTableScene(activity)?.villainSeatCount, 0);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.bbConvertCorrect,
        choices: activity.choices,
      ),
      'bb-100',
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
      find.text('200 chips at 1/2 — tap the stack in big blinds.'),
      findsOneWidget,
    );
    expect(
      find.text('Blinds 1/2. You have 200 chips. How many big blinds?'),
      findsNothing,
    );
    expect(find.text('Chips 200 · BB 2'), findsOneWidget);
    expect(find.text('Them'), findsNothing);
    expect(find.text('Chips'), findsOneWidget);
    expect(find.text('BB'), findsOneWidget);
    expect(find.text('÷'), findsOneWidget);
    expect(find.text('100bb'), findsOneWidget);
    expect(find.text('Tap 100bb.'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('100bb'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bb-100');
    controller.dispose();
  });

  testWidgets('s2 bb convert checkpoint taps 200bb on densified 1000÷5 felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-05-01-checkpoint-200',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Convert a 1000 chip buy-in at 2/5 to big blinds.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Blinds 2/5. You buy in for 1000 chips. Stack in big blinds?',
      choices: const [
        CourseChoice(id: 'bb-200', label: '200bb'),
        CourseChoice(id: 'bb-100', label: '100bb'),
        CourseChoice(id: 'bb-500', label: '500bb'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.bbConvertOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.caption, 'Chips 1000 · BB 5');
    expect(resolveLessonTableScene(activity)?.villainSeatCount, 0);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.bbConvertCorrect,
        choices: activity.choices,
      ),
      'bb-200',
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
    expect(
      find.text('1000 chips at 2/5 — tap the buy-in in big blinds.'),
      findsOneWidget,
    );
    expect(find.text('Chips 1000 · BB 5'), findsOneWidget);
    expect(find.text('Them'), findsNothing);
    expect(find.text('1000'), findsWidgets);
    expect(find.text('5'), findsWidgets);
    expect(find.text('200bb'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    // Checkpoint: no SoftPulse spoiler cue.
    expect(find.text('Tap 200bb.'), findsNothing);
    await tester.tap(find.text('200bb'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bb-200');
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
    expect(find.text('Worst hand vs a raise — tap Fold.'), findsOneWidget);
    expect(find.textContaining('72o'), findsNothing);
    // SoftPulse the Fold dock so teach-by-doing matches Rex.
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, 'fold-72');
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold-72');
    expect(find.text('Checking…'), findsOneWidget);
    controller.finishSubmit(
      _result(
        grade: SoftGrade.recommended,
        accepted: true,
        lifeLost: false,
      ),
    );
    await tester.pump();
    expect(find.text('Checking…'), findsNothing);
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
    expect(find.text('CALL (off)'), findsOneWidget);
    expect(find.text('CHECK FREE'), findsNothing);
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, 'check-free');
    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Check free'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Check free'));
    await tester.pump();
    expect(controller.draft.choiceId, 'check-free');
    handle.dispose();
    controller.dispose();
  });

  testWidgets('facing-bet dock marks Check off on unguided call', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-03-01-unguided-call',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Call',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'A bet is out — tap Call to continue.',
      choices: const [
        CourseChoice(id: 'call-5', label: 'Call 5', action: 'CALL'),
        CourseChoice(id: 'check-5', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'fold-strong', label: 'Fold', action: 'FOLD'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        PokerActionSizingActivity(
          activity: activity,
          controller: controller,
          showGuidance: false,
        ),
      ),
    );
    expect(find.text('CHECK (off)'), findsOneWidget);
    expect(find.text('CALL 5'), findsOneWidget);
    expect(find.text('A bet is out — tap Call to continue.'), findsOneWidget);
    await tester.tap(find.text('CALL 5'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call-5');
    controller.dispose();
  });

  testWidgets('checkpoint keeps Check live so identify is not spoiled', (
    tester,
  ) async {
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
    expect(find.text('CHECK (off)'), findsNothing);
    expect(find.text('CHECK'), findsOneWidget);
    expect(find.text('CALL'), findsOneWidget);
    expect(find.text('FOLD'), findsOneWidget);
    await tester.tap(find.text('CHECK'));
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
    // SoftPulse + Rex own the cue — no generic felt gold status mid-teach.
    expect(find.text('Pot is open to a bet'), findsNothing);
    expect(find.text('RAISE (off)'), findsOneWidget);
    expect(find.text('CALL (off)'), findsNothing);
    expect(
      tester.widget<LessonActionDock>(find.byType(LessonActionDock)).pulseChoiceId,
      'bet-half',
    );
    var autoSubmits = 0;
    betController.onAutoSubmit = () => autoSubmits += 1;
    await tester.tap(find.text('BET 5'));
    await tester.pump();
    expect(betController.draft.choiceId, 'bet-half');
    expect(autoSubmits, 1);
    expect(find.text('Checking…'), findsOneWidget);
    betController.dispose();

    final raise = CourseActivity(
      id: 'act-01-03-02-scaffolded-raise',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Raise',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap how you charge.',
      choices: const [
        CourseChoice(id: 'raise-15', label: 'Raise to 15', action: 'RAISE'),
        CourseChoice(id: 'call-flat', label: 'Call 5', action: 'CALL'),
        CourseChoice(id: 'bet-again', label: 'Bet 5', action: 'BET'),
      ],
    );
    final raiseController = LessonActivityController(activity: raise);
    await tester.pumpWidget(
      _wrap(
        PokerActionSizingActivity(
          activity: raise,
          controller: raiseController,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('Villain bets 5'), findsOneWidget);
    expect(find.text('BET (off)'), findsOneWidget);
    expect(find.text('CHECK (off)'), findsNothing);
    expect(
      tester.widget<LessonActionDock>(find.byType(LessonActionDock)).pulseChoiceId,
      'raise-15',
    );
    await tester.tap(find.text('RAISE TO 15'));
    await tester.pump();
    expect(raiseController.draft.choiceId, 'raise-15');
    raiseController.dispose();

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
    // Call 20 exceeds the 12-chip stack — live dock marks it off.
    expect(find.text('CALL (off)'), findsOneWidget);
    expect(find.text('CALL 20'), findsNothing);
    await tester.tap(find.text('ALL-IN 12'));
    await tester.pump();
    expect(allInController.draft.choiceId, 'shove-12');
    allInController.dispose();
  });

  testWidgets('open-pot checkpoint marks Raise and Call off', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-03-02-checkpoint-names',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tap Bet',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Pot is unchecked. Tap the first chips into the pot.',
      choices: const [
        CourseChoice(id: 'named-bet', label: 'Bet 4', action: 'BET'),
        CourseChoice(id: 'named-raise', label: 'Raise', action: 'RAISE'),
        CourseChoice(id: 'named-call', label: 'Call', action: 'CALL'),
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
    expect(find.text('BET 4'), findsOneWidget);
    expect(find.text('RAISE (off)'), findsOneWidget);
    expect(find.text('CALL (off)'), findsOneWidget);
    await tester.tap(find.text('RAISE (off)'));
    await tester.pump();
    expect(controller.draft.choiceId, 'named-raise');
    controller.dispose();
  });

  test('baseline full-hand action spots resolve mini-table dock mode', () {
    final guided = CourseActivity(
      id: 'act-02-07-01-guided-ep',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Open ace-jack suited under the gun',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Nine-handed. UTG with AJs. Action?',
      choices: const [
        CourseChoice(id: 'open-ajs', label: 'Open to 6', action: 'RAISE'),
        CourseChoice(id: 'fold-ajs', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'limp-ajs', label: 'Limp', action: 'CALL'),
      ],
    );
    expect(isLessonActionTableActivity(guided), isTrue);
    final guidedSpot = resolveLessonActionSpot(guided)!;
    expect(guidedSpot.openPot, isTrue);
    expect(guidedSpot.facingBet, isFalse);
    expect(guidedSpot.heroCodes, ['Ah', 'Jh']);
    expect(guidedSpot.potLabel, 'Pot 3');

    final vsOpen = CourseActivity(
      id: 'act-02-07-01-scaffolded-vs',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Call a small pair on the button',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'UTG opens to 6. You have 22 on the button. Action?',
      choices: const [
        CourseChoice(id: 'call-22', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-22', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: '3bet-22', label: '3-bet to 18', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(vsOpen), isTrue);
    final vsSpot = resolveLessonActionSpot(vsOpen)!;
    expect(vsSpot.facingBet, isTrue);
    expect(vsSpot.heroCodes, ['2h', '2d']);
    expect(vsSpot.villainLine, 'UTG opens to 6');

    final lab = CourseActivity(
      id: 'act-02-07-01-unguided-lab',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.fullTableHandLab,
      estimatedSeconds: 70,
      accessibilityText: 'Full-ring hand lab: button versus cutoff open',
      acceptedGrades: const [SoftGrade.recommended, SoftGrade.reasonable],
      prompt: 'Full ring. Decide versus a cutoff open.',
      choices: const [
        CourseChoice(id: 'lab-fold', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'lab-call', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'lab-3bet', label: '3-bet to 18', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(lab), isTrue);
    final labSpot = resolveLessonActionSpot(lab)!;
    expect(labSpot.facingBet, isTrue);
    expect(labSpot.heroCodes, ['Kh', 'Qd']);
    expect(labSpot.villainLine, 'CO opens to 6');
  });

  testWidgets('baseline guided EP docks Open to 6 on felt — no text prompt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-07-01-guided-ep',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Open ace-jack suited under the gun',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Nine-handed. UTG with AJs. Action?',
      choices: const [
        CourseChoice(id: 'open-ajs', label: 'Open to 6', action: 'RAISE'),
        CourseChoice(id: 'fold-ajs', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'limp-ajs', label: 'Limp', action: 'CALL'),
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
    expect(
      find.text('Suited broadway UTG — tap Open to 6.'),
      findsOneWidget,
    );
    // SoftPulse + Rex own the cue — no third felt gold status line.
    expect(find.text('First in — open the pot'), findsNothing);
    expect(find.text('Nine-handed. UTG with AJs. Action?'), findsNothing);
    expect(find.text('OPEN TO 6'), findsOneWidget);
    expect(find.text('LIMP'), findsOneWidget);
    expect(find.text('RAISE (off)'), findsNothing);
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, 'open-ajs');
    await tester.tap(find.text('OPEN TO 6'));
    await tester.pump();
    expect(controller.draft.choiceId, 'open-ajs');
    controller.dispose();
  });

  testWidgets('baseline scaffolded vs-open docks Call on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-02-07-01-scaffolded-vs',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Call a small pair on the button',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'UTG opens to 6. You have 22 on the button. Action?',
      choices: const [
        CourseChoice(id: 'call-22', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-22', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: '3bet-22', label: '3-bet to 18', action: 'RAISE'),
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
    expect(
      find.text('Pair on the button vs a small open — tap Call.'),
      findsOneWidget,
    );
    // SoftPulse + Rex own the cue — no third felt gold status line.
    expect(find.text('A bet faces you'), findsNothing);
    expect(
      find.text('UTG opens to 6. You have 22 on the button. Action?'),
      findsNothing,
    );
    expect(find.text('3-BET TO 18'), findsOneWidget);
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, 'call-22');
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call-22');
    controller.dispose();
  });

  testWidgets('baseline unguided lab docks KQo vs CO on felt — no text Q&A', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-07-01-unguided-lab',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.fullTableHandLab,
      estimatedSeconds: 70,
      accessibilityText: 'Full-ring hand lab: button versus cutoff open',
      acceptedGrades: const [SoftGrade.recommended, SoftGrade.reasonable],
      prompt: 'Full ring. Decide versus a cutoff open.',
      choices: const [
        CourseChoice(id: 'lab-fold', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'lab-call', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'lab-3bet', label: '3-bet to 18', action: 'RAISE'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        FullTableHandLabActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.byType(LessonActionTable), findsOneWidget);
    expect(find.byType(LessonActionDock), findsOneWidget);
    expect(
      find.text('CO open faces you on the button — tap Fold, Call, or 3-bet.'),
      findsOneWidget,
    );
    expect(find.text('Full ring. Decide versus a cutoff open.'), findsNothing);
    expect(find.text('Hand lab — tap the action you would take live.'), findsNothing);
    expect(find.text('A bet faces you'), findsOneWidget);
    expect(find.text('3-BET TO 18'), findsOneWidget);
    await tester.tap(find.text('3-BET TO 18'));
    await tester.pump();
    expect(controller.draft.choiceId, 'lab-3bet');
    controller.dispose();
  });

  testWidgets('section jump open docks Fold on felt for UTG trash', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-02-07-02-jump-open',
      order: 3,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 40,
      accessibilityText: 'Jump test: fold trash early.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'UTG with 72o. Action?',
      choices: const [
        CourseChoice(id: 'j2-fold', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'j2-open', label: 'Open to 6', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    expect(resolveLessonActionSpot(activity)?.heroCodes, ['7h', '2d']);
    expect(resolveLessonActionSpot(activity)?.openPot, isTrue);

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
    expect(find.text('UTG first in — tap Fold or Open.'), findsOneWidget);
    expect(find.text('Trash UTG — tap Fold or Open.'), findsNothing);
    expect(find.text('UTG with 72o. Action?'), findsNothing);
    // Jump: structural felt only — no “trash folds” answer tip.
    expect(find.text('First in — trash folds'), findsNothing);
    expect(find.text('First in — open the pot'), findsNothing);
    expect(find.text('First in · your action'), findsOneWidget);
    expect(find.text('OPEN TO 6'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j2-fold');
    controller.dispose();
  });

  testWidgets('section jump vs docks 3-bet for AA in BB', (tester) async {
    final activity = CourseActivity(
      id: 'act-02-07-02-jump-vs',
      order: 4,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 40,
      accessibilityText: 'Jump test: value 3-bet aces.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Open to 6. You have AA in the big blind. Action?',
      choices: const [
        CourseChoice(id: 'j2-3bet', label: '3-bet to 18', action: 'RAISE'),
        CourseChoice(id: 'j2-call', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'j2-fold-aa', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    expect(resolveLessonActionSpot(activity)?.heroCodes, ['Ah', 'Ad']);

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
    expect(
      find.text('Big blind vs an open — tap your action.'),
      findsOneWidget,
    );
    expect(
      find.text('Aces in the big blind vs an open — tap your action.'),
      findsNothing,
    );
    expect(
      find.text('Open to 6. You have AA in the big blind. Action?'),
      findsNothing,
    );
    await tester.tap(find.text('3-BET TO 18'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j2-3bet');
    controller.dispose();
  });

  test('s3 flop-line action spots resolve mini-table dock mode', () {
    final guided = CourseActivity(
      id: 'act-03-04-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Bet for value with TPTK.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Heads-up. You hold top pair top kicker. Checked to you. Action?',
      choices: const [
        CourseChoice(id: 'bet-tp', label: 'Bet half pot', action: 'BET'),
        CourseChoice(id: 'check-tp', label: 'Check back', action: 'CHECK'),
        CourseChoice(id: 'fold-tp', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(guided), isTrue);
    final guidedSpot = resolveLessonActionSpot(guided)!;
    expect(guidedSpot.openPot, isTrue);
    expect(guidedSpot.facingBet, isFalse);
    expect(guidedSpot.heroCodes, ['Ah', 'Kd']);
    expect(guidedSpot.boardCodes, ['As', '7c', '2d']);

    final scaffolded = CourseActivity(
      id: 'act-03-04-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'High-card air can c-bet a dry ace-high board selectively.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You opened BTN, BB called. Flop As 7d 2c. You have KQo. Action?',
      choices: const [
        CourseChoice(id: 'cbet', label: 'C-bet small', action: 'BET'),
        CourseChoice(id: 'check-kq', label: 'Check back', action: 'CHECK'),
        CourseChoice(id: 'jam-kq', label: 'Jam all-in', action: 'ALL_IN'),
      ],
    );
    expect(isLessonActionTableActivity(scaffolded), isTrue);
    expect(resolveLessonActionSpot(scaffolded)?.heroCodes, ['Kh', 'Qd']);

    final unguided = CourseActivity(
      id: 'act-03-04-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Raise a set for value multiway.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Multiway pot. Villain bets half pot. You flopped a set. Action?',
      choices: const [
        CourseChoice(id: 'raise-set', label: 'Raise', action: 'RAISE'),
        CourseChoice(id: 'call-set', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-set', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(unguided), isTrue);
    expect(resolveLessonActionSpot(unguided)?.facingBet, isTrue);

    final checkpoint = CourseActivity(
      id: 'act-03-04-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Fold weak one-pair multiway to heat.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Three players. Flop bets and a raise ahead. You have bottom pair. Action?',
      choices: const [
        CourseChoice(id: 'fold-bp', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'call-bp', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'raise-bp', label: 'Raise', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(checkpoint), isTrue);
    expect(resolveLessonActionSpot(checkpoint)?.facingBet, isTrue);
  });

  testWidgets('s3 flop-line guided docks Bet half pot on TPTK felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-04-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Bet for value with TPTK.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Heads-up. You hold top pair top kicker. Checked to you. Action?',
      choices: const [
        CourseChoice(id: 'bet-tp', label: 'Bet half pot', action: 'BET'),
        CourseChoice(id: 'check-tp', label: 'Check back', action: 'CHECK'),
        CourseChoice(id: 'fold-tp', label: 'Fold', action: 'FOLD'),
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
    expect(
      find.text('Top pair top kicker checked to you — tap a value bet.'),
      findsOneWidget,
    );
    // SoftPulse + Rex own the cue — no third gold felt status / TPTK spoiler.
    expect(find.text('Checked to you — value bet'), findsNothing);
    expect(find.text('Flop · Heads-up · TPTK'), findsNothing);
    expect(find.text('Flop · Heads-up'), findsOneWidget);
    expect(find.text('Checked to you'), findsWidgets);
    expect(
      find.text('Heads-up. You hold top pair top kicker. Checked to you. Action?'),
      findsNothing,
    );
    expect(find.text('BET HALF POT'), findsOneWidget);
    await tester.tap(find.text('BET HALF POT'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bet-tp');
    controller.dispose();
  });

  testWidgets('s3 flop-line scaffolded docks C-bet on dry ace felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-04-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'High-card air can c-bet a dry ace-high board selectively.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You opened BTN, BB called. Flop As 7d 2c. You have KQo. Action?',
      choices: const [
        CourseChoice(id: 'cbet', label: 'C-bet small', action: 'BET'),
        CourseChoice(id: 'check-kq', label: 'Check back', action: 'CHECK'),
        CourseChoice(id: 'jam-kq', label: 'Jam all-in', action: 'ALL_IN'),
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
    expect(
      find.text('You opened; dry ace flops — tap a small c-bet.'),
      findsOneWidget,
    );
    expect(
      find.text('You opened BTN, BB called. Flop As 7d 2c. You have KQo. Action?'),
      findsNothing,
    );
    expect(find.text('C-BET SMALL'), findsOneWidget);
    await tester.tap(find.text('C-BET SMALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cbet');
    controller.dispose();
  });

  testWidgets('s3 flop-line unguided docks Raise on set multiway felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-04-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Raise a set for value multiway.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Multiway pot. Villain bets half pot. You flopped a set. Action?',
      choices: const [
        CourseChoice(id: 'raise-set', label: 'Raise', action: 'RAISE'),
        CourseChoice(id: 'call-set', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-set', label: 'Fold', action: 'FOLD'),
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
    expect(
      find.text('Set multiway vs a bet — tap Raise, Call, or Fold.'),
      findsOneWidget,
    );
    expect(
      find.text('Multiway pot. Villain bets half pot. You flopped a set. Action?'),
      findsNothing,
    );
    // Felt is structural — don’t spoil Raise with “build the pot” / Set label.
    expect(find.text('Set multiway — build the pot'), findsNothing);
    expect(find.text('Flop · Multiway · Set'), findsNothing);
    expect(find.text('Flop · Multiway'), findsOneWidget);
    expect(find.text('Facing a bet'), findsOneWidget);
    expect(find.text('RAISE'), findsOneWidget);
    await tester.tap(find.text('RAISE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'raise-set');
    controller.dispose();
  });

  testWidgets('s3 flop-line checkpoint docks Fold on bottom-pair heat felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-04-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Fold weak one-pair multiway to heat.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Three players. Flop bets and a raise ahead. You have bottom pair. Action?',
      choices: const [
        CourseChoice(id: 'fold-bp', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'call-bp', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'raise-bp', label: 'Raise', action: 'RAISE'),
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
    expect(
      find.text('Bottom pair vs bet and raise multiway — tap your action.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Three players. Flop bets and a raise ahead. You have bottom pair. Action?',
      ),
      findsNothing,
    );
    // Felt is structural — don’t tip Fold with “weak one pair.”
    expect(find.text('Heat multiway — weak one pair'), findsNothing);
    expect(find.text('Flop · Multiway · Bottom pair'), findsNothing);
    expect(find.text('Facing raise · multiway'), findsOneWidget);
    expect(find.text('FOLD'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold-bp');
    controller.dispose();
  });

  testWidgets('s3 turn guided taps Brick on flop+turn felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-03-05-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'A blank three is a brick on this dry ace board.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Flop As 7d 2c. Turn 3h. For a missed c-bettor, is this a brick?',
      choices: const [
        CourseChoice(
          id: 'brick',
          label: 'Brick — rarely helps the caller',
        ),
        CourseChoice(id: 'scare', label: 'Major scare card'),
        CourseChoice(
          id: 'always-change',
          label: 'Every turn changes everything',
        ),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.turnBrickScareOutcomes,
    );
    expect(
      resolveLessonTableScene(activity)?.boardCodes,
      ['As', '7d', '2c', '3h'],
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.turnBrick,
        choices: activity.choices,
      ),
      'brick',
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
      find.text('Dry ace flop, blank three — tap Brick.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Flop As 7d 2c. Turn 3h. For a missed c-bettor, is this a brick?',
      ),
      findsNothing,
    );
    expect(find.text('Brick — rarely helps'), findsNothing);
    expect(find.text('Brick'), findsOneWidget);
    expect(find.text('Rarely helps'), findsOneWidget);
    // SoftPulse must not spoil with “turn blank?” on the felt.
    expect(find.text('Missed c-bet · turn blank?'), findsNothing);
    expect(find.text('Missed c-bet · your holes'), findsOneWidget);
    await tester.tap(find.text('Brick'));
    await tester.pump();
    expect(controller.draft.choiceId, 'brick');
    controller.dispose();
  });

  testWidgets('s3 turn scaffolded docks barrel on brick-turn felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-05-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Second barrel value with top pair top kicker.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'You c-bet A-high flop with AK. Brick turn. Villain called flop. Action?',
      choices: const [
        CourseChoice(
          id: 'barrel',
          label: 'Bet again for value',
          action: 'BET',
        ),
        CourseChoice(id: 'check-ak', label: 'Check', action: 'CHECK'),
        CourseChoice(
          id: 'fold-ak',
          label: 'Fold to a future bet preemptively',
          action: 'FOLD',
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('TPTK on a brick turn after a call — tap a barrel.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'You c-bet A-high flop with AK. Brick turn. Villain called flop. Action?',
      ),
      findsNothing,
    );
    // Felt is structural — don’t tip barrel with Brick/TPTK status.
    expect(find.text('Brick turn — still ahead'), findsNothing);
    expect(find.text('Turn · Brick · TPTK'), findsNothing);
    expect(find.text('Turn · your holes'), findsOneWidget);
    // Dock compactifies long teaching labels.
    expect(find.text('BET AGAIN'), findsOneWidget);
    await tester.tap(find.text('BET AGAIN'));
    await tester.pump();
    expect(controller.draft.choiceId, 'barrel');
    controller.dispose();
  });

  testWidgets('s3 turn unguided docks delayed value on flush felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-05-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Delayed value bet when the draw comes in.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'You checked back flop with a flush draw. Turn completes your flush. Checked to you. Action?',
      choices: const [
        CourseChoice(
          id: 'delay-bet',
          label: 'Bet for value now',
          action: 'BET',
        ),
        CourseChoice(
          id: 'delay-check',
          label: 'Check again always',
          action: 'CHECK',
        ),
        CourseChoice(id: 'delay-fold', label: 'Fold the nuts', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Flush comes in; checked to you — tap delayed value.'),
      findsOneWidget,
    );
    // Felt is structural — don’t tip delayed value on the felt.
    expect(find.text('Draw hit — delayed value'), findsNothing);
    expect(find.text('Turn · Flush completes'), findsNothing);
    expect(find.text('Turn · hearts'), findsOneWidget);
    // Dock compactifies long teaching labels.
    expect(find.text('BET VALUE'), findsOneWidget);
    await tester.tap(find.text('BET VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'delay-bet');
    controller.dispose();
  });

  testWidgets('s3 turn checkpoint taps give-up on scare-card felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-05-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Scare cards often end unsupported barrels.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'You bluffed flop on Kc 8d 3s. Turn Qh completes front-door draws. Plan?',
      choices: const [
        CourseChoice(
          id: 'give-up',
          label: 'Often give up — changing card hurts air',
        ),
        CourseChoice(id: 'auto-jam', label: 'Always jam larger'),
        CourseChoice(
          id: 'ignore',
          label: 'Treat every turn like a brick',
        ),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.turnScarePlanOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.turnGiveUp,
        choices: activity.choices,
      ),
      'give-up',
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
      find.text('Air bluff meets a draw-completing queen — tap the plan.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'You bluffed flop on Kc 8d 3s. Turn Qh completes front-door draws. Plan?',
      ),
      findsNothing,
    );
    expect(find.text('Give up — card hurts air'), findsNothing);
    expect(find.text('Give up'), findsOneWidget);
    expect(find.text('Card hurts air'), findsOneWidget);
    await tester.tap(find.text('Give up'));
    await tester.pump();
    expect(controller.draft.choiceId, 'give-up');
    controller.dispose();
  });

  testWidgets('s3 river guided docks value bet on brick river felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-06-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Value bet two pair on a brick river.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'River bricks. You have top two pair. Villain checked. Action?',
      choices: const [
        CourseChoice(id: 'val-bet', label: 'Bet for value', action: 'BET'),
        CourseChoice(id: 'val-check', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'val-fold', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Top two on a brick river — tap a value bet.'),
      findsOneWidget,
    );
    expect(
      find.text('River bricks. You have top two pair. Villain checked. Action?'),
      findsNothing,
    );
    expect(find.text('BET FOR VALUE'), findsOneWidget);
    expect(find.text('River · Brick · Top two'), findsNothing);
    expect(find.text('Brick river — get paid'), findsNothing);
    expect(find.text('River · brick'), findsOneWidget);
    expect(find.text('Checked to you'), findsWidgets);
    await tester.tap(find.text('BET FOR VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'val-bet');
    controller.dispose();
  });

  testWidgets('s3 river scaffolded docks flush-story bluff on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-06-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Represent the flush as a bluff when the story fits.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'You missed a flush draw after betting twice. River completes the flush. Action?',
      choices: const [
        CourseChoice(
          id: 'bluff',
          label: 'Bluff flush',
          action: 'BET',
        ),
        CourseChoice(
          id: 'giveup',
          label: 'Give up',
          action: 'CHECK',
        ),
        CourseChoice(
          id: 'tiny',
          label: 'Joke 1 chip',
          action: 'BET',
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    expect(
      resolveLessonActionSpot(activity)?.heroCodes,
      ['9s', '8s'],
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
    expect(
      find.text('You missed; river completes the flush — tap the bluff.'),
      findsOneWidget,
    );
    expect(find.text('BLUFF FLUSH'), findsOneWidget);
    expect(find.text('GIVE UP'), findsOneWidget);
    expect(find.text('JOKE 1 CHIP'), findsOneWidget);
    expect(find.text('River · Flush completes · Missed'), findsNothing);
    expect(find.text('Flush hits — tell that story'), findsNothing);
    expect(find.text('River · flush completes'), findsOneWidget);
    await tester.tap(find.text('BLUFF FLUSH'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bluff');
    controller.dispose();
  });

  testWidgets('s3 river unguided docks Fold vs quiet jam on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-06-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Often fold weak top pair to a huge river jam.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'You have top pair weak kicker. Villain jams river after a quiet line. Action?',
      choices: const [
        CourseChoice(id: 'fold-weak', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'call-weak', label: 'Call', action: 'CALL'),
        CourseChoice(
          id: 'raise-weak',
          label: 'Re-raise all-in',
          action: 'RAISE',
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Weak top pair faces a quiet-line jam — tap Fold or Call.'),
      findsOneWidget,
    );
    expect(find.text('River · Quiet line · Weak TPTK'), findsNothing);
    expect(find.text('Huge jam — weak kicker'), findsNothing);
    expect(find.text('River · quiet line'), findsOneWidget);
    expect(find.text('Jams all-in'), findsWidgets);
    expect(find.text('FOLD'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold-weak');
    controller.dispose();
  });

  testWidgets('s3 river checkpoint taps bluff-catch job on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-06-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Medium one pair is often a bluff-catch decision.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Which river job matches medium-strength one pair versus a big bet?',
      choices: const [
        CourseChoice(
          id: 'role-catch',
          label: 'Bluff-catch or fold — not thin value',
        ),
        CourseChoice(id: 'role-value', label: 'Always thin-value shove'),
        CourseChoice(id: 'role-air', label: 'Pure bluff with one pair'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.riverJobOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.riverJobCatch,
        choices: activity.choices,
      ),
      'role-catch',
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
      find.text('Medium one pair faces a big bet — tap the river job.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'Which river job matches medium-strength one pair versus a big bet?',
      ),
      findsNothing,
    );
    expect(find.text('Catch / fold'), findsOneWidget);
    expect(find.text('Not thin value'), findsOneWidget);
    await tester.tap(find.text('Catch / fold'));
    await tester.pump();
    expect(controller.draft.choiceId, 'role-catch');
    controller.dispose();
  });

  testWidgets('s3 multiway guided docks Check on second-pair felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-07-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Often check second pair multiway.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Four players to the flop. You have second pair. Checked to you. Action?',
      choices: const [
        CourseChoice(id: 'check-2p', label: 'Check', action: 'CHECK'),
        CourseChoice(
          id: 'bet-2p',
          label: 'Bet large for value',
          action: 'BET',
        ),
        CourseChoice(id: 'jam-2p', label: 'Jam', action: 'ALL_IN'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Second pair four ways — tap Check or Bet.'),
      findsOneWidget,
    );
    expect(find.text('Four ways — not auto-value'), findsNothing);
    expect(find.text('Checked to you · 4-way'), findsWidgets);
    expect(find.text('CHECK'), findsOneWidget);
    await tester.tap(find.text('CHECK'));
    await tester.pump();
    expect(controller.draft.choiceId, 'check-2p');
    controller.dispose();
  });

  testWidgets('s3 multiway scaffolded docks Check vs crowd on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-07-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Do not bluff into a crowd.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Three callers behind. You missed entirely on a wet board. Action?',
      choices: const [
        CourseChoice(
          id: 'mw-check',
          label: 'Check or give up',
          action: 'CHECK',
        ),
        CourseChoice(id: 'mw-bluff', label: 'Bluff large', action: 'BET'),
        CourseChoice(id: 'mw-min', label: 'Min-bluff', action: 'BET'),
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
    expect(
      find.text('Missed on a wet board with a crowd — tap Check.'),
      findsOneWidget,
    );
    expect(find.text('Crowd left — no bluff'), findsNothing);
    expect(find.text('Three callers behind'), findsWidgets);
    // Authored multi-word CHECK stays short chrome.
    expect(find.text('CHECK'), findsOneWidget);
    await tester.tap(find.text('CHECK'));
    await tester.pump();
    expect(controller.draft.choiceId, 'mw-check');
    controller.dispose();
  });

  testWidgets('s3 multiway unguided taps suited connector tile', (tester) async {
    final activity = CourseActivity(
      id: 'act-03-07-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText:
          'Suited connectors with nut potential beat dominated offsuit trash.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Multiway. Choose the better speculative hand deep.',
      choices: const [
        CourseChoice(id: 'sc', label: 'Suited connector in position'),
        CourseChoice(id: 'kto', label: 'KTo out of position'),
        CourseChoice(id: 'q6o', label: 'Q6o any seat'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.multiwaySpecOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.mwSpecSc,
        choices: activity.choices,
      ),
      'sc',
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
      find.text('Deep multiway — tap the better speculative hand.'),
      findsOneWidget,
    );
    expect(find.text('76s · IP'), findsOneWidget);
    expect(find.text('In position'), findsOneWidget);
    await tester.tap(find.text('76s · IP'));
    await tester.pump();
    expect(controller.draft.choiceId, 'sc');
    controller.dispose();
  });

  testWidgets('s3 multiway checkpoint taps note-participation tile', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-07-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText:
          'Tag high participation without naming an archetype yet.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'One seat has entered eight of the last ten pots with calls. Observation?',
      choices: const [
        CourseChoice(
          id: 'obs-many',
          label: 'They play many hands — note it',
        ),
        CourseChoice(id: 'obs-ignore', label: 'Ignore seat history'),
        CourseChoice(
          id: 'obs-label',
          label: 'Immediately insult their personality',
        ),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.multiwayObserveOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.mwObsNote,
        choices: activity.choices,
      ),
      'obs-many',
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
      find.text('Seat enters most pots — tap what you note.'),
      findsOneWidget,
    );
    expect(find.text('Note it'), findsOneWidget);
    expect(find.text('Play many'), findsOneWidget);
    await tester.tap(find.text('Note it'));
    await tester.pump();
    expect(controller.draft.choiceId, 'obs-many');
    controller.dispose();
  });

  testWidgets('s3 leak guided docks Fold on weak TPTK heat felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-08-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText:
          'Fold or play cautious — do not stack with weak top pair.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Multiway raise-reraise pot. You have top pair weak kicker. Action?',
      choices: const [
        CourseChoice(
          id: 'careful',
          label: 'Fold',
          action: 'FOLD',
        ),
        CourseChoice(id: 'stack', label: 'Jam stacks', action: 'ALL_IN'),
        CourseChoice(
          id: 'call-down',
          label: 'Call forever',
          action: 'CALL',
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Weak top pair in a raise-reraise pot — tap Fold.'),
      findsOneWidget,
    );
    expect(find.text('Weak kicker — do not stack'), findsNothing);
    expect(find.text('Facing raise · multiway'), findsOneWidget);
    expect(find.text('FOLD'), findsOneWidget);
    expect(find.text('JAM STACKS'), findsOneWidget);
    expect(find.text('CALL FOREVER'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'careful');
    controller.dispose();
  });

  testWidgets('s3 leak scaffolded docks Fold on gutshot overbet felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-08-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Fold a gutshot to an oversized bet.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Gutshot only. Pot 12, bet 18. Action?',
      choices: const [
        CourseChoice(id: 'fold-gut', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'call-gut', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'raise-gut', label: 'Bluff-raise', action: 'RAISE'),
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
    expect(find.text('Gutshot vs an overbet — tap Fold.'), findsOneWidget);
    expect(find.text('Four outs · terrible price'), findsNothing);
    expect(find.text('Facing a bet'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold-gut');
    controller.dispose();
  });

  testWidgets('s3 leak unguided docks Fold on multiway air felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-08-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText:
          'Fold air multiway; do not float or bluff the crowd.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Four players. You have no pair, no draw. Someone bets. Action?',
      choices: const [
        CourseChoice(id: 'fold-air', label: 'Fold', action: 'FOLD'),
        CourseChoice(
          id: 'float-air',
          label: 'Float call',
          action: 'CALL',
        ),
        CourseChoice(
          id: 'bluff-crowd',
          label: 'Bluff raise',
          action: 'RAISE',
        ),
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
    expect(find.text('Air multiway vs a bet — tap Fold.'), findsOneWidget);
    expect(find.text('No pair, no draw — fold'), findsNothing);
    expect(find.text('Facing a bet · 4-way'), findsOneWidget);
    expect(find.text('FLOAT CALL'), findsOneWidget);
    expect(find.text('BLUFF RAISE'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold-air');
    controller.dispose();
  });

  testWidgets('s3 leak checkpoint taps seat-frequency note tile', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-08-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText:
          'Track raise-versus-call and participation without labels.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Seat A raises often; Seat B almost never enters. Best notes?',
      choices: const [
        CourseChoice(
          id: 'notes',
          label: 'A raises a lot; B plays few hands',
        ),
        CourseChoice(id: 'guess', label: 'Invent life stories for both'),
        CourseChoice(
          id: 'same',
          label: 'Treat every seat identically forever',
        ),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.leakSeatNoteOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.leakSeatNotes,
        choices: activity.choices,
      ),
      'notes',
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
      find.text('Two seats, different frequencies — tap the note.'),
      findsOneWidget,
    );
    expect(find.text('Note freqs'), findsOneWidget);
    expect(find.text('A high · B low'), findsOneWidget);
    await tester.tap(find.text('Note freqs'));
    await tester.pump();
    expect(controller.draft.choiceId, 'notes');
    controller.dispose();
  });

  testWidgets('s3 jump table taps pot+eff on densified felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-03-08-02-jump-table',
      order: 1,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Jump: pot and effective stack.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Pot 16, shorter stack 40bb. What do you track first?',
      choices: const [
        CourseChoice(id: 'j3-track', label: 'Pot and effective 40bb'),
        CourseChoice(id: 'j3-ignore', label: 'Only hole cards'),
        CourseChoice(id: 'j3-chat', label: 'Only table talk'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.jumpTableTrackOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.jumpTrackPotEff,
        choices: activity.choices,
      ),
      'j3-track',
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
      find.text('Pot 16, shorter 40bb — tap what you track first.'),
      findsOneWidget,
    );
    expect(find.text('Pot 16 · shorter stack 40bb'), findsNothing);
    expect(find.text('Pot + 40bb'), findsNothing);
    expect(find.text('Table frame'), findsOneWidget);
    expect(find.text('Pot · effective'), findsOneWidget);
    expect(find.text('Price frame'), findsOneWidget);
    await tester.tap(find.text('Pot · effective'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j3-track');
    controller.dispose();
  });

  testWidgets('s3 jump class taps Draw on densified combo-draw felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-08-02-jump-class',
      order: 2,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Jump: combo draw.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Board Qd 9d 3c. You hold Jd Td. Class?',
      choices: const [
        CourseChoice(
          id: 'j3-draw',
          label: 'Draw — straight and flush potential',
        ),
        CourseChoice(id: 'j3-made', label: 'Made two pair'),
        CourseChoice(id: 'j3-air', label: 'Air'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.jumpFlopClassOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.jumpClassDraw,
        choices: activity.choices,
      ),
      'j3-draw',
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
      find.text('Qd9d3c with JdTd — tap the flop class.'),
      findsOneWidget,
    );
    expect(find.text('Draw'), findsOneWidget);
    expect(find.text('OESD + flush'), findsOneWidget);
    await tester.tap(find.text('Draw'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j3-draw');
    controller.dispose();
  });

  testWidgets('s3 jump mw docks Fold on multiway air felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-03-08-02-jump-mw',
      order: 3,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 40,
      accessibilityText: 'Jump: fold air multiway.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Four-way. You have air on a wet flop. Action?',
      choices: const [
        CourseChoice(id: 'j3-fold', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'j3-bluff', label: 'Bluff large', action: 'BET'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Air four-way on a wet flop — tap Fold.'),
      findsOneWidget,
    );
    expect(find.text('Crowd — fold air'), findsNothing);
    expect(find.text('Facing a bet · 4-way'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j3-fold');
    controller.dispose();
  });

  testWidgets('s3 jump river docks value on top-two felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-03-08-02-jump-river',
      order: 4,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 40,
      accessibilityText: 'Jump: value bet two pair.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Brick river. You have top two. Villain checks. Action?',
      choices: const [
        CourseChoice(id: 'j3-val', label: 'Bet value', action: 'BET'),
        CourseChoice(id: 'j3-check', label: 'Check always', action: 'CHECK'),
        CourseChoice(id: 'j3-fold2', label: 'Fold', action: 'FOLD'),
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
    expect(find.text('BET VALUE'), findsOneWidget);
    expect(find.text('River · Brick · Top two'), findsNothing);
    expect(find.text('Brick river — get paid'), findsNothing);
    expect(find.text('River · brick'), findsOneWidget);
    expect(find.text('Checked to you'), findsWidgets);
    await tester.tap(find.text('BET VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j3-val');
    controller.dispose();
  });

  testWidgets('s3 jump leak taps Fold on densified gutshot felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-03-08-02-jump-leak',
      order: 5,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Jump: fold bad price.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Gutshot, pot 10, face a 20 bet. Fix the leak?',
      choices: const [
        CourseChoice(id: 'j3-foldprice', label: 'Fold — price is wrong'),
        CourseChoice(
          id: 'j3-callprice',
          label: 'Call because any draw is lucky',
        ),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.jumpLeakPriceOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.jumpLeakFoldPrice,
        choices: activity.choices,
      ),
      'j3-foldprice',
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
      find.text('Gutshot vs a 2x pot bet — tap the fix.'),
      findsOneWidget,
    );
    expect(find.text('Fold'), findsOneWidget);
    expect(find.text('Price wrong'), findsOneWidget);
    await tester.tap(find.text('Fold'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j3-foldprice');
    controller.dispose();
  });

  testWidgets('s4 ranges scaffolded taps BB 3-bet on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-01-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'The 3-bettor\'s range is stronger.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'BTN opens, BB 3-bets, BTN calls. Whose range is stronger?',
      choices: const [
        CourseChoice(
          id: 'bb-stronger',
          label: 'Big blind 3-bet range is stronger',
        ),
        CourseChoice(id: 'btn-stronger', label: 'Button call is stronger'),
        CourseChoice(id: 'equal', label: 'Identical ranges'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.rangesScaffoldedOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.rangesBbStronger,
        choices: activity.choices,
      ),
      'bb-stronger',
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
      find.text('BTN open, BB 3-bet, BTN calls — tap who is stronger.'),
      findsOneWidget,
    );
    expect(find.text('BB 3-bet'), findsOneWidget);
    expect(find.text('Stronger'), findsOneWidget);
    await tester.tap(find.text('BB 3-bet'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bb-stronger');
    controller.dispose();
  });

  testWidgets('s4 ranges guided taps stronger-narrower on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-01-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Early opens are a stronger, narrower range.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'UTG opens at 1/2. Best description?',
      choices: const [
        CourseChoice(id: 'strong-narrow', label: 'Stronger, narrower range'),
        CourseChoice(id: 'any-two', label: 'Any two cards'),
        CourseChoice(id: 'exact-ak', label: 'Exactly Ace-King'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.rangesGuidedOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.rangesStrongNarrow,
        choices: activity.choices,
      ),
      'strong-narrow',
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
      find.text('UTG opens at 1/2 — tap the range shape.'),
      findsOneWidget,
    );
    expect(find.text('UTG opens at 1/2. Best description?'), findsNothing);
    expect(find.text('Strong narrow'), findsOneWidget);
    expect(find.text('UTG opens'), findsOneWidget);
    await tester.tap(find.text('Strong narrow'));
    await tester.pump();
    expect(controller.draft.choiceId, 'strong-narrow');
    controller.dispose();
  });

  testWidgets(
    's4 ranges checkpoint taps Read drives on densified same-board felt',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-04-01-01-checkpoint',
        order: 5,
        stage: ActivityStage.checkpoint,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 45,
        accessibilityText:
            'Recommendations change only when the read/range changes.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Same board. Same hero hand. Different villain lines. Result?',
        choices: const [
          CourseChoice(
            id: 'read-drives',
            label: 'Advice may change when the range changes',
          ),
          CourseChoice(
            id: 'always-same',
            label: 'Always do the same thing forever',
          ),
          CourseChoice(
            id: 'random',
            label: 'Pick randomly for unpredictability',
          ),
        ],
      );
      expect(
        resolveSelectIdentifyPresentation(activity),
        SelectIdentifyPresentation.tableRegionTap,
      );
      expect(isTableRegionTapActivity(activity), isTrue);
      expect(
        resolveLessonTableScene(activity)?.layout,
        LessonTableLayout.rangesCheckpointOutcomes,
      );
      expect(
        mapTableRegionToChoiceId(
          activityId: activity.id,
          region: LessonTableRegion.rangesReadDrives,
          choices: activity.choices,
        ),
        'read-drives',
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
        find.text('Same board, different villain lines — tap what changes.'),
        findsOneWidget,
      );
      expect(find.text('Read drives'), findsOneWidget);
      expect(find.text('Advice shifts'), findsOneWidget);
      await tester.tap(find.text('Read drives'));
      await tester.pump();
      expect(controller.draft.choiceId, 'read-drives');
      controller.dispose();
    },
  );

  testWidgets('s4 ranges unguided taps Keep range on densified bet-twice felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-01-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Over-precision is a leak.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Villain bets twice. You decide they have exactly AK. Problem?',
      choices: const [
        CourseChoice(
          id: 'too-exact',
          label: 'Too exact — keep a weighted range',
        ),
        CourseChoice(
          id: 'fine-exact',
          label: 'Exact hands are always knowable',
        ),
        CourseChoice(
          id: 'ignore-action',
          label: 'Ignore betting pattern entirely',
        ),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.rangesUnguidedOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.rangesTooExact,
        choices: activity.choices,
      ),
      'too-exact',
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
      find.text('They bet twice — you pinned Exactly AK. Tap the problem.'),
      findsOneWidget,
    );
    expect(find.text('Keep range'), findsOneWidget);
    expect(find.text('Weighted'), findsOneWidget);
    await tester.tap(find.text('Keep range'));
    await tester.pump();
    expect(controller.draft.choiceId, 'too-exact');
    controller.dispose();
  });

  testWidgets('s4 3bet guided docks 3-bet on QQ button felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-04-02-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: '3-bet queens for value.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'CO opens to 6. You have QQ on the button. Action?',
      choices: const [
        CourseChoice(id: '3bet-qq', label: '3-bet to ~18', action: 'RAISE'),
        CourseChoice(id: 'call-qq', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-qq', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Queens on the button vs a CO open — tap a 3-bet.'),
      findsOneWidget,
    );
    expect(find.text('3-BET TO ~18'), findsOneWidget);
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, '3bet-qq');
    await tester.tap(find.text('3-BET TO ~18'));
    await tester.pump();
    expect(controller.draft.choiceId, '3bet-qq');
    controller.dispose();
  });

  testWidgets('s4 3bet scaffolded docks Fold on 72o vs 3-bet felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-02-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Fold trash to a 3-bet.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You open BTN to 6. BB 3-bets to 20. You have 72o. Action?',
      choices: const [
        CourseChoice(id: 'fold-72', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'call-72', label: 'Call', action: 'CALL'),
        CourseChoice(id: '4bet-72', label: '4-bet bluff', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('72o faces a BB 3-bet — tap Fold.'),
      findsOneWidget,
    );
    expect(find.text('FOLD'), findsOneWidget);
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, 'fold-72');
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold-72');
    controller.dispose();
  });

  testWidgets('s4 3bet unguided docks squeeze on multiway AKo felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-02-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 40,
      accessibilityText: 'Squeeze with strong hands multiway.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'UTG opens, two callers. You have AKo in the big blind. Action?',
      choices: const [
        CourseChoice(
          id: 'squeeze',
          label: 'Squeeze to ~20',
          action: 'RAISE',
        ),
        CourseChoice(id: 'limp-more', label: 'Limp behind', action: 'CALL'),
        CourseChoice(id: 'fold-ak', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text(
        'UTG open, two callers, AKo in BB — tap Fold, Limp behind, or Squeeze.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'UTG open, two callers, AKo in BB — tap Fold, Call, or Squeeze.',
      ),
      findsNothing,
    );
    expect(
      find.text('UTG open, two callers, AKo in BB — tap a squeeze.'),
      findsNothing,
    );
    expect(find.text('Multiway — AKo in BB'), findsOneWidget);
    expect(find.text('Multiway — squeeze AK'), findsNothing);
    expect(find.text('SQUEEZE TO ~20'), findsOneWidget);
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, isNull);
    await tester.tap(find.text('SQUEEZE TO ~20'));
    await tester.pump();
    expect(controller.draft.choiceId, 'squeeze');
    controller.dispose();
  });

  testWidgets('s4 plan guided docks TPTK value bet on flop felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-03-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'Plan top pair across flop and turn.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-flop-tp',
          street: 'flop',
          prompt: 'Heads-up with TPTK on a dry flop. Checked to you.',
          choices: [
            CourseChoice(id: 'flop-bet', label: 'Bet', action: 'BET'),
            CourseChoice(id: 'flop-check', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-turn-tp',
          street: 'turn',
          prompt: 'Brick turn. Villain calls flop. Continue?',
          choices: [
            CourseChoice(id: 'turn-bet', label: 'Bet again', action: 'BET'),
            CourseChoice(id: 'turn-check', label: 'Check', action: 'CHECK'),
          ],
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('TPTK on a dry flop — tap Bet to start the plan.'),
      findsOneWidget,
    );
    expect(find.textContaining('Flop · A72 rainbow · TPTK'), findsOneWidget);
    expect(find.text('BET'), findsOneWidget);
    expect(
      find.text('Heads-up with TPTK on a dry flop. Checked to you.'),
      findsNothing,
    );
    expect(find.text('Tap your action on the dock.'), findsNothing);
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, 'flop-bet');
    await tester.tap(find.text('BET'));
    await tester.pump();
    expect(controller.draft.choiceId, 'flop-bet');
    controller.dispose();
  });

  testWidgets('s4 plan scaffolded docks Check on flush-turn air felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-03-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Abort unsupported barrels on changing boards.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'You bluffed flop. Turn puts four to a flush; you have no heart. Action?',
      choices: const [
        CourseChoice(id: 'abort', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'bigger', label: 'Bet bigger', action: 'BET'),
        CourseChoice(id: 'ignore-board', label: 'Bet as if dry', action: 'BET'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Air vs a flush turn — tap Check to shut down.'),
      findsOneWidget,
    );
    expect(find.textContaining('Turn · four hearts · air'), findsOneWidget);
    expect(find.text('CHECK'), findsOneWidget);
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, 'abort');
    await tester.tap(find.text('CHECK'));
    await tester.pump();
    expect(controller.draft.choiceId, 'abort');
    controller.dispose();
  });

  testWidgets('s4 plan unguided docks Check on medium multiway felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-03-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 40,
      accessibilityText: 'Keep medium hands in smaller pots.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Medium strength, deep stacks, multiway. Prefer?',
      choices: const [
        CourseChoice(
          id: 'small-pot',
          label: 'Keep pot small',
          action: 'CHECK',
        ),
        CourseChoice(id: 'jam-med', label: 'Jam stacks in', action: 'ALL_IN'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text(
        'Medium hand multiway and deep — tap Keep pot small.',
      ),
      findsOneWidget,
    );
    expect(find.text('KEEP POT SMALL'), findsOneWidget);
    await tester.tap(find.text('KEEP POT SMALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'small-pot');
    controller.dispose();
  });

  testWidgets('s4 sizing unguided taps Soft band on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-04-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Nearby sizes earn soft grades.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Two value sizes both get worse hands to call. Grading idea?',
      choices: const [
        CourseChoice(id: 'soft', label: 'Nearby sizes both soft-grade'),
        CourseChoice(id: 'one-only', label: 'Only one chip count is correct'),
        CourseChoice(id: 'random-size', label: 'Even 1-chip bets are fine'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.sizingUnguidedOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.sizingSoftBand,
        choices: activity.choices,
      ),
      'soft',
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
      find.text('Two value sizes both get calls — tap the grading idea.'),
      findsOneWidget,
    );
    expect(find.text('Soft band'), findsOneWidget);
    expect(find.text('Nearby OK'), findsOneWidget);
    await tester.tap(find.text('Soft band'));
    await tester.pump();
    expect(controller.draft.choiceId, 'soft');
    controller.dispose();
  });

  testWidgets('s4 plan checkpoint taps Branches on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-03-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Plans state flop intent and turn/river branches.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Good multi-street plans do what?',
      choices: const [
        CourseChoice(
          id: 'branches',
          label: 'Brick → barrel · flush → abort',
        ),
        CourseChoice(id: 'vibes', label: 'Wait for vibes each street'),
        CourseChoice(id: 'one-street', label: 'Only this street, always'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.planCheckpointOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.planBranches,
        choices: activity.choices,
      ),
      'branches',
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
      find.text('You have a flop plan — tap the turn branches.'),
      findsOneWidget,
    );
    expect(find.text('Branches'), findsOneWidget);
    expect(find.text('Brick · flush'), findsOneWidget);
    await tester.tap(find.text('Branches'));
    await tester.pump();
    expect(controller.draft.choiceId, 'branches');
    controller.dispose();
  });

  testWidgets('s4 sizing guided docks value sizes on dry top-pair felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-04-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Half to two-thirds pot is fine value.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Dry board, top pair, heads-up. Choose a value size into 20.',
      choices: const [
        CourseChoice(id: 'half', label: 'Bet 10', action: 'BET'),
        CourseChoice(id: 'two-third', label: 'Bet 14', action: 'BET'),
        CourseChoice(id: 'pot', label: 'Bet 20', action: 'BET'),
        CourseChoice(id: 'one-chip', label: 'Bet 1', action: 'BET'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Dry board, top pair — tap a value size into 20.'),
      findsOneWidget,
    );
    expect(find.textContaining('Flop · dry · top pair'), findsOneWidget);
    expect(find.text('BET 10'), findsOneWidget);
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, 'half');
    await tester.tap(find.text('BET 10'));
    await tester.pump();
    expect(controller.draft.choiceId, 'half');
    controller.dispose();
  });

  testWidgets('s4 sizing scaffolded docks pressure size on scare river', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-04-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Larger polar sizes sell the story.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Missed draw, credible river scare card. Choose pressure size into 40.',
      choices: const [
        CourseChoice(id: 'big', label: 'Bet 30-40', action: 'BET'),
        CourseChoice(id: 'tiny-bluff', label: 'Bet 2', action: 'BET'),
        CourseChoice(id: 'check-bluff', label: 'Check and hope', action: 'CHECK'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Missed draw on a scare river — tap a pressure size.'),
      findsOneWidget,
    );
    expect(find.text('BET 30-40'), findsOneWidget);
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, 'big');
    await tester.tap(find.text('BET 30-40'));
    await tester.pump();
    expect(controller.draft.choiceId, 'big');
    controller.dispose();
  });

  testWidgets('s4 sizing checkpoint docks worst value size on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-04-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 40,
      accessibilityText: 'One-chip value bets are clear mistakes.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Pot 30. You want value with a strong hand. Worst size?',
      choices: const [
        CourseChoice(id: 'bad-1', label: 'Bet 1', action: 'BET'),
        CourseChoice(id: 'good-15', label: 'Bet 15', action: 'BET'),
        CourseChoice(id: 'good-20', label: 'Bet 20', action: 'BET'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Strong hand for value into 30 — tap the worst size.'),
      findsOneWidget,
    );
    // Rex owns the tap verb — felt stays a structural status, not a Tap footer.
    expect(find.text('Tap the worst value size'), findsNothing);
    expect(find.text('One-chip value is a mistake'), findsOneWidget);
    expect(find.text('BET 1'), findsOneWidget);
    await tester.tap(find.text('BET 1'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bad-1');
    controller.dispose();
  });

  testWidgets('s4 spr scaffolded docks commit on low-SPR top set', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-05-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Get it in with top set at low SPR.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'SPR ~1 after a 3-bet. You flop top set. Action?',
      choices: const [
        CourseChoice(id: 'commit', label: 'Commit for stacks', action: 'RAISE'),
        CourseChoice(id: 'tiny', label: 'Check forever', action: 'CHECK'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Top set at SPR ~1 — tap Commit for stacks.'),
      findsOneWidget,
    );
    expect(find.text('COMMIT FOR STACKS'), findsOneWidget);
    expect(find.text('Low SPR — get it in'), findsNothing);
    expect(find.text('3-bet pot · short SPR'), findsWidgets);
    final dock = tester.widget<LessonActionDock>(find.byType(LessonActionDock));
    expect(dock.pulseChoiceId, 'commit');
    await tester.tap(find.text('COMMIT FOR STACKS'));
    await tester.pump();
    expect(controller.draft.choiceId, 'commit');
    controller.dispose();
  });

  testWidgets('s4 spr checkpoint docks Weigh SPR first on jam felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-05-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 45,
      accessibilityText: 'Check SPR before committing the rest.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'About to put stacks in. First?',
      choices: const [
        CourseChoice(id: 'before', label: 'Weigh SPR first'),
        CourseChoice(
          id: 'never',
          label: 'Jam on cards alone',
          action: 'ALL_IN',
        ),
        CourseChoice(id: 'showdown-only', label: 'Wait for showdown'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('About to put the rest in — tap Weigh SPR first.'),
      findsOneWidget,
    );
    expect(find.text('WEIGH SPR FIRST'), findsOneWidget);
    expect(find.text('Weigh SPR before you put it in'), findsNothing);
    expect(find.text('Turn · commitment spot'), findsNothing);
    expect(find.text('Turn · facing jam'), findsOneWidget);
    expect(find.textContaining('Opponent jams'), findsWidgets);
    await tester.tap(find.text('WEIGH SPR FIRST'));
    await tester.pump();
    expect(controller.draft.choiceId, 'before');
    controller.dispose();
  });

  testWidgets('s4 observe sticky guided taps high participation on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'High participation noted.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Seat calls preflop seven of nine hands. Observation?',
      choices: const [
        CourseChoice(id: 'high-part', label: 'High participation'),
        CourseChoice(id: 'low-part', label: 'Low participation'),
        CourseChoice(id: 'label-now', label: 'Label archetype now'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Seat calls 7 of 9 preflops — tap the observation.'),
      findsOneWidget,
    );
    expect(find.text('High part.'), findsOneWidget);
    expect(find.text('7 of 9'), findsNothing);
    expect(find.text('7/9'), findsNothing);
    expect(find.text('Many pots'), findsOneWidget);
    expect(find.text('HI'), findsOneWidget);
    await tester.tap(find.text('High part.'));
    await tester.pump();
    expect(controller.draft.choiceId, 'high-part');
    controller.dispose();
  });

  testWidgets('s4 observe sticky scaffolded taps Sticky on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Low folding / sticky calls.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Same seat calls three streets with second pair twice tonight. Note?',
      choices: const [
        CourseChoice(id: 'sticky', label: 'Sticky calls — low folding'),
        CourseChoice(id: 'folds-alot', label: 'They fold too much'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.observeStickyOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.observeStickyCalls,
        choices: activity.choices,
      ),
      'sticky',
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
      find.text('Second pair called three streets twice — tap the note.'),
      findsOneWidget,
    );
    expect(find.text('Sticky'), findsOneWidget);
    // SoftPulse + Rex own the cue — no Tap footer mid-teach.
    expect(find.text('Tap Sticky.'), findsNothing);
    await tester.tap(find.text('Sticky'));
    await tester.pump();
    expect(controller.draft.choiceId, 'sticky');
    controller.dispose();
  });

  testWidgets('s4 observe sticky unguided taps Low conf. on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'One sample is weak confidence.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'One dramatic call. How confident is a type label?',
      choices: const [
        CourseChoice(id: 'low-conf', label: 'Low confidence — need samples'),
        CourseChoice(id: 'sure', label: 'Certain forever'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.observeConfidenceOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.observeLowConf,
        choices: activity.choices,
      ),
      'low-conf',
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
    expect(
      find.text('One dramatic call — tap how confident the label is.'),
      findsOneWidget,
    );
    expect(find.text('Low conf.'), findsOneWidget);
    await tester.tap(find.text('Low conf.'));
    await tester.pump();
    expect(controller.draft.choiceId, 'low-conf');
    controller.dispose();
  });

  testWidgets('s4 observe sticky checkpoint taps Bundle on densified felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Bundle evidence before labeling.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Best pre-label note bundle?',
      choices: const [
        CourseChoice(id: 'bundle', label: 'Many hands · rarely folds'),
        CourseChoice(id: 'insult', label: 'They are a bad person'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.observeBundleOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.observeBundle,
        choices: activity.choices,
      ),
      'bundle',
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
    expect(
      find.text('Before you label — tap the evidence bundle.'),
      findsOneWidget,
    );
    expect(find.text('Bundle the evidence before labeling'), findsNothing);
    expect(find.text('Observation notes'), findsOneWidget);
    expect(find.text('Bundle'), findsOneWidget);
    await tester.tap(find.text('Bundle'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bundle');
    controller.dispose();
  });

  testWidgets('s4 meet station guided taps Station on sticky evidence felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-02-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'Calling Station fits sticky calls.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Seat called three streets with second pair. Best working label?',
      choices: const [
        CourseChoice(id: 'pt-station', label: 'Calling Station'),
        CourseChoice(id: 'pt-nit', label: 'Nit'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Sticky second pair calls — tap the working label.'),
      findsOneWidget,
    );
    expect(find.text('Station'), findsOneWidget);
    expect(find.text('Sticky calls'), findsNothing);
    expect(find.text('Calls down'), findsOneWidget);
    expect(find.textContaining('second pair'), findsWidgets);
    await tester.tap(find.text('Station'));
    await tester.pump();
    expect(controller.draft.choiceId, 'pt-station');
    controller.dispose();
  });

  testWidgets('s4 meet station scaffolded taps working model on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-02-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Working model, not a personality judgment.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'A label is…',
      choices: const [
        CourseChoice(id: 'model', label: 'A working model from evidence'),
        CourseChoice(id: 'soul', label: 'A permanent personality verdict'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('A player-type label is a working model — tap it.'),
      findsOneWidget,
    );
    expect(find.text('Working model'), findsOneWidget);
    await tester.tap(find.text('Working model'));
    await tester.pump();
    expect(controller.draft.choiceId, 'model');
    controller.dispose();
  });

  testWidgets('s4 meet station unguided taps Station on limp evidence felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-02-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'Calling Station.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Seat limps often, calls raises, almost never folds turns. Label?',
      choices: const [
        CourseChoice(id: 'station2', label: 'Calling Station'),
        CourseChoice(id: 'maniac2', label: 'Maniac'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Station'), findsOneWidget);
    await tester.tap(find.text('Station'));
    await tester.pump();
    expect(controller.draft.choiceId, 'station2');
    controller.dispose();
  });

  testWidgets('s4 meet station checkpoint taps low confidence on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-02-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Low sample confidence.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'After 2 hands, confidence in Calling Station should be?',
      choices: const [
        CourseChoice(id: 'low', label: 'Low — keep collecting samples'),
        CourseChoice(id: 'max', label: 'Maximum certainty'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Low'), findsOneWidget);
    expect(find.text('2'), findsNothing);
    expect(find.text('LO'), findsOneWidget);
    expect(find.text('Keep sampling'), findsOneWidget);
    await tester.tap(find.text('Low'));
    await tester.pump();
    expect(controller.draft.choiceId, 'low');
    controller.dispose();
  });

  testWidgets('s4 adjust station guided docks thin value on river felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-03-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Thin value versus station.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Known sticky caller. You have second pair good kicker on river. Action?',
      choices: const [
        CourseChoice(id: 'thin-val', label: 'Bet thin value', action: 'BET'),
        CourseChoice(id: 'check-val', label: 'Check behind', action: 'CHECK'),
        CourseChoice(
          id: 'bluff-air',
          label: 'Bluff-raise later with air',
          action: 'RAISE',
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Sticky seat, second pair river — tap Bet thin value.'),
      findsOneWidget,
    );
    expect(find.text('BET THIN VALUE'), findsOneWidget);
    await tester.tap(find.text('BET THIN VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'thin-val');
    controller.dispose();
  });

  testWidgets('s4 adjust station checkpoint taps rarely folds on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-06-03-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Because they fold too little.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Why bluff less versus a Calling Station?',
      choices: const [
        CourseChoice(id: 'cite-fold', label: 'They fold too rarely'),
        CourseChoice(id: 'cite-mean', label: 'The label sounds mean'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Rarely folds'), findsOneWidget);
    await tester.tap(find.text('Rarely folds'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cite-fold');
    controller.dispose();
  });

  testWidgets('s4 observe narrow guided taps Narrow on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-04-07-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Narrow entry.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Seat folded 20 of 22 hands. Observation?',
      choices: const [
        CourseChoice(id: 'narrow', label: 'Narrow entry — plays few hands'),
        CourseChoice(id: 'wide', label: 'Wide entry'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Folded 20 of 22 — tap the observation.'),
      findsOneWidget,
    );
    expect(find.text('Narrow'), findsOneWidget);
    await tester.tap(find.text('Narrow'));
    await tester.pump();
    expect(controller.draft.choiceId, 'narrow');
    controller.dispose();
  });

  testWidgets('s4 observe wild guided taps Extreme on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-04-08-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Extreme entry/aggression.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Seat raises or 3-bets twelve of fifteen pots. Observation?',
      choices: const [
        CourseChoice(id: 'extreme', label: 'Extreme entry and aggression'),
        CourseChoice(id: 'nit-like', label: 'Narrow and timid'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Raises 12 of 15 — tap the observation.'),
      findsOneWidget,
    );
    expect(find.text('Extreme'), findsOneWidget);
    await tester.tap(find.text('Extreme'));
    await tester.pump();
    expect(controller.draft.choiceId, 'extreme');
    controller.dispose();
  });

  testWidgets('s4 meet maniac guided taps Maniac on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-04-08-02-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'Maniac.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Seat open-raises 60% and triple-barrels light. Label?',
      choices: const [
        CourseChoice(id: 'pt-maniac', label: 'Maniac'),
        CourseChoice(id: 'pt-nit-m', label: 'Nit'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Opens 60%, barrels light — tap the working label.'),
      findsOneWidget,
    );
    expect(find.text('Maniac'), findsOneWidget);
    await tester.tap(find.text('Maniac'));
    await tester.pump();
    expect(controller.draft.choiceId, 'pt-maniac');
    controller.dispose();
  });

  testWidgets('s4 adjust maniac guided docks Call on river felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-04-08-03-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Wider bluff-catch versus maniac.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Maniac barrels river. You have top pair weakish kicker. Action?',
      choices: const [
        CourseChoice(id: 'call-wider', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-tp', label: 'Fold top pair always', action: 'FOLD'),
        CourseChoice(
          id: 'punish-jam',
          label: 'Jam to punish ego-to-ego',
          action: 'RAISE',
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Maniac barrels river — tap Call with top pair.'),
      findsOneWidget,
    );
    expect(find.text('CALL'), findsOneWidget);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call-wider');
    controller.dispose();
  });

  testWidgets('s4 confidence guided taps One note on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-04-09-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'One observation, low certainty.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You saw one huge bluff. What do you know?',
      choices: const [
        CourseChoice(id: 'one-note', label: 'One note — low certainty'),
        CourseChoice(id: 'proven', label: 'Type proven forever'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('One huge bluff — tap what you know.'),
      findsOneWidget,
    );
    expect(find.text('One note'), findsOneWidget);
    await tester.tap(find.text('One note'));
    await tester.pump();
    expect(controller.draft.choiceId, 'one-note');
    controller.dispose();
  });

  testWidgets('s4 same-hand station docks Bet value on river felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-04-10-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Thin value versus station.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'River, second pair. Versus Calling Station. Action?',
      choices: const [
        CourseChoice(id: 'st-val', label: 'Bet value', action: 'BET'),
        CourseChoice(id: 'st-bluff', label: 'Huge bluff', action: 'BET'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Station checked · second pair — tap Bet value.'),
      findsOneWidget,
    );
    expect(find.text('BET VALUE'), findsOneWidget);
    await tester.tap(find.text('BET VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'st-val');
    controller.dispose();
  });

  testWidgets('s4 same-hand lab docks Open to 6 on BTN felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-04-10-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.fullTableHandLab,
      estimatedSeconds: 70,
      accessibilityText: 'Button vs nit BB steal; deep stack.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Full ring. Type × position × stack decide the line.',
      choices: const [
        CourseChoice(id: 'lab-steal', label: 'Open to 6', action: 'RAISE'),
        CourseChoice(id: 'lab-fold', label: 'Fold KTo', action: 'FOLD'),
        CourseChoice(id: 'lab-limp', label: 'Limp', action: 'CALL'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    expect(resolveLessonActionSpot(activity), isNotNull);
    final controller = LessonActivityController(activity: activity);
    await tester.pumpWidget(
      _wrap(
        FullTableHandLabActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(
      find.text('BTN vs Nit BB with KTo — tap Open to 6.'),
      findsOneWidget,
    );
    expect(find.text('OPEN TO 6'), findsOneWidget);
    await tester.tap(find.text('OPEN TO 6'));
    await tester.pump();
    expect(controller.draft.choiceId, 'lab-steal');
    controller.dispose();
  });

  testWidgets('s4 jump range taps Narrower on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-04-10-02-jump-range',
      order: 1,
      stage: ActivityStage.jumpTest,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Jump: stronger narrower range.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'UTG open is best described as?',
      choices: const [
        CourseChoice(id: 'j4-range', label: 'Stronger, narrower range'),
        CourseChoice(id: 'j4-any', label: 'Any two'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('UTG open — tap how wide the range is.'),
      findsOneWidget,
    );
    expect(find.text('Narrower'), findsOneWidget);
    await tester.tap(find.text('Narrower'));
    await tester.pump();
    expect(controller.draft.choiceId, 'j4-range');
    controller.dispose();
  });

  testWidgets('s5 multiway guided taps Nut FD on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-05-01-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Nut flush draw beats weak pair-draw mixes.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Four-way flop. Best continue with?',
      choices: const [
        CourseChoice(id: 'nfd', label: 'Nut flush draw'),
        CourseChoice(id: 'weak-fd', label: 'Low flush draw with no overs'),
        CourseChoice(id: 'air', label: 'Complete air for a stab'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Four-way flop — tap the best continue.'),
      findsOneWidget,
    );
    expect(find.text('Nut FD'), findsOneWidget);
    await tester.tap(find.text('Nut FD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'nfd');
    controller.dispose();
  });

  testWidgets('s5 deep guided taps Implied on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-05-02-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Implied odds versus stacks that pay sets.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: '200bb effective. Best reason to call a raise with 55 BTN?',
      choices: const [
        CourseChoice(id: 'impl', label: 'Implied odds if they pay sets'),
        CourseChoice(id: 'spr-low', label: 'SPR is already low'),
        CourseChoice(id: 'bluff', label: 'You will bluff every flop'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('200bb with 55 — tap why you call.'),
      findsOneWidget,
    );
    expect(find.text('Implied'), findsOneWidget);
    await tester.tap(find.text('Implied'));
    await tester.pump();
    expect(controller.draft.choiceId, 'impl');
    controller.dispose();
  });

  testWidgets('s5 implied-odds guided docks Call on Station felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-03-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Station pays — implied odds improve. Call.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Deep vs Calling Station. Gutshot with overs facing a small bet. Action?',
      choices: const [
        CourseChoice(id: 'call-io', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-io', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    expect(resolveLessonActionSpot(activity)?.heroCodes, ['Jh', '9d']);
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
    expect(
      find.text('Deep gutshot vs Station — tap Call.'),
      findsOneWidget,
    );
    expect(find.text('Tap your action on the dock.'), findsNothing);
    expect(find.text('CALL'), findsOneWidget);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call-io');
    controller.dispose();
  });

  testWidgets('s5 implied-odds scaffolded docks Fold on Nit RIO felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-03-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Reverse implied odds — fold dominated broadway.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'KJo on A-high wet board. Nit check-raises large. Action?',
      choices: const [
        CourseChoice(id: 'rio', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'free', label: 'Call', action: 'CALL'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('KJo vs Nit check-raise — tap Fold.'),
      findsOneWidget,
    );
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'rio');
    controller.dispose();
  });

  testWidgets('s5 implied-odds unguided docks Fold on non-nut FD felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-03-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Non-nut flush draw — fold the domination leak.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Four-way. 7h6h on Kh 9h 2c facing a bet. Action?',
      choices: const [
        CourseChoice(id: 'nonut', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'auto', label: 'Call', action: 'CALL'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Non-nut FD four-way — tap Fold.'),
      findsOneWidget,
    );
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'nonut');
    controller.dispose();
  });

  testWidgets('s5 implied-odds checkpoint taps Depth + pay on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-03-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Depth plus paying tendencies.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Implied odds rise most when?',
      choices: const [
        CourseChoice(
          id: 'depth-pay',
          label: 'Deep stacks and opponents who pay',
        ),
        CourseChoice(id: 'short', label: 'Short stacks always'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Implied odds — tap when they rise most.'),
      findsOneWidget,
    );
    expect(find.text('Depth + pay'), findsOneWidget);
    await tester.tap(find.text('Depth + pay'));
    await tester.pump();
    expect(controller.draft.choiceId, 'depth-pay');
    controller.dispose();
  });

  testWidgets('s5 thin-value guided docks Bet thin value on Station felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-04-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Thin value bet.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'River second pair. Calling Station checked twice. Action?',
      choices: const [
        CourseChoice(
          id: 'tv',
          label: 'Bet thin value',
          action: 'BET',
          amountBb: 7,
        ),
        CourseChoice(id: 'check', label: 'Check always', action: 'CHECK'),
        CourseChoice(
          id: 'overbet',
          label: 'Overbet bluff',
          action: 'BET',
          amountBb: 40,
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    expect(resolveLessonActionSpot(activity)?.heroCodes, ['Jh', '9d']);
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
    expect(
      find.text('Station checked · second pair — tap Bet thin value.'),
      findsOneWidget,
    );
    expect(find.text('Tap your action on the dock.'), findsNothing);
    expect(find.text('Station pays — bet thin value'), findsNothing);
    expect(find.text('Checked to you'), findsOneWidget);
    expect(find.text('BET THIN VALUE'), findsOneWidget);
    await tester.tap(find.text('BET THIN VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'tv');
    controller.dispose();
  });

  testWidgets('s5 thin-value scaffolded docks Call on Maniac felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-04-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Call wider.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Maniac barrels river. You have second pair. Action?',
      choices: const [
        CourseChoice(id: 'call-m', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold-m', label: 'Fold', action: 'FOLD'),
        CourseChoice(
          id: 'raise-m',
          label: 'Hero-raise for ego',
          action: 'RAISE',
          amountBb: 50,
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Maniac barrels second pair — tap Call.'),
      findsOneWidget,
    );
    expect(find.text('Wide barrels — call the catch'), findsNothing);
    expect(find.text('Facing a bet'), findsOneWidget);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call-m');
    controller.dispose();
  });

  testWidgets('s5 thin-value unguided docks Check back on Nit felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-04-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Check back — thin value dies.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Same second pair river. Nit checked to you. Action?',
      choices: const [
        CourseChoice(id: 'check-nit', label: 'Check back', action: 'CHECK'),
        CourseChoice(
          id: 'bet-nit',
          label: 'Bet thin',
          action: 'BET',
          amountBb: 7,
        ),
        CourseChoice(
          id: 'jam-nit',
          label: 'Overbet',
          action: 'BET',
          amountBb: 60,
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Nit checked · second pair — tap Check.'),
      findsOneWidget,
    );
    expect(find.text('Nit overfolds — check back'), findsNothing);
    expect(find.text('Checked to you'), findsOneWidget);
    expect(find.text('CHECK'), findsOneWidget);
    await tester.tap(find.text('CHECK'));
    await tester.pump();
    expect(controller.draft.choiceId, 'check-nit');
    controller.dispose();
  });

  testWidgets('s5 thin-value checkpoint taps The line on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-04-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'The recommendation only when the read justifies it.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Same hand, different types — what must change?',
      choices: const [
        CourseChoice(
          id: 'read',
          label: 'The line — only when the authored read justifies it',
        ),
        CourseChoice(id: 'random', label: 'Flip a coin every time'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Same hand, new type — tap what must change.'),
      findsOneWidget,
    );
    expect(find.text('The line'), findsOneWidget);
    await tester.tap(find.text('The line'));
    await tester.pump();
    expect(controller.draft.choiceId, 'read');
    controller.dispose();
  });

  testWidgets('s5 lines guided taps Value-heavy on Nit XR felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-05-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Strong value-heavy.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Nit check-raises flop. Default read?',
      choices: const [
        CourseChoice(id: 'strong', label: 'Value-heavy — respect'),
        CourseChoice(id: 'air', label: 'Always a bluff'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Nit check-raises — tap the default read.'),
      findsOneWidget,
    );
    expect(find.text('Value-heavy'), findsOneWidget);
    await tester.tap(find.text('Value-heavy'));
    await tester.pump();
    expect(controller.draft.choiceId, 'strong');
    controller.dispose();
  });

  testWidgets('s5 lines scaffolded docks Probe small on BB felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-05-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Small probe can be reasonable.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Preflop raiser checks flop. You are BB with middle pair. Action?',
      choices: const [
        CourseChoice(
          id: 'probe',
          label: 'Probe small',
          action: 'BET',
          amountBb: 4,
        ),
        CourseChoice(
          id: 'huge',
          label: 'Pot-size probe',
          action: 'BET',
          amountBb: 12,
        ),
        CourseChoice(id: 'never', label: 'Check back', action: 'CHECK'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('PFR checks · middle pair BB — tap Probe small.'),
      findsOneWidget,
    );
    expect(find.text('PROBE SMALL'), findsOneWidget);
    await tester.tap(find.text('PROBE SMALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'probe');
    controller.dispose();
  });

  testWidgets('s5 lines unguided taps Polarized on donk felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-05-05-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Often polarized — ace or air.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'BB donks large on A-high dry flop into PFR. Meaning?',
      choices: const [
        CourseChoice(
          id: 'polar',
          label: 'Often polarized — strong or bluff',
        ),
        CourseChoice(id: 'merged', label: 'Always medium pairs'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Large BB donk on dry ace — tap the meaning.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Polarized'));
    await tester.pump();
    expect(controller.draft.choiceId, 'polar');
    controller.dispose();
  });

  testWidgets('s5 lines checkpoint taps After weakness on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-05-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText:
          'Flop check then turn barrel after they show weakness.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Delayed c-bet is best when?',
      choices: const [
        CourseChoice(
          id: 'delay',
          label: 'After flop check takes away their range strength',
        ),
        CourseChoice(id: 'always', label: 'Every hand regardless'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Delayed c-bet — tap when it is best.'),
      findsOneWidget,
    );
    await tester.tap(find.text('After weakness'));
    await tester.pump();
    expect(controller.draft.choiceId, 'delay');
    controller.dispose();
  });

  testWidgets('s5 line-reading guided taps Fewer nuts on bet-check felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-06-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Often capped / weakened.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Villain bets flop, checks turn. Range now?',
      choices: const [
        CourseChoice(id: 'capped', label: 'Capped — fewer nuts'),
        CourseChoice(id: 'nutted', label: 'Still nuts'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Bet flop, check turn — tap Capped.'),
      findsOneWidget,
    );
    expect(find.text('Fewer nuts'), findsOneWidget);
    await tester.tap(find.text('Fewer nuts'));
    await tester.pump();
    expect(controller.draft.choiceId, 'capped');
    controller.dispose();
  });

  testWidgets('s5 line-reading scaffolded docks Fold on draw-bomb felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-06-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Re-price; folding draws is allowed.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'You called flop as a draw. Turn bricks and villain bombs. Action?',
      choices: const [
        CourseChoice(id: 'repr', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'auto', label: 'Call', action: 'CALL'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Draw faces bomb — tap Fold.'),
      findsOneWidget,
    );
    expect(find.text('FOLD'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'repr');
    controller.dispose();
  });

  testWidgets('s5 line-reading unguided taps Rebuild on habit felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-06-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Street-by-street updates.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Best line-reading habit?',
      choices: const [
        CourseChoice(id: 'update', label: 'Rebuild after every action'),
        CourseChoice(id: 'freeze', label: 'Lock flop forever'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Best habit — tap Rebuild.'), findsOneWidget);
    await tester.tap(find.text('Rebuild'));
    await tester.pump();
    expect(controller.draft.choiceId, 'update');
    controller.dispose();
  });

  testWidgets('s5 line-reading checkpoint taps Uncapped on XR line felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-06-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText:
          'Strong uncapped pressure — respect without a read.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Check-raise flop, bet turn, shove river usually means?',
      choices: const [
        CourseChoice(
          id: 'uncap',
          label: 'Uncapped — respect unless type says otherwise',
        ),
        CourseChoice(id: 'bluff', label: 'Always bluff'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('XR / bet / shove — tap Uncapped.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Uncapped'));
    await tester.pump();
    expect(controller.draft.choiceId, 'uncap');
    controller.dispose();
  });

  testWidgets('s5 timing guided taps Soft evidence on shove felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-07-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Soft evidence — not proof.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Instant river shove after you bet. Correct framing?',
      choices: const [
        CourseChoice(id: 'soft', label: 'Soft evidence'),
        CourseChoice(id: 'nuts', label: 'Proven nuts'),
        CourseChoice(id: 'air', label: 'Proven bluff'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Instant shove — tap Soft evidence.'),
      findsOneWidget,
    );
    expect(find.text('Soft evidence'), findsWidgets);
    await tester.tap(find.text('Soft evidence').first);
    await tester.pump();
    expect(controller.draft.choiceId, 'soft');
    controller.dispose();
  });

  testWidgets('s5 timing scaffolded taps Weaker / blocking on sizing felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-07-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Weak or blocking — not solver gospel.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tiny flop bet into a huge pot often says?',
      choices: const [
        CourseChoice(id: 'weakish', label: 'Weaker / blocking'),
        CourseChoice(id: 'solver', label: 'Solver known'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Tiny flop bet — tap Weaker / blocking.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Weaker / blocking'));
    await tester.pump();
    expect(controller.draft.choiceId, 'weakish');
    controller.dispose();
  });

  testWidgets('s5 timing unguided taps Reject on magic-tell felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-07-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Reject magic tells.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Coach says "look left means bluff." Response?',
      choices: const [
        CourseChoice(id: 'reject', label: 'Reject magic tells'),
        CourseChoice(id: 'trust', label: 'Trust the book'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Look-left tell — tap Reject.'), findsOneWidget);
    await tester.tap(find.text('Reject'));
    await tester.pump();
    expect(controller.draft.choiceId, 'reject');
    controller.dispose();
  });

  testWidgets('s5 timing checkpoint taps Tiny update on evidence felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-07-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText:
          'Tiny confidence update alongside stronger evidence.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Best use of live timing?',
      choices: const [
        CourseChoice(id: 'tiny', label: 'Tiny update beside stronger reads'),
        CourseChoice(id: 'only', label: 'Only evidence'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Best use of timing — tap Tiny update.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tiny update'));
    await tester.pump();
    expect(controller.draft.choiceId, 'tiny');
    controller.dispose();
  });

  testWidgets('s5 table-dynamics guided taps Stuck / tilted on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-08-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Stuck/tilted — widen value, choose spots.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Villain lost two buy-ins, now open-raises every hand. Note?',
      choices: const [
        CourseChoice(id: 'stuck', label: 'Stuck / tilted'),
        CourseChoice(id: 'ignore', label: 'Ignore dynamics'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Lost two buy-ins — tap Stuck / tilted.'),
      findsOneWidget,
    );
    expect(find.text('Stuck / tilted'), findsWidgets);
    await tester.tap(find.text('Stuck / tilted').first);
    await tester.pump();
    expect(controller.draft.choiceId, 'stuck');
    controller.dispose();
  });

  testWidgets('s5 dynamics scaffolded taps Gear change on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-08-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Possible gear change — sample again.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Solid selective player suddenly flats junk and donks rivers. Best read?',
      choices: const [
        CourseChoice(id: 'gear', label: 'Gear change'),
        CourseChoice(id: 'same', label: 'Old label'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Flats junk / donks — tap Gear change.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Gear change'));
    await tester.pump();
    expect(controller.draft.choiceId, 'gear');
    controller.dispose();
  });

  testWidgets('s5 table-dynamics unguided docks Fold on steaming felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-08-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Reset or step away — bankroll guardrail.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You are steaming after a cooler. Best action?',
      choices: const [
        CourseChoice(id: 'reset', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'revenge', label: 'All-in', action: 'ALL_IN'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Steaming after cooler — tap Fold.'),
      findsOneWidget,
    );
    expect(find.text('FOLD'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'reset');
    controller.dispose();
  });

  testWidgets('s5 dynamics checkpoint taps Fresh samples on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-08-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Temporary working models with samples.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Dynamic reads should be?',
      choices: const [
        CourseChoice(id: 'temp', label: 'Fresh samples'),
        CourseChoice(id: 'perm', label: 'Permanent seats'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Dynamic reads — tap Fresh samples.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Fresh samples'));
    await tester.pump();
    expect(controller.draft.choiceId, 'temp');
    controller.dispose();
  });

  testWidgets('s5 discipline guided taps Stop / move down on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-09-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Leave or move down — do not reload emotionally.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You hit a planned stop-loss. Next step?',
      choices: const [
        CourseChoice(id: 'stop', label: 'Stop / move down'),
        CourseChoice(id: 'reload', label: 'Reload / chase'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Hit stop-loss — tap Stop / move down.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Stop / move down'));
    await tester.pump();
    expect(controller.draft.choiceId, 'stop');
    controller.dispose();
  });

  testWidgets('s5 discipline scaffolded taps Decline on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-09-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Decline if outside bankroll plan.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Bankroll 40 buy-ins for 1/2. Spot opens at 2/5. Action?',
      choices: const [
        CourseChoice(id: 'decline', label: 'Decline'),
        CourseChoice(id: 'jump', label: 'Jump up'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('2/5 opens — tap Decline.'), findsOneWidget);
    await tester.tap(find.text('Decline'));
    await tester.pump();
    expect(controller.draft.choiceId, 'decline');
    controller.dispose();
  });

  testWidgets('s5 discipline unguided taps Cash out on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-09-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Cash out while ahead of fatigue.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tired, winning small, table getting wild. Best?',
      choices: const [
        CourseChoice(id: 'cash', label: 'Cash out'),
        CourseChoice(id: 'punish', label: 'Stay forever'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Tired and up small — tap Cash out.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cash out'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cash');
    controller.dispose();
  });

  testWidgets('s5 discipline checkpoint taps Your edge on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-09-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Winning strategy — not soft extra credit.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Session discipline is part of?',
      choices: const [
        CourseChoice(id: 'edge', label: 'Your edge'),
        CourseChoice(id: 'soft', label: 'Soft skills only'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Session discipline — tap Your edge.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Your edge'));
    await tester.pump();
    expect(controller.draft.choiceId, 'edge');
    controller.dispose();
  });

  testWidgets('s5 guardrails explain hides interactive footer dupe', (
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
    await tester.pumpWidget(
      _wrap(
        CoachDialogueActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
          onFeltAcknowledge: () {},
        ),
      ),
    );
    expect(find.byType(GuardrailsDemo), findsOneWidget);
    // SoftPulse + Rex own the cue — no Tap QUIT next / bulk coach footer dupe.
    expect(find.text('Tap QUIT next'), findsNothing);
    expect(find.text('Tap Quit, Guard, and First.'), findsNothing);
    expect(find.text('Tap Quit, Guard, and First'), findsNothing);
    expect(find.text('Know when to quit'), findsNothing);
    controller.dispose();
  });

  testWidgets('s5 exit multi taps Nut potential on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-05-09-02-cp-multi',
      order: 1,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Nut potential.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Four-way pot priority?',
      choices: const [
        CourseChoice(id: 'nut', label: 'Nut potential'),
        CourseChoice(id: 'bluff', label: 'Bluff more'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Four-way pot — tap Nut potential.'), findsOneWidget);
    await tester.tap(find.text('Nut potential'));
    await tester.pump();
    expect(controller.draft.choiceId, 'nut');
    controller.dispose();
  });

  testWidgets('s5 exit value docks Bet thin value on station river', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-05-09-02-cp-value',
      order: 2,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Thin value.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'River second pair vs Calling Station. Action?',
      choices: const [
        CourseChoice(
          id: 'bet',
          label: 'Bet thin value',
          action: 'BET',
          amountBb: 8,
        ),
        CourseChoice(
          id: 'bluff',
          label: 'Huge bluff',
          action: 'BET',
          amountBb: 40,
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Station · second pair river — tap Bet thin value.'),
      findsOneWidget,
    );
    expect(find.text('BET THIN VALUE'), findsOneWidget);
    await tester.tap(find.text('BET THIN VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bet');
    controller.dispose();
  });

  testWidgets('s5 exit catch docks Call vs maniac barrel', (tester) async {
    final activity = CourseActivity(
      id: 'act-05-09-02-cp-catch',
      order: 3,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Call.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Maniac river barrel. Second pair. Action?',
      choices: const [
        CourseChoice(id: 'call', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Maniac river barrel — tap Call.'),
      findsOneWidget,
    );
    expect(find.text('CALL'), findsOneWidget);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call');
    controller.dispose();
  });

  testWidgets('s5 exit tell taps Soft evidence on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-05-09-02-cp-tell',
      order: 4,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Nothing absolute.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Instant shove proves?',
      choices: const [
        CourseChoice(id: 'soft', label: 'Soft evidence'),
        CourseChoice(id: 'nuts', label: 'Absolute nuts'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Instant shove — tap Soft evidence.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Soft evidence'));
    await tester.pump();
    expect(controller.draft.choiceId, 'soft');
    controller.dispose();
  });

  testWidgets('s5 exit stop taps Honor stop on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-05-09-02-cp-stop',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Stop.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Hit stop-loss. Do?',
      choices: const [
        CourseChoice(id: 'stop', label: 'Honor stop'),
        CourseChoice(id: 'chase', label: 'Chase'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Hit stop-loss — tap Honor stop.'), findsOneWidget);
    await tester.tap(find.text('Honor stop'));
    await tester.pump();
    expect(controller.draft.choiceId, 'stop');
    controller.dispose();
  });

  testWidgets('s6 range-nut guided taps Preflop raiser on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-01-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Preflop raiser.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'PFR on A-high dry flop. Who often has range advantage?',
      choices: const [
        CourseChoice(id: 'pfr', label: 'Preflop raiser'),
        CourseChoice(id: 'caller', label: 'Flatting BB'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('A-high dry flop — tap Preflop raiser.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Preflop raiser'));
    await tester.pump();
    expect(controller.draft.choiceId, 'pfr');
    controller.dispose();
  });

  testWidgets('s6 range-nut scaffolded taps Wide caller on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-01-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Often the wider caller has more trips/fulls.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Paired board. Caller defends wide. Who may have nut advantage?',
      choices: const [
        CourseChoice(id: 'caller-nuts', label: 'Wide caller'),
        CourseChoice(id: 'pfr-always', label: 'PFR always'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Paired board — tap Wide caller.'), findsOneWidget);
    await tester.tap(find.text('Wide caller'));
    await tester.pump();
    expect(controller.draft.choiceId, 'caller-nuts');
    controller.dispose();
  });

  testWidgets('s6 range-nut unguided docks C-bet on K72r', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-01-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'C-bet with advantage.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You are PFR on K72r. Action with range+nut lean?',
      choices: const [
        CourseChoice(id: 'cbet', label: 'C-bet 6', action: 'BET', amountBb: 6),
        CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'jam', label: 'Jam', action: 'RAISE', amountBb: 200),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(find.text('PFR on K72r — tap C-bet 6.'), findsOneWidget);
    expect(find.text('C-BET 6'), findsOneWidget);
    await tester.tap(find.text('C-BET 6'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cbet');
    controller.dispose();
  });

  testWidgets('s6 range-nut checkpoint taps Apply pressure on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-01-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Apply pressure selectively.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Advantage is a reason to?',
      choices: const [
        CourseChoice(id: 'press', label: 'Apply pressure'),
        CourseChoice(id: 'random', label: 'Bet any two'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Advantage — tap Apply pressure.'), findsOneWidget);
    await tester.tap(find.text('Apply pressure'));
    await tester.pump();
    expect(controller.draft.choiceId, 'press');
    controller.dispose();
  });

  testWidgets('s6 equity guided taps In position on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-02-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'In position.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Same draw OOP vs IP. Where does it realize better?',
      choices: const [
        CourseChoice(id: 'ip', label: 'In position'),
        CourseChoice(id: 'oop', label: 'Out of position'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Same draw — tap In position.'), findsOneWidget);
    await tester.tap(find.text('In position'));
    await tester.pump();
    expect(controller.draft.choiceId, 'ip');
    controller.dispose();
  });

  testWidgets('s6 equity scaffolded taps Discount / fold on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-02-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Discount and fold more.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Weak showdown value OOP facing dual barrels. Default?',
      choices: const [
        CourseChoice(id: 'discount', label: 'Discount / fold'),
        CourseChoice(id: 'hero', label: 'Hero-call'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Weak SDV OOP — tap Discount / fold.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Discount / fold'));
    await tester.pump();
    expect(controller.draft.choiceId, 'discount');
    controller.dispose();
  });

  testWidgets('s6 equity unguided taps Fold equity on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-02-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Realize equity via fold equity + outs.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Semi-bluff check-raise with nut draw IP-denied. Purpose?',
      choices: const [
        CourseChoice(id: 'realize', label: 'Fold equity'),
        CourseChoice(id: 'fancy', label: 'Fancy play'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Nut draw XR — tap Fold equity.'), findsOneWidget);
    await tester.tap(find.text('Fold equity'));
    await tester.pump();
    expect(controller.draft.choiceId, 'realize');
    controller.dispose();
  });

  testWidgets('s6 equity checkpoint taps Position + initiative on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-02-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Position and initiative.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Equity realization rises with?',
      choices: const [
        CourseChoice(id: 'pos', label: 'Position + initiative'),
        CourseChoice(id: 'hope', label: 'Hope alone'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Realization rises with — tap Position + initiative.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Position + initiative'));
    await tester.pump();
    expect(controller.draft.choiceId, 'pos');
    controller.dispose();
  });

  testWidgets('s6 capped guided taps Capped on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-03-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Capped.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Villain checks turn after betting flop. Often?',
      choices: const [
        CourseChoice(id: 'cap', label: 'Capped'),
        CourseChoice(id: 'uncap', label: 'Uncapped'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Checks turn after flop bet — tap Capped.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Capped'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cap');
    controller.dispose();
  });

  testWidgets('s6 capped scaffolded docks Bet thin on river', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-03-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Bet thin / stab.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Villain capped on river. You have thin value. Action?',
      choices: const [
        CourseChoice(id: 'bet', label: 'Bet thin', action: 'BET', amountBb: 10),
        CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Capped river · thin value — tap Bet thin.'),
      findsOneWidget,
    );
    expect(find.text('BET THIN'), findsOneWidget);
    await tester.tap(find.text('BET THIN'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bet');
    controller.dispose();
  });

  testWidgets('s6 capped unguided taps Uncapped on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-03-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Uncapped — respect.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Check-raise flop, bet turn, bomb river. Treat as?',
      choices: const [
        CourseChoice(id: 'uncap', label: 'Uncapped'),
        CourseChoice(id: 'cap2', label: 'Capped air'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('XR flop / bet turn / bomb — tap Uncapped.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Uncapped'));
    await tester.pump();
    expect(controller.draft.choiceId, 'uncap');
    controller.dispose();
  });

  testWidgets('s6 capped checkpoint taps Attack caps on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-03-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Attacking.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Caps are for?',
      choices: const [
        CourseChoice(id: 'attack', label: 'Attack caps'),
        CourseChoice(id: 'fear', label: 'Auto-fold'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Caps are for — tap Attack caps.'), findsOneWidget);
    await tester.tap(find.text('Attack caps'));
    await tester.pump();
    expect(controller.draft.choiceId, 'attack');
    controller.dispose();
  });

  testWidgets('s6 polar guided taps Polarized on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-04-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Polarized.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'River overbet usually wants which shape?',
      choices: const [
        CourseChoice(id: 'polar', label: 'Polarized'),
        CourseChoice(id: 'merged', label: 'Merged'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('River overbet — tap Polarized.'), findsOneWidget);
    await tester.tap(find.text('Polarized'));
    await tester.pump();
    expect(controller.draft.choiceId, 'polar');
    controller.dispose();
  });

  testWidgets('s6 polar scaffolded docks Bet medium on river', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-04-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Merged medium.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Thin value vs station on river. Size shape?',
      choices: const [
        CourseChoice(
          id: 'mid',
          label: 'Bet medium',
          action: 'BET',
          amountBb: 8,
        ),
        CourseChoice(
          id: 'ob',
          label: 'Huge overbet',
          action: 'BET',
          amountBb: 30,
        ),
        CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Thin value vs station — tap Bet medium.'),
      findsOneWidget,
    );
    expect(find.text('BET MEDIUM'), findsOneWidget);
    await tester.tap(find.text('BET MEDIUM'));
    await tester.pump();
    expect(controller.draft.choiceId, 'mid');
    controller.dispose();
  });

  testWidgets('s6 polar unguided taps Tiny bluffs on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-04-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Tiny bets as pure polar bluffs without a story.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Mismatch to avoid?',
      choices: const [
        CourseChoice(id: 'mismatch', label: 'Tiny bluffs'),
        CourseChoice(id: 'ok', label: 'Any size'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Mismatch to avoid — tap Tiny bluffs.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tiny bluffs'));
    await tester.pump();
    expect(controller.draft.choiceId, 'mismatch');
    controller.dispose();
  });

  testWidgets('s6 polar checkpoint taps Thin value on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-04-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Get called by worse / fold out some better sometimes.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Merged betting aims to?',
      choices: const [
        CourseChoice(id: 'thin', label: 'Thin value'),
        CourseChoice(id: 'only-nuts', label: 'Only nuts'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Merged betting aims to — tap Thin value.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Thin value'));
    await tester.pump();
    expect(controller.draft.choiceId, 'thin');
    controller.dispose();
  });

  testWidgets('s6 overbet guided taps Nuts / bluffs on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-05-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Nuts or strong bluffs with blockers.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Best overbet river candidate?',
      choices: const [
        CourseChoice(id: 'polar-ob', label: 'Nuts / bluffs'),
        CourseChoice(id: 'tpwk', label: 'Top pair weak'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Best overbet river — tap Nuts / bluffs.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Nuts / bluffs'));
    await tester.pump();
    expect(controller.draft.choiceId, 'polar-ob');
    controller.dispose();
  });

  testWidgets('s6 overbet scaffolded docks Bet ~20 on turn', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-05-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Around 20.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Pot 20 after half-pot flop. Geometric turn?',
      choices: const [
        CourseChoice(
          id: 'mid',
          label: 'Bet ~20',
          action: 'BET',
          amountBb: 20,
        ),
        CourseChoice(
          id: 'tiny',
          label: 'Bet tiny',
          action: 'BET',
          amountBb: 3,
        ),
        CourseChoice(
          id: 'bomb',
          label: 'Bet 3x pot',
          action: 'BET',
          amountBb: 60,
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Pot 20 after half-pot flop — tap Bet ~20.'),
      findsOneWidget,
    );
    expect(find.text('BET ~20'), findsOneWidget);
    await tester.tap(find.text('BET ~20'));
    await tester.pump();
    expect(controller.draft.choiceId, 'mid');
    controller.dispose();
  });

  testWidgets('s6 overbet unguided taps Avoid on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-05-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Avoid.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Random 3x pot bet with medium strength?',
      choices: const [
        CourseChoice(id: 'avoid', label: 'Avoid'),
        CourseChoice(id: 'yolo', label: 'Always fine'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Random 3x pot medium — tap Avoid.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Avoid'));
    await tester.pump();
    expect(controller.draft.choiceId, 'avoid');
    controller.dispose();
  });

  testWidgets('s6 overbet checkpoint taps Multi-street plan on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-05-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Multi-street stack pressure.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Geometric sizing primarily helps?',
      choices: const [
        CourseChoice(id: 'multi', label: 'Multi-street plan'),
        CourseChoice(id: 'style', label: 'Look flashy'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Geometric sizing helps — tap Multi-street plan.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Multi-street plan'));
    await tester.pump();
    expect(controller.draft.choiceId, 'multi');
    controller.dispose();
  });

  testWidgets('s6 blockers guided taps Ace blocker on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-06-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Ace of the suit.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'River bluff on completed flush board. Better blocker?',
      choices: const [
        CourseChoice(id: 'as', label: 'Ace blocker'),
        CourseChoice(id: 'off', label: 'No blockers'),
        CourseChoice(id: 'ev', label: 'Fake +EV'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Flush-board river bluff — tap Ace blocker.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Ace blocker'));
    await tester.pump();
    expect(controller.draft.choiceId, 'as');
    controller.dispose();
  });

  testWidgets('s6 blockers scaffolded taps Unblock bluffs on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-06-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Unblock bluffs — no flush blockers.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Bluff-catching a river bomb on flush board. Prefer?',
      choices: const [
        CourseChoice(id: 'unblock', label: 'Unblock bluffs'),
        CourseChoice(id: 'block-nuts', label: 'Block their air'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Bluff-catch flush bomb — tap Unblock bluffs.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Unblock bluffs'));
    await tester.pump();
    expect(controller.draft.choiceId, 'unblock');
    controller.dispose();
  });

  testWidgets('s6 blockers unguided taps Tweak evidence on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-06-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Nothing — they tweak choices.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Blockers replace?',
      choices: const [
        CourseChoice(id: 'tweak', label: 'Tweak evidence'),
        CourseChoice(id: 'replace', label: 'Replace all reasoning'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Blockers replace — tap Tweak evidence.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tweak evidence'));
    await tester.pump();
    expect(controller.draft.choiceId, 'tweak');
    controller.dispose();
  });

  testWidgets('s6 blockers checkpoint taps No fake EV on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-06-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'No fabricated EV.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Course stance on solver EV quotes?',
      choices: const [
        CourseChoice(id: 'no', label: 'No fake EV'),
        CourseChoice(id: 'fake', label: 'Invent EVs'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Solver EV quotes — tap No fake EV.'),
      findsOneWidget,
    );
    await tester.tap(find.text('No fake EV'));
    await tester.pump();
    expect(controller.draft.choiceId, 'no');
    controller.dispose();
  });

  testWidgets('s6 defend guided taps Strong catchers on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-07-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Top pair / strong blockers.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Facing a river bet. Best continue?',
      choices: const [
        CourseChoice(id: 'strong', label: 'Strong catchers'),
        CourseChoice(id: 'any', label: 'Any two for %'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Facing a river bet — tap Strong catchers.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Strong catchers'));
    await tester.pump();
    expect(controller.draft.choiceId, 'strong');
    controller.dispose();
  });

  testWidgets('s6 defend scaffolded docks Fold on scary river', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-07-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Fold.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Third pair no blockers on scary river. Default?',
      choices: const [
        CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'call-mdf', label: 'Call for MDF', action: 'CALL'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Third pair scary river — tap Fold.'),
      findsOneWidget,
    );
    expect(find.text('FOLD'), findsOneWidget);
    expect(find.text('CALL FOR MDF'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold');
    controller.dispose();
  });

  testWidgets('s6 defend unguided taps Intuition on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-07-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Intuition only — no fake precision.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'MDF numbers in this course?',
      choices: const [
        CourseChoice(id: 'int', label: 'Intuition'),
        CourseChoice(id: 'pct', label: 'Exact percents'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('MDF numbers — tap Intuition.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Intuition'));
    await tester.pump();
    expect(controller.draft.choiceId, 'int');
    controller.dispose();
  });

  testWidgets('s6 defend checkpoint taps Punish over-bluffs on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-07-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Punish over-bluffing with sensible continues.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Minimum defense goal?',
      choices: const [
        CourseChoice(id: 'punish', label: 'Punish over-bluffs'),
        CourseChoice(id: 'call-all', label: 'Never fold'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Minimum defense goal — tap Punish over-bluffs.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Punish over-bluffs'));
    await tester.pump();
    expect(controller.draft.choiceId, 'punish');
    controller.dispose();
  });

  testWidgets('s6 mix guided docks Check on flopped set', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-08-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Check — protect checking range / induce.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You flop a set. Sometimes?',
      choices: const [
        CourseChoice(id: 'protect', label: 'Check', action: 'CHECK'),
        CourseChoice(id: 'coin', label: 'Always bet', action: 'BET'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(find.text('Flopped set — tap Check.'), findsOneWidget);
    expect(find.text('CHECK'), findsOneWidget);
    expect(find.text('ALWAYS BET'), findsOneWidget);
    await tester.tap(find.text('CHECK'));
    await tester.pump();
    expect(controller.draft.choiceId, 'protect');
    controller.dispose();
  });

  testWidgets('s6 mix scaffolded taps Less bluff on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-08-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Less — they do not fold.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Versus a Calling Station, how much bluff-mixing?',
      choices: const [
        CourseChoice(id: 'less', label: 'Less bluff'),
        CourseChoice(id: 'same', label: 'Same mix'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Vs Calling Station — tap Less bluff.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Less bluff'));
    await tester.pump();
    expect(controller.draft.choiceId, 'less');
    controller.dispose();
  });

  testWidgets('s6 mix unguided taps Need a reason on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-08-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'No.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Randomness for its own sake?',
      choices: const [
        CourseChoice(id: 'no', label: 'Need a reason'),
        CourseChoice(id: 'yes', label: 'Always random'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Randomness for its own sake — tap Need a reason.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Need a reason'));
    await tester.pump();
    expect(controller.draft.choiceId, 'no');
    controller.dispose();
  });

  testWidgets('s6 mix checkpoint taps Purpose freq on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-08-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Frequency with purpose.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Best mix description?',
      choices: const [
        CourseChoice(id: 'freq', label: 'Purpose freq'),
        CourseChoice(id: 'chaos', label: 'Chaos'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Best mix description — tap Purpose freq.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Purpose freq'));
    await tester.pump();
    expect(controller.draft.choiceId, 'freq');
    controller.dispose();
  });

  testWidgets('s6 3bet4bet guided taps High commit on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-09-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Often committed-ish — careful.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: '100bb 4-bet pot. Flop top pair. Default mindset?',
      choices: const [
        CourseChoice(id: 'careful', label: 'High commit'),
        CourseChoice(id: 'deep', label: '300bb deep'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('100bb 4-bet pot · top pair — tap High commit.'),
      findsOneWidget,
    );
    await tester.tap(find.text('High commit'));
    await tester.pump();
    expect(controller.draft.choiceId, 'careful');
    controller.dispose();
  });

  testWidgets('s6 3bet4bet scaffolded docks Small c-bet on miss', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-09-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Small c-bet or give-up — not auto-jam.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'BTN opens, you 3-bet AQo BB, depth 180bb. Flop misses. Action?',
      choices: const [
        CourseChoice(
          id: 'small',
          label: 'Small c-bet',
          action: 'BET',
          amountBb: 8,
        ),
        CourseChoice(
          id: 'jam',
          label: 'Jam forever',
          action: 'ALL_IN',
          amountBb: 180,
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(find.text('Deep 3-bet miss — tap Small c-bet.'), findsOneWidget);
    expect(find.text('SMALL C-BET'), findsOneWidget);
    expect(find.text('JAM FOREVER'), findsOneWidget);
    await tester.tap(find.text('SMALL C-BET'));
    await tester.pump();
    expect(controller.draft.choiceId, 'small');
    controller.dispose();
  });

  testWidgets('s6 3bet4bet unguided taps Avoid ego on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-09-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Avoid.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Light 4-bet bluff with no blockers for ego?',
      choices: const [
        CourseChoice(id: 'avoid', label: 'Avoid ego'),
        CourseChoice(id: 'ego', label: 'Ego 4-bet'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Light 4-bet for ego — tap Avoid ego.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Avoid ego'));
    await tester.pump();
    expect(controller.draft.choiceId, 'avoid');
    controller.dispose();
  });

  testWidgets('s6 3bet4bet checkpoint taps SPR / commit on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-09-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'SPR and commitment thresholds.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Depth change in 3-bet pots mainly changes?',
      choices: const [
        CourseChoice(id: 'spr', label: 'SPR / commit'),
        CourseChoice(id: 'suits', label: 'Felt suits'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Depth change in 3-bet pots — tap SPR / commit.'),
      findsOneWidget,
    );
    await tester.tap(find.text('SPR / commit'));
    await tester.pump();
    expect(controller.draft.choiceId, 'spr');
    controller.dispose();
  });

  testWidgets('s6 hardfolds guided docks Fold vs triple barrels', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-10-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Often fold.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Top pair weak kicker faces triple barrels from a solid unknown. Action?',
      choices: const [
        CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'call', label: 'Call it off'),
        CourseChoice(
          id: 'raise',
          label: 'Hero raise',
          action: 'RAISE',
          amountBb: 40,
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('TPWK vs triple barrels — tap Fold.'),
      findsOneWidget,
    );
    expect(find.text('FOLD'), findsOneWidget);
    expect(find.text('CALL IT OFF'), findsOneWidget);
    expect(find.text('HERO RAISE'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold');
    controller.dispose();
  });

  testWidgets('s6 hardfolds scaffolded taps Cooler on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-10-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Cooler.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'KK loses to AA all-in pre. Review label?',
      choices: const [
        CourseChoice(id: 'cooler', label: 'Cooler'),
        CourseChoice(id: 'mistake', label: 'Fold KK'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('KK loses to AA all-in — tap Cooler.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cooler'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cooler');
    controller.dispose();
  });

  testWidgets('s6 hardfolds unguided taps Ego call on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-10-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Mistake.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Calling because you are "due"?',
      choices: const [
        CourseChoice(id: 'ego', label: 'Ego call'),
        CourseChoice(id: 'ok', label: 'Sound play'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Calling because you are "due" — tap Ego call.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Ego call'));
    await tester.pump();
    expect(controller.draft.choiceId, 'ego');
    controller.dispose();
  });

  testWidgets('s6 hardfolds checkpoint taps Cooler / mistake? on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-10-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Cooler or mistake?',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Review question after a big loss?',
      choices: const [
        CourseChoice(id: 'ask', label: 'Cooler / mistake?'),
        CourseChoice(id: 'rtilt', label: 'Tilt harder'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Review after a big loss — tap Cooler / mistake?.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Cooler / mistake?'));
    await tester.pump();
    expect(controller.draft.choiceId, 'ask');
    controller.dispose();
  });

  testWidgets('s6 selective guided taps Selective + plan on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-11-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Selective entry + disciplined aggression.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Seat folds most hands, then 3-bets and c-bets strong boards. Note?',
      choices: const [
        CourseChoice(id: 'sel', label: 'Selective + plan'),
        CourseChoice(id: 'loose', label: 'Loose passive'),
        CourseChoice(id: 'label', label: 'Label now'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Folds most, then 3-bets / c-bets — tap Selective + plan.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Selective + plan'));
    await tester.pump();
    expect(controller.draft.choiceId, 'sel');
    controller.dispose();
  });

  testWidgets('s6 selective scaffolded taps Disciplined on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-11-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Disciplined — not maniac.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Same seat gives up on turns when called. Observation?',
      choices: const [
        CourseChoice(id: 'disc', label: 'Disciplined'),
        CourseChoice(id: 'mania', label: 'Same maniac'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Gives up on turns when called — tap Disciplined.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Disciplined'));
    await tester.pump();
    expect(controller.draft.choiceId, 'disc');
    controller.dispose();
  });

  testWidgets('s6 selective unguided taps Keep sampling on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-11-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Low.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Two hands of tightness. Confidence?',
      choices: const [
        CourseChoice(id: 'low', label: 'Keep sampling'),
        CourseChoice(id: 'max', label: 'Max certainty'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Two hands of tightness — tap Keep sampling.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Keep sampling'));
    await tester.pump();
    expect(controller.draft.choiceId, 'low');
    controller.dispose();
  });

  testWidgets('s6 selective checkpoint taps Tight · plan · give on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-11-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Tight in, aggressive with discipline.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Best pre-label note bundle?',
      choices: const [
        CourseChoice(id: 'bundle', label: 'Tight · plan · give'),
        CourseChoice(id: 'vibe', label: 'Good haircut'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Best pre-label note bundle — tap Tight · plan · give.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Tight · plan · give'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bundle');
    controller.dispose();
  });

  testWidgets('s6 meet tag guided taps TAG on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-11-02-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'TAG.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Folds most, 3-bets strong, barrels with a plan. Label?',
      choices: const [
        CourseChoice(id: 'tag', label: 'TAG'),
        CourseChoice(id: 'station', label: 'Station'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Folds most, 3-bets strong — tap TAG.'),
      findsOneWidget,
    );
    await tester.tap(find.text('TAG'));
    await tester.pump();
    expect(controller.draft.choiceId, 'tag');
    controller.dispose();
  });

  testWidgets('s6 meet tag scaffolded taps Selective vs extreme on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-11-02-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Entry width and discipline.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'TAG versus Maniac difference?',
      choices: const [
        CourseChoice(id: 'diff', label: 'Selective vs extreme'),
        CourseChoice(id: 'same', label: 'Identical'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('TAG versus Maniac — tap Selective vs extreme.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Selective vs extreme'));
    await tester.pump();
    expect(controller.draft.choiceId, 'diff');
    controller.dispose();
  });

  testWidgets('s6 meet tag unguided taps TAG on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-11-02-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 45,
      accessibilityText: 'TAG.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Seat opens tight, folds to 3-bets, c-bets selectively. Label?',
      choices: const [
        CourseChoice(id: 'tag2', label: 'TAG'),
        CourseChoice(id: 'mania2', label: 'Maniac'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Opens tight, selective c-bets — tap TAG.'),
      findsOneWidget,
    );
    await tester.tap(find.text('TAG'));
    await tester.pump();
    expect(controller.draft.choiceId, 'tag2');
    controller.dispose();
  });

  testWidgets('s6 meet tag checkpoint taps Working model on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-11-02-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Working model.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'TAG is?',
      choices: const [
        CourseChoice(id: 'model', label: 'Working model'),
        CourseChoice(id: 'soul', label: 'Insult'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('TAG is a working model — tap Working model.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Working model'));
    await tester.pump();
    expect(controller.draft.choiceId, 'model');
    controller.dispose();
  });

  testWidgets('s6 adjust tag explain resolves vsTags visual', (tester) async {
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-06-11-03-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Versus TAG: respect raises; do not invent light bluff-raises.',
          objectives: const ['Respect TAG aggression'],
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.vsTags,
    );
  });

  testWidgets(
    'vs-tags explain taps Credit Tighter No light instead of Continue',
    (tester) async {
    final activity = CourseActivity(
      id: 'act-06-11-03-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText:
          'Versus TAG: respect raises; do not invent light bluff-raises.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text:
              'Versus TAG: respect raises; do not invent light bluff-raises.',
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
    expect(find.byType(VsTagsDemo), findsOneWidget);
    expect(find.text('Three TAG plans'), findsOneWidget);
    expect(find.text('Versus TAGs'), findsNothing);
    expect(find.text('Tap CREDIT next'), findsNothing);
    expect(find.text('Tap Credit, Tighter, and No light.'), findsNothing);
    expect(find.text('Tap Credit, Tighter, and No light'), findsNothing);
    expect(
      find.text('Respect heat · steal less · no light XR'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(VsTagsDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('CREDIT'));
    await tester.pump();
    expect(find.text('Tap TIGHTER next'), findsNothing);
    await tester.tap(find.text('TIGHTER'));
    await tester.pump();
    expect(find.text('Tap NO LIGHT next'), findsNothing);
    await tester.tap(find.text('NO LIGHT'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Respect heat · steal less · no light XR'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(VsTagsDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('s6 adjust tag guided docks Fold on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-11-03-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Fold often.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'TAG check-raises flop. You have second pair. Action?',
      choices: const [
        CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'raise', label: 'Rebluff light', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('TAG check-raises second pair — tap Fold.'),
      findsOneWidget,
    );
    expect(find.text('FOLD'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold');
    controller.dispose();
  });

  testWidgets('s6 adjust tag scaffolded docks Tighter fold on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-11-03-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Tighter than vs nit.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Steal BTN vs TAG BB with K9o. Action?',
      choices: const [
        CourseChoice(id: 'fold-k9', label: 'Tighter fold', action: 'FOLD'),
        CourseChoice(id: 'open-wide', label: 'Open any two', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('BTN vs TAG BB with K9o — tap Tighter fold.'),
      findsOneWidget,
    );
    expect(find.text('TIGHTER FOLD'), findsOneWidget);
    await tester.tap(find.text('TIGHTER FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold-k9');
    controller.dispose();
  });

  testWidgets('s6 adjust tag unguided docks Check on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-11-03-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Check more.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'River thin value vs TAG who rarely calls light. Action?',
      choices: const [
        CourseChoice(id: 'check', label: 'Check back', action: 'CHECK'),
        CourseChoice(id: 'bet', label: 'Bet thin always', action: 'BET'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('River thin vs TAG who rarely calls — tap Check.'),
      findsOneWidget,
    );
    expect(find.text('CHECK'), findsOneWidget);
    await tester.tap(find.text('CHECK'));
    await tester.pump();
    expect(controller.draft.choiceId, 'check');
    controller.dispose();
  });

  testWidgets('s6 adjust tag checkpoint taps Selective + disciplined on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-11-03-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Selective aggression / tighter call-downs.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Versus TAG, cite which tendency?',
      choices: const [
        CourseChoice(id: 'cite', label: 'Selective + disciplined'),
        CourseChoice(id: 'vague', label: 'Vibes'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Versus TAG — tap Selective + disciplined.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Selective + disciplined'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cite');
    controller.dispose();
  });

  testWidgets('s6 adjust lag explain resolves vsLags visual', (tester) async {
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-06-12-03-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Versus LAG: trap more, call wider, fancy less.',
          objectives: const ['Widen bluff-catches versus LAG'],
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.vsLags,
    );
  });

  testWidgets(
    'vs-lags explain taps Call Trap Fancy less instead of Continue',
    (tester) async {
    final activity = CourseActivity(
      id: 'act-06-12-03-explain',
      order: 1,
      stage: ActivityStage.explain,
      renderer: ActivityRenderer.coachDialogue,
      estimatedSeconds: 30,
      accessibilityText: 'Versus LAG: trap more, call wider, fancy less.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'm',
          kind: 'dialogue',
          text: 'Versus LAG: trap more, call wider, fancy less.',
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
    expect(find.byType(VsLagsDemo), findsOneWidget);
    expect(find.text('Three LAG plans'), findsOneWidget);
    expect(find.text('Versus LAGs'), findsNothing);
    expect(find.text('Tap CALL next'), findsNothing);
    expect(find.text('Tap Call, Trap, and Fancy less.'), findsNothing);
    expect(find.text('Tap Call, Trap, and Fancy less'), findsNothing);
    expect(
      find.text('Trap more · call wider · fancy less'),
      findsNothing,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
    expect(isTableRegionTapActivity(activity), isTrue);
    final teachHeight =
        tester.getSize(find.byType(VsLagsDemo)).height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(find.text('Tap TRAP next'), findsNothing);
    await tester.tap(find.text('TRAP'));
    await tester.pump();
    expect(find.text('Tap FANCY LESS next'), findsNothing);
    await tester.tap(find.text('FANCY LESS'));
    await tester.pump();
    expect(feltAck, 1);
    // Lock clears enabled / ack — densified shell must stay filled.
    expect(
      find.text('Trap more · call wider · fancy less'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byType(VsLagsDemo)).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('s6 adjust lag guided docks Call on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-12-03-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Call.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'LAG barrels river. You have second pair good kicker. Action?',
      choices: const [
        CourseChoice(id: 'call', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold', label: 'Fold always', action: 'FOLD'),
        CourseChoice(id: 'raise', label: 'Bluff-raise light', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('LAG barrels river · second pair — tap Call.'),
      findsOneWidget,
    );
    expect(find.text('CALL'), findsOneWidget);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call');
    controller.dispose();
  });

  testWidgets('s6 adjust lag scaffolded docks Trap on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-12-03-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Trap / let them bluff sometimes.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You flop top set vs LAG. Line?',
      choices: const [
        CourseChoice(id: 'trap', label: 'Trap / induce', action: 'CHECK'),
        CourseChoice(id: 'repel', label: 'Bet-bet-jam only', action: 'BET'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Top set vs LAG — tap Trap / induce.'),
      findsOneWidget,
    );
    expect(find.text('TRAP / INDUCE'), findsOneWidget);
    await tester.tap(find.text('TRAP / INDUCE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'trap');
    controller.dispose();
  });

  testWidgets('s6 adjust lag unguided taps Usually avoid on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-12-03-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Usually bad.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Inventing triple-barrel bluffs into a LAG?',
      choices: const [
        CourseChoice(id: 'avoid', label: 'Usually avoid'),
        CourseChoice(id: 'more', label: 'Bluff more'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text(
        'Inventing triple-barrel bluffs into a LAG — tap Usually avoid.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Usually avoid'));
    await tester.pump();
    expect(controller.draft.choiceId, 'avoid');
    controller.dispose();
  });

  testWidgets('s6 adjust lag checkpoint taps Wide + pressure on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-12-03-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Wide entry and sustained pressure.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'LAG exploit cites?',
      choices: const [
        CourseChoice(id: 'cite', label: 'Wide + pressure'),
        CourseChoice(id: 'mood', label: 'Vibes'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('LAG exploit cites — tap Wide + pressure.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Wide + pressure'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cite');
    controller.dispose();
  });

  testWidgets('s6 mix five explain resolves exploitEvidence visual', (
    tester,
  ) async {
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-06-13-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Five models. Same cards. Change only with evidence.',
          objectives: const ['Adjust across all five types'],
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.exploitEvidence,
    );
    expect(
      isTableRegionTapActivity(
        CourseActivity(
          id: 'act-06-13-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Five models. Same cards. Change only with evidence.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ),
      isTrue,
    );
  });

  testWidgets('s6 mix five guided docks Bet thin value on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-13-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Thin value.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'River second pair. Versus Calling Station?',
      choices: const [
        CourseChoice(id: 'cs', label: 'Bet thin value', action: 'BET'),
        CourseChoice(id: 'cs-bluff', label: 'Huge bluff', action: 'BET'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('River second pair vs Calling Station — tap Bet thin value.'),
      findsOneWidget,
    );
    expect(find.text('BET THIN VALUE'), findsOneWidget);
    await tester.tap(find.text('BET THIN VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cs');
    controller.dispose();
  });

  testWidgets('s6 mix five scaffolded docks Fold on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-13-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Fold.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Same hand. Versus Nit who check-raised. Action?',
      choices: const [
        CourseChoice(id: 'nit', label: 'Fold', action: 'FOLD'),
        CourseChoice(id: 'nit-call', label: 'Call light', action: 'CALL'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Same hand · Nit check-raises — tap Fold.'),
      findsOneWidget,
    );
    expect(find.text('FOLD'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'nit');
    controller.dispose();
  });

  testWidgets('s6 mix five unguided docks Call on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-13-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Call.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Same hand. LAG barrels. Action?',
      choices: const [
        CourseChoice(id: 'lag', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'lag-fold', label: 'Auto-fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Same hand · LAG barrels — tap Call.'),
      findsOneWidget,
    );
    expect(find.text('CALL'), findsOneWidget);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'lag');
    controller.dispose();
  });

  testWidgets('s6 mix five checkpoint taps TAG — respect on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-13-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 45,
      accessibilityText: 'TAG — respect.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Selective entry + disciplined barrels. Label + line vs their raise?',
      choices: const [
        CourseChoice(id: 'tag', label: 'TAG — respect the raise'),
        CourseChoice(id: 'wrong', label: 'Calling Station — bluff more'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Selective entry + disciplined barrels — tap TAG — respect.'),
      findsOneWidget,
    );
    await tester.tap(find.text('TAG — respect'));
    await tester.pump();
    expect(controller.draft.choiceId, 'tag');
    controller.dispose();
  });

  testWidgets('s6 section checkpoint taps Range advantage on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-13-02-cp-adv',
      order: 1,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Range advantage.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'PFR on dry A-high often has?',
      choices: const [
        CourseChoice(id: 'ra', label: 'Range advantage'),
        CourseChoice(id: 'none', label: 'No concept applies'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('PFR on dry A-high — tap Range advantage.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Range advantage'));
    await tester.pump();
    expect(controller.draft.choiceId, 'ra');
    controller.dispose();
  });

  testWidgets('s6 section checkpoint taps More capped on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-13-02-cp-cap',
      order: 2,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Capped.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Check-back turn often makes river range?',
      choices: const [
        CourseChoice(id: 'cap', label: 'More capped'),
        CourseChoice(id: 'uncap', label: 'More uncapped nuts'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Check-back turn — tap More capped.'), findsOneWidget);
    await tester.tap(find.text('More capped'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cap');
    controller.dispose();
  });

  testWidgets('s6 section checkpoint taps Polarized on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-13-02-cp-polar',
      order: 3,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Polar.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'River overbet shape?',
      choices: const [
        CourseChoice(id: 'polar', label: 'Polarized'),
        CourseChoice(id: 'merged', label: 'Always merged thin value'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('River overbet shape — tap Polarized.'), findsOneWidget);
    await tester.tap(find.text('Polarized'));
    await tester.pump();
    expect(controller.draft.choiceId, 'polar');
    controller.dispose();
  });

  testWidgets('s6 section checkpoint taps TAG on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-13-02-cp-tag',
      order: 4,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'TAG.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tight entry, planned barrels. Label?',
      choices: const [
        CourseChoice(id: 'tag', label: 'TAG'),
        CourseChoice(id: 'lag', label: 'LAG'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Tight entry, planned barrels — tap TAG.'),
      findsOneWidget,
    );
    await tester.tap(find.text('TAG'));
    await tester.pump();
    expect(controller.draft.choiceId, 'tag');
    controller.dispose();
  });

  testWidgets('s6 section checkpoint taps LAG on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-13-02-cp-lag',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'LAG.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Wide entry, sustained pressure, some folds. Label?',
      choices: const [
        CourseChoice(id: 'lag', label: 'LAG'),
        CourseChoice(id: 'nit', label: 'Nit'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Wide entry, sustained pressure — tap LAG.'),
      findsOneWidget,
    );
    await tester.tap(find.text('LAG'));
    await tester.pump();
    expect(controller.draft.choiceId, 'lag');
    controller.dispose();
  });

  testWidgets('s6 lag observe explain resolves widePressure visual', (tester) async {
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-06-12-01-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'Before labels: wide entry plus pressure that still has a plan. Count samples.',
          objectives: const ['Note wide entry'],
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.widePressure,
    );
  });

  testWidgets(
    's6 lag observe explain taps Wide Pressure Sample instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-12-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Before labels: wide entry plus pressure that still has a plan. Count samples.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Note wide entry'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text:
                'Before labels: wide entry plus pressure that still has a plan. Count samples.',
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
      expect(find.byType(WidePressureDemo), findsOneWidget);
      expect(find.text('Tap WIDE next'), findsNothing);
      expect(find.text('Tap Wide, Pressure, and Sample.'), findsNothing);
      expect(find.text('Tap Wide, Pressure, and Sample'), findsNothing);
      expect(
        find.text('Wide in · pressure on · count samples'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('WIDE'));
      await tester.pump();
      expect(find.text('Tap PRESSURE next'), findsNothing);
      await tester.tap(find.text('PRESSURE'));
      await tester.pump();
      expect(find.text('Tap SAMPLE next'), findsNothing);
      await tester.tap(find.text('SAMPLE'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s6 lag observe guided taps Wide + pressure on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-12-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Wide + sustained but not mindless.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Seat opens many hands and barrels often but folds some turn raises. Note?',
      choices: const [
        CourseChoice(id: 'wide', label: 'Wide + pressure'),
        CourseChoice(id: 'nit', label: 'Nit'),
        CourseChoice(id: 'label', label: 'Label now'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Wide opens + barrels, some folds — tap Wide + pressure.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Wide + pressure'));
    await tester.pump();
    expect(controller.draft.choiceId, 'wide');
    controller.dispose();
  });

  testWidgets('s6 lag observe scaffolded taps Some folds on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-12-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'This seat still folds sometimes; maniac rarely.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Difference brewing vs maniac?',
      choices: const [
        CourseChoice(id: 'sep', label: 'Some folds'),
        CourseChoice(id: 'same', label: 'No difference'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Difference vs maniac — tap Some folds.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Some folds'));
    await tester.pump();
    expect(controller.draft.choiceId, 'sep');
    controller.dispose();
  });

  testWidgets('s6 lag observe unguided taps Keep sampling on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-12-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'No.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Label after one wide open?',
      choices: const [
        CourseChoice(id: 'wait', label: 'Keep sampling'),
        CourseChoice(id: 'now', label: 'Label now'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('One wide open — tap Keep sampling.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Keep sampling'));
    await tester.pump();
    expect(controller.draft.choiceId, 'wait');
    controller.dispose();
  });

  testWidgets('s6 lag observe checkpoint taps Wide · barrels · folds on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-12-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Wide + pressure + some discipline.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Best pre-label note bundle?',
      choices: const [
        CourseChoice(id: 'bundle', label: 'Wide · barrels · folds'),
        CourseChoice(id: 'soul', label: 'Seem loud'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Best pre-label notes — tap Wide · barrels · folds.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Wide · barrels · folds'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bundle');
    controller.dispose();
  });

  testWidgets('s6 meet lag explain resolves lagModel not callingStation', (
    tester,
  ) async {
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-06-12-02-explain',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText:
              'LAG: wide in, pressure on — still a working model.',
          objectives: const ['Introduce LAG'],
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      CoachDialogueVisualKind.lagModel,
    );
    // Blob-only (no id match) must not treat bare "working model" as Station.
    expect(
      resolveCoachDialogueVisual(
        CourseActivity(
          id: 'act-generic-working-model-only',
          order: 1,
          stage: ActivityStage.explain,
          renderer: ActivityRenderer.coachDialogue,
          estimatedSeconds: 30,
          accessibilityText: 'Still a working model.',
          acceptedGrades: const [SoftGrade.recommended],
        ),
      ).kind,
      isNot(CoachDialogueVisualKind.callingStation),
    );
  });

  testWidgets(
    's6 meet lag explain taps Wide Pressure Model instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-06-12-02-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'LAG: wide in, pressure on — still a working model.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Introduce LAG'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'LAG: wide in, pressure on — still a working model.',
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
      expect(find.byType(LagModelDemo), findsOneWidget);
      expect(find.text('Tap WIDE next'), findsNothing);
      expect(find.text('Tap Wide, Pressure, and Model.'), findsNothing);
      expect(find.text('Tap Wide, Pressure, and Model'), findsNothing);
      expect(
        find.text('Wide in, pressure on — a working model'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('WIDE'));
      await tester.pump();
      expect(find.text('Tap PRESSURE next'), findsNothing);
      await tester.tap(find.text('PRESSURE'));
      await tester.pump();
      expect(find.text('Tap MODEL next'), findsNothing);
      await tester.tap(find.text('MODEL'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s6 meet lag guided taps LAG on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-12-02-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'LAG.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Opens wide, barrels often, folds some raises. Label?',
      choices: const [
        CourseChoice(id: 'lag', label: 'LAG'),
        CourseChoice(id: 'tag', label: 'TAG'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Opens wide, barrels often — tap LAG.'),
      findsOneWidget,
    );
    await tester.tap(find.text('LAG'));
    await tester.pump();
    expect(controller.draft.choiceId, 'lag');
    controller.dispose();
  });

  testWidgets('s6 meet lag scaffolded taps Pressure vs passive on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-12-02-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'LAG raises; station calls.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'LAG vs Calling Station?',
      choices: const [
        CourseChoice(id: 'diff', label: 'Pressure vs passive'),
        CourseChoice(id: 'same', label: 'Same exploit'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('LAG vs Station — tap Pressure vs passive.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Pressure vs passive'));
    await tester.pump();
    expect(controller.draft.choiceId, 'diff');
    controller.dispose();
  });

  testWidgets('s6 meet lag unguided taps LAG on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-06-12-02-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 45,
      accessibilityText: 'LAG.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Wide opens, 3-bets light, keeps barreling. Label?',
      choices: const [
        CourseChoice(id: 'lag2', label: 'LAG'),
        CourseChoice(id: 'nit2', label: 'Nit'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Wide opens, keeps barreling — tap LAG.'),
      findsOneWidget,
    );
    await tester.tap(find.text('LAG'));
    await tester.pump();
    expect(controller.draft.choiceId, 'lag2');
    controller.dispose();
  });

  testWidgets('s6 meet lag checkpoint taps Sample limits on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-06-12-02-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Sample/confidence limits.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Show beside LAG label?',
      choices: const [
        CourseChoice(id: 'limits', label: 'Sample limits'),
        CourseChoice(id: 'destiny', label: 'Destiny'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Beside LAG label — tap Sample limits.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Sample limits'));
    await tester.pump();
    expect(controller.draft.choiceId, 'limits');
    controller.dispose();
  });

  testWidgets('s4 meet nit guided taps Nit on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-04-07-02-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'Nit.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Seat plays ~8% of hands and 3-bets rarely but large. Label?',
      choices: const [
        CourseChoice(id: 'pt-nit', label: 'Nit'),
        CourseChoice(id: 'pt-station-n', label: 'Calling Station'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Rare entry, large 3-bets — tap the working label.'),
      findsOneWidget,
    );
    expect(find.text('Nit'), findsOneWidget);
    await tester.tap(find.text('Nit'));
    await tester.pump();
    expect(controller.draft.choiceId, 'pt-nit');
    controller.dispose();
  });

  testWidgets('s4 adjust nit guided docks steal on button felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-04-07-03-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Open wider steal versus nit big blind.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Nit in BB. You have K9o on BTN. Action?',
      choices: const [
        CourseChoice(id: 'steal', label: 'Open / steal', action: 'RAISE'),
        CourseChoice(id: 'fold-k9', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Nit in the BB — tap Open / steal with K9o.'),
      findsOneWidget,
    );
    expect(find.text('OPEN / STEAL'), findsOneWidget);
    await tester.tap(find.text('OPEN / STEAL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'steal');
    controller.dispose();
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
    expect(find.text('Try: Hole cards'), findsOneWidget);
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
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(spot), isTrue);
    final scene = resolveLessonTableScene(spot);
    expect(scene?.layout, LessonTableLayout.handRankSpotOutcomes);
    expect(scene?.heroCodes, ['Ac', '3d']);
    expect(scene?.boardCodes, ['Kc', '9c', '4c', '7c', '2s']);
    expect(
      mapTableRegionToChoiceId(
        activityId: spot.id,
        region: LessonTableRegion.handRankFlush,
        choices: spot.choices,
      ),
      'cat-flush',
    );
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
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(showdown), isTrue);
    expect(
      resolveLessonTableScene(showdown)?.layout,
      LessonTableLayout.handRankShowdownOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: showdown.id,
        region: LessonTableRegion.handRankYouWin,
        choices: showdown.choices,
      ),
      'you-win',
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
    // Rex owns "Tap weakest to strongest" — SoftPulse owns the next tile.
    expect(find.text('Tap weakest to strongest.'), findsOneWidget);
    expect(find.text('Tap to place'), findsNothing);
    expect(find.text('Tap High card'), findsNothing);
    expect(find.byType(HandExampleTile), findsNWidgets(3));
    expect(find.byType(ActionChip), findsNothing);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('hand-order-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    await tester.tap(find.text('High card'));
    await tester.pump();
    expect(find.text('Tap One pair'), findsNothing);
    await tester.tap(find.text('One pair'));
    await tester.pump();
    expect(find.text('Tap Flush'), findsNothing);
    await tester.tap(find.text('Flush'));
    await tester.pump();
    expect(controller.draft.orderedIds, ['hr-high', 'hr-pair', 'hr-flush']);
    expect(find.text('Checking…'), findsOneWidget);
    // Densified shell stays filled through Checking…
    expect(
      tester.getSize(find.byKey(const ValueKey('hand-order-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
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
    expect(find.text('Order these ranks from lowest to highest.'), findsOneWidget);
    // Rex + SoftPulse own the cue — no duplicate status / Tap to place.
    expect(find.text('Tap lowest first'), findsNothing);
    expect(find.text('Tap low → high'), findsNothing);
    expect(find.text('Tap to place'), findsNothing);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('rank-order-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    await tester.tap(find.text('2').last);
    await tester.pump();
    await tester.tap(find.text('3').last);
    await tester.pump();
    await tester.tap(find.text('4').last);
    await tester.pump();
    expect(controller.draft.orderedIds, ['r2', 'r3', 'r4']);
    expect(find.text('Checking…'), findsOneWidget);
    // Densified shell stays filled through Checking…
    expect(
      tester.getSize(find.byKey(const ValueKey('rank-order-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets('hand ranks spot taps Flush on densified felt', (tester) async {
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
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.handRankSpotOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.handRankFlush,
        choices: activity.choices,
      ),
      'cat-flush',
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
      find.text('Board and holes show five clubs — tap what you made.'),
      findsOneWidget,
    );
    expect(find.text('Tap what you made.'), findsNothing);
    expect(find.byType(HandExampleTile), findsNothing);
    expect(find.text('Flush'), findsOneWidget);
    expect(find.text('Five clubs'), findsOneWidget);
    // SoftPulse + Rex own the cue — no Tap footer mid-teach.
    expect(find.text('Tap Flush.'), findsNothing);
    expect(find.text('One pair'), findsOneWidget);
    expect(find.text('Straight'), findsOneWidget);
    expect(
      find.textContaining('Look at the board and your holes'),
      findsNothing,
    );

    await tester.tap(find.text('Flush'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cat-flush');
    controller.dispose();
  });

  testWidgets('hand ranks showdown taps You on densified felt', (tester) async {
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
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.handRankShowdownOutcomes,
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.handRankYouWin,
        choices: activity.choices,
      ),
      'you-win',
    );
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.handRankChop,
        choices: activity.choices,
      ),
      'split',
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
      find.text('Flush vs straight on the river — tap who wins.'),
      findsOneWidget,
    );
    expect(find.text('Showdown — tap who wins.'), findsNothing);
    expect(find.text('Chop the pot'), findsNothing);
    expect(find.text('Tap You or Them on the felt.'), findsNothing);
    expect(find.byType(HandExampleTile), findsNothing);
    // Spot rail + outcome tile both label You / Them.
    expect(find.text('You'), findsWidgets);
    expect(find.text('Them'), findsWidgets);
    expect(find.text('Chop'), findsOneWidget);
    expect(find.text('Club flush'), findsOneWidget);
    expect(find.text('Straight?'), findsOneWidget);
    expect(find.text('Split pot?'), findsOneWidget);
    // Checkpoint: no SoftPulse spoiler cue.
    expect(find.text('Tap You.'), findsNothing);

    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;
    await tester.tap(find.text('Club flush'));
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
      find.byKey(const ValueKey('best-five-picker-felt')),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('best-five-picker-felt'))).height,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );
    expect(
      find.text('Only five cards count — tap the ones that play.'),
      findsOneWidget,
    );
    expect(find.text('0/5 selected'), findsOneWidget);
    expect(find.textContaining('You hold Ah'), findsNothing);
    expect(find.text('BOARD · shared'), findsOneWidget);

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

  testWidgets('kicker showdown taps You on densified felt', (tester) async {
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
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveLessonTableScene(activity)?.layout,
      LessonTableLayout.kickerShowdownOutcomes,
    );
    expect(resolveLessonTableScene(activity)?.villainCodes, ['As', 'Jd']);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.handRankYouWin,
        choices: activity.choices,
      ),
      'you-kicker',
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
      find.text('Same pair of kings — tap who wins on kickers.'),
      findsOneWidget,
    );
    expect(find.text('Tap who wins.'), findsNothing);
    expect(find.text('Chop the pot'), findsNothing);
    expect(find.text('Tap You or Them on the felt.'), findsNothing);
    expect(find.byType(HandExampleTile), findsNothing);
    expect(find.text('Queen kicker'), findsOneWidget);
    expect(find.text('Jack kicker?'), findsOneWidget);
    expect(find.text('Same pair ties?'), findsOneWidget);
    // SoftPulse + Rex own the cue — no Tap You. footer under the felt.
    expect(find.text('Tap You.'), findsNothing);
    expect(find.text('Them'), findsWidgets);

    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('outcome-phases-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    var autoSubmits = 0;
    controller.onAutoSubmit = () => autoSubmits += 1;
    await tester.tap(find.text('Queen kicker'));
    await tester.pump();
    expect(controller.draft.choiceId, 'you-kicker');
    expect(autoSubmits, 1);
    controller.dispose();
  });

  testWidgets('board chop taps the felt board, not choice tiles', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-02-02-unguided-board',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap chop when the board plays',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Both checked down — tap who takes the pot.',
      choices: const [
        CourseChoice(id: 'chop-broadway', label: 'Chop — both play the board'),
        CourseChoice(id: 'button-wins', label: 'Button wins automatically'),
        CourseChoice(id: 'high-card-wins', label: 'Higher hole card wins'),
      ],
    );
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
    );
    final scene = resolveLessonTableScene(activity);
    expect(scene?.boardCodes, ['Ac', 'Kc', 'Qc', 'Jc', 'Tc']);
    expect(scene?.heroCodes, ['2h', '2d']);
    expect(
      mapTableRegionToChoiceId(
        activityId: activity.id,
        region: LessonTableRegion.board,
        choices: activity.choices,
      ),
      'chop-broadway',
    );
    expect(resolveHandExample(id: 'high-card-wins')?.codes, ['2h', '2d']);

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
    expect(
      find.text('Both checked down — tap who takes the pot.'),
      findsOneWidget,
    );
    expect(find.textContaining('broadway clubs'), findsNothing);
    expect(find.text('Chop — board plays'), findsNothing);
    // Rex already owns the cue — no third status line.
    expect(find.text('Tap the answer on the table.'), findsNothing);
    // SoftPulse invite under the board + densified felt (~58% height).
    expect(find.text('Tap the board'), findsOneWidget);
    final teachHeight = tester
        .getSize(find.byKey(const ValueKey('hole-cards-felt')))
        .height;
    expect(
      teachHeight,
      moreOrLessEquals(
        tester.view.physicalSize.height /
            tester.view.devicePixelRatio *
            0.58,
        epsilon: 1,
      ),
    );

    final boardCards = find.byWidgetPredicate(
      (w) =>
          w is MiniCard &&
          (w.size == MiniCardSize.hero || w.size == MiniCardSize.small),
    );
    // SoftPulse board teach uses hero-sized board cards.
    expect(
      find.byWidgetPredicate(
        (w) => w is MiniCard && w.size == MiniCardSize.hero,
      ),
      findsAtLeastNWidgets(5),
    );
    expect(boardCards, findsAtLeastNWidgets(5));
    await tester.tap(boardCards.first);
    await tester.pump();
    expect(controller.draft.choiceId, 'chop-broadway');
    expect(find.text('Board plays — everyone chops'), findsOneWidget);
    // Densified shell must stay filled after the board tap.
    expect(
      tester.getSize(find.byKey(const ValueKey('hole-cards-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );

    controller.finishSubmit(
      _result(
        grade: SoftGrade.recommended,
        accepted: true,
        lifeLost: false,
      ),
    );
    await tester.pump();
    expect(find.text('Checking…'), findsNothing);
    expect(find.text('Tap the answer on the table.'), findsNothing);
    expect(
      tester.getSize(find.byKey(const ValueKey('hole-cards-felt'))).height,
      moreOrLessEquals(teachHeight, epsilon: 1),
    );
    controller.dispose();
  });

  testWidgets(
    's7 preflop flop explain taps Reason Confirm Cancel instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-01-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Enter with a reason. Flop confirms or cancels.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['State a preflop thesis'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Enter with a reason. Flop confirms or cancels.',
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
      expect(find.byType(PreflopFlopPlanDemo), findsOneWidget);
      expect(find.text('Tap REASON next'), findsNothing);
      expect(find.text('Tap Reason, Confirm, and Cancel.'), findsNothing);
      expect(find.text('Tap Reason, Confirm, and Cancel'), findsNothing);
      expect(
        find.text('Reason in · flop confirms or cancels'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('REASON'));
      await tester.pump();
      expect(find.text('Tap CONFIRM next'), findsNothing);
      await tester.tap(find.text('CONFIRM'));
      await tester.pump();
      expect(find.text('Tap CANCEL next'), findsNothing);
      await tester.tap(find.text('CANCEL'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s7 preflop flop guided taps Plan is sick on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-01-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Give up more — plan dead.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'You 3-bet AQo for value. Flop 872tt. Update?',
      choices: const [
        CourseChoice(id: 'dead', label: 'Plan is sick — give up more'),
        CourseChoice(id: 'jam', label: 'Still jam every street'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('AQo 3-bet · 872tt — tap Plan is sick.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Plan is sick'));
    await tester.pump();
    expect(controller.draft.choiceId, 'dead');
    controller.dispose();
  });

  testWidgets('s7 preflop flop scaffolded taps Value continues on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-01-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Value continues.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'BTN steal with KTo. Flop KT2r. Update?',
      choices: const [
        CourseChoice(id: 'value', label: 'Value plan continues'),
        CourseChoice(id: 'fold', label: 'Auto-fold top two'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('BTN steal KTo · KT2r — tap Value continues.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Value continues'));
    await tester.pump();
    expect(controller.draft.choiceId, 'value');
    controller.dispose();
  });

  testWidgets('s7 preflop flop unguided taps Name the thesis on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-01-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Write the thesis before flop.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Best habit?',
      choices: const [
        CourseChoice(
          id: 'thesis',
          label: 'Name the preflop reason before acting flop',
        ),
        CourseChoice(id: 'vibes', label: 'Wing it every street'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Best habit — tap Name the thesis.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Name the thesis'));
    await tester.pump();
    expect(controller.draft.choiceId, 'thesis');
    controller.dispose();
  });

  testWidgets('s7 preflop flop checkpoint taps Abandon quickly on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-01-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Abandon quickly.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Dead plan response?',
      choices: const [
        CourseChoice(id: 'abandon', label: 'Abandon quickly'),
        CourseChoice(id: 'force', label: 'Force the old line'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Dead plan — tap Abandon quickly.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Abandon quickly'));
    await tester.pump();
    expect(controller.draft.choiceId, 'abandon');
    controller.dispose();
  });

  testWidgets(
    's7 turn map explain taps Continue Give-up Map instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-02-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Flop bet needs a turn map. Continue or kill.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['List turn continue cards'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Flop bet needs a turn map. Continue or kill.',
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
      expect(find.byType(TurnMapDemo), findsOneWidget);
      expect(find.text('Tap BARREL next'), findsNothing);
      expect(find.text('Tap Barrel, Give-up, and Map.'), findsNothing);
      expect(find.text('Tap Barrel, Give-up, and Map'), findsNothing);
      expect(
        find.text('List continue and give-up cards before you bet'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('BARREL'));
      await tester.pump();
      expect(find.text('Tap GIVE-UP next'), findsNothing);
      await tester.tap(find.text('GIVE-UP'));
      await tester.pump();
      expect(find.text('Tap MAP next'), findsNothing);
      await tester.tap(find.text('MAP'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s7 turn map guided taps Aces & blanks on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-02-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'A/K or blanks that keep equity.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'C-betting AK on Q72r. Good turn continue?',
      choices: const [
        CourseChoice(
          id: 'ok',
          label: 'Aces, kings, and many blanks with a plan',
        ),
        CourseChoice(
          id: 'any',
          label: 'Any card including four-to-flush always',
        ),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('AK c-bet · Q72r — tap Aces & blanks.'),
      findsOneWidget,
    );
    expect(find.text('BOARD · shared'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(resolveLessonTableScene(activity)?.heroCodes, ['Ah', 'Kd']);
    expect(
      resolveLessonTableScene(activity)?.boardCodes,
      ['Qs', '7h', '2c'],
    );
    await tester.tap(find.text('Aces & blanks'));
    await tester.pump();
    expect(controller.draft.choiceId, 'ok');
    controller.dispose();
  });

  testWidgets('s7 turn map scaffolded taps Give up on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-02-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Often give up.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'You c-bet a gutshot. Turn bricks and they raise big. Map says?',
      choices: const [
        CourseChoice(id: 'give', label: 'Give up — map included this kill'),
        CourseChoice(
          id: 'hero',
          label: 'Hero-call because flop bet exists',
        ),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Gutshot · brick raise — tap Give up.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Give up'));
    await tester.pump();
    expect(controller.draft.choiceId, 'give');
    controller.dispose();
  });

  testWidgets('s7 turn map unguided taps Map first on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-02-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Avoid.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Bet flop with no turn idea?',
      choices: const [
        CourseChoice(id: 'avoid', label: 'Avoid — map first'),
        CourseChoice(id: 'yolo', label: 'Yolo barrels'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('No turn idea — tap Map first.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Map first'));
    await tester.pump();
    expect(controller.draft.choiceId, 'avoid');
    controller.dispose();
  });

  testWidgets('s7 turn map checkpoint taps Continue/kill list on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-02-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Continue vs kill list.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Turn map is?',
      choices: const [
        CourseChoice(
          id: 'list',
          label: 'A continue/kill list made on the flop',
        ),
        CourseChoice(
          id: 'later',
          label: 'Something you invent after you are stuck',
        ),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Turn map — tap Continue/kill list.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Continue/kill list'));
    await tester.pump();
    expect(controller.draft.choiceId, 'list');
    controller.dispose();
  });

  testWidgets(
    's7 river composition explain taps Value Bluff Check instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-03-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'River: value if they call worse; bluff if they fold better.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Choose river value candidates'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'River: value if they call worse; bluff if they fold better.',
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
      expect(find.byType(RiverCompositionDemo), findsOneWidget);
      expect(find.text('Tap VALUE next'), findsNothing);
      expect(find.text('Tap Value, Bluff, and Hold.'), findsNothing);
      expect(find.text('Tap Value, Bluff, and Hold'), findsNothing);
      expect(
        find.text('Value needs calls · bluffs need folds · check trash'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('VALUE'));
      await tester.pump();
      expect(find.text('Tap BLUFF next'), findsNothing);
      await tester.tap(find.text('BLUFF'));
      await tester.pump();
      expect(find.text('Tap HOLD next'), findsNothing);
      await tester.tap(find.text('HOLD'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s7 river composition guided docks Value bet on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-03-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Value bet.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Thick value vs station. Size?',
      choices: const [
        CourseChoice(id: 'val', label: 'Value bet', action: 'BET'),
        CourseChoice(id: 'check', label: 'Check to be fancy'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Thick value vs station — tap Value bet.'),
      findsOneWidget,
    );
    expect(find.text('VALUE BET'), findsOneWidget);
    await tester.tap(find.text('VALUE BET'));
    await tester.pump();
    expect(controller.draft.choiceId, 'val');
    controller.dispose();
  });

  testWidgets('s7 river composition scaffolded taps Blocks strong calls on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-03-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Blocks their calling flushes.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Bluff river with nut flush blocker. Why?',
      choices: const [
        CourseChoice(id: 'block', label: 'Blocks strong calls'),
        CourseChoice(
          id: 'ev',
          label: 'Because a fake EV sheet said +0.02',
        ),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Nut flush blocker — tap Blocks strong calls.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Blocks strong calls'));
    await tester.pump();
    expect(controller.draft.choiceId, 'block');
    controller.dispose();
  });

  testWidgets('s7 river composition unguided taps Check on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-03-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Check.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'No value, no blockers, no fold equity. River?',
      choices: const [
        CourseChoice(id: 'check', label: 'Check'),
        CourseChoice(id: 'spew', label: 'Blast off'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('No story — tap Check.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Check'));
    await tester.pump();
    expect(controller.draft.choiceId, 'check');
    controller.dispose();
  });

  testWidgets('s7 river composition checkpoint taps Value needs calls on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-03-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Value needs calls; bluffs need folds.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'River composition rule?',
      choices: const [
        CourseChoice(
          id: 'rule',
          label: 'Value needs calls; bluffs need folds',
        ),
        CourseChoice(id: 'random', label: 'Bet every river for style'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('River rule — tap Value needs calls.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Value needs calls'));
    await tester.pump();
    expect(controller.draft.choiceId, 'rule');
    controller.dispose();
  });

  testWidgets(
    's7 pot type explain taps Limped SRP 3-4bet instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-04-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Pot type sets ranges and SPR. Plan accordingly.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Plan single-raised pots'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Pot type sets ranges and SPR. Plan accordingly.',
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
      expect(find.byType(PotTypePlansDemo), findsOneWidget);
      expect(find.text('Tap LIMPED next'), findsNothing);
      expect(find.text('Tap Limped, SRP, and 3-4bet.'), findsNothing);
      expect(find.text('Tap Limped, SRP, and 3-4bet'), findsNothing);
      expect(
        find.text('Pot type sets ranges and SPR — plan accordingly'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('LIMPED'));
      await tester.pump();
      expect(find.text('Tap SRP next'), findsNothing);
      await tester.tap(find.text('SRP'));
      await tester.pump();
      expect(find.text('Tap 3-4BET next'), findsNothing);
      await tester.tap(find.text('3-4BET'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s7 pot type guided taps Nut potential on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-04-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Nut potential / stronger made hands.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Multiway limped pot. Priority?',
      choices: const [
        CourseChoice(
          id: 'nuts',
          label: 'Nut potential and strong made hands',
        ),
        CourseChoice(id: 'air', label: 'Pure air stabs always'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Multiway limped — tap Nut potential.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Nut potential'));
    await tester.pump();
    expect(controller.draft.choiceId, 'nuts');
    controller.dispose();
  });

  testWidgets('s7 pot type scaffolded taps C-bet maps on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-04-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'C-bets with turn maps.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Heads-up SRP IP. Default weapon?',
      choices: const [
        CourseChoice(id: 'cb', label: 'C-bets with turn maps'),
        CourseChoice(id: 'check', label: 'Never bet'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('HU SRP IP — tap C-bet maps.'),
      findsOneWidget,
    );
    await tester.tap(find.text('C-bet maps'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cb');
    controller.dispose();
  });

  testWidgets('s7 pot type unguided taps Higher commitment on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-04-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'High commitment — tighter.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: '4-bet pot 100bb. Mindset?',
      choices: const [
        CourseChoice(
          id: 'commit',
          label: 'Higher commitment — fewer spewy bluffs',
        ),
        CourseChoice(id: 'deep', label: 'Play like 300bb deep'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('4-bet 100bb — tap Higher commitment.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Higher commitment'));
    await tester.pump();
    expect(controller.draft.choiceId, 'commit');
    controller.dispose();
  });

  testWidgets('s7 pot type checkpoint taps Ranges and SPR on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-04-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Ranges and SPR.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Pot type changes?',
      choices: const [
        CourseChoice(id: 'both', label: 'Ranges and SPR'),
        CourseChoice(id: 'nothing', label: 'Nothing material'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Pot type — tap Ranges and SPR.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Ranges and SPR'));
    await tester.pump();
    expect(controller.draft.choiceId, 'both');
    controller.dispose();
  });

  testWidgets(
    's7 hu multiway explain taps Fewer Thicker Widen instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-05-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'More players: fewer bluffs, thicker value.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Bluff less multiway'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'More players: fewer bluffs, thicker value.',
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
      expect(find.byType(HuVsMultiwayDemo), findsOneWidget);
      expect(find.text('Tap FEWER next'), findsNothing);
      expect(find.text('Tap Fewer, Thicker, and Widen.'), findsNothing);
      expect(find.text('Tap Fewer, Thicker, and Widen'), findsNothing);
      expect(
        find.text('More players: fewer bluffs, thicker value'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('FEWER'));
      await tester.pump();
      expect(find.text('Tap THICKER next'), findsNothing);
      await tester.tap(find.text('THICKER'));
      await tester.pump();
      expect(find.text('Tap WIDEN next'), findsNothing);
      await tester.tap(find.text('WIDEN'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s7 hu multiway guided taps Usually no on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-05-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Usually no.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Four-way river. Naked air bluff?',
      choices: const [
        CourseChoice(id: 'no', label: 'Usually no'),
        CourseChoice(id: 'yes', label: 'Always yes'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Four-way river — tap Usually no.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Usually no'));
    await tester.pump();
    expect(controller.draft.choiceId, 'no');
    controller.dispose();
  });

  testWidgets('s7 hu multiway scaffolded taps Higher HU on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-05-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Higher HU.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'HU vs nit BB. Steal frequency vs multiway limped?',
      choices: const [
        CourseChoice(id: 'higher', label: 'Higher heads-up versus the nit'),
        CourseChoice(id: 'same', label: 'Identical always'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('HU vs nit — tap Higher HU.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Higher HU'));
    await tester.pump();
    expect(controller.draft.choiceId, 'higher');
    controller.dispose();
  });

  testWidgets('s7 hu multiway unguided taps Thicker value on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-05-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Thicker value / protection.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Multiway top set. Line lean?',
      choices: const [
        CourseChoice(id: 'thick', label: 'Thicker value and protection'),
        CourseChoice(id: 'slow', label: 'Ultra-slow every time'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Multiway top set — tap Thicker value.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Thicker value'));
    await tester.pump();
    expect(controller.draft.choiceId, 'thick');
    controller.dispose();
  });

  testWidgets('s7 hu multiway checkpoint taps First-class input on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-05-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'A first-class input.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Player count is?',
      choices: const [
        CourseChoice(id: 'input', label: 'A first-class planning input'),
        CourseChoice(id: 'ignore', label: 'Noise'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Player count — tap First-class input.'),
      findsOneWidget,
    );
    await tester.tap(find.text('First-class input'));
    await tester.pump();
    expect(controller.draft.choiceId, 'input');
    controller.dispose();
  });

  testWidgets(
    's7 stack explain taps Short Deep Effective instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-06-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Effective stack rewrites the plan every hand.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Recalculate effective stacks each hand'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Effective stack rewrites the plan every hand.',
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
      expect(find.byType(StackDepthPlansDemo), findsOneWidget);
      expect(find.text('Tap SHORT next'), findsNothing);
      expect(find.text('Tap Short, Deep, and Effective.'), findsNothing);
      expect(find.text('Tap Short, Deep, and Effective'), findsNothing);
      expect(
        find.text('Effective stack rewrites the plan every hand'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('SHORT'));
      await tester.pump();
      expect(find.text('Tap DEEP next'), findsNothing);
      await tester.tap(find.text('DEEP'));
      await tester.pump();
      expect(find.text('Tap EFFECTIVE next'), findsNothing);
      await tester.tap(find.text('EFFECTIVE'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s7 stack guided taps Closer to stacking on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-06-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Closer to committed.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: '35bb effective. Top pair strong kicker vs raise. Lean?',
      choices: const [
        CourseChoice(
          id: 'commit',
          label: 'Closer to stacking — SPR is low',
        ),
        CourseChoice(id: 'deep', label: 'Play as 250bb deep'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('35bb TPTK — tap Closer to stacking.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Closer to stacking'));
    await tester.pump();
    expect(controller.draft.choiceId, 'commit');
    controller.dispose();
  });

  testWidgets('s7 stack scaffolded taps More attractive on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-06-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'More attractive.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: '250bb. Set-mine 55?',
      choices: const [
        CourseChoice(id: 'yes', label: 'More attractive with depth'),
        CourseChoice(id: 'no', label: 'Never set-mine deep'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('250bb 55 — tap More attractive.'),
      findsOneWidget,
    );
    await tester.tap(find.text('More attractive'));
    await tester.pump();
    expect(controller.draft.choiceId, 'yes');
    controller.dispose();
  });

  testWidgets('s7 stack unguided taps 40bb on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-06-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: '40bb.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Hero 200bb, villain 40bb. Effective?',
      choices: const [
        CourseChoice(id: '40', label: '40bb'),
        CourseChoice(id: '200', label: '200bb'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Hero 200 / Villain 40 — tap 40bb.'),
      findsOneWidget,
    );
    await tester.tap(find.text('40bb'));
    await tester.pump();
    expect(controller.draft.choiceId, '40');
    controller.dispose();
  });

  testWidgets('s7 stack checkpoint taps Every hand on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-06-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Plan input every hand.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Stack depth is?',
      choices: const [
        CourseChoice(id: 'every', label: 'Recalculated every hand'),
        CourseChoice(id: 'once', label: 'Set once per lifetime'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Stack depth — tap Every hand.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Every hand'));
    await tester.pump();
    expect(controller.draft.choiceId, 'every');
    controller.dispose();
  });

  testWidgets(
    's7 same cards explain taps Cards Models Cite instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-07-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Same cards. Five models. Cite the tendency.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Change lines by type with citations'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Same cards. Five models. Cite the tendency.',
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
      expect(find.byType(SameCardsTypesDemo), findsOneWidget);
      expect(find.text('Tap CARDS next'), findsNothing);
      expect(find.text('Tap Cards, Models, and Cite.'), findsNothing);
      expect(find.text('Tap Cards, Models, and Cite'), findsNothing);
      expect(
        find.text('Change lines only when the tendency justifies it'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('CARDS'));
      await tester.pump();
      expect(find.text('Tap MODELS next'), findsNothing);
      await tester.tap(find.text('MODELS'));
      await tester.pump();
      expect(find.text('Tap CITE next'), findsNothing);
      await tester.tap(find.text('CITE'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s7 same cards guided docks Bet for value on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-07-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Bet value.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Flop top pair. Station check. Action?',
      choices: const [
        CourseChoice(id: 'bet', label: 'Bet for value', action: 'BET'),
        CourseChoice(id: 'check', label: 'Check always', action: 'CHECK'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Flop top pair · Station check — tap Bet for value.'),
      findsOneWidget,
    );
    expect(find.text('BET FOR VALUE'), findsOneWidget);
    await tester.tap(find.text('BET FOR VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bet');
    controller.dispose();
  });

  testWidgets('s7 same cards scaffolded docks Fold on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-07-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Fold/more careful.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Same top pair. TAG check-raises. Action?',
      choices: const [
        CourseChoice(id: 'fold', label: 'Fold more often', action: 'FOLD'),
        CourseChoice(id: 'bluff', label: 'Rebluff light', action: 'RAISE'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Same top pair · TAG check-raises — tap Fold.'),
      findsOneWidget,
    );
    expect(find.text('FOLD'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold');
    controller.dispose();
  });

  testWidgets('s7 same cards unguided docks Call on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-07-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Call.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Same top pair. LAG barrels turn. Action?',
      choices: const [
        CourseChoice(id: 'call', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold', label: 'Auto-fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Same top pair · LAG barrels — tap Call.'),
      findsOneWidget,
    );
    expect(find.text('CALL'), findsOneWidget);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call');
    controller.dispose();
  });

  testWidgets('s7 same cards checkpoint taps Baseline on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-07-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Baseline strategy.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'No type evidence yet. Default?',
      choices: const [
        CourseChoice(id: 'base', label: 'Baseline strategy'),
        CourseChoice(id: 'guess', label: 'Guess a type and overfit'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('No type evidence — tap Baseline.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Baseline'));
    await tester.pump();
    expect(controller.draft.choiceId, 'base');
    controller.dispose();
  });

  testWidgets(
    's7 type board explain taps Type Board Line Size instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-08-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Type × board × line × size. One answer.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Produce one coherent action'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Type × board × line × size. One answer.',
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
      expect(find.byType(TypeBoardLineDemo), findsOneWidget);
      expect(find.text('TYPE'), findsOneWidget);
      expect(find.text('BOARD'), findsOneWidget);
      expect(find.text('LINE'), findsOneWidget);
      expect(find.text('SIZE'), findsOneWidget);
      expect(find.text('Tap TYPE next'), findsNothing);
      expect(find.text('Tap Type, Board, Line, and Size.'), findsNothing);
      expect(find.text('Tap Type, Board, Line, and Size'), findsNothing);
      expect(
        find.text('One coherent action from all four inputs'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      // Densify tiles stay one-line labels (no BOAR/D wrap overflow).
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('TYPE'));
      await tester.pump();
      expect(find.text('Tap BOARD next'), findsNothing);
      await tester.tap(find.text('BOARD'));
      await tester.pump();
      expect(find.text('Tap LINE next'), findsNothing);
      await tester.tap(find.text('LINE'));
      await tester.pump();
      expect(find.text('Tap SIZE next'), findsNothing);
      await tester.tap(find.text('SIZE'));
      await tester.pump();
      expect(feltAck, 1);
      expect(tester.takeException(), isNull);
      controller.dispose();
    },
  );

  testWidgets('s7 type board guided docks Call on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-08-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Call.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Wet board. Maniac overbets turn. Second pair. Action?',
      choices: const [
        CourseChoice(id: 'call', label: 'Call', action: 'CALL'),
        CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Wet board · Maniac overbet — tap Call.'),
      findsOneWidget,
    );
    expect(find.text('CALL'), findsOneWidget);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call');
    controller.dispose();
  });

  testWidgets('s7 type board scaffolded docks Raise on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-08-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Raise/bluff more available.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Dry board. Nit tiny turn bet. Air. Action?',
      choices: const [
        CourseChoice(
          id: 'raise',
          label: 'Raise as a bluff candidate',
          action: 'RAISE',
        ),
        CourseChoice(id: 'call', label: 'Call air', action: 'CALL'),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Dry board · Nit tiny bet — tap Raise.'),
      findsOneWidget,
    );
    expect(find.text('RAISE AS A BLUFF CANDIDATE'), findsNothing);
    expect(find.text('RAISE BLUFF'), findsOneWidget);
    expect(find.text('CALL AIR'), findsOneWidget);
    await tester.tap(find.text('RAISE BLUFF'));
    await tester.pump();
    expect(controller.draft.choiceId, 'raise');
    controller.dispose();
  });

  testWidgets('s7 type board unguided docks Fold on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-08-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.pokerActionSizing,
      estimatedSeconds: 55,
      accessibilityText: 'Fold.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'TAG pots river after strong line. Second pair. Action?',
      choices: const [
        CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
        CourseChoice(
          id: 'hero',
          label: 'Hero-call for storytime',
          action: 'CALL',
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('TAG pots river · second pair — tap Fold.'),
      findsOneWidget,
    );
    expect(find.text('FOLD'), findsOneWidget);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold');
    controller.dispose();
  });

  testWidgets('s7 type board checkpoint taps All four on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-08-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'All four inputs.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Integrated decision uses?',
      choices: const [
        CourseChoice(
          id: 'four',
          label: 'Type, board, line, and sizing together',
        ),
        CourseChoice(id: 'one', label: 'Only hole card beauty'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Integrated decision — tap All four.'),
      findsOneWidget,
    );
    await tester.tap(find.text('All four'));
    await tester.pump();
    expect(controller.draft.choiceId, 'four');
    controller.dispose();
  });

  testWidgets(
    's7 leak explain taps Leak Book Review instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-09-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Defaults beat vibes. Write the book; review leaks.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Write default lines for common spots'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Defaults beat vibes. Write the book; review leaks.',
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
      expect(find.byType(LeakReviewBookDemo), findsOneWidget);
      expect(find.text('Tap LEAK next'), findsNothing);
      expect(find.text('Tap Leak, Book, and Review.'), findsNothing);
      expect(find.text('Tap Leak, Book, and Review'), findsNothing);
      expect(
        find.text('Defaults beat vibes — write and review'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('LEAK'));
      await tester.pump();
      expect(find.text('Tap BOOK next'), findsNothing);
      await tester.tap(find.text('BOOK'));
      await tester.pump();
      expect(find.text('Tap REVIEW next'), findsNothing);
      await tester.tap(find.text('REVIEW'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s7 leak guided taps Specific note on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-09-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Specific and actionable.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Best leak note?',
      choices: const [
        CourseChoice(
          id: 'spec',
          label: 'I overcall river vs unknowns — fold more second pair',
        ),
        CourseChoice(id: 'vague', label: 'I am bad'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Best leak note — tap Specific note.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Specific note'));
    await tester.pump();
    expect(controller.draft.choiceId, 'spec');
    controller.dispose();
  });

  testWidgets('s7 leak scaffolded taps Written range on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-09-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'A written range family.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Default BTN vs unknown BB open?',
      choices: const [
        CourseChoice(
          id: 'book',
          label: 'A written range family from your book',
        ),
        CourseChoice(id: 'mood', label: 'Whatever mood says'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('BTN vs unknown BB — tap Written range.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Written range'));
    await tester.pump();
    expect(controller.draft.choiceId, 'book');
    controller.dispose();
  });

  testWidgets('s7 leak unguided taps On a schedule on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-09-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'After sessions / on a schedule.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'When to review the book?',
      choices: const [
        CourseChoice(id: 'sched', label: 'After sessions on a schedule'),
        CourseChoice(id: 'never', label: 'Never — memory is enough'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Review the book — tap On a schedule.'),
      findsOneWidget,
    );
    await tester.tap(find.text('On a schedule'));
    await tester.pump();
    expect(controller.draft.choiceId, 'sched');
    controller.dispose();
  });

  testWidgets('s7 leak checkpoint taps Baseline on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-09-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Baseline before exploits.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Default book purpose?',
      choices: const [
        CourseChoice(id: 'base', label: 'Baseline before exploits'),
        CourseChoice(id: 'replace', label: 'Replace all thinking forever'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
      find.text('Default book purpose — tap Baseline.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Baseline'));
    await tester.pump();
    expect(controller.draft.choiceId, 'base');
    controller.dispose();
  });

  testWidgets(
    's7 capstone srp explain taps Plan Update Finish instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-10-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Capstone SRP. No hints. Trust your map.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Execute a full SRP plan'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Capstone SRP. No hints. Trust your map.',
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
      expect(find.byType(CapstoneSrpDemo), findsOneWidget);
      expect(find.text('Tap PLAN next'), findsNothing);
      expect(find.text('Tap Plan, Update, and Finish.'), findsNothing);
      expect(find.text('Tap Plan, Update, and Finish'), findsNothing);
      expect(
        find.text('No hints — trust your map across three streets'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('PLAN'));
      await tester.pump();
      expect(find.text('Tap UPDATE next'), findsNothing);
      await tester.tap(find.text('UPDATE'));
      await tester.pump();
      expect(find.text('Tap FINISH next'), findsNothing);
      await tester.tap(find.text('FINISH'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s7 capstone srp hand docks C-bet on flop felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-10-01-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'BTN open, BB call. Play three streets.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-flop',
          street: 'flop',
          prompt: 'BTN, SRP, board K72r, you have AQ. Action?',
          choices: [
            CourseChoice(id: 'cb', label: 'C-bet', action: 'BET', amountBb: 6),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
            CourseChoice(
              id: 'jam',
              label: 'Jam 150bb',
              action: 'RAISE',
              amountBb: 150,
            ),
          ],
        ),
        CourseHandStep(
          id: 'step-turn',
          street: 'turn',
          prompt: 'Called. Turn 2d. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Barrel blanks',
              action: 'BET',
              amountBb: 14,
            ),
            CourseChoice(
              id: 'check-t',
              label: 'Give up',
              action: 'CHECK',
            ),
            CourseChoice(id: 'min', label: 'Bet 1bb', action: 'BET', amountBb: 1),
          ],
        ),
        CourseHandStep(
          id: 'step-river',
          street: 'river',
          prompt: 'Called again. River 9c. Ace-high. Action?',
          choices: [
            CourseChoice(
              id: 'check-r',
              label: 'Check',
              action: 'CHECK',
            ),
            CourseChoice(
              id: 'bluff',
              label: 'Bluff large',
              action: 'BET',
              amountBb: 40,
            ),
            CourseChoice(id: 'tiny', label: 'Bet 1bb', action: 'BET', amountBb: 1),
          ],
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(find.text('BTN SRP on K72r — tap Bet.'), findsOneWidget);
    expect(find.textContaining('Flop · K72r · AQ'), findsOneWidget);
    expect(find.text('BET'), findsOneWidget);
    expect(
      find.text('BTN, SRP, board K72r, you have AQ. Action?'),
      findsNothing,
    );
    await tester.tap(find.text('BET'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cb');
    controller.dispose();
  });

  testWidgets('s7 srp hand docks Barrel on turn felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-10-01-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'BTN open, BB call. Play three streets.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-flop',
          street: 'flop',
          prompt: 'BTN, SRP, board K72r, you have AQ. Action?',
          choices: [
            CourseChoice(id: 'cb', label: 'C-bet', action: 'BET'),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-turn',
          street: 'turn',
          prompt: 'Called. Turn 2d. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Barrel blanks',
              action: 'BET',
              amountBb: 14,
            ),
            CourseChoice(
              id: 'check-t',
              label: 'Give up',
              action: 'CHECK',
            ),
            CourseChoice(id: 'min', label: 'Bet 1bb', action: 'BET', amountBb: 1),
          ],
        ),
        CourseHandStep(
          id: 'step-river',
          street: 'river',
          prompt: 'Called again. River 9c. Ace-high. Action?',
          choices: [
            CourseChoice(id: 'check-r', label: 'Check', action: 'CHECK'),
            CourseChoice(
              id: 'bluff',
              label: 'Bluff large',
              action: 'BET',
            ),
          ],
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    final controller = LessonActivityController(activity: activity);
    controller.setHandStepIndex(1);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(
      find.text('Called · paired blank — tap Barrel blanks.'),
      findsOneWidget,
    );
    expect(find.textContaining('Turn · K722 · AQ'), findsOneWidget);
    expect(find.text('BARREL BLANKS'), findsOneWidget);
    expect(find.text('Called. Turn 2d. Action?'), findsNothing);
    await tester.tap(find.text('BARREL BLANKS'));
    await tester.pump();
    expect(controller.draft.choiceId, 'barrel');
    controller.dispose();
  });

  testWidgets('s7 srp hand docks Check on river felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-10-01-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'BTN open, BB call. Play three streets.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-flop',
          street: 'flop',
          prompt: 'BTN, SRP, board K72r, you have AQ. Action?',
          choices: [
            CourseChoice(id: 'cb', label: 'C-bet', action: 'BET'),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-turn',
          street: 'turn',
          prompt: 'Called. Turn 2d. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Barrel blanks',
              action: 'BET',
            ),
            CourseChoice(
              id: 'check-t',
              label: 'Give up',
              action: 'CHECK',
            ),
          ],
        ),
        CourseHandStep(
          id: 'step-river',
          street: 'river',
          prompt: 'Called again. River 9c. Ace-high. Action?',
          choices: [
            CourseChoice(
              id: 'check-r',
              label: 'Check',
              action: 'CHECK',
            ),
            CourseChoice(
              id: 'bluff',
              label: 'Bluff large',
              action: 'BET',
              amountBb: 40,
            ),
            CourseChoice(id: 'tiny', label: 'Bet 1bb', action: 'BET', amountBb: 1),
          ],
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    final controller = LessonActivityController(activity: activity);
    controller.setHandStepIndex(2);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('Ace-high on 9c — tap Check.'), findsOneWidget);
    expect(find.textContaining('River · K7229 · ace-high'), findsOneWidget);
    expect(find.text('CHECK'), findsOneWidget);
    expect(
      find.text('Called again. River 9c. Ace-high. Action?'),
      findsNothing,
    );
    await tester.tap(find.text('CHECK'));
    await tester.pump();
    expect(controller.draft.choiceId, 'check-r');
    controller.dispose();
  });

  testWidgets(
    's7 capstone 3bet explain taps SPR Continue Close instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-10-02-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Capstone 3-bet. Short prompts. No hints.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Plan a 3-bet pot by SPR'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Capstone 3-bet. Short prompts. No hints.',
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
      expect(find.byType(Capstone3betDemo), findsOneWidget);
      expect(find.text('Tap SPR next'), findsNothing);
      expect(find.text('Tap SPR, Turn, and Close.'), findsNothing);
      expect(find.text('Tap SPR, Turn, and Close'), findsNothing);
      expect(
        find.text('Short prompts — plan by SPR, then close clean'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);

      await tester.tap(find.text('SPR'));
      await tester.pump();
      expect(find.text('Tap TURN next'), findsNothing);
      await tester.tap(find.text('TURN'));
      await tester.pump();
      expect(find.text('Tap CLOSE next'), findsNothing);
      await tester.tap(find.text('CLOSE'));
      await tester.pump();
      expect(feltAck, 1);
      controller.dispose();
    },
  );

  testWidgets('s7 capstone 3bet hand docks C-bet value on flop felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-10-02-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'You 3-bet TAG open with AQ; 120bb deep.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-3b-flop',
          street: 'flop',
          prompt: 'Flop Q83tt. Action?',
          choices: [
            CourseChoice(
              id: 'bet',
              label: 'C-bet value',
              action: 'BET',
              amountBb: 10,
            ),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-3b-turn',
          street: 'turn',
          prompt: 'Called. Turn 2d. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Continue value',
              action: 'BET',
              amountBb: 22,
            ),
            CourseChoice(id: 'check-t', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-3b-river',
          street: 'river',
          prompt: 'TAG check-raises huge. Action?',
          choices: [
            CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
            CourseChoice(id: 'call', label: 'Call', action: 'CALL'),
            CourseChoice(
              id: 'jam',
              label: 'Rejam for ego',
              action: 'RAISE',
              amountBb: 90,
            ),
          ],
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('3-bet pot · Q83tt — tap C-bet value.'),
      findsOneWidget,
    );
    expect(find.textContaining('Flop · Q83tt · AQ'), findsOneWidget);
    expect(find.text('C-BET VALUE'), findsOneWidget);
    expect(find.text('Flop Q83tt. Action?'), findsNothing);
    await tester.tap(find.text('C-BET VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bet');
    controller.dispose();
  });

  testWidgets('s7 capstone 3bet hand docks Continue value on turn felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-10-02-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'You 3-bet TAG open with AQ; 120bb deep.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-3b-flop',
          street: 'flop',
          prompt: 'Flop Q83tt. Action?',
          choices: [
            CourseChoice(id: 'bet', label: 'C-bet value', action: 'BET'),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-3b-turn',
          street: 'turn',
          prompt: 'Called. Turn 2d. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Continue value',
              action: 'BET',
              amountBb: 22,
            ),
            CourseChoice(id: 'check-t', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-3b-river',
          street: 'river',
          prompt: 'TAG check-raises huge. Action?',
          choices: [
            CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
            CourseChoice(id: 'call', label: 'Call', action: 'CALL'),
          ],
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    final controller = LessonActivityController(activity: activity);
    controller.setHandStepIndex(1);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(
      find.text('Called · blank turn — tap Continue value.'),
      findsOneWidget,
    );
    expect(find.textContaining('Turn · Q832 · AQ'), findsOneWidget);
    expect(find.text('CONTINUE VALUE'), findsOneWidget);
    expect(find.text('Called. Turn 2d. Action?'), findsNothing);
    await tester.tap(find.text('CONTINUE VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'barrel');
    controller.dispose();
  });

  testWidgets('s7 capstone 3bet hand docks Fold on river felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-10-02-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'You 3-bet TAG open with AQ; 120bb deep.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-3b-flop',
          street: 'flop',
          prompt: 'Flop Q83tt. Action?',
          choices: [
            CourseChoice(id: 'bet', label: 'C-bet value', action: 'BET'),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-3b-turn',
          street: 'turn',
          prompt: 'Called. Turn 2d. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Continue value',
              action: 'BET',
            ),
            CourseChoice(id: 'check-t', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-3b-river',
          street: 'river',
          prompt: 'TAG check-raises huge. Action?',
          choices: [
            CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
            CourseChoice(id: 'call', label: 'Call', action: 'CALL'),
            CourseChoice(
              id: 'jam',
              label: 'Rejam for ego',
              action: 'RAISE',
              amountBb: 90,
            ),
          ],
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
    final controller = LessonActivityController(activity: activity);
    controller.setHandStepIndex(2);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(
      find.text('TAG check-raises huge — tap Fold.'),
      findsOneWidget,
    );
    expect(find.textContaining('River · Q8327 · TPTK'), findsOneWidget);
    expect(find.text('FOLD'), findsOneWidget);
    expect(find.text('TAG check-raises huge. Action?'), findsNothing);
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold');
    controller.dispose();
  });

  testWidgets(
    's7 capstone mw deep explain taps Nuts Deep No-bluff instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-10-03-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Capstone multiway deep. No hints.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Prefer nut potential multiway'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Capstone multiway deep. No hints.',
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
      expect(find.byType(CapstoneMultiwayDeepDemo), findsOneWidget);
      expect(find.text('Tap NUTS next'), findsNothing);
      expect(find.text('Tap Nuts, Deep, and No-bluff.'), findsNothing);
      expect(find.text('Tap Nuts, Deep, and No-bluff'), findsNothing);
      expect(
        find.text('Deep multiway — chase nuts, skip light bluffs'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight =
          tester.getSize(find.byType(CapstoneMultiwayDeepDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(
          tester.view.physicalSize.height /
              tester.view.devicePixelRatio *
              0.58,
          epsilon: 1,
        ),
      );

      await tester.tap(find.text('NUTS'));
      await tester.pump();
      expect(find.text('Tap DEEP next'), findsNothing);
      await tester.tap(find.text('DEEP'));
      await tester.pump();
      expect(find.text('Tap NO-BLUFF next'), findsNothing);
      await tester.tap(find.text('NO-BLUFF'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(
        find.text('Deep multiway — chase nuts, skip light bluffs'),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(CapstoneMultiwayDeepDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
      controller.dispose();
    },
  );

  testWidgets('s7 capstone mw deep hand docks Call on flop felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-10-03-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'Four-way, 200bb, you hold AhQh.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-mw-flop',
          street: 'flop',
          prompt: 'Flop Jh 8h 2c. Bet into you. Action?',
          choices: [
            CourseChoice(id: 'call', label: 'Call', action: 'CALL'),
            CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
            CourseChoice(
              id: 'bluffjam',
              label: 'Bluff-jam off',
              action: 'RAISE',
              amountBb: 80,
            ),
          ],
        ),
        CourseHandStep(
          id: 'step-mw-turn',
          street: 'turn',
          prompt: 'Turn 3d. Checked to you. Action?',
          choices: [
            CourseChoice(
              id: 'bet',
              label: 'Bet semi-bluff',
              action: 'BET',
              amountBb: 18,
            ),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-mw-river',
          street: 'river',
          prompt: 'River 9c misses. Two players behind. Action?',
          choices: [
            CourseChoice(
              id: 'check-r',
              label: 'Check',
              action: 'CHECK',
            ),
            CourseChoice(
              id: 'bluff',
              label: 'Blast bluff both',
              action: 'BET',
              amountBb: 60,
            ),
          ],
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(
      find.text('Deep multiway · flush draw — tap Call.'),
      findsOneWidget,
    );
    expect(find.textContaining('Flop · Jh8h2c · AQs'), findsOneWidget);
    expect(find.text('CALL'), findsOneWidget);
    expect(find.text('Flop Jh 8h 2c. Bet into you. Action?'), findsNothing);
    await tester.tap(find.text('CALL'));
    await tester.pump();
    expect(controller.draft.choiceId, 'call');
    controller.dispose();
  });

  testWidgets('s7 capstone mw deep hand docks Bet semi-bluff on turn felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-10-03-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'Four-way, 200bb, you hold AhQh.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-mw-flop',
          street: 'flop',
          prompt: 'Flop Jh 8h 2c. Bet into you. Action?',
          choices: [
            CourseChoice(id: 'call', label: 'Call', action: 'CALL'),
            CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
          ],
        ),
        CourseHandStep(
          id: 'step-mw-turn',
          street: 'turn',
          prompt: 'Turn 3d. Checked to you. Action?',
          choices: [
            CourseChoice(
              id: 'bet',
              label: 'Bet semi-bluff',
              action: 'BET',
              amountBb: 18,
            ),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-mw-river',
          street: 'river',
          prompt: 'River 9c misses. Two players behind. Action?',
          choices: [
            CourseChoice(
              id: 'check-r',
              label: 'Check',
              action: 'CHECK',
            ),
            CourseChoice(
              id: 'bluff',
              label: 'Blast bluff both',
              action: 'BET',
            ),
          ],
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.setHandStepIndex(1);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(
      find.text('Turn checked · nut draw — tap Bet semi-bluff.'),
      findsOneWidget,
    );
    expect(find.textContaining('Turn · Jh8h2c3d · AQs'), findsOneWidget);
    expect(find.text('BET SEMI-BLUFF'), findsOneWidget);
    expect(find.text('Turn 3d. Checked to you. Action?'), findsNothing);
    await tester.tap(find.text('BET SEMI-BLUFF'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bet');
    controller.dispose();
  });

  testWidgets('s7 capstone mw deep hand docks Check on river felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-10-03-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'Four-way, 200bb, you hold AhQh.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-mw-flop',
          street: 'flop',
          prompt: 'Flop Jh 8h 2c. Bet into you. Action?',
          choices: [
            CourseChoice(id: 'call', label: 'Call', action: 'CALL'),
            CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
          ],
        ),
        CourseHandStep(
          id: 'step-mw-turn',
          street: 'turn',
          prompt: 'Turn 3d. Checked to you. Action?',
          choices: [
            CourseChoice(
              id: 'bet',
              label: 'Bet semi-bluff',
              action: 'BET',
            ),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-mw-river',
          street: 'river',
          prompt: 'River 9c misses. Two players behind. Action?',
          choices: [
            CourseChoice(
              id: 'check-r',
              label: 'Check',
              action: 'CHECK',
            ),
            CourseChoice(
              id: 'bluff',
              label: 'Blast bluff both',
              action: 'BET',
              amountBb: 60,
            ),
          ],
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.setHandStepIndex(2);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(
      find.text('Missed river · two behind — tap Check.'),
      findsOneWidget,
    );
    expect(find.textContaining('River · miss · ace-high'), findsOneWidget);
    expect(find.text('CHECK'), findsOneWidget);
    expect(
      find.text('River 9c misses. Two players behind. Action?'),
      findsNothing,
    );
    await tester.tap(find.text('CHECK'));
    await tester.pump();
    expect(controller.draft.choiceId, 'check-r');
    controller.dispose();
  });


  testWidgets(
    's7 capstone limped explain taps Nuts Value Thin instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-10-04-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Capstone limped pot. Crowded. No hints.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Prefer nut potential limped multiway'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Capstone limped pot. Crowded. No hints.',
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
      expect(find.byType(CapstoneLimpedDemo), findsOneWidget);
      expect(find.text('Tap NUTS next'), findsNothing);
      expect(find.text('Tap Nuts, Value, and Thin.'), findsNothing);
      expect(find.text('Tap Nuts, Value, and Thin'), findsNothing);
      expect(
        find.text('Limped multiway — value thick, bluffs thin'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight = tester.getSize(find.byType(CapstoneLimpedDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(
          tester.view.physicalSize.height /
              tester.view.devicePixelRatio *
              0.58,
          epsilon: 1,
        ),
      );

      await tester.tap(find.text('NUTS'));
      await tester.pump();
      expect(find.text('Tap VALUE next'), findsNothing);
      await tester.tap(find.text('VALUE'));
      await tester.pump();
      expect(find.text('Tap THIN next'), findsNothing);
      await tester.tap(find.text('THIN'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(
        find.text('Limped multiway — value thick, bluffs thin'),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(CapstoneLimpedDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
      controller.dispose();
    },
  );

  testWidgets('s7 capstone limped hand docks Bet value on flop felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-10-04-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'Four-way limp, 150bb, you hold AhKh on BTN.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-limp-flop',
          street: 'flop',
          prompt: 'Flop Kd 9c 4h. Checked to you. Action?',
          choices: [
            CourseChoice(
              id: 'bet',
              label: 'Bet value',
              action: 'BET',
              amountBb: 8,
            ),
            CourseChoice(id: 'check', label: 'Check forever', action: 'CHECK'),
            CourseChoice(
              id: 'jam',
              label: 'Jam 150bb',
              action: 'RAISE',
              amountBb: 150,
            ),
          ],
        ),
        CourseHandStep(
          id: 'step-limp-turn',
          street: 'turn',
          prompt: 'Called by two. Turn 2s. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Continue value',
              action: 'BET',
              amountBb: 18,
            ),
            CourseChoice(id: 'check-t', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-limp-river',
          street: 'river',
          prompt: 'Both call. River 8d. Action?',
          choices: [
            CourseChoice(
              id: 'value',
              label: 'Bet thin value',
              action: 'BET',
              amountBb: 22,
            ),
            CourseChoice(id: 'check-r', label: 'Check', action: 'CHECK'),
            CourseChoice(
              id: 'bluff',
              label: 'Blast as a pure bluff',
              action: 'BET',
              amountBb: 80,
            ),
          ],
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(find.text('Limped · top pair — tap Bet value.'), findsOneWidget);
    expect(find.textContaining('Flop · Kd9c4h · AK'), findsOneWidget);
    expect(find.text('BET VALUE'), findsOneWidget);
    expect(find.text('Flop Kd 9c 4h. Checked to you. Action?'), findsNothing);
    await tester.tap(find.text('BET VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'bet');
    controller.dispose();
  });

  testWidgets('s7 capstone limped hand docks Continue value on turn felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-10-04-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'Four-way limp, 150bb, you hold AhKh on BTN.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-limp-flop',
          street: 'flop',
          prompt: 'Flop Kd 9c 4h. Checked to you. Action?',
          choices: [
            CourseChoice(id: 'bet', label: 'Bet value', action: 'BET'),
            CourseChoice(id: 'check', label: 'Check forever', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-limp-turn',
          street: 'turn',
          prompt: 'Called by two. Turn 2s. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Continue value',
              action: 'BET',
              amountBb: 18,
            ),
            CourseChoice(id: 'check-t', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-limp-river',
          street: 'river',
          prompt: 'Both call. River 8d. Action?',
          choices: [
            CourseChoice(
              id: 'value',
              label: 'Bet thin value',
              action: 'BET',
            ),
            CourseChoice(id: 'check-r', label: 'Check', action: 'CHECK'),
          ],
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.setHandStepIndex(1);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(
      find.text('Two callers · blank — tap Continue value.'),
      findsOneWidget,
    );
    expect(find.textContaining('Turn · Kd9c4h2s · AK'), findsOneWidget);
    expect(find.text('CONTINUE VALUE'), findsOneWidget);
    expect(find.text('Called by two. Turn 2s. Action?'), findsNothing);
    await tester.tap(find.text('CONTINUE VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'barrel');
    controller.dispose();
  });

  testWidgets('s7 capstone limped hand docks Bet thin value on river felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-10-04-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: 'Four-way limp, 150bb, you hold AhKh on BTN.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-limp-flop',
          street: 'flop',
          prompt: 'Flop Kd 9c 4h. Checked to you. Action?',
          choices: [
            CourseChoice(id: 'bet', label: 'Bet value', action: 'BET'),
            CourseChoice(id: 'check', label: 'Check forever', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-limp-turn',
          street: 'turn',
          prompt: 'Called by two. Turn 2s. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Continue value',
              action: 'BET',
            ),
            CourseChoice(id: 'check-t', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-limp-river',
          street: 'river',
          prompt: 'Both call. River 8d. Action?',
          choices: [
            CourseChoice(
              id: 'value',
              label: 'Bet thin value',
              action: 'BET',
              amountBb: 22,
            ),
            CourseChoice(id: 'check-r', label: 'Check', action: 'CHECK'),
            CourseChoice(
              id: 'bluff',
              label: 'Blast as a pure bluff',
              action: 'BET',
              amountBb: 80,
            ),
          ],
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.setHandStepIndex(2);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(
      find.text('Both call · thin value — tap Bet thin value.'),
      findsOneWidget,
    );
    expect(find.textContaining('River · Kd9c4h2s8d · TPTK'), findsOneWidget);
    expect(find.text('BET THIN VALUE'), findsOneWidget);
    expect(find.text('Both call. River 8d. Action?'), findsNothing);
    await tester.tap(find.text('BET THIN VALUE'));
    await tester.pump();
    expect(controller.draft.choiceId, 'value');
    controller.dispose();
  });


  testWidgets(
    's7 capstone 4bet explain taps SPR Commit Fold instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-10-05-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText: 'Capstone 4-bet. Short SPR. No hints.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['Respect short SPR commitment'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text: 'Capstone 4-bet. Short SPR. No hints.',
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
      expect(find.byType(Capstone4betDemo), findsOneWidget);
      expect(find.text('Tap SPR next'), findsNothing);
      expect(find.text('Tap SPR, Commit, and No Hero.'), findsNothing);
      expect(find.text('Tap SPR, Commit, and No Hero'), findsNothing);
      expect(
        find.text('Short SPR — commit clean, fold ego'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight = tester.getSize(find.byType(Capstone4betDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(tester.view.physicalSize.height /
                tester.view.devicePixelRatio *
                0.58,
            epsilon: 1),
      );

      await tester.tap(find.text('SPR'));
      await tester.pump();
      expect(find.text('Tap COMMIT next'), findsNothing);
      await tester.tap(find.text('COMMIT'));
      await tester.pump();
      expect(find.text('Tap NO HERO next'), findsNothing);
      await tester.tap(find.text('NO HERO'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(
        find.text('Short SPR — commit clean, fold ego'),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(Capstone4betDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
      controller.dispose();
    },
  );

  testWidgets('s7 capstone 4bet hand docks Bet on flop felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-10-05-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: '100bb 4-bet pot; you hold KK after 4-betting.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-4b-flop',
          street: 'flop',
          prompt: 'Flop Q83r. Action?',
          choices: [
            CourseChoice(id: 'bet', label: 'C-bet', action: 'BET', amountBb: 12),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
            CourseChoice(id: 'min', label: 'Bet 1bb', action: 'BET', amountBb: 1),
          ],
        ),
        CourseHandStep(
          id: 'step-4b-turn',
          street: 'turn',
          prompt: 'Called. Turn 2d. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Continue / commit',
              action: 'BET',
              amountBb: 28,
            ),
            CourseChoice(
              id: 'check-t',
              label: 'Check/give up',
              action: 'CHECK',
            ),
          ],
        ),
        CourseHandStep(
          id: 'step-4b-river',
          street: 'river',
          prompt: 'Called. River Ad. Opponent jams. Action?',
          choices: [
            CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
            CourseChoice(id: 'call', label: 'Hero call', action: 'CALL'),
            CourseChoice(
              id: 'jam',
              label: 'Rejam for style',
              action: 'RAISE',
              amountBb: 60,
            ),
          ],
        ),
      ],
    );
    expect(isLessonActionTableActivity(activity), isTrue);
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
    expect(find.text('4-bet pot · Q83r — tap Bet.'), findsOneWidget);
    expect(find.textContaining('Flop · Q83r · KK'), findsOneWidget);
    expect(find.text('BET'), findsWidgets);
    expect(find.text('Flop Q83r. Action?'), findsNothing);
    await tester.tap(find.text('BET').first);
    await tester.pump();
    expect(controller.draft.choiceId, 'bet');
    controller.dispose();
  });

  testWidgets('s7 capstone 4bet hand docks Continue / commit on turn felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-10-05-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: '100bb 4-bet pot; you hold KK after 4-betting.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-4b-flop',
          street: 'flop',
          prompt: 'Flop Q83r. Action?',
          choices: [
            CourseChoice(id: 'bet', label: 'C-bet', action: 'BET'),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-4b-turn',
          street: 'turn',
          prompt: 'Called. Turn 2d. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Continue / commit',
              action: 'BET',
              amountBb: 28,
            ),
            CourseChoice(
              id: 'check-t',
              label: 'Check/give up',
              action: 'CHECK',
            ),
          ],
        ),
        CourseHandStep(
          id: 'step-4b-river',
          street: 'river',
          prompt: 'Called. River Ad. Opponent jams. Action?',
          choices: [
            CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
            CourseChoice(id: 'call', label: 'Hero call', action: 'CALL'),
          ],
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.setHandStepIndex(1);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(
      find.text('Called · blank — tap Continue / commit.'),
      findsOneWidget,
    );
    expect(find.textContaining('Turn · Q832 · KK'), findsOneWidget);
    expect(find.text('CONTINUE / COMMIT'), findsOneWidget);
    expect(find.text('Called. Turn 2d. Action?'), findsNothing);
    await tester.tap(find.text('CONTINUE / COMMIT'));
    await tester.pump();
    expect(controller.draft.choiceId, 'barrel');
    controller.dispose();
  });

  testWidgets('s7 capstone 4bet hand docks Fold on river felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-10-05-hand',
      order: 2,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.authoredMultiStepHand,
      estimatedSeconds: 70,
      accessibilityText: '100bb 4-bet pot; you hold KK after 4-betting.',
      acceptedGrades: const [SoftGrade.recommended],
      handSteps: const [
        CourseHandStep(
          id: 'step-4b-flop',
          street: 'flop',
          prompt: 'Flop Q83r. Action?',
          choices: [
            CourseChoice(id: 'bet', label: 'C-bet', action: 'BET'),
            CourseChoice(id: 'check', label: 'Check', action: 'CHECK'),
          ],
        ),
        CourseHandStep(
          id: 'step-4b-turn',
          street: 'turn',
          prompt: 'Called. Turn 2d. Action?',
          choices: [
            CourseChoice(
              id: 'barrel',
              label: 'Continue / commit',
              action: 'BET',
            ),
            CourseChoice(
              id: 'check-t',
              label: 'Check/give up',
              action: 'CHECK',
            ),
          ],
        ),
        CourseHandStep(
          id: 'step-4b-river',
          street: 'river',
          prompt: 'Called. River Ad. Opponent jams. Action?',
          choices: [
            CourseChoice(id: 'fold', label: 'Fold', action: 'FOLD'),
            CourseChoice(id: 'call', label: 'Hero call', action: 'CALL'),
            CourseChoice(
              id: 'jam',
              label: 'Rejam for style',
              action: 'RAISE',
              amountBb: 60,
            ),
          ],
        ),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    controller.setHandStepIndex(2);
    await tester.pumpWidget(
      _wrap(
        AuthoredMultiStepActivity(
          activity: activity,
          controller: controller,
          showGuidance: true,
        ),
      ),
    );
    expect(find.text('Ace hits · jam — tap Fold.'), findsOneWidget);
    expect(find.textContaining('River · Q832A · KK'), findsOneWidget);
    expect(find.text('FOLD'), findsOneWidget);
    expect(
      find.text('Called. River Ad. Opponent jams. Action?'),
      findsNothing,
    );
    await tester.tap(find.text('FOLD'));
    await tester.pump();
    expect(controller.draft.choiceId, 'fold');
    controller.dispose();
  });


  testWidgets(
    's7 live warmup explain taps Checklist Defaults One hand instead of Continue',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-07-11-01-explain',
        order: 1,
        stage: ActivityStage.explain,
        renderer: ActivityRenderer.coachDialogue,
        estimatedSeconds: 30,
        accessibilityText:
            'Live warm-up: short checklist, then play. Plan 10 wires the bridge.',
        acceptedGrades: const [SoftGrade.recommended],
        objectives: const ['List warm-up checklist items'],
        coachMedia: const [
          CoachMediaRef(
            id: 'm',
            kind: 'dialogue',
            text:
                'Live warm-up: short checklist, then play. Plan 10 wires the bridge.',
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
      expect(find.byType(LiveWarmupPrepDemo), findsOneWidget);
      expect(find.text('Tap CHECKLIST next'), findsNothing);
      expect(
        find.text('Tap Checklist, Defaults, and One hand.'),
        findsNothing,
      );
      expect(
        find.text('Tap Checklist, Defaults, and One hand'),
        findsNothing,
      );
      expect(
        find.text('Short checklist, then one coached hand'),
        findsNothing,
      );
      expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);
      expect(isTableRegionTapActivity(activity), isTrue);
      final teachHeight =
          tester.getSize(find.byType(LiveWarmupPrepDemo)).height;
      expect(
        teachHeight,
        moreOrLessEquals(
          tester.view.physicalSize.height /
              tester.view.devicePixelRatio *
              0.58,
          epsilon: 1,
        ),
      );

      await tester.tap(find.text('CHECKLIST'));
      await tester.pump();
      expect(find.text('Tap DEFAULTS next'), findsNothing);
      await tester.tap(find.text('DEFAULTS'));
      await tester.pump();
      expect(find.text('Tap ONE HAND next'), findsNothing);
      await tester.tap(find.text('ONE HAND'));
      await tester.pump();
      expect(feltAck, 1);
      // Lock clears enabled / ack — densified shell must stay filled.
      expect(
        find.text('Short checklist, then one coached hand'),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(LiveWarmupPrepDemo)).height,
        moreOrLessEquals(teachHeight, epsilon: 1),
      );
      controller.dispose();
    },
  );

  testWidgets('s7 live warmup guided taps Full list on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-11-01-guided',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Effective stacks, pot type, type notes, street map.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Warm-up checklist must include?',
      choices: const [
        CourseChoice(
          id: 'list',
          label: 'Stacks, pot type, type notes, street map',
        ),
        CourseChoice(
          id: 'hud',
          label: 'Ignore stacks and invent a random plan',
        ),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
    expect(find.text('Warm-up checklist — tap Full list.'), findsOneWidget);
    await tester.tap(find.text('Full list'));
    await tester.pump();
    expect(controller.draft.choiceId, 'list');
    controller.dispose();
  });

  testWidgets('s7 live warmup scaffolded taps Defaults + exploits on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-11-01-scaffolded',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Course defaults + exploit notes.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Carry into Live?',
      choices: const [
        CourseChoice(
          id: 'defaults',
          label: 'Course defaults plus typed exploits',
        ),
        CourseChoice(id: 'blank', label: 'Forget the course'),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Carry into Live — tap Defaults + exploits.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Defaults + exploits'));
    await tester.pump();
    expect(controller.draft.choiceId, 'defaults');
    controller.dispose();
  });

  testWidgets('s7 live warmup unguided taps Live cash NLH on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-11-01-unguided',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Live cash NLH only.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Scope reminder?',
      choices: const [
        CourseChoice(id: 'scope', label: 'Live cash NLH only'),
        CourseChoice(
          id: 'tourney',
          label: 'Study other betting games instead',
        ),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
      find.text('Scope reminder — tap Live cash NLH.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Live cash NLH'));
    await tester.pump();
    expect(controller.draft.choiceId, 'scope');
    controller.dispose();
  });

  testWidgets('s7 live warmup checkpoint taps One hand on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-11-01-checkpoint',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 45,
      accessibilityText: 'Load the plan, then execute one hand.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Warm-up goal?',
      choices: const [
        CourseChoice(
          id: 'one',
          label: 'Load checklist and execute one coached hand',
        ),
        CourseChoice(
          id: 'grind',
          label: 'Ignore checklist and mash buttons',
        ),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Warm-up goal — tap One hand.'), findsOneWidget);
    await tester.tap(find.text('One hand'));
    await tester.pump();
    expect(controller.draft.choiceId, 'one');
    controller.dispose();
  });


  testWidgets('s7 five type final cs taps Station value on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-12-01-cs',
      order: 1,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'Calling Station — value more.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Sticky calls three streets. Label + exploit?',
      choices: const [
        CourseChoice(
          id: 'cs',
          label: 'Calling Station — thicker value, fewer bluffs',
        ),
        CourseChoice(
          id: 'cs-wrong',
          label: 'Calling Station — bluff more',
        ),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
    expect(
      resolveSelectIdentifyPresentation(activity),
      SelectIdentifyPresentation.tableRegionTap,
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
    expect(find.text('Sticky calls — tap Station value.'), findsOneWidget);
    await tester.tap(find.text('Station value'));
    await tester.pump();
    expect(controller.draft.choiceId, 'cs');
    controller.dispose();
  });

  testWidgets('s7 five type final nit taps Nit respect on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-12-01-nit',
      order: 2,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'Nit — respect.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tiny range, huge check-raise. Label + line?',
      choices: const [
        CourseChoice(
          id: 'nit',
          label: 'Nit — respect heat; steal elsewhere',
        ),
        CourseChoice(
          id: 'nit-wrong',
          label: 'Nit — call down light always',
        ),
      ],
    );
    expect(isTableRegionTapActivity(activity), isTrue);
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
    expect(find.text('Tiny range heat — tap Nit respect.'), findsOneWidget);
    await tester.tap(find.text('Nit respect'));
    await tester.pump();
    expect(controller.draft.choiceId, 'nit');
    controller.dispose();
  });

  testWidgets('s7 five type final maniac taps Maniac catch on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-12-01-maniac',
      order: 3,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'Maniac — call wider.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Endless barrels, never folds. Label + line?',
      choices: const [
        CourseChoice(
          id: 'man',
          label: 'Maniac — widen catches; avoid ego raises',
        ),
        CourseChoice(
          id: 'man-wrong',
          label: 'Maniac — fold all one-pair forever',
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
    expect(
      find.text('Endless barrels — tap Maniac catch.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Maniac catch'));
    await tester.pump();
    expect(controller.draft.choiceId, 'man');
    controller.dispose();
  });

  testWidgets('s7 five type final tag taps TAG respect on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-12-01-tag',
      order: 4,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'TAG — respect.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Selective entry, disciplined barrels. Label + vs raise?',
      choices: const [
        CourseChoice(
          id: 'tag',
          label: 'TAG — respect raises; steal less than vs nits',
        ),
        CourseChoice(
          id: 'tag-wrong',
          label: 'TAG — bluff their check-raises light',
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
    expect(
      find.text('Selective barrels — tap TAG respect.'),
      findsOneWidget,
    );
    await tester.tap(find.text('TAG respect'));
    await tester.pump();
    expect(controller.draft.choiceId, 'tag');
    controller.dispose();
  });

  testWidgets('s7 five type final lag taps LAG trap on felt', (tester) async {
    final activity = CourseActivity(
      id: 'act-07-12-01-lag',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.playerReadClassify,
      estimatedSeconds: 40,
      accessibilityText: 'LAG — trap/call wider.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Wide entry, sustained pressure, some folds. Label + line?',
      choices: const [
        CourseChoice(
          id: 'lag',
          label: 'LAG — trap more; call wider; fancy less',
        ),
        CourseChoice(
          id: 'lag-wrong',
          label: 'LAG — bluff into them more',
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
    expect(find.text('Wide pressure — tap LAG trap.'), findsOneWidget);
    await tester.tap(find.text('LAG trap'));
    await tester.pump();
    expect(controller.draft.choiceId, 'lag');
    controller.dispose();
  });

  testWidgets('s7 five type final uncertain taps Low certainty on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-12-01-uncertain',
      order: 6,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Low — keep baseline heavier.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Three mixed samples only. Confidence?',
      choices: const [
        CourseChoice(
          id: 'low',
          label: 'Low — lean baseline until samples grow',
        ),
        CourseChoice(
          id: 'max',
          label: 'Maximum certainty on a label',
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
    expect(
      find.text('Three mixed samples — tap Low certainty.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Low certainty'));
    await tester.pump();
    expect(controller.draft.choiceId, 'low');
    controller.dispose();
  });

  testWidgets('s7 five type final retire taps Retire model on felt', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-07-12-01-retire',
      order: 7,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Retire/update the label.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt:
          'Old Calling Station now folds rivers and 3-bets light. Do?',
      choices: const [
        CourseChoice(
          id: 'retire',
          label: 'Retire or update the model',
        ),
        CourseChoice(
          id: 'freeze',
          label: 'Keep the old label forever',
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
    expect(find.text('Label flipped — tap Retire model.'), findsOneWidget);
    await tester.tap(find.text('Retire model'));
    await tester.pump();
    expect(controller.draft.choiceId, 'retire');
    controller.dispose();
  });

}
