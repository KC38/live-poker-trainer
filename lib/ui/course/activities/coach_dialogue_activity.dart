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
          const SizedBox(height: 12),
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
            onPassiveAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.passiveActions
                    ? null
                    : onFeltAcknowledge,
            onAggressiveAcknowledge:
                locked ||
                        visual.kind != CoachDialogueVisualKind.aggressiveActions
                    ? null
                    : onFeltAcknowledge,
            onStreetsAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.streetsTimeline
                    ? null
                    : onFeltAcknowledge,
            onPathsAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.winningPaths
                    ? null
                    : onFeltAcknowledge,
            onToyHandAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.toyHandRun
                    ? null
                    : onFeltAcknowledge,
            onActionOrderAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.actionOrder
                    ? null
                    : onFeltAcknowledge,
            onHandFamiliesAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.handFamilies
                    ? null
                    : onFeltAcknowledge,
            onOpenRangeAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.openRange
                    ? null
                    : onFeltAcknowledge,
            onVsOpenAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.vsOpenResponse
                    ? null
                    : onFeltAcknowledge,
            onBbStackAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.bbStackDepth
                    ? null
                    : onFeltAcknowledge,
            onTableHabitsAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.tableHabits
                    ? null
                    : onFeltAcknowledge,
            onFullRingAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.fullRing
                    ? null
                    : onFeltAcknowledge,
            onTableReadAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.tableRead
                    ? null
                    : onFeltAcknowledge,
            onFlopLabelAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.flopLabel
                    ? null
                    : onFeltAcknowledge,
            onOutsPriceAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.outsPrice
                    ? null
                    : onFeltAcknowledge,
            onFlopLinesAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.flopLines
                    ? null
                    : onFeltAcknowledge,
            onTurnStoryAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.turnStory
                    ? null
                    : onFeltAcknowledge,
            onRiverBinaryAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.riverBinary
                    ? null
                    : onFeltAcknowledge,
            onMultiwayAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.multiwayPlan
                    ? null
                    : onFeltAcknowledge,
            onCommonLeaksAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.commonLeaks
                    ? null
                    : onFeltAcknowledge,
            onRangeUpdateAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.rangeUpdate
                    ? null
                    : onFeltAcknowledge,
            onThreeBetSqueezeAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.threeBetSqueeze
                    ? null
                    : onFeltAcknowledge,
            onMultiStreetPlanAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.multiStreetPlan
                    ? null
                    : onFeltAcknowledge,
            onSizingLanguageAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.sizingLanguage
                    ? null
                    : onFeltAcknowledge,
            onSprAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.sprDepth
                    ? null
                    : onFeltAcknowledge,
          ),
        ],
        if (showGuidance && visual.requiresFeltTap) ...[
          const SizedBox(height: 10),
          _TapHint(text: visual.continueHint),
        ],
      ],
    );
  }
}

