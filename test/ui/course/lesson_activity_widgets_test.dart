/// Widget coverage for lesson activity shells and grade feedback.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
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
  return MaterialApp(
    theme: buildPokerTheme(),
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
    expect(find.textContaining('REX'), findsWidgets);
    expect(
      find.text('Tap Continue when you have looked at your two cards.'),
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
      find.text('Tap Continue when the four suits and ranks click.'),
      findsOneWidget,
    );
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

    final guided = CourseActivity(
      id: 'act-01-01-03-guided-button',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap button',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Tap the dealer button on the table.',
      choices: buttonChoices,
    );
    expect(
      resolveSelectIdentifyPresentation(guided),
      SelectIdentifyPresentation.tableRegionTap,
    );
    final scene = resolveLessonTableScene(guided);
    expect(scene, isNotNull);
    expect(scene!.layout, LessonTableLayout.blindsSeats);
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

  testWidgets('suit tap picker maps four suits onto Check-ready choice', (
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

    await tester.tap(find.text('Hearts'));
    await tester.pump();
    await tester.tap(find.text('Diamonds'));
    await tester.pump();
    await tester.tap(find.text('Clubs'));
    await tester.pump();
    expect(controller.draft.choiceId, 'suits-missing');

    await tester.tap(find.text('Spades'));
    await tester.pump();
    expect(controller.draft.choiceId, 'suits-full');
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
    expect(find.text('Ready — Check when it looks right.'), findsOneWidget);
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
