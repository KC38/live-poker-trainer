/// Street timeline + tap-to-order visuals for Streets and action order.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';

/// Features for Streets explain / order on the full table.
TableFeatures get lessonStreetsTableFeatures => const TableFeatures(
  stacks: false,
  pot: false,
  street: false,
  blinds: false,
  positions: false,
  bets: false,
  actions: false,
  opponentCards: false,
  playerTypes: false,
  stats: false,
  boardSlots: true,
);

/// Board codes for a guided street sequence id.
List<String> lessonStreetBoardForId(String id) {
  return switch (id) {
    'st-pre' => const <String>[],
    'st-flop' => const ['Qs', '7c', '2d'],
    'st-turn' => const ['Qs', '7c', '2d', 'Ah'],
    'st-river' => const ['Qs', '7c', '2d', 'Ah', '9s'],
    _ => const <String>[],
  };
}

/// Full table: tap each street under the felt while the board advances.
class LessonStreetsExplainTable extends StatefulWidget {
  /// Creates the explain stage.
  const LessonStreetsExplainTable({
    super.key,
    required this.onAllStreetsTapped,
    this.enabled = true,
    this.showGuidance = true,
  });

  final VoidCallback? onAllStreetsTapped;
  final bool enabled;
  final bool showGuidance;

  @override
  State<LessonStreetsExplainTable> createState() =>
      _LessonStreetsExplainTableState();
}

class _LessonStreetsExplainTableState extends State<LessonStreetsExplainTable> {
  final Set<String> _tapped = <String>{};

  void _onTap(String title) {
    if (!widget.enabled || widget.onAllStreetsTapped == null) return;
    setState(() => _tapped.add(title));
    if (_tapped.length >= StreetsTimelineDemo.streets.length) {
      widget.onAllStreetsTapped!();
    }
  }

  String? get _nextStreet {
    for (final street in StreetsTimelineDemo.streets) {
      if (!_tapped.contains(street.title)) return street.title;
    }
    return null;
  }

  List<String> get _board {
    // Show the furthest street reached (or the next one while teaching).
    final next = _nextStreet;
    if (next != null) {
      for (final street in StreetsTimelineDemo.streets) {
        if (street.title == next) return street.board;
      }
    }
    return StreetsTimelineDemo.streets.last.board;
  }

