/// Reusable gold glow highlight for lesson cues and selected targets.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Gold border + outer glow wrapped around any [child].
///
/// This is the single highlight style used across the app — seats, hole
/// cards, board cards (individually or as a group), and demo tiles. Pass
/// the widgets to emphasize as [child]; inactive draws [child] untouched
/// when [reserveLayout] is false.
///
/// There are no arrows. Optional breathing animation matches the felt cue
/// pulse; set [animated] false for a static selected ring.
///
/// By default the ring's [outset] is reserved in layout so SoftPulse tiles
/// (Bet/Raise/All-in, streets, demos) do not paint over neighbors or the
/// tool row. That reserved box is present whether SoftPulse is on or off,
/// so the button face does not resize when hint / guidance toggles the
/// ring. Felt seats and cards pass [reserveLayout] false so their
/// footprint stays tight under [Positioned] constraints.
class GlowHighlight extends StatefulWidget {
  /// Wraps [child] in the shared gold highlight.
  const GlowHighlight({
    super.key,
    required this.child,
    this.active = true,
    this.animated = true,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(outset),
    this.reserveLayout = true,
  });

  /// Outward paint past [child] on each side (ring pad).
  static const double outset = 6;

  /// Extra layout air past the ring for soft-shadow so neighboring SoftPulse
  /// tiles stay clear of the glow.
  static const double softBleed = 8;

  /// Minimum clear space between neighboring SoftPulse targets after each
  /// has reserved its own [outset] + [softBleed].
  static const double gutter = outset * 2;

  /// Content to highlight — a card, a name tag, a row of cards, etc.
  final Widget child;

  /// When false, hides the ring. With [reserveLayout], the layout pad stays.
  final bool active;

  /// When true and [active], the ring's glow breathes. When false, a static
  /// ring. SoftPulse tiles do not scale — only the glow opacity pulses.
  final bool animated;

  /// Corner radius of the gold ring before [padding] is applied.
  final double borderRadius;

  /// Air between [child] and the gold ring. Defaults to [outset] on each side.
  final EdgeInsets padding;

  /// When true (default), pad the layout so the ring sits inside this
  /// widget's box — always, even when inactive, so SoftPulse does not
  /// resize the face. When false, paint the ring outside [child] (felt
  /// seats / cards under tight [Positioned] slots).
  final bool reserveLayout;

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

  BoxDecoration _ringDecoration(double t, BorderRadius radius) {
    return BoxDecoration(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = widget.padding;
    // Grow corner radius with the outward pad so the ring still tracks the
    // child's rounded shape.
    final radius = BorderRadius.only(
      topLeft: Radius.circular(widget.borderRadius + pad.top),
      topRight: Radius.circular(widget.borderRadius + pad.top),
      bottomLeft: Radius.circular(widget.borderRadius + pad.bottom),
      bottomRight: Radius.circular(widget.borderRadius + pad.bottom),
    );

    if (widget.reserveLayout) {
      // SoftPulse tiles: always keep outset + softBleed in layout so the
      // face size is stable when SoftPulse turns on (hint / guidance).
      // Breath is glow opacity only — no Transform.scale.
      return AnimatedBuilder(
        animation: _motion,
        builder: (context, child) {
          final t = widget.animated ? _beat.value : 0.55;
          return Padding(
            padding: const EdgeInsets.all(GlowHighlight.softBleed),
            child: DecoratedBox(
              key: const ValueKey<String>('glow-highlight-ring'),
              decoration:
                  widget.active
                      ? _ringDecoration(t, radius)
                      : const BoxDecoration(),
              child: Padding(
                key: const ValueKey<String>('glow-highlight'),
                padding: pad,
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      );
    }

    if (!widget.active) return widget.child;

    // Felt seats / cards: keep the child's footprint; ring paints outside.
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
                  decoration: _ringDecoration(t, radius),
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
