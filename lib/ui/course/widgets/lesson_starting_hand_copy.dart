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

final _tableCardToken = RegExp(
  r'\b([2-9TJQKA][shdc])\b',
  caseSensitive: false,
);

const Map<String, (String singular, String plural)> _suitWords = {
  's': ('spade', 'spades'),
  'h': ('heart', 'hearts'),
  'd': ('diamond', 'diamonds'),
  'c': ('club', 'clubs'),
};

void _pairTemplateDealtCodes(
  Map<String, String> codeMap,
  List<String> template,
  List<String> dealt,
) {
  final n = template.length < dealt.length ? template.length : dealt.length;
  for (var i = 0; i < n; i++) {
    final from = template[i].trim();
    final to = dealt[i].trim();
    if (from.isEmpty || to.isEmpty) continue;
    codeMap[from.toLowerCase()] = to;
  }
}

/// Rewrites densified table-scene coach / grade copy onto the remapped felt.
///
/// Flop-class (and other board+hole densify) catalog prompts name template
/// codes (`Board Ks 9d 2c. You hold Kh Qh`) and bank feedback names template
/// ranks/suits (`Pair of kings`, `No jack`, `need a heart`) while
/// [dealtLessonTableScene] isomorphic-remaps both holes and board (LPT-261).
String alignLessonTableCopy({
  required String text,
  required List<String> templateHero,
  required List<String> dealtHero,
  List<String> templateBoard = const <String>[],
  List<String> dealtBoard = const <String>[],
}) {
  if (text.isEmpty) return text;
  final codeMap = <String, String>{};
  _pairTemplateDealtCodes(codeMap, templateHero, dealtHero);
  _pairTemplateDealtCodes(codeMap, templateBoard, dealtBoard);
  if (codeMap.isEmpty) {
    return alignStartingHandCopy(
      text: text,
      templateHero: templateHero,
      dealtHero: dealtHero,
    );
  }

  final rankMap = <int, int>{};
  final suitMap = <String, String>{};
  for (final entry in codeMap.entries) {
    final from = CardModel.fromCode(entry.key);
    final to = CardModel.fromCode(entry.value);
    rankMap[from.rank] = to.rank;
    suitMap[from.suit.code] = to.suit.code;
  }

  var next = text.replaceAllMapped(_tableCardToken, (match) {
    final token = match[1]!;
    return codeMap[token.toLowerCase()] ?? token;
  });

  // Hero chart / spoken starting-hand rewrite first so board rank/suit
  // word swaps cannot turn a correct "six-five" into "five-five".
  if (templateHero.length >= 2 && dealtHero.length >= 2) {
    next = alignStartingHandCopy(
      text: next,
      templateHero: templateHero,
      dealtHero: dealtHero,
    );
  }

  // Spoken rank/suit words only when a board remapped — hole-only densify
  // (hand families) is fully handled by alignStartingHandCopy above.
  if (templateBoard.isEmpty || dealtBoard.isEmpty) {
    return next;
  }

  // Protect English count phrases before spoken rank remaps. A template
  // board deuce remapped to a trey must not turn "Your two cards" into
  // "Your three cards" on Hint (LPT-791), or "Those two stay…" into
  // "Those three stay…" on Nice! (LPT-797 Your two cards guided find-holes).
  //
  // Rank/suit word swaps use placeholders so a chain like king→queen and
  // queen→jack cannot turn "Pair of kings" into "Pair of jacks" when the
  // hero kicker also remaps through queen (LPT-852 Made hands densify).
  next = _withProtectedCountPhrases(next, (body) {
    return _rewriteSpokenRankSuitWords(
      body,
      rankMap: rankMap,
      suitMap: suitMap,
    );
  });

  return _fixIndefiniteArticles(next);
}

/// Applies [rankMap] / [suitMap] spoken-word rewrites without chaining.
///
/// Direct `kings`→`queens` then `queens`→`jacks` would mis-name a remapped
/// top pair when the kicker rank is also in the map (LPT-852).
String _rewriteSpokenRankSuitWords(
  String body, {
  required Map<int, int> rankMap,
  required Map<String, String> suitMap,
}) {
  var out = body;
  final placeholders = <String, String>{};
  var token = 0;

  void stash(String from, String to) {
    if (from.isEmpty || to.isEmpty || from.toLowerCase() == to.toLowerCase()) {
      return;
    }
    final key = '<<RW${token++}>>';
    out = _replaceIgnoringCase(out, from, key);
    placeholders[key] = to;
  }

  // Plurals before singulars so "kings" is not left as "aces"+"s".
  for (final entry in rankMap.entries) {
    if (entry.key == entry.value) continue;
    stash(_pairPluralWord(entry.key), _pairPluralWord(entry.value));
  }
  for (final entry in rankMap.entries) {
    if (entry.key == entry.value) continue;
    final fromWord = _rankWords[entry.key];
    final toWord = _rankWords[entry.value];
    if (fromWord == null || toWord == null) continue;
    stash(fromWord, toWord);
  }

  for (final entry in suitMap.entries) {
    if (entry.key == entry.value) continue;
    final from = _suitWords[entry.key];
    final to = _suitWords[entry.value];
    if (from == null || to == null) continue;
    stash(from.$2, to.$2);
    stash(from.$1, to.$1);
  }

  for (final entry in placeholders.entries) {
    out = out.replaceAll(entry.key, entry.value);
  }
  return out;
}

/// Stashes count phrases like "two cards" / "those two" / "your two holes"
/// while [rewrite] runs, then restores them so board rank-word remaps cannot
/// clobber counts.
String _withProtectedCountPhrases(
  String text,
  String Function(String body) rewrite,
) {
  final protected = <String>[];
  final masked = text.replaceAllMapped(
    RegExp(
      // "Those/These two" (before stay/are/…) and "your/the two cards|…"
      r'\b((?:(?:those|these)\s+(?:two|three|four|five|six|seven))'
      r'|(?:(?:your\s+|the\s+)?(?:two|three|four|five|six|seven)'
      r'(?:\s+cards?|\s+holes?|\s+seats?|\s+presses?'
      r'|\s+at\s+your|\s+in\s+front'
      r'|\s+stay|\s+are|\s+keep|\s+remain)))\b',
      caseSensitive: false,
    ),
    (match) {
      final token = '<<COUNT${protected.length}>>';
      protected.add(match[0]!);
      return token;
    },
  );
  var next = rewrite(masked);
  for (var i = 0; i < protected.length; i++) {
    next = next.replaceAll('<<COUNT$i>>', protected[i]);
  }
  return next;
}

/// Fixes `an queen` / `a ace` after rank-word remaps.
String _fixIndefiniteArticles(String text) {
  var next = text.replaceAllMapped(
    RegExp(r'\b([Aa])n\s+([bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ])'),
    (m) => '${m[1]} ${m[2]}',
  );
  next = next.replaceAllMapped(
    RegExp(r'\b([Aa])\s+([aeiouAEIOU])'),
    (m) => '${m[1]}n ${m[2]}',
  );
  return next;
}