/// Compact gold instruction under an interactive demo (not a second Rex bubble).
class _TapHint extends StatelessWidget {
  const _TapHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.manrope(
          color: AppColors.gold,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
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

  /// Preflop seats left-of-BB in order (UTG → HJ → BTN).
  actionOrder,

  /// Starting-hand families (pairs, broadways, suited aces, connectors).
  handFamilies,

  /// Early vs button open ranges and live ~3x sizing.
  openRange,

  /// Fold / call / 3-bet responses versus an open.
  vsOpenResponse,

  /// Count stacks in BB; shorter stack sets effective depth.
  bbStackDepth,

  /// Live-table habits: watch, say, cover, wait.
  tableHabits,

  /// Nine-max table: same rules; position still matters.
  fullRing,

  /// Pre-deal table read: pot, stacks, button, who acts.
  tableRead,

  /// Flop hand labels: made, draw, showdown value, air.
  flopLabel,

  /// Clean vs dirty outs and pricing the call.
  outsPrice,

  /// Flop line menu: value, c-bet, check, call, fold, raise.
  flopLines,

  /// Turn brick vs change; barrel or delay with intent.
  turnStory,

  /// River binary: value, bluff, bluff-catch, or fold.
  riverBinary,

  /// Multiway: stronger value, fewer bluffs, chase nuts.
  multiwayPlan,

  /// Common live leaks: top pair, prices, passive, crowds.
  commonLeaks,

  /// Ranges not one hand — then update with each action.
  rangeUpdate,

  /// 3-bets define ranges; squeezes punish multiway flats.
  threeBetSqueeze,

  /// Flop choice must answer turn and river plans.
  multiStreetPlan,

  /// Size is language: value vs polar pressure.
  sizingLanguage,

  /// SPR = stack/pot; low commit, high maneuver.
  sprDepth,
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
      'Tap Fold, Check, and Call.',
    CoachDialogueVisualKind.aggressiveActions =>
      'Tap Bet, Raise, and All-in.',
    CoachDialogueVisualKind.streetsTimeline =>
      'Tap each street from preflop to river.',
    CoachDialogueVisualKind.winningPaths =>
      'Tap Fold win, Showdown, and Side pot.',
    CoachDialogueVisualKind.toyHandRun =>
      'Tap Blinds, You act, and Ending.',
    CoachDialogueVisualKind.actionOrder =>
      'Tap UTG, then HJ, then BTN.',
    CoachDialogueVisualKind.handFamilies =>
      'Tap each starting-hand family.',
    CoachDialogueVisualKind.openRange =>
      'Tap Early, Button, and Live 3x.',
    CoachDialogueVisualKind.vsOpenResponse =>
      'Tap Fold, Call, and 3-Bet.',
    CoachDialogueVisualKind.bbStackDepth =>
      'Tap Chips→BB, Shorter, and Depth.',
    CoachDialogueVisualKind.tableHabits =>
      'Tap Watch, Say, Cover, and Wait.',
    CoachDialogueVisualKind.fullRing =>
      'Tap Nine, Same, and Position.',
    CoachDialogueVisualKind.tableRead =>
      'Tap Pot, Stacks, Button, and Who Acts.',
    CoachDialogueVisualKind.flopLabel =>
      'Tap Made, Draw, SDV, and Air.',
    CoachDialogueVisualKind.outsPrice =>
      'Tap Clean, Dirty, and Price.',
    CoachDialogueVisualKind.flopLines =>
      'Tap each flop line once.',
    CoachDialogueVisualKind.turnStory =>
      'Tap Brick, Change, Barrel, and Delay.',
    CoachDialogueVisualKind.riverBinary =>
      'Tap Value, Bluff, Catch, and Fold.',
    CoachDialogueVisualKind.multiwayPlan =>
      'Tap Stronger, Fewer, and Nuts.',
    CoachDialogueVisualKind.commonLeaks =>
      'Tap each common leak once.',
    CoachDialogueVisualKind.rangeUpdate =>
      'Tap One Hand, Range, and Update.',
    CoachDialogueVisualKind.threeBetSqueeze =>
      'Tap 3-Bet, Ranges, and Squeeze.',
    CoachDialogueVisualKind.multiStreetPlan =>
      'Tap Flop, Turn, and River.',
    CoachDialogueVisualKind.sizingLanguage =>
      'Tap Value, Pressure, and Size.',
    CoachDialogueVisualKind.sprDepth =>
      'Tap SPR, Low, and High.',
    CoachDialogueVisualKind.none => 'Tap Continue when you are ready.',
  };

