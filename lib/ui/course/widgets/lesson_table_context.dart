/// Compact felt + cards context for lesson select/identify activities.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';

/// Tappable regions on the lesson mini-table.
enum LessonTableRegion {
  /// Hero hole cards.
  hero,

  /// Community board.
  board,

  /// Face-down villain seat(s).
  villain,

  /// Folded/muck pile.
  muck,

  /// Dealer button / dealer role chip.
  dealer,
}

/// Authored (or inferred) mini-table scene for a lesson activity.
class LessonTableScene {
  /// Creates a scene.
  const LessonTableScene({
    required this.heroCodes,
    this.boardCodes = const <String>[],
    this.villainSeatCount = 1,
    this.highlight = LessonTableHighlight.none,
    this.caption,
    this.showMuck = false,
    this.showDealerChip = false,
  });

  /// Face-up hero hole cards (e.g. `Ah`, `Kd`).
  final List<String> heroCodes;

  /// Optional community cards in the middle.
  final List<String> boardCodes;

  /// How many other seats show face-down hole cards.
  final int villainSeatCount;

  /// Soft emphasis for guided teaching (pulse only — never a spoiler label).
  final LessonTableHighlight highlight;

  /// Optional short non-spoiling label under the hero rail (e.g. `You`).
  final String? caption;

  /// Show a small muck pile distractor.
  final bool showMuck;

  /// Show a dealer chip distractor (privacy questions).
  final bool showDealerChip;
}

/// Which region of the mini-table should read as the teaching target.
enum LessonTableHighlight { none, hero, board }

final _cardToken = RegExp(r'\b([2-9TJQKA][shdc])\b', caseSensitive: false);

/// Resolves a table scene for activities that reference the felt / hole cards.
///
/// Returns null when the activity is a pure text quiz (e.g. suit names).
LessonTableScene? resolveLessonTableScene(CourseActivity activity) {
  if (activity.renderer != ActivityRenderer.selectIdentify &&
      activity.renderer != ActivityRenderer.coachDialogue) {
    return null;
  }

  switch (activity.id) {
    case 'act-01-01-01-guided-find-holes':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 1,
        // Soft pulse only — no spoiler caption.
        highlight: LessonTableHighlight.hero,
        caption: 'You',
      );
    case 'act-01-01-01-scaffolded-private':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 2,
        highlight: LessonTableHighlight.none,
        caption: 'You',
        showDealerChip: true,
      );
    case 'act-01-01-01-unguided-mix':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.none,
        caption: 'You',
        showMuck: true,
      );
    case 'act-01-01-01-checkpoint-table':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        boardCodes: ['Qs', 'Jh', '2c'],
        villainSeatCount: 3,
        highlight: LessonTableHighlight.none,
        caption: 'You',
      );
    case 'act-01-01-01-explain-hole-cards':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kd'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.hero,
        caption: 'You',
      );
    case 'act-01-01-02-unguided-suited':
      return const LessonTableScene(
        heroCodes: ['Ah', 'Kh'],
        villainSeatCount: 0,
        highlight: LessonTableHighlight.hero,
        caption: 'You',
      );
    case 'act-01-01-02-checkpoint-pair':
      return const LessonTableScene(
        heroCodes: ['9h', '9d'],
        villainSeatCount: 1,
        highlight: LessonTableHighlight.hero,
        caption: 'You',
      );
  }

  final hero = <String>[];
  final board = <String>[];
  for (final choice in activity.choices) {
    final codes = _cardToken
        .allMatches(choice.label)
        .map((m) => m.group(1)!)
        .toList(growable: false);
    if (codes.length >= 2 &&
        (choice.label.toLowerCase().contains('you') ||
            choice.label.toLowerCase().contains('front') ||
            choice.label.toLowerCase().contains('seat') ||
            choice.id.contains('hero') ||
            choice.id.contains('hole'))) {
      hero
        ..clear()
        ..addAll(codes.take(2));
    } else if (codes.length >= 3 &&
        (choice.label.toLowerCase().contains('middle') ||
            choice.label.toLowerCase().contains('flop') ||
            choice.label.toLowerCase().contains('board') ||
            choice.id.contains('flop') ||
            choice.id.contains('board'))) {
      board
        ..clear()
        ..addAll(codes.take(5));
    }
  }

  final prompt = (activity.prompt ?? activity.accessibilityText).toLowerCase();
  final wantsTable =
      prompt.contains('hole') ||
      prompt.contains('table') ||
      prompt.contains('community') ||
      prompt.contains('board') ||
      prompt.contains('seat') ||
      activity.objectives.any(
        (o) =>
            o.toLowerCase().contains('hole') ||
            o.toLowerCase().contains('community') ||
            o.toLowerCase().contains('table'),
      );

  if (!wantsTable && hero.isEmpty && board.isEmpty) return null;

  return LessonTableScene(
    heroCodes: hero.isEmpty ? const ['Ah', 'Kd'] : List.unmodifiable(hero),
    boardCodes: List.unmodifiable(board),
    villainSeatCount:
        prompt.contains('dealer') || prompt.contains('who can see')
            ? 2
            : (board.isEmpty ? 1 : 1),
    highlight:
        prompt.contains('community') || prompt.contains('board')
            ? LessonTableHighlight.board
            : LessonTableHighlight.hero,
    caption: 'You',
  );
}

