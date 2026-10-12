/// Rewrites authored starting-hand names to match isomorphic lesson deals.
library;

import 'package:live_poker_trainer/core/constants/poker_constants.dart';
import 'package:live_poker_trainer/models/card_model.dart';

const Map<int, String> _rankWords = {
  14: 'ace',
  13: 'king',
  12: 'queen',
  11: 'jack',
  10: 'ten',
  9: 'nine',
  8: 'eight',
  7: 'seven',
  6: 'six',
  5: 'five',
  4: 'four',
  3: 'three',
  2: 'two',
};

/// English decade stems for low-rank compounds (`Seventy-two`, `eighty-five`).
///
/// Catalog Oops lines sometimes use this form instead of `seven-two`. Only
/// ranks 2–9 have decade words; broadway uses [_rankWords] alone.
const Map<int, String> _decadeWords = {
  9: 'ninety',
  8: 'eighty',
  7: 'seventy',
  6: 'sixty',
  5: 'fifty',
  4: 'forty',
  3: 'thirty',
  2: 'twenty',
};

/// Chart label for two hole codes (`K9s`, `ATo`, `QQ`).
String startingHandLabelFromCodes(List<String> hero) {
  if (hero.length < 2) return '';
  final a = CardModel.fromCode(hero[0]);
  final b = CardModel.fromCode(hero[1]);
  final high = a.rank >= b.rank ? a : b;
  final low = a.rank >= b.rank ? b : a;
  final highChar = PokerConstants.rankLabels[high.rank] ?? '?';
  final lowChar = PokerConstants.rankLabels[low.rank] ?? '?';
  if (high.rank == low.rank) return '$highChar$lowChar';
  return '$highChar$lowChar${a.suit == b.suit ? 's' : 'o'}';
}

String _pairPluralWord(int rank) {
  return switch (rank) {
    6 => 'sixes',
    _ => '${_rankWords[rank] ?? 'cards'}s',
  };
}

String _spokenStartingHand(List<String> hero) {
  if (hero.length < 2) return '';
  final a = CardModel.fromCode(hero[0]);
  final b = CardModel.fromCode(hero[1]);
  final high = a.rank >= b.rank ? a.rank : b.rank;
  final low = a.rank >= b.rank ? b.rank : a.rank;
  if (high == low) return 'pocket ${_pairPluralWord(high)}';
  final fit = a.suit == b.suit ? 'suited' : 'offsuit';
  return '${_rankWords[high]}-${_rankWords[low]} $fit';
}

/// Decade-compound spoken hand (`seventy-two offsuit`) when both ranks are 2–9.
///
/// Returns empty when the hand is a pair or uses a broadway rank — those stay
/// on [_spokenStartingHand] / pair plurals only.
String _decadeCompoundStartingHand(List<String> hero) {
  if (hero.length < 2) return '';
  final a = CardModel.fromCode(hero[0]);
  final b = CardModel.fromCode(hero[1]);
  final high = a.rank >= b.rank ? a.rank : b.rank;
  final low = a.rank >= b.rank ? b.rank : a.rank;
  if (high == low) return '';
  final decade = _decadeWords[high];
  final lowWord = _rankWords[low];
  if (decade == null || lowWord == null) return '';
  final fit = a.suit == b.suit ? 'suited' : 'offsuit';
  return '$decade-$lowWord $fit';
}

String _replaceIgnoringCase(String source, String from, String to) {
  if (from.isEmpty || to.isEmpty || source.isEmpty) return source;
  return source.replaceAllMapped(
    RegExp(
      '(?<![A-Za-z0-9])${RegExp.escape(from)}(?![A-Za-z0-9])',
      caseSensitive: false,
    ),
    (match) {
      final matched = match[0]!;
      if (matched == matched.toUpperCase() &&
          matched.length <= 3 &&
          !matched.contains('-')) {
        return to;
      }
      if (matched[0] == matched[0].toUpperCase()) {
        return '${to[0].toUpperCase()}${to.substring(1)}';
      }
      return to;
    },
  );
}

/// Rewrites authored combo names in [text] to match [dealtHero].
///
/// Catalog copy names a template holding (`K9s`, "king-nine suited",
/// "queens") while isomorphic deals stay in the same family. Coach lines
/// and felt labels must follow the faces on the table.
String alignStartingHandCopy({
  required String text,
  required List<String> templateHero,
  required List<String> dealtHero,
}) {
  if (text.isEmpty || templateHero.length < 2 || dealtHero.length < 2) {
    return text;
  }
  final templateLabel = startingHandLabelFromCodes(templateHero);
  final dealtLabel = startingHandLabelFromCodes(dealtHero);
  if (templateLabel.isEmpty || dealtLabel.isEmpty) return text;
  if (templateLabel == dealtLabel) return text;

  final templateA = CardModel.fromCode(templateHero[0]);
  final templateB = CardModel.fromCode(templateHero[1]);
  final dealtA = CardModel.fromCode(dealtHero[0]);
  final dealtB = CardModel.fromCode(dealtHero[1]);
  final templatePair = templateA.rank == templateB.rank;
  final dealtPair = dealtA.rank == dealtB.rank;
  final templateHigh =
      templateA.rank >= templateB.rank ? templateA.rank : templateB.rank;
  final dealtHigh = dealtA.rank >= dealtB.rank ? dealtA.rank : dealtB.rank;

  var next = text;
  final dealtSpoken = _spokenStartingHand(dealtHero);
  next = _replaceIgnoringCase(
    next,
    _spokenStartingHand(templateHero),
    dealtSpoken,
  );
  // Catalog Open-or-fold trash Oops uses "Seventy-two offsuit" (decade
  // compound), not "seven-two offsuit" — rewrite that alias too (LPT-164).
  final templateDecade = _decadeCompoundStartingHand(templateHero);
  if (templateDecade.isNotEmpty && dealtSpoken.isNotEmpty) {
    next = _replaceIgnoringCase(next, templateDecade, dealtSpoken);
  }
  if (templatePair && dealtPair) {
    next = _replaceIgnoringCase(
      next,
      _pairPluralWord(templateHigh),
      _pairPluralWord(dealtHigh),
    );
  }
  next = next.replaceAll(
    RegExp('\\b${RegExp.escape(templateLabel)}\\b'),
    dealtLabel,
  );
  if (templateLabel.length == 3) {
    final ranksOnly = templateLabel.substring(0, 2);
    final dealtRanks = dealtLabel.length >= 2
        ? dealtLabel.substring(0, 2)
        : dealtLabel;
    next = next.replaceAll(
      RegExp('\\b${RegExp.escape(ranksOnly)}\\b'),
      dealtRanks,
    );
  }
  return next;
}
