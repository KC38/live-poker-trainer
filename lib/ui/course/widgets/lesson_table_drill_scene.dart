/// Full poker table for choice / number drills.
///
/// Every select / identify drill that used to draw a standalone green panel
/// of answer tiles (SPR 4 / 2 / 8, Calling Station / Nit, …) now draws the
/// same six-max table as hand steps: players around the ring, the pot in the
/// middle, stacks on the seats, and the answers in the action-button row
/// under the felt. [resolveLessonTableDrillSpec] reads the step's own copy
/// (stacks, pot, bets, street, position, player count) so the felt matches
/// the script; per-step overrides cover the few prompts plain parsing cannot.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_felt_layout.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

/// Six-max ring the drill table draws (hero + five opponents).
const int lessonTableDrillVillainCount = 5;

/// Postflop opponents still in the hand, in the order a drill picks them.
const List<String> _postflopVillainOrder = [
  'BB',
  'SB',
  'CO',
  'HJ',
  'UTG',
  'BTN',
];

/// What the drill felt shows. Money is in table chips (dollars at the
/// step's stakes); [showInBigBlinds] formats every amount as big blinds.
@immutable
class LessonTableDrillSpec {
  /// Creates a spec.
  const LessonTableDrillSpec({
    this.heroCodes = const <String>[],
    this.boardCodes = const <String>[],
    this.villainCodes = const <String>[],
    this.heroPosition = 'BTN',
    this.liveVillainPositions = const <String>[],
    this.postflop = false,
    this.potChips,
    this.heroStackChips,
    this.villainStackChips,
    this.betsByPosition = const <String, double>{},
    this.actionsByPosition = const <String, String>{},
    this.showInBigBlinds = false,
    this.hidePot = false,
    this.postBlinds = true,
    this.holeCardsDealt = true,
    this.smallBlind = 1,
    this.bigBlind = 2,
  });

  /// Face-up hero holes. Empty draws the hero's cards face down.
  final List<String> heroCodes;

  /// Community cards (never invented — only the step's own board).
  final List<String> boardCodes;

  /// Face-up cards for the first live opponent (showdown steps).
  final List<String> villainCodes;

  /// Hero seat on the six-max ring (UTG, HJ, CO, BTN, SB, BB).
  final String heroPosition;

  /// Opponents still in the hand. Every other opponent has folded.
  /// Preflop with no named actions, everyone is still live.
  final List<String> liveVillainPositions;

  /// Money is past preflop (no blinds in front of seats).
  final bool postflop;

  /// Total in the middle, including any [betsByPosition]. Null keeps the
  /// posted blinds preflop, or hides the pot postflop.
  final double? potChips;

  /// Hero chips behind. Null keeps 100bb.
  final double? heroStackChips;

  /// Opponent chips behind. Null keeps 100bb.
  final double? villainStackChips;

  /// Chips in front of a seat this street (position → chips, `You` = hero).
  final Map<String, double> betsByPosition;

  /// Last-action tag per seat (position → RAISE / CALL / BET / ALL-IN).
  final Map<String, String> actionsByPosition;

  /// Format stacks, bets, and pot in big blinds (`60 BB`), matching steps
  /// whose copy talks in bb.
  final bool showInBigBlinds;

  /// Hide the pot pill (the question asks for the pot total).
  final bool hidePot;

  /// Preflop blinds in front of SB / BB. False for steps set before the deal.
  final bool postBlinds;

  /// False draws the table before the deal: no cards on any seat.
  final bool holeCardsDealt;

  /// Stakes.
  final double smallBlind;

  /// Stakes.
  final double bigBlind;

  /// Felt dealer index so the hero (seat 0) sits in [heroPosition].
  int get dealerIndex => lessonSixMaxDealerIndexForHero(heroPosition);

  /// Felt seat index for [position] on this ring.
  int seatIndexOf(String position) => position == heroPosition
      ? 0
      : lessonSixMaxSeatIndex(position: position, dealerIndex: dealerIndex);

