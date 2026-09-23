/// Visual parsers/widgets for interactive select/identify choices.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/widgets/mini_card.dart';

final _cardCodeToken = RegExp(r'\b([2-9TJQKA][shdc])\b', caseSensitive: false);

/// Tokens that map to a suit glyph (or decoy).
enum LessonSuitToken {
  hearts('h', '♥', 'Hearts'),
  diamonds('d', '♦', 'Diamonds'),
  clubs('c', '♣', 'Clubs'),
  spades('s', '♠', 'Spades'),
  stars('x', '★', 'Stars');

  const LessonSuitToken(this.code, this.glyph, this.label);
  final String code;
  final String glyph;
  final String label;

  bool get isReal => this != LessonSuitToken.stars;

  Color get color => switch (this) {
    LessonSuitToken.hearts => AppColors.hearts,
    LessonSuitToken.diamonds => AppColors.diamonds,
    LessonSuitToken.clubs => AppColors.clubs,
    LessonSuitToken.spades => AppColors.spades,
    LessonSuitToken.stars => AppColors.goldMuted,
  };

  static LessonSuitToken? fromWord(String raw) {
    final word = raw.trim().toLowerCase();
    return switch (word) {
      'heart' || 'hearts' || 'h' || '♥' => LessonSuitToken.hearts,
      'diamond' || 'diamonds' || 'd' || '♦' => LessonSuitToken.diamonds,
      'club' || 'clubs' || 'c' || '♣' => LessonSuitToken.clubs,
      'spade' || 'spades' || 's' || '♠' => LessonSuitToken.spades,
      'star' || 'stars' || '★' => LessonSuitToken.stars,
      _ => null,
    };
  }
}

/// How a select/identify activity should present its choices.
enum SelectIdentifyPresentation {
  /// Plain text buttons.
  text,

  /// Each choice is a set of suit glyphs.
  suitSets,

  /// Each choice is one or more hole-card faces.
  holeCards,

  /// Tap real suits (plus optional decoy) to assemble the answer.
  suitTapPicker,

  /// Tap regions on the mini-table (hole cards / board / seats).
  tableRegionTap,

  /// Tap a made-hand category shown as example cards.
  handCategoryTap,

  /// Tap who wins a visual showdown (you / them / chop).
  showdownTap,

  /// Tap five of seven cards that play in the made hand.
  bestFiveCardTap,
}

