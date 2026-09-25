/// Felt visuals for How pots are won — fold-win, showdown, side pots.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Explain-step demo: three ways a pot is decided.
class WinningPathsDemo extends StatefulWidget {
  /// Creates the demo.
  const WinningPathsDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPathsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPathsTapped;

  @override
  State<WinningPathsDemo> createState() => _WinningPathsDemoState();
}

class _WinningPathsDemoState extends State<WinningPathsDemo> {
  final Set<String> _tapped = <String>{};
  static const _titles = ['FOLD WIN', 'SHOWDOWN', 'SIDE POT'];

  void _onTap(String title) {
    if (!widget.enabled || widget.onAllPathsTapped == null) return;
    setState(() => _tapped.add(title));
    if (_tapped.length >= _titles.length) {
      widget.onAllPathsTapped!();
    }
  }

  int? get _nextIndex {
    for (var i = 0; i < _titles.length; i++) {
      if (!_tapped.contains(_titles[i])) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextIndex;
    // Keep densify after the last path while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final lanes = <(String, String, Widget)>[
      (
        'FOLD WIN',
        'Everyone folds — take it, no show',
        _ChipStack(label: 'POT', amount: '9', densify: expandTeach),
      ),
      (
        'SHOWDOWN',
        'Call to the end — best five wins',
        _ShowdownMini(densify: expandTeach),
      ),
      (
        'SIDE POT',
        'Short all-in — main vs unmatched chips',
        _SidePotMini(densify: expandTeach),
      ),
    ];

    Widget laneAt(int i) {
      return _SoftPulseTarget(
        active:
            widget.interactive && widget.enabled && next == i,
        child: _PathLane(
          step: i + 1,
          title: lanes[i].$1,
          detail: lanes[i].$2,
          visual: lanes[i].$3,
          selected: _tapped.contains(lanes[i].$1),
          densify: expandTeach,
          enabled: widget.interactive && widget.enabled,
          onPressed:
              widget.interactive ? () => _onTap(lanes[i].$1) : null,
        ),
      );
    }

    final pathLanes = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < lanes.length; i++) ...[
          if (i > 0) SizedBox(height: expandTeach ? 14 : 8),
          laneAt(i),
        ],
      ],
    );
    // SoftPulse + Rex own the next-path cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                widget.interactive
                    ? 'Fold win · Showdown · Side pot'
                    : 'Folds, showdown, or side pots decide it',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 16 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
    final body = Column(
      mainAxisSize: expandTeach ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment:
          expandTeach
              ? MainAxisAlignment.spaceEvenly
              : MainAxisAlignment.start,
      children: [
        Text(
          'How a pot is won',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 12),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                // Pack densified lanes, then contain-scale into the felt —
                // fills tall-phone green (scaleDown left a void).
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: max(
                      MediaQuery.sizeOf(context).width - 48,
                      400,
                    ),
                    child: pathLanes,
                  ),
                ),
              ),
            )
            : pathLanes,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 12),
          cue,
        ],
      ],
    );
    final child = Container(
      key: const ValueKey('winning-paths-felt'),
      width: double.infinity,
      height: feltHeight,
      padding: EdgeInsets.fromLTRB(
        12,
        expandTeach ? 18 : 14,
        12,
        expandTeach ? 18 : 14,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.feltBorder.withValues(alpha: 0.85),
        ),
      ),
      child: body,
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Soft gold pulse around the next winning-path lane.
class _SoftPulseTarget extends StatefulWidget {
  const _SoftPulseTarget({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_SoftPulseTarget> createState() => _SoftPulseTargetState();
}

class _SoftPulseTargetState extends State<_SoftPulseTarget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.active) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _SoftPulseTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.active && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = 0.4 + (_pulse.value * 0.55);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: glow * 0.65),
                blurRadius: 12 + (10 * _pulse.value),
                spreadRadius: 1 + (2 * _pulse.value),
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _PathLane extends StatelessWidget {
  const _PathLane({
    required this.step,
    required this.title,
    required this.detail,
    required this.visual,
    this.selected = false,
    this.densify = false,
    this.enabled = false,
    this.onPressed,
  });

  final int step;
  final String title;
  final String detail;
  final Widget visual;
  final bool selected;

  /// Tall-phone SoftPulse pack: larger lane so FittedBox contain can fill felt.
  final bool densify;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final border =
        selected ? AppColors.gold : AppColors.feltBorder.withValues(alpha: 0.7);
    final badge = densify ? 28.0 : 22.0;
    final radius = densify ? 14.0 : 12.0;
    final lane = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: densify ? 12 : 10,
        vertical: densify ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.bgDark.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: selected ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: badge,
            height: badge,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.25),
              border: Border.all(color: AppColors.gold),
            ),
            child: Text(
              '$step',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: densify ? 13 : 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: densify ? 12 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: densify ? 15 : 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: densify ? 12 : 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: densify ? 10 : 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: visual,
          ),
        ],
      ),
    );
    if (onPressed == null) return lane;
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(radius),
          child: lane,
        ),
      ),
    );
  }
}

class _ChipStack extends StatelessWidget {
  const _ChipStack({
    required this.label,
    required this.amount,
    this.densify = false,
  });

  final String label;
  final String amount;
  final bool densify;

  @override
  Widget build(BuildContext context) {
    final chip = densify ? 44.0 : 36.0;
    return Column(
      children: [
        Container(
          width: chip,
          height: chip,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withValues(alpha: 0.35),
            border: Border.all(color: AppColors.gold, width: 2),
          ),
          child: Text(
            amount,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: densify ? 14 : 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(height: densify ? 4 : 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppColors.gold,
            fontSize: densify ? 11 : 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ShowdownMini extends StatelessWidget {
  const _ShowdownMini({this.densify = false});

  final bool densify;

  @override
  Widget build(BuildContext context) {
    final cardSize = densify ? MiniCardSize.small : MiniCardSize.tiny;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MiniCard(card: CardModel.fromCode('Ah'), size: cardSize),
        SizedBox(width: densify ? 3 : 2),
        MiniCard(card: CardModel.fromCode('Kd'), size: cardSize),
        SizedBox(width: densify ? 8 : 6),
        Text(
          'vs',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: densify ? 12 : 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: densify ? 8 : 6),
        MiniCard(card: CardModel.fromCode('Qs'), size: cardSize),
        SizedBox(width: densify ? 3 : 2),
        MiniCard(card: CardModel.fromCode('Jh'), size: cardSize),
      ],
    );
  }
}

class _SidePotMini extends StatelessWidget {
  const _SidePotMini({this.densify = false});

  final bool densify;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _miniPot(label: 'MAIN', color: AppColors.gold),
        SizedBox(width: densify ? 8 : 6),
        _miniPot(label: 'SIDE', color: AppColors.slate),
      ],
    );
  }

  Widget _miniPot({required String label, required Color color}) {
    final size = densify ? 34.0 : 28.0;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.3),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        SizedBox(height: densify ? 4 : 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: color,
            fontSize: densify ? 10 : 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
