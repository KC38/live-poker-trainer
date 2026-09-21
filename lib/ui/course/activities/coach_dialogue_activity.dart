/// Coach demonstration / dialogue activity.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_best_five.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_choice_visuals.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_hand_examples.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Show-stage activity: Rex speaks with a content-driven visual.
class CoachDialogueActivity extends StatelessWidget {
  /// Creates the activity.
  const CoachDialogueActivity({
    super.key,
    required this.activity,
    required this.controller,
    required this.showGuidance,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  @override
  Widget build(BuildContext context) {
    final visual = resolveCoachDialogueVisual(activity);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RexCoachLine.fromActivity(activity),
        if (visual.kind != CoachDialogueVisualKind.none) ...[
          const SizedBox(height: 20),
          _CoachDialogueVisualPane(visual: visual),
        ],
        if (showGuidance) ...[
          const SizedBox(height: 16),
          RexCoachLine(text: visual.continueHint, label: 'Rex'),
        ],
      ],
    );
  }
}

/// Visual kinds a coach-dialogue explain can show.
enum CoachDialogueVisualKind {
  /// Dialogue only — no demo chrome.
  none,

  /// Hero hole cards (optionally on a mini-table).
  holeCards,

  /// Four suits + ace-high rank reminder.
  suitsRanks,

  /// Dealer button chip.
  dealerButton,

  /// Weakest-to-strongest made-hand ladder.
  handLadder,

  /// Seven cards with five highlighted as the playing hand.
  bestFive,

  /// Fold / Check / Call action meanings.
  passiveActions,
}

/// Resolved demo chrome for one coach-dialogue activity.
class CoachDialogueVisual {
  /// Creates a visual descriptor.
  const CoachDialogueVisual({
    required this.kind,
    this.cardCodes = const <String>[],
    this.useTable = false,
  });

  final CoachDialogueVisualKind kind;
  final List<String> cardCodes;
  final bool useTable;

  String get continueHint => switch (kind) {
    CoachDialogueVisualKind.holeCards =>
      'Tap Continue when you have looked at your two cards.',
    CoachDialogueVisualKind.suitsRanks =>
      'Tap Continue when the four suits and ranks click.',
    CoachDialogueVisualKind.dealerButton =>
      'Tap Continue when you can spot the button and blinds.',
    CoachDialogueVisualKind.handLadder =>
      'Tap Continue when the ladder from high card to flush clicks.',
    CoachDialogueVisualKind.bestFive =>
      'Tap Continue when you see that only five of seven play.',
    CoachDialogueVisualKind.passiveActions =>
      'Tap Continue when Fold, Check, and Call click.',
    CoachDialogueVisualKind.none => 'Tap Continue when you are ready.',
  };

  String get semanticsLabel => switch (kind) {
    CoachDialogueVisualKind.holeCards =>
      cardCodes.isEmpty
          ? 'Demonstration hole cards'
          : 'Demonstration hole cards ${cardCodes.join(' and ')}',
    CoachDialogueVisualKind.suitsRanks =>
      'Demonstration suits hearts diamonds clubs spades, ranks deuce through ace',
    CoachDialogueVisualKind.dealerButton =>
      'Poker table showing dealer button and blinds',
    CoachDialogueVisualKind.handLadder =>
      'Hand rank ladder from high card to flush',
    CoachDialogueVisualKind.bestFive =>
      'Seven cards with five highlighted as the playing hand',
    CoachDialogueVisualKind.passiveActions =>
      'Fold, Check, and Call action buttons',
    CoachDialogueVisualKind.none => 'Coach dialogue',
  };
}