/// Detects the best interactive presentation for [activity].
SelectIdentifyPresentation resolveSelectIdentifyPresentation(
  CourseActivity activity,
) {
  if (activity.renderer == ActivityRenderer.selectIdentify &&
      (activity.id.startsWith('act-01-01-01-') ||
          activity.id.startsWith('act-01-01-03-') ||
          activity.id.startsWith('act-01-04-01-') ||
          activity.id.startsWith('act-01-05-01-') ||
          activity.id.startsWith('act-02-01-01-'))) {
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-01-02-01-scaffolded-spot') {
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-02-07-02-jump-family') {
    // Jump: see Ah5h on felt, tap the starting-hand family tile.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-01-02-02-unguided-board') {
    // Board-plays chop: tap the felt (board / you / them), not text tiles.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-02-07-01-checkpoint-habit') {
    // Live habit: tap Cover+wait / Act early / Leave bare on the felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-02-07-02-jump-pos') {
    // Jump: tap the seat before the button on the position felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-02-07-02-jump-stack') {
    // Jump: tap the effective (shorter) stack on the felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-03-01-01-guided') {
    // Table-read: tap the multiway pot total on the felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-03-01-01-scaffolded') {
    // Table-read: tap UTG (left of BB) on the nine-handed felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-03-01-01-unguided') {
    // Table-read: tap whether the verbal raise stands.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-03-01-01-checkpoint') {
    // Table-read: tap effective stack + pot on the felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-03-02-01-guided') {
    // Flop class: see board + holes, tap Made / Draw / Air.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id.startsWith('act-03-02-01-') &&
      activity.renderer == ActivityRenderer.selectIdentify) {
    // Flop class scaffolded / unguided / checkpoint: same teach-by-doing.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-03-03-01-guided') {
    // Outs: see board + holes, tap clean-out count.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-03-03-01-scaffolded') {
    // Outs: tap chips to call on the felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-03-03-01-unguided') {
    // Outs: tap Call / Fold / Raise category tiles (choice ids native).
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-03-03-01-checkpoint') {
    // Outs: deep NFD spot — tap the implied-odds edge on category tiles.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-03-05-01-guided' ||
      activity.id == 'act-03-05-01-checkpoint') {
    // Turn: see flop+turn board, tap brick / scare / plan tiles.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-03-06-01-checkpoint') {
    // River: see medium one-pair spot, tap the job (catch vs value vs air).
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-03-07-01-unguided' ||
      activity.id == 'act-03-07-01-checkpoint') {
    // Multiway: tap the speculative hand / observation tile.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-03-08-01-checkpoint') {
    // Leak repair: tap the seat-note tile.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-03-08-02-jump-table' ||
      activity.id == 'act-03-08-02-jump-class' ||
      activity.id == 'act-03-08-02-jump-leak') {
    // S3 jump: track / class / price on felt tiles.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id.startsWith('act-04-01-01-') &&
      activity.renderer == ActivityRenderer.selectIdentify) {
    // Ranges: tap range descriptions on seat/action felt.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-04-03-01-checkpoint') {
    // Multi-street plan: tap the branching plan on felt.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-04-04-01-unguided') {
    // Sizing: nearby soft grades vs exactness / junk sizes.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-04-06-01-guided') {
    // Observe: tap participation note on felt tiles.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-04-06-02-guided') {
    // Meet Calling Station: tap Station vs Nit on sticky evidence felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-04-06-02-scaffolded' ||
      activity.id == 'act-04-06-02-unguided' ||
      activity.id == 'act-04-06-02-checkpoint') {
    // Meet Calling Station: remaining steps tap answers on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-04-06-03-checkpoint') {
    // Adjust vs Station: cite fold tendency on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id.startsWith('act-04-07-01-') &&
      activity.renderer == ActivityRenderer.selectIdentify) {
    // Observe narrow players: tap notes on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-04-07-02-guided' ||
      activity.id == 'act-04-07-02-unguided' ||
      activity.id == 'act-04-07-02-checkpoint') {
    // Meet Nit: tap labels / model on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-04-07-03-checkpoint') {
    // Adjust vs Nit: cite strong range on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id.startsWith('act-04-08-01-') &&
      activity.renderer == ActivityRenderer.selectIdentify) {
    // Observe wild aggressors: tap notes on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-04-08-02-guided' ||
      activity.id == 'act-04-08-02-unguided' ||
      activity.id == 'act-04-08-02-checkpoint') {
    // Meet Maniac: tap labels / mix on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-04-08-03-checkpoint') {
    // Adjust vs Maniac: cite wide betting on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id.startsWith('act-04-09-01-') &&
      (activity.renderer == ActivityRenderer.selectIdentify ||
          activity.renderer == ActivityRenderer.playerReadClassify)) {
    // Confidence and samples: tap notes on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-04-10-02-jump-range' ||
      activity.id == 'act-04-10-02-jump-station' ||
      activity.id == 'act-04-10-02-jump-nit' ||
      activity.id == 'act-04-10-02-jump-maniac') {
    // S4 jump: tap answers on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-05-01-01-guided' ||
      activity.id == 'act-05-01-01-checkpoint') {
    // Multiway ranges: tap nut preference on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-05-02-01-guided' ||
      activity.id == 'act-05-02-01-unguided' ||
      activity.id == 'act-05-02-01-checkpoint') {
    // Deep stacks: tap theses on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-05-03-01-checkpoint') {
    // Implied odds: tap when IO rise on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-05-04-01-checkpoint') {
    // Thin value: tap what changes with the type on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-05-05-01-guided' ||
      activity.id == 'act-05-05-01-unguided' ||
      activity.id == 'act-05-05-01-checkpoint') {
    // Advanced lines: tap reads on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-05-06-01-guided' ||
      activity.id == 'act-05-06-01-unguided' ||
      activity.id == 'act-05-06-01-checkpoint') {
    // Line reading: tap range updates on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-05-07-01-guided' ||
      activity.id == 'act-05-07-01-scaffolded' ||
      activity.id == 'act-05-07-01-unguided' ||
      activity.id == 'act-05-07-01-checkpoint') {
    // Timing / sizing evidence: tap soft-evidence reads on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-05-08-01-guided' ||
      activity.id == 'act-05-08-01-scaffolded' ||
      activity.id == 'act-05-08-01-checkpoint') {
    // Table dynamics: tap stuck / gear / sample reads on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-05-09-01-guided' ||
      activity.id == 'act-05-09-01-scaffolded' ||
      activity.id == 'act-05-09-01-unguided' ||
      activity.id == 'act-05-09-01-checkpoint') {
    // Session discipline: tap stop / stakes / cash-out / edge on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-05-09-02-cp-multi' ||
      activity.id == 'act-05-09-02-cp-tell' ||
      activity.id == 'act-05-09-02-cp-stop') {
    // Section 5 exit: tap multiway / tell / stop reads on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-06-01-01-guided' ||
      activity.id == 'act-06-01-01-scaffolded' ||
      activity.id == 'act-06-01-01-checkpoint') {
    // Range / nut advantage: tap who owns the edge on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-06-02-01-guided' ||
      activity.id == 'act-06-02-01-scaffolded' ||
      activity.id == 'act-06-02-01-unguided' ||
      activity.id == 'act-06-02-01-checkpoint') {
    // Equity realization: tap IP / discount / fold equity / levers on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-06-03-01-guided' ||
      activity.id == 'act-06-03-01-unguided' ||
      activity.id == 'act-06-03-01-checkpoint') {
    // Capped / uncapped ranges: tap line reads on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-06-04-01-guided' ||
      activity.id == 'act-06-04-01-unguided' ||
      activity.id == 'act-06-04-01-checkpoint') {
    // Polar vs merged: tap range-shape reads on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-06-05-01-guided' ||
      activity.id == 'act-06-05-01-unguided' ||
      activity.id == 'act-06-05-01-checkpoint') {
    // Overbets / geometry: tap polar candidates and plan reads on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-06-06-01-guided' ||
      activity.id == 'act-06-06-01-scaffolded' ||
      activity.id == 'act-06-06-01-unguided' ||
      activity.id == 'act-06-06-01-checkpoint') {
    // Blockers / unblockers: tap blocker reads on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-06-07-01-guided' ||
      activity.id == 'act-06-07-01-unguided' ||
      activity.id == 'act-06-07-01-checkpoint') {
    // Min-defense: tap continue / MDF stance reads on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-06-08-01-scaffolded' ||
      activity.id == 'act-06-08-01-unguided' ||
      activity.id == 'act-06-08-01-checkpoint') {
    // Mixed strategy: tap mix-reason reads on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-06-09-01-guided' ||
      activity.id == 'act-06-09-01-unguided' ||
      activity.id == 'act-06-09-01-checkpoint') {
    // 3-bet / 4-bet by depth: tap commitment / ego / SPR reads on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-06-10-01-scaffolded' ||
      activity.id == 'act-06-10-01-unguided' ||
      activity.id == 'act-06-10-01-checkpoint') {
    // Hard folds / coolers: tap cooler vs ego-call review labels on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id == 'act-06-11-01-guided' ||
      activity.id == 'act-06-11-01-scaffolded' ||
      activity.id == 'act-06-11-01-unguided' ||
      activity.id == 'act-06-11-01-checkpoint') {
    // Observe selective aggression: tap evidence notes on felt.
    return SelectIdentifyPresentation.tableRegionTap;
  }
  if (activity.id.startsWith('act-04-06-01-') &&
      activity.renderer == ActivityRenderer.selectIdentify) {
    // Observe sticky callers: tap notes on seat evidence felt.
    return SelectIdentifyPresentation.handCategoryTap;
  }
  if (activity.id == 'act-01-02-01-checkpoint-winner' ||
      activity.id == 'act-01-02-02-scaffolded-kicker') {
    return SelectIdentifyPresentation.showdownTap;
  }
  if (activity.id == 'act-01-02-02-guided-seven' ||
      activity.id == 'act-01-02-02-checkpoint-build') {
    return SelectIdentifyPresentation.bestFiveCardTap;
  }
  if (activity.id == 'act-01-01-02-guided-suits' ||
      activity.choices.any((c) => c.id == 'suits-full')) {
    return SelectIdentifyPresentation.suitTapPicker;
  }
  if (activity.choices.isNotEmpty &&
      activity.choices.every((c) => parseSuitTokens(c.label).isNotEmpty)) {
    return SelectIdentifyPresentation.suitSets;
  }
  if (activity.choices.isNotEmpty &&
      activity.choices.every((c) => parseCardCodes(c.label).length >= 2)) {
    return SelectIdentifyPresentation.holeCards;
  }
  return SelectIdentifyPresentation.text;
}

