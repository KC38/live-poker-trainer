/// Lesson frame regions and the first-step peek table.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

CourseActivity _hintActivity({
  required String id,
  required ActivityStage stage,
  required String accessibilityText,
  String? prompt,
  ActivityRenderer renderer = ActivityRenderer.selectIdentify,
}) {
  return CourseActivity(
    id: id,
    order: 1,
    stage: stage,
    renderer: renderer,
    estimatedSeconds: 30,
    accessibilityText: accessibilityText,
    acceptedGrades: const [SoftGrade.recommended],
    prompt: prompt,
  );
}

void main() {
  test('lesson mascot expressions map to Rex moods', () {
    expect(LessonMascotExpression.thinking.rexMood, RexMood.calm);
    expect(LessonMascotExpression.happy.rexMood, RexMood.celebrate);
    expect(LessonMascotExpression.wrong.rexMood, RexMood.think);
  });

  test('hint fallback uses accessibility text on interactive steps', () {
    final scaffolded = _hintActivity(
      id: 'act-01-01-01-scaffolded-private',
      stage: ActivityStage.scaffolded,
      accessibilityText:
          'Tap your private hole cards — not the board or other seats.',
      prompt: 'Tap the cards only you can see.',
    );
    expect(
      lessonFrameHintFallback(scaffolded),
      'Tap your private hole cards — not the board or other seats.',
    );

    final unguided = _hintActivity(
      id: 'act-01-01-01-unguided-mix',
      stage: ActivityStage.unguided,
      accessibilityText: 'Tap the shared community cards on the flop.',
      prompt: 'Tap the community cards.',
    );
    expect(
      lessonFrameHintFallback(unguided),
      'Tap the shared community cards on the flop.',
    );
  });

  test('guided SoftPulse leaves Hint disabled — cues are already on', () {
    final guided = _hintActivity(
      id: 'act-01-01-01-guided-find-holes',
      stage: ActivityStage.guided,
      accessibilityText: 'Tap your hole cards on the table.',
      prompt: 'Tap the cards that belong to you.',
    );
    expect(lessonFrameHintShownByDefault(guided), isTrue);
    expect(lessonFrameHintsDisabled(guided), isTrue);
    expect(lessonFrameHintFallback(guided), isNull);

    final scaffolded = _hintActivity(
      id: 'act-01-01-01-scaffolded-private',
      stage: ActivityStage.scaffolded,
      accessibilityText: 'Tap your private hole cards.',
      prompt: 'Tap the cards only you can see.',
    );
    expect(lessonFrameHintShownByDefault(scaffolded), isFalse);
    expect(lessonFrameHintsDisabled(scaffolded), isFalse);
  });

  test('scaffolded SoftPulse leaves Hint disabled when cues are already on', () {
    final seatOrder = _hintActivity(
      id: 'act-01-04-01-scaffolded-order',
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.orderSequence,
      accessibilityText: 'Put UTG, HJ, CO, and BTN in preflop action order.',
      prompt: 'Tap seats in the order they act preflop after blinds.',
    );
    expect(lessonFrameHintShownByDefault(seatOrder), isTrue);
    expect(lessonFrameHintsDisabled(seatOrder), isTrue);
    expect(lessonFrameHintFallback(seatOrder), isNull);

    final sizing = _hintActivity(
      id: 'act-01-03-01-scaffolded-check',
      stage: ActivityStage.scaffolded,
      renderer: ActivityRenderer.pokerActionSizing,
      accessibilityText: 'Check when the pot is free.',
      prompt: 'Nobody has bet. Pick the cheap action.',
    );
    expect(lessonFrameHintShownByDefault(sizing), isTrue);
    expect(lessonFrameHintsDisabled(sizing), isTrue);

    expect(
      lessonFrameHintShownByDefault(seatOrder, isReview: true),
      isFalse,
    );
    expect(lessonFrameHintsDisabled(seatOrder, isReview: true), isFalse);
    expect(
      lessonFrameHintFallback(seatOrder, isReview: true),
      'Put UTG, HJ, CO, and BTN in preflop action order.',
    );
  });

  test('same-concept guided keeps Hint so SoftPulse can unlock', () {
    final guided = _hintActivity(
      id: 'act-01-01-02-guided-suits',
      stage: ActivityStage.guided,
      accessibilityText: 'Tap hearts, diamonds, clubs, and spades on the board.',
      prompt: 'Tap one community card of each suit.',
    );
    expect(lessonFrameSoftPulseQuietByDefault(guided), isTrue);
    expect(lessonFrameHintShownByDefault(guided), isFalse);
    expect(lessonFrameHintsDisabled(guided), isFalse);
    expect(
      lessonFrameHintFallback(guided),
      'Tap hearts, diamonds, clubs, and spades on the board.',
    );
  });

  test('lesson review keeps SoftPulse off until Hint', () {
    final guided = _hintActivity(
      id: 'act-01-01-01-guided-find-holes',
      stage: ActivityStage.guided,
      accessibilityText: 'Tap your hole cards on the table.',
      prompt: 'Tap the cards that belong to you.',
    );
    expect(
      lessonFrameSoftPulseQuietByDefault(guided, isReview: true),
      isTrue,
    );
    expect(lessonFrameHintShownByDefault(guided, isReview: true), isFalse);
    expect(lessonFrameHintsDisabled(guided, isReview: true), isFalse);
    expect(
      lessonFrameHintFallback(guided, isReview: true),
      'Tap your hole cards on the table.',
    );

    final explain = _hintActivity(
      id: 'act-01-01-02-explain-suits',
      stage: ActivityStage.explain,
      accessibilityText: 'You found all four suits. Ace is still the high card.',
    );
    expect(
      lessonFrameSoftPulseQuietByDefault(explain, isReview: true),
      isTrue,
    );
    expect(
      lessonFrameHintFallback(explain, isReview: true),
      'You found all four suits. Ace is still the high card.',
    );
  });

  test('hint fallback stays off for explain, jump tests, and no-hint caps', () {
    final explain = _hintActivity(
      id: 'act-01-01-02-explain-suits',
      stage: ActivityStage.explain,
      accessibilityText: 'You found all four suits. Ace is still the high card.',
    );
    expect(lessonFrameHintFallback(explain), isNull);

    final jump = _hintActivity(
      id: 'act-01-06-02-jump-legal',
      stage: ActivityStage.jumpTest,
      accessibilityText: 'Jump test: check is illegal facing a bet.',
      prompt: 'A bet faces you. Pick the action you cannot take.',
    );
    expect(lessonFrameHintsDisabled(jump), isTrue);
    expect(lessonFrameHintFallback(jump), isNull);

    final capstone = _hintActivity(
      id: 'act-07-10-01-hand',
      stage: ActivityStage.unguided,
      accessibilityText: 'Capstone single-raised pot. No hints. Trust your map.',
      prompt: 'Play the street.',
    );
    expect(lessonFrameHintsDisabled(capstone), isTrue);
    expect(lessonFrameHintFallback(capstone), isNull);
  });

  test('hole-cards explain keeps its authored seat hint', () {
    final activity = _hintActivity(
      id: 'act-01-01-01-explain-hole-cards',
      stage: ActivityStage.explain,
      accessibilityText: 'These two are yours alone. Nobody else sees them.',
    );
    expect(
      lessonFrameHintFallback(activity),
      'Your two cards are at your seat, along the bottom of the table.',
    );
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

  testWidgets('coach band crops Rex to the upper body', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: const Scaffold(
          body: LessonCoachBand(
            speech: 'Tap your cards to peek.',
            expression: LessonMascotExpression.thinking,
          ),
        ),
      ),
    );
    await tester.pump();

    final mascot = tester.widget<RexMascot>(find.byType(RexMascot));
    expect(mascot.crop, RexMascotCrop.upperBody);
    expect(mascot.size, LessonCoachBand.mascotSize);
    final laidOut = tester.getSize(find.byType(RexMascot));
    expect(
      laidOut.height,
      closeTo(
        RexMascot.heightFor(LessonCoachBand.mascotSize, RexMascotCrop.upperBody),
        0.5,
      ),
    );
    expect(
      laidOut.height,
      lessThan(RexMascot.heightFor(LessonCoachBand.mascotSize)),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('out of hearts keeps tools and pulses chrome hearts', (
    tester,
  ) async {
    var restoreTaps = 0;
    var blockedTaps = 0;
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: LessonScreenLayout(
            progress: 0.2,
            livesRemaining: 0,
            livesMax: 5,
            onClose: _noop,
            speech: 'The button has the D chip.',
            expression: LessonMascotExpression.thinking,
            stage: ElevatedButton(
              key: const ValueKey<String>('blocked-stage-tap'),
              onPressed: () => restoreTaps += 100,
              child: const Text('Stage action'),
            ),
            onUndo: _noop,
            onRedo: _noop,
            onHint: _noop,
            canUndo: false,
            canRedo: false,
            canHint: false,
            onRestoreHearts: () => restoreTaps += 1,
            onBlockedPlay: () => blockedTaps += 1,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Out of hearts'), findsNothing);
    expect(find.text('Restore hearts'), findsNothing);
    expect(find.byTooltip('Undo'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('lesson-hearts')), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('lesson-empty-hearts-block')),
    );
    await tester.pump();
    expect(restoreTaps, 0);
    expect(blockedTaps, 1);
    await tester.tap(find.byKey(const ValueKey<String>('lesson-hearts')));
    await tester.pump();
    expect(restoreTaps, 1);
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

  testWidgets('answer dock is full-bleed with clearance above the stage', (
    tester,
  ) async {
    const size = Size(390, 844);
    const bottomInset = 34.0;
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: size,
            padding: EdgeInsets.only(bottom: bottomInset),
          ),
          child: Scaffold(
            backgroundColor: AppColors.bgDark,
            body: SafeArea(
              bottom: false,
              child: LessonScreenLayout(
                progress: 0.4,
                livesRemaining: 3,
                livesMax: 3,
                onClose: _noop,
                speech: 'Those two stay private.',
                expression: LessonMascotExpression.happy,
                stage: const ColoredBox(
                  key: ValueKey<String>('lesson-stage-probe'),
                  color: Color(0xFF112233),
                  child: SizedBox.expand(),
                ),
                onUndo: _noop,
                onRedo: _noop,
                onHint: _noop,
                canUndo: false,
                canRedo: false,
                canHint: false,
                onContinue: _noop,
                result: _result(
                  accepted: true,
                  feedback: 'You must fold, call, or raise — check is off.',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final dockRect = tester.getRect(find.byType(LessonAnswerDock));
    expect(dockRect.left, 0);
    expect(dockRect.right, size.width);
    expect(dockRect.bottom, size.height);

    // Home-indicator inset stays inside the banner, not as a dark gutter.
    final continueRect = tester.getRect(find.text('Continue'));
    expect(continueRect.bottom, lessThanOrEqualTo(size.height - bottomInset));

    final stageRect = tester.getRect(
      find.byKey(const ValueKey<String>('lesson-stage-probe')),
    );
    expect(
      dockRect.top - stageRect.bottom,
      LessonAnswerDock.stageGlowInset + LessonAnswerDock.stageClearance,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tool row keeps clearance under the stage', (tester) async {
    const size = Size(390, 844);
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          backgroundColor: AppColors.bgDark,
          body: LessonScreenLayout(
            progress: 0.2,
            livesRemaining: 3,
            livesMax: 3,
            onClose: _noop,
            speech: 'Four streets: preflop, flop, turn, river.',
            expression: LessonMascotExpression.thinking,
            stage: const ColoredBox(
              key: ValueKey<String>('lesson-stage-probe'),
              color: Color(0xFF112233),
              child: SizedBox.expand(),
            ),
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

    final toolRect = tester.getRect(find.byType(LessonToolRow));
    final stageRect = tester.getRect(
      find.byKey(const ValueKey<String>('lesson-stage-probe')),
    );
    expect(
      toolRect.top - stageRect.bottom,
      LessonAnswerDock.stageGlowInset + LessonAnswerDock.stageClearance,
    );
    // Glow outset is part of the stage inset — never smaller than the ring.
    expect(
      LessonAnswerDock.stageGlowInset,
      greaterThanOrEqualTo(GlowHighlight.outset),
    );
    // Tool controls sit under the row's top padding, not flush to the stage.
    final undoRect = tester.getRect(find.byTooltip('Undo'));
    expect(
      undoRect.top - stageRect.bottom,
      greaterThanOrEqualTo(
        LessonAnswerDock.stageGlowInset +
            LessonAnswerDock.stageClearance +
            12,
      ),
    );
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

    final aceOfHearts = find.byWidgetPredicate(
      (w) => w is TableCard && w.card.display == 'A♥',
    );
    expect(find.text('A'), findsNothing);
    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-1')));
    await tester.pump();
    expect(misses, 1);
    expect(peeks, 0);
    expect(aceOfHearts, findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-hero')));
    await tester.pump();
    expect(peeks, 1);
    expect(aceOfHearts, findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('peeked hole cards stay face-up after Nice! docks', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var peeks = 0;
    var accepted = false;
    late VoidCallback rebuild;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = () => setState(() {});
              return LessonScreenLayout(
                progress: 0.1,
                livesRemaining: 5,
                livesMax: 5,
                onClose: _noop,
                speech:
                    'These two are your cards alone. Nobody else sees them. '
                    'Tap your cards to peek.',
                expression:
                    accepted
                        ? LessonMascotExpression.happy
                        : LessonMascotExpression.thinking,
                stage: LessonPeekTable(
                  enabled: !accepted,
                  onPeek: () {
                    peeks += 1;
                    accepted = true;
                    rebuild();
                  },
                  onMiss: _noop,
                ),
                onUndo: _noop,
                onRedo: _noop,
                onHint: _noop,
                canUndo: false,
                canRedo: false,
                canHint: false,
                onContinue: accepted ? _noop : null,
                result:
                    accepted
                        ? _result(
                          accepted: true,
                          feedback:
                              'These two are yours alone. Nobody else sees them.',
                        )
                        : null,
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final aceOfHearts = find.byWidgetPredicate(
      (w) => w is TableCard && w.card.display == 'A♥',
    );
    expect(aceOfHearts, findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('lesson-seat-hero')));
    await tester.pump();
    expect(peeks, 1);
    expect(find.text('Nice!'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    // Answer dock shrinks the stage and used to remount the peek table,
    // flipping the hero holes face-down again. They must stay revealed.
    expect(aceOfHearts, findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('peek stage hides empty board slot outlines at mini size', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final early = TableFeatures.forLessonId(
      'lesson-01-01-01-your-two-cards',
    );
    expect(early.boardSlots, isTrue);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: TableFeaturesScope(
            features: early,
            child: LessonPeekTable(onPeek: _noop, onMiss: _noop),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byType(TableCardSlot), findsNothing);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hero order badge stays fully above the answer dock', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: SafeArea(
            bottom: false,
            child: LessonScreenLayout(
              progress: 0.55,
              livesRemaining: 5,
              livesMax: 5,
              onClose: _noop,
              speech: 'Tap who wins, then next, then last.',
              expression: LessonMascotExpression.happy,
              stage: LessonTableStage(
                heroCodes: const ['As', 'Kh'],
                boardCodes: const ['Th', '7h', 'Jh', '5s', '4c'],
                villainHoleCodes: const [
                  ['Qc', 'Jd'],
                  ['9c', '9d'],
                ],
                villainCount: 2,
                heroFaceUp: true,
                features: TableFeatures.full.copyWith(
                  playerTypes: false,
                  stats: false,
                ),
                seatOrderBadges: const {0: 2, 1: 3, 2: 1},
              ),
              onUndo: _noop,
              onRedo: _noop,
              onHint: _noop,
              canUndo: false,
              canRedo: false,
              canHint: false,
              onContinue: _noop,
              result: _result(
                accepted: true,
                feedback: 'High card, then pair, then flush.',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final badge = tester.getRect(
      find.byKey(const ValueKey<String>('seat-order-0-2')),
    );
    final dock = tester.getRect(find.byType(LessonAnswerDock));
    expect(badge.height, kSeatOrderBadgeSize);
    expect(
      badge.bottom,
      lessThanOrEqualTo(dock.top),
      reason: 'Nice! must not cover the hero order badge',
    );
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
