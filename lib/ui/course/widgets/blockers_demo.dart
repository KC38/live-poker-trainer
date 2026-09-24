import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Block / remove / EV tiles for blocker explain demos.
class BlockersDemo extends StatefulWidget {
  /// Creates the demo.
  const BlockersDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'BLOCK', caption: 'Remove hands', color: AppColors.gold),
    (label: 'USE', caption: 'Apply blockers', color: AppColors.cream),
    (label: 'NO EV', caption: 'Skip decimals', color: AppColors.danger),
  ];

  @override
  State<BlockersDemo> createState() => _BlockersDemoState();
}

class _BlockersDemoState extends State<BlockersDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= BlockersDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  ({String label, String caption, Color color})? get _nextPoint {
    for (final point in BlockersDemo.points) {
      if (!_tapped.contains(point.label)) return point;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextPoint;
    final expandTeach = widget.interactive && widget.enabled && next != null;
    final minFelt =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.38 : null;
    final child = ConstrainedBox(
      constraints:
          minFelt != null
              ? BoxConstraints(minHeight: minFelt)
              : const BoxConstraints(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        alignment: minFelt != null ? Alignment.center : null,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Blockers',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (var i = 0; i < BlockersDemo.points.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _BlockersSoftPulse(
                      active:
                          widget.interactive &&
                          widget.enabled &&
                          next?.label == BlockersDemo.points[i].label,
                      child: _BlockerTile(
                        label: BlockersDemo.points[i].label,
                        caption: BlockersDemo.points[i].caption,
                        color: BlockersDemo.points[i].color,
                        selected: _tapped.contains(
                          BlockersDemo.points[i].label,
                        ),
                        enabled: widget.interactive && widget.enabled,
                        onPressed: widget.interactive
                            ? () => _onTap(BlockersDemo.points[i].label)
                            : null,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                        ? 'Remove hands — skip EV decimals'
                        : 'Tap ${next.label} next')
                    : 'Remove hands — skip EV decimals',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: AppColors.gold,
                  fontSize: expandTeach ? 14 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

class _BlockerTile extends StatelessWidget {
  const _BlockerTile({
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
    if (onPressed == null) return child;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}

class _BlockersSoftPulse extends StatefulWidget {
  const _BlockersSoftPulse({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_BlockersSoftPulse> createState() => _BlockersSoftPulseState();
}

class _BlockersSoftPulseState extends State<_BlockersSoftPulse>
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
  void didUpdateWidget(covariant _BlockersSoftPulse oldWidget) {
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

