/// Dedicated coach shelf — CORRECT / INCORRECT / CLOSE from server coaching.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/coach_feedback.dart';

/// Non-overlapping coach panel between the hero rail and the action dock.
class CoachShelfWidget extends StatelessWidget {
  /// Creates the coach shelf.
  const CoachShelfWidget({
    super.key,
    required this.feedback,
    required this.bigBlind,
    required this.chipDisplayMode,
    this.replaying = false,
    this.preparing = false,
    this.maxHeight,
    this.onDismiss,
    this.dismissLabel = 'Continue',
    this.onUndo,
    this.undoLabel = 'Undo',
  });

  final CoachFeedback feedback;
  final double bigBlind;
  final ChipDisplayMode chipDisplayMode;
  final bool replaying;

  /// True while the server is generating the coaching rubric.
  final bool preparing;
  final double? maxHeight;

  /// Clears the shelf (or advances the hand when [dismissLabel] is Next hand).
  final VoidCallback? onDismiss;

  /// Button copy for [onDismiss] — Continue mid-hand, Next hand when done.
  final String dismissLabel;

  /// Rewinds the graded action so the player can pick another branch.
  final VoidCallback? onUndo;

  /// Button copy for [onUndo].
  final String undoLabel;

  ChipDisplayMode get _stripMode => chipDisplayMode.tableMode;

  String get _message {
    if (feedback.message.isEmpty) return 'Reviewing that line…';
    return feedback.message;
  }

  String? get _optimalLine {
    final label = feedback.optimalActionLabel ?? feedback.optimalAction?.label;
    if (label == null || label.isEmpty) return null;
    return ChipFormat.optimalLine(
      actionLabel: label,
      sizingBb: feedback.optimalSizingBb,
      bigBlind: bigBlind,
      mode: _stripMode,
    );
  }

  String get _youLine {
    final label = feedback.heroAction;
    if (label == null || label.isEmpty) return '—';
    return ChipFormat.optimalLine(
      actionLabel: label,
      sizingBb: feedback.heroSizingBb,
      bigBlind: bigBlind,
      mode: _stripMode,
    );
  }

  Color get _borderColor {
    return switch (feedback.verdict) {
      CoachVerdict.correct => AppColors.success,
      CoachVerdict.close => AppColors.warning,
      CoachVerdict.incorrect => AppColors.danger,
      _ => AppColors.slateDark,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (preparing && !feedback.hasAdvice) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
        child: const _CoachPreparingShelf(),
      );
    }

    final hasVerdict = feedback.hasVerdict;
    final optimal = _optimalLine;
    final canDismiss = onDismiss != null && !replaying;
    final canUndo = onUndo != null && !replaying;

    final advice = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _CoachHeader(replaying: replaying, feedback: feedback),
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
              confidence: feedback.confidence,
              compact: false,
            ),
          ),
        if (canDismiss || canUndo)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                if (canUndo)
                  TextButton(
                    onPressed: onUndo,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.cream.withValues(alpha: 0.85),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      undoLabel,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                const Spacer(),
                if (canDismiss)
                  TextButton(
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.goldBright,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    child: Text(
                      dismissLabel,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final hasCap = maxHeight != null && constraints.hasBoundedHeight;
        if (!hasCap) return advice;
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
            color: _borderColor,
            width: hasVerdict ? 1.5 : 0.8,
          ),
        ),
        child: body,
      ),
    );
  }
}

class _HeightCappedScroll extends StatelessWidget {
  const _HeightCappedScroll({required this.maxHeight, required this.child});

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

/// Pulsing shelf shown while the next coaching rubric is generating.
class _CoachPreparingShelf extends StatefulWidget {
  const _CoachPreparingShelf();

  @override
  State<_CoachPreparingShelf> createState() => _CoachPreparingShelfState();
}

class _CoachPreparingShelfState extends State<_CoachPreparingShelf>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_pulse.value);
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          decoration: BoxDecoration(
            color: AppColors.bgElevated.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.35 + 0.45 * t),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.12 + 0.18 * t),
                blurRadius: 14 + 10 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
              const SizedBox(width: 8),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.6,
                  color: AppColors.goldBright.withValues(alpha: 0.9),
                ),
              ),
              const Spacer(),
              Text(
                'REVIEWING…',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppColors.goldBright,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Grading your line against the table…',
            style: GoogleFonts.manrope(
              fontSize: 13.5,
              height: 1.35,
              color: AppColors.cream.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const _ShimmerBars(),
        ],
      ),
    );
  }
}

class _ShimmerBars extends StatefulWidget {
  const _ShimmerBars();

  @override
  State<_ShimmerBars> createState() => _ShimmerBarsState();
}

class _ShimmerBarsState extends State<_ShimmerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slide;

  @override
  void initState() {
    super.initState();
    _slide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slide,
      builder: (context, _) {
        return Column(
          children: [
            for (final width in const [1.0, 0.82, 0.64])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _ShimmerBar(progress: _slide.value, widthFactor: width),
              ),
          ],
        );
      },
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  const _ShimmerBar({required this.progress, required this.widthFactor});

  final double progress;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment(-1.2 + 2.4 * progress, 0),
            end: Alignment(-0.2 + 2.4 * progress, 0),
            colors: [
              AppColors.surfaceMuted,
              AppColors.gold.withValues(alpha: 0.35),
              AppColors.surfaceMuted,
            ],
          ),
        ),
      ),
    );
  }
}

class _CoachHeader extends StatelessWidget {
  const _CoachHeader({required this.replaying, required this.feedback});

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
          _VerdictBadge(verdict: feedback.verdict, compact: true),
      ],
    );
  }
}

class _DecisionStatsStrip extends StatelessWidget {
  const _DecisionStatsStrip({
    required this.best,
    required this.you,
    required this.evAmount,
    required this.evDeltaBb,
    required this.confidence,
    required this.compact,
  });

  final String best;
  final String you;
  final String evAmount;
  final double evDeltaBb;
  final String? confidence;
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
            child: _StatsCell(label: 'BEST', value: best, compact: compact),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _StatsCell(label: 'YOU', value: you, compact: compact),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _StatsCell(
              label: confidence == null ? 'EV' : 'CONFIDENCE',
              value: confidence?.toUpperCase() ?? evAmount,
              valueColor: confidence == null ? _evColor : AppColors.gold,
              compact: compact,
            ),
          ),
        ],
      ),
    );
  }
}

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

class _VerdictBadge extends StatelessWidget {
  const _VerdictBadge({required this.verdict, this.compact = false});

  final CoachVerdict verdict;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (verdict) {
      CoachVerdict.correct => ('CORRECT', AppColors.success),
      CoachVerdict.close => ('CLOSE', AppColors.warning),
      _ => ('INCORRECT', AppColors.danger),
    };
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 9,
        vertical: compact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
      ),
      child: Text(
        label,
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
