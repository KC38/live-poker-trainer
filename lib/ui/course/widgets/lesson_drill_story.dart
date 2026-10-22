/// Authored action lines for choice / number drill felts.
///
/// A drill whose copy describes a situation ("Nit check-raises flop",
/// "BTN opens, BB 3-bets, BTN calls") must show that situation on the felt
/// before the learner answers: the street and board, every named action in
/// seat order with chips in front of the seat, the pot, effective stacks, the
/// seat being read highlighted, and its player-type badge when the copy names
/// the type. A [LessonDrillStory] is a short, checked script of that hand
/// written in a compact line format (see [parseLessonDrillStory]); the felt
/// replays it frame by frame ([LessonDrillStory.frames]) and
/// `lesson_scene_story_contract_test.dart` checks every drill's copy and
/// answers against the script.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Six-max seats, in preflop act order.
const List<String> lessonDrillPreflopOrder = [
  'UTG',
  'HJ',
  'CO',
  'BTN',
  'SB',
  'BB',
];

/// Six-max seats, in postflop act order.
const List<String> lessonDrillPostflopOrder = [
  'SB',
  'BB',
  'UTG',
  'HJ',
  'CO',
  'BTN',
];

/// Streets a story can reach.
const List<String> lessonDrillStreets = ['pre', 'flop', 'turn', 'river'];

/// One action in a story (implicit folds included).
@immutable
class LessonDrillAction {
  /// Creates an action.
  const LessonDrillAction({
    required this.street,
    required this.position,
    required this.label,
    required this.toChips,
    required this.potBeforeChips,
    this.implicit = false,
  });

  /// `pre`, `flop`, `turn`, or `river`.
  final String street;

  /// Six-max position that acted.
  final String position;

  /// Badge text (RAISE, 3-BET, CALL, CHECK, BET, CHECK-RAISE, FOLD, …).
  final String label;

  /// Chips this seat has in front after acting (this street).
  final double toChips;

  /// Money in the middle when the action happened (bets in front included).
  final double potBeforeChips;

  /// Folds the script left out because action passed the seat (preflop).
  final bool implicit;

  @override
  String toString() => '$street:$position:$label:$toChips';
}

/// One picture of the felt while the story plays.
@immutable
class LessonDrillFrame {
  /// Creates a frame.
  const LessonDrillFrame({
    required this.street,
    required this.board,
    required this.bets,
    required this.labels,
    required this.folded,
    required this.middleChips,
    required this.stacks,
    required this.hold,
  });

  /// Street on the felt.
  final String street;

  /// Community cards dealt so far.
  final List<String> board;

  /// Chips in front of each seat this street.
  final Map<String, double> bets;

  /// Last-action badge per seat.
  final Map<String, String> labels;

  /// Seats out of the hand.
  final Set<String> folded;

  /// Money already pulled into the middle (excludes [bets]).
  final double middleChips;

  /// Chips behind per seat.
  final Map<String, double> stacks;

  /// How long this frame stays up before the next one.
  final Duration hold;

  /// Pot pill total (middle + every bet in front).
  double get potChips =>
      middleChips + bets.values.fold<double>(0, (sum, b) => sum + b);
}

/// A parsed, validated drill story.
@immutable
class LessonDrillStory {
  /// Creates a story. Use [parseLessonDrillStory].
  const LessonDrillStory({
    required this.source,
    required this.heroPosition,
    required this.heroCodes,
    required this.holesByPosition,
    required this.types,
    required this.focus,
    required this.inBigBlinds,
    required this.smallBlind,
    required this.bigBlind,
    required this.hidePot,
    required this.actions,
    required this.frames,
    required this.streetsShown,
  });

  /// Script text.
  final String source;

  /// Hero seat.
  final String heroPosition;

  /// Face-up hero holes (empty draws backs).
  final List<String> heroCodes;

  /// Face-up opponent holes by position (showdown spots).
  final Map<String, List<String>> holesByPosition;

  /// Player-type badges by position.
  final Map<String, PlayerArchetype> types;

