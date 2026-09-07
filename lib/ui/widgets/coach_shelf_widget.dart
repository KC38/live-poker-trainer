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

  @override
  State<CoachShelfWidget> createState() => _CoachShelfWidgetState();
}

class _CoachShelfWidgetState extends State<CoachShelfWidget> {
  /// Whether the user has opened the full coach copy.
  ///
  /// New coach lines keep this preference: stay collapsed by default, but if
  /// the panel is already open it stays open for the next line.
  bool _expanded = false;

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
  bool get _hasHiddenContext {
    return _feedback.hasVerdict && _optimalLine != null;
  }

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

    final body = Column(
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
        if (showExpanded && hasVerdict && optimal != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Best: $optimal'
              '${_feedback.heroAction != null ? '  ·  You: ${_feedback.heroAction}' : ''}'
              '  ·  ${ChipFormat.evDelta(_feedback.evDeltaBb, widget.bigBlind, widget.chipDisplayMode)}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9.5,
                height: 1.35,
                color: AppColors.slate,
              ),
            ),
          ),
        if (_canCollapse)
          _CollapseToggle(
            expanded: showExpanded,
            onPressed: _toggleExpanded,
          ),
      ],
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
            Expanded(
              child: maxHeight == null
                  ? body
                  : _HeightCappedScroll(
                      maxHeight: maxHeight,
                      // Leave room for vertical padding inside the panel.
                      paddingReserve: 20,
                      child: body,
                    ),
            ),
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
    required this.paddingReserve,
    required this.child,
  });

  final double maxHeight;
  final double paddingReserve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cap = (maxHeight - paddingReserve).clamp(48.0, maxHeight);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: cap),
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
