import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// Nuts / Deep / No-bluff tiles for capstone multiway-deep explain demos.
class CapstoneMultiwayDeepDemo extends StatefulWidget {
  /// Creates the demo.
  const CapstoneMultiwayDeepDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: 'NUTS', caption: 'Prefer potential', color: AppColors.gold),
    (label: 'DEEP', caption: 'Implied odds', color: AppColors.cream),
    (label: 'NO-BLUFF', caption: 'Crowds punish air', color: AppColors.danger),
  ];

  @override
  State<CapstoneMultiwayDeepDemo> createState() =>
      _CapstoneMultiwayDeepDemoState();
}

class _CapstoneMultiwayDeepDemoState extends State<CapstoneMultiwayDeepDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= CapstoneMultiwayDeepDemo.points.length) {
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
            'Capstone · multiway deep',
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
                  i < CapstoneMultiwayDeepDemo.points.length;
                  i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _CapstoneMwDeepTile(
                    label: CapstoneMultiwayDeepDemo.points[i].label,
                    caption: CapstoneMultiwayDeepDemo.points[i].caption,
                    color: CapstoneMultiwayDeepDemo.points[i].color,
                    selected: _tapped.contains(
                      CapstoneMultiwayDeepDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed: widget.interactive
                        ? () =>
                            _onTap(CapstoneMultiwayDeepDemo.points[i].label)
                        : null,
                  ),
                ),
              ],
            ],
          ),
          if (!widget.interactive) ...[
            const SizedBox(height: 10),
            Text(
              'Deep multiway — chase nuts, skip light bluffs',
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

class _CapstoneMwDeepTile extends StatelessWidget {
  const _CapstoneMwDeepTile({
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
              fontSize: 11,
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