/// Picks explain chrome from activity id / copy — never defaults to Ah/Kd.
CoachDialogueVisual resolveCoachDialogueVisual(CourseActivity activity) {
  switch (activity.id) {
    case 'act-01-01-01-explain-hole-cards':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.holeCards,
        cardCodes: ['Ah', 'Kd'],
        useTable: true,
      );
    case 'act-01-01-02-explain-suits':
      return const CoachDialogueVisual(kind: CoachDialogueVisualKind.suitsRanks);
    case 'act-01-01-03-explain-button':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.dealerButton,
      );
    case 'act-01-02-01-explain-ladder':
      return const CoachDialogueVisual(kind: CoachDialogueVisualKind.handLadder);
    case 'act-01-02-02-explain-five':
      return const CoachDialogueVisual(kind: CoachDialogueVisualKind.bestFive);
    case 'act-01-03-01-explain-passive':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.passiveActions,
      );
  }

  final blob =
      '${activity.accessibilityText} '
              '${activity.primaryCoachLine?.text ?? ''} '
              '${activity.objectives.join(' ')}'
          .toLowerCase();

  if (blob.contains('fold ends') ||
      blob.contains('check passes') ||
      blob.contains('call matches')) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.passiveActions,
    );
  }
  if (blob.contains('only five') ||
      blob.contains('strongest five') ||
      blob.contains('five cards count') ||
      blob.contains('best five')) {
    return const CoachDialogueVisual(kind: CoachDialogueVisualKind.bestFive);
  }
  if (blob.contains('flush beats') ||
      blob.contains('hand rank') ||
      blob.contains('pair beats') ||
      blob.contains('remember the ladder')) {
    return const CoachDialogueVisual(kind: CoachDialogueVisualKind.handLadder);
  }
  if (blob.contains('suit') ||
      blob.contains('deuce') ||
      blob.contains('ace is high') ||
      (blob.contains('rank') && blob.contains('thirteen'))) {
    return const CoachDialogueVisual(kind: CoachDialogueVisualKind.suitsRanks);
  }
  if (blob.contains('button') ||
      blob.contains('dealer') ||
      blob.contains('blind')) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.dealerButton,
    );
  }
  if (blob.contains('hole') ||
      blob.contains('your two') ||
      blob.contains('private') ||
      blob.contains('nobody else sees')) {
    final scene = resolveLessonTableScene(activity);
    final codes =
        scene != null && scene.heroCodes.length >= 2
            ? scene.heroCodes.take(2).toList(growable: false)
            : const ['Ah', 'Kd'];
    return CoachDialogueVisual(
      kind: CoachDialogueVisualKind.holeCards,
      cardCodes: codes,
      useTable: scene != null,
    );
  }
  return const CoachDialogueVisual(kind: CoachDialogueVisualKind.none);
}

class _CoachDialogueVisualPane extends StatelessWidget {
  const _CoachDialogueVisualPane({required this.visual});

  final CoachDialogueVisual visual;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: visual.semanticsLabel,
      child: switch (visual.kind) {
        CoachDialogueVisualKind.holeCards => _HoleCardDemo(visual: visual),
        CoachDialogueVisualKind.suitsRanks => const _SuitsRanksDemo(),
        CoachDialogueVisualKind.dealerButton => const _DealerButtonDemo(),
        CoachDialogueVisualKind.handLadder => const HandRankLadderDemo(),
        CoachDialogueVisualKind.bestFive => const BestFiveDemo(),
        CoachDialogueVisualKind.passiveActions => const PassiveActionsDemo(),
        CoachDialogueVisualKind.none => const SizedBox.shrink(),
      },
    );
  }
}

class _HoleCardDemo extends StatelessWidget {
  const _HoleCardDemo({required this.visual});

  final CoachDialogueVisual visual;

  @override
  Widget build(BuildContext context) {
    if (visual.useTable) {
      final codes =
          visual.cardCodes.length >= 2
              ? visual.cardCodes.take(2).toList(growable: false)
              : const ['Ah', 'Kd'];
      return LessonTableContext(
        scene: LessonTableScene(
          heroCodes: codes,
          villainSeatCount: 0,
          highlight: LessonTableHighlight.hero,
          caption: 'You',
        ),
      );
    }
    final codes =
        visual.cardCodes.length >= 2
            ? visual.cardCodes.take(2).toList(growable: false)
            : const ['Ah', 'Kd'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < codes.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          MiniCard(card: CardModel.fromCode(codes[i]), size: MiniCardSize.hero),
        ],
      ],
    );
  }
}

class _SuitsRanksDemo extends StatelessWidget {
  const _SuitsRanksDemo();

  static const _suits = <LessonSuitToken>[
    LessonSuitToken.hearts,
    LessonSuitToken.diamonds,
    LessonSuitToken.clubs,
    LessonSuitToken.spades,
  ];

  static const _ranks = <String>['2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.feltLight.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.55)),
      ),
      child: Column(
        children: [
          const SuitGlyphRow(tokens: _suits, glyphSize: 34),
          const SizedBox(height: 14),
          Text(
            'Thirteen ranks — ace high',
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final rank in _ranks)
                Container(
                  width: 28,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    rank,
                    style: GoogleFonts.manrope(
                      color: AppColors.bgDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DealerButtonDemo extends StatelessWidget {
  const _DealerButtonDemo();

  @override
  Widget build(BuildContext context) {
    return const LessonTableContext(
      scene: LessonTableScene(
        layout: LessonTableLayout.blindsSeats,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
      ),
    );
  }
}
