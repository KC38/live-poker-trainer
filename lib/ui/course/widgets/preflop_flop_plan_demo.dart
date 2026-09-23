import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Reason / Confirm / Cancel tiles for preflop→flop plan explain demos.
class PreflopFlopPlanDemo extends StatefulWidget {
  /// Creates the demo.
  const PreflopFlopPlanDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'REASON', caption: 'Enter with why', color: AppColors.gold),
    (label: 'CONFIRM', caption: 'Flop agrees', color: AppColors.cream),
    (label: 'CANCEL', caption: 'Flop kills it', color: AppColors.danger),
  ];

  @override
  State<PreflopFlopPlanDemo> createState() => _PreflopFlopPlanDemoState();
}

class _PreflopFlopPlanDemoState extends State<PreflopFlopPlanDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= PreflopFlopPlanDemo.points.length) {
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
            'Preflop → flop',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < PreflopFlopPlanDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _PreflopFlopPlanTile(
                    label: PreflopFlopPlanDemo.points[i].label,
                    caption: PreflopFlopPlanDemo.points[i].caption,
                    color: PreflopFlopPlanDemo.points[i].color,
                    selected: _tapped.contains(
                      PreflopFlopPlanDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed: widget.interactive
                        ? () => _onTap(PreflopFlopPlanDemo.points[i].label)
                        : null,
                  ),
                ),
              ],
            ],
          ),
          // Interactive: Rex already cues Reason / Confirm / Cancel — no dupe footer.
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Reason in · flop confirms or cancels',
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

class _PreflopFlopPlanTile extends StatelessWidget {
  const _PreflopFlopPlanTile({
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