/// True when select/identify answers auto-submit (no Check dock).
bool isAutoSubmitSelectIdentify(CourseActivity activity) {
  // Teach-by-doing: hide Check for all single-choice identify shells.
  return activity.renderer == ActivityRenderer.selectIdentify ||
      activity.renderer == ActivityRenderer.playerReadClassify;
}

/// Parses suit words / glyphs from a choice label.
List<LessonSuitToken> parseSuitTokens(String label) {
  final parts = label
      .split(RegExp(r'[,+/|]| and ', caseSensitive: false))
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty);
  final tokens = <LessonSuitToken>[];
  for (final part in parts) {
    final token = LessonSuitToken.fromWord(part);
    if (token == null) return const [];
    tokens.add(token);
  }
  return tokens;
}

/// Parses poker card codes from a label (e.g. `Ah Kh`).
List<String> parseCardCodes(String label) {
  return _cardCodeToken
      .allMatches(label)
      .map((m) => m.group(1)!)
      .toList(growable: false);
}

/// Maps a suit-tap selection onto authored choice ids for the suits lesson.
String? mapSuitTapSelectionToChoiceId({
  required Set<LessonSuitToken> selected,
  required List<CourseChoice> choices,
}) {
  final ids = {for (final c in choices) c.id};
  final hasStar = selected.contains(LessonSuitToken.stars);
  final real = selected.where((t) => t.isReal).toSet();
  final allFour = {
    LessonSuitToken.hearts,
    LessonSuitToken.diamonds,
    LessonSuitToken.clubs,
    LessonSuitToken.spades,
  };

  if (hasStar) {
    if (ids.contains('suits-extra')) return 'suits-extra';
    return null;
  }
  if (real.length == 4 && real.containsAll(allFour)) {
    if (ids.contains('suits-full')) return 'suits-full';
    return null;
  }
  if (real.length == 3 &&
      real.containsAll({
        LessonSuitToken.hearts,
        LessonSuitToken.diamonds,
        LessonSuitToken.clubs,
      }) &&
      !real.contains(LessonSuitToken.spades)) {
    if (ids.contains('suits-missing')) return 'suits-missing';
    return null;
  }
  return null;
}