  /// Seat the question is about (highlighted).
  final String? focus;

  /// Money shows as big blinds.
  final bool inBigBlinds;

  /// Stakes.
  final double smallBlind;

  /// Stakes.
  final double bigBlind;

  /// Pot pill hidden (the question asks for the pot).
  final bool hidePot;

  /// Every action, in the order it plays.
  final List<LessonDrillAction> actions;

  /// Felt pictures, first to last. The last frame is the question.
  final List<LessonDrillFrame> frames;

  /// Streets the story visits, in order.
  final List<String> streetsShown;

  /// Final picture (what the felt shows when the question is asked).
  LessonDrillFrame get last => frames.last;

  /// Players still in the hand at the question (hero included).
  int get liveCount => 6 - last.folded.length;

  /// Formats [chips] the way the felt does (number only).
  num displayAmount(double chips) {
    final v = inBigBlinds ? chips / bigBlind : chips;
    return v == v.roundToDouble() ? v.round() : v;
  }
}

String? _seat(String raw, String hero) {
  final word = raw.trim().toUpperCase();
  if (word == 'YOU' || word == 'HERO') return hero;
  return lessonDrillPreflopOrder.contains(word) ? word : null;
}

PlayerArchetype? _type(String raw) => switch (raw.trim().toLowerCase()) {
  'nit' => PlayerArchetype.nit,
  'station' || 'callingstation' => PlayerArchetype.callingStation,
  'maniac' => PlayerArchetype.maniac,
  'tag' => PlayerArchetype.tag,
  'lag' => PlayerArchetype.lag,
  _ => null,
};

List<String> _cards(String raw) {
  final s = raw.replaceAll(' ', '');
  if (s.length.isOdd) throw FormatException('bad cards "$raw"');
  return [for (var i = 0; i < s.length; i += 2) s.substring(i, i + 2)];
}

