/// Widget coverage for lesson activity shells and grade feedback.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/course/activities/authored_multi_step_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/coach_dialogue_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/numeric_pot_price_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/order_sequence_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/poker_action_sizing_activity.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_best_five.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_choice_visuals.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_feedback_sheet.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_hand_examples.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_streets.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

CourseActivity _activity({
  required ActivityRenderer renderer,
  ActivityStage stage = ActivityStage.guided,
  List<CourseChoice> choices = const [],
  List<CourseChoice> sequenceItems = const [],
  String? numericQuestion,
  String? numericUnit,
}) {
  return CourseActivity(
    id: 'act-test',
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
    expect(
      find.text('Tap your two cards on the felt.'),
      findsOneWidget,
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
    expect(
      find.text('Tap each of the four suits.'),
      findsOneWidget,
    );
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
    expect(
      resolveCoachDialogueVisual(activity).requiresFeltTap,
      isTrue,
    );

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
    expect(
      find.text('Tap each rung from high card to flush.'),
      findsOneWidget,
    );
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

  testWidgets('best-five explain taps each gold card instead of Continue', (
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
      find.text('Tap each gold card — only five of seven play.'),
      findsOneWidget,
    );
    expect(resolveCoachDialogueVisual(activity).requiresFeltTap, isTrue);

    final playing = find.byWidgetPredicate(
      (w) => w is SelectableBestFiveCard && w.enabled,
    );
    expect(playing, findsNWidgets(5));
    for (final el in playing.evaluate()) {
      await tester.tap(find.byWidget(el.widget));
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
  });

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

    await tester.tap(
      find.descendant(
        of: find.byType(LessonTableContext),
        matching: find.text('D'),
      ),
    );
    await tester.pump();
    expect(controller.draft.choiceId, 'btn-seat');

    await tester.tap(
      find.descendant(
        of: find.byType(LessonTableContext),
        matching: find.text('Big blind'),
      ),
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
        CourseChoice(id: 'before-deal', label: 'Before any hole cards are dealt'),
        CourseChoice(id: 'after-flop', label: 'After the flop'),
        CourseChoice(id: 'only-showdown', label: 'Only if the hand reaches showdown'),
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
      accessibilityText: 'Classify pocket nines',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Look at your two cards. What do you have?',
    );
    final checkpointScene = resolveLessonTableScene(checkpoint);
    expect(checkpointScene, isNotNull);
    expect(checkpointScene!.heroCodes, ['9h', '9d']);
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
    expect(
      blindsSmallBlindSeat(buttonSeat: 5, seatCount: 6),
      0,
    );
    expect(
      blindsBigBlindSeat(buttonSeat: 5, seatCount: 6),
      1,
    );
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
          accessibilityText: 'One short hand. Blinds post, you act, we reach an ending.',
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
          choices: const [
            CourseChoice(id: 'side-exists', label: 'Side pot'),
          ],
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
      CourseChoice(
        id: 'suits-full',
        label: 'Hearts, diamonds, clubs, spades',
      ),
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
    expect(find.text('Keep tapping — include every real suit.'), findsOneWidget);

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
    await tester.tap(find.byType(HoleCardChoiceButton).first);
    await tester.pump();
    expect(controller.draft.choiceId, 'suited-ah-kh');
    controller.dispose();
  });

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
    await tester.tap(find.text('Raise'));
    await tester.pump();
    expect(controller.draft.choiceId, 'raise');
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
    expect(find.text('Ready — Lock in below.'), findsOneWidget);
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
    await tester.tap(find.text('BET 5'));
    await tester.pump();
    expect(betController.draft.choiceId, 'bet-half');
    expect(find.text('Ready — Lock in below.'), findsOneWidget);
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
    expect(find.text('Playable'), findsOneWidget);
    expect(find.text('Life −1'), findsNothing);
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
    expect(find.byType(HandExampleTile), findsNWidgets(3));
    expect(find.byType(ActionChip), findsNothing);

    await tester.tap(find.text('High card'));
    await tester.pump();
    await tester.tap(find.text('One pair'));
    await tester.pump();
    await tester.tap(find.text('Flush'));
    await tester.pump();
    expect(controller.draft.orderedIds, ['hr-high', 'hr-pair', 'hr-flush']);
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

    await tester.tap(find.text('Your flush'));
    await tester.pump();
    expect(controller.draft.choiceId, 'you-win');
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

    for (final code in ['Ah', 'As', 'Kd', '9h', '7c']) {
      await tester.tap(find.byKey(ValueKey<String>('best-five-$code')));
      await tester.pump();
    }
    expect(controller.draft.choiceId, 'best-pair-k');
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
    await tester.tap(find.text('You — kings, Q kicker'));
    await tester.pump();
    expect(controller.draft.choiceId, 'you-kicker');
    controller.dispose();
  });
}
