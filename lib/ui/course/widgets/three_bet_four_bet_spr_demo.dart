import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';

/// 3-bet / 4-bet / depth tiles for raised-pot SPR explain demos.
class ThreeBetFourBetSprDemo extends StatefulWidget {
  /// Creates the demo.
  const ThreeBetFourBetSprDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllPointsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllPointsTapped;

  static const points = <({String label, String caption, Color color})>[
    (label: '3BET', caption: 'Shrink ranges', color: AppColors.gold),
    (label: '4BET', caption: 'Lower SPR', color: AppColors.cream),
    (label: 'DEPTH', caption: 'Decides commit', color: AppColors.danger),
  ];

  @override
  State<ThreeBetFourBetSprDemo> createState() => _ThreeBetFourBetSprDemoState();
}

class _ThreeBetFourBetSprDemoState extends State<ThreeBetFourBetSprDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllPointsTapped == null) return;
    setState(() => _tapped.add(label));
    if (_tapped.length >= ThreeBetFourBetSprDemo.points.length) {
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
            '3-bet / 4-bet SPR',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < ThreeBetFourBetSprDemo.points.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _SprTile(
                    label: ThreeBetFourBetSprDemo.points[i].label,
                    caption: ThreeBetFourBetSprDemo.points[i].caption,
                    color: ThreeBetFourBetSprDemo.points[i].color,
                    selected: _tapped.contains(
                      ThreeBetFourBetSprDemo.points[i].label,
                    ),
                    enabled: widget.interactive && widget.enabled,
                    onPressed: widget.interactive
                        ? () => _onTap(ThreeBetFourBetSprDemo.points[i].label)
                        : null,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.interactive
                ? 'Tap 3-Bet, 4-Bet, and Depth'
                : 'Raised pots shrink ranges — depth decides commitment',
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

class _SprTile extends StatelessWidget {
  const _SprTile({
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
