/// Coach demonstration / dialogue activity.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
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
import 'package:live_poker_trainer/ui/course/widgets/lag_model_demo.dart';
import 'package:live_poker_trainer/ui/course/widgets/wide_pressure_demo.dart';
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
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final visual = resolveCoachDialogueVisual(activity);
        final locked =
            controller.submitting || controller.lastResult != null;
        return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Nice! owns the teaching line — hide stale Rex above feedback.
        if (!locked) RexCoachLine.fromActivity(activity),
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
            onPlayerObserveAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.playerObserve
                    ? null
                    : onFeltAcknowledge,
            onCallingStationAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.callingStation
                    ? null
                    : onFeltAcknowledge,
            onVsStationAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.vsStation
                    ? null
                    : onFeltAcknowledge,
            onTightSeatsAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.tightSeats
                    ? null
                    : onFeltAcknowledge,
            onNitModelAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.nitModel
                    ? null
                    : onFeltAcknowledge,
            onVsNitsAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.vsNits
                    ? null
                    : onFeltAcknowledge,
            onExtremeEntryAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.extremeEntry
                    ? null
                    : onFeltAcknowledge,
            onManiacModelAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.maniacModel
                    ? null
                    : onFeltAcknowledge,
            onVsManiacsAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.vsManiacs
                    ? null
                    : onFeltAcknowledge,
            onVsTagsAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.vsTags
                    ? null
                    : onFeltAcknowledge,
            onVsLagsAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.vsLags
                    ? null
                    : onFeltAcknowledge,
            onObservationCertaintyAcknowledge:
                locked ||
                        visual.kind !=
                            CoachDialogueVisualKind.observationCertainty
                    ? null
                    : onFeltAcknowledge,
            onExploitEvidenceAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.exploitEvidence
                    ? null
                    : onFeltAcknowledge,
            onMultiwayNutsAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.multiwayNuts
                    ? null
                    : onFeltAcknowledge,
            onDeepStacksAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.deepStacks
                    ? null
                    : onFeltAcknowledge,
            onImpliedOddsAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.impliedOdds
                    ? null
                    : onFeltAcknowledge,
            onThinValueAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.thinValue
                    ? null
                    : onFeltAcknowledge,
            onLineStoriesAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.lineStories
                    ? null
                    : onFeltAcknowledge,
            onRangeRewriteAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.rangeRewrite
                    ? null
                    : onFeltAcknowledge,
            onTimingCluesAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.timingClues
                    ? null
                    : onFeltAcknowledge,
            onTablesChangeAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.tablesChange
                    ? null
                    : onFeltAcknowledge,
            onGuardrailsAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.guardrails
                    ? null
                    : onFeltAcknowledge,
            onRangeAdvantageAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.rangeAdvantage
                    ? null
                    : onFeltAcknowledge,
            onEquityRealizeAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.equityRealize
                    ? null
                    : onFeltAcknowledge,
            onCappedUncappedAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.cappedUncapped
                    ? null
                    : onFeltAcknowledge,
            onPolarMergedAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.polarMerged
                    ? null
                    : onFeltAcknowledge,
            onOverbetGeometryAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.overbetGeometry
                    ? null
                    : onFeltAcknowledge,
            onBlockersAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.blockers
                    ? null
                    : onFeltAcknowledge,
            onDefendEnoughAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.defendEnough
                    ? null
                    : onFeltAcknowledge,
            onMixedStrategyAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.mixedStrategy
                    ? null
                    : onFeltAcknowledge,
            onThreeBetFourBetSprAcknowledge:
                locked ||
                        visual.kind != CoachDialogueVisualKind.threeBetFourBetSpr
                    ? null
                    : onFeltAcknowledge,
            onHardFoldCoolerAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.hardFoldCooler
                    ? null
                    : onFeltAcknowledge,
            onSelectiveAggressionAcknowledge:
                locked ||
                        visual.kind !=
                            CoachDialogueVisualKind.selectiveAggression
                    ? null
                    : onFeltAcknowledge,
            onTagModelAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.tagModel
                    ? null
                    : onFeltAcknowledge,
            onLagModelAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.lagModel
                    ? null
                    : onFeltAcknowledge,
            onWidePressureAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.widePressure
                    ? null
                    : onFeltAcknowledge,
            onPreflopFlopPlanAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.preflopFlopPlan
                    ? null
                    : onFeltAcknowledge,
            onTurnMapAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.turnMap
                    ? null
                    : onFeltAcknowledge,
            onRiverCompositionAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.riverComposition
                    ? null
                    : onFeltAcknowledge,
            onPotTypePlansAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.potTypePlans
                    ? null
                    : onFeltAcknowledge,
            onHuVsMultiwayAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.huVsMultiway
                    ? null
                    : onFeltAcknowledge,
            onStackDepthPlansAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.stackDepthPlans
                    ? null
                    : onFeltAcknowledge,
            onSameCardsTypesAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.sameCardsTypes
                    ? null
                    : onFeltAcknowledge,
            onTypeBoardLineAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.typeBoardLine
                    ? null
                    : onFeltAcknowledge,
            onLeakReviewBookAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.leakReviewBook
                    ? null
                    : onFeltAcknowledge,
            onCapstoneSrpAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.capstoneSrp
                    ? null
                    : onFeltAcknowledge,
            onCapstone3betAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.capstone3bet
                    ? null
                    : onFeltAcknowledge,
            onCapstoneMultiwayDeepAcknowledge:
                locked ||
                        visual.kind !=
                            CoachDialogueVisualKind.capstoneMultiwayDeep
                    ? null
                    : onFeltAcknowledge,
            onCapstoneLimpedAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.capstoneLimped
                    ? null
                    : onFeltAcknowledge,
            onCapstone4betAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.capstone4bet
                    ? null
                    : onFeltAcknowledge,
            onLiveWarmupPrepAcknowledge:
                locked || visual.kind != CoachDialogueVisualKind.liveWarmupPrep
                    ? null
                    : onFeltAcknowledge,
          ),
        ],
        if (showGuidance &&
            !locked &&
            visual.requiresFeltTap &&
            // These demos embed their own tap hint on the felt / chrome —
            // or Rex already names the tiles (no duplicate gold footer).
            visual.kind != CoachDialogueVisualKind.bestFive &&
            visual.kind != CoachDialogueVisualKind.holeCards &&
            visual.kind != CoachDialogueVisualKind.suitsRanks &&
            visual.kind != CoachDialogueVisualKind.handLadder &&
            visual.kind != CoachDialogueVisualKind.dealerButton &&
            visual.kind != CoachDialogueVisualKind.positionLabels &&
            visual.kind != CoachDialogueVisualKind.passiveActions &&
            visual.kind != CoachDialogueVisualKind.aggressiveActions &&
            visual.kind != CoachDialogueVisualKind.streetsTimeline &&
            visual.kind != CoachDialogueVisualKind.winningPaths &&
            visual.kind != CoachDialogueVisualKind.toyHandRun &&
            visual.kind != CoachDialogueVisualKind.actionOrder &&
            visual.kind != CoachDialogueVisualKind.handFamilies &&
            visual.kind != CoachDialogueVisualKind.openRange &&
            visual.kind != CoachDialogueVisualKind.vsOpenResponse &&
            visual.kind != CoachDialogueVisualKind.bbStackDepth &&
            visual.kind != CoachDialogueVisualKind.tableHabits &&
            visual.kind != CoachDialogueVisualKind.fullRing &&
            visual.kind != CoachDialogueVisualKind.tableRead &&
            visual.kind != CoachDialogueVisualKind.flopLabel &&
            visual.kind != CoachDialogueVisualKind.outsPrice &&
            visual.kind != CoachDialogueVisualKind.flopLines &&
            visual.kind != CoachDialogueVisualKind.turnStory &&
            visual.kind != CoachDialogueVisualKind.riverBinary &&
            visual.kind != CoachDialogueVisualKind.multiwayPlan &&
            visual.kind != CoachDialogueVisualKind.commonLeaks &&
            visual.kind != CoachDialogueVisualKind.rangeUpdate &&
            visual.kind != CoachDialogueVisualKind.threeBetSqueeze &&
            visual.kind != CoachDialogueVisualKind.multiStreetPlan &&
            visual.kind != CoachDialogueVisualKind.sizingLanguage &&
            visual.kind != CoachDialogueVisualKind.sprDepth &&
            visual.kind != CoachDialogueVisualKind.playerObserve &&
            visual.kind != CoachDialogueVisualKind.callingStation &&
            visual.kind != CoachDialogueVisualKind.vsStation &&
            visual.kind != CoachDialogueVisualKind.tightSeats &&
            visual.kind != CoachDialogueVisualKind.nitModel &&
            visual.kind != CoachDialogueVisualKind.vsNits &&
            visual.kind != CoachDialogueVisualKind.extremeEntry &&
            visual.kind != CoachDialogueVisualKind.maniacModel &&
            visual.kind != CoachDialogueVisualKind.vsManiacs &&
            visual.kind != CoachDialogueVisualKind.observationCertainty &&
            visual.kind != CoachDialogueVisualKind.exploitEvidence &&
            visual.kind != CoachDialogueVisualKind.multiwayNuts &&
            visual.kind != CoachDialogueVisualKind.deepStacks &&
            visual.kind != CoachDialogueVisualKind.impliedOdds &&
            visual.kind != CoachDialogueVisualKind.thinValue &&
            visual.kind != CoachDialogueVisualKind.lineStories &&
            visual.kind != CoachDialogueVisualKind.rangeRewrite &&
            visual.kind != CoachDialogueVisualKind.timingClues &&
            visual.kind != CoachDialogueVisualKind.vsTags &&
            visual.kind != CoachDialogueVisualKind.vsLags &&
            visual.kind != CoachDialogueVisualKind.tablesChange &&
            visual.kind != CoachDialogueVisualKind.guardrails &&
            visual.kind != CoachDialogueVisualKind.rangeAdvantage &&
            visual.kind != CoachDialogueVisualKind.equityRealize &&
            visual.kind != CoachDialogueVisualKind.cappedUncapped &&
            visual.kind != CoachDialogueVisualKind.polarMerged &&
            visual.kind != CoachDialogueVisualKind.overbetGeometry &&
            visual.kind != CoachDialogueVisualKind.blockers &&
            visual.kind != CoachDialogueVisualKind.defendEnough &&
            visual.kind != CoachDialogueVisualKind.mixedStrategy &&
            visual.kind != CoachDialogueVisualKind.threeBetFourBetSpr &&
            visual.kind != CoachDialogueVisualKind.hardFoldCooler &&
            visual.kind != CoachDialogueVisualKind.selectiveAggression &&
            visual.kind != CoachDialogueVisualKind.tagModel &&
            visual.kind != CoachDialogueVisualKind.lagModel &&
            visual.kind != CoachDialogueVisualKind.widePressure &&
            visual.kind != CoachDialogueVisualKind.preflopFlopPlan &&
            visual.kind != CoachDialogueVisualKind.potTypePlans &&
            visual.kind != CoachDialogueVisualKind.huVsMultiway &&
            visual.kind != CoachDialogueVisualKind.stackDepthPlans &&
            visual.kind != CoachDialogueVisualKind.sameCardsTypes &&
            visual.kind != CoachDialogueVisualKind.typeBoardLine &&
            visual.kind != CoachDialogueVisualKind.leakReviewBook &&
            visual.kind != CoachDialogueVisualKind.capstoneSrp &&
            visual.kind != CoachDialogueVisualKind.capstone3bet &&
            visual.kind !=
                CoachDialogueVisualKind.capstoneMultiwayDeep &&
            visual.kind != CoachDialogueVisualKind.capstoneLimped &&
            visual.kind != CoachDialogueVisualKind.capstone4bet &&
            visual.kind != CoachDialogueVisualKind.liveWarmupPrep &&
            visual.kind != CoachDialogueVisualKind.turnMap &&
            visual.kind != CoachDialogueVisualKind.riverComposition) ...[
          const SizedBox(height: 10),
          _TapHint(text: visual.continueHint),
        ],
      ],
    );
      },
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

  /// Observe who enters, calls, folds before labeling.
  playerObserve,

  /// Calling Station: high participation, low folding.
  callingStation,

  /// Versus stations: thicker value, fewer bluffs, cite calling.
  vsStation,

  /// Tight seats rarely enter; when they do, they mean it.
  tightSeats,

  /// Nit: narrow entry; respect their heavy action.
  nitModel,

  /// Versus nits: steal blinds more; give credit when they explode.
  vsNits,

  /// Extreme entry: raise and barrel seemingly forever.
  extremeEntry,

  /// Maniac: extreme entry and aggression — a model, not an insult.
  maniacModel,

  /// Versus maniacs: call wider for value; let them hang; no ego.
  vsManiacs,

  /// Versus TAGs: respect raises; steal less; no light rebluffs.
  vsTags,

  /// Versus LAGs: trap more; call wider; fancy less.
  vsLags,

  /// Observation ≠ certainty; confidence grows with samples/showdowns.
  observationCertainty,

  /// Same cards, different seats — exploits need evidence.
  exploitEvidence,

  /// Multiway: nutted up, air down; domination hurts more.
  multiwayNuts,

  /// Deep stacks: more room to realize — and to lose a stack.
  deepStacks,

  /// Implied odds: future money; reverse when second-best.
  impliedOdds,

  /// Thin value needs calls; bluff-catches need wide barrels.
  thinValue,

  /// Lines mean ranges: check-raise, probe, delay, donk.
  lineStories,

  /// Each action rewrites the range — keep updating.
  rangeRewrite,

  /// Timing and sizing are clues — small updates only.
  timingClues,

  /// Tables change — stuck, tilted, gears; keep updating.
  tablesChange,

  /// Winning includes knowing when to quit — guardrails first.
  guardrails,

  /// Range advantage vs nut advantage — strong hands overall vs the nuts.
  rangeAdvantage,

  /// Chart equity is not cash — position decides realization.
  equityRealize,

  /// Capped = nuts unlikely; uncapped = nuts still live.
  cappedUncapped,

  /// Polar = nuts or air; merged = many medium-strong hands.
  polarMerged,

  /// Overbets need a polar story; geometry links street sizes.
  overbetGeometry,

  /// Blockers remove hands — use them; do not invent EV decimals.
  blockers,

  /// Defend enough that over-bluffing fails — no fake percentages.
  defendEnough,

  /// Mixing is frequency with a purpose — not coin-flip theater.
  mixedStrategy,

  /// 3-bet/4-bet pots shrink ranges and SPR — depth decides commitment.
  threeBetFourBetSpr,

  /// Hard folds save buy-ins; coolers happen; ego call-downs are mistakes.
  hardFoldCooler,

  /// Selective aggression: tight entry, then barrels with a plan — count samples.
  selectiveAggression,

  /// TAG: tight in, aggressive after — a working model.
  tagModel,

  /// LAG: wide in, pressure on — a working model.
  lagModel,

  /// Wide sustained pressure: wide entry, planned barrels — count samples.
  widePressure,

  /// Enter with a reason; flop confirms or cancels the preflop plan.
  preflopFlopPlan,

  /// List continue and give-up turn cards before you bet the flop.
  turnMap,

  /// Compose river value, bluffs with blockers, and check trash without a story.
  riverComposition,

  /// Change plans by pot type: limped, SRP, and 3-/4-bet pots.
  potTypePlans,

  /// Switch gears: bluff less multiway, value thicker, widen selected HU bluffs.
  huVsMultiway,

  /// Rewrite plans by stack depth: short commit, deep implied, effective each hand.
  stackDepthPlans,

  /// Replay same holdings across five type models; cite tendency or keep baseline.
  sameCardsTypes,

  /// Integrate type, board texture, line history, and sizing into one action.
  typeBoardLine,

  /// Personal leak notes, written default book, and scheduled review habits.
  leakReviewBook,

  /// Capstone single-raised pot: plan, update streets, finish river.
  capstoneSrp,

  /// Capstone 3-bet pot: plan by SPR, continue or kill, close without ego.
  capstone3bet,

  /// Capstone multiway deep: nut potential, deep implied, no light bluffs.
  capstoneMultiwayDeep,

  /// Capstone limped pot: nut potential, value thick, thin river carefully.
  capstoneLimped,

  /// Capstone 4-bet pot: short SPR commit, no ego, fold hero calls.
  capstone4bet,

  /// Live warm-up prep: checklist, carry defaults, execute one hand.
  liveWarmupPrep,
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
      'Tap each highlighted card — only five of seven play.',
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
      'Tap each seat in preflop order.',
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
      'Tap Value, C-bet, Check, Call, Fold, and Raise.',
    CoachDialogueVisualKind.turnStory =>
      'Tap Brick, Change, Barrel, and Delay.',
    CoachDialogueVisualKind.riverBinary =>
      'Tap Value, Bluff, Catch, and Fold.',
    CoachDialogueVisualKind.multiwayPlan =>
      'Tap Stronger, Fewer, and Nuts.',
    CoachDialogueVisualKind.commonLeaks =>
      'Tap Top pair, Prices, Passive, and Crowds.',
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
    CoachDialogueVisualKind.playerObserve =>
      'Tap Enters, Calls, and Folds.',
    CoachDialogueVisualKind.callingStation =>
      'Tap Station, High, and Low.',
    CoachDialogueVisualKind.vsStation =>
      'Tap Value, Bluffs, and Cite.',
    CoachDialogueVisualKind.tightSeats =>
      'Tap Rare, Enter, and Mean It.',
    CoachDialogueVisualKind.nitModel =>
      'Tap Nit, Narrow, and Respect.',
    CoachDialogueVisualKind.vsNits =>
      'Tap Steal, Credit, and Explode.',
    CoachDialogueVisualKind.extremeEntry =>
      'Tap Raise, Barrel, and Count.',
    CoachDialogueVisualKind.maniacModel =>
      'Tap Maniac, Entry, and Aggro.',
    CoachDialogueVisualKind.vsManiacs =>
      'Tap Wider, Hang, and Ego.',
    CoachDialogueVisualKind.vsTags =>
      'Tap Credit, Tighter, and No light.',
    CoachDialogueVisualKind.vsLags =>
      'Tap Call, Trap, and Fancy less.',
    CoachDialogueVisualKind.observationCertainty =>
      'Tap Observe, Samples, and Showdowns.',
    CoachDialogueVisualKind.exploitEvidence =>
      'Tap Cards, Seats, and Evidence.',
    CoachDialogueVisualKind.multiwayNuts =>
      'Tap Nutted, Air, and Domination.',
    CoachDialogueVisualKind.deepStacks =>
      'Tap Deep, Realize, and Stack.',
    CoachDialogueVisualKind.impliedOdds =>
      'Tap Implied, Reverse, and Second.',
    CoachDialogueVisualKind.thinValue =>
      'Tap Thin, Catch, and Barrels.',
    CoachDialogueVisualKind.lineStories =>
      'Tap X/R, Probe, Delay, and Donk.',
    CoachDialogueVisualKind.rangeRewrite =>
      'Tap Action, Rewrite, and Update.',
    CoachDialogueVisualKind.timingClues =>
      'Tap Timing, Sizing, and Clues.',
    CoachDialogueVisualKind.tablesChange =>
      'Tap Stuck, Tilted, and Gears.',
    CoachDialogueVisualKind.guardrails =>
      'Tap Quit, Guard, and First.',
    CoachDialogueVisualKind.rangeAdvantage =>
      'Tap Range, Nut, and Advantage.',
    CoachDialogueVisualKind.equityRealize =>
      'Tap Equity, Cash, and Pos.',
    CoachDialogueVisualKind.cappedUncapped =>
      'Tap Capped, Uncapped, and Nuts.',
    CoachDialogueVisualKind.polarMerged =>
      'Tap Polar, Merged, and Size.',
    CoachDialogueVisualKind.overbetGeometry =>
      'Tap Overbet, Polar, and Geo.',
    CoachDialogueVisualKind.blockers =>
      'Tap Block, Use, and No EV.',
    CoachDialogueVisualKind.defendEnough =>
      'Tap Defend, Bluff, and Enough.',
    CoachDialogueVisualKind.mixedStrategy =>
      'Tap Mix, Purpose, and Strong.',
    CoachDialogueVisualKind.threeBetFourBetSpr =>
      'Tap 3-Bet, 4-Bet, and Depth.',
    CoachDialogueVisualKind.hardFoldCooler =>
      'Tap Hard, Cooler, and Ego.',
    CoachDialogueVisualKind.selectiveAggression =>
      'Tap Tight, Barrel, and Sample.',
    CoachDialogueVisualKind.tagModel =>
      'Tap Tight, Aggro, and Model.',
    CoachDialogueVisualKind.lagModel =>
      'Tap Wide, Pressure, and Model.',
    CoachDialogueVisualKind.widePressure =>
      'Tap Wide, Pressure, and Sample.',
    CoachDialogueVisualKind.preflopFlopPlan =>
      'Tap Reason, Confirm, and Cancel.',
    CoachDialogueVisualKind.turnMap =>
      'Tap Barrel, Give-up, and Map.',
    CoachDialogueVisualKind.riverComposition =>
      'Tap Value, Bluff, and Hold.',
    CoachDialogueVisualKind.potTypePlans =>
      'Tap Limped, SRP, and 3-4bet.',
    CoachDialogueVisualKind.huVsMultiway =>
      'Tap Fewer, Thicker, and Widen.',
    CoachDialogueVisualKind.stackDepthPlans =>
      'Tap Short, Deep, and Effective.',
    CoachDialogueVisualKind.sameCardsTypes =>
      'Tap Cards, Models, and Cite.',
    CoachDialogueVisualKind.typeBoardLine =>
      'Tap Type, Board, Line, and Size.',
    CoachDialogueVisualKind.leakReviewBook =>
      'Tap Leak, Book, and Review.',
    CoachDialogueVisualKind.capstoneSrp =>
      'Tap Plan, Update, and Finish.',
    CoachDialogueVisualKind.capstone3bet =>
      'Tap SPR, Turn, and Close.',
    CoachDialogueVisualKind.capstoneMultiwayDeep =>
      'Tap Nuts, Deep, and No-bluff.',
    CoachDialogueVisualKind.capstoneLimped =>
      'Tap Nuts, Value, and Thin.',
    CoachDialogueVisualKind.capstone4bet =>
      'Tap SPR, Commit, and No Hero.',
    CoachDialogueVisualKind.liveWarmupPrep =>
      'Tap Checklist, Defaults, and One hand.',
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
      kind == CoachDialogueVisualKind.sprDepth ||
      kind == CoachDialogueVisualKind.playerObserve ||
      kind == CoachDialogueVisualKind.callingStation ||
      kind == CoachDialogueVisualKind.vsStation ||
      kind == CoachDialogueVisualKind.tightSeats ||
      kind == CoachDialogueVisualKind.nitModel ||
      kind == CoachDialogueVisualKind.vsNits ||
      kind == CoachDialogueVisualKind.extremeEntry ||
      kind == CoachDialogueVisualKind.maniacModel ||
      kind == CoachDialogueVisualKind.vsManiacs ||
      kind == CoachDialogueVisualKind.vsTags ||
      kind == CoachDialogueVisualKind.vsLags ||
      kind == CoachDialogueVisualKind.observationCertainty ||
      kind == CoachDialogueVisualKind.exploitEvidence ||
      kind == CoachDialogueVisualKind.multiwayNuts ||
      kind == CoachDialogueVisualKind.deepStacks ||
      kind == CoachDialogueVisualKind.impliedOdds ||
      kind == CoachDialogueVisualKind.thinValue ||
      kind == CoachDialogueVisualKind.lineStories ||
      kind == CoachDialogueVisualKind.rangeRewrite ||
      kind == CoachDialogueVisualKind.timingClues ||
      kind == CoachDialogueVisualKind.tablesChange ||
      kind == CoachDialogueVisualKind.guardrails ||
      kind == CoachDialogueVisualKind.rangeAdvantage ||
      kind == CoachDialogueVisualKind.equityRealize ||
      kind == CoachDialogueVisualKind.cappedUncapped ||
      kind == CoachDialogueVisualKind.polarMerged ||
      kind == CoachDialogueVisualKind.overbetGeometry ||
      kind == CoachDialogueVisualKind.blockers ||
      kind == CoachDialogueVisualKind.defendEnough ||
      kind == CoachDialogueVisualKind.mixedStrategy ||
      kind == CoachDialogueVisualKind.threeBetFourBetSpr ||
      kind == CoachDialogueVisualKind.hardFoldCooler ||
      kind == CoachDialogueVisualKind.selectiveAggression ||
      kind == CoachDialogueVisualKind.tagModel ||
      kind == CoachDialogueVisualKind.lagModel ||
      kind == CoachDialogueVisualKind.widePressure ||
      kind == CoachDialogueVisualKind.preflopFlopPlan ||
      kind == CoachDialogueVisualKind.turnMap ||
      kind == CoachDialogueVisualKind.riverComposition ||
      kind == CoachDialogueVisualKind.potTypePlans ||
      kind == CoachDialogueVisualKind.huVsMultiway ||
      kind == CoachDialogueVisualKind.stackDepthPlans ||
      kind == CoachDialogueVisualKind.sameCardsTypes ||
      kind == CoachDialogueVisualKind.typeBoardLine ||
      kind == CoachDialogueVisualKind.leakReviewBook ||
      kind == CoachDialogueVisualKind.capstoneSrp ||
      kind == CoachDialogueVisualKind.capstone3bet ||
      kind == CoachDialogueVisualKind.capstoneMultiwayDeep ||
      kind == CoachDialogueVisualKind.capstoneLimped ||
      kind == CoachDialogueVisualKind.capstone4bet ||
      kind == CoachDialogueVisualKind.liveWarmupPrep;

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
    CoachDialogueVisualKind.playerObserve =>
      'Observe tiles: enters, calls, folds',
    CoachDialogueVisualKind.callingStation =>
      'Station tiles: model, high participation, low folding',
    CoachDialogueVisualKind.vsStation =>
      'Vs-station tiles: thicker value, fewer bluffs, cite calling',
    CoachDialogueVisualKind.tightSeats =>
      'Tight-seat tiles: rare, enter, mean it',
    CoachDialogueVisualKind.nitModel =>
      'Nit tiles: label, narrow entry, respect heavy action',
    CoachDialogueVisualKind.vsNits =>
      'Vs-nit tiles: steal more, give credit, when they explode',
    CoachDialogueVisualKind.extremeEntry =>
      'Extreme-entry tiles: raise, barrel, count',
    CoachDialogueVisualKind.maniacModel =>
      'Maniac tiles: label, extreme entry, aggression',
    CoachDialogueVisualKind.vsManiacs =>
      'Vs-maniac tiles: call wider, let them hang, no ego',
    CoachDialogueVisualKind.vsTags =>
      'Vs-TAG tiles: respect heat, steal less, no light XR',
    CoachDialogueVisualKind.vsLags =>
      'Vs-LAG tiles: trap more, call wider, fancy less',
    CoachDialogueVisualKind.observationCertainty =>
      'Certainty tiles: observe, samples, showdowns',
    CoachDialogueVisualKind.exploitEvidence =>
      'Exploit tiles: same cards, different seats, evidence',
    CoachDialogueVisualKind.multiwayNuts =>
      'Multiway-nuts tiles: nutted up, air down, domination',
    CoachDialogueVisualKind.deepStacks =>
      'Deep-stack tiles: depth, realize, lose a stack',
    CoachDialogueVisualKind.impliedOdds =>
      'Implied-odds tiles: implied, reverse, second-best',
    CoachDialogueVisualKind.thinValue =>
      'Thin-value tiles: thin value, bluff-catch, wide barrels',
    CoachDialogueVisualKind.lineStories =>
      'Line tiles: check-raise, probe, delay, donk',
    CoachDialogueVisualKind.rangeRewrite =>
      'Range-rewrite tiles: action, rewrite, keep updating',
    CoachDialogueVisualKind.timingClues =>
      'Timing-clues tiles: timing, sizing, clues — not mind-reading',
    CoachDialogueVisualKind.tablesChange =>
      'Tables-change tiles: stuck, tilted, shifting gears',
    CoachDialogueVisualKind.guardrails =>
      'Guardrails tiles: quit, guard, first',
    CoachDialogueVisualKind.rangeAdvantage =>
      'Range-advantage tiles: range, nut, advantage',
    CoachDialogueVisualKind.equityRealize =>
      'Equity-realize tiles: equity, cash, position',
    CoachDialogueVisualKind.cappedUncapped =>
      'Capped/uncapped tiles: capped, uncapped, nuts',
    CoachDialogueVisualKind.polarMerged =>
      'Polar/merged tiles: polar, merged, size',
    CoachDialogueVisualKind.overbetGeometry =>
      'Overbet/geometry tiles: overbet, polar, geo',
    CoachDialogueVisualKind.blockers =>
      'Blocker tiles: block, use, no EV',
    CoachDialogueVisualKind.defendEnough =>
      'Defend-enough tiles: defend, bluff, enough',
    CoachDialogueVisualKind.mixedStrategy =>
      'Mixed-strategy tiles: mix, purpose, strong',
    CoachDialogueVisualKind.threeBetFourBetSpr =>
      '3-bet/4-bet SPR tiles: 3-bet, 4-bet, depth',
    CoachDialogueVisualKind.hardFoldCooler =>
      'Hard-fold/cooler tiles: hard, cooler, ego',
    CoachDialogueVisualKind.selectiveAggression =>
      'Selective-aggression tiles: tight, barrel, sample',
    CoachDialogueVisualKind.tagModel =>
      'TAG tiles: tight, aggro, model',
    CoachDialogueVisualKind.lagModel =>
      'LAG tiles: wide, pressure, model',
    CoachDialogueVisualKind.widePressure =>
      'Wide-pressure tiles: wide entry, planned barrels, count samples',
    CoachDialogueVisualKind.preflopFlopPlan =>
      'Preflop-to-flop tiles: reason, confirm, cancel',
    CoachDialogueVisualKind.turnMap =>
      'Flop-to-turn map tiles: continue, give-up, map',
    CoachDialogueVisualKind.riverComposition =>
      'River composition tiles: value, bluff, check',
    CoachDialogueVisualKind.potTypePlans =>
      'Pot-type plan tiles: limped, SRP, 3-4bet',
    CoachDialogueVisualKind.huVsMultiway =>
      'HU vs multiway tiles: fewer bluffs, thicker value, widen HU',
    CoachDialogueVisualKind.stackDepthPlans =>
      'Stack-depth plan tiles: short commit, deep implied, effective',
    CoachDialogueVisualKind.sameCardsTypes =>
      'Same-cards tiles: same holdings, five models, cite tendency',
    CoachDialogueVisualKind.typeBoardLine =>
      'Type-board-line tiles: type, board, line, size — one action',
    CoachDialogueVisualKind.leakReviewBook =>
      'Leak-review tiles: specific leak, written book, scheduled review',
    CoachDialogueVisualKind.capstoneSrp =>
      'Capstone SRP tiles: plan, update streets, finish river',
    CoachDialogueVisualKind.capstone3bet =>
      'Capstone 3-bet tiles: plan by SPR, continue or kill, close river',
    CoachDialogueVisualKind.capstoneMultiwayDeep =>
      'Capstone multiway-deep tiles: nuts, deep implied, no light bluffs',
    CoachDialogueVisualKind.capstoneLimped =>
      'Capstone limped tiles: nuts, value thick, thin river carefully',
    CoachDialogueVisualKind.capstone4bet =>
      'Capstone 4-bet tiles: short SPR, commit, fold ego',
    CoachDialogueVisualKind.liveWarmupPrep =>
      'Live warm-up tiles: checklist, defaults, one hand',
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
    case 'act-04-06-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.playerObserve,
      );
    case 'act-04-06-02-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.callingStation,
      );
    case 'act-04-06-03-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.vsStation,
      );
    case 'act-04-07-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.tightSeats,
      );
    case 'act-04-07-02-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.nitModel,
      );
    case 'act-04-07-03-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.vsNits,
      );
    case 'act-04-08-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.extremeEntry,
      );
    case 'act-04-08-02-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.maniacModel,
      );
    case 'act-04-08-03-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.vsManiacs,
      );
    case 'act-04-09-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.observationCertainty,
      );
    case 'act-04-10-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.exploitEvidence,
      );
    case 'act-05-01-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.multiwayNuts,
      );
    case 'act-05-02-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.deepStacks,
      );
    case 'act-05-03-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.impliedOdds,
      );
    case 'act-05-04-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.thinValue,
      );
    case 'act-05-05-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.lineStories,
      );
    case 'act-05-06-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.rangeRewrite,
      );
    case 'act-05-07-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.timingClues,
      );
    case 'act-05-08-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.tablesChange,
      );
    case 'act-05-09-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.guardrails,
      );
    case 'act-06-01-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.rangeAdvantage,
      );
    case 'act-06-02-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.equityRealize,
      );
    case 'act-06-03-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.cappedUncapped,
      );
    case 'act-06-04-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.polarMerged,
      );
    case 'act-06-05-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.overbetGeometry,
      );
    case 'act-06-06-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.blockers,
      );
    case 'act-06-07-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.defendEnough,
      );
    case 'act-06-08-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.mixedStrategy,
      );
    case 'act-06-09-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.threeBetFourBetSpr,
      );
    case 'act-06-10-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.hardFoldCooler,
      );
    case 'act-06-11-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.selectiveAggression,
      );
    case 'act-06-11-02-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.tagModel,
      );
    case 'act-06-11-03-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.vsTags,
      );
    case 'act-06-12-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.widePressure,
      );
    case 'act-06-12-02-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.lagModel,
      );
    case 'act-06-12-03-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.vsLags,
      );
    case 'act-06-13-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.exploitEvidence,
      );
    case 'act-07-01-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.preflopFlopPlan,
      );
    case 'act-07-02-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.turnMap,
      );
    case 'act-07-03-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.riverComposition,
      );
    case 'act-07-04-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.potTypePlans,
      );
    case 'act-07-05-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.huVsMultiway,
      );
    case 'act-07-06-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.stackDepthPlans,
      );
    case 'act-07-07-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.sameCardsTypes,
      );
    case 'act-07-08-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.typeBoardLine,
      );
    case 'act-07-09-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.leakReviewBook,
      );
    case 'act-07-10-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.capstoneSrp,
      );
    case 'act-07-10-02-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.capstone3bet,
      );
    case 'act-07-10-03-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.capstoneMultiwayDeep,
      );
    case 'act-07-10-04-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.capstoneLimped,
      );
    case 'act-07-10-05-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.capstone4bet,
      );
    case 'act-07-11-01-explain':
      return const CoachDialogueVisual(
        kind: CoachDialogueVisualKind.liveWarmupPrep,
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
  // Phrase-safe river composition — value / bluff / check framing.
  // Must run before riverBinary (which also matches river+value+bluff+fold).
  if (blob.contains('value if they call worse') ||
      blob.contains('bluff if they fold better') ||
      blob.contains('compose river value') ||
      (blob.contains('river') &&
          blob.contains('value') &&
          blob.contains('bluff') &&
          (blob.contains('call worse') ||
              blob.contains('fold better') ||
              blob.contains('blockers') ||
              blob.contains('check trash'))) ||
      (blob.contains('value needs calls') && blob.contains('bluffs need folds'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.riverComposition,
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
  // HU-vs-multiway (S7) — require player-count / HU framing so we do not steal
  // vs-station "thicker value" copy.
  if ((blob.contains('thicker value') &&
          (blob.contains('more players') ||
              blob.contains('multiway') ||
              blob.contains('heads-up') ||
              blob.contains('player count'))) ||
      blob.contains('widen selected hu') ||
      blob.contains('widen selected heads-up') ||
      blob.contains('switch gears between hu') ||
      blob.contains('heads-up versus multiway') ||
      blob.contains('hu versus multiway') ||
      (blob.contains('fewer bluffs') &&
          blob.contains('thicker') &&
          (blob.contains('more players') || blob.contains('multiway'))) ||
      (blob.contains('player count') &&
          (blob.contains('first-class') || blob.contains('planning')))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.huVsMultiway,
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
  // Phrase-safe 3-bet/4-bet SPR — before bare "spr" / stack-to-pot.
  if (blob.contains('3-bet and 4-bet') ||
      blob.contains('depth decides commitment') ||
      (blob.contains('4-bet pots') && blob.contains('spr')) ||
      (blob.contains('shrink ranges') && blob.contains('spr'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.threeBetFourBetSpr,
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
  if (blob.contains('before labels') ||
      blob.contains('who enters pots') ||
      blob.contains('count samples') ||
      (blob.contains('who calls') && blob.contains('who folds'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.playerObserve,
    );
  }
  if (blob.contains('calling station') ||
      (blob.contains('working model') &&
          (blob.contains('station') || blob.contains('participation'))) ||
      (blob.contains('high participation') && blob.contains('low folding'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.callingStation,
    );
  }
  if (blob.contains('versus stations') ||
      blob.contains('thicker value') ||
      blob.contains('cite their calling') ||
      (blob.contains('fewer pure bluffs') && blob.contains('stations'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.vsStation,
    );
  }
  // Phrase-safe tight seats — require rare-entry framing, not bare "enter".
  if (blob.contains('almost never enter') ||
      blob.contains('when they do, they mean it') ||
      (blob.contains('almost never') && blob.contains('mean it')) ||
      (blob.contains('note both') && blob.contains('never enter'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.tightSeats,
    );
  }
  if (blob.contains('nit means') ||
      blob.contains('narrow entry') ||
      blob.contains('respect for their heavy') ||
      (blob.contains('nit') && blob.contains('heavy action'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.nitModel,
    );
  }
  // Phrase-safe vs nits — require versus/steal+explode framing, not bare "nit".
  if (blob.contains('versus nits') ||
      blob.contains('give credit when they explode') ||
      (blob.contains('steal blinds more') && blob.contains('nit')) ||
      (blob.contains('steal') &&
          blob.contains('explode') &&
          blob.contains('nit'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.vsNits,
    );
  }
  if (blob.contains('raise and barrel') ||
      blob.contains('seemingly forever') ||
      blob.contains('count it calmly') ||
      (blob.contains('barrel') && blob.contains('forever'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.extremeEntry,
    );
  }
  if (blob.contains('maniac means') ||
      blob.contains('not an insult') ||
      (blob.contains('maniac') && blob.contains('extreme entry')) ||
      (blob.contains('maniac') && blob.contains('aggression'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.maniacModel,
    );
  }
  // Phrase-safe vs maniacs — require versus/hang/ego framing, not bare "maniac".
  if (blob.contains('versus maniacs') ||
      blob.contains('let them hang themselves') ||
      (blob.contains('no ego') && blob.contains('maniac')) ||
      (blob.contains('call wider') && blob.contains('maniac'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.vsManiacs,
    );
  }
  if (blob.contains('observation') ||
      blob.contains('certainty') ||
      blob.contains('samples and showdowns') ||
      (blob.contains('confidence grows') && blob.contains('samples'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.observationCertainty,
    );
  }
  // Phrase-safe same-cards types — cite tendency across five models.
  // Before exploitEvidence so "Same cards. Five models. Cite the tendency."
  // is not stolen by the mix-five Cards/Seats/Evidence demo.
  if (blob.contains('cite the tendency') ||
      blob.contains('same cards. five models') ||
      blob.contains('change lines by type') ||
      blob.contains('recommendations diverge') ||
      (blob.contains('same cards') &&
          blob.contains('five models') &&
          blob.contains('cite'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.sameCardsTypes,
    );
  }
  // Phrase-safe type × board × line × size — one coherent action.
  if (blob.contains('type × board × line') ||
      blob.contains('type x board x line') ||
      blob.contains('one answer') && blob.contains('size') ||
      (blob.contains('type') &&
          blob.contains('board') &&
          blob.contains('line') &&
          blob.contains('size') &&
          blob.contains('one'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.typeBoardLine,
    );
  }
  // Capstone SRP — full-hand transfer without hints.
  if (blob.contains('capstone srp') ||
      (blob.contains('trust your map') && blob.contains('no hints')) ||
      (blob.contains('full srp') && blob.contains('plan'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.capstoneSrp,
    );
  }
  // Capstone 3-bet — plan by SPR, continue or kill, close without ego.
  if (blob.contains('capstone 3-bet') ||
      blob.contains('capstone 3bet') ||
      (blob.contains('3-bet') &&
          blob.contains('short prompts') &&
          blob.contains('no hints'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.capstone3bet,
    );
  }
  // Capstone multiway deep — nut potential, implied odds, no light bluffs.
  if (blob.contains('capstone multiway deep') ||
      (blob.contains('multiway deep') && blob.contains('no hints'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.capstoneMultiwayDeep,
    );
  }
  // Capstone limped — crowded pot, value thick, thin carefully.
  if (blob.contains('capstone limped') ||
      (blob.contains('limped pot') && blob.contains('no hints'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.capstoneLimped,
    );
  }
  // Capstone 4-bet — short SPR, commit, no hero calls.
  if (blob.contains('capstone 4-bet') ||
      blob.contains('capstone 4bet') ||
      (blob.contains('4-bet') &&
          blob.contains('short spr') &&
          blob.contains('no hints'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.capstone4bet,
    );
  }
  // Live warm-up prep — checklist then one coached hand.
  if (blob.contains('live warm-up') ||
      blob.contains('live warmup') ||
      (blob.contains('warm-up') && blob.contains('checklist'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.liveWarmupPrep,
    );
  }
  // Phrase-safe leak review / default book — before commonLeaks so "review leaks"
  // with "defaults" / "write the book" is not stolen by the common-leaks demo.
  if (blob.contains('defaults beat vibes') ||
      blob.contains('write the book') ||
      blob.contains('write your default') ||
      blob.contains('personal leak') ||
      (blob.contains('review leaks') &&
          (blob.contains('book') || blob.contains('default'))) ||
      (blob.contains('default') &&
          blob.contains('book') &&
          blob.contains('leak'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.leakReviewBook,
    );
  }
  if (blob.contains('same cards') ||
      blob.contains('different seats') ||
      blob.contains('exploits change') ||
      (blob.contains('only with evidence') && blob.contains('seats'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.exploitEvidence,
    );
  }
  if (blob.contains('nutted hands') ||
      blob.contains('air down') ||
      blob.contains('domination hurts') ||
      (blob.contains('nut potential') && blob.contains('multiway'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.multiwayNuts,
    );
  }
  if (blob.contains('more room to realize') ||
      blob.contains('lose a stack') ||
      blob.contains('speculative implied') ||
      (blob.contains('deep') && blob.contains('realize'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.deepStacks,
    );
  }
  // Phrase-safe implied odds — require implied/reverse framing, not bare "second-best".
  if (blob.contains('implied odds') ||
      blob.contains('reverse implied') ||
      blob.contains('future money') ||
      (blob.contains('implied') && blob.contains('second-best'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.impliedOdds,
    );
  }
  if (blob.contains('thin value') ||
      blob.contains('bluff-catches need') ||
      blob.contains('wide barrels') ||
      (blob.contains('sticky callers') && blob.contains('value'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.thinValue,
    );
  }
  if (blob.contains('lines mean ranges') ||
      blob.contains('check-raise, probe') ||
      blob.contains('updates the story') ||
      (blob.contains('donk') && blob.contains('probe') && blob.contains('delay'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.lineStories,
    );
  }
  if (blob.contains('rewrites the range') ||
      blob.contains('keep updating') ||
      blob.contains('after each street') ||
      (blob.contains('each action') && blob.contains('range'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.rangeRewrite,
    );
  }
  // Phrase-safe timing clues — never bare "timing" / "sizing" (sizing-language).
  if (blob.contains('timing and sizing') ||
      blob.contains('not mind-reading') ||
      blob.contains('small updates only')) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.timingClues,
    );
  }
  // Phrase-safe tables-change — avoid bare "update" / "tilted" alone.
  if (blob.contains('tables change') ||
      blob.contains('shifting gears') ||
      (blob.contains('stuck') && blob.contains('tilted') && blob.contains('tired'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.tablesChange,
    );
  }
  // Phrase-safe guardrails — quit / guardrails, not bare "winning".
  if (blob.contains('guardrails first') ||
      blob.contains('knowing when to quit') ||
      (blob.contains('guardrails') && blob.contains('quit')) ||
      (blob.contains('winning 1/2') && blob.contains('quit'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.guardrails,
    );
  }
  // Phrase-safe range/nut advantage — never bare "range" alone.
  if (blob.contains('range advantage') ||
      blob.contains('nut advantage') ||
      (blob.contains('strong hands overall') && blob.contains('nuts'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.rangeAdvantage,
    );
  }
  // Phrase-safe equity realize — chart equity vs cash / position.
  if (blob.contains('equity on a chart') ||
      blob.contains('not cash') ||
      (blob.contains('position decides') && blob.contains('realization')) ||
      (blob.contains('equity') && blob.contains('realization'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.equityRealize,
    );
  }
  // Phrase-safe mixed strategy — avoid bare "mix" / "frequency" alone.
  if (blob.contains('coin-flip theater') ||
      blob.contains('frequency with a purpose') ||
      (blob.contains('mix strong hands') && blob.contains('purpose'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.mixedStrategy,
    );
  }
  // Phrase-safe selective aggression — before bare "tight" / "barrel" alone.
  if (blob.contains('enters tight') ||
      blob.contains('barrels with a plan') ||
      blob.contains('count samples') ||
      blob.contains('selective aggression') ||
      (blob.contains('before labels') && blob.contains('count samples'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.selectiveAggression,
    );
  }
  // Phrase-safe TAG model — avoid bare "tag" / "tight" alone.
  if (blob.contains('tight in') ||
      blob.contains('aggressive after') ||
      blob.contains('introduce tag') ||
      (blob.contains('working model') &&
          (blob.contains('tag') || blob.contains('tight in'))) ||
      (blob.contains('tag:') && blob.contains('tight in'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.tagModel,
    );
  }
  // Phrase-safe vs TAG — require versus/respect/light framing.
  if (blob.contains('versus tag') ||
      blob.contains('versus tags') ||
      blob.contains('do not invent light bluff') ||
      (blob.contains('respect raises') && blob.contains('tag')) ||
      (blob.contains('light bluff') && blob.contains('tag'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.vsTags,
    );
  }
  // Phrase-safe wide pressure — before bare "wide" / "barrel" alone.
  if (blob.contains('wide entry plus pressure') ||
      blob.contains('pressure that still has a plan') ||
      blob.contains('wide sustained') ||
      (blob.contains('before labels') && blob.contains('wide entry')) ||
      (blob.contains('wide entry') && blob.contains('count samples'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.widePressure,
    );
  }
  // Phrase-safe LAG model — lag framing so we don't steal tagModel/widePressure.
  if (blob.contains('meet the lag') ||
      (blob.contains('wide in') && blob.contains('pressure on')) ||
      blob.contains('introduce lag') ||
      (blob.contains('working model') &&
          (blob.contains('lag') || blob.contains('wide in'))) ||
      (blob.contains('lag:') && blob.contains('wide in'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.lagModel,
    );
  }
  // Phrase-safe preflop→flop plan — reason / confirm / cancel framing.
  if (blob.contains('enter with a reason') ||
      blob.contains('flop confirms or cancels') ||
      blob.contains('confirms or cancels') ||
      (blob.contains('preflop') &&
          blob.contains('flop') &&
          (blob.contains('reason') || blob.contains('cancels'))) ||
      (blob.contains('carry a preflop') && blob.contains('flop'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.preflopFlopPlan,
    );
  }
  // Phrase-safe flop→turn map — continue / give-up / map framing.
  if (blob.contains('flop bet needs a turn map') ||
      blob.contains('continue or kill') ||
      blob.contains('map turn barrels') ||
      (blob.contains('turn map') &&
          (blob.contains('continue') || blob.contains('give-up') ||
              blob.contains('give up'))) ||
      (blob.contains('continue cards') && blob.contains('give-up'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.turnMap,
    );
  }
  // Phrase-safe pot-type plans — limped / SRP / 3-4bet framing.
  if (blob.contains('pot type sets ranges') ||
      blob.contains('plan accordingly') ||
      blob.contains('change plans by pot type') ||
      (blob.contains('pot type') &&
          (blob.contains('limped') ||
              blob.contains('spr') ||
              blob.contains('3-bet') ||
              blob.contains('4-bet'))) ||
      (blob.contains('limped') &&
          blob.contains('single-raised') &&
          (blob.contains('3-bet') || blob.contains('4-bet')))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.potTypePlans,
    );
  }
  // Phrase-safe stack-depth plans — short commit / deep implied / effective each hand.
  // Before deepStacks / impliedOdds so "effective stack rewrites" is not stolen.
  if (blob.contains('effective stack rewrites') ||
      blob.contains('rewrite plans when stacks') ||
      blob.contains('plans by stack depth') ||
      (blob.contains('effective stack') &&
          (blob.contains('rewrites the plan') ||
              blob.contains('every hand') ||
              blob.contains('recalculate'))) ||
      (blob.contains('short') &&
          blob.contains('commit') &&
          blob.contains('implied') &&
          blob.contains('deep'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.stackDepthPlans,
    );
  }
  // Phrase-safe vs LAG — require versus/trap/fancy framing.
  if (blob.contains('versus lag') ||
      blob.contains('versus lags') ||
      blob.contains('trap more, call wider') ||
      (blob.contains('trap more') && blob.contains('fancy less')) ||
      (blob.contains('call wider') && blob.contains('lag'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.vsLags,
    );
  }
  // Phrase-safe hard folds / coolers — avoid bare "cooler" / "ego" alone.
  if (blob.contains('hard folds save buy-ins') ||
      blob.contains('coolers happen') ||
      blob.contains('ego call-downs') ||
      (blob.contains('coolers') && blob.contains('ego call-downs')) ||
      (blob.contains('hard folds') && blob.contains('save buy-ins'))) {
    return const CoachDialogueVisual(
      kind: CoachDialogueVisualKind.hardFoldCooler,
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
    this.onPlayerObserveAcknowledge,
    this.onCallingStationAcknowledge,
    this.onVsStationAcknowledge,
    this.onTightSeatsAcknowledge,
    this.onNitModelAcknowledge,
    this.onVsNitsAcknowledge,
    this.onExtremeEntryAcknowledge,
    this.onManiacModelAcknowledge,
    this.onVsManiacsAcknowledge,
    this.onVsTagsAcknowledge,
    this.onVsLagsAcknowledge,
    this.onObservationCertaintyAcknowledge,
    this.onExploitEvidenceAcknowledge,
    this.onMultiwayNutsAcknowledge,
    this.onDeepStacksAcknowledge,
    this.onImpliedOddsAcknowledge,
    this.onThinValueAcknowledge,
    this.onLineStoriesAcknowledge,
    this.onRangeRewriteAcknowledge,
    this.onTimingCluesAcknowledge,
    this.onTablesChangeAcknowledge,
    this.onGuardrailsAcknowledge,
    this.onRangeAdvantageAcknowledge,
    this.onEquityRealizeAcknowledge,
    this.onCappedUncappedAcknowledge,
    this.onPolarMergedAcknowledge,
    this.onOverbetGeometryAcknowledge,
    this.onBlockersAcknowledge,
    this.onDefendEnoughAcknowledge,
    this.onMixedStrategyAcknowledge,
    this.onThreeBetFourBetSprAcknowledge,
    this.onHardFoldCoolerAcknowledge,
    this.onSelectiveAggressionAcknowledge,
    this.onTagModelAcknowledge,
    this.onLagModelAcknowledge,
    this.onWidePressureAcknowledge,
    this.onPreflopFlopPlanAcknowledge,
    this.onTurnMapAcknowledge,
    this.onRiverCompositionAcknowledge,
    this.onPotTypePlansAcknowledge,
    this.onHuVsMultiwayAcknowledge,
    this.onStackDepthPlansAcknowledge,
    this.onSameCardsTypesAcknowledge,
    this.onTypeBoardLineAcknowledge,
    this.onLeakReviewBookAcknowledge,
    this.onCapstoneSrpAcknowledge,
    this.onCapstone3betAcknowledge,
    this.onCapstoneMultiwayDeepAcknowledge,
    this.onCapstoneLimpedAcknowledge,
    this.onCapstone4betAcknowledge,
    this.onLiveWarmupPrepAcknowledge,
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
  final VoidCallback? onPlayerObserveAcknowledge;
  final VoidCallback? onCallingStationAcknowledge;
  final VoidCallback? onVsStationAcknowledge;
  final VoidCallback? onTightSeatsAcknowledge;
  final VoidCallback? onNitModelAcknowledge;
  final VoidCallback? onVsNitsAcknowledge;
  final VoidCallback? onExtremeEntryAcknowledge;
  final VoidCallback? onManiacModelAcknowledge;
  final VoidCallback? onVsManiacsAcknowledge;
  final VoidCallback? onVsTagsAcknowledge;
  final VoidCallback? onVsLagsAcknowledge;
  final VoidCallback? onObservationCertaintyAcknowledge;
  final VoidCallback? onExploitEvidenceAcknowledge;
  final VoidCallback? onMultiwayNutsAcknowledge;
  final VoidCallback? onDeepStacksAcknowledge;
  final VoidCallback? onImpliedOddsAcknowledge;
  final VoidCallback? onThinValueAcknowledge;
  final VoidCallback? onLineStoriesAcknowledge;
  final VoidCallback? onRangeRewriteAcknowledge;
  final VoidCallback? onTimingCluesAcknowledge;
  final VoidCallback? onTablesChangeAcknowledge;
  final VoidCallback? onGuardrailsAcknowledge;
  final VoidCallback? onRangeAdvantageAcknowledge;
  final VoidCallback? onEquityRealizeAcknowledge;
  final VoidCallback? onCappedUncappedAcknowledge;
  final VoidCallback? onPolarMergedAcknowledge;
  final VoidCallback? onOverbetGeometryAcknowledge;
  final VoidCallback? onBlockersAcknowledge;
  final VoidCallback? onDefendEnoughAcknowledge;
  final VoidCallback? onMixedStrategyAcknowledge;
  final VoidCallback? onThreeBetFourBetSprAcknowledge;
  final VoidCallback? onHardFoldCoolerAcknowledge;
  final VoidCallback? onSelectiveAggressionAcknowledge;
  final VoidCallback? onTagModelAcknowledge;
  final VoidCallback? onLagModelAcknowledge;
  final VoidCallback? onWidePressureAcknowledge;
  final VoidCallback? onPreflopFlopPlanAcknowledge;
  final VoidCallback? onTurnMapAcknowledge;
  final VoidCallback? onRiverCompositionAcknowledge;
  final VoidCallback? onPotTypePlansAcknowledge;
  final VoidCallback? onHuVsMultiwayAcknowledge;
  final VoidCallback? onStackDepthPlansAcknowledge;
  final VoidCallback? onSameCardsTypesAcknowledge;
  final VoidCallback? onTypeBoardLineAcknowledge;
  final VoidCallback? onLeakReviewBookAcknowledge;
  final VoidCallback? onCapstoneSrpAcknowledge;
  final VoidCallback? onCapstone3betAcknowledge;
  final VoidCallback? onCapstoneMultiwayDeepAcknowledge;
  final VoidCallback? onCapstoneLimpedAcknowledge;
  final VoidCallback? onCapstone4betAcknowledge;
  final VoidCallback? onLiveWarmupPrepAcknowledge;

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
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllActionsTapped: onPassiveAcknowledge,
        ),
        CoachDialogueVisualKind.aggressiveActions => AggressiveActionsDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
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
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onOpenRangeAcknowledge,
        ),
        CoachDialogueVisualKind.vsOpenResponse => VsOpenResponseDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllResponsesTapped: onVsOpenAcknowledge,
        ),
        CoachDialogueVisualKind.bbStackDepth => BbStackDepthDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onBbStackAcknowledge,
        ),
        CoachDialogueVisualKind.tableHabits => TableHabitsDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllHabitsTapped: onTableHabitsAcknowledge,
        ),
        CoachDialogueVisualKind.fullRing => FullRingDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onFullRingAcknowledge,
        ),
        CoachDialogueVisualKind.tableRead => TableReadDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onTableReadAcknowledge,
        ),
        CoachDialogueVisualKind.flopLabel => FlopLabelDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllLabelsTapped: onFlopLabelAcknowledge,
        ),
        CoachDialogueVisualKind.outsPrice => OutsPriceDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onOutsPriceAcknowledge,
        ),
        CoachDialogueVisualKind.flopLines => FlopLinesDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllLinesTapped: onFlopLinesAcknowledge,
        ),
        CoachDialogueVisualKind.turnStory => TurnStoryDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onTurnStoryAcknowledge,
        ),
        CoachDialogueVisualKind.riverBinary => RiverBinaryDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
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
        CoachDialogueVisualKind.playerObserve => PlayerObserveDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onPlayerObserveAcknowledge,
        ),
        CoachDialogueVisualKind.callingStation => CallingStationDemo(
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onCallingStationAcknowledge,
        ),
        CoachDialogueVisualKind.vsStation => VsStationDemo(
          interactive: onVsStationAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onVsStationAcknowledge,
        ),
        CoachDialogueVisualKind.tightSeats => TightSeatsDemo(
          interactive: onTightSeatsAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onTightSeatsAcknowledge,
        ),
        CoachDialogueVisualKind.nitModel => NitModelDemo(
          interactive: onNitModelAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onNitModelAcknowledge,
        ),
        CoachDialogueVisualKind.vsNits => VsNitsDemo(
          interactive: onVsNitsAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onVsNitsAcknowledge,
        ),
        CoachDialogueVisualKind.extremeEntry => ExtremeEntryDemo(
          interactive: onExtremeEntryAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onExtremeEntryAcknowledge,
        ),
        CoachDialogueVisualKind.maniacModel => ManiacModelDemo(
          interactive: onManiacModelAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onManiacModelAcknowledge,
        ),
        CoachDialogueVisualKind.vsManiacs => VsManiacsDemo(
          interactive: onVsManiacsAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onVsManiacsAcknowledge,
        ),
        CoachDialogueVisualKind.vsTags => VsTagsDemo(
          interactive: onVsTagsAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onVsTagsAcknowledge,
        ),
        CoachDialogueVisualKind.vsLags => VsLagsDemo(
          interactive: onVsLagsAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onVsLagsAcknowledge,
        ),
        CoachDialogueVisualKind.observationCertainty =>
          ObservationCertaintyDemo(
            interactive: onObservationCertaintyAcknowledge != null,
            enabled: enabled,
            onAllPointsTapped: onObservationCertaintyAcknowledge,
          ),
        CoachDialogueVisualKind.exploitEvidence => ExploitEvidenceDemo(
          interactive: onExploitEvidenceAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onExploitEvidenceAcknowledge,
        ),
        CoachDialogueVisualKind.multiwayNuts => MultiwayNutsDemo(
          interactive: onMultiwayNutsAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onMultiwayNutsAcknowledge,
        ),
        CoachDialogueVisualKind.deepStacks => DeepStacksDemo(
          interactive: onDeepStacksAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onDeepStacksAcknowledge,
        ),
        CoachDialogueVisualKind.impliedOdds => ImpliedOddsDemo(
          interactive: onImpliedOddsAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onImpliedOddsAcknowledge,
        ),
        CoachDialogueVisualKind.thinValue => ThinValueDemo(
          interactive: onThinValueAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onThinValueAcknowledge,
        ),
        CoachDialogueVisualKind.lineStories => LineStoriesDemo(
          interactive: onLineStoriesAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onLineStoriesAcknowledge,
        ),
        CoachDialogueVisualKind.rangeRewrite => RangeRewriteDemo(
          interactive: onRangeRewriteAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onRangeRewriteAcknowledge,
        ),
        CoachDialogueVisualKind.timingClues => TimingCluesDemo(
          interactive: onTimingCluesAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onTimingCluesAcknowledge,
        ),
        CoachDialogueVisualKind.tablesChange => TablesChangeDemo(
          interactive: onTablesChangeAcknowledge != null,
          enabled: enabled,
          onAllPointsTapped: onTablesChangeAcknowledge,
        ),
        CoachDialogueVisualKind.guardrails => GuardrailsDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onGuardrailsAcknowledge,
        ),
        CoachDialogueVisualKind.rangeAdvantage => RangeAdvantageDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onRangeAdvantageAcknowledge,
        ),
        CoachDialogueVisualKind.equityRealize => EquityRealizeDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onEquityRealizeAcknowledge,
        ),
        CoachDialogueVisualKind.cappedUncapped => CappedUncappedDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onCappedUncappedAcknowledge,
        ),
        CoachDialogueVisualKind.polarMerged => PolarMergedDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onPolarMergedAcknowledge,
        ),
        CoachDialogueVisualKind.overbetGeometry => OverbetGeometryDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onOverbetGeometryAcknowledge,
        ),
        CoachDialogueVisualKind.blockers => BlockersDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onBlockersAcknowledge,
        ),
        CoachDialogueVisualKind.defendEnough => DefendEnoughDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onDefendEnoughAcknowledge,
        ),
        CoachDialogueVisualKind.mixedStrategy => MixedStrategyDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onMixedStrategyAcknowledge,
        ),
        CoachDialogueVisualKind.threeBetFourBetSpr => ThreeBetFourBetSprDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onThreeBetFourBetSprAcknowledge,
        ),
        CoachDialogueVisualKind.hardFoldCooler => HardFoldCoolerDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onHardFoldCoolerAcknowledge,
        ),
        CoachDialogueVisualKind.selectiveAggression => SelectiveAggressionDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onSelectiveAggressionAcknowledge,
        ),
        CoachDialogueVisualKind.tagModel => TagModelDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onTagModelAcknowledge,
        ),
        CoachDialogueVisualKind.lagModel => LagModelDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onLagModelAcknowledge,
        ),
        CoachDialogueVisualKind.widePressure => WidePressureDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onWidePressureAcknowledge,
        ),
        CoachDialogueVisualKind.preflopFlopPlan => PreflopFlopPlanDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onPreflopFlopPlanAcknowledge,
        ),
        CoachDialogueVisualKind.turnMap => TurnMapDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onTurnMapAcknowledge,
        ),
        CoachDialogueVisualKind.riverComposition => RiverCompositionDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onRiverCompositionAcknowledge,
        ),
        CoachDialogueVisualKind.potTypePlans => PotTypePlansDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onPotTypePlansAcknowledge,
        ),
        CoachDialogueVisualKind.huVsMultiway => HuVsMultiwayDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onHuVsMultiwayAcknowledge,
        ),
        CoachDialogueVisualKind.stackDepthPlans => StackDepthPlansDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onStackDepthPlansAcknowledge,
        ),
        CoachDialogueVisualKind.sameCardsTypes => SameCardsTypesDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onSameCardsTypesAcknowledge,
        ),
        CoachDialogueVisualKind.typeBoardLine => TypeBoardLineDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onTypeBoardLineAcknowledge,
        ),
        CoachDialogueVisualKind.leakReviewBook => LeakReviewBookDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onLeakReviewBookAcknowledge,
        ),
        CoachDialogueVisualKind.capstoneSrp => CapstoneSrpDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onCapstoneSrpAcknowledge,
        ),
        CoachDialogueVisualKind.capstone3bet => Capstone3betDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onCapstone3betAcknowledge,
        ),
        CoachDialogueVisualKind.capstoneMultiwayDeep =>
          CapstoneMultiwayDeepDemo(
            // Stay interactive (densified) through Continue — lock only clears
            // the ack callback / enabled, not the teach shell.
            interactive: true,
            enabled: enabled,
            onAllPointsTapped: onCapstoneMultiwayDeepAcknowledge,
          ),
        CoachDialogueVisualKind.capstoneLimped => CapstoneLimpedDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onCapstoneLimpedAcknowledge,
        ),
        CoachDialogueVisualKind.capstone4bet => Capstone4betDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onCapstone4betAcknowledge,
        ),
        CoachDialogueVisualKind.liveWarmupPrep => LiveWarmupPrepDemo(
          // Stay interactive (densified) through Continue — lock only clears
          // the ack callback / enabled, not the teach shell.
          interactive: true,
          enabled: enabled,
          onAllPointsTapped: onLiveWarmupPrepAcknowledge,
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

class _SuitsRanksDemoState extends State<_SuitsRanksDemo>
    with SingleTickerProviderStateMixin {
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
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _onSuitTap(LessonSuitToken token) {
    if (!widget.enabled || widget.onAllSuitsTapped == null) return;
    setState(() => _tapped.add(token));
    if (_tapped.length >= _suits.length) {
      _pulse.stop();
      widget.onAllSuitsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _suits.length - _tapped.length;
    final ranksReady = remaining <= 0;
    LessonSuitToken? nextSuit;
    for (final token in _suits) {
      if (!_tapped.contains(token)) {
        nextSuit = token;
        break;
      }
    }
    final minFelt =
        widget.interactive && widget.enabled && remaining > 0
            ? MediaQuery.sizeOf(context).height * 0.38
            : null;
    return ConstrainedBox(
      constraints:
          minFelt != null
              ? BoxConstraints(minHeight: minFelt)
              : const BoxConstraints(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        alignment: minFelt != null ? Alignment.center : null,
        decoration: BoxDecoration(
          color: AppColors.feltLight.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.feltBorder.withValues(alpha: 0.55),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.interactive) ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  for (final token in _suits)
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        // Pulse only the next untapped suit — teach-by-doing
                        // order, not a bulk glow on every remaining tile.
                        final needsPulse =
                            widget.enabled &&
                            nextSuit == token &&
                            remaining > 0;
                        final glow =
                            needsPulse ? 0.45 + (_pulse.value * 0.55) : 0.0;
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:
                                glow > 0
                                    ? [
                                      BoxShadow(
                                        color: AppColors.gold.withValues(
                                          alpha: 0.34 * glow,
                                        ),
                                        blurRadius: 12 + (8 * _pulse.value),
                                        spreadRadius: 1 + (2 * _pulse.value),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: child,
                        );
                      },
                      child: SuitTapTile(
                        token: token,
                        selected: _tapped.contains(token),
                        enabled: widget.enabled,
                        onPressed: () => _onSuitTap(token),
                      ),
                    ),
                ],
              ),
              if (widget.enabled && remaining > 0 && nextSuit != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Tap ${nextSuit.label}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_tapped.length} of ${_suits.length} suits',
                  style: GoogleFonts.manrope(
                    color: AppColors.goldMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ] else
              const SuitGlyphRow(tokens: _suits, glyphSize: 34),
            const SizedBox(height: 14),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: widget.interactive && !ranksReady ? 0.42 : 1,
              child: Column(
                children: [
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
                            color: AppColors.cream.withValues(
                              alpha:
                                  widget.interactive && !ranksReady ? 0.55 : 1,
                            ),
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
            ),
          ],
        ),
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
