/// Street timeline + tap-to-order visuals for Streets and action order.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';

/// Whether this order-sequence activity uses street progression tiles.
bool isStreetSequenceActivity(CourseActivity activity) {
  return activity.id == 'act-01-04-01-guided-streets';
}

/// Whether this order-sequence activity uses preflop seat tiles.
bool isSeatOrderSequenceActivity(CourseActivity activity) {
  return activity.id == 'act-01-04-01-scaffolded-order';
}

/// Explain-step demo: four streets progressing on a mini felt.
class StreetsTimelineDemo extends StatelessWidget {
  /// Creates the demo.
  const StreetsTimelineDemo({super.key});

  static const _streets = <({String title, String detail, List<String> board})>[
    (title: 'PREFLOP', detail: 'Holes only', board: <String>[]),
    (title: 'FLOP', detail: '3 cards', board: ['Qs', '7c', '2d']),
    (title: 'TURN', detail: '+1 card', board: ['Qs', '7c', '2d', 'Ah']),
    (title: 'RIVER', detail: '+1 card', board: ['Qs', '7c', '2d', 'Ah', '9s']),
  ];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
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
              'Four streets of a hand',
              style: GoogleFonts.manrope(
                color: AppColors.slate,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < _streets.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _StreetLane(
                title: _streets[i].title,
                detail: _streets[i].detail,
                boardCodes: _streets[i].board,
                step: i + 1,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Match bets to leave each street',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreetLane extends StatelessWidget {
  const _StreetLane({
    required this.title,
    required this.detail,
    required this.boardCodes,
    required this.step,
  });

  final String title;
  final String detail;
  final List<String> boardCodes;
  final int step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgDark.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.feltBorder.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.25),
              border: Border.all(color: AppColors.gold),
            ),
            child: Text(
              '$step',
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                const CardBack(size: MiniCardSize.tiny),
                const SizedBox(width: 2),
                const CardBack(size: MiniCardSize.tiny),
                if (boardCodes.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  for (var i = 0; i < boardCodes.length; i++) ...[
                    if (i > 0) const SizedBox(width: 2),
                    MiniCard(
                      card: CardModel.fromCode(boardCodes[i]),
                      size: MiniCardSize.tiny,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Visual for one street in tap-to-order.
class StreetOrderTile extends StatelessWidget {
  /// Creates a street tile.
  const StreetOrderTile({
    super.key,
    required this.label,
    this.badge,
    this.selected = false,
    this.enabled = true,
    this.onPressed,
  });

  final String label;
  final String? badge;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  List<String> get _board {
    switch (label.toLowerCase()) {
      case 'flop':
        return const ['Qs', '7c', '2d'];
      case 'turn':
        return const ['Qs', '7c', '2d', 'Ah'];
      case 'river':
        return const ['Qs', '7c', '2d', 'Ah', '9s'];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final board = _board;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? AppColors.gold.withValues(alpha: 0.22)
            : AppColors.feltDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 96,
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.gold : AppColors.feltBorder,
                width: selected ? 2 : 1.2,
              ),
            ),
            child: Column(
              children: [
                if (badge != null)
                  Text(
                    badge!,
                    style: GoogleFonts.manrope(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CardBack(size: MiniCardSize.tiny),
                    const SizedBox(width: 2),
                    const CardBack(size: MiniCardSize.tiny),
                  ],
                ),
                if (board.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final code in board)
                        MiniCard(
                          card: CardModel.fromCode(code),
                          size: MiniCardSize.tiny,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Visual for one preflop seat in tap-to-order.
class SeatOrderTile extends StatelessWidget {
  /// Creates a seat tile.
  const SeatOrderTile({
    super.key,
    required this.label,
    this.badge,
    this.selected = false,
    this.enabled = true,
    this.onPressed,
  });

  final String label;
  final String? badge;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  String get _caption {
    switch (label.toUpperCase()) {
      case 'UTG':
        return 'First';
      case 'HJ':
        return 'Middle';
      case 'BTN':
        return 'Last';
      default:
        return 'Seat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBtn = label.toUpperCase() == 'BTN';
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? AppColors.gold.withValues(alpha: 0.22)
            : AppColors.feltDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 96,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.gold : AppColors.feltBorder,
                width: selected ? 2 : 1.2,
              ),
            ),
            child: Column(
              children: [
                if (badge != null)
                  Text(
                    badge!,
                    style: GoogleFonts.manrope(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isBtn
                        ? AppColors.gold.withValues(alpha: 0.35)
                        : AppColors.surfaceMuted.withValues(alpha: 0.55),
                    border: Border.all(
                      color: isBtn ? AppColors.gold : AppColors.slate,
                    ),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: GoogleFonts.manrope(
                      color: AppColors.cream,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _caption,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