/// Maps a table region tap onto an authored choice id for Your two cards.
String? mapTableRegionToChoiceId({
  required String activityId,
  required LessonTableRegion region,
  required List<CourseChoice> choices,
}) {
  final ids = {for (final c in choices) c.id};
  String? pick(String id) => ids.contains(id) ? id : null;

  switch (activityId) {
    case 'act-01-01-01-guided-find-holes':
      return switch (region) {
        LessonTableRegion.hero => pick('choice-hero-holes'),
        LessonTableRegion.board => pick('choice-board'),
        LessonTableRegion.villain => pick('choice-villain'),
        _ => null,
      };
    case 'act-01-01-01-scaffolded-private':
      // Tap what only you can see / who sees your holes.
      return switch (region) {
        LessonTableRegion.hero => pick('choice-only-you'),
        LessonTableRegion.villain || LessonTableRegion.board =>
          pick('choice-whole-table'),
        LessonTableRegion.dealer => pick('choice-dealer-only'),
        _ => null,
      };
    case 'act-01-01-01-unguided-mix':
      return switch (region) {
        LessonTableRegion.board => pick('choice-flop'),
        LessonTableRegion.hero => pick('choice-hero-again'),
        LessonTableRegion.muck || LessonTableRegion.villain =>
          pick('choice-muck'),
        _ => null,
      };
    case 'act-01-01-01-checkpoint-table':
      return switch (region) {
        LessonTableRegion.hero => pick('choice-checkpoint-holes'),
        LessonTableRegion.board => pick('choice-checkpoint-board'),
        // Tapping other face-up-looking areas / villains ≈ "everything I see".
        LessonTableRegion.villain => pick('choice-checkpoint-all'),
        _ => null,
      };
  }
  return null;
}

/// Whether this activity is answered by tapping the mini-table.
bool isTableRegionTapActivity(CourseActivity activity) {
  return activity.id.startsWith('act-01-01-01-') &&
      activity.renderer == ActivityRenderer.selectIdentify;
}

/// Felt strip with hero holes, optional board, and face-down seats.
class LessonTableContext extends StatelessWidget {
  /// Creates the table context chrome.
  const LessonTableContext({
    super.key,
    required this.scene,
    this.selectedRegion,
    this.onRegionTap,
    this.enabled = true,
    this.showSoftPulse = false,
  });

  final LessonTableScene scene;

  /// Currently selected region (gold border).
  final LessonTableRegion? selectedRegion;

  /// When set, table regions are tappable answers.
  final ValueChanged<LessonTableRegion>? onRegionTap;

  final bool enabled;

  /// Guided soft pulse on [scene.highlight] when nothing is selected yet.
  final bool showSoftPulse;

  bool get _interactive => onRegionTap != null;

