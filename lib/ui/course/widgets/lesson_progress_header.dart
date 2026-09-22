/// Progress, lives, streak, and hint chrome for the lesson runner.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Top chrome for an in-progress lesson.
///
/// Duolingo-chess density: one tight row (track + lives + optional streak +
/// hint). Optional title sits flush underneath only when callers pass it.
/// When [livesRemaining] drops, the heart chip pulses once (scale + opacity).
class LessonProgressHeader extends StatefulWidget {
  /// Creates the header.
  const LessonProgressHeader({
    super.key,
    this.title,
    required this.progress,
    required this.livesRemaining,
    required this.livesMax,
    required this.acceptedStreak,
    this.onHint,
    this.hintEnabled = false,
  });

  /// Single loss pulse — short enough to feel snappy, not distracting.
  static const Duration livesLossPulseDuration = Duration(milliseconds: 200);

  /// Optional secondary title. Prefer showing the activity prompt once in the
  /// activity body — leave null here to avoid duplicating the question.
  final String? title;
  final double progress;
  final int livesRemaining;
  final int livesMax;
  final int acceptedStreak;
  final VoidCallback? onHint;
  final bool hintEnabled;

  @override
  State<LessonProgressHeader> createState() => _LessonProgressHeaderState();
}

class _LessonProgressHeaderState extends State<LessonProgressHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _livesPulse;

  @override
  void initState() {
    super.initState();
    _livesPulse = AnimationController(
      vsync: this,
      duration: LessonProgressHeader.livesLossPulseDuration,
    );
  }

  @override
  void didUpdateWidget(covariant LessonProgressHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.livesRemaining < oldWidget.livesRemaining) {
      _livesPulse.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _livesPulse.dispose();
    super.dispose();
  }

  /// Peak mid-pulse (scale up + slight fade), settle at identity.
  double get _livesScale {
    final t = _livesPulse.value;
    if (t <= 0 || t >= 1) return 1;
    // 0→0.5 swell to 1.28, 0.5→1 settle back to 1.
    if (t < 0.5) {
      return 1 + 0.28 * (t / 0.5);
    }
    return 1.28 - 0.28 * ((t - 0.5) / 0.5);
  }

  double get _livesOpacity {
    final t = _livesPulse.value;
    if (t <= 0 || t >= 1) return 1;
    // Dip slightly at peak, restore by end.
    if (t < 0.5) {
      return 1 - 0.35 * (t / 0.5);
    }
    return 0.65 + 0.35 * ((t - 0.5) / 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final hasTitle = widget.title != null && widget.title!.trim().isNotEmpty;
    final showStreak = widget.acceptedStreak >= 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label:
              'Lesson progress ${(widget.progress * 100).round()} percent. '
              '${widget.livesRemaining} of ${widget.livesMax} lives. '
              'Accepted streak ${widget.acceptedStreak}.',
          child: SizedBox(
            height: 28,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: widget.progress.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.slateDark,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedBuilder(
                  animation: _livesPulse,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _livesOpacity,
                      child: Transform.scale(
                        scale: _livesScale,
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, size: 16, color: AppColors.danger),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.livesRemaining}',
                        style: GoogleFonts.manrope(
                          color: AppColors.cream,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showStreak) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.local_fire_department,
                    size: 15,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.acceptedStreak}',
                    style: GoogleFonts.manrope(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      height: 1,
                    ),
                  ),
                ],
                if (widget.onHint != null) ...[
                  const SizedBox(width: 2),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: IconButton(
                      tooltip: 'Hint',
                      onPressed: widget.hintEnabled ? widget.onHint : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.lightbulb_outline,
                        size: 18,
                        color:
                            widget.hintEnabled
                                ? AppColors.gold
                                : AppColors.slateDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasTitle) ...[
          const SizedBox(height: 6),
          Text(
            widget.title!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
