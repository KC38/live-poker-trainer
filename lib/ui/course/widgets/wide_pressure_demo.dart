import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Wide / pressure / sample tiles for LAG-observe explain demos.
class WidePressureDemo extends StatefulWidget {
  /// Creates the demo.
  const WidePressureDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'WIDE', caption: 'Many opens', color: AppColors.gold),
    (label: 'PRESSURE', caption: 'Barrels with a plan', color: AppColors.cream),
    (label: 'SAMPLE', caption: 'Count first', color: AppColors.danger),
  ];

  @override
  State<WidePressureDemo> createState() => _WidePressureDemoState();
}

class _WidePressureDemoState extends State<WidePressureDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= WidePressureDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in WidePressureDemo.points) {
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
            'Wide sustained pressure',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < WidePressureDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _WideSoftPulse(
                    active:
                        widget.interactive &&
                        widget.enabled &&
                        next?.label == WidePressureDemo.points[i].label,
                    child: _WidePressureTile(
                      label: WidePressureDemo.points[i].label,
                      caption: WidePressureDemo.points[i].caption,
                      color: WidePressureDemo.points[i].color,
                      selected: _tapped.contains(
                        WidePressureDemo.points[i].label,
                      ),
                      enabled: widget.interactive && widget.enabled,
                      onPressed: widget.interactive
                          ? () => _onTap(WidePressureDemo.points[i].label)
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
                    ? 'Wide in · pressure on · count samples'
                    : 'Tap ${next.label} next')
                : 'Wide in · pressure on · count samples',
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

class _WidePressureTile extends StatelessWidget {
  const _WidePressureTile({
    required this.label,
    required this.caption,
    required this.color,
    required this.selected,
    required this.enabled,
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
    return Material(
      color: color.withValues(alpha: selected ? 0.35 : 0.18),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.gold : color.withValues(alpha: 0.7),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: AppColors.cream,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                style: GoogleFonts.manrope(
                  color: AppColors.slate,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideSoftPulse extends StatefulWidget {
  const _WideSoftPulse({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_WideSoftPulse> createState() => _WideSoftPulseState();
}

class _WideSoftPulseState extends State<_WideSoftPulse>
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
  void didUpdateWidget(covariant _WideSoftPulse oldWidget) {
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