  /// True when the learner should tap the demo instead of Continue.
  bool get requiresFeltTap =>
      (kind == CoachDialogueVisualKind.holeCards && useTable) ||
      kind == CoachDialogueVisualKind.suitsRanks ||
      kind == CoachDialogueVisualKind.dealerButton ||
      kind == CoachDialogueVisualKind.positionLabels ||
      kind == CoachDialogueVisualKind.handLadder ||
      kind == CoachDialogueVisualKind.bestFive ||
      kind == CoachDialogueVisualKind.passiveActions ||
      kind == CoachDialogueVisualKind.aggressiveActions ||
      kind == CoachDialogueVisualKind.streetsTimeline ||
      kind == CoachDialogueVisualKind.winningPaths ||
      kind == CoachDialogueVisualKind.toyHandRun ||
      kind == CoachDialogueVisualKind.actionOrder ||
      kind == CoachDialogueVisualKind.handFamilies ||
      kind == CoachDialogueVisualKind.openRange ||
      kind == CoachDialogueVisualKind.vsOpenResponse ||
      kind == CoachDialogueVisualKind.bbStackDepth ||
      kind == CoachDialogueVisualKind.tableHabits ||
      kind == CoachDialogueVisualKind.fullRing ||
      kind == CoachDialogueVisualKind.tableRead ||
      kind == CoachDialogueVisualKind.flopLabel ||
      kind == CoachDialogueVisualKind.outsPrice ||
      kind == CoachDialogueVisualKind.flopLines ||
      kind == CoachDialogueVisualKind.turnStory ||
      kind == CoachDialogueVisualKind.riverBinary ||
      kind == CoachDialogueVisualKind.multiwayPlan ||
      kind == CoachDialogueVisualKind.commonLeaks ||
      kind == CoachDialogueVisualKind.rangeUpdate ||
      kind == CoachDialogueVisualKind.threeBetSqueeze ||
      kind == CoachDialogueVisualKind.multiStreetPlan ||
      kind == CoachDialogueVisualKind.sizingLanguage ||
      kind == CoachDialogueVisualKind.sprDepth;

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
    CoachDialogueVisualKind.actionOrder =>
      'Preflop action order tiles UTG, HJ, and BTN',
    CoachDialogueVisualKind.handFamilies =>
      'Starting-hand family tiles: pairs, broadways, suited aces, connectors',
    CoachDialogueVisualKind.openRange =>
      'Open-range tiles: early strong, button wider, live 3x size',
    CoachDialogueVisualKind.vsOpenResponse =>
      'Versus-open response tiles: fold, call, and 3-bet',
    CoachDialogueVisualKind.bbStackDepth =>
      'Stack-depth tiles: chips to BB, shorter stack, depth',
    CoachDialogueVisualKind.tableHabits =>
      'Live-table habit tiles: watch, say, cover, wait',
    CoachDialogueVisualKind.fullRing =>
      'Full-ring tiles: nine seats, same rules, position',
    CoachDialogueVisualKind.tableRead =>
      'Table-read tiles: pot, stacks, button, who acts',
    CoachDialogueVisualKind.flopLabel =>
      'Flop-label tiles: made, draw, showdown value, air',
    CoachDialogueVisualKind.outsPrice =>
      'Outs tiles: clean, dirty, and price the call',
    CoachDialogueVisualKind.flopLines =>
      'Flop-line tiles: value, c-bet, check, call, fold, raise',
    CoachDialogueVisualKind.turnStory =>
      'Turn-story tiles: brick, change, barrel, delay',
    CoachDialogueVisualKind.riverBinary =>
      'River-binary tiles: value, bluff, catch, fold',
    CoachDialogueVisualKind.multiwayPlan =>
      'Multiway tiles: stronger value, fewer bluffs, nuts',
    CoachDialogueVisualKind.commonLeaks =>
      'Leak tiles: top pair, bad prices, passive, crowds',
    CoachDialogueVisualKind.rangeUpdate =>
      'Range tiles: one hand, range, update',
    CoachDialogueVisualKind.threeBetSqueeze =>
      '3-bet tiles: 3-bet, ranges, squeeze',
    CoachDialogueVisualKind.multiStreetPlan =>
      'Multi-street tiles: flop, turn, river',
    CoachDialogueVisualKind.sizingLanguage =>
      'Sizing tiles: value, pressure, size',
    CoachDialogueVisualKind.sprDepth =>
      'SPR tiles: ratio, low commit, high maneuver',
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
    case 'act-02-01-02-explain-order':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.actionOrder,
      );
    case 'act-02-02-01-explain-families':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.handFamilies,
      );
    case 'act-02-03-01-explain-open':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.openRange,
      );
    case 'act-02-04-01-explain-vs':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.vsOpenResponse,
      );
    case 'act-02-05-01-explain-bb':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.bbStackDepth,
      );
    case 'act-02-06-01-explain-habits':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.tableHabits,
      );
    case 'act-02-07-01-explain-full':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.fullRing,
      );
    case 'act-03-01-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.tableRead,
      );
    case 'act-03-02-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.flopLabel,
      );
    case 'act-03-03-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.outsPrice,
      );
    case 'act-03-04-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.flopLines,
      );
    case 'act-03-05-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.turnStory,
      );
    case 'act-03-06-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.riverBinary,
      );
    case 'act-03-07-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.multiwayPlan,
      );
    case 'act-03-08-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.commonLeaks,
      );
    case 'act-04-01-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.rangeUpdate,
      );
    case 'act-04-02-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.threeBetSqueeze,
      );
    case 'act-04-03-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.multiStreetPlan,
      );
    case 'act-04-04-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.sizingLanguage,
      );
    case 'act-04-05-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.sprDepth,
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
  if (blob.contains('four suits') ||
      blob.contains('deuce') ||
      blob.contains('ace is high') ||
      (blob.contains('hearts') && blob.contains('spades')) ||
      (blob.contains('rank') && blob.contains('thirteen'))) {
    return const CoachDialogueVisual(kind: CoachDialogueVisualKind.suitsRanks);
  }
  // Avoid false hits on "suited", "big blind", "Button: wider", "steal blinds".
  if (blob.contains('dealer button') ||
      blob.contains('the button marks') ||
      blob.contains('button marks the') ||
      blob.contains('button and blinds') ||
      blob.contains('who posts') ||
      (blob.contains('dealer') && blob.contains('button'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.dealerButton,
    );
  }
  if (blob.contains('preflop starts left') ||
      blob.contains('postflop starts left') ||
      blob.contains('left of the big blind') ||
      blob.contains('left of the button') ||
      blob.contains('action order after the blinds')) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.actionOrder,
    );
  }
  // Before hole-card matching — "whole edge" contains the letters "hole".
  if (blob.contains('later seats') ||
      blob.contains('prefer later') ||
      blob.contains('latest seat')) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.positionLabels,
    );
  }
  if (blob.contains('suited aces') ||
      blob.contains('starting-hand families') ||
      (blob.contains('pairs') &&
          blob.contains('broadway') &&
          blob.contains('connector'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.handFamilies,
    );
  }
  if (blob.contains('early: strong') ||
      blob.contains('button: wider') ||
      blob.contains('live opens often') ||
      (blob.contains('strong only') && blob.contains('wider'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.openRange,
    );
  }
  if (blob.contains('weak hands fold') ||
      blob.contains('playable hands call') ||
      blob.contains('strong hands make it more') ||
      (blob.contains('versus an open') || blob.contains('facing an open'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.vsOpenResponse,
    );
  }
  // Avoid bare "effective stack" — SPR / rewrite explains are not BB-count demos.
  if (blob.contains('count stacks in big blinds') ||
      blob.contains('shorter stack sets the ceiling') ||
      (blob.contains('big blinds') &&
          blob.contains('shorter') &&
          (blob.contains('ceiling') || blob.contains('count stacks')))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.bbStackDepth,
    );
  }
  if (blob.contains('watch the action') ||
      blob.contains('cover your cards') ||
      blob.contains('wait your turn') ||
      (blob.contains('say your action') && blob.contains('cover'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.tableHabits,
    );
  }
  if (blob.contains('nine seats') ||
      blob.contains('full ring') ||
      blob.contains('full-ring') ||
      (blob.contains('same rules') && blob.contains('position'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.fullRing,
    );
  }
  if (blob.contains('before cards') ||
      blob.contains('read pot') ||
      blob.contains('words count live') ||
      (blob.contains('stacks') &&
          blob.contains('button') &&
          blob.contains('who acts'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.tableRead,
    );
  }
  if (blob.contains('flop first') ||
      blob.contains('label before you bet') ||
      blob.contains('showdown value') ||
      (blob.contains('made') &&
          blob.contains('draw') &&
          blob.contains('air'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.flopLabel,
    );
  }
  if (blob.contains('clean outs') ||
      blob.contains('dirty outs') ||
      blob.contains('price the call') ||
      (blob.contains('second-best') && blob.contains('outs'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.outsPrice,
    );
  }
  if (blob.contains('flop lines') ||
      blob.contains('one plan') ||
      blob.contains('c-bet') ||
      (blob.contains('check back') && blob.contains('raise'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.flopLines,
    );
  }
  if (blob.contains('turn cards') ||
      blob.contains('change the story') ||
      blob.contains('barrel or delay') ||
      (blob.contains('brick') && blob.contains('barrel'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.turnStory,
    );
  }
  // River binary — require river framing. Bare "bluff-catch" / value+bluff+fold
  // steals maniac, LAG, thin-value, and station explains onto river tiles.
  if (blob.contains('river is binary') ||
      blob.contains('no mystery floats') ||
      (blob.contains('river') &&
          (blob.contains('bluff-catch') ||
              (blob.contains('bluff') &&
                  blob.contains('fold') &&
                  blob.contains('value'))))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.riverBinary,
    );
  }
  // Multiway — keep "fewer bluffs" tied to multiway / more-players framing.
  if (blob.contains('chase nuts') ||
      (blob.contains('stronger value') && blob.contains('multiway')) ||
      (blob.contains('more players') &&
          (blob.contains('bluff') ||
              blob.contains('value') ||
              blob.contains('nuts'))) ||
      (blob.contains('fewer bluffs') &&
          (blob.contains('multiway') || blob.contains('more players')))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.multiwayPlan,
    );
  }
  if (blob.contains('common leaks') ||
      blob.contains('worship top pair') ||
      blob.contains('chase bad prices') ||
      blob.contains('bluff crowds') ||
      (blob.contains('call too passive') && blob.contains('leak'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.commonLeaks,
    );
  }
  if (blob.contains('never know one hand') ||
      blob.contains('know a range') ||
      blob.contains('then update it') ||
      (blob.contains('one hand') && blob.contains('range'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.rangeUpdate,
    );
  }
  if (blob.contains('3-bets define') ||
      blob.contains('squeezes punish') ||
      blob.contains('multiway limps') ||
      (blob.contains('squeeze') && blob.contains('flatting'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.threeBetSqueeze,
    );
  }
  if (blob.contains('turn and river') ||
      blob.contains('multi-street plan') ||
      blob.contains('what do i do on turn') ||
      (blob.contains('flop choice') && blob.contains('river'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.multiStreetPlan,
    );
  }
  if (blob.contains('size is language') ||
      blob.contains('value looks like value') ||
      blob.contains('pressure looks like pressure') ||
      (blob.contains('polar') && blob.contains('pressure'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.sizingLanguage,
    );
  }
  if (blob.contains('spr') ||
      blob.contains('stack-to-pot') ||
      blob.contains('stack to pot') ||
      (blob.contains('effective stack') && blob.contains('pot'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.sprDepth,
    );
  }
  // Word-boundary on "hole" so "whole" / "wholesale" do not steal this demo.
  if (RegExp(r'\bhole\b').hasMatch(blob) ||
      blob.contains('your two') ||
      blob.contains('yours alone') ||
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
    this.onPassiveAcknowledge,
    this.onAggressiveAcknowledge,
    this.onStreetsAcknowledge,
    this.onPathsAcknowledge,
    this.onToyHandAcknowledge,
    this.onActionOrderAcknowledge,
    this.onHandFamiliesAcknowledge,
    this.onOpenRangeAcknowledge,
    this.onVsOpenAcknowledge,
    this.onBbStackAcknowledge,
    this.onTableHabitsAcknowledge,
    this.onFullRingAcknowledge,
    this.onTableReadAcknowledge,
    this.onFlopLabelAcknowledge,
    this.onOutsPriceAcknowledge,
    this.onFlopLinesAcknowledge,
    this.onTurnStoryAcknowledge,
    this.onRiverBinaryAcknowledge,
    this.onMultiwayAcknowledge,
    this.onCommonLeaksAcknowledge,
    this.onRangeUpdateAcknowledge,
    this.onThreeBetSqueezeAcknowledge,
    this.onMultiStreetPlanAcknowledge,
    this.onSizingLanguageAcknowledge,
    this.onSprAcknowledge,
  });

  final CoachDialogueVisual visual;
  final bool enabled;
  final bool showSoftPulse;
  final ValueChanged<LessonTableTapTarget>? onRegionTap;
  final VoidCallback? onSuitAcknowledge;
  final VoidCallback? onLadderAcknowledge;
  final VoidCallback? onBestFiveAcknowledge;
  final VoidCallback? onPassiveAcknowledge;
  final VoidCallback? onAggressiveAcknowledge;
  final VoidCallback? onStreetsAcknowledge;
  final VoidCallback? onPathsAcknowledge;
  final VoidCallback? onToyHandAcknowledge;
  final VoidCallback? onActionOrderAcknowledge;
  final VoidCallback? onHandFamiliesAcknowledge;
  final VoidCallback? onOpenRangeAcknowledge;
  final VoidCallback? onVsOpenAcknowledge;
  final VoidCallback? onBbStackAcknowledge;
  final VoidCallback? onTableHabitsAcknowledge;
  final VoidCallback? onFullRingAcknowledge;
  final VoidCallback? onTableReadAcknowledge;
  final VoidCallback? onFlopLabelAcknowledge;
  final VoidCallback? onOutsPriceAcknowledge;
  final VoidCallback? onFlopLinesAcknowledge;
  final VoidCallback? onTurnStoryAcknowledge;
  final VoidCallback? onRiverBinaryAcknowledge;
  final VoidCallback? onMultiwayAcknowledge;
  final VoidCallback? onCommonLeaksAcknowledge;
  final VoidCallback? onRangeUpdateAcknowledge;
  final VoidCallback? onThreeBetSqueezeAcknowledge;
  final VoidCallback? onMultiStreetPlanAcknowledge;
  final VoidCallback? onSizingLanguageAcknowledge;
  final VoidCallback? onSprAcknowledge;

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
        CoachDialogueVisualKind.passiveActions => PassiveActionsDemo(
          interactive: onPassiveAcknowledge != null,
          enabled: enabled,
          onAllActionsTapped: onPassiveAcknowledge,
        ),
        CoachDialogueVisualKind.aggressiveActions => AggressiveActionsDemo(
          interactive: onAggressiveAcknowledge != null,
          enabled: enabled,
          onAllActionsTapped: onAggressiveAcknowledge,
        ),
        CoachDialogueVisualKind.streetsTimeline => StreetsTimelineDemo(
          interactive: onStreetsAcknowledge != null,
          enabled: enabled,
          onAllStreetsTapped: onStreetsAcknowledge,
        ),
        CoachDialogueVisualKind.winningPaths => WinningPathsDemo(
          interactive: onPathsAcknowledge != null,
          enabled: enabled,
          onAllPathsTapped: onPathsAcknowledge,
        ),
        CoachDialogueVisualKind.toyHandRun => ToyHandRunDemo(
          interactive: onToyHandAcknowledge != null,
          enabled: enabled,
          onAllStepsTapped: onToyHandAcknowledge,
        ),
        CoachDialogueVisualKind.actionOrder => ActionOrderDemo(
          interactive: onActionOrderAcknowledge != null,
          enabled: enabled,
          onAllSeatsTapped: onActionOrderAcknowledge,
        ),
        CoachDialogueVisualKind.handFamilies => HandFamiliesDemo(
          interactive: onHandFamiliesAcknowledge != null,
          enabled: enabled,
          onAllFamiliesTapped: onHandFamiliesAcknowledge,
        ),
        CoachDialogueVisualKind.openRange => OpenRangeDemo(
          interactive: onOpenRangeAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onOpenRangeAcknowledge,
        ),
        CoachDialogueVisualKind.vsOpenResponse => VsOpenResponseDemo(
          interactive: onVsOpenAcknowledge != null,
          enabled: enabled,
          onAllResponsesTapped: onVsOpenAcknowledge,
        ),
        CoachDialogueVisualKind.bbStackDepth => BbStackDepthDemo(
          interactive: onBbStackAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onBbStackAcknowledge,
        ),
        CoachDialogueVisualKind.tableHabits => TableHabitsDemo(
          interactive: onTableHabitsAcknowledge != null,
          enabled: enabled,
          onAllHabitsTapped: onTableHabitsAcknowledge,
        ),
        CoachDialogueVisualKind.fullRing => FullRingDemo(
          interactive: onFullRingAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onFullRingAcknowledge,
        ),
        CoachDialogueVisualKind.tableRead => TableReadDemo(
          interactive: onTableReadAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onTableReadAcknowledge,
        ),
        CoachDialogueVisualKind.flopLabel => FlopLabelDemo(
          interactive: onFlopLabelAcknowledge != null,
          enabled: enabled,
          onAllLabelsTapped: onFlopLabelAcknowledge,
        ),
        CoachDialogueVisualKind.outsPrice => OutsPriceDemo(
          interactive: onOutsPriceAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onOutsPriceAcknowledge,
        ),
        CoachDialogueVisualKind.flopLines => FlopLinesDemo(
          interactive: onFlopLinesAcknowledge != null,
          enabled: enabled,
          onAllLinesTapped: onFlopLinesAcknowledge,
        ),
        CoachDialogueVisualKind.turnStory => TurnStoryDemo(
          interactive: onTurnStoryAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onTurnStoryAcknowledge,
        ),
        CoachDialogueVisualKind.riverBinary => RiverBinaryDemo(
          interactive: onRiverBinaryAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onRiverBinaryAcknowledge,
        ),
        CoachDialogueVisualKind.multiwayPlan => MultiwayPlanDemo(
          interactive: onMultiwayAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onMultiwayAcknowledge,
        ),
        CoachDialogueVisualKind.commonLeaks => CommonLeaksDemo(
          interactive: onCommonLeaksAcknowledge != null,
          enabled: enabled,
          onAllLeaksTapped: onCommonLeaksAcknowledge,
        ),
        CoachDialogueVisualKind.rangeUpdate => RangeUpdateDemo(
          interactive: onRangeUpdateAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onRangeUpdateAcknowledge,
        ),
        CoachDialogueVisualKind.threeBetSqueeze => ThreeBetSqueezeDemo(
          interactive: onThreeBetSqueezeAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onThreeBetSqueezeAcknowledge,
        ),
        CoachDialogueVisualKind.multiStreetPlan => MultiStreetPlanDemo(
          interactive: onMultiStreetPlanAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onMultiStreetPlanAcknowledge,
        ),
        CoachDialogueVisualKind.sizingLanguage => SizingLanguageDemo(
          interactive: onSizingLanguageAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onSizingLanguageAcknowledge,
        ),
        CoachDialogueVisualKind.sprDepth => SprDepthDemo(
          interactive: onSprAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onSprAcknowledge,
        ),
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