  /// Seats that have folded (all opponents not in [liveVillainPositions],
  /// once anyone is named live or the hand is past preflop).
  List<int> get foldedSeatIndexes {
    if (!postflop && liveVillainPositions.isEmpty) return const <int>[];
    final live = {for (final p in liveVillainPositions) seatIndexOf(p)};
    return [
      for (var i = 1; i <= lessonTableDrillVillainCount; i++)
        if (!live.contains(i)) i,
    ];
  }

  /// Street bets in felt seat order (hero at 0).
  List<double>? get streetBets {
    if (betsByPosition.isEmpty) return null;
    final bets = List<double>.filled(lessonTableDrillVillainCount + 1, 0);
    betsByPosition.forEach((position, chips) {
      bets[position == 'You' ? 0 : seatIndexOf(position)] = chips;
    });
    return bets;
  }

  /// Action tags in felt seat order.
  Map<int, String> get seatActionLabels => {
    for (final entry in actionsByPosition.entries)
      (entry.key == 'You' ? 0 : seatIndexOf(entry.key)): entry.value,
  };

  /// Amount as the felt formats it (`60 BB` or `$120`).
  String format(double chips) => ChipFormat.chips(
    chips,
    bigBlind,
    showInBigBlinds ? ChipDisplayMode.bb : ChipDisplayMode.dollars,
  );
}

/// One answer in the drill's action-button row.
@immutable
class LessonTableDrillOption {
  /// Creates an option.
  const LessonTableDrillOption({
    required this.label,
    required this.onTap,
    this.selected = false,
    this.highlighted = false,
    this.semanticsLabel,
  });

  /// Short button label (e.g. `SPR 4`, `Calling Station`).
  final String label;

  /// Grades this answer. Null when the row is locked.
  final VoidCallback? onTap;

  /// Learner picked this answer.
  final bool selected;

  /// SoftPulse cue (guided / after Hint).
  final bool highlighted;

  /// Screen-reader label when it differs from [label].
  final String? semanticsLabel;
}

String? _position(String raw) {
  final word = raw.trim().toLowerCase();
  return switch (word) {
    'utg' || 'under the gun' || 'early position' || 'ep' => 'UTG',
    'hj' || 'hijack' || 'mp' => 'HJ',
    'co' || 'cutoff' => 'CO',
    'btn' || 'button' => 'BTN',
    'sb' || 'small blind' => 'SB',
    'bb' || 'big blind' => 'BB',
    _ => null,
  };
}

final _posAlt =
    r'(UTG|HJ|CO|BTN|SB|BB|button|cutoff|hijack|small blind|big blind|early position)';

double? _num(String? raw) => raw == null ? null : double.tryParse(raw);

