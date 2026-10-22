/// Rules that keep a drill's copy and answers honest to its felt.
///
/// Used by `lesson_scene_story_contract_test.dart`. A drill's speech bubble,
/// hint, and seat-named answers may only describe what the felt shows: every
/// action, street, board feature, bet size, seat, table size, and player type
/// they name must play out in the drill's story, and the speech must not
/// restate a stack / pot / bet number the felt already shows.
library;

import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_drill_story.dart';

/// What a drill felt shows, reduced to checkable facts.
class SceneFacts {
  /// Creates facts.
  SceneFacts({
    required this.streets,
    required this.board,
    required this.actions,
    required this.liveCount,
    required this.types,
    required this.focus,
    required this.heroPosition,
    required this.shownHoles,
  });

  /// From a drill story.
  factory SceneFacts.fromStory(LessonDrillStory story) => SceneFacts(
    streets: story.streetsShown.toSet(),
    board: story.last.board,
    actions: story.actions.where((a) => !a.implicit).toList(),
    liveCount: story.liveCount,
    types: story.types,
    focus: story.focus,
    heroPosition: story.heroPosition,
    shownHoles: story.holesByPosition.isNotEmpty,
  );

  /// Streets the felt visits (`pre`, `flop`, `turn`, `river`).
  final Set<String> streets;

  /// Final board.
  final List<String> board;

  /// Actions that play out (implicit folds excluded).
  final List<LessonDrillAction> actions;

  /// Players in the hand at the question (hero included).
  final int liveCount;

  /// Type badges on seats.
  final Map<String, PlayerArchetype> types;

  /// Highlighted seat.
  final String? focus;

  /// Hero seat.
  final String heroPosition;

  /// Opponent holes face up.
  final bool shownHoles;

  bool has(String label, {String? seat, String? street}) => actions.any(
    (a) =>
        a.label == label &&
        (seat == null || a.position == seat) &&
        (street == null || a.street == street),
  );

  bool get anyRaise => actions.any(
    (a) =>
        a.label == 'RAISE' ||
        a.label.endsWith('-BET') ||
        a.label == 'CHECK-RAISE',
  );

  /// Last preflop raiser (the PFR), if any.
  String? get preflopRaiser {
    String? who;
    for (final a in actions) {
      if (a.street == 'pre' &&
          (a.label == 'RAISE' || a.label.endsWith('-BET'))) {
        who = a.position;
      }
    }
    return who;
  }

  bool betOn(String street, {String? seat}) => actions.any(
    (a) =>
        a.street == street &&
        (a.label == 'BET' ||
            a.label == 'ALL-IN' ||
            a.label.contains('RAISE')) &&
        (seat == null || a.position == seat),
  );
}

const _seatWords = <String, String>{
  'UTG': 'UTG',
  'HJ': 'HJ',
  'CO': 'CO',
  'BTN': 'BTN',
  'SB': 'SB',
  'BB': 'BB',
  'button': 'BTN',
  'cutoff': 'CO',
  'hijack': 'HJ',
  'small blind': 'SB',
  'big blind': 'BB',
};

final _typeWords = <PlayerArchetype, RegExp>{
  PlayerArchetype.nit: RegExp(r'\bnits?\b', caseSensitive: false),
  PlayerArchetype.callingStation: RegExp(
    r'\b(calling )?stations?\b',
    caseSensitive: false,
  ),
  PlayerArchetype.maniac: RegExp(r'\bmaniacs?\b', caseSensitive: false),
  PlayerArchetype.tag: RegExp(r'\btags?\b', caseSensitive: false),
  PlayerArchetype.lag: RegExp(r'\blags?\b', caseSensitive: false),
};

/// A phrase the copy may use and what the felt must show for it.
class _Need {
  const _Need(this.name, this.pattern, this.ok, {this.heroPlanExempt = true});
  final String name;
  final RegExp pattern;
  final bool Function(SceneFacts f) ok;

  /// Skip when the phrase is the hero's own option ("Why call wider…").
  final bool heroPlanExempt;
}

bool _overbet(SceneFacts f) => f.actions.any(
  (a) =>
      (a.label == 'BET' || a.label == 'ALL-IN' || a.label.contains('RAISE')) &&
      a.toChips > a.potBeforeChips,
);

