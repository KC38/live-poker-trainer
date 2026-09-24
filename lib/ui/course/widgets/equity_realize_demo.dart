import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Equity / cash / pos tiles for equity-realize explain demos.
class EquityRealizeDemo extends StatefulWidget {
  /// Creates the demo.
  const EquityRealizeDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'EQUITY', caption: 'Chart number', color: AppColors.gold),
    (label: 'CASH', caption: 'Not automatic', color: AppColors.cream),
    (label: 'POS', caption: 'Decides realization', color: AppColors.danger),
  ];

  @override
  State<EquityRealizeDemo> createState() => _EquityRealizeDemoState();
}

class _EquityRealizeDemoState extends State<EquityRealizeDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= EquityRealizeDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in EquityRealizeDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    // Keep densify after the last tap while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    // Tall-phone teach: fixed felt + stretched tiles (minHeight alone leaves
    // sparse green under EQUITY / CASH / POS).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < EquityRealizeDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _EquityRealizeSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == EquityRealizeDemo.points[i].label,
              child: _EquityRealizeTile(
                label: EquityRealizeDemo.points[i].label,
                caption: EquityRealizeDemo.points[i].caption,
                color: EquityRealizeDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(EquityRealizeDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(EquityRealizeDemo.points[i].label)
                    : null,
              ),
            ),
          ),
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
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
      ),
      child: Text(
        widget.interactive
            ? (next == null
                ? 'Position decides realization'
                : 'Tap ${next.label} next')
            : 'Position decides realization',
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
          'Equity is not cash',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 14),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: tiles,
              ),
            )
            : tiles,
        if (!expandTeach) const SizedBox(height: 14),
        cue,
      ],
    );
    final child = Container(
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

class _EquityRealizeTile extends StatelessWidget {
  const _EquityRealizeTile({
    required this.label,
    required this.caption,
    required this.color,
    this.densify = false,
    this.selected = false,
    this.enabled = false,
    this.onPressed,
  });

  final String label;
  final String caption;
  final Color color;
  final bool densify;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.gold : color.withValues(alpha: 0.9);
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: densify ? double.infinity : null,
      padding: EdgeInsets.symmetric(
        vertical: densify ? 24 : 12,
        horizontal: densify ? 10 : 6,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.gold.withValues(alpha: 0.28)
            : color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(densify ? 16 : 12),
        border: Border.all(color: borderColor, width: selected ? 2.5 : 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              color: AppColors.cream,
              fontSize: densify ? 18 : 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: densify ? 10 : 4),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.cream.withValues(alpha: 0.9),
              fontSize: densify ? 13 : 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    final child = densify ? SizedBox.expand(child: card) : card;
    if (onPressed == null) return child;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(densify ? 16 : 12),
          child: child,
        ),
      ),
    );
  }
}

class _EquityRealizeSoftPulse extends StatefulWidget {
  const _EquityRealizeSoftPulse({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_EquityRealizeSoftPulse> createState() =>
      _EquityRealizeSoftPulseState();
}

class _EquityRealizeSoftPulseState extends State<_EquityRealizeSoftPulse>
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
  void didUpdateWidget(covariant _EquityRealizeSoftPulse oldWidget) {
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
