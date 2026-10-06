/// Reusable glow highlight for lesson cues and selected targets.
library;

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_soft_pulse_scope.dart';

/// Gold coach/SoftPulse cue versus cyan learner selection.
enum GlowKind {
  /// Gold ring for SoftPulse, hints, and coach “these count” cards.
  cue,

  /// Cyan ring for cards the learner tapped. Stays on after SoftPulse ends
  /// so coach feedback can still show what they picked.
  selection,
}

/// Gold (or cyan) border + outer glow wrapped around any [child].
///
/// Coach/SoftPulse cues use [GlowKind.cue]. Learner taps use
/// [GlowKind.selection] so both rings can sit on the same card. Pass the
/// widgets to emphasize as [child]; inactive hides the ring. Felt seats and
/// cards keep a stable wrapper so toggling SoftPulse does not remount dealt
/// cards.
///
/// There are no arrows. Optional breathing animation matches the felt cue
/// pulse; set [animated] false for a static selected ring.
///
/// By default the ring's [outset] is reserved in layout so SoftPulse tiles
/// (Bet/Raise/All-in, streets, demos) do not paint over neighbors or the
/// tool row. That reserved box is present whether SoftPulse is on or off,
/// so the button face does not resize when hint / guidance toggles the
/// ring. SoftPulse cues one target at a time, so [gutter] clears a single
/// [outset], not two. Felt seats and cards pass [reserveLayout] false so
/// their footprint stays tight under [Positioned] constraints.
///
/// Inside [LessonSoftPulseScope], cue rings also respect the current Hint
/// wave so multi-press teach steps only glow for the first press (or after
/// Hint re-opens SoftPulse). Selection rings ignore that gate.
class GlowHighlight extends StatefulWidget {
  /// Wraps [child] in a gold or cyan highlight.
  const GlowHighlight({
    super.key,
    required this.child,
    this.active = true,
    this.animated = true,
    this.kind = GlowKind.cue,
    this.ignoreSoftPulse = false,
    this.borderRadius = 8,
    this.padding = const EdgeInsets.all(outset),
    this.reserveLayout = true,
  });

  /// Outward paint past [child] on each side (ring pad).
  static const double outset = 6;

  /// Soft-shadow bleed past the ring. Used by the lesson stage inset under
  /// SoftPulse rows — not double-counted into every tile face.
  static const double softBleed = 8;

  /// Clear space between SoftPulse siblings. SoftPulse highlights one tile
  /// at a time, so this clears a single [outset], not two.
  static const double gutter = outset;

  /// Tighter ring so a cyan selection can sit inside a gold coach cue.
  static const double selectionOutset = 4;

  /// Content to highlight — a card, a name tag, a row of cards, etc.
  final Widget child;

  /// When false, hides the ring. With [reserveLayout], the layout pad stays.
  final bool active;

  /// When true and [active], the ring's glow breathes. When false, a static
  /// ring. SoftPulse tiles do not scale — only the glow opacity pulses.
  final bool animated;

  /// Gold coach cue versus cyan learner selection.
  final GlowKind kind;

  /// When true, paint even if [LessonSoftPulseScope] closed the Hint wave.
  ///
  /// Learner selection always sets this so taps remain visible under coach
  /// feedback. Cue rings keep the default (false).
  final bool ignoreSoftPulse;

  /// Corner radius of the ring before [padding] is applied.
  final double borderRadius;

  /// Air between [child] and the ring. Defaults to [outset] on each side.
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

  String get _onKey => widget.kind == GlowKind.selection
      ? 'selection-highlight'
      : 'glow-highlight';

  String get _offKey => widget.kind == GlowKind.selection
      ? 'selection-highlight-off'
      : 'glow-highlight-off';

  String get _ringKey => widget.kind == GlowKind.selection
      ? 'selection-highlight-ring'
      : 'glow-highlight-ring';