bool _bigBet(SceneFacts f) => f.actions.any(
  (a) =>
      (a.label == 'BET' ||
          a.label == 'ALL-IN' ||
          a.label.contains('RAISE') ||
          a.label.endsWith('-BET')) &&
      a.toChips >= 0.75 * a.potBeforeChips,
);

bool _tinyBet(SceneFacts f) => f.actions.any(
  (a) => a.label == 'BET' && a.toChips <= 0.34 * a.potBeforeChips,
);

bool _cbet(SceneFacts f) {
  final pfr = f.preflopRaiser;
  return pfr != null && f.betOn('flop', seat: pfr) ||
      // Postflop-start stories: the focus is the raiser by construction.
      (pfr == null && f.betOn('flop'));
}

bool _delayedCbet(SceneFacts f) {
  final pfr = f.preflopRaiser;
  return pfr != null &&
      f.has('CHECK', seat: pfr, street: 'flop') &&
      f.streets.contains('turn');
}

bool _donk(SceneFacts f) {
  final pfr = f.preflopRaiser;
  for (final street in const ['flop', 'turn', 'river']) {
    final acts = f.actions.where((a) => a.street == street).toList();
    if (acts.isEmpty) continue;
    final first = acts.first;
    if (first.label == 'BET' && (pfr == null || first.position != pfr)) {
      return true;
    }
  }
  return false;
}

bool _barrel(SceneFacts f) => f.betOn('turn') || f.betOn('river');

bool _triple(SceneFacts f) =>
    f.betOn('flop') && f.betOn('turn') && f.betOn('river');

bool _double(SceneFacts f) => f.betOn('flop') && f.betOn('turn');

bool _pairedBoard(SceneFacts f) {
  final ranks = [for (final c in f.board) c[0]];
  return ranks.toSet().length < ranks.length;
}