/// Whether the current suit-tap selection is ready to Check.
bool suitTapSelectionIsReady(Set<LessonSuitToken> selected) {
  if (selected.isEmpty) return false;
  if (selected.contains(LessonSuitToken.stars)) return true;
  final real = selected.where((t) => t.isReal).length;
  return real >= 3;
}

/// Row of suit glyphs for a suit-set choice.
class SuitGlyphRow extends StatelessWidget {
  /// Creates a suit glyph row.
  const SuitGlyphRow({
    super.key,
    required this.tokens,
    this.glyphSize = 24,
  });

  final List<LessonSuitToken> tokens;
  final double glyphSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final token in tokens)
          Text(
            token.glyph,
            style: TextStyle(
              color: token.color,
              fontSize: glyphSize,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
      ],
    );
  }
}

/// Selectable suit tile for the tap-picker teaching interaction.
class SuitTapTile extends StatelessWidget {
  /// Creates a suit tap tile.
  const SuitTapTile({
    super.key,
    required this.token,
    required this.selected,
    required this.enabled,
    required this.onPressed,
  });

  final LessonSuitToken token;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: token.label,
      child: Material(
        color:
            selected
                ? token.color.withValues(alpha: 0.22)
                : AppColors.surfaceMuted.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 64,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.gold : AppColors.slateDark,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  token.glyph,
                  style: TextStyle(
                    color: token.color,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  token.label,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
                    fontSize: 10,
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

/// Choice button that shows hole-card faces instead of prose.
class HoleCardChoiceButton extends StatelessWidget {
  /// Creates a hole-card choice.
  const HoleCardChoiceButton({
    super.key,
    required this.codes,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    this.accessibilityText,
    this.highlighted = false,
  });

  final List<String> codes;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;
  final String? accessibilityText;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final cards = <CardModel>[];
    for (final code in codes) {
      try {
        cards.add(CardModel.fromCode(code));
      } catch (_) {
        // Skip malformed codes; fall through to empty row.
      }
    }
    final border =
        selected
            ? AppColors.gold
            : highlighted
            ? AppColors.goldMuted
            : AppColors.slateDark;
    return Semantics(
      button: true,
      selected: selected,
      label: accessibilityText ?? codes.join(' '),
      child: AnimatedScale(
        scale: selected ? 1.015 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Material(
          color:
              selected
                  ? AppColors.gold.withValues(alpha: 0.22)
                  : highlighted
                  ? AppColors.gold.withValues(alpha: 0.08)
                  : AppColors.surfaceMuted.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border, width: selected ? 2 : 1),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    MiniCard(card: cards[i], size: MiniCardSize.hero),
                  ],
                  if (cards.isEmpty)
                    Text(
                      codes.join(' '),
                      style: GoogleFonts.manrope(
                        color: AppColors.cream,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Choice button with suit glyphs for suit-set answers.
class SuitSetChoiceButton extends StatelessWidget {
  /// Creates a suit-set choice.
  const SuitSetChoiceButton({
    super.key,
    required this.tokens,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onPressed,
    this.accessibilityText,
    this.highlighted = false,
  });

  final List<LessonSuitToken> tokens;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onPressed;
  final String? accessibilityText;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final border =
        selected
            ? AppColors.gold
            : highlighted
            ? AppColors.goldMuted
            : AppColors.slateDark;
    return Semantics(
      button: true,
      selected: selected,
      label: accessibilityText ?? label,
      child: AnimatedScale(
        scale: selected ? 1.015 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Material(
          color:
              selected
                  ? AppColors.gold.withValues(alpha: 0.22)
                  : highlighted
                  ? AppColors.gold.withValues(alpha: 0.08)
                  : AppColors.surfaceMuted.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: selected ? 2 : 1),
              ),
              child: SuitGlyphRow(tokens: tokens),
            ),
          ),
        ),
      ),
    );
  }
}