  @override
  Widget build(BuildContext context) {
    final teaching = widget.enabled && widget.onAllStreetsTapped != null;
    final next = _nextStreet;
    return Column(
      key: const ValueKey<String>('streets-table'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LessonTableStage(
            heroCodes: const ['Ah', 'Kd'],
            boardCodes: _board,
            villainCount: 1,
            heroFaceUp: true,
            enabled: false,
            features: lessonStreetsTableFeatures,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: GlowHighlight.gutter,
          runSpacing: GlowHighlight.gutter,
          alignment: WrapAlignment.center,
          children: [
            for (final street in StreetsTimelineDemo.streets)
              GlowHighlight(
                active:
                    teaching &&
                    widget.showGuidance &&
                    next == street.title,
                child: _UnderFeltStreetChip(
                  label: street.title,
                  selected: _tapped.contains(street.title),
                  enabled: teaching,
                  onPressed: teaching ? () => _onTap(street.title) : null,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Full table: order streets under the felt while the board follows.
class LessonStreetsOrderTable extends StatelessWidget {
  /// Creates the order stage.
  ///
  /// [sequenceItems] is the answer key (chronological). [paletteItems] is the
  /// under-felt chip order — pass a shuffled copy so teach-by-doing stays real.
  const LessonStreetsOrderTable({
    super.key,
    required this.sequenceItems,
    required this.orderedIds,
    required this.onPick,
    List<({String id, String label})>? paletteItems,
    this.enabled = true,
    this.showGuidance = true,
  }) : paletteItems = paletteItems ?? sequenceItems;

  /// Chronological answer key (SoftPulse / board preview).
  final List<({String id, String label})> sequenceItems;

  /// Display order for remaining chips (shuffled when authored by the runner).
  final List<({String id, String label})> paletteItems;
  final List<String> orderedIds;
  final ValueChanged<String> onPick;
  final bool enabled;
  final bool showGuidance;

  @override
  Widget build(BuildContext context) {
    final remaining = [
      for (final item in paletteItems)
        if (!orderedIds.contains(item.id)) item,
    ];
    final nextId =
        showGuidance &&
                enabled &&
                orderedIds.length < sequenceItems.length
            ? sequenceItems[orderedIds.length].id
            : null;
    final previewId = nextId ??
        (orderedIds.isNotEmpty ? orderedIds.last : sequenceItems.first.id);
    return Column(
      key: const ValueKey<String>('streets-order-table'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LessonTableStage(
            heroCodes: const ['Ah', 'Kd'],
            boardCodes: lessonStreetBoardForId(previewId),
            villainCount: 1,
            heroFaceUp: true,
            enabled: false,
            features: lessonStreetsTableFeatures,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          key: const ValueKey<String>('street-order-palette'),
          spacing: GlowHighlight.gutter,
          runSpacing: GlowHighlight.gutter,
          alignment: WrapAlignment.center,
          children: [
            for (final item in remaining)
              GlowHighlight(
                active: showGuidance && enabled && item.id == nextId,
                child: _UnderFeltStreetChip(
                  label: item.label,
                  selected: false,
                  enabled: enabled,
                  onPressed: enabled ? () => onPick(item.id) : null,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _UnderFeltStreetChip extends StatelessWidget {
  const _UnderFeltStreetChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final border =
        selected ? AppColors.gold : AppColors.feltBorder.withValues(alpha: 0.7);
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.bgDark.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: selected ? 2 : 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: AppColors.cream,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
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
    this.height,
  });

  final bool interactive;
  final bool enabled;
  final VoidCallback? onAllStreetsTapped;

  /// Stage height when the lesson frame already owns the chrome.
  ///
  /// Null keeps the standalone teach shell at 58% of the screen.
  final double? height;

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

  String? get _nextStreet {
    for (final street in StreetsTimelineDemo.streets) {
      if (!_tapped.contains(street.title)) return street.title;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextStreet;
    // Keep densify after the last street while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    final feltHeight =
        widget.height ??
        (expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null);

    Widget laneAt(int i) {
      return GlowHighlight(
        active:
            widget.interactive &&
            widget.enabled &&
            next == StreetsTimelineDemo.streets[i].title,
        child: _StreetLane(
          title: StreetsTimelineDemo.streets[i].title,
          detail: StreetsTimelineDemo.streets[i].detail,
          boardCodes: StreetsTimelineDemo.streets[i].board,
          step: i + 1,
          selected: _tapped.contains(
            StreetsTimelineDemo.streets[i].title,
          ),
          densify: expandTeach,
          enabled: widget.interactive && widget.enabled,
          onPressed:
              widget.interactive
                  ? () => _onTap(StreetsTimelineDemo.streets[i].title)
                  : null,
        ),
      );
    }

    final lanes = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < StreetsTimelineDemo.streets.length; i++) ...[
          if (i > 0) SizedBox(height: expandTeach ? 14 : 8),
          laneAt(i),
        ],
      ],
    );
    // SoftPulse + Rex own the next-street cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Text(
              widget.interactive
                  ? 'Preflop → flop → turn → river'
                  : 'Match bets to leave each street',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: AppColors.gold,
                fontSize: expandTeach ? 16 : 12,
                fontWeight: FontWeight.w700,
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
          'Four streets of a hand',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 12),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                // Pack densified lanes into a wide intrinsic shell, then
                // contain-scale into the felt — fills tall-phone green
                // without RIVER overflowing at phone width.
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: max(
                      MediaQuery.sizeOf(context).width - 48,
                      420,
                    ),
                    child: lanes,
                  ),
                ),
              ),
            )
            : lanes,
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 12),
          cue,
        ],
      ],
    );
    final child = Container(
      key: const ValueKey('streets-timeline-felt'),
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

class _StreetLane extends StatelessWidget {
  const _StreetLane({
    required this.title,
    required this.detail,
    required this.boardCodes,
    required this.step,
    this.selected = false,
    this.densify = false,
    this.enabled = false,
    this.onPressed,
  });

  final String title;
  final String detail;
  final List<String> boardCodes;
  final int step;
  final bool selected;

  /// Tall-phone SoftPulse pack: larger lane so FittedBox contain can fill felt.
  final bool densify;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final border =
        selected ? AppColors.gold : AppColors.feltBorder.withValues(alpha: 0.7);
    final cardSize = densify ? MiniCardSize.small : MiniCardSize.tiny;
    final badge = densify ? 28.0 : 22.0;
    final titleW = densify ? 88.0 : 72.0;
    final radius = densify ? 14.0 : 12.0;
    final lane = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: densify ? 12 : 10,
        vertical: densify ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color:
            selected
                ? AppColors.gold.withValues(alpha: 0.18)
                : AppColors.bgDark.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: selected ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: badge,
            height: badge,
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
                fontSize: densify ? 13 : 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: densify ? 12 : 10),
          SizedBox(
            width: titleW,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: densify ? 15 : 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: densify ? 12 : 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: densify ? 10 : 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CardBack(size: cardSize),
                    SizedBox(width: densify ? 3 : 2),
                    CardBack(size: cardSize),
                    if (boardCodes.isNotEmpty) ...[
                      SizedBox(width: densify ? 10 : 8),
                      for (var i = 0; i < boardCodes.length; i++) ...[
                        if (i > 0) SizedBox(width: densify ? 3 : 2),
                        MiniCard(
                          card: CardModel.fromCode(boardCodes[i]),
                          size: cardSize,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
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
          borderRadius: BorderRadius.circular(radius),
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
              // Shrink-wrap so densify FittedBox can scale the pack.
              mainAxisSize: MainAxisSize.min,
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
                  mainAxisSize: MainAxisSize.min,
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
    this.densify = false,
    this.onPressed,
  });

  final String label;
  final String? badge;
  final bool selected;
  final bool enabled;

  /// Gold dealer-chip chrome on BTN. Turn off in order quizzes so BTN is not
  /// mistaken for the next tap target.
  final bool emphasizeDealer;

  /// Tall-phone SoftPulse pack: larger chip so FittedBox contain can fill felt.
  final bool densify;
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
    // Fixed densify footprint — FittedBox.contain scales the pack into the
    // teach shell. Avoid infinity/max-size (unbounded Wrap parents break).
    final tileW = densify ? 132.0 : 96.0;
    final chip = densify ? 64.0 : 36.0;
    final labelSize = densify ? 16.0 : 11.0;
    final captionSize = densify ? 13.0 : 11.0;
    final badgeSize = densify ? 14.0 : 11.0;
    final radius = densify ? 18.0 : 14.0;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected
            ? AppColors.gold.withValues(alpha: 0.22)
            : AppColors.feltDark.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            width: tileW,
            padding: EdgeInsets.fromLTRB(
              densify ? 12 : 8,
              densify ? 18 : 12,
              densify ? 12 : 8,
              densify ? 18 : 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: selected ? AppColors.gold : AppColors.feltBorder,
                width: selected ? 2 : 1.2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badge != null)
                  Text(
                    badge!,
                    style: GoogleFonts.manrope(
                      color: AppColors.gold,
                      fontSize: badgeSize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                Container(
                  width: chip,
                  height: chip,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isBtn
                        ? AppColors.gold.withValues(alpha: 0.35)
                        : AppColors.surfaceMuted.withValues(alpha: 0.55),
                    border: Border.all(
                      color: isBtn ? AppColors.gold : AppColors.slate,
                      width: densify ? 1.6 : 1,
                    ),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: GoogleFonts.manrope(
                      color: AppColors.cream,
                      fontSize: labelSize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(height: densify ? 10 : 6),
                Text(
                  _caption,
                  style: GoogleFonts.manrope(
                    color: AppColors.slate,
                    fontSize: captionSize,
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

/// Explain-step demo: tap preflop seats left-of-BB in order (UTG → HJ → CO → BTN).
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
    (label: 'CO', detail: 'Before BTN'),
    (label: 'BTN', detail: 'Last preflop'),
  ];

  @override
  State<ActionOrderDemo> createState() => _ActionOrderDemoState();
}

class _ActionOrderDemoState extends State<ActionOrderDemo> {
  final List<String> _ordered = <String>[];

  static const _correct = ['UTG', 'HJ', 'CO', 'BTN'];

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
    // Keep densify after the last seat while Continue shows — locking
    // `enabled` false must not collapse the teach shell into navy void.
    final expandTeach = widget.interactive;
    final feltHeight =
        expandTeach ? MediaQuery.sizeOf(context).height * 0.58 : null;
    final seats = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _palette.length; i++) ...[
          if (i > 0) SizedBox(width: GlowHighlight.gutter),
          GlowHighlight(
            active:
                widget.interactive &&
                widget.enabled &&
                next == _palette[i].label,
            child: SeatOrderTile(
              label: _palette[i].label,
              badge:
                  _ordered.contains(_palette[i].label)
                      ? '${_ordered.indexOf(_palette[i].label) + 1}'
                      : null,
              selected: _ordered.contains(_palette[i].label),
              emphasizeDealer: false,
              densify: expandTeach,
              enabled:
                  widget.interactive &&
                  widget.enabled &&
                  !_ordered.contains(_palette[i].label),
              onPressed:
                  widget.interactive
                      ? () => _onTap(_palette[i].label)
                      : null,
            ),
          ),
        ],
      ],
    );
    // SoftPulse + Rex own the next-seat cue while teaching. Show a summary
    // after all taps (or once locked under Nice! / Continue).
    final showCue = !widget.interactive || next == null || !widget.enabled;
    final cue =
        !showCue
            ? null
            : Container(
              width: expandTeach ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                horizontal: expandTeach ? 18 : 14,
                vertical: expandTeach ? 14 : 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.feltDark.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                widget.interactive
                    ? 'UTG → HJ → CO → BTN'
                    : 'Left of BB preflop · left of button postflop',
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
          'Preflop order after the blinds',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: expandTeach ? 15 : 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (!expandTeach) const SizedBox(height: 12),
        expandTeach
            ? Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                // Pack densified seats, then scale up into the felt — fills
                // tall-phone green without unbounded-max tile layout.
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: seats,
                ),
              ),
            )
            : seats,
        // SoftPulse + Rex own postflop teach — no felt line echoing Rex.
        if (cue != null) ...[
          if (!expandTeach) const SizedBox(height: 12),
          cue,
        ],
      ],
    );
    final child = Container(
      key: const ValueKey('action-order-felt'),
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
