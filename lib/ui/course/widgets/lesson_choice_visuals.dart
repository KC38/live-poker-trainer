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
}

/// Detects the best interactive presentation for [activity].
SelectIdentifyPresentation resolveSelectIdentifyPresentation(
  CourseActivity activity,
) {
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
    this.glyphSize = 28,
  });

  final List<LessonSuitToken> tokens;
  final double glyphSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 72,
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  token.label,
                  style: GoogleFonts.manrope(
                    color: AppColors.cream,
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
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border, width: selected ? 2 : 1),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    MiniCard(card: cards[i], size: MiniCardSize.hero, scale: 0.85),
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