final List<_Need> _needs = [
  _Need(
    'preflop action',
    RegExp(r'\bpreflops?\b'),
    (f) => f.actions.any((a) => a.street == 'pre'),
    heroPlanExempt: false,
  ),
  _Need(
    'flop',
    RegExp(r'\bflops?\b'),
    (f) => f.streets.contains('flop'),
    heroPlanExempt: false,
  ),
  _Need(
    'turn',
    RegExp(r'(?<!(your|of|in|wait) )\bturns?\b(?! (idea|map))'),
    (f) => f.streets.contains('turn'),
    heroPlanExempt: false,
  ),
  _Need(
    'river',
    RegExp(r'\brivers?\b'),
    (f) => f.streets.contains('river'),
    heroPlanExempt: false,
  ),
  _Need(
    'showdown',
    RegExp(r'\bshowdowns\b|\b(at|to) showdown\b'),
    (f) => f.shownHoles || f.streets.contains('river'),
    heroPlanExempt: false,
  ),
  _Need('3-bet', RegExp(r'\b3-?bet'), (f) => f.has('3-BET')),
  _Need('4-bet', RegExp(r'\b4-?bet'), (f) => f.has('4-BET')),
  _Need(
    'check-raise',
    RegExp(r'check-?rais|\bxr\b'),
    (f) => f.has('CHECK-RAISE'),
  ),
  _Need('limp', RegExp(r'\blimp'), (f) => f.has('LIMP')),
  _Need(
    'open',
    RegExp(r'\bopens?\b|\bopen-rais|\bopened\b|\bsteals?\b|\bpfr\b|\braiser\b'),
    (f) => f.has('RAISE', street: 'pre'),
  ),
  _Need('delayed c-bet', RegExp(r'\bdelayed c-?bet'), _delayedCbet),
  _Need('c-bet', RegExp(r'(?<!delayed )\bc-?bets?\b'), _cbet),
  _Need('triple barrel', RegExp(r'\btriple'), _triple),
  _Need('double barrel', RegExp(r'\b(double|dual) barrel'), _double),
  _Need('barrel', RegExp(r'\bbarrel'), _barrel),
  _Need('donk', RegExp(r'\bdonk'), _donk),
  _Need('overbet', RegExp(r'overbet|\bbomb\b|\b\dx pot'), _overbet),
  _Need(
    'all-in',
    RegExp(r'\bshoves?\b|\bjams?\b|all-in'),
    (f) => f.has('ALL-IN'),
  ),
  _Need(
    'call',
    RegExp(r'\b(calls?|called|callers?|calling|flats?|flatting|flatted)\b'),
    (f) => f.has('CALL'),
  ),
  _Need(
    'bet',
    RegExp(r'(?<![-\w])bets?\b|\bbetting\b|\bleads?\b'),
    (f) => f.has('BET') || f.has('ALL-IN'),
  ),
  _Need('check', RegExp(r'\bchecks?\b(?!-)|check-back'), (f) => f.has('CHECK')),
  _Need(
    'raise',
    RegExp(r'\brais(e|es|ed|ing)\b(?! (confidence|your|the bar))'),
    (f) => f.anyRaise,
  ),
  _Need(
    'large size',
    RegExp(
      r'\b(huge|large|big) (bet|raise|check-raise|lead|shove)|\bhuge check',
    ),
    _bigBet,
  ),
  _Need(
    'small size',
    RegExp(r'\b(tiny|small|min) (bet|lead|raise)|\btiny flop bet'),
    _tinyBet,
  ),
  _Need(
    'four-way',
    RegExp(r'\bfour-way\b'),
    (f) => f.liveCount == 4,
    heroPlanExempt: false,
  ),
  _Need(
    'three-way',
    RegExp(r'\bthree-way\b'),
    (f) => f.liveCount == 3,
    heroPlanExempt: false,
  ),
  _Need(
    'multiway',
    RegExp(r'\bmultiway\b'),
    (f) => f.liveCount >= 3,
    heroPlanExempt: false,
  ),
  _Need(
    'heads-up',
    RegExp(r'\bheads-up\b|\bhu\b'),
    (f) => f.liveCount == 2,
    heroPlanExempt: false,
  ),
  _Need(
    'A-high board',
    RegExp(r'\ba-high\b|\bace-high\b'),
    (f) => f.board.any((c) => c.startsWith('A')),
    heroPlanExempt: false,
  ),
  _Need(
    'paired board',
    RegExp(r'\bpaired\b'),
    _pairedBoard,
    heroPlanExempt: false,
  ),
  _Need(
    'board',
    RegExp(r'\bboard\b|\bdry\b|\bwet\b|\bmonotone\b'),
    (f) => f.board.isNotEmpty,
    heroPlanExempt: false,
  ),
  _Need(
    'seat being read',
    RegExp(r'\b(seat|villain|opponent)\b'),
    (f) => f.focus != null,
    heroPlanExempt: false,
  ),
];

/// Hero's own plan or a general question — no action needs to play out.
final _heroPlan = RegExp(
  r"\b(you|your|why|should|best|how|when|avoid|don't|never|to|if|versus|vs|tap|pick|before)\b",
);

String _clauseBefore(String text, int index) {
  final head = text.substring(0, index);
  final cut = head.lastIndexOf(RegExp(r'[.?!—:;]'));
  return cut < 0 ? head : head.substring(cut + 1);
}

/// Strips words that look like actions but are not ("Calling Station").
String _normalize(String text) => text
    .replaceAll(RegExp(r'calling stations?', caseSensitive: false), 'station')
    .replaceAll(RegExp(r'\bcall(ing)? down\b', caseSensitive: false), 'catch')
    .toLowerCase();