/// Per-step specs where the copy names a whole action line or a money
/// picture plain parsing cannot read safely.
LessonTableDrillSpec? _authoredDrillSpec(String id) {
  switch (id) {
    // Blinds 1/2. UTG opens to 6, BTN calls, BB calls. Pot now? — show the
    // chips in front of every seat, never the total (the answer).
    case 'act-03-01-01-guided':
      return const LessonTableDrillSpec(
        heroPosition: 'BTN',
        liveVillainPositions: ['UTG', 'BB'],
        betsByPosition: {'UTG': 6, 'You': 6, 'SB': 1, 'BB': 6},
        actionsByPosition: {'UTG': 'RAISE', 'You': 'CALL', 'BB': 'CALL'},
        hidePot: true,
      );
    // Pot is 20. Villain bets 10. — 20 already in the middle, their 10 out.
    case 'act-03-03-01-scaffolded':
      return const LessonTableDrillSpec(
        heroPosition: 'BB',
        liveVillainPositions: ['BTN'],
        postflop: true,
        potChips: 30,
        betsByPosition: {'BTN': 10},
        actionsByPosition: {'BTN': 'BET'},
      );
    // You are all-in for less; two big stacks keep betting.
    case 'act-01-05-01-checkpoint-side':
      return const LessonTableDrillSpec(
        heroPosition: 'BTN',
        liveVillainPositions: ['SB', 'BB'],
        postflop: true,
        heroStackChips: 0,
        villainStackChips: 160,
        potChips: 120,
        actionsByPosition: {'You': 'ALL-IN', 'SB': 'BET', 'BB': 'CALL'},
      );
    // Tap when the blinds go in — table before the deal: no blinds, no cards.
    case 'act-01-01-03-unguided-when':
      return const LessonTableDrillSpec(
        postBlinds: false,
        holeCardsDealt: false,
        hidePot: true,
      );
    // Flop betting is live. Tap when this street ends.
    case 'act-01-04-01-unguided-end':
      return const LessonTableDrillSpec(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        heroPosition: 'BB',
        liveVillainPositions: ['BTN'],
        postflop: true,
        potChips: 15,
        betsByPosition: {'BTN': 4},
        actionsByPosition: {'BTN': 'BET'},
      );
    // "4-bet pot 100bb" names the starting depth, not the pot size.
    case 'act-07-04-01-unguided':
      return const LessonTableDrillSpec(
        liveVillainPositions: ['BB'],
        postflop: true,
        heroStackChips: 200,
        villainStackChips: 200,
        showInBigBlinds: true,
      );
  }
  return null;
}

