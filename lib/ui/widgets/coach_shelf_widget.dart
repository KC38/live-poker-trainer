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
/// Collapsed by default to a short preview so the felt stays readable. Expanding
/// reveals the full advice plus decision context inside this band (height-capped
/// by the parent; content scrolls internally and never covers hero hole cards).
class CoachShelfWidget extends StatefulWidget {
  /// Creates the coach shelf.
  const CoachShelfWidget({
    super.key,
    required this.feedback,
    required this.bigBlind,
    required this.chipDisplayMode,
    this.onMuteToggle,
    this.ttsEnabled = true,
    this.replaying = false,
    this.maxHeight,
    this.autoExpand = false,
  });

  final CoachFeedback feedback;
  final double bigBlind;
  final ChipDisplayMode chipDisplayMode;
  final VoidCallback? onMuteToggle;
  final bool ttsEnabled;

  /// True while villains are acting, shown as a subtle live indicator.
  final bool replaying;

  /// Hard cap for this band; content scrolls beyond it.
  final double? maxHeight;

  /// Opens the full review copy without a tap.
  ///
  /// Set once the hand is over: the action dock is gone, so the shelf owns
  /// that space and should show the whole verdict rather than a teaser. The
  /// user can still collapse it, and the next hand returns to a preview.
  final bool autoExpand;

  @override
  State<CoachShelfWidget> createState() => _CoachShelfWidgetState();
}

class _CoachShelfWidgetState extends State<CoachShelfWidget> {
  /// Whether the full coach copy is open.
  ///
  /// New coach lines keep this preference: stay collapsed by default, but if
  /// the panel is already open it stays open for the next line. Entering or
  /// leaving review ([CoachShelfWidget.autoExpand]) overrides it.
  late bool _expanded = widget.autoExpand;

  @override
  void didUpdateWidget(covariant CoachShelfWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoExpand != oldWidget.autoExpand) {
      _expanded = widget.autoExpand;
    }
  }

  CoachFeedback get _feedback => widget.feedback;

  String get _message {
    if (_feedback.message.isEmpty) {
      return 'Your move — pick Fold, Check/Call, or Bet/Raise.';
    }
    return _feedback.message;
  }

  String? get _optimalLine {
    if (_feedback.optimalAction == null) {
      return null;
    }
    return ChipFormat.optimalLine(
      actionLabel: _feedback.optimalAction!.label,
      sizingBb: _feedback.optimalSizingBb,
      bigBlind: widget.bigBlind,
      mode: widget.chipDisplayMode,
    );
  }

  /// Extra decision context only shown while expanded.
  bool get _hasHiddenContext => _feedback.hasVerdict;

  /// Whether the advice benefits from a collapser (long copy or hidden context).
  bool get _canCollapse {
    if (_hasHiddenContext) {
      return true;
    }
    // ~2 lines at 13.5px / 1.35 height on a phone coach column.
    return _message.length > 90;
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final hasVerdict = _feedback.hasVerdict;
    final borderColor = _feedback.verdict == CoachVerdict.correct
        ? AppColors.success
        : _feedback.verdict == CoachVerdict.incorrect
            ? AppColors.danger
            : AppColors.slateDark;
    final showExpanded = _expanded || !_canCollapse;
    final optimal = _optimalLine;
    final maxHeight = widget.maxHeight;

    final advice = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _CoachHeader(replaying: widget.replaying),
        const SizedBox(height: 4),
        Text(
          _message,
          maxLines: showExpanded ? null : 2,
          overflow: showExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: GoogleFonts.manrope(
            fontSize: 13.5,
            height: 1.35,
            color: AppColors.cream,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (hasVerdict)
          Padding(
            padding: EdgeInsets.only(top: showExpanded ? 10 : 8),
            child: _DecisionStatsStrip(
              best: optimal ?? '—',
              you: _feedback.heroAction ?? '—',
              evAmount: ChipFormat.evDeltaAmount(
                _feedback.evDeltaBb,
                widget.bigBlind,
                widget.chipDisplayMode,
              ),
              evDeltaBb: _feedback.evDeltaBb,
              compact: !showExpanded,
            ),
          ),
      ],
    );

    // Pin Show more/less below a height-capped scroll so it stays tappable
    // when advice + stats exceed the band. Budget uses the real inner
    // constraint (not the outer maxHeight), so padding/margin never overflow.
    final body = LayoutBuilder(
      builder: (context, constraints) {
        const toggleReserve = 40.0;
        final hasCap = maxHeight != null && constraints.hasBoundedHeight;
        final scrollChild = hasCap
            ? _HeightCappedScroll(
                maxHeight: _canCollapse
                    ? (constraints.maxHeight - toggleReserve)
                        .clamp(48.0, constraints.maxHeight)
                    : constraints.maxHeight,
                child: advice,
              )
            : advice;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            scrollChild,
            if (_canCollapse)
              _CollapseToggle(
                expanded: showExpanded,
                onPressed: _toggleExpanded,
              ),
          ],
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
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: hasVerdict ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasVerdict) ...[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _VerdictBadge(verdict: _feedback.verdict),
                  if (_feedback.isRepeat)
                    _LeakChip(
                      label: LeakLines.repeatBadge(_feedback.repeatCount),
                      color: AppColors.warning,
                      icon: Icons.replay_rounded,
                    )
                  else if (_feedback.isImprovement)
                    _LeakChip(
                      label: LeakLines.improvementBadge(
                        _feedback.improvementStreak,
                      ),
                      color: AppColors.success,
                      icon: Icons.trending_up_rounded,
                    ),
                ],
              ),
              const SizedBox(width: 12),
            ],
            Expanded(child: body),
            IconButton(
              tooltip: widget.ttsEnabled ? 'Mute coach' : 'Unmute coach',
              onPressed: widget.onMuteToggle,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                widget.ttsEnabled
                    ? Icons.volume_up_outlined
                    : Icons.volume_off_outlined,
                color: AppColors.slate,
                size: 20,
              ),
            ),
          ],
        ),
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
        // Size to the preview when collapsed; scroll only when over the cap.
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        children: [child],
      ),
    );
  }
}

class _CoachHeader extends StatelessWidget {
  const _CoachHeader({required this.replaying});

  final bool replaying;

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
      ],
    );
  }
}

/// Aligned BEST / YOU / EV decision strip for graded coach feedback.
///
/// Expanded: labeled cells with mono values. Collapsed: compact peek so the
/// verdict stays scannable without opening the full shelf.
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
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.jetBrainsMono(
            fontSize: compact ? 11 : 12.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.cream,
            height: 1.15,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

/// Touch-friendly expand / collapse control for the coach copy.
class _CollapseToggle extends StatelessWidget {
  const _CollapseToggle({
    required this.expanded,
    required this.onPressed,
  });

  final bool expanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: AppColors.goldMuted,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  expanded ? 'Show less' : 'Show more',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small "Repeat ×N" / "Improved" indicator under the verdict badge.
///
/// Lives inside the verdict column so it never widens the shelf or overlaps
/// the hero rail above.
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
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
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
      ),
    );
  }
}

class _VerdictBadge extends StatelessWidget {
  const _VerdictBadge({required this.verdict});

  final CoachVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final correct = verdict == CoachVerdict.correct;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: correct ? AppColors.success : AppColors.danger,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        correct ? 'CORRECT' : 'INCORRECT',
        style: GoogleFonts.jetBrainsMono(
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
          color: AppColors.bgDark,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
