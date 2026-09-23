/// Street timeline + tap-to-order visuals for Streets and action order.
library;

import 'dart:math';

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
  return activity.id == 'act-01-04-01-scaffolded-order' ||
      activity.id == 'act-01-06-02-jump-order' ||
      activity.id == 'act-02-01-02-guided-pre' ||
      activity.id == 'act-02-01-02-scaffolded-post';
}

/// Explain-step demo: four streets progressing on a mini felt.
class StreetsTimelineDemo extends StatefulWidget {
  /// Creates the demo.
  const StreetsTimelineDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllStreetsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllStreetsTapped;

  static const streets = <({String title, String detail, List<String> board})>[
    (title: 'PREFLOP', detail: 'Holes only', board: <String>[]),
    (title: 'FLOP', detail: '3 cards', board: ['Qs', '7c', '2d']),
    (title: 'TURN', detail: '+1 card', board: ['Qs', '7c', '2d', 'Ah']),
    (title: 'RIVER', detail: '+1 card', board: ['Qs', '7c', '2d', 'Ah', '9s']),
  ];

  @override
  State<StreetsTimelineDemo> createState() => _StreetsTimelineDemoState();
}

class _StreetsTimelineDemoState extends State<StreetsTimelineDemo> {
  final Set<String> _tapped = <String>{};

  void _onTap(String title) {
    if (!widget.enabled || widget.onAllStreetsTapped == null) return;
    setState(() => _tapped.add(title));
    if (_tapped.length >= StreetsTimelineDemo.streets.length) {
      widget.onAllStreetsTapped!();
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
          for (var i = 0; i < StreetsTimelineDemo.streets.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _StreetLane(
              title: StreetsTimelineDemo.streets[i].title,
              detail: StreetsTimelineDemo.streets[i].detail,
              boardCodes: StreetsTimelineDemo.streets[i].board,
              step: i + 1,
              selected: _tapped.contains(StreetsTimelineDemo.streets[i].title),
              enabled: widget.interactive && widget.enabled,
              onPressed:
                  widget.interactive
                      ? () => _onTap(StreetsTimelineDemo.streets[i].title)
                      : null,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            widget.interactive
                ? 'Tap each street from preflop to river'
                : 'Match bets to leave each street',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

class _StreetLane extends StatelessWidget {
  const _StreetLane({
    required this.title,
    required this.detail,
    required this.boardCodes,
    required this.step,
    this.selected = false,
    this.enabled = false,
    this.onPressed,
  });

  final String title;
  final String detail;
  final List<String> boardCodes;
  final int step;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final border =
        selected ? AppColors.gold : AppColors.feltBorder.withValues(alpha: 0.7);
    final lane = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.bgDark.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: selected ? 2 : 1),
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
    if (onPressed == null) return lane;
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12),
          child: lane,
        ),
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
    this.expand = false,
    this.onPressed,
  });

  final String label;
  final String? badge;
  final bool selected;
  final bool enabled;
  final bool expand;
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
            width: expand ? double.infinity : 96,
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
    this.emphasizeDealer = true,
    this.onPressed,
  });

  final String label;
  final String? badge;
  final bool selected;
  final bool enabled;

  /// Gold dealer-chip chrome on BTN. Turn off in order quizzes so BTN is not
  /// mistaken for the next tap target.
  final bool emphasizeDealer;
  final VoidCallback? onPressed;

  String get _caption {
    switch (label.toUpperCase()) {
      case 'UTG':
        return 'Early';
      case 'HJ':
        return 'Mid';
      case 'CO':
        return 'Late';
      case 'BTN':
        return 'Dealer';
      case 'SB':
        return 'Posts 1';
      case 'BB':
        return 'Posts 2';
      default:
        return 'Seat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBtn = emphasizeDealer && label.toUpperCase() == 'BTN';
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

/// Explain-step demo: tap preflop seats left-of-BB in order (UTG → HJ → BTN).
class ActionOrderDemo extends StatefulWidget {
  /// Creates the demo.
  const ActionOrderDemo({
    super.key,
    this.interactive = false,
    this.enabled = false,
    this.onAllSeatsTapped,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllSeatsTapped;

  static const seats = <({String label, String detail})>[
    (label: 'UTG', detail: 'Left of BB'),
    (label: 'HJ', detail: 'Next'),
    (label: 'BTN', detail: 'Last preflop'),
  ];

  @override
  State<ActionOrderDemo> createState() => _ActionOrderDemoState();
}

class _ActionOrderDemoState extends State<ActionOrderDemo> {
  final List<String> _ordered = <String>[];

  static const _correct = ['UTG', 'HJ', 'BTN'];

  late final List<({String label, String detail})> _palette = () {
    final seats = List<({String label, String detail})>.of(ActionOrderDemo.seats);
    // Stable shuffle so rebuilds keep palette order; never leave authored order.
    seats.shuffle(Random(0xAC70));
    if (seats[0].label == ActionOrderDemo.seats[0].label &&
        seats[1].label == ActionOrderDemo.seats[1].label) {
      final tmp = seats[0];
      seats[0] = seats[2];
      seats[2] = tmp;
    }
    return List<({String label, String detail})>.unmodifiable(seats);
  }();

  void _onTap(String label) {
    if (!widget.enabled || widget.onAllSeatsTapped == null) return;
    if (_ordered.contains(label)) return;
    final nextIndex = _ordered.length;
    if (nextIndex >= _correct.length || _correct[nextIndex] != label) {
      return;
    }
    setState(() => _ordered.add(label));
    if (_ordered.length >= _correct.length) {
      widget.onAllSeatsTapped!();
    }
  }

  String? get _nextCorrect {
    final nextIndex = _ordered.length;
    if (nextIndex >= _correct.length) return null;
    return _correct[nextIndex];
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextCorrect;
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
            'Preflop order after the blinds',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final seat in _palette)
                _SoftPulseTarget(
                  active:
                      widget.interactive &&
                      widget.enabled &&
                      next == seat.label,
                  child: SeatOrderTile(
                    label: seat.label,
                    badge:
                        _ordered.contains(seat.label)
                            ? '${_ordered.indexOf(seat.label) + 1}'
                            : null,
                    selected: _ordered.contains(seat.label),
                    emphasizeDealer: false,
                    enabled:
                        widget.interactive &&
                        widget.enabled &&
                        !_ordered.contains(seat.label),
                    onPressed:
                        widget.interactive
                            ? () => _onTap(seat.label)
                            : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Postflop starts left of the button',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.interactive
                ? (next == null ? 'UTG → HJ → BTN' : 'Tap $next next')
                : 'Left of BB preflop · left of button postflop',
            style: GoogleFonts.manrope(
              color: AppColors.gold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
    if (widget.interactive) return child;
    return ExcludeSemantics(child: child);
  }
}

/// Soft gold pulse around the next correct seat in [ActionOrderDemo].
class _SoftPulseTarget extends StatefulWidget {
  const _SoftPulseTarget({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  State<_SoftPulseTarget> createState() => _SoftPulseTargetState();
}

class _SoftPulseTargetState extends State<_SoftPulseTarget>
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
  void didUpdateWidget(covariant _SoftPulseTarget oldWidget) {
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
                color: AppColors.gold.withValues(alpha: glow * 0.55),
                blurRadius: 10 + (_pulse.value * 6),
                spreadRadius: 0.4,
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
