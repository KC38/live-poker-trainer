import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Defend / bluff / enough tiles for defend-enough explain demos.
class DefendEnoughDemo extends StatefulWidget {
  /// Creates the demo.
  const DefendEnoughDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'DEFEND', caption: 'Continue enough', color: AppColors.gold),
    (label: 'BLUFF', caption: 'Over-bluffs fail', color: AppColors.cream),
    (label: 'ENOUGH', caption: 'No fake %', color: AppColors.danger),
  ];

  @override
  State<DefendEnoughDemo> createState() => _DefendEnoughDemoState();
}

class _DefendEnoughDemoState extends State<DefendEnoughDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= DefendEnoughDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in DefendEnoughDemo.points) {
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
    // sparse green under DEFEND / BLUFF / ENOUGH).
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final tiles = Row(
      crossAxisAlignment:
          expandTeach ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < DefendEnoughDemo.points.length; i++) ...[
          if (i > 0) SizedBox(width: expandTeach ? 12 : 8),
          Expanded(
            child: _DefendSoftPulse(
              active:
                  widget.interactive &&
                  widget.enabled &&
                  next?.label == DefendEnoughDemo.points[i].label,
              child: _DefendTile(
                label: DefendEnoughDemo.points[i].label,
                caption: DefendEnoughDemo.points[i].caption,
                color: DefendEnoughDemo.points[i].color,
                densify: expandTeach,
                selected: _tapped.contains(DefendEnoughDemo.points[i].label),
                enabled: widget.interactive && widget.enabled,
                onPressed: widget.interactive
                    ? () => _onTap(DefendEnoughDemo.points[i].label)
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
                ? 'Defend better hands — skip fake %'
                : 'Tap ${next.label} next')
            : 'Defend better hands — skip fake %',
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
          'Defend enough',
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

class _DefendTile extends StatelessWidget {
  const _DefendTile({
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

class _DefendSoftPulse extends StatefulWidget {
  const _DefendSoftPulse({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_DefendSoftPulse> createState() => _DefendSoftPulseState();
}

class _DefendSoftPulseState extends State<_DefendSoftPulse>
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
  void didUpdateWidget(covariant _DefendSoftPulse oldWidget) {
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
