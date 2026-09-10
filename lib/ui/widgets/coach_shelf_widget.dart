/// Dedicated coach shelf — clear CORRECT / INCORRECT, never over cards.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/engine/leak_lines.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';

/// Non-overlapping AI coach panel between the hero rail and the action dock.
///
/// Shown only after a hero action produces coaching. Always shows the full
/// advice plus decision context inside this band (height-capped by the parent;
/// content scrolls internally and never covers hero hole cards).
///
/// Layout is a single full-width column (no side badge rail) so advice copy and
/// BEST/YOU/EV use the whole shelf. A shelved prior-street grade is labeled
/// inline as `Correct · preflop` / `Incorrect · turn` so it cannot be read as
/// live advice for the current street.
class CoachShelfWidget extends StatelessWidget {
  /// Creates the coach shelf.
  const CoachShelfWidget({
    super.key,
    required this.feedback,
    required this.bigBlind,
    required this.chipDisplayMode,
    this.replaying = false,
    this.maxHeight,
  });

  final CoachFeedback feedback;
  final double bigBlind;
  final ChipDisplayMode chipDisplayMode;

  /// True while villains are acting, shown as a subtle live indicator.
  final bool replaying;

  /// Hard cap for this band; content scrolls beyond it.
  final double? maxHeight;

  /// Felt-style chip mode so strip amounts stay compact like table stacks.
  ChipDisplayMode get _stripMode => chipDisplayMode.tableMode;

  String get _message {
    if (feedback.message.isEmpty) {
      return 'Reviewing that line…';
    }
    return feedback.message;
  }

  String? get _optimalLine {
    if (feedback.optimalAction == null) {
      return null;
    }
    return ChipFormat.optimalLine(
      actionLabel: feedback.optimalAction!.label,
      sizingBb: feedback.optimalSizingBb,
      bigBlind: bigBlind,
      mode: _stripMode,
    );
  }

  /// Hero action with raise/bet size when available for fair BEST comparison.
  String get _youLine {
    final label = feedback.heroAction;
    if (label == null || label.isEmpty) {
      return '—';
    }
    return ChipFormat.optimalLine(
      actionLabel: label,
      sizingBb: feedback.heroSizingBb,
      bigBlind: bigBlind,
      mode: _stripMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasVerdict = feedback.hasVerdict;
    final borderColor = feedback.isHistorical
        ? AppColors.slateDark
        : feedback.verdict == CoachVerdict.correct
            ? AppColors.success
            : feedback.verdict == CoachVerdict.incorrect
                ? AppColors.danger
                : AppColors.slateDark;
    final optimal = _optimalLine;

    final advice = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _CoachHeader(
          replaying: replaying,
          feedback: feedback,
        ),
        if (feedback.isRepeat || feedback.isImprovement) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (feedback.isRepeat)
                _LeakChip(
                  label: LeakLines.repeatBadge(feedback.repeatCount),
                  color: AppColors.warning,
                  icon: Icons.replay_rounded,
                ),
              if (feedback.isImprovement)
                _LeakChip(
                  label: LeakLines.improvementBadge(
                    feedback.improvementStreak,
                  ),
                  color: AppColors.success,
                  icon: Icons.trending_up_rounded,
                ),
            ],
          ),
        ],
        const SizedBox(height: 6),
        Text(
          _message,
          style: GoogleFonts.manrope(
            fontSize: 13.5,
            height: 1.35,
            color: AppColors.cream,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (hasVerdict)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _DecisionStatsStrip(
              best: optimal ?? '—',
              you: _youLine,
              evAmount: ChipFormat.evDeltaAmount(
                feedback.evDeltaBb,
                bigBlind,
                _stripMode,
              ),
              evDeltaBb: feedback.evDeltaBb,
              compact: feedback.isHistorical,
            ),
          ),
      ],
    );

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final hasCap = maxHeight != null && constraints.hasBoundedHeight;
        if (!hasCap) {
          return advice;
        }
        return _HeightCappedScroll(
          maxHeight: constraints.maxHeight,
          child: advice,
        );
      },
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: hasVerdict ? 1.5 : 0.8,
          ),
        ),
        child: body,
      ),
    );
  }
}

