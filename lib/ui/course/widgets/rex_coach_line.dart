/// Shared Rex coach line for lesson activities.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';

/// Resolves a single Rex instruction vs a duplicate prompt under the bubble.
///
/// Teach-by-doing: prefer one spoken line. Authored dialogue/demo wins; otherwise
/// the activity [CourseActivity.prompt] becomes the Rex line so we do not repeat
/// near-identical copy ("Tap ranks…" + "Order these ranks…").
({String coach, bool showPrompt}) resolveLessonCoachPrompt({
  required CourseActivity activity,
  required String fallback,
}) {
  final authored = activity.primaryCoachLine?.text.trim();
  final prompt = activity.prompt?.trim();
  if (authored != null && authored.isNotEmpty) {
    final show =
        prompt != null &&
        prompt.isNotEmpty &&
        prompt.toLowerCase() != authored.toLowerCase();
    return (coach: authored, showPrompt: show);
  }
  if (prompt != null && prompt.isNotEmpty) {
    return (coach: prompt, showPrompt: false);
  }
  return (coach: fallback, showPrompt: false);
}

/// Felt-first densified asks for select_identify steps whose catalog prompt
/// is still quiz-list language.
///
/// Under [LessonFrameScope], [RexCoachLine] shrinks and the runner bubble
/// uses [lessonFrameSpeech]. Without these lines, frame speech falls through
/// to catalog + "Tap the best answer." (LPT-221). Shared with the activity's
/// own coach so unframed and framed paths stay identical.
String? selectIdentifyDensifiedCoachLine(String activityId) {
  return switch (activityId) {
    'act-02-07-02-jump-family' =>
      'Look at your holes — pick the family they belong to.',
    'act-02-07-02-jump-stack' =>
      'You 120bb · villain 55bb — pick the effective stack.',
    // Count outs densified asks (LPT-279) — same path as baseline jump (LPT-221).
    'act-03-03-01-guided' =>
      'Count only the outs that make the best hand — pick every clean out.',
    'act-03-03-01-scaffolded' =>
      'Pot 20, bet 10 — pick the call that equals the bet.',
    'act-03-03-01-unguided' =>
      'Getting 3:1 with real outs — pick Call, Fold, or Raise.',
    'act-03-03-01-checkpoint' =>
      'Nut flush draw, deep and sticky — pick when future payoffs justify the price.',
    // Close the river checkpoint densified ask (LPT-343) — same path as
    // baseline jump (LPT-221) / count outs (LPT-279). Use pick/tap so
    // withLessonTapInstruction does not append "Tap the best answer."
    'act-03-06-01-checkpoint' =>
      'Medium one pair faces a big bet — pick the river job.',
    // Play tighter multiway densified asks (LPT-368) — same path.
    'act-03-07-01-unguided' =>
      'Deep multiway — pick the better speculative hand.',
    'act-03-07-01-checkpoint' =>
      'Seat enters most pots — pick what you note.',
    // Patch the common leaks checkpoint densified ask (LPT-382) — same path.
    'act-03-08-01-checkpoint' =>
      'Two seats, different frequencies — pick how often each seat enters.',
    // Section 3 jump select_identify densified asks (LPT-390) — same path.
    // jump-class stays felt-first (no hard-coded template ranks/suits).
    'act-03-08-02-jump-table' =>
      'Pot 16, shorter 40bb — pick pot and effective stack first.',
    'act-03-08-02-jump-class' =>
      'Straight and flush both need runout — pick the hand class.',
    'act-03-08-02-jump-leak' =>
      'Gutshot vs a 2x pot bet — pick Fold when the price is wrong.',
    // Think in ranges densified asks (LPT-403) — same path as LPT-390.
    'act-04-01-01-guided' =>
      'UTG opens at 1/2 — pick the stronger, narrower range.',
    'act-04-01-01-scaffolded' =>
      'BTN open, BB 3-bet, BTN calls — pick whose range is stronger.',
    'act-04-01-01-unguided' =>
      'They bet twice — pick why Exactly AK is too precise.',
    'act-04-01-01-checkpoint' =>
      'Same board, different villain lines — pick how advice should change.',
    // Plan beyond the flop checkpoint densified ask (LPT-407) — same path.
    'act-04-03-01-checkpoint' =>
      'You have a flop plan — pick brick→barrel vs flush→abort.',
    // Size with a message unguided densified ask (LPT-410) — same path.
    'act-04-04-01-unguided' =>
      'Two value sizes both get calls — pick nearby soft-grade over one exact chip.',
    // SPR decides commitment guided densified ask (LPT-412) — same path.
    'act-04-05-01-guided' =>
      'Effective 80 into pot 20 — pick SPR 4.',
    // Observe sticky callers densified asks (LPT-416) — same path.
    'act-04-06-01-guided' =>
      'Seat calls 7 of 9 preflops — pick High part.',
    'act-04-06-01-scaffolded' =>
      'Second pair called three streets twice — pick Sticky.',
    'act-04-06-01-unguided' =>
      'One dramatic call — pick Low conf.',
    'act-04-06-01-checkpoint' =>
      'Before you label — pick Bundle.',
    // Meet the Calling Station densified asks (LPT-420) — same path.
    'act-04-06-02-guided' =>
      'Sticky second pair called three streets — pick Station.',
    'act-04-06-02-scaffolded' =>
      'A player-type label is temporary evidence — pick Working model.',
    'act-04-06-02-unguided' =>
      'Limps, calls, never folds turns — pick Station.',
    'act-04-06-02-checkpoint' =>
      'Only two hands so far — pick Low conf.',
    // Recognize capped densified asks (LPT-636) — same path as LPT-416.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-03-01-guided' =>
      'Checks turn after flop bet — pick Capped.',
    'act-06-03-01-unguided' =>
      'XR flop / bet turn / bomb — pick Uncapped.',
    'act-06-03-01-checkpoint' => 'Caps are for — pick Attack.',
    // Choose polarized densified asks (LPT-637) — same path as LPT-636.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-04-01-guided' =>
      'River overbet — pick the betting shape.',
    'act-06-04-01-unguided' =>
      'Mismatch to avoid — pick the sizing leak.',
    'act-06-04-01-checkpoint' =>
      'Merged betting aims to — pick the goal.',
    // Use overbets densified asks (LPT-638) — same path as LPT-637.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-05-01-guided' =>
      'Best overbet river — pick the polar candidate.',
    'act-06-05-01-unguided' =>
      'Random 3x pot medium — pick the disciplined line.',
    'act-06-05-01-checkpoint' =>
      'Geometric sizing helps — pick what it links.',
    // Use blockers densified asks (LPT-639) — same path as LPT-638.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-06-01-guided' =>
      'Flush-board river bluff — pick the better blocker.',
    'act-06-06-01-scaffolded' =>
      'Bluff-catch flush bomb — pick what you leave live.',
    'act-06-06-01-unguided' =>
      'Blockers replace — pick how far they go.',
    'act-06-06-01-checkpoint' =>
      'Solver EV quotes — pick the course stance.',
    // Defend enough densified asks (LPT-640) — same path as LPT-639.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-07-01-guided' =>
      'Facing a river bet — pick quality continues.',
    'act-06-07-01-unguided' =>
      'MDF numbers — pick how this course uses them.',
    'act-06-07-01-checkpoint' =>
      'Minimum defense goal — pick what you protect.',
    // Mix with a reason densified asks (LPT-644) — same path as LPT-640.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-08-01-scaffolded' =>
      'Vs Calling Station — pick the mix adjustment.',
    'act-06-08-01-unguided' =>
      'Randomness for its own sake — pick when mix is allowed.',
    'act-06-08-01-checkpoint' =>
      'Best mix description — pick the course standard.',
    // Navigate 3-bet densified asks (LPT-645) — same path as LPT-644.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-09-01-guided' =>
      '100bb 4-bet pot · top pair — pick the depth mindset.',
    'act-06-09-01-unguided' =>
      'Light 4-bet for ego — pick the discipline.',
    'act-06-09-01-checkpoint' =>
      'Depth change in 3-bet pots — pick what shifts.',
    // Difficult folds densified asks (LPT-646) — same path as LPT-645.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-10-01-scaffolded' =>
      'KK loses to AA all-in — pick the review label.',
    'act-06-10-01-unguided' =>
      'Calling because you are "due" — pick the real reason.',
    'act-06-10-01-checkpoint' =>
      'Review after a big loss — pick the honest question.',
    // Observe selective densified asks (LPT-647) — same path as LPT-646.
    // Use pick/tap so withLessonTapInstruction does not append the footer.
    'act-06-11-01-guided' =>
      'Folds most, then 3-bets / c-bets — pick the note.',
    'act-06-11-01-scaffolded' =>
      'Gives up on turns when called — pick the observation.',
    'act-06-11-01-unguided' =>
      'Two hands of tightness — pick the confidence.',
    'act-06-11-01-checkpoint' =>
      'Best pre-label note bundle — pick the evidence pack.',
    _ => null,
  };
}

