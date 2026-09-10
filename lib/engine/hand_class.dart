/// Board-relative hand classification: what a holding actually *is* on a given
/// flop, turn, or river.
///
/// The old grader compared a raw [DeckEvaluator] score against a single
/// constant, so bottom pair with a deuce kicker and an overpair were the same
/// input — both cleared "any pair". Every downstream number the coach reports
/// depends on telling those apart, so the distinction lives here and is used
/// by both the villain action model and the hero's own read.
library;

import 'package:live_poker_trainer/engine/fast_evaluator.dart';

/// How strong a two-card holding is *relative to the board*.
///
/// Ordered weakest to strongest so comparisons read naturally.
enum HandClass {
  /// No pair and nothing worth drawing to.
  air,

  /// A gutshot, or two overcards to a low board — real outs, but few.
  weakDraw,

  /// A flush draw or open-ended straight draw: eight outs or more.
  strongDraw,

  /// A pair below the top board card, including underpairs to the board.
  weakPair,

  /// Top pair, or a pocket pair above every board card.
  topPair,

  /// Two pair or a set.
  strongMade,

  /// A straight or better.
  monster;

  /// Player-facing name, used in coach copy.
  String get label => switch (this) {
        HandClass.air => 'air',
        HandClass.weakDraw => 'a weak draw',
        HandClass.strongDraw => 'a strong draw',
        HandClass.weakPair => 'a weak pair',
        HandClass.topPair => 'top pair',
        HandClass.strongMade => 'two pair or better',
        HandClass.monster => 'a straight or better',
      };

  /// Whether this class has showdown value on its own.
  bool get isMade => index >= HandClass.weakPair.index;
}

/// Outs counts that define the draw boundaries.
class DrawOuts {
  DrawOuts._();

  /// A flush draw or open-ended straight draw.
  static const int strong = 8;

  /// A gutshot.
  static const int weak = 4;

  /// A flush draw that is also an open-ender.
  static const int combo = 15;

  /// Outs a bare flush draw has.
  static const int flushDraw = 9;
}

/// Classifies holdings against a board.
class HandClassifier {
  HandClassifier._();

  /// Classifies the two hole cards [a] and [b] against [board].
  ///
  /// All arguments are [FastEvaluator] card codes. An empty [board] returns
  /// [HandClass.air]; preflop strength is a different question and is answered
  /// by the chart, not by this.
  static HandClass classify(int a, int b, List<int> board) {
    if (board.length < 3) return HandClass.air;

    final cards = <int>[a, b, ...board];
    final score = FastEvaluator.score(cards);
    final category = FastEvaluator.categoryOf(score);

    if (category >= HandCategory.straight) return HandClass.monster;
    if (category == HandCategory.trips || category == HandCategory.twoPair) {
      return HandClass.strongMade;
    }

    final outs = drawOuts(a, b, board);

    if (category == HandCategory.pair) {
      var boardTop = -1;
      for (final c in board) {
        final r = c >> 2;
        if (r > boardTop) boardTop = r;
      }
      final pairRank = FastEvaluator.primaryRankOf(score);
      if (pairRank >= boardTop) return HandClass.topPair;
      // A weak pair that also holds a big draw plays like the draw: it is
      // going to keep betting or calling, which is what the frequency model
      // needs to know.
      if (outs >= DrawOuts.strong) return HandClass.strongDraw;
      return HandClass.weakPair;
    }

    if (outs >= DrawOuts.strong) return HandClass.strongDraw;
    if (outs >= DrawOuts.weak) return HandClass.weakDraw;

    // Two live overcards to a low board are worth something against a wide
    // range, but never as much as a real draw.
    if (_overcards(a, b, board) == 2) return HandClass.weakDraw;
    return HandClass.air;
  }

  /// Outs to a flush or straight that the hole cards contribute to.
  ///
  /// Zero on the river (nothing left to draw to) and zero when the straight is
  /// already made. A draw the board holds on its own is nobody's draw, so
  /// board-only straights are excluded.
  static int drawOuts(int a, int b, List<int> board) {
    if (board.length < 3 || board.length > 4) return 0;

    final cards = <int>[a, b, ...board];
    final rankMask = FastEvaluator.rankMaskOf(cards);
    if (FastEvaluator.straightHigh(rankMask) >= 0) return 0;

    var flushOuts = 0;
    for (var suit = 0; suit < 4; suit++) {
      var total = 0;
      var mine = 0;
      for (final c in cards) {
        if (c & 3 == suit) total++;
      }
      if (a & 3 == suit) mine++;
      if (b & 3 == suit) mine++;
      if (total == 4 && mine > 0) flushOuts = DrawOuts.flushDraw;
    }

    final boardMask = FastEvaluator.rankMaskOf(board);
    var straightOuts = 0;
    for (var rank = 0; rank < 13; rank++) {
      final bit = 1 << rank;
      if (FastEvaluator.straightHigh(rankMask | bit) < 0) continue;
      if (FastEvaluator.straightHigh(boardMask | bit) >= 0) continue;
      var seen = 0;
      for (final c in cards) {
        if (c >> 2 == rank) seen++;
      }
      straightOuts += 4 - seen;
    }

    if (flushOuts > 0 && straightOuts >= DrawOuts.strong) return DrawOuts.combo;
    return flushOuts > straightOuts ? flushOuts : straightOuts;
  }

  /// How many hole cards outrank every board card.
  static int _overcards(int a, int b, List<int> board) {
    var boardTop = -1;
    for (final c in board) {
      final r = c >> 2;
      if (r > boardTop) boardTop = r;
    }
    var count = 0;
    if (a >> 2 > boardTop) count++;
    if (b >> 2 > boardTop) count++;
    return count;
  }
}
