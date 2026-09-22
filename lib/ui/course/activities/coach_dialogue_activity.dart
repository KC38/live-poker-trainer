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
import 'package:live_poker_trainer/ui/course/widgets/lesson_pots.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_streets.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_context.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_toy_hand.dart';
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
    this.onFeltAcknowledge,
  });

  final CourseActivity activity;
  final LessonActivityController controller;
  final bool showGuidance;

  /// Called when the learner taps the correct region on an interactive demo.
  final VoidCallback? onFeltAcknowledge;

  @override
  Widget build(BuildContext context) {
    final visual = resolveCoachDialogueVisual(activity);
    final locked =
        controller.submitting || controller.lastResult != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RexCoachLine.fromActivity(activity),
        if (visual.kind != CoachDialogueVisualKind.none) ...[
          const SizedBox(height: 20),
          _CoachDialogueVisualPane(
            visual: visual,
            enabled: !locked && visual.requiresFeltTap,
            showSoftPulse:
                showGuidance && !locked && visual.requiresFeltTap,
            onRegionTap:
                locked ||
                        (visual.kind != CoachDialogueVisualKind.holeCards &&
                            visual.kind !=
                                CoachDialogueVisualKind.dealerButton &&
                            visual.kind !=
                                CoachDialogueVisualKind.positionLabels)
                    ? null
                    : (target) {
                      if (visual.kind == CoachDialogueVisualKind.holeCards &&
                          target.region == LessonTableRegion.hero) {
                        onFeltAcknowledge?.call();
                      } else if (visual.kind ==
                              CoachDialogueVisualKind.dealerButton &&
                          target.region == LessonTableRegion.button) {
                        onFeltAcknowledge?.call();
                      } else if (visual.kind ==
                              CoachDialogueVisualKind.positionLabels &&
                          target.region == LessonTableRegion.button) {
                        onFeltAcknowledge?.call();
                      }
                    },
            onSuitAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.suitsRanks
                    ? null
                    : onFeltAcknowledge,
            onLadderAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.handLadder
                    ? null
                    : onFeltAcknowledge,
            onBestFiveAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.bestFive
                    ? null
                    : onFeltAcknowledge,
          ),
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

  /// Six-max EP / HJ / CO / BTN / SB / BB labels.
  positionLabels,

  /// Weakest-to-strongest made-hand ladder.
  handLadder,

  /// Seven cards with five highlighted as the playing hand.
  bestFive,

  /// Fold / Check / Call action meanings.
  passiveActions,

  /// Bet / Raise / All-in action meanings.
  aggressiveActions,

  /// Preflop → river street timeline.
  streetsTimeline,

  /// Fold-win / showdown / side-pot paths.
  winningPaths,

  /// Blinds → you act → ending toy hand.
  toyHandRun,
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
      useTable
          ? 'Tap your two cards on the felt.'
          : 'Tap Continue when you have looked at your two cards.',
    CoachDialogueVisualKind.suitsRanks =>
      'Tap each of the four suits.',
    CoachDialogueVisualKind.dealerButton =>
      'Tap the dealer button on the table.',
    CoachDialogueVisualKind.positionLabels =>
      'Tap the button (BTN) — the latest seat.',
    CoachDialogueVisualKind.handLadder =>
      'Tap each rung from high card to flush.',
    CoachDialogueVisualKind.bestFive =>
      'Tap each gold card — only five of seven play.',
    CoachDialogueVisualKind.passiveActions =>
      'Tap Continue when Fold, Check, and Call click.',
    CoachDialogueVisualKind.aggressiveActions =>
      'Tap Continue when Bet, Raise, and All-in click.',
    CoachDialogueVisualKind.streetsTimeline =>
      'Tap Continue when the four streets click.',
    CoachDialogueVisualKind.winningPaths =>
      'Tap Continue when fold-win, showdown, and side pots click.',
    CoachDialogueVisualKind.toyHandRun =>
      'Tap Continue when blinds, your act, and the ending click.',
    CoachDialogueVisualKind.none => 'Tap Continue when you are ready.',
  };

  /// True when the learner should tap the demo instead of Continue.
  bool get requiresFeltTap =>
      (kind == CoachDialogueVisualKind.holeCards && useTable) ||
      kind == CoachDialogueVisualKind.suitsRanks ||
      kind == CoachDialogueVisualKind.dealerButton ||
      kind == CoachDialogueVisualKind.positionLabels ||
      kind == CoachDialogueVisualKind.handLadder ||
      kind == CoachDialogueVisualKind.bestFive;

  String get semanticsLabel => switch (kind) {
    CoachDialogueVisualKind.holeCards =>
      cardCodes.isEmpty
          ? 'Demonstration hole cards'
          : 'Demonstration hole cards ${cardCodes.join(' and ')}',
    CoachDialogueVisualKind.suitsRanks =>
      'Demonstration suits hearts diamonds clubs spades, ranks deuce through ace',
    CoachDialogueVisualKind.dealerButton =>
      'Poker table showing dealer button and blinds',
    CoachDialogueVisualKind.positionLabels =>
      'Six-max table showing EP, HJ, CO, button, and blinds',
    CoachDialogueVisualKind.handLadder =>
      'Hand rank ladder from high card to flush',
    CoachDialogueVisualKind.bestFive =>
      'Seven cards with five highlighted as the playing hand',
    CoachDialogueVisualKind.passiveActions =>
      'Fold, Check, and Call action buttons',
    CoachDialogueVisualKind.aggressiveActions =>
      'Bet, Raise, and All-in action buttons',
    CoachDialogueVisualKind.streetsTimeline =>
      'Street timeline from preflop to river',
    CoachDialogueVisualKind.winningPaths =>
      'Fold-win, showdown, and side-pot paths',
    CoachDialogueVisualKind.toyHandRun =>
      'Toy hand timeline: blinds, you act, ending',
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
    case 'act-02-01-01-explain-pos':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.positionLabels,
      );
    case 'act-01-02-01-explain-ladder':
      return const CoachDialogueVisual(kind: CoachDialogueVisualKind.handLadder);
    case 'act-01-02-02-explain-five':
      return const CoachDialogueVisual(kind: CoachDialogueVisualKind.bestFive);
    case 'act-01-03-01-explain-passive':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.passiveActions,
      );
    case 'act-01-03-02-explain-aggro':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.aggressiveActions,
      );
    case 'act-01-04-01-explain-streets':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.streetsTimeline,
      );
    case 'act-01-05-01-explain-win':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.winningPaths,
      );
    case 'act-01-06-01-explain-run':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.toyHandRun,
      );
  }

  final blob =
      '${activity.accessibilityText} '
              '${activity.primaryCoachLine?.text ?? ''} '
              '${activity.objectives.join(' ')}'
          .toLowerCase();

  if (blob.contains('one short hand') ||
      blob.contains('blinds post, you act') ||
      blob.contains('we reach an ending')) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.toyHandRun,
    );
  }
  if (blob.contains('folds win pots') ||
      blob.contains('showdown compares') ||
      blob.contains('short stacks make side')) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.winningPaths,
    );
  }
  if (blob.contains('four streets') ||
      blob.contains('preflop, flop, turn, river') ||
      blob.contains('match bets to move')) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.streetsTimeline,
    );
  }
  if (blob.contains('bet opens') ||
      blob.contains('raise reopens') ||
      blob.contains('all-in is just') ||
      blob.contains('size-capped')) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.aggressiveActions,
    );
  }
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
  const _CoachDialogueVisualPane({
    required this.visual,
    this.enabled = false,
    this.showSoftPulse = false,
    this.onRegionTap,
    this.onSuitAcknowledge,
    this.onLadderAcknowledge,
    this.onBestFiveAcknowledge,
  });

  final CoachDialogueVisual visual;
  final bool enabled;
  final bool showSoftPulse;
  final ValueChanged<LessonTableTapTarget>? onRegionTap;
  final VoidCallback? onSuitAcknowledge;
  final VoidCallback? onLadderAcknowledge;
  final VoidCallback? onBestFiveAcknowledge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: visual.semanticsLabel,
      child: switch (visual.kind) {
        CoachDialogueVisualKind.holeCards => _HoleCardDemo(
          visual: visual,
          enabled: enabled,
          showSoftPulse: showSoftPulse,
          onRegionTap: onRegionTap,
        ),
        CoachDialogueVisualKind.suitsRanks => _SuitsRanksDemo(
          interactive: onSuitAcknowledge != null,
          enabled: enabled,
          onAllSuitsTapped: onSuitAcknowledge,
        ),
        CoachDialogueVisualKind.dealerButton => _DealerButtonDemo(
          enabled: enabled,
          showSoftPulse: showSoftPulse,
          onRegionTap: onRegionTap,
        ),
        CoachDialogueVisualKind.positionLabels => _PositionLabelsDemo(
          enabled: enabled,
          showSoftPulse: showSoftPulse,
          onRegionTap: onRegionTap,
        ),
        CoachDialogueVisualKind.handLadder => HandRankLadderDemo(
          interactive: onLadderAcknowledge != null,
          enabled: enabled,
          onAllRungsTapped: onLadderAcknowledge,
        ),
        CoachDialogueVisualKind.bestFive => BestFiveDemo(
          interactive: onBestFiveAcknowledge != null,
          enabled: enabled,
          onAllPlayingTapped: onBestFiveAcknowledge,
        ),
        CoachDialogueVisualKind.passiveActions => const PassiveActionsDemo(),
        CoachDialogueVisualKind.aggressiveActions =>
          const AggressiveActionsDemo(),
        CoachDialogueVisualKind.streetsTimeline => const StreetsTimelineDemo(),
        CoachDialogueVisualKind.winningPaths => const WinningPathsDemo(),
        CoachDialogueVisualKind.toyHandRun => const ToyHandRunDemo(),
        CoachDialogueVisualKind.none => const SizedBox.shrink(),
      },
    );
  }
}

