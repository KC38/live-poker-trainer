/// Felt visuals for Play a full toy hand — blinds → act → ending.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

/// Explain-step demo: one short hand from blinds to a finish.
class ToyHandRunDemo extends StatefulWidget {
  /// Creates the demo.
  const ToyHandRunDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllStepsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllStepsTapped;

  @override
  State<ToyHandRunDemo> createState() => _ToyHandRunDemoState();
}

class _ToyHandRunDemoState extends State<ToyHandRunDemo> {
  final Set<String> _tapped = <String>{};
  static const _titles = ['BLINDS', 'YOU ACT', 'ENDING'];

  void _onTap(String title) {
    if (!widget.enabled || widget.onAllStepsTapped == null) return;
    setState(() => _tapped.add(title));
    if (_tapped.length >= _titles.length) {
      widget.onAllStepsTapped!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lanes = <(String, String, Widget)>[
      (
        'BLINDS',
        'SB and BB post — pot starts',
        const _BlindDots(),
      ),
      (
        'YOU ACT',
        'Open, call, or fold on a street',
        const _HeroMini(),
      ),
      (
        'ENDING',
        'Folds win it — or keep going',
        const _PotEndChip(),
      ),
    ];
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
        border: Border.all(
          color: AppColors.feltBorder.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        children: [
          Text(
            'One short hand',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < lanes.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _RunLane(
              step: i + 1,
              title: lanes[i].$1,
              detail: lanes[i].$2,
              visual: lanes[i].$3,
              selected: _tapped.contains(lanes[i].$1),
              enabled: widget.interactive && widget.enabled,
              onPressed:
                  widget.interactive ? () => _onTap(lanes[i].$1) : null,
            ),
          ],
          const SizedBox(height: 12),
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
                  ? 'Tap Blinds, You act, and Ending'
                  : 'Blinds post, you act, then finish',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

class _RunLane extends StatelessWidget {
  const _RunLane({
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
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.feltDark.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: selected ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.22),
              border: Border.all(color: AppColors.gold, width: 1.4),
            ),
            child: Text(
              '$step',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 11,
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
          borderRadius: BorderRadius.circular(14),
          child: lane,
        ),
      ),
    );
  }
}

class _BlindDots extends StatelessWidget {
  const _BlindDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _chip('1'),
        const SizedBox(width: 4),
        _chip('2'),
      ],
    );
  }

  Widget _chip(String amount) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold.withValues(alpha: 0.3),
        border: Border.all(color: AppColors.gold, width: 1.3),
      ),
      child: Text(
        amount,
        style: GoogleFonts.manrope(
          color: AppColors.gold,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HeroMini extends StatelessWidget {
  const _HeroMini();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final code in const ['Ah', '9h']) ...[
          MiniCard(card: CardModel.fromCode(code), size: MiniCardSize.tiny),
          const SizedBox(width: 2),
        ],
      ],
    );
  }
}

class _PotEndChip extends StatelessWidget {
  const _PotEndChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.75)),
      ),
      child: Text(
        'POT',
        style: GoogleFonts.manrope(
          color: AppColors.gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
