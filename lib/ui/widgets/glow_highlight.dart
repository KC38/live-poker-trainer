/// Reusable gold glow highlight for lesson cues and selected targets.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Gold border + outer glow wrapped around any [child].
///
/// This is the single highlight style used across the app — seats, hole
/// cards, board cards (individually or as a group), and demo tiles. Pass
/// the widgets to emphasize as [child]; inactive draws [child] untouched.
///
/// There are no arrows. Optional breathing animation matches the felt cue
/// pulse; set [animated] false for a static selected ring.
class GlowHighlight extends StatefulWidget {
  /// Wraps [child] in the shared gold highlight.
  ///
  /// [padding] expands the ring outward so content is not flush against the
  /// border. Drawn outside [child] so seats keep their footprint under tight
  /// [Positioned] constraints.
  const GlowHighlight({
    super.key,
    required this.child,
    this.active = true,
    this.animated = true,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(4),
  });

  /// Content to highlight — a card, a name tag, a row of cards, etc.
  final Widget child;

  /// When false, draws [child] only.
  final bool active;

  /// When true and [active], the ring breathes. When false, a static ring.
  final bool animated;

  /// Corner radius of the gold ring before [padding] is applied.
  final double borderRadius;

  /// Air between [child] and the gold ring.
  final EdgeInsets padding;

  @override
  State<GlowHighlight> createState() => _GlowHighlightState();
}

class _GlowHighlightState extends State<GlowHighlight>
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
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant GlowHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active ||
        oldWidget.animated != widget.animated) {
      _syncMotion();
    }
  }

  void _syncMotion() {
    if (widget.active && widget.animated) {
      if (!_motion.isAnimating) _motion.repeat(reverse: true);
    } else {
      _motion
        ..stop()
        ..value = widget.active ? 0.55 : 0;
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
        final t = widget.animated ? _beat.value : 0.55;
        return Transform.scale(
          scale: widget.animated ? 1 + (0.05 * t) : 1,
          child: Stack(
            key: const ValueKey<String>('glow-highlight'),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -pad.left,
                top: -pad.top,
                right: -pad.right,
                bottom: -pad.bottom,
                child: DecoratedBox(
                  key: const ValueKey<String>('glow-highlight-ring'),
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

/// Backward-compatible name for [GlowHighlight] used by older call sites.
typedef CuePulse = GlowHighlight;