/// Problems in [speech] / [hints] / [options] versus [facts].
List<String> sceneStoryProblems({
  required String speech,
  required List<String> hints,
  required List<String> options,
  required SceneFacts facts,
  required List<String> feltTexts,
  List<String> heroCodes = const <String>[],
}) {
  final problems = <String>{};
  for (final source in [speech, ...hints]) {
    final text = _normalize(source);
    for (final need in _needs) {
      for (final m in need.pattern.allMatches(text)) {
        if (need.heroPlanExempt &&
            _heroPlan.hasMatch(_clauseBefore(text, m.start))) {
          continue;
        }
        if (!need.ok(facts)) {
          problems.add(
            'copy says "${m.group(0)}" (${need.name}) but the felt never shows it',
          );
        }
        break;
      }
    }
    // Seats named as actors ("BTN opens", "BB donks") must be in the hand.
    _seatWords.forEach((word, pos) {
      final re = word.length <= 3
          ? RegExp('(?<![\\d.])\\b$word\\b')
          : RegExp('\\b$word\\b', caseSensitive: false);
      if (re.hasMatch(source)) {
        final inHand =
            pos == facts.heroPosition ||
            facts.actions.any((a) => a.position == pos) ||
            facts.focus == pos;
        if (!inHand) {
          problems.add(
            'copy names $pos but that seat does nothing on the felt',
          );
        }
      }
    });
  }
  // Type badges: named type → badge on a seat; never a badge that names the
  // one answer that differs.
  final optionText = options.join(' / ');
  _typeWords.forEach((type, re) {
    final optionsNaming = options.where((o) => re.hasMatch(o)).length;
    final spoiler = optionsNaming > 0 && optionsNaming < options.length;
    final named =
        [speech, ...hints].any(re.hasMatch) ||
        (options.isNotEmpty && optionsNaming == options.length);
    final shown = facts.types.values.contains(type);
    if (shown && spoiler) {
      problems.add('badge ${type.label} spoils the answer ($optionText)');
    } else if (named && !shown && !spoiler) {
      problems.add('copy names ${type.label} but no seat wears that badge');
    }
  });
  // Seat-named answers ("BB 3-BET", "BTN CALL") must have happened.
  for (final option in options) {
    final upper = option.toUpperCase();
    final seat = RegExp(r'\b(UTG|HJ|CO|BTN|SB|BB)\b')
        .firstMatch(upper)
        ?.group(1);
    if (seat == null) continue;
    const verbs = {
      '3-BET': '3-BET',
      '4-BET': '4-BET',
      'CALL': 'CALL',
      'LIMP': 'LIMP',
      'OPEN': 'RAISE',
      'RAISE': 'RAISE',
      'BET': 'BET',
      'CHECK': 'CHECK',
      'FLAT': 'CALL',
    };
    verbs.forEach((word, label) {
      if (RegExp('\\b$word').hasMatch(upper) &&
          !upper.contains('3-$word') &&
          !facts.has(label, seat: seat)) {
        problems.add(
          'answer "$option" names $seat $word but the felt never shows it',
        );
      }
    });
  }
  // Speech must not restate money the felt already shows.
  final felt = feltTexts.join(' | ');
  final money = RegExp(
    r'(\d+(?:\.\d+)?)\s*bb\b'
    r'|\bpot\s*(?:is\s*|of\s*)?(\d+(?:\.\d+)?)'
    r'|\bstacks?\s*(\d+(?:\.\d+)?)'
    r'|(\d+(?:\.\d+)?)\s*chips'
    r'|\$(\d+(?:\.\d+)?)'
    r'|\b(?:bets?|opens? to|raises? to|effective|hero|villain|you have)\s*(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );
  for (final m in money.allMatches(speech)) {
    final n = [for (var g = 1; g <= m.groupCount; g++) m.group(g)]
        .firstWhere((x) => x != null)!;
    final shown =
        RegExp('(^|[^\\d.])\\\$?$n( BB)?(\$|[^\\d.])').hasMatch(felt) &&
        (felt.contains('\$$n') || felt.contains('$n BB'));
    if (shown) {
      problems.add(
        'speech restates "${m.group(0)}" — the felt already shows $n',
      );
    }
  }
  // Cards the felt shows face up (board, hero holes) are not restated.
  for (final m in RegExp(r'\b([2-9TJQKA])([shdc])\b').allMatches(speech)) {
    final code = '${m.group(1)}${m.group(2)}';
    if (facts.board.contains(code) || heroCodes.contains(code)) {
      problems.add('speech restates the card $code — the felt shows it');
    }
  }
  final stakes = RegExp(
    r'\bblinds\s*(\d+)\s*/\s*(\d+)',
    caseSensitive: false,
  ).firstMatch(speech);
  if (stakes != null &&
      felt.contains('\$${stakes.group(1)}/\$${stakes.group(2)}')) {
    problems.add('speech restates the stakes — the felt shows them');
  }
  return problems.toList();
}
