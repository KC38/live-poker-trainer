/// Every lesson step says what to tap, and the table cue bounces on it.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activities/select_identify_activity.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_starting_hand_copy.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

CourseCatalog _catalog() {
  final raw = File('assets/course/v2/catalog.json').readAsStringSync();
  return CourseCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(390, 560));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(theme: buildPokerTheme(), home: Scaffold(body: child)),
  );
  await tester.pump();
}

void main() {
  test('every step and hand street tells the learner what to tap', () {
    final missing = <String>[];
    for (final section in _catalog().sections) {
      for (final unit in section.units) {
        for (final lesson in unit.lessons) {
          for (final activity in lesson.activities) {
            final streets =
                activity.handSteps.isEmpty ? 1 : activity.handSteps.length;
            for (var i = 0; i < streets; i++) {
              final speech = lessonFrameSpeech(activity, handStepIndex: i);
              if (!RegExp(r'\btap\b', caseSensitive: false).hasMatch(speech)) {
                missing.add('${activity.id}#$i: $speech');
              }
            }
          }
        }
      }
    }
    expect(missing, isEmpty);
  });

  test('suits and ranks explain asks for one board card per suit', () {
    final activity = _catalog().sections
        .expand((s) => s.units)
        .expand((u) => u.lessons)
        .expand((l) => l.activities)
        .firstWhere((a) => a.id == 'act-01-01-02-explain-suits');
    expect(
      lessonFrameSpeech(activity),
      'Four suits, thirteen ranks. Ace is high here. '
      'Tap one board card of each suit.',
    );
  });

  test('board-plays showdown names board vs hole taps without seat myths', () {
    final activity = _catalog().sections
        .expand((s) => s.units)
        .expand((u) => u.lessons)
        .expand((l) => l.activities)
        .firstWhere((a) => a.id == 'act-01-02-02-unguided-board');
    expect(
      lessonFrameSpeech(activity),
      'Both checked down. Tap the board if both play it, or a '
      "player's cards if you think their holes win.",
    );
  });

  test('scene-only copy gains the step instruction', () {
    const dock = 'Tap your action below the table.';
    expect(
      withLessonTapInstruction('UTG with QQ at 1/2. Action?', dock),
      'UTG with QQ at 1/2. Tap your action below the table.',
    );
    expect(
      withLessonTapInstruction('Button with A9s. Folds to you.', dock),
      'Button with A9s. Folds to you. Tap your action below the table.',
    );
    expect(
      withLessonTapInstruction('A bet is out — pick how you continue.', dock),
      'A bet is out — tap how you continue.',
    );
    expect(
      withLessonTapInstruction('Name the family for your holes.', dock),
      'Tap the family for your holes.',
    );
    expect(
      withLessonTapInstruction('Tap the pocket pair.', dock),
      'Tap the pocket pair.',
    );
    expect(withLessonTapInstruction('Four suits.', ''), 'Four suits.');
  });

  test('open-fold unguided names the dealt holes, not catalog K9s', () {
    final activity = _catalog().sections
        .expand((s) => s.units)
        .expand((u) => u.lessons)
        .expand((l) => l.activities)
        .firstWhere((a) => a.id == 'act-02-03-01-unguided-btn');
    String? speech;
    String? dealtLabel;
    for (var generation = 0; generation < 48; generation++) {
      final dealt = dealtLessonActionSpot(
        activity,
        generation: generation,
      );
      final label = startingHandLabelFromCodes(dealt!.heroCodes);
      if (label == 'K9s') continue;
      speech = lessonFrameSpeech(activity, bindGeneration: generation);
      dealtLabel = label;
      break;
    }
    expect(dealtLabel, isNotNull);
    expect(speech, isNot(contains('K9s')));
    expect(speech, contains(dealtLabel));
    expect(speech, contains('Tap your action below the table.'));
  });

  testWidgets('next suit card SoftPulses with GlowHighlight, no arrows', (tester) async {
    await _pump(tester, LessonSuitBoardTable(onAllSuitsSelected: () {}));

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('lesson-board-card-0')));
    await tester.pump();
    // Selected card keeps a cyan ring; SoftPulse moves to the next suit.
    expect(
      find.byKey(const ValueKey<String>('selection-highlight')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('glow-highlight')),
      findsAtLeastNWidgets(1),
    );
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('blinds clockwise arrow walks button, small, then big blind', (
    tester,
  ) async {
    await _pump(tester, LessonBlindsClockwiseTable(onComplete: () {}));

    Finder cue(int seat) => find.byKey(ValueKey<String>('seat-cue-$seat'));
    expect(cue(lessonBlindsButtonIndex), findsOneWidget);
    expect(cue(lessonBlindsSmallBlindIndex), findsNothing);

    await tester.tap(
      find.byKey(ValueKey<String>('lesson-seat-$lessonBlindsButtonIndex')),
    );
    await tester.pump();
    expect(cue(lessonBlindsButtonIndex), findsNothing);
    expect(cue(lessonBlindsSmallBlindIndex), findsOneWidget);

    await tester.tap(
      find.byKey(ValueKey<String>('lesson-seat-$lessonBlindsSmallBlindIndex')),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(ValueKey<String>('lesson-seat-$lessonBlindsBigBlindIndex')),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('selection-highlight')),
      findsNWidgets(3),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('framed find-holes shows GlowHighlight on face-up hero holes', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-01-guided-find-holes',
      order: 2,
      stage: ActivityStage.guided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap your hole cards',
      acceptedGrades: const [SoftGrade.recommended],
      choices: const [
        CourseChoice(id: 'choice-hero-holes', label: 'Ah Kd in front of you'),
        CourseChoice(id: 'choice-board', label: 'The flop cards in the middle'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonFrameScope(
            onLocalMiss: (_) {},
            child: SizedBox(
              height: 520,
              child: SelectIdentifyActivity(
                activity: activity,
                controller: controller,
                showGuidance: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('lesson-table-stage')),
      findsOneWidget,
    );
    // One GlowHighlight on each face-up hole card (not a centered pair).
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNWidgets(2));
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
    controller.dispose();
  });

  testWidgets('hint restores GlowHighlight on quieter hole-card frame steps', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-01-scaffolded-private',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap your private cards',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'h',
          kind: 'hint',
          text: 'Your two cards sit at your seat — not the board.',
        ),
      ],
      choices: const [
        CourseChoice(id: 'choice-only-you', label: 'Only you'),
        CourseChoice(id: 'choice-everyone', label: 'Everyone'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonFrameScope(
            onLocalMiss: (_) {},
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return SizedBox(
                  height: 520,
                  child: SelectIdentifyActivity(
                    activity: activity,
                    controller: controller,
                    showGuidance: controller.showTargetCue,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    // Scaffolded scene clears highlight — no SoftPulse until Hint.
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);

    controller.revealHint();
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNWidgets(2));
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
    controller.dispose();
  });

  testWidgets('hint SoftPulses every flop card on unguided mix', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-01-01-unguided-mix',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the shared community cards on the flop.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'h',
          kind: 'hint',
          text: 'Community cards sit in the middle of the table.',
        ),
      ],
      choices: const [
        CourseChoice(id: 'choice-flop', label: 'Qs Jh 2c in the middle'),
        CourseChoice(id: 'choice-hero-again', label: 'Your Ah Kd'),
        CourseChoice(id: 'choice-muck', label: 'Folded cards in the muck'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonFrameScope(
            onLocalMiss: (_) {},
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return SizedBox(
                  height: 520,
                  child: SelectIdentifyActivity(
                    activity: activity,
                    controller: controller,
                    showGuidance: controller.showTargetCue,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);

    controller.revealHint();
    await tester.pump();

    // Region board SoftPulse: one GlowHighlight around the whole board row.
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
    controller.dispose();
  });

  testWidgets('scaffolded blinds SoftPulse only after hint', (tester) async {
    final activity = CourseActivity(
      id: 'act-01-01-03-scaffolded-blinds',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the seat that posts the big blind.',
      acceptedGrades: const [SoftGrade.recommended],
      coachMedia: const [
        CoachMediaRef(
          id: 'h',
          kind: 'hint',
          text:
              'Blinds sit left of the button — the bigger forced bet posts two.',
        ),
      ],
      prompt: 'Blinds are 1/2. Tap who posts the big blind.',
      choices: const [
        CourseChoice(id: 'bb-two', label: 'The seat two left of the button'),
        CourseChoice(id: 'sb-one', label: 'The seat immediately left'),
        CourseChoice(id: 'btn-posts', label: 'The button posts both'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: TableFeaturesScope(
            features: TableFeatures.forLessonId(
              'lesson-01-01-03-blinds-and-button',
            ),
            child: LessonFrameScope(
              onLocalMiss: (_) {},
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return SizedBox(
                    height: 560,
                    child: SelectIdentifyActivity(
                      activity: activity,
                      controller: controller,
                      showGuidance: controller.showTargetCue,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final bbSeat = find.byKey(
      ValueKey<String>('lesson-seat-$lessonBlindsBigBlindIndex'),
    );
    expect(bbSeat, findsOneWidget);
    // No SoftPulse / action-glow spoiler before Hint.
    expect(
      find.byKey(ValueKey<String>('seat-cue-$lessonBlindsBigBlindIndex')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);
    expect(
      tester
          .widget<PlayerSeatWidget>(
            find.descendant(
              of: bbSeat,
              matching: find.byType(PlayerSeatWidget),
            ),
          )
          .isActive,
      isFalse,
    );

    controller.revealHint();
    await tester.pump();

    // Same SoftPulse as hole / board cues: GlowHighlight ring, no arrows.
    expect(
      find.byKey(ValueKey<String>('seat-cue-$lessonBlindsBigBlindIndex')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('postflop checkpoint SoftPulses SB only after hint', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-04-01-checkpoint-postflop',
      order: 5,
      stage: ActivityStage.checkpoint,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText:
          'Tap the seat left of the button — first to act postflop.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Postflop multiway. Tap who acts first.',
      choices: const [
        CourseChoice(id: 'sb-first', label: 'SB'),
        CourseChoice(id: 'btn-first', label: 'BTN'),
        CourseChoice(id: 'bb-first-always', label: 'BB'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: TableFeaturesScope(
            features: TableFeatures.forLessonId(
              'lesson-01-04-01-streets-and-order',
            ),
            child: LessonFrameScope(
              onLocalMiss: (_) {},
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  return SizedBox(
                    height: 560,
                    child: SelectIdentifyActivity(
                      activity: activity,
                      controller: controller,
                      showGuidance: controller.showTargetCue,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('FLOP'), findsOneWidget);
    expect(find.textContaining('PREFLOP'), findsNothing);

    expect(
      find.byKey(ValueKey<String>('seat-cue-$lessonBlindsSmallBlindIndex')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);

    controller.revealHint();
    await tester.pump();

    expect(
      find.byKey(ValueKey<String>('seat-cue-$lessonBlindsSmallBlindIndex')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);
    expect(
      find.byKey(ValueKey<String>('seat-cue-$lessonBlindsButtonIndex')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('street-end SoftPulses Bets matched only after hint', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-04-01-unguided-end',
      order: 4,
      stage: ActivityStage.unguided,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Betting is live — pick when this street ends.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Flop betting is live. Tap when this street ends.',
      choices: const [
        CourseChoice(id: 'matched', label: 'Bets matched'),
        CourseChoice(id: 'three-cards', label: 'Flop appears'),
        CourseChoice(id: 'someone-folds', label: 'Someone folds'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonFrameScope(
            onLocalMiss: (_) {},
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return SizedBox(
                  height: 560,
                  child: SelectIdentifyActivity(
                    activity: activity,
                    controller: controller,
                    showGuidance: controller.showTargetCue,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('street-end-cue-streetActionMatched')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('street-end-tile-streetActionMatched')),
      findsOneWidget,
    );

    controller.revealHint();
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('street-end-cue-streetActionMatched')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('street-end-cue-streetFlopDealt')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('street-end-felt')), findsOneWidget);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets('scaffolded blinds posts BB chips only after a correct tap', (
    tester,
  ) async {
    final activity = CourseActivity(
      id: 'act-01-01-03-scaffolded-blinds',
      order: 3,
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.selectIdentify,
      estimatedSeconds: 40,
      accessibilityText: 'Tap the seat that posts the big blind.',
      acceptedGrades: const [SoftGrade.recommended],
      prompt: 'Blinds are 1/2. Tap who posts the big blind.',
      choices: const [
        CourseChoice(id: 'bb-two', label: 'The seat two left of the button'),
        CourseChoice(id: 'sb-one', label: 'The seat immediately left'),
        CourseChoice(id: 'btn-posts', label: 'The button posts both'),
      ],
    );
    final controller = LessonActivityController(activity: activity);
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: TableFeaturesScope(
            features: TableFeatures.forLessonId(
              'lesson-01-01-03-blinds-and-button',
            ),
            child: LessonFrameScope(
              onLocalMiss: (_) {},
              child: SizedBox(
                height: 560,
                child: SelectIdentifyActivity(
                  activity: activity,
                  controller: controller,
                  showGuidance: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey<String>('lesson-table-stage')),
      findsOneWidget,
    );
    // SB is already out; BB chip and puck wait for the correct tap.
    expect(find.text(r'$1'), findsOneWidget);
    expect(find.text(r'$2'), findsNothing);
    expect(find.byKey(const ValueKey<String>('puck-BB')), findsNothing);
    expect(find.byKey(const ValueKey<String>('puck-SB')), findsOneWidget);
    expect(find.textContaining(r'POT $1'), findsOneWidget);

    await tester.tap(
      find.byKey(ValueKey<String>('lesson-seat-$lessonBlindsBigBlindIndex')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    expect(controller.draft.choiceId, 'bb-two');
    expect(find.text(r'$2'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('puck-BB')), findsOneWidget);
    expect(find.textContaining(r'POT $3'), findsOneWidget);
    expect(tester.takeException(), isNull);
    controller.dispose();
  });

  testWidgets(
    'checkpoint layout reveals SB then BB after a correct small-blind tap',
    (tester) async {
      final activity = CourseActivity(
        id: 'act-01-01-03-checkpoint-layout',
        order: 5,
        stage: ActivityStage.checkpoint,
        renderer: ActivityRenderer.selectIdentify,
        estimatedSeconds: 45,
        accessibilityText: 'On a six-handed table, tap the small blind seat.',
        acceptedGrades: const [SoftGrade.recommended],
        prompt: 'Button is seat 5. Tap the small blind.',
        choices: const [
          CourseChoice(id: 'sb-seat0', label: 'Seat 0 (first left of button)'),
          CourseChoice(id: 'sb-seat4', label: 'Seat 4 (right of button)'),
          CourseChoice(id: 'sb-seat1', label: 'Seat 1 (big blind seat)'),
        ],
      );
      final controller = LessonActivityController(activity: activity);
      await tester.binding.setSurfaceSize(const Size(390, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: buildPokerTheme(),
          home: Scaffold(
            body: TableFeaturesScope(
              features: TableFeatures.forLessonId(
                'lesson-01-01-03-blinds-and-button',
              ),
              child: LessonFrameScope(
                onLocalMiss: (_) {},
                child: SizedBox(
                  height: 560,
                  child: SelectIdentifyActivity(
                    activity: activity,
                    controller: controller,
                    showGuidance: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(const ValueKey<String>('lesson-table-stage')),
        findsOneWidget,
      );
      // Only the D chip — SB/BB wait for the correct seat tap.
      expect(find.byKey(const ValueKey<String>('puck-D')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('puck-SB')), findsNothing);
      expect(find.byKey(const ValueKey<String>('puck-BB')), findsNothing);
      expect(find.text(r'$1'), findsNothing);
      expect(find.text(r'$2'), findsNothing);

      await tester.tap(
        find.byKey(
          ValueKey<String>('lesson-seat-$lessonBlindsSmallBlindIndex'),
        ),
      );
      await tester.pump();

      expect(controller.draft.choiceId, 'sb-seat0');
      // SB pops first; BB still hidden for the stagger beat.
      expect(find.byKey(const ValueKey<String>('puck-SB')), findsOneWidget);
      expect(find.text(r'$1'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('puck-BB')), findsNothing);
      expect(find.text(r'$2'), findsNothing);
      expect(find.textContaining(r'POT $1'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 380));

      expect(find.byKey(const ValueKey<String>('puck-BB')), findsOneWidget);
      expect(find.text(r'$2'), findsOneWidget);
      expect(find.textContaining(r'POT $3'), findsOneWidget);
      expect(tester.takeException(), isNull);
      controller.dispose();
    },
  );

  test('same-concept guided nodes stay SoftPulse-quiet until Hint', () {
    expect(lessonFrameSameConceptQuietIds, isNotEmpty);
    for (final id in lessonFrameSameConceptQuietIds) {
      final activity = _catalog().sections
          .expand((s) => s.units)
          .expand((u) => u.lessons)
          .expand((l) => l.activities)
          .firstWhere((a) => a.id == id);
      expect(activity.stage, ActivityStage.guided, reason: id);
      final controller = LessonActivityController(activity: activity);
      expect(
        controller.showTargetCue,
        isFalse,
        reason: '$id should not SoftPulse by default',
      );
      controller.revealHint();
      expect(
        controller.showTargetCue,
        isTrue,
        reason: '$id SoftPulse unlocks on Hint',
      );
      controller.dispose();
    }
  });

  test(
    'same-concept quiet ids follow an interactive explain in the same lesson',
    () {
      final catalogIds = <String>{};
      for (final section in _catalog().sections) {
        for (final unit in section.units) {
          for (final lesson in unit.lessons) {
            final acts = [...lesson.activities]
              ..sort((a, b) => a.order.compareTo(b.order));
            for (final activity in acts) {
              catalogIds.add(activity.id);
              if (!lessonFrameSameConceptQuietIds.contains(activity.id)) {
                continue;
              }
              CourseActivity? explain;
              for (final prior in acts) {
                if (prior.stage == ActivityStage.explain &&
                    prior.order < activity.order) {
                  explain = prior;
                  break;
                }
              }
              expect(
                explain,
                isNotNull,
                reason: '${activity.id} needs a prior explain in ${lesson.id}',
              );
              final explainObjectives = explain!.objectives.toSet();
              expect(
                activity.objectives.any(explainObjectives.contains),
                isTrue,
                reason:
                    '${activity.id} should share an objective with '
                    '${explain.id}',
              );
            }
          }
        }
      }
      expect(
        lessonFrameSameConceptQuietIds.difference(catalogIds),
        isEmpty,
      );
    },
  );
}