/// Reads a drill's felt from its own copy (prompt + scene caption + cards).
///
/// * Stacks: `Stack 60bb`, `Effective stack 80bb`, `You 120bb, villain 55bb`,
///   `Hero 140bb`, `200bb effective`, `250bb.`, `You have 200 chips`.
/// * Pot: `pot 15bb`, `Pot 16`, `Pot is 20` (same unit as the stacks).
/// * Stakes: `Blinds 2/5`.
/// * Players: `Four-way`, `three-way`, `multiway`, `heads-up` / `HU`.
/// * Street: a dealt board, a pot, or flop / turn / river / barrel words put
///   the hand past preflop (blinds pulled in, other seats folded).
/// * Hero seat: `on BTN`, `in SB`, `BTN steal`, `early position`.
LessonTableDrillSpec resolveLessonTableDrillSpec({
  required CourseActivity activity,
  List<String> heroCodes = const <String>[],
  List<String> boardCodes = const <String>[],
  List<String> villainCodes = const <String>[],
  int villainSeatCount = 1,
  String? caption,
}) {
  final authored = _authoredDrillSpec(activity.id);
  if (authored != null) return authored;
  final prompt = activity.prompt ?? '';
  final text = '$prompt ${caption ?? ''}';
  final lower = text.toLowerCase();
  final bbMode = RegExp(r'\d\s*bb\b', caseSensitive: false).hasMatch(text);

  var smallBlind = 1.0;
  var bigBlind = 2.0;
  final stakes = RegExp(
    r'blinds\s*(\d+)\s*/\s*(\d+)',
    caseSensitive: false,
  ).firstMatch(text);
  if (stakes != null) {
    smallBlind = _num(stakes.group(1))!;
    bigBlind = _num(stakes.group(2))!;
  }
  double chipsOf(double value, {required bool bb}) =>
      bb ? value * bigBlind : value;

  double? heroStack;
  double? villainStack;
  final hero = RegExp(
    r'\b(?:you|hero)\s*(?:have\s*|has\s*)?(\d+(?:\.\d+)?)\s*bb\b',
    caseSensitive: false,
  ).firstMatch(text);
  final villain = RegExp(
    r'\bvillain\s*(?:has\s*)?(\d+(?:\.\d+)?)\s*bb\b',
    caseSensitive: false,
  ).firstMatch(text);
  if (hero != null) heroStack = chipsOf(_num(hero.group(1))!, bb: true);
  if (villain != null) {
    villainStack = chipsOf(_num(villain.group(1))!, bb: true);
  }
  final shared = RegExp(
    r'(?:effective\s+stack|shorter\s+stack|\bstacks?)\s*(?:is\s*)?(\d+(?:\.\d+)?)\s*bb\b'
    r'|(\d+(?:\.\d+)?)\s*bb\s*(?:effective|deep)\b'
    r'|^\s*(\d+(?:\.\d+)?)\s*bb\b',
    caseSensitive: false,
  ).firstMatch(prompt);
  if (shared != null && hero == null && villain == null) {
    final v = _num(shared.group(1) ?? shared.group(2) ?? shared.group(3))!;
    heroStack = villainStack = chipsOf(v, bb: true);
  }
  final chips = RegExp(
    r'(?:you have|buy in for)\s*(\d+)\s*chips',
    caseSensitive: false,
  ).firstMatch(text);
  if (chips != null) heroStack = _num(chips.group(1));

  double? pot;
  final potMatch = RegExp(
    r'\bpot\s*(?:is\s*|of\s*)?(\d+(?:\.\d+)?)\s*(bb)?\b',
    caseSensitive: false,
  ).firstMatch(prompt);
  if (potMatch != null) {
    pot = chipsOf(
      _num(potMatch.group(1))!,
      bb: potMatch.group(2) != null || bbMode,
    );
  }

  var live = villainCodes.length >= 2 ? 1 : villainSeatCount.clamp(1, 5);
  if (RegExp(r'\bfour-way\b').hasMatch(lower)) live = 3;
  if (RegExp(r'\bthree-way\b').hasMatch(lower)) live = 2;
  if (RegExp(r'\bmultiway\b').hasMatch(lower) && live < 2) live = 2;
  if (RegExp(r'\b(heads-up|hu)\b').hasMatch(lower)) live = 1;

  final postflop =
      boardCodes.isNotEmpty ||
      pot != null ||
      RegExp(
        r'\b(flop|turn|rivers?|streets?|c-bets?|barrel\w*|check-raise\w*|donk\w*|spr|showdown|bomb|overbet)\b',
      ).hasMatch(lower);

  String heroPosition = 'BTN';
  final seat = RegExp(
    '\\b(?:on|in|from|at)\\s+(?:the\\s+)?$_posAlt\\b|\\b$_posAlt\\s+steal\\b',
    caseSensitive: false,
  ).firstMatch(text);
  final named = seat == null
      ? null
      : _position(seat.group(1) ?? seat.group(2)!);
  if (named != null) {
    heroPosition = named;
  } else if (lower.contains('early position')) {
    heroPosition = 'UTG';
  }

  final villains = <String>[
    for (final p in _postflopVillainOrder)
      if (p != heroPosition) p,
  ].take(live).toList(growable: false);

  return LessonTableDrillSpec(
    heroCodes: heroCodes,
    boardCodes: boardCodes,
    villainCodes: villainCodes,
    heroPosition: heroPosition,
    liveVillainPositions: postflop ? villains : const <String>[],
    postflop: postflop,
    potChips: pot,
    heroStackChips: heroStack,
    villainStackChips: villainStack,
    showInBigBlinds: bbMode && chips == null,
    smallBlind: smallBlind,
    bigBlind: bigBlind,
  );
}

/// Six-max table + action-button row for a choice / number drill.
class LessonTableDrillScene extends StatelessWidget {
  /// Creates the scene.
  const LessonTableDrillScene({
    super.key,
    required this.spec,
    required this.options,
    this.enabled = true,
    this.semanticsLabel,
    this.actions,
  });

  /// What the felt shows.
  final LessonTableDrillSpec spec;

  /// Answers, in display order.
  final List<LessonTableDrillOption> options;

  /// False after an answer locks the step.
  final bool enabled;

  /// Screen-reader summary of the drill.
  final String? semanticsLabel;

