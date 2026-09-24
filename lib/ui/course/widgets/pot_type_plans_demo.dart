import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Limped / SRP / 3-4bet tiles for pot-type plan explain demos.
class PotTypePlansDemo extends StatefulWidget {
  /// Creates the demo.
  const PotTypePlansDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'LIMPED', caption: 'Nut potential', color: AppColors.cream),
    (label: 'SRP', caption: 'C-bet maps', color: AppColors.gold),
    (label: '3-4BET', caption: 'High commit', color: AppColors.danger),
  ];

  @override
  State<PotTypePlansDemo> createState() => _PotTypePlansDemoState();
}

class _PotTypePlansDemoState extends State<PotTypePlansDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= PotTypePlansDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in PotTypePlansDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.feltLight, AppColors.feltDark],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.85)),
      ),
      child: Column(
        children: [
          Text(
            'Plans by pot type',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < PotTypePlansDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _PotSoftPulse(
                    active:
                        widget.interactive &&
                        widget.enabled &&
                        next?.label == PotTypePlansDemo.points[i].label,
                    child: _PotTypePlansTile(
                      label: PotTypePlansDemo.points[i].label,
                      caption: PotTypePlansDemo.points[i].caption,
                      color: PotTypePlansDemo.points[i].color,
                      selected: _tapped.contains(
                        PotTypePlansDemo.points[i].label,
                      ),
                      enabled: widget.interactive && widget.enabled,
                      onPressed: widget.interactive
                          ? () => _onTap(PotTypePlansDemo.points[i].label)
                          : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? (next == null
                    ? 'Pot type sets ranges and SPR — plan accordingly'
                    : 'Tap ${next.label} next')
                : 'Pot type sets ranges and SPR — plan accordingly',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

class _PotTypePlansTile extends StatelessWidget {
  const _PotTypePlansTile({
    required this.label,
    required this.caption,
    required this.color,
    this.selected = false,
    this.enabled = false,
    this.onPressed,
  });

  final String label;
  final String caption;
  final Color color;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.gold : color.withValues(alpha: 0.9);
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.gold.withValues(alpha: 0.28)
            : color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: selected ? 2 : 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.cream.withValues(alpha: 0.9),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    if (!enabled || onPressed == null) return child;
    return GestureDetector(onTap: onPressed, child: child);
  }
}

class _PotSoftPulse extends StatefulWidget {
  const _PotSoftPulse({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_PotSoftPulse> createState() => _PotSoftPulseState();
}

class _PotSoftPulseState extends State<_PotSoftPulse>
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
  void didUpdateWidget(covariant _PotSoftPulse oldWidget) {
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
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glow = 0.22 + (_pulse.value * 0.38);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: glow),
                blurRadius: 10 + (_pulse.value * 8),
                spreadRadius: 0.5 + (_pulse.value * 1.2),
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