  Color get _color => widget.kind == GlowKind.selection
      ? AppColors.selectionGlow
      : AppColors.goldBright;

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
    final color = _color;
    return BoxDecoration(
      borderRadius: radius,
      border: Border.all(
        color: color,
        width: 2.4,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withValues(
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

    // Multi-press SoftPulse: demos may mark the next tile active, but the
    // frame SoftPulse scope decides whether this Hint wave still glows.
    // Learner selection stays on so coach feedback can show their picks.
    final bool active = widget.active &&
        (widget.ignoreSoftPulse || LessonSoftPulseScope.isAllowed(context));

    if (widget.reserveLayout) {
      // SoftPulse tiles: reserve only [outset] so faces stay large. Soft
      // shadow may soft-bleed into [gutter] / stage inset; SoftPulse cues
      // one tile at a time so that is enough. Breath is glow opacity only.
      return AnimatedBuilder(
        animation: _motion,
        builder: (context, child) {
          final t = widget.animated ? _beat.value : 0.55;
          return DecoratedBox(
            key: ValueKey<String>(_ringKey),
            decoration:
                active ? _ringDecoration(t, radius) : const BoxDecoration(),
            child: Padding(
              key: ValueKey<String>(_onKey),
              padding: pad,
              child: child,
            ),
          );
        },
        child: widget.child,
      );
    }

    // Felt seats / cards: keep the child's footprint; ring paints outside.
    // Always use this tree — swapping to a bare [child] when inactive
    // remounted [DealtCardReveal] and replayed the deal on every tap.
    return AnimatedBuilder(
      animation: _motion,
      builder: (context, child) {
        final t = widget.animated ? _beat.value : 0.55;
        return Transform.scale(
          scale: widget.animated && active ? 1 + (0.05 * t) : 1,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -pad.left,
                top: -pad.top,
                right: -pad.right,
                bottom: -pad.bottom,
                child: KeyedSubtree(
                  key: active
                      ? ValueKey<String>(_onKey)
                      : ValueKey<String>(_offKey),
                  child: DecoratedBox(
                    key: ValueKey<String>(_ringKey),
                    decoration: active
                        ? _ringDecoration(t, radius)
                        : const BoxDecoration(),
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

/// Cyan learner selection inside a gold coach/SoftPulse cue.
///
/// Used on felt cards, seats, and any other tap target. Wrappers stay
/// mounted whether either ring is on so dealt cards do not replay.
/// Selection ignores SoftPulse so picks remain visible under coach
/// feedback; the gold cue still respects the Hint wave.
class LessonTargetGlow extends StatelessWidget {
  /// Wraps [child] with optional selection and cue rings.
  const LessonTargetGlow({
    super.key,
    required this.child,
    this.selected = false,
    this.highlighted = false,
    this.borderRadius = 8,
    this.scale = 1,
    this.reserveLayout = false,
    this.cueIgnoresSoftPulse = false,
  });

  /// Card face (or [DealtCardReveal] wrapping it).
  final Widget child;

  /// Cyan ring: the learner tapped this card.
  final bool selected;

  /// Gold ring: SoftPulse next target or coach feedback.
  final bool highlighted;

  /// Card corner radius before ring padding.
  final double borderRadius;

  /// Scales ring padding with the felt.
  final double scale;

  /// When true, gold cue reserves layout (demo trays). Felt uses false.
  final bool reserveLayout;

  /// When true, gold cue paints even if SoftPulse is closed (coach review).
  final bool cueIgnoresSoftPulse;

  @override
  Widget build(BuildContext context) {
    final selectionPad = GlowHighlight.selectionOutset * scale;
    final cuePad = GlowHighlight.outset * scale +
        (selected && highlighted ? 3.0 * scale : 0);
    return GlowHighlight(
      kind: GlowKind.selection,
      active: selected,
      animated: false,
      ignoreSoftPulse: true,
      reserveLayout: reserveLayout,
      borderRadius: borderRadius,
      padding: EdgeInsets.all(selectionPad),
      child: GlowHighlight(
        active: highlighted,
        animated: highlighted && !selected,
        ignoreSoftPulse: cueIgnoresSoftPulse,
        reserveLayout: false,
        borderRadius: borderRadius,
        padding: EdgeInsets.all(cuePad),
        child: child,
      ),
    );
  }
}

/// Backward-compatible name for [GlowHighlight] used by older call sites.
typedef CuePulse = GlowHighlight;