/// Whether Rex should render for [activity] given [showGuidance] and resolved
/// coach copy (covers prompt-as-Rex on unguided steps).
bool shouldShowLessonCoach({
  required CourseActivity activity,
  required bool showGuidance,
  required String coach,
}) {
  if (coach.trim().isEmpty) return false;
  return showGuidance ||
      activity.primaryCoachLine != null ||
      (activity.prompt?.trim().isNotEmpty ?? false);
}

/// One short Rex sentence with optional demonstration chrome.
class RexCoachLine extends StatelessWidget {
  /// Creates a Rex line.
  const RexCoachLine({
    super.key,
    required this.text,
    this.label = 'Rex',
    this.emphasize = false,
  });

  /// Builds from catalog media when present.
  factory RexCoachLine.fromActivity(CourseActivity activity, {Key? key}) {
    final media = activity.primaryCoachLine;
    return RexCoachLine(
      key: key,
      text: media?.text ?? activity.accessibilityText,
      emphasize: media?.kind == 'demonstration',
    );
  }

  final String text;
  final String label;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    if (LessonFrameScope.maybeOf(context) != null) {
      return const SizedBox.shrink();
    }
    return Semantics(
      label: '$label says: $text',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RexMascot(size: 36),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              decoration: BoxDecoration(
                color: AppColors.bgElevated.withValues(alpha: 0.85),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                border: Border.all(
                  color:
                      emphasize
                          ? AppColors.gold.withValues(alpha: 0.55)
                          : AppColors.slateDark,
                ),
              ),
              child: Text(
                text,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 14.5,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Choice chip/button used across select-style activities.
class LessonChoiceButton extends StatelessWidget {
  /// Creates a choice button.
  const LessonChoiceButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.accessibilityText,
    this.highlighted = false,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final String? accessibilityText;
  final bool highlighted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final border =
        selected
            ? AppColors.selectionGlow
            : highlighted
            ? AppColors.goldMuted
            : AppColors.slateDark;
    return Semantics(
      button: true,
      selected: selected,
      label: accessibilityText ?? label,
      child: AnimatedScale(
        scale: selected ? 1.015 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Material(
          color:
              selected
                  ? AppColors.selectionGlow.withValues(alpha: 0.22)
                  : highlighted
                  ? AppColors.gold.withValues(alpha: 0.08)
                  : AppColors.surfaceMuted.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: selected ? 2 : 1),
              ),
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  color: enabled ? AppColors.cream : AppColors.slate,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