class _HoleCardDemo extends StatelessWidget {
  const _HoleCardDemo({
    required this.visual,
    this.enabled = false,
    this.showSoftPulse = false,
    this.onRegionTap,
  });

  final CoachDialogueVisual visual;
  final bool enabled;
  final bool showSoftPulse;
  final ValueChanged<LessonTableTapTarget>? onRegionTap;

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
        enabled: enabled,
        showSoftPulse: showSoftPulse,
        onRegionTap: onRegionTap,
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

class _SuitsRanksDemo extends StatefulWidget {
  const _SuitsRanksDemo({
    this.interactive = false,
    this.enabled = false,
    this.onAllSuitsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllSuitsTapped;

  @override
  State<_SuitsRanksDemo> createState() => _SuitsRanksDemoState();
}

class _SuitsRanksDemoState extends State<_SuitsRanksDemo> {
  static const _suits = <LessonSuitToken>[
    LessonSuitToken.hearts,
    LessonSuitToken.diamonds,
    LessonSuitToken.clubs,
    LessonSuitToken.spades,
  ];

  static const _ranks = <String>[
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'T',
    'J',
    'Q',
    'K',
    'A',
  ];

  final Set<LessonSuitToken> _tapped = <LessonSuitToken>{};

  void _onSuitTap(LessonSuitToken token) {
    if (!widget.enabled || widget.onAllSuitsTapped == null) return;
    setState(() => _tapped.add(token));
    if (_tapped.length >= _suits.length) {
      widget.onAllSuitsTapped!();
    }
  }

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
          if (widget.interactive)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (final token in _suits)
                  SuitTapTile(
                    token: token,
                    selected: _tapped.contains(token),
                    enabled: widget.enabled,
                    onPressed: () => _onSuitTap(token),
                  ),
              ],
            )
          else
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
  const _DealerButtonDemo({
    this.enabled = false,
    this.showSoftPulse = false,
    this.onRegionTap,
  });

  final bool enabled;
  final bool showSoftPulse;
  final ValueChanged<LessonTableTapTarget>? onRegionTap;

  @override
  Widget build(BuildContext context) {
    return LessonTableContext(
      scene: const LessonTableScene(
        layout: LessonTableLayout.blindsSeats,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
      ),
      enabled: enabled,
      showSoftPulse: showSoftPulse,
      onRegionTap: onRegionTap,
    );
  }
}

class _PositionLabelsDemo extends StatelessWidget {
  const _PositionLabelsDemo({
    this.enabled = false,
    this.showSoftPulse = false,
    this.onRegionTap,
  });

  final bool enabled;
  final bool showSoftPulse;
  final ValueChanged<LessonTableTapTarget>? onRegionTap;

  @override
  Widget build(BuildContext context) {
    return LessonTableContext(
      scene: const LessonTableScene(
        layout: LessonTableLayout.positionLabels,
        highlight: LessonTableHighlight.button,
        seatCount: 6,
        buttonSeat: 3,
        caption: 'Later seats see more action',
      ),
      enabled: enabled,
      showSoftPulse: showSoftPulse,
      onRegionTap: onRegionTap,
    );
  }
}
