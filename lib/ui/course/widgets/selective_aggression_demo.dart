import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Tight / barrel / sample tiles for selective-aggression explain demos.
class SelectiveAggressionDemo extends StatefulWidget {
  /// Creates the demo.
  const SelectiveAggressionDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'TIGHT', caption: 'Selective entry', color: AppColors.gold),
    (label: 'BARREL', caption: 'With a plan', color: AppColors.cream),
    (label: 'SAMPLE', caption: 'Count first', color: AppColors.danger),
  ];

  @override
  State<SelectiveAggressionDemo> createState() =>
      _SelectiveAggressionDemoState();
}

class _SelectiveAggressionDemoState extends State<SelectiveAggressionDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= SelectiveAggressionDemo.points.length) {
      widget.onAllPointsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'Selective aggression',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0;
                  i < SelectiveAggressionDemo.points.length;
                  i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _SelectiveAggressionTile(
                    label: SelectiveAggressionDemo.points[i].label,
                    caption: SelectiveAggressionDemo.points[i].caption,
                    color: SelectiveAggressionDemo.points[i].color,
                    selected: _tapped.contains(
                      SelectiveAggressionDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed: widget.interactive
                        ? () => _onTap(
                              SelectiveAggressionDemo.points[i].label,
                            )
                        : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues Tight / Barrel / Sample — no dupe footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Tight entry, then barrels with a plan — count samples',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

class _SelectiveAggressionTile extends StatelessWidget {
  const _SelectiveAggressionTile({
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
