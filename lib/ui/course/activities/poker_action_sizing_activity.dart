/// Fold/check/call/bet/raise sizing choice activity.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

/// Action + sizing choices styled like the live action dock.
class PokerActionSizingActivity extends StatelessWidget {
  /// Creates the activity.
  const PokerActionSizingActivity({
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
    final spot = resolveLessonActionSpot(activity);
    final tableMode = isLessonActionTableActivity(activity) && spot != null;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final selected = controller.draft.choiceId;
        final locked = controller.submitting || controller.lastResult != null;
        final feltFirstCoach = _feltFirstCoach(activity, spot);
        final fallback =
            feltFirstCoach ??
            (activity.id == 'act-01-06-01-unguided-lab'
                ? 'Big blind vs a button open — tap Fold, Call, or Jam.'
                : spot?.identifyUnavailable == true
                ? 'A bet is out — tap the action you cannot take.'
                : spot?.stackLabel != null
                ? 'Short stack — tap what you can put in.'
                : spot?.openPot == true
                ? 'The pot is open — tap the first chips.'
                : spot?.facingBet == true
                ? 'Read the pot and the bet — tap your action.'
                : spot != null
                ? 'Nothing to match — tap the free action.'
                : 'Choose the action you would take live.');
        // Felt already shows holes / villain line — never dump "72o" prompts.
        final resolved =
            tableMode
                ? (coach: fallback, showPrompt: false)
                : resolveLessonCoachPrompt(
                  activity: activity,
                  fallback: fallback,
                );
        final coach = resolved.coach;
        final showPrompt = resolved.showPrompt;
        final showCoach =
            !locked &&
            shouldShowLessonCoach(
              activity: activity,
              showGuidance: showGuidance,
              coach: coach,
            );

        if (tableMode) {
          final pulseTarget = _guidedPulseTargetId(activity);
          final pulseChoiceId =
              showGuidance && !locked && selected == null
                  ? pulseTarget
                  : null;
          // SoftPulse + Rex own the cue — keep felt gold status hidden under
          // Nice! too (locked drops showCoach / SoftPulse, not ownership).
          final coachOwnsCue = showGuidance && pulseTarget != null;
          final dock = LessonActionDock(
            choices: activity.choices,
            selectedId: selected,
            enabled: !locked,
            identifyUnavailable: spot.identifyUnavailable,
            facingBet: spot.facingBet,
            heroStackAmount: spot.heroStackAmount,
            pulseChoiceId: pulseChoiceId,
            onSelect: (id) => controller.selectChoice(id, autoSubmit: true),
          );
          final status = Builder(
            builder: (context) {
              final text = () {
                if (controller.lastResult != null) return '';
                if (controller.submitting) return 'Checking…';
                if (selected == null) {
                  // Rex already cues the dock — no third "tap…" line.
                  if (showCoach) return '';
                  // Felt + Rex already name open pots — avoid a third
                  // "tap Bet" line under the dock.
                  return spot.identifyUnavailable
                      ? 'Tap the illegal action.'
                      : spot.stackLabel != null
                      ? 'Tap All-in, Call, or Fold on the dock.'
                      : 'Tap your action on the dock.';
                }
                return 'Checking…';
              }();
              if (text.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          );
          // Expanded table fills Rex→dock when the runner gives a bounded
          // height; widget tests (scroll wrap) keep a fixed-height felt.
          return LayoutBuilder(
            builder: (context, constraints) {
              final fill =
                  constraints.hasBoundedHeight &&
                  constraints.maxHeight.isFinite;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (showCoach) RexCoachLine(text: coach),
                  if (showPrompt) ...[
                    const SizedBox(height: 12),
                    Text(
                      activity.prompt!,
                      style: GoogleFonts.manrope(
                        color: AppColors.cream,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (fill)
                    Expanded(
                      child: LessonActionTable(
                        spot: spot,
                        coachOwnsCue: coachOwnsCue,
                      ),
                    )
                  else
                    LessonActionTable(
                      spot: spot,
                      coachOwnsCue: coachOwnsCue,
                    ),
                  const SizedBox(height: 10),
                  dock,
                  status,
                ],
              );
            },
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showCoach) RexCoachLine(text: coach),
            if (showPrompt) ...[
              const SizedBox(height: 12),
              Text(
                activity.prompt!,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final choice in activity.choices)
                  _ActionPill(
                    label: choice.label,
                    accessibilityText:
                        choice.accessibilityText ??
                        [
                          if (choice.action != null) choice.action!,
                          choice.label,
                        ].join(' '),
                    selected: selected == choice.id,
                    enabled: !locked,
                    onPressed: () =>
                        controller.selectChoice(choice.id, autoSubmit: true),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Builder(
              builder: (context) {
                final status = () {
                  if (controller.lastResult != null) return '';
                  if (controller.submitting) return 'Checking…';
                  if (selected == null) return 'Tap your action.';
                  return 'Checking…';
                }();
                if (status.isEmpty) return const SizedBox.shrink();
                return Text(
                  status,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Soft-pulse dock target for guided / scaffolded teach spots (ignores lock).
String? _guidedPulseTargetId(CourseActivity activity) {
  if (activity.stage != ActivityStage.guided &&
      activity.stage != ActivityStage.scaffolded &&
      activity.stage != ActivityStage.checkpoint &&
      activity.stage != ActivityStage.jumpTest) {
    return null;
  }
  return switch (activity.id) {
    'act-01-03-01-guided-fold' => 'fold-72',
    'act-01-03-01-scaffolded-check' => 'check-free',
    'act-01-03-02-guided-bet' => 'bet-half',
    'act-01-03-02-scaffolded-raise' => 'raise-15',
    'act-02-03-01-guided-utg' => 'fold',
    'act-02-04-01-guided-fold' => 'fold-j3',
    'act-02-04-01-scaffolded-call' => 'call-87s',
    'act-02-07-01-guided-ep' => 'open-ajs',
    'act-02-07-01-scaffolded-vs' => 'call-22',
    'act-03-04-01-guided' => 'bet-tp',
    'act-03-04-01-scaffolded' => 'cbet',
    'act-03-05-01-scaffolded' => 'barrel',
    'act-03-06-01-guided' => 'val-bet',
    'act-03-06-01-scaffolded' => 'bluff',
    'act-03-07-01-guided' => 'check-2p',
    'act-03-07-01-scaffolded' => 'mw-check',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-03-08-01-guided' => 'careful',
    'act-03-08-01-scaffolded' => 'fold-gut',
    // SoftPulse owns Fold / value on S3 jump docks.
    'act-03-08-02-jump-mw' => 'j3-fold',
    'act-03-08-02-jump-river' => 'j3-val',
    'act-04-02-01-guided' => '3bet-qq',
    'act-04-02-01-scaffolded' => 'fold-72',
    // SoftPulse owns 3-bet to 18 size pick.
    'act-04-02-01-checkpoint' => 'size-18',
    'act-04-03-01-scaffolded' => 'abort',
    // SoftPulse owns value / pressure / worst-size docks.
    'act-04-04-01-guided' => 'half',
    'act-04-04-01-scaffolded' => 'big',
    'act-04-04-01-checkpoint' => 'bad-1',
    // SoftPulse owns Commit / Weigh SPR docks.
    'act-04-05-01-scaffolded' => 'commit',
    'act-04-05-01-checkpoint' => 'before',
    // Adjust vs Station: SoftPulse the plan; Rex names the model, not the dock.
    'act-04-06-03-guided' => 'thin-val',
    'act-04-06-03-scaffolded' => 'give-up',
    // Adjust vs Nit: SoftPulse the plan; Rex names the model, not the dock.
    'act-04-07-03-guided' => 'steal',
    'act-04-07-03-scaffolded' => 'fold-mid',
    // Adjust vs Maniac: SoftPulse the plan; Rex names the model, not the dock.
    'act-04-08-03-guided' => 'call-wider',
    'act-04-08-03-scaffolded' => 'val-m',
    // Same hand × type: SoftPulse the plan; Rex names the model, not the dock.
    'act-04-10-01-guided' => 'st-val',
    'act-04-10-01-scaffolded' => 'nit-fold',
    'act-04-10-01-unguided' => 'm-call',
    // SoftPulse owns Fold on multiway speculative SB.
    'act-05-01-01-scaffolded' => 'fold-76',
    // SoftPulse owns Fold on deep TPWK vs heat.
    'act-05-02-01-scaffolded' => 'fold-tp',
    // SoftPulse owns Call / Fold on implied / reverse-implied docks.
    'act-05-03-01-guided' => 'call-io',
    'act-05-03-01-scaffolded' => 'rio',
    // Thin value / bluff-catch: SoftPulse the plan; Rex names the model.
    'act-05-04-01-guided' => 'tv',
    'act-05-04-01-scaffolded' => 'call-m',
    // SoftPulse owns Probe small when PFR checks.
    'act-05-05-01-scaffolded' => 'probe',
    // SoftPulse owns Fold when draw faces a bomb.
    'act-05-06-01-scaffolded' => 'repr',
    // S5 exit checkpoint docks — SoftPulse owns the answer.
    'act-05-09-02-cp-value' => 'bet',
    'act-05-09-02-cp-catch' => 'call',
    // Capped ranges scaffold — SoftPulse owns thin stab.
    'act-06-03-01-scaffolded' => 'bet',
    // Polar/merged scaffold — SoftPulse owns medium value size.
    'act-06-04-01-scaffolded' => 'mid',
    // Overbets geometric scaffold — SoftPulse owns pot-ish turn size.
    'act-06-05-01-scaffolded' => 'mid',
    // Min-defense scaffold — SoftPulse owns Fold trash.
    'act-06-07-01-scaffolded' => 'fold',
    // Mix guided — SoftPulse owns Check to protect checking range.
    'act-06-08-01-guided' => 'protect',
    // Hard folds guided — SoftPulse owns Fold TPWK.
    'act-06-10-01-guided' => 'fold',
    'act-06-09-01-scaffolded' => 'small',
    // Adjust vs TAG: SoftPulse the plan; Rex names the model, not the dock.
    'act-06-11-03-guided' => 'fold',
    'act-06-11-03-scaffolded' => 'fold-k9',
    // Adjust vs LAG: SoftPulse the plan; Rex names the model, not the dock.
    'act-06-12-03-guided' => 'call',
    'act-06-12-03-scaffolded' => 'trap',
    // Mix-five: SoftPulse the plan; Rex names the model, not the dock label.
    'act-06-13-01-guided' => 'cs',
    'act-06-13-01-scaffolded' => 'nit',
    // River composition guided — SoftPulse owns Value bet.
    'act-07-03-01-guided' => 'val',
    // Same cards × type: SoftPulse the plan; Rex names the model, not the dock.
    'act-07-07-01-guided' => 'bet',
    'act-07-07-01-scaffolded' => 'fold',
    // Type × board × line: SoftPulse the plan; Rex names the spot, not the dock.
    'act-07-08-01-guided' => 'call',
    'act-07-08-01-scaffolded' => 'raise',
    // S4 jump docks — SoftPulse owns the answer.
    'act-04-10-02-jump-3bet' => 'j4-3bet',
    'act-04-10-02-jump-size' => 'j4-10',
    _ => null,
  };
}

/// Felt-first Rex lines for action spots (felt already shows cards/context).
String? _feltFirstCoach(CourseActivity activity, LessonActionSpot? _) {
  return switch (activity.id) {
    'act-01-03-01-guided-fold' => 'Worst hand vs a raise — pick how you leave.',
    'act-01-03-01-scaffolded-check' => 'Nothing faces you — pick the free action.',
    'act-01-03-01-unguided-call' => 'A bet is out — pick how you continue.',
    'act-01-03-01-checkpoint-legal' =>
      'A bet is out — pick the illegal action.',
    'act-01-03-02-guided-bet' => 'The pot is open — pick a value size.',
    'act-01-03-02-scaffolded-raise' => 'They bet — pick how you charge.',
    'act-01-03-02-unguided-allin' => 'Short vs a big bet — pick what you can put in.',
    'act-01-03-02-checkpoint-names' => 'The pot is open — pick the first chips.',
    // SoftPulse owns Open to 6 — don’t gold-tip the dock.
    'act-02-07-01-guided-ep' =>
      'Suited broadway UTG — open for value first in.',
    // SoftPulse owns Call — don’t gold-tip the dock.
    'act-02-07-01-scaffolded-vs' =>
      'Pair on the button vs a small open — continue in position.',
    // Unguided: name the spot; list legal lines without SoftPulse.
    'act-02-07-01-unguided-lab' =>
      'CO open faces you on the button — pick Fold, Call, or 3-bet.',
    // Jump: name the seat, not the answer.
    'act-02-07-02-jump-open' =>
      'UTG first in — pick Fold or Open.',
    'act-02-03-01-guided-utg' =>
      'Trash UTG — pick how you leave.',
    'act-02-03-01-scaffolded-qq' =>
      'Premium pair UTG — pick a live open size.',
    'act-02-03-01-unguided-btn' =>
      'Folds to you on the button — pick Fold, Open, or Limp.',
    'act-02-03-01-checkpoint-hj' =>
      'Hijack first in — pick your action.',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-02-04-01-guided-fold' =>
      'Junk in the big blind vs an open — leave without defending.',
    // SoftPulse owns Call — don’t gold-tip the dock.
    'act-02-04-01-scaffolded-call' =>
      'Suited connector on the button vs a CO open — continue in position.',
    // Unguided: name the spot; list legal lines without SoftPulse.
    'act-02-04-01-unguided-3bet' =>
      'Premium pair in the small blind vs a button open — pick Fold, Call, or 3-bet.',
    // Checkpoint: name the hand class; SoftPulse isn’t on.
    'act-02-04-01-checkpoint-aq' =>
      'Strong suited broadway in the CO — pick your line.',
    'act-02-07-02-jump-vs' =>
      // Jump: seat + facing line — cards already show AA (no “Aces” tip).
      'Big blind vs an open — pick your action.',
    // SoftPulse owns value bet — don’t gold-tip the dock.
    'act-03-04-01-guided' =>
      'Top pair top kicker checked to you — extract when they check.',
    // SoftPulse owns small c-bet — don’t gold-tip the dock.
    'act-03-04-01-scaffolded' =>
      'You opened; dry ace flops — keep pressure small as PFR.',
    // Unguided: name the spot; list legal lines without SoftPulse.
    'act-03-04-01-unguided' =>
      'Set multiway vs a bet — pick Raise, Call, or Fold.',
    // Checkpoint: name the spot; SoftPulse isn’t on.
    'act-03-04-01-checkpoint' =>
      'Bottom pair vs bet and raise multiway — pick your line.',
    // SoftPulse owns barrel — don’t gold-tip the dock.
    'act-03-05-01-scaffolded' =>
      'TPTK on a brick turn after a call — keep value pressure.',
    // Unguided: name the spot; SoftPulse isn’t on.
    'act-03-05-01-unguided' =>
      'Flush comes in; checked to you — pick delayed value or give up.',
    // SoftPulse owns value bet — don’t gold-tip the dock.
    'act-03-06-01-guided' =>
      'Top two on a brick river — extract when they check.',
    // SoftPulse owns bluff — don’t gold-tip the dock.
    'act-03-06-01-scaffolded' =>
      'You missed; river completes the flush — sell the story.',
    // Unguided: name the spot; list legal lines without SoftPulse.
    'act-03-06-01-unguided' =>
      'Weak top pair faces a quiet-line jam — pick Fold or Call.',
    // SoftPulse owns Check — don’t gold-tip the dock.
    'act-03-07-01-guided' =>
      'Second pair four ways — pot-control with a crowd.',
    // SoftPulse owns Check — don’t gold-tip the dock.
    'act-03-07-01-scaffolded' =>
      'Missed on a wet board with a crowd — don’t stab into many.',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-03-08-01-guided' =>
      'Weak top pair in a raise-reraise pot — leave without stacking.',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-03-08-01-scaffolded' =>
      'Gutshot vs an overbet — price is wrong for four outs.',
    // Unguided: name the spot; SoftPulse isn’t on.
    'act-03-08-01-unguided' =>
      'Air multiway vs a bet — leave without floating the crowd.',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-03-08-02-jump-mw' =>
      'Air four-way on a wet flop — leave without bluffing the crowd.',
    // SoftPulse owns Bet value — don’t gold-tip the dock.
    'act-03-08-02-jump-river' =>
      'Top two on a brick river — extract when they check.',
    // SoftPulse owns 3-bet — don’t gold-tip the dock.
    'act-04-02-01-guided' =>
      'Queens on the button vs a CO open — reopen for value.',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-04-02-01-scaffolded' =>
      '72o faces a BB 3-bet — leave without defending trash.',
    // Unguided: name the spot; list legal lines without SoftPulse.
    'act-04-02-01-unguided' =>
      'UTG open, two callers, AKo in BB — pick Fold, Limp behind, or Squeeze.',
    // SoftPulse owns 3-bet size — don’t gold-tip the dock.
    'act-04-02-01-checkpoint' =>
      'KK vs a live open to 6 — pick a value 3-bet size.',
    // SoftPulse owns Check (abort) — don’t gold-tip the dock.
    'act-04-03-01-scaffolded' =>
      'Air vs a flush turn — the bluff story just got worse.',
    // Unguided: name the spot; list legal lines without SoftPulse.
    'act-04-03-01-unguided' =>
      'Medium hand multiway and deep — pick Keep pot small or Jam.',
    // SoftPulse owns value size — don’t gold-tip the dock.
    'act-04-04-01-guided' =>
      'Dry board, top pair heads-up — ask for a value call into 20.',
    // SoftPulse owns pressure size — don’t gold-tip the dock.
    'act-04-04-01-scaffolded' =>
      'Missed draw on a scare river — sell polar pressure into 40.',
    // SoftPulse owns the worst size — don’t gold-tip the dock.
    'act-04-04-01-checkpoint' =>
      'Strong hand for value into 30 — spot the size that doesn’t look like value.',
    // SoftPulse owns Commit — don’t gold-tip the dock.
    'act-04-05-01-scaffolded' =>
      'Top set at SPR ~1 — commitment territory.',
    // Unguided: name the spot; list legal lines without SoftPulse.
    'act-04-05-01-unguided' =>
      'Second pair multiway at SPR 20 — pick Keep pot small or Jam.',
    // SoftPulse owns Weigh SPR — don’t gold-tip the dock.
    'act-04-05-01-checkpoint' =>
      'About to put the rest in — depth decides commitment.',
    // SoftPulse owns the dock — don’t gold-tip Bet thin value / Give up.
    'act-04-06-03-guided' =>
      'Sticky seat · second pair river — extract vs wide calls.',
    'act-04-06-03-scaffolded' =>
      'Missed draw · same station — no fold equity on air.',
    // Unguided: list legal lines; don’t tip Keep it cautious alone.
    'act-04-06-03-unguided' =>
      'Same hand · unknown seat — pick cautious or thin-value.',
    // SoftPulse owns Open / steal — don’t gold-tip the dock.
    'act-04-07-03-guided' =>
      'Nit in the BB · K9o on button — they overfold blinds.',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-04-07-03-scaffolded' =>
      'Nit check-raises middle pair — their heat is usually strong.',
    // Unguided: name the model; list legal lines without SoftPulse.
    'act-04-07-03-unguided' =>
      'Unknown BB with K9o — pick Tighter baseline or Always steal.',
    // SoftPulse owns Call — don’t gold-tip the dock.
    'act-04-08-03-guided' =>
      'Maniac barrels river · top pair — catch wide aggression.',
    // SoftPulse owns Bet value — don’t gold-tip the dock.
    'act-04-08-03-scaffolded' =>
      'Maniac checks · top two — they call light.',
    // Unguided: name the model; list legal lines without SoftPulse.
    'act-04-08-03-unguided' =>
      'Unknown river bet · weak kicker — pick Fold more or Always call.',
    // SoftPulse owns Bet value — don’t gold-tip the dock.
    'act-04-10-01-guided' =>
      'Station checked · second pair — extract vs wide calls.',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-04-10-01-scaffolded' =>
      'Nit check-raises second pair — their heat is usually strong.',
    // Unguided: name the model; list legal lines without SoftPulse.
    'act-04-10-01-unguided' =>
      'Maniac barrels second pair — pick Call, Fold, or Raise.',
    // Checkpoint lab: name the spot.
    'act-04-10-01-checkpoint' =>
      'BTN vs Nit BB with KTo — steal wider when they overfold.',
    // SoftPulse owns 3-bet to 18 — don’t gold-tip the dock.
    'act-04-10-02-jump-3bet' =>
      'CO opens · KK on BTN — pick a value 3-bet.',
    // SoftPulse owns Bet 10 — don’t gold-tip the dock.
    'act-04-10-02-jump-size' =>
      'Top pair into pot 20 — pick a value size.',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-05-01-01-scaffolded' =>
      '76s in SB multiway — medium connectors hate OOP crowds.',
    // Unguided: name the spot; list legal lines without SoftPulse.
    'act-05-01-01-unguided' =>
      'Top set wet multiway — pick Bet solid value, Check, or Tiny.',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-05-02-01-scaffolded' =>
      'Deep TPWK vs huge wet check-raise — depth punishes light stacks.',
    // SoftPulse owns Call — don’t gold-tip the dock.
    'act-05-03-01-guided' =>
      'Deep gutshot vs Station — sticky callers raise implied odds.',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-05-03-01-scaffolded' =>
      'KJo vs Nit check-raise — reverse implied on A-high wet.',
    // Unguided: name the spot; list legal lines without SoftPulse.
    'act-05-03-01-unguided' =>
      'Non-nut FD four-way — pick Fold or Call.',
    // SoftPulse owns the dock — don’t gold-tip Bet thin value / Call / Check.
    'act-05-04-01-guided' =>
      'Station checked · second pair — extract vs wide calls.',
    'act-05-04-01-scaffolded' =>
      'Maniac barrels · second pair — catch wide aggression.',
    // Unguided: list legal lines; don’t tip Check alone.
    'act-05-04-01-unguided' =>
      'Nit checked · second pair — pick Check or Bet thin.',
    // SoftPulse owns Probe small — don’t gold-tip the dock.
    'act-05-05-01-scaffolded' =>
      'PFR checks · middle pair BB — capped ranges invite small probes.',
    // SoftPulse owns Fold — don’t gold-tip the dock.
    'act-05-06-01-scaffolded' =>
      'Draw faces bomb — re-price when the turn bricks.',
    // Unguided: name the spot; list legal lines without SoftPulse.
    'act-05-08-01-unguided' =>
      'Steaming after cooler — protect the bankroll; leave without revenge.',
    // SoftPulse owns the dock — don’t gold-tip Bet thin value / Call.
    'act-05-09-02-cp-value' =>
      'Station · second pair river — extract vs wide calls.',
    'act-05-09-02-cp-catch' =>
      'Maniac river barrel — catch wide aggression.',
    // Unguided: name the spot; list legal lines without SoftPulse.
    'act-06-01-01-unguided' =>
      'PFR on K72r — dry A-high favors the raiser; pick C-bet 6 or Check.',
    // SoftPulse owns the dock — don’t gold-tip Bet thin.
    'act-06-03-01-scaffolded' =>
      'Capped river · second pair — extract when they check.',
    // SoftPulse owns the dock — don’t gold-tip Bet medium.
    'act-06-04-01-scaffolded' =>
      'Station checked · second pair — extract with a merged size.',
    // SoftPulse owns the dock — don’t gold-tip Bet ~20 (or its amount).
    'act-06-05-01-scaffolded' =>
      'Half-pot flop checked — keep geometric pressure.',
    // SoftPulse owns the dock — don’t gold-tip Fold.
    'act-06-07-01-scaffolded' =>
      'Third pair scary river — trash with no blockers.',
    // SoftPulse owns the dock — don’t gold-tip Check.
    'act-06-08-01-guided' =>
      'Flopped set — protect checking range sometimes.',
    // SoftPulse owns the dock — don’t gold-tip Small c-bet.
    'act-06-09-01-scaffolded' =>
      'Deep 3-bet miss — keep pressure small or give up.',
    // SoftPulse owns the dock — don’t gold-tip Fold.
    'act-06-10-01-guided' =>
      'TPWK vs triple barrels — no maniac read in heat.',
    // SoftPulse owns the dock — don’t gold-tip Fold.
    'act-06-11-03-guided' =>
      'TAG check-raises second pair — respect their heat.',
    // SoftPulse owns the dock — don’t gold-tip Tighter fold.
    'act-06-11-03-scaffolded' =>
      'BTN vs TAG BB with K9o — steal narrower than vs nits.',
    // Unguided: name the model; don’t tip Check.
    'act-06-11-03-unguided' =>
      'River thin vs TAG who rarely calls — need their calls.',
    // SoftPulse owns the dock — don’t gold-tip Call.
    'act-06-12-03-guided' =>
      'LAG barrels river · second pair — widen defense vs pressure.',
    // SoftPulse owns the dock — don’t gold-tip Trap / induce.
    'act-06-12-03-scaffolded' =>
      'Top set vs LAG — let wide pressure hang themselves.',
    // SoftPulse owns the dock — don’t gold-tip Value bet.
    'act-07-03-01-guided' =>
      'Thick value vs station — extract when they call wide.',
    // SoftPulse owns the dock target — don’t gold-tip Bet thin value / Fold.
    'act-06-13-01-guided' =>
      'Same cards · Station checked — extract vs wide calls.',
    'act-06-13-01-scaffolded' =>
      'Same cards · Nit check-raises — respect narrow heat.',
    // Unguided: list legal lines; don’t tip Call alone.
    'act-06-13-01-unguided' =>
      'Same cards · LAG barrels — tap Call or Fold.',
    // SoftPulse owns the dock — don’t gold-tip Bet for value.
    'act-07-07-01-guided' =>
      'Flop top pair · Station check — extract vs wide calls.',
    // SoftPulse owns the dock — don’t gold-tip Fold.
    'act-07-07-01-scaffolded' =>
      'Same top pair · TAG check-raises — respect selective heat.',
    // Unguided: name the model; don’t tip Call alone.
    'act-07-07-01-unguided' =>
      'Same top pair · LAG barrels — defend vs wide pressure.',
    // SoftPulse owns the dock — don’t gold-tip Call.
    'act-07-08-01-guided' =>
      'Wet board · Maniac overbet — widen defense vs pressure.',
    // SoftPulse owns the dock — don’t gold-tip Raise.
    'act-07-08-01-scaffolded' =>
      'Dry board · Nit tiny bet — pressure weak lines.',
    // Unguided: name the model; don’t tip Fold alone.
    'act-07-08-01-unguided' =>
      'TAG pots river · second pair — respect selective heat.',
    _ => null,
  };
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.enabled,
    this.accessibilityText,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final bool enabled;
  final String? accessibilityText;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: accessibilityText ?? label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 108, minHeight: 48),
        child: Material(
          color:
              selected
                  ? AppColors.gold.withValues(alpha: 0.22)
                  : AppColors.feltDark.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.gold : AppColors.feltBorder,
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