/// Sizes to [child] until [maxHeight], then scrolls instead of overflowing.
class _HeightCappedScroll extends StatelessWidget {
  const _HeightCappedScroll({
    required this.maxHeight,
    required this.child,
  });

  final double maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [child],
      ),
    );
  }
}

/// Coach title plus live verdict or shelved prior-street grade.
class _CoachHeader extends StatelessWidget {
  const _CoachHeader({
    required this.replaying,
    required this.feedback,
  });

  final bool replaying;
  final CoachFeedback feedback;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Coach',
          style: GoogleFonts.cinzel(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.goldMuted,
            letterSpacing: 1.1,
          ),
        ),
        if (replaying) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'TABLE ACTING…',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (feedback.hasVerdict)
          feedback.isHistorical
              ? _HistoricalGradeChip(feedback: feedback)
              : _VerdictBadge(verdict: feedback.verdict, compact: true),
      ],
    );
  }
}

/// Shelved grade from an earlier street — not live advice for the tip below.
///
/// Copy is `Correct · preflop` / `Incorrect · turn` so the street scopes the
/// verdict and cannot be mistaken for the current-street tip.
class _HistoricalGradeChip extends StatelessWidget {
  const _HistoricalGradeChip({required this.feedback});

  final CoachFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final correct = feedback.verdict == CoachVerdict.correct;
    final street = feedback.decisionStreet?.label.toLowerCase() ?? 'earlier';
    final color = correct ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.65), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            correct ? Icons.check_rounded : Icons.close_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${correct ? 'Correct' : 'Incorrect'} · $street',
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w800,
              fontSize: 9.5,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aligned BEST / YOU / EV decision strip for graded coach feedback.
class _DecisionStatsStrip extends StatelessWidget {
  const _DecisionStatsStrip({
    required this.best,
    required this.you,
    required this.evAmount,
    required this.evDeltaBb,
    required this.compact,
  });

  final String best;
  final String you;
  final String evAmount;
  final double evDeltaBb;
  final bool compact;

  Color get _evColor {
    if (evDeltaBb > 0.001) return AppColors.success;
    if (evDeltaBb < -0.001) return AppColors.danger;
    return AppColors.cream;
  }

  @override
  Widget build(BuildContext context) {
    final padV = compact ? 6.0 : 8.0;
    final padH = compact ? 8.0 : 10.0;
    final gap = compact ? 6.0 : 8.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        border: Border.all(
          color: AppColors.slateDark.withValues(alpha: 0.9),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatsCell(
              label: 'BEST',
              value: best,
              compact: compact,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _StatsCell(
              label: 'YOU',
              value: you,
              compact: compact,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _StatsCell(
              label: 'EV',
              value: evAmount,
              valueColor: _evColor,
              compact: compact,
            ),
          ),
        ],
      ),
    );
  }
}

/// One labeled mono value in the decision stats strip.
///
/// Never ellipsizes away raise sizing — scales the mono value down so the
/// full `RAISE · $42` string stays readable in the three-cell strip.
class _StatsCell extends StatelessWidget {
  const _StatsCell({
    required this.label,
    required this.value,
    required this.compact,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool compact;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: compact ? 8.5 : 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.9,
            color: AppColors.goldMuted,
            height: 1.1,
          ),
        ),
        SizedBox(height: compact ? 2 : 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 2,
            softWrap: true,
            textAlign: TextAlign.left,
            style: GoogleFonts.jetBrainsMono(
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.cream,
              height: 1.15,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

/// Small "Repeat ×N" / "Improved" indicator under the header.
class _LeakChip extends StatelessWidget {
  const _LeakChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w800,
              fontSize: 8.5,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerdictBadge extends StatelessWidget {
  const _VerdictBadge({
    required this.verdict,
    this.compact = false,
  });

  final CoachVerdict verdict;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final correct = verdict == CoachVerdict.correct;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 9,
        vertical: compact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: correct ? AppColors.success : AppColors.danger,
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
      ),
      child: Text(
        correct ? 'CORRECT' : 'INCORRECT',
        style: GoogleFonts.jetBrainsMono(
          fontWeight: FontWeight.w800,
          fontSize: compact ? 9.5 : 10.5,
          color: AppColors.bgDark,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