/// Parses a drill story line.
///
/// Segments are separated by `|`:
///
/// * `hero BB` — hero seat (default BTN). `holes AhKd` — hero cards.
/// * `show BB AsAd` — face-up opponent holes.
/// * `type BB=nit` — badge (nit, station, maniac, tag, lag), comma separated.
/// * `focus BB` — seat the question reads (highlighted).
/// * `bb` — money in big blinds (amounts below are in bb).
/// * `blinds 2/5` — stakes (default 1/2).
/// * `stacks You=150,BB=60,*=100` — chips (or bb) at the start of the hand.
/// * `pot 12` + `live BB,CO` — start postflop with that much in the middle.
/// * `hidepot` — the question asks for the pot.
/// * `pre: UTG raise 6, BTN call, BB 3bet 22` — street action in order.
///   `flop Kd7c2s: BB check, BTN bet 8, BB raise 26`, `turn 9h: …`,
///   `river 2c: …`. Verbs: fold, check, call, limp, bet N, raise N (also
///   open / 3bet / 4bet), allin N. Amounts are the seat's total in front
///   this street. Preflop, seats the action passes are folded for you.
///
/// Throws [FormatException] when the line breaks seat order or betting.
LessonDrillStory parseLessonDrillStory(String source) {
  var hero = 'BTN';
  var heroCodes = const <String>[];
  final shows = <String, List<String>>{};
  final types = <String, PlayerArchetype>{};
  String? focus;
  var bb = false;
  var smallBlind = 1.0;
  var bigBlind = 2.0;
  var hidePot = false;
  final stackSpec = <String, double>{};
  double? startPot;
  final startLive = <String>[];
  final streets = <({String street, List<String> board, String body})>[];

  final segments = source
      .split('|')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty);
  // First pass: hero seat (other segments refer to "You").
  for (final seg in segments) {
    final m = RegExp(r'^hero\s+(\w+)$', caseSensitive: false).firstMatch(seg);
    if (m != null) {
      hero =
          _seat(m.group(1)!, 'BTN') ??
          (throw FormatException('unknown hero seat "${m.group(1)}"'));
    }
  }
  double money(String raw) {
    final v = double.tryParse(raw.trim());
    if (v == null) throw FormatException('bad amount "$raw"');
    return v;
  }

  for (final seg in segments) {
    final lower = seg.toLowerCase();
    final street = RegExp(
      r'^(pre|flop|turn|river)\s*([2-9TJQKA][shdc](?:\s*[2-9TJQKA][shdc])*)?\s*:(.*)$',
      caseSensitive: false,
    ).firstMatch(seg);
    if (street != null) {
      streets.add((
        street: street.group(1)!.toLowerCase(),
        board: street.group(2) == null
            ? const <String>[]
            : _cards(street.group(2)!),
        body: street.group(3)!.trim(),
      ));
    } else if (lower.startsWith('hero ')) {
      continue;
    } else if (lower.startsWith('holes ')) {
      heroCodes = _cards(seg.substring(6));
    } else if (lower.startsWith('show ')) {
      final parts = seg.substring(5).trim().split(RegExp(r'\s+'));
      final pos =
          _seat(parts.first, hero) ??
          (throw FormatException('bad show seat in "$seg"'));
      shows[pos] = _cards(parts.skip(1).join());
    } else if (lower.startsWith('type ')) {
      for (final pair in seg.substring(5).split(',')) {
        final kv = pair.split('=');
        final pos = _seat(kv.first, hero);
        final t = kv.length == 2 ? _type(kv[1]) : null;
        if (pos == null || t == null) throw FormatException('bad type "$pair"');
        types[pos] = t;
      }
    } else if (lower.startsWith('focus ')) {
      focus =
          _seat(seg.substring(6), hero) ??
          (throw FormatException('bad focus "$seg"'));
    } else if (lower == 'bb') {
      bb = true;
    } else if (lower == 'hidepot') {
      hidePot = true;
    } else if (lower.startsWith('blinds ')) {
      final parts = seg.substring(7).split('/');
      smallBlind = money(parts[0]);
      bigBlind = money(parts[1]);
    } else if (lower.startsWith('stacks ')) {
      for (final pair in seg.substring(7).split(',')) {
        final kv = pair.split('=');
        if (kv.length != 2) throw FormatException('bad stack "$pair"');
        final key = kv.first.trim() == '*' ? '*' : _seat(kv.first, hero);
        if (key == null) throw FormatException('bad stack seat "$pair"');
        stackSpec[key] = money(kv[1]);
      }
    } else if (lower.startsWith('pot ')) {
      startPot = money(seg.substring(4));
    } else if (lower.startsWith('live ')) {
      for (final p in seg.substring(5).split(',')) {
        startLive.add(
          _seat(p, hero) ?? (throw FormatException('bad live "$p"')),
        );
      }
    } else {
      throw FormatException('unknown segment "$seg"');
    }
  }
  if (streets.isEmpty) throw const FormatException('story has no street');
  final unit = bb ? bigBlind : 1.0;
  double chips(double v) => v * unit;

  // Start of hand.
  final stacks = <String, double>{
    for (final p in lessonDrillPreflopOrder)
      p: chips(stackSpec[p] ?? stackSpec['*'] ?? (bb ? 100 : 200)),
  };
  final folded = <String>{};
  // Seats folded for the story because the action passed them; the focus
  // seat may fold on screen, but never silently.
  final passedOver = <String>{};
  final allIn = <String>{};
  var middle = 0.0;
  var board = <String>[];
  final bets = <String, double>{};
  final labels = <String, String>{};
  final actions = <LessonDrillAction>[];
  final frames = <LessonDrillFrame>[];
  final shown = <String>[];

  void frame(String street, Duration hold) {
    frames.add(
      LessonDrillFrame(
        street: street,
        board: List.unmodifiable(board),
        bets: Map.unmodifiable(bets),
        labels: Map.unmodifiable(labels),
        folded: Set.unmodifiable(folded),
        middleChips: middle,
        stacks: Map.unmodifiable(stacks),
        hold: hold,
      ),
    );
  }

  final first = streets.first.street;
  if (first == 'pre') {
    if (startPot != null || startLive.isNotEmpty) {
      throw const FormatException('pot / live only start a postflop story');
    }
    bets['SB'] = smallBlind;
    bets['BB'] = bigBlind;
    stacks['SB'] = stacks['SB']! - smallBlind;
    stacks['BB'] = stacks['BB']! - bigBlind;
  } else {
    if (startLive.isEmpty) {
      throw const FormatException('postflop start needs live seats');
    }
    for (final p in lessonDrillPreflopOrder) {
      if (p != hero && !startLive.contains(p)) folded.add(p);
    }
    middle = chips(startPot ?? 0);
  }

  var expectedIndex = 0;
  for (final s in streets) {
    final order = s.street == 'pre'
        ? lessonDrillPreflopOrder
        : lessonDrillPostflopOrder;
    final streetIndex = lessonDrillStreets.indexOf(s.street);
    if (streetIndex < expectedIndex) {
      throw FormatException('street ${s.street} out of order');
    }
    if (s.street != 'pre') {
      if (shown.isNotEmpty && streetIndex != expectedIndex) {
        throw FormatException('story skips to ${s.street}');
      }
      // Sweep bets, deal board.
      middle += bets.values.fold<double>(0, (a, b) => a + b);
      bets.clear();
      labels.removeWhere((pos, label) => label != 'FOLD');
      final need = streetIndex + 2; // flop 3, turn 4, river 5
      board = [...board, ...s.board];
      if (board.length != need) {
        throw FormatException(
          '${s.street} needs $need board cards, has ${board.length}',
        );
      }
    } else if (s.board.isNotEmpty) {
      throw const FormatException('preflop has no board');
    }
    shown.add(s.street);
    expectedIndex = streetIndex + 1;
    frame(s.street, Duration(milliseconds: frames.isEmpty ? 400 : 800));

    var high = bets.values.fold<double>(0, (m, b) => b > m ? b : m);
    var raises = s.street == 'pre'
        ? 1
        : 0; // the big blind counts as a bet preflop
    final acted = <String>{};
    final checked = <String>{};
    var pointer = order.length - 1; // last seat; first to act is order[0]

    bool needsToAct(String p) =>
        !folded.contains(p) &&
        !allIn.contains(p) &&
        (!acted.contains(p) || (bets[p] ?? 0) < high);

    String? nextToAct() {
      for (var i = 1; i <= order.length; i++) {
        final p = order[(pointer + i) % order.length];
        if (needsToAct(p)) return p;
      }
      return null;
    }

    final body = s.body.trim();
    final steps = body.isEmpty ? const <String>[] : body.split(',');
    for (final raw in steps) {
      final words = raw.trim().split(RegExp(r'\s+'));
      if (words.length < 2) throw FormatException('bad action "$raw"');
      final pos =
          _seat(words[0], hero) ??
          (throw FormatException('bad seat in "$raw"'));
      final verb = words[1].toLowerCase();
      final amount = words.length > 2 ? chips(money(words[2])) : null;
      // Seat order: fold the seats the action passed (preflop only).
      while (true) {
        final next = nextToAct();
        if (next == null) {
          throw FormatException(
            '"$raw": the ${s.street} action is already closed',
          );
        }
        if (next == pos) break;
        if (s.street != 'pre' || next == hero) {
          throw FormatException(
            '"$raw": $next acts before $pos on the ${s.street}',
          );
        }
        final potBefore = middle + bets.values.fold<double>(0, (a, b) => a + b);
        folded.add(next);
        passedOver.add(next);
        labels[next] = 'FOLD';
        acted.add(next);
        actions.add(
          LessonDrillAction(
            street: s.street,
            position: next,
            label: 'FOLD',
            toChips: bets[next] ?? 0,
            potBeforeChips: potBefore,
            implicit: true,
          ),
        );
        pointer = order.indexOf(next);
        frame(s.street, const Duration(milliseconds: 260));
      }
      final potBefore = middle + bets.values.fold<double>(0, (a, b) => a + b);
      final current = bets[pos] ?? 0;
      String label;
      var to = current;
      switch (verb) {
        case 'fold':
          label = 'FOLD';
          folded.add(pos);
        case 'check':
          if (current < high) {
            throw FormatException('"$raw": cannot check facing a bet');
          }
          label = 'CHECK';
          checked.add(pos);
        case 'call':
        case 'limp':
          if (high <= current) throw FormatException('"$raw": nothing to call');
          to = high;
          label = verb == 'limp' ? 'LIMP' : 'CALL';
          if (verb == 'limp' && (s.street != 'pre' || high != bigBlind)) {
            throw FormatException(
              '"$raw": limp only calls the big blind preflop',
            );
          }
        case 'bet':
          if (high > 0) {
            throw FormatException('"$raw": bet facing a bet — use raise');
          }
          if (amount == null) {
            throw FormatException('"$raw": bet needs an amount');
          }
          to = amount;
          label = 'BET';
          raises += 1;
        case 'raise':
        case 'open':
        case '3bet':
        case '4bet':
        case '5bet':
          if (amount == null || amount <= high) {
            throw FormatException('"$raw": raise must go above $high');
          }
          if (s.street != 'pre' && high == 0) {
            throw FormatException('"$raw": nothing to raise — use bet');
          }
          raises += 1;
          to = amount;
          if (s.street == 'pre') {
            label = raises == 2 ? 'RAISE' : '$raises-BET';
            final want = switch (verb) {
              'open' => 2,
              '3bet' => 3,
              '4bet' => 4,
              '5bet' => 5,
              _ => raises,
            };
            if (want != raises) {
              throw FormatException(
                '"$raw": that raise is a ${raises == 2 ? 'open' : '$raises-bet'}',
              );
            }
          } else {
            label = checked.contains(pos) ? 'CHECK-RAISE' : 'RAISE';
          }
        case 'allin':
          if (amount == null) {
            throw FormatException('"$raw": allin needs an amount');
          }
          to = amount;
          label = 'ALL-IN';
          allIn.add(pos);
          if (to > high) raises += 1;
        default:
          throw FormatException('"$raw": unknown verb $verb');
      }
      final add = to - current;
      if (add > stacks[pos]! + 1e-9) {
        throw FormatException(
          '"$raw": ${stacks[pos]} behind, cannot put in $add',
        );
      }
      stacks[pos] = stacks[pos]! - add;
      if (to > 0) bets[pos] = to;
      if (verb == 'allin' && stacks[pos]! > 1e-9) {
        throw FormatException('"$raw": all-in leaves ${stacks[pos]} behind');
      }
      if (to > high) {
        high = to;
        acted.clear();
      }
      acted.add(pos);
      labels[pos] = label;
      actions.add(
        LessonDrillAction(
          street: s.street,
          position: pos,
          label: label,
          toChips: to,
          potBeforeChips: potBefore,
        ),
      );
      pointer = order.indexOf(pos);
      frame(s.street, const Duration(milliseconds: 650));
    }
    // A street the story leaves must be closed (except the last one, where
    // the hero is asked).
    if (!identical(s, streets.last) && nextToAct() != null) {
      throw FormatException(
        '${s.street} ends with ${nextToAct()} still to act',
      );
    }
  }
  if (focus != null && passedOver.contains(focus)) {
    throw FormatException('focus $focus folded without acting');
  }
  for (final pos in types.keys) {
    if (pos == hero) throw const FormatException('hero has no type badge');
  }
  return LessonDrillStory(
    source: source,
    heroPosition: hero,
    heroCodes: heroCodes,
    holesByPosition: shows,
    types: types,
    focus: focus,
    inBigBlinds: bb,
    smallBlind: smallBlind,
    bigBlind: bigBlind,
    hidePot: hidePot,
    actions: List.unmodifiable(actions),
    frames: List.unmodifiable(frames),
    streetsShown: List.unmodifiable(shown),
  );
}
