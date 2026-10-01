/// Lesson tap cues: bouncing gold arrows and a pulsing gold ring.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Bouncing gold arrows that mark the tap the step is teaching.
class CueArrows extends StatefulWidget {
  /// Creates [count] arrows [size] tall. [pointUp] flips them for a target
  /// that sits above the arrows.
  const CueArrows({
    super.key,
    this.count = 1,
    this.size = 22,
    this.pointUp = false,
  });

  final int count;
  final double size;
  final bool pointUp;

  @override
  State<CueArrows> createState() => _CueArrowsState();
}

class _CueArrowsState extends State<CueArrows>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounce = CurvedAnimation(parent: _motion, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final travel = widget.size * 0.36;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _motion,
        builder: (context, child) {
          final dip = 2.0 + (_bounce.value * travel);
          final glow = 0.35 + (_bounce.value * 0.55);
          return Transform.translate(
            offset: Offset(0, widget.pointUp ? -dip : dip),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldBright.withValues(alpha: glow * 0.75),
                    blurRadius: 10 + (8 * _bounce.value),
                    spreadRadius: 1 + (2 * _bounce.value),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Row(
          key: const ValueKey<String>('felt-cue-arrows'),
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.count; i++)
              Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 2),
                child: Icon(
                  widget.pointUp
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: widget.size,
                  color: AppColors.goldBright,
                  shadows: [
                    Shadow(
                      color: AppColors.gold.withValues(alpha: 0.9),
                      blurRadius: 8,
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

/// Gold ring that breathes around the next thing to tap, in time with
/// [CueArrows].
class CuePulse extends StatefulWidget {
  /// Wraps [child]. Inactive draws [child] untouched.
  ///
  /// [padding] expands the ring outward so content (e.g. hole cards) is not
  /// flush against the gold border — especially the top edge.
  const CuePulse({
    super.key,
    required this.child,
    this.active = true,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.fromLTRB(4, 6, 4, 4),
  });

  final Widget child;
  final bool active;
  final double borderRadius;

  /// Air between [child] and the gold ring. Drawn outside [child] so seats
  /// keep their footprint under tight [Positioned] constraints.
  final EdgeInsets padding;

  @override
  State<CuePulse> createState() => _CuePulseState();
}

class _CuePulseState extends State<CuePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  late final Animation<double> _beat;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _beat = CurvedAnimation(parent: _motion, curve: Curves.easeInOut);
    if (widget.active) _motion.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant CuePulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_motion.isAnimating) {
      _motion.repeat(reverse: true);
    } else if (!widget.active && _motion.isAnimating) {
      _motion
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    final pad = widget.padding;
    // Grow corner radius with the outward pad so the ring still tracks the
    // child's rounded shape.
    final radius = BorderRadius.only(
      topLeft: Radius.circular(widget.borderRadius + pad.top),
      topRight: Radius.circular(widget.borderRadius + pad.top),
      bottomLeft: Radius.circular(widget.borderRadius + pad.bottom),
      bottomRight: Radius.circular(widget.borderRadius + pad.bottom),
    );
    return AnimatedBuilder(
      animation: _motion,
      builder: (context, child) {
        final t = _beat.value;
        return Transform.scale(
          scale: 1 + (0.05 * t),
          child: Stack(
            key: const ValueKey<String>('cue-pulse'),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -pad.left,
                top: -pad.top,
                right: -pad.right,
                bottom: -pad.bottom,
                child: DecoratedBox(
                  key: const ValueKey<String>('cue-pulse-ring'),
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(
                      color: AppColors.goldBright,
                      width: 2.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.goldBright.withValues(
                          alpha: 0.35 + (0.45 * t),
                        ),
                        blurRadius: 10 + (10 * t),
                        spreadRadius: 1 + (2.5 * t),
                      ),
                    ],
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}