  /// Custom answer row (e.g. tappable out cards) instead of [options].
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final preset = TableFeaturesScope.of(context);
    final postflopNoBoard = spec.postflop && spec.boardCodes.isEmpty;
    final features = preset.copyWith(
      boardSlots: false,
      // No dealt board: a PREFLOP street tag would contradict a flop spot.
      street: postflopNoBoard ? false : null,
      pot: !(spec.hidePot || (spec.postflop && spec.potChips == null)),
      stacks: true,
      positions: true,
      bets: true,
      actions: true,
      opponentCards: spec.holeCardsDealt ? null : false,
    );
    final bets = spec.streetBets;
    final table = LessonTableStage(
      heroCodes: spec.heroCodes,
      boardCodes: spec.boardCodes,
      villainCodes: spec.villainCodes,
      villainCount: lessonTableDrillVillainCount,
      heroFaceUp: spec.heroCodes.isNotEmpty,
      dealerIndex: spec.dealerIndex,
      positionLabels: false,
      smallBlind: spec.smallBlind,
      bigBlind: spec.bigBlind,
      postSmallBlind: spec.postBlinds && !spec.postflop,
      postBigBlind: spec.postBlinds && !spec.postflop,
      streetBets: bets ?? (spec.postflop ? const <double>[] : null),
      potTotal: spec.potChips ?? (spec.postflop ? 0 : null),
      heroStackChips: spec.heroStackChips,
      villainStackChips: spec.villainStackChips,
      foldedSeatIndexes: spec.foldedSeatIndexes,
      seatActionLabels: spec.seatActionLabels,
      features: features,
      chipDisplayMode: spec.showInBigBlinds
          ? ChipDisplayMode.bb
          : ChipDisplayMode.dollars,
      showHoleCardBacks: spec.holeCardsDealt,
      enabled: enabled,
    );
    return Semantics(
      label: semanticsLabel,
      child: Column(
        key: const ValueKey<String>('lesson-table-drill-scene'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: table),
          const SizedBox(height: 8),
          actions ??
              LessonTableDrillActionRow(options: options, enabled: enabled),
        ],
      ),
    );
  }
}

/// Answers drawn like the hand dock (FOLD / CALL / RAISE row): equal live
/// chrome so no tile spoils the answer; up to three per row.
class LessonTableDrillActionRow extends StatelessWidget {
  /// Creates the row.
  const LessonTableDrillActionRow({
    super.key,
    required this.options,
    this.enabled = true,
  });

  /// Answers.
  final List<LessonTableDrillOption> options;

  /// False when locked.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final perRow = options.length == 4 ? 2 : 3;
    final rows = <List<int>>[];
    for (var i = 0; i < options.length; i += perRow) {
      rows.add([for (var j = i; j < i + perRow && j < options.length; j++) j]);
    }
    return Column(
      key: const ValueKey<String>('lesson-table-drill-actions'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var k = 0; k < rows[r].length; k++) ...[
                  if (k > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _DrillButton(
                      key: ValueKey<String>('drill-option-${rows[r][k]}'),
                      option: options[rows[r][k]],
                      enabled: enabled,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DrillButton extends StatelessWidget {
  const _DrillButton({super.key, required this.option, required this.enabled});

  final LessonTableDrillOption option;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final live = enabled && option.onTap != null;
    final button = Semantics(
      button: true,
      selected: option.selected,
      excludeSemantics: true,
      label: option.semanticsLabel ?? option.label,
      child: Material(
        color: AppColors.surfaceMuted.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: live ? option.onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: option.selected
                    ? AppColors.selectionGlow
                    : AppColors.feltBorder,
                width: option.selected ? 2.2 : 1.4,
              ),
            ),
            child: Text(
              option.label.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                color: AppColors.cream,
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
                height: 1.15,
              ),
            ),
          ),
        ),
      ),
    );
    return GlowHighlight(
      active: option.highlighted && live && !option.selected,
      borderRadius: 12,
      child: button,
    );
  }
}
