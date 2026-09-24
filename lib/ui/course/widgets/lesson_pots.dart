/// Felt visuals for How pots are won — fold-win, showdown, side pots.
library;

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
  static const _cueLabels = ['Fold win', 'Showdown', 'Side pot'];

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
        const _ChipStack(label: 'POT', amount: '9'),
      ),
      (
        'SHOWDOWN',
        'Call to the end — best five wins',
        const _ShowdownMini(),
      ),
      (
        'SIDE POT',
        'Short all-in — main vs unmatched chips',
        const _SidePotMini(),
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
          if (i > 0) SizedBox(height: expandTeach ? 10 : 8),
          laneAt(i),
        ],
      ],
    );
    final cue = Container(
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
            ? (next == null
                ? 'Fold win · Showdown · Side pot'
                : 'Tap ${_cueLabels[next]}')
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
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).width - 48,
                    child: pathLanes,
                  ),
                ),
              ),
            )
            : pathLanes,
        if (!expandTeach) const SizedBox(height: 12),
        cue,
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
    this.enabled = false,
    this.onPressed,
  });

  final int step;
  final String title;
  final String detail;
  final Widget visual;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final border =
        selected ? AppColors.gold : AppColors.feltBorder.withValues(alpha: 0.7);
    final lane = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.bgDark.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: selected ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
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
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          visual,
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
          borderRadius: BorderRadius.circular(12),
          child: lane,
        ),
      ),
    );
  }
}

class _ChipStack extends StatelessWidget {
  const _ChipStack({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
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
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppColors.gold,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ShowdownMini extends StatelessWidget {
  const _ShowdownMini();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MiniCard(card: CardModel.fromCode('Ah'), size: MiniCardSize.tiny),
        const SizedBox(width: 2),
        MiniCard(card: CardModel.fromCode('Kd'), size: MiniCardSize.tiny),
        const SizedBox(width: 6),
        Text(
          'vs',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        MiniCard(card: CardModel.fromCode('Qs'), size: MiniCardSize.tiny),
        const SizedBox(width: 2),
        MiniCard(card: CardModel.fromCode('Jh'), size: MiniCardSize.tiny),
      ],
    );
  }
}

class _SidePotMini extends StatelessWidget {
  const _SidePotMini();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _miniPot(label: 'MAIN', color: AppColors.gold),
        const SizedBox(width: 6),
        _miniPot(label: 'SIDE', color: AppColors.slate),
      ],
    );
  }

  Widget _miniPot({required String label, required Color color}) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.3),
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