  @override
  Widget build(BuildContext context) {
    final hero = scene.heroCodes
        .map(CardModel.fromCode)
        .toList(growable: false);
    final board = scene.boardCodes
        .map(CardModel.fromCode)
        .toList(growable: false);
    final pulseHero =
        showSoftPulse &&
        selectedRegion == null &&
        scene.highlight == LessonTableHighlight.hero;
    final pulseBoard =
        showSoftPulse &&
        selectedRegion == null &&
        scene.highlight == LessonTableHighlight.board;

    return Semantics(
      label: _semanticsLabel(hero, board),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
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
            if (scene.villainSeatCount > 0 || scene.showDealerChip) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var i = 0; i < scene.villainSeatCount; i++)
                    _TappableRegion(
                      label: 'Other seat face-down cards',
                      selected: selectedRegion == LessonTableRegion.villain,
                      enabled: enabled && _interactive,
                      onTap:
                          _interactive
                              ? () => onRegionTap!(LessonTableRegion.villain)
                              : null,
                      child: const _FaceDownPair(),
                    ),
                  if (scene.showDealerChip)
                    _TappableRegion(
                      label: 'Dealer',
                      selected: selectedRegion == LessonTableRegion.dealer,
                      enabled: enabled && _interactive,
                      onTap:
                          _interactive
                              ? () => onRegionTap!(LessonTableRegion.dealer)
                              : null,
                      child: const _DealerChip(),
                    ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            if (board.isNotEmpty) ...[
              _TappableRegion(
                label:
                    'Board ${board.map((c) => c.display).join(' ')}',
                selected: selectedRegion == LessonTableRegion.board,
                highlighted: pulseBoard,
                enabled: enabled && _interactive,
                onTap:
                    _interactive
                        ? () => onRegionTap!(LessonTableRegion.board)
                        : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < board.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        MiniCard(card: board[i], size: MiniCardSize.small),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            _TappableRegion(
              label: 'Your hole cards ${hero.map((c) => c.display).join(' ')}',
              selected: selectedRegion == LessonTableRegion.hero,
              highlighted: pulseHero,
              enabled: enabled && _interactive,
              onTap:
                  _interactive
                      ? () => onRegionTap!(LessonTableRegion.hero)
                      : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    Text(
                      scene.caption ?? 'You',
                      style: GoogleFonts.manrope(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < hero.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          MiniCard(card: hero[i], size: MiniCardSize.hero),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (scene.showMuck) ...[
              const SizedBox(height: 12),
              _TappableRegion(
                label: 'Muck pile',
                selected: selectedRegion == LessonTableRegion.muck,
                enabled: enabled && _interactive,
                onTap:
                    _interactive
                        ? () => onRegionTap!(LessonTableRegion.muck)
                        : null,
                child: const _MuckPile(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _semanticsLabel(List<CardModel> hero, List<CardModel> board) {
    if (_interactive) {
      return 'Interactive poker table';
    }
    final heroText = hero.map((c) => c.display).join(' ');
    final parts = <String>['Your hole cards $heroText'];
    if (board.isNotEmpty) {
      parts.add('Board ${board.map((c) => c.display).join(' ')}');
    }
    if (scene.villainSeatCount > 0) {
      parts.add(
        '${scene.villainSeatCount} other '
        '${scene.villainSeatCount == 1 ? 'seat has' : 'seats have'} '
        'face-down hole cards',
      );
    }
    return parts.join('. ');
  }
}

class _TappableRegion extends StatelessWidget {
  const _TappableRegion({
    required this.label,
    required this.child,
    required this.selected,
    required this.enabled,
    this.highlighted = false,
    this.onTap,
  });

  final String label;
  final Widget child;
  final bool selected;
  final bool enabled;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final border =
        selected
            ? AppColors.gold
            : highlighted
            ? AppColors.gold.withValues(alpha: 0.55)
            : Colors.transparent;
    final fill =
        selected
            ? AppColors.gold.withValues(alpha: 0.2)
            : highlighted
            ? AppColors.gold.withValues(alpha: 0.12)
            : Colors.transparent;

    final framed = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: selected ? 2.2 : 1.4),
      ),
      child: child,
    );

    if (onTap == null) return framed;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: framed,
        ),
      ),
    );
  }
}

class _FaceDownPair extends StatelessWidget {
  const _FaceDownPair();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Seat',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CardBack(size: MiniCardSize.tiny),
            SizedBox(width: 3),
            CardBack(size: MiniCardSize.tiny),
          ],
        ),
      ],
    );
  }
}

class _DealerChip extends StatelessWidget {
  const _DealerChip();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Dealer',
          style: GoogleFonts.manrope(
            color: AppColors.slate,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cream,
            border: Border.all(color: AppColors.bgDark, width: 2),
          ),
          child: Text(
            'D',
            style: GoogleFonts.manrope(
              color: AppColors.bgDark,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _MuckPile extends StatelessWidget {
  const _MuckPile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: -0.18,
            child: const CardBack(size: MiniCardSize.tiny),
          ),
          Transform.translate(
            offset: const Offset(-8, 2),
            child: Transform.rotate(
              angle: 0.12,
              child: const CardBack(size: MiniCardSize.tiny),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Muck',
            style: GoogleFonts.manrope(
              color: AppColors.slate,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
