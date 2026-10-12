/// Lessons that follow the Your two cards pilot author `teachSpec` on every
/// interactive step (docs/agents/11-lesson-content-agent.md). Each content
/// ticket adds its lesson to [_lessons] plus any lesson-specific checks.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/engine/fast_evaluator.dart';
import 'package:live_poker_trainer/engine/hand_class.dart';
import 'package:live_poker_trainer/models/card_model.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_action_table.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_best_five.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_card_deal.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_screen_layout.dart';

/// Lesson id -> interactive activity ids that must author `teachSpec`.
const _lessons = <String, List<String>>{
  // LPT-85
  'lesson-01-01-03-blinds-and-button': [
    'act-01-01-03-explain-button',
    'act-01-01-03-guided-button',
    'act-01-01-03-scaffolded-blinds',
    'act-01-01-03-unguided-when',
    'act-01-01-03-checkpoint-layout',
  ],
  // LPT-88
  'lesson-01-02-01-hand-ranks': [
    'act-01-02-01-explain-ladder',
    'act-01-02-01-guided-ladder',
    'act-01-02-01-scaffolded-spot',
    'act-01-02-01-unguided-compare',
    'act-01-02-01-checkpoint-winner',
  ],
  // LPT-91
  'lesson-01-02-02-best-five-kickers': [
    'act-01-02-02-explain-five',
    'act-01-02-02-guided-seven',
    'act-01-02-02-scaffolded-kicker',
    'act-01-02-02-unguided-board',
    'act-01-02-02-checkpoint-build',
  ],
  // LPT-94
  'lesson-01-03-01-fold-check-call': [
    'act-01-03-01-guided-fold',
    'act-01-03-01-scaffolded-check',
    'act-01-03-01-unguided-call',
    'act-01-03-01-checkpoint-legal',
  ],
  // LPT-98
  'lesson-01-03-02-bet-raise-allin': [
    'act-01-03-02-guided-bet',
    'act-01-03-02-scaffolded-raise',
    'act-01-03-02-unguided-allin',
    'act-01-03-02-checkpoint-names',
  ],
  // LPT-101
  'lesson-01-04-01-streets-and-order': [
    'act-01-04-01-guided-streets',
    'act-01-04-01-scaffolded-order',
    'act-01-04-01-unguided-end',
    'act-01-04-01-checkpoint-postflop',
  ],
  // LPT-104
  'lesson-01-05-01-winning-pots': [
    'act-01-05-01-guided-fold-win',
    'act-01-05-01-scaffolded-showdown',
    'act-01-05-01-unguided-pot',
    'act-01-05-01-checkpoint-side',
  ],
  // LPT-108
  'lesson-01-06-01-guided-complete-hand': [
    'act-01-06-01-guided-steps',
    'act-01-06-01-scaffolded-multi',
    'act-01-06-01-unguided-lab',
    'act-01-06-01-checkpoint-finish',
  ],
  // LPT-110
  'lesson-01-06-02-section-one-jump': [
    'act-01-06-02-jump-ranks',
    'act-01-06-02-jump-order',
    'act-01-06-02-jump-legal',
    'act-01-06-02-jump-hand',
  ],
  // LPT-112
  'lesson-02-01-01-position-labels': [
    'act-02-01-01-guided-btn',
    'act-02-01-01-scaffolded-blinds',
    'act-02-01-01-unguided-co',
    'act-02-01-01-checkpoint-edge',
  ],
  // LPT-115
  'lesson-02-01-02-acting-order': [
    'act-02-01-02-guided-pre',
    'act-02-01-02-scaffolded-post',
    'act-02-01-02-unguided-wait',
    'act-02-01-02-checkpoint-full',
  ],
  // LPT-119
  'lesson-02-02-01-hand-families': [
    'act-02-02-01-guided-pair',
    'act-02-02-01-scaffolded-broadway',
    'act-02-02-01-unguided-sc',
    'act-02-02-01-checkpoint-trash',
  ],
  // LPT-122
  'lesson-02-03-01-open-fold': [
    'act-02-03-01-guided-utg',
    'act-02-03-01-scaffolded-qq',
    'act-02-03-01-unguided-btn',
    'act-02-03-01-checkpoint-hj',
  ],
  // LPT-125
  'lesson-02-04-01-facing-raise': [
    'act-02-04-01-guided-fold',
    'act-02-04-01-scaffolded-call',
    'act-02-04-01-unguided-3bet',
    'act-02-04-01-checkpoint-aq',
  ],
  // LPT-128
  'lesson-02-05-01-effective-stack': [
    'act-02-05-01-guided-convert',
    'act-02-05-01-scaffolded-eff',
    'act-02-05-01-unguided-depth',
    'act-02-05-01-checkpoint-200',
  ],
  // LPT-131
  'lesson-02-06-01-live-habits': [
    'act-02-06-01-explain-habits',
    'act-02-06-01-guided-follow',
    'act-02-06-01-scaffolded-verbal',
    'act-02-06-01-unguided-protect',
    'act-02-06-01-checkpoint-oot',
  ],
  // LPT-135
  'lesson-02-07-01-baseline-full-hand': [
    'act-02-07-01-guided-ep',
    'act-02-07-01-scaffolded-vs',
    'act-02-07-01-unguided-lab',
    'act-02-07-01-checkpoint-habit',
  ],
  // LPT-137
  'lesson-02-07-02-section-two-jump': [
    'act-02-07-02-jump-pos',
    'act-02-07-02-jump-family',
    'act-02-07-02-jump-open',
    'act-02-07-02-jump-vs',
    'act-02-07-02-jump-stack',
  ],
  // LPT-138
  'lesson-03-01-01-reading-live-table': [
    'act-03-01-01-explain',
    'act-03-01-01-guided',
    'act-03-01-01-scaffolded',
    'act-03-01-01-unguided',
    'act-03-01-01-checkpoint',
  ],
  // LPT-141
  'lesson-03-02-01-flop-hand-classes': [
    'act-03-02-01-explain',
    'act-03-02-01-guided',
    'act-03-02-01-scaffolded',
    'act-03-02-01-unguided',
    'act-03-02-01-checkpoint',
  ],
};

const _modes = {'none', 'fixed', 'random_in_class'};

CourseCatalog _catalog() {
  final raw = File('assets/course/v2/catalog.json').readAsStringSync();
  return CourseCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

List<Map<String, dynamic>> _list(CourseActivity a, String key) => [
  for (final e in (a.teachSpec?[key] as List<dynamic>? ?? const []))
    Map<String, dynamic>.from(e as Map),
];

void main() {
  late CourseCatalog catalog;
  setUpAll(() => catalog = _catalog());

  CourseActivity act(String id) {
    final found = catalog.activityById(id);
    expect(found, isNotNull, reason: id);
    return found!;
  }

  for (final entry in _lessons.entries) {
    group(entry.key, () {
      test('every interactive step authors a valid teachSpec.deal', () {
        final lesson = catalog.lessonById(entry.key);
        expect(lesson, isNotNull);
        for (final id in entry.value) {
          final a = act(id);
          final deal = a.teachSpec?['deal'];
          expect(deal, isA<Map<String, dynamic>>(), reason: '$id deal');
          final mode = (deal as Map)['mode'];
          expect(_modes, contains(mode), reason: '$id mode');
          if (mode == 'random_in_class') {
            expect(
              deal['handFamily'] != null || deal['suitFamily'] != null,
              isTrue,
              reason: '$id random_in_class needs a family',
            );
          }
          if (mode == 'fixed') {
            expect(deal['fixedCards'], isNotNull, reason: '$id fixedCards');
          }
          if (mode == 'none') {
            expect(deal.containsKey('handFamily'), isFalse, reason: id);
            expect(deal.containsKey('suitFamily'), isFalse, reason: id);
          }
        }
      });

      test('press numbers are 1-based and unique', () {
        for (final id in entry.value) {
          final a = act(id);
          for (final key in ['cues', 'pressHints']) {
            final presses = [for (final e in _list(a, key)) e['press'] as int];
            expect(presses.toSet().length, presses.length, reason: '$id $key');
            expect(presses.every((p) => p >= 1), isTrue, reason: '$id $key');
          }
        }
      });

      test('assessment steps keep no pressHints and no Hint media', () {
        for (final id in entry.value) {
          final a = act(id);
          if (a.assessmentRole == null) continue;
          expect(a.teachSpec!.containsKey('pressHints'), isFalse, reason: id);
          expect(a.coachMedia.where((m) => m.kind == 'hint'), isEmpty);
          expect(lessonFrameHintsDisabled(a), isTrue, reason: id);
          expect(lessonFrameHintFallback(a), isNull, reason: id);
          for (final cue in _list(a, 'cues')) {
            expect(cue['kind'], 'none', reason: '$id checkpoint cue');
          }
        }
      });
    });
  }

  group('Button and blinds (LPT-85)', () {
    test('seat/puck lesson deals no cards', () {
      for (final id in _lessons['lesson-01-01-03-blinds-and-button']!) {
        expect((act(id).teachSpec!['deal'] as Map)['mode'], 'none', reason: id);
      }
    });

    test('explain SoftPulse walks the pucks D -> SB -> BB', () {
      final cues = _list(act('act-01-01-03-explain-button'), 'cues');
      expect([for (final c in cues) c['press']], [1, 2, 3]);
      expect([for (final c in cues) c['target']], ['D', 'SB', 'BB']);
      expect(cues.every((c) => c['kind'] == 'soft_pulse'), isTrue);
    });

    test('single-press steps cue the graded target', () {
      String target(String id) => _list(act(id), 'cues').single['target'];
      expect(target('act-01-01-03-guided-button'), 'D');
      expect(target('act-01-01-03-scaffolded-blinds'), 'BB');
      expect(target('act-01-01-03-unguided-when'), 'before-deal');
      expect(target('act-01-01-03-checkpoint-layout'), 'SB');
      // The timing cue names a real choice id.
      expect(
        act('act-01-01-03-unguided-when').choices.map((c) => c.id),
        contains('before-deal'),
      );
    });
  });

  group('Hand ranks (LPT-88)', () {
    const classes = {
      'act-01-02-01-explain-ladder': ['high_card', 'pair', 'flush'],
      'act-01-02-01-guided-ladder': ['high_card', 'pair', 'flush'],
      'act-01-02-01-scaffolded-spot': ['pair', 'straight', 'flush'],
      'act-01-02-01-unguided-compare': ['full_house', 'trips', 'two_pair'],
      'act-01-02-01-checkpoint-winner': ['flush', 'straight', 'high_card'],
    };

    test('deal families list the press-order classes', () {
      for (final MapEntry(key: id, value: want) in classes.entries) {
        final deal = act(id).teachSpec!['deal'] as Map<String, dynamic>;
        final variants = [
          for (final v in deal['variants'] as List<dynamic>)
            (v as Map)['handFamily'],
        ];
        expect([deal['handFamily'], ...variants], want, reason: id);
      }
    });

    test('cues follow the role ids in press order', () {
      for (final id in classes.keys) {
        final a = act(id);
        final cues = _list(a, 'cues');
        expect([for (final c in cues) c['target']], ['you', 'sam', 'jo']);
        // Role ids are the authored sequence items (grading stays on them).
        final items = [for (final i in a.sequenceItems) i.id];
        if (items.isNotEmpty) {
          expect(items, ['you', 'sam', 'jo'], reason: id);
        }
        final kind = a.assessmentRole == null ? 'soft_pulse' : 'none';
        expect(cues.every((c) => c['kind'] == kind), isTrue, reason: id);
      }
    });

    test('Dart deal classes match the authored families per role', () {
      String spoken(String family) => family.replaceAll('_', ' ');
      for (final MapEntry(key: id, value: want) in classes.entries) {
        for (var seed = 0; seed < 12; seed++) {
          final deal = dealShowdownOrderCards(id, random: Random(seed))!;
          final hint = showdownOrderHintSpeech(id, deal: deal)!;
          // Hint names each role's class in press order: "You (pair), ...".
          final named = RegExp(r'\(([^)]+)\)')
              .allMatches(hint)
              .map((m) => m.group(1))
              .toList();
          expect(named, [for (final f in want) spoken(f)], reason: hint);
          expect(deal.correctOrder, ['you', 'sam', 'jo']);
        }
      }
    });
  });

  group('Best five and kickers (LPT-91)', () {
    String rank(String code) => code.substring(0, code.length - 1);
    List<String> targets(String id) => [
      for (final c in _list(act(id), 'cues')) c['target'] as String,
    ];

    /// Names each card of a top-pair + kicker deal the way the cues do.
    Map<String, String> roles(List<String> hero, List<String> board) {
      final pairRank = rank(
        hero.firstWhere((h) => board.any((b) => rank(b) == rank(h))),
      );
      final kickers = [
        for (final b in board)
          if (rank(b) != pairRank) b,
      ];
      return {
        for (final h in hero)
          h: rank(h) == pairRank ? 'hero_pair' : 'hero_kicker',
        board.firstWhere((b) => rank(b) == pairRank): 'board_pair',
        kickers[0]: 'board_top_kicker',
        kickers[1]: 'board_second_kicker',
      };
    }

    test('explain cues follow the dealt playOrder', () {
      for (var seed = 0; seed < 16; seed++) {
        final deal = dealBestFiveExplainLayout(random: Random(seed));
        final named = roles(deal.hero, deal.board);
        expect(
          [for (final c in deal.playOrder) named[c]],
          targets('act-01-02-02-explain-five'),
          reason: '$seed ${deal.playOrder}',
        );
      }
    });

    test('guided seven cues follow the picker guide order', () {
      final a = act('act-01-02-02-guided-seven');
      expect(a.choices.first.id, 'best-pair-k');
      for (var seed = 0; seed < 16; seed++) {
        final spot = dealtBestFiveSpot(a, random: Random(seed))!;
        final named = roles(spot.heroCodes, spot.boardCodes);
        expect(
          [for (final c in spot.choiceSets['best-pair-k']!) named[c]],
          targets('act-01-02-02-guided-seven'),
          reason: '$seed',
        );
      }
    });

    test('checkpoint deals a pocket pair into a full house', () {
      final a = act('act-01-02-02-checkpoint-build');
      final deal = a.teachSpec!['deal'] as Map<String, dynamic>;
      expect(deal['handFamily'], 'full_house');
      expect(deal['suitFamily'], 'pair');
      for (var seed = 0; seed < 16; seed++) {
        final spot = dealtBestFiveSpot(a, random: Random(seed))!;
        expect(rank(spot.heroCodes[0]), rank(spot.heroCodes[1]));
        final fh = spot.choiceSets['fh-eights']!;
        final counts = <String, int>{};
        for (final c in fh) {
          counts[rank(c)] = (counts[rank(c)] ?? 0) + 1;
        }
        expect(counts.values.toList()..sort(), [2, 3], reason: '$fh');
      }
    });

    test('showdown steps cue the graded region', () {
      expect(targets('act-01-02-02-scaffolded-kicker'), ['hero_holes']);
      expect(targets('act-01-02-02-unguided-board'), ['board']);
      final board =
          act('act-01-02-02-unguided-board').teachSpec!['deal'] as Map;
      expect(board['handFamily'], 'straight_flush');
      expect(board['suitFamily'], 'monotone');
    });
  });

  group('Fold, check, call (LPT-94)', () {
    const want = {
      'act-01-03-01-guided-fold': ('fold-72', 'FOLD', 'trash'),
      'act-01-03-01-scaffolded-check': ('check-free', 'CHECK', 'weak_draw'),
      'act-01-03-01-unguided-call': ('call-5', 'CALL', 'strong_draw'),
      'act-01-03-01-checkpoint-legal': ('check-illegal', 'CHECK', 'weak_draw'),
    };
    int enc(String c) => FastEvaluator.encode(CardModel.fromCode(c));
    String snake(HandClass c) => c.name.replaceAllMapped(
      RegExp('[A-Z]'),
      (m) => '_${m[0]!.toLowerCase()}',
    );
    HandClass classOf(LessonActionSpot s) => HandClassifier.classify(
      enc(s.heroCodes[0]),
      enc(s.heroCodes[1]),
      [for (final b in s.boardCodes) enc(b)],
    );
    String suit(String c) => c.substring(c.length - 1);

    test('cues target the graded dock choice', () {
      for (final MapEntry(key: id, value: w) in want.entries) {
        final a = act(id);
        final cues = _list(a, 'cues');
        expect(cues, hasLength(1), reason: id);
        expect(cues.single['target'], w.$1, reason: id);
        final choice = a.choices.firstWhere((c) => c.id == w.$1);
        expect(choice.action, w.$2, reason: id);
        final deal = a.teachSpec!['deal'] as Map<String, dynamic>;
        expect(deal['handFamily'], w.$3, reason: id);
      }
      expect(
        _list(act('act-01-03-01-checkpoint-legal'), 'cues').single['kind'],
        'none',
      );
    });

    test('preflop fold deals trash offsuit holes', () {
      final a = act('act-01-03-01-guided-fold');
      final deal = a.teachSpec!['deal'] as Map<String, dynamic>;
      expect(deal['suitFamily'], 'offsuit');
      for (var seed = 0; seed < 16; seed++) {
        final h = dealtLessonActionSpot(a, random: Random(seed))!.heroCodes;
        expect(suit(h[0]), isNot(suit(h[1])), reason: '$seed $h');
      }
    });

    test('postflop deals stay in the authored hand class', () {
      for (final id in want.keys.skip(1)) {
        final a = act(id);
        final family =
            (a.teachSpec!['deal'] as Map<String, dynamic>)['handFamily'];
        final template = resolveLessonActionSpot(a)!;
        expect(snake(classOf(template)), family, reason: id);
        for (var seed = 0; seed < 16; seed++) {
          final spot = dealtLessonActionSpot(a, random: Random(seed))!;
          expect(snake(classOf(spot)), family, reason: '$id $seed');
          expect(spot.facingBet, template.facingBet, reason: id);
        }
      }
    });
  });

  group('Bet, raise, all-in (LPT-98)', () {
    const want = {
      'act-01-03-02-guided-bet': ('bet-half', 'BET', 'top_pair'),
      'act-01-03-02-scaffolded-raise': ('raise-15', 'RAISE', 'top_pair'),
      'act-01-03-02-unguided-allin': ('shove-12', 'ALL_IN', 'top_pair'),
      'act-01-03-02-checkpoint-names': ('named-bet', 'BET', 'air'),
    };
    int enc(String c) => FastEvaluator.encode(CardModel.fromCode(c));
    String snake(HandClass c) => c.name.replaceAllMapped(
      RegExp('[A-Z]'),
      (m) => '_${m[0]!.toLowerCase()}',
    );
    HandClass classOf(LessonActionSpot s) => HandClassifier.classify(
      enc(s.heroCodes[0]),
      enc(s.heroCodes[1]),
      [for (final b in s.boardCodes) enc(b)],
    );

    test('cues target the graded dock choice', () {
      for (final MapEntry(key: id, value: w) in want.entries) {
        final a = act(id);
        final cues = _list(a, 'cues');
        expect(cues, hasLength(1), reason: id);
        expect(cues.single['target'], w.$1, reason: id);
        final choice = a.choices.firstWhere((c) => c.id == w.$1);
        expect(choice.action, w.$2, reason: id);
        final deal = a.teachSpec!['deal'] as Map<String, dynamic>;
        expect(deal['handFamily'], w.$3, reason: id);
      }
      expect(
        _list(act('act-01-03-02-checkpoint-names'), 'cues').single['kind'],
        'none',
      );
    });

    test('postflop deals stay in the authored hand class', () {
      for (final id in want.keys) {
        final a = act(id);
        final family =
            (a.teachSpec!['deal'] as Map<String, dynamic>)['handFamily'];
        final template = resolveLessonActionSpot(a)!;
        expect(snake(classOf(template)), family, reason: id);
        for (var seed = 0; seed < 16; seed++) {
          final spot = dealtLessonActionSpot(a, random: Random(seed))!;
          expect(snake(classOf(spot)), family, reason: '$id $seed');
          expect(spot.facingBet, template.facingBet, reason: id);
          expect(spot.openPot, template.openPot, reason: id);
        }
      }
    });
  });

  group('Streets and action order (LPT-101)', () {
    test('guided streets SoftPulse targets chronological tiles', () {
      final cues = _list(act('act-01-04-01-guided-streets'), 'cues');
      expect(
        [for (final c in cues) c['target']],
        ['st-pre', 'st-flop', 'st-turn', 'st-river'],
      );
      expect(cues.every((c) => c['kind'] == 'soft_pulse'), isTrue);
      expect(act('act-01-04-01-guided-streets').teachSpec!['deal'], {
        'mode': 'none',
      });
    });

    test('scaffolded order SoftPulse includes CO seat', () {
      final a = act('act-01-04-01-scaffolded-order');
      expect(
        [for (final c in _list(a, 'cues')) c['target']],
        ['seat-utg', 'seat-hj', 'seat-co', 'seat-btn'],
      );
      expect(a.sequenceItems.map((s) => s.id).toList(), [
        'seat-utg',
        'seat-hj',
        'seat-co',
        'seat-btn',
      ]);
      expect(a.teachSpec!['deal'], {'mode': 'none'});
    });

    test('unguided-end SoftPulse matched; checkpoint kind none', () {
      expect(
        _list(act('act-01-04-01-unguided-end'), 'cues').single['target'],
        'matched',
      );
      final cp = act('act-01-04-01-checkpoint-postflop');
      final cue = _list(cp, 'cues').single;
      expect(cue['target'], 'sb-first');
      expect(cue['kind'], 'none');
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
      expect(cp.coachMedia.where((m) => m.kind == 'hint'), isEmpty);
    });
  });

  group('How pots are won (LPT-104)', () {
    test('fold-win and showdown author fixed felt cards + SoftPulse', () {
      final fold = act('act-01-05-01-guided-fold-win');
      final foldDeal = fold.teachSpec!['deal'] as Map<String, dynamic>;
      expect(foldDeal['mode'], 'fixed');
      expect((foldDeal['fixedCards'] as Map)['hero'], ['Ah', 'Kd']);
      expect(_list(fold, 'cues').single['target'], 'no-show');

      final sd = act('act-01-05-01-scaffolded-showdown');
      final sdDeal = sd.teachSpec!['deal'] as Map<String, dynamic>;
      expect(sdDeal['mode'], 'fixed');
      expect((sdDeal['fixedCards'] as Map)['board'], [
        'Qs',
        '7c',
        '2d',
        '9h',
        '3s',
      ]);
      expect(_list(sd, 'cues').single['target'], 'showdown');
    });

    test('unguided-pot variants cover open-to sizes; checkpoint kind none', () {
      final pot = act('act-01-05-01-unguided-pot');
      final deal = pot.teachSpec!['deal'] as Map<String, dynamic>;
      expect(deal['mode'], 'none');
      final variants = [
        for (final v in (deal['variants'] as List)) (v as Map)['id'] as String,
      ];
      expect(variants, [
        'open-5',
        'open-6',
        'open-7',
        'open-8',
        'open-9',
        'open-10',
      ]);
      expect(_list(pot, 'cues').single['target'], 'pot-correct');

      final cp = act('act-01-05-01-checkpoint-side');
      final cue = _list(cp, 'cues').single;
      expect(cue['target'], 'side-exists');
      expect(cue['kind'], 'none');
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
    });
  });

  group('Play a full toy hand (LPT-108)', () {
    test('multi-step SoftPulse targets match graded presses', () {
      expect(
        [
          for (final c in _list(act('act-01-06-01-guided-steps'), 'cues'))
            c['target'],
        ],
        ['open-6', 'won-folds'],
      );
      expect(
        [
          for (final c in _list(act('act-01-06-01-scaffolded-multi'), 'cues'))
            c['target'],
        ],
        ['ready-flop', 'cbet'],
      );
      final guidedDeal =
          act('act-01-06-01-guided-steps').teachSpec!['deal'] as Map;
      expect(guidedDeal['handFamily'], 'suited_ace');
      expect(guidedDeal['suitFamily'], 'suited');
    });

    test('lab and checkpoint author deal families; checkpoint kind none', () {
      final lab = act('act-01-06-01-unguided-lab');
      final labDeal = lab.teachSpec!['deal'] as Map;
      expect(labDeal['handFamily'], 'high_card');
      expect(labDeal['suitFamily'], 'offsuit');
      expect(_list(lab, 'cues').single['target'], 'call-bb');

      final cp = act('act-01-06-01-checkpoint-finish');
      final cpDeal = cp.teachSpec!['deal'] as Map;
      expect(cpDeal['handFamily'], 'broadway');
      expect(cpDeal['suitFamily'], 'offsuit');
      expect(_list(cp, 'cues').every((c) => c['kind'] == 'none'), isTrue);
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
    });
  });

  group('Section 1 jump check (LPT-110)', () {
    test('all jump_test steps author deal + kind none cues; no pressHints', () {
      const ids = [
        'act-01-06-02-jump-ranks',
        'act-01-06-02-jump-order',
        'act-01-06-02-jump-legal',
        'act-01-06-02-jump-hand',
      ];
      for (final id in ids) {
        final a = act(id);
        expect(a.assessmentRole, AssessmentRole.jumpTest, reason: id);
        expect(a.teachSpec!['deal'], isA<Map<String, dynamic>>(), reason: id);
        expect(a.teachSpec!.containsKey('pressHints'), isFalse, reason: id);
        expect(
          _list(a, 'cues').every((c) => c['kind'] == 'none'),
          isTrue,
          reason: id,
        );
      }
    });

    test('ranks/order/legal/hand deal contracts', () {
      final ranks = act('act-01-06-02-jump-ranks').teachSpec!['deal'] as Map;
      expect(ranks['handFamily'], 'flush');
      expect(
        [for (final v in (ranks['variants'] as List)) (v as Map)['handFamily']],
        ['straight', 'two_pair'],
      );
      expect(act('act-01-06-02-jump-order').teachSpec!['deal'], {
        'mode': 'none',
      });
      expect(act('act-01-06-02-jump-order').sequenceItems.map((s) => s.id), [
        'j-utg',
        'j-hj',
        'j-co',
        'j-btn',
      ]);
      final legal = act('act-01-06-02-jump-legal').teachSpec!['deal'] as Map;
      expect(legal['mode'], 'fixed');
      final hand = act('act-01-06-02-jump-hand').teachSpec!['deal'] as Map;
      expect(hand['handFamily'], 'suited_ace');
      expect(hand['suitFamily'], 'suited');
    });
  });

  group('Position labels (LPT-112)', () {
    test('seat lesson deal.mode none + SoftPulse targets', () {
      const want = {
        'act-02-01-01-guided-btn': 'pos-btn',
        'act-02-01-01-scaffolded-blinds': 'sb-bb',
        'act-02-01-01-unguided-co': 'label-co',
      };
      for (final MapEntry(key: id, value: target) in want.entries) {
        final a = act(id);
        expect(a.teachSpec!['deal'], {'mode': 'none'}, reason: id);
        expect(_list(a, 'cues').single['target'], target, reason: id);
        expect(_list(a, 'cues').single['kind'], 'soft_pulse', reason: id);
      }
      final cp = act('act-02-01-01-checkpoint-edge');
      expect(cp.teachSpec!['deal'], {'mode': 'none'});
      expect(_list(cp, 'cues').single['target'], 'prefer-btn');
      expect(_list(cp, 'cues').single['kind'], 'none');
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
    });
  });

  group('Acting order (LPT-115)', () {
    test('guided/scaffolded SoftPulse seat order; checkpoint kind none', () {
      final guided = act('act-02-01-02-guided-pre');
      expect(
        [for (final c in _list(guided, 'cues')) c['target']],
        ['ord-co', 'ord-btn', 'ord-sb'],
      );
      expect(
        _list(guided, 'cues').every((c) => c['kind'] == 'soft_pulse'),
        isTrue,
      );
      expect(guided.teachSpec!['deal'], {'mode': 'none'});

      final post = act('act-02-01-02-scaffolded-post');
      expect(
        [for (final c in _list(post, 'cues')) c['target']],
        ['post-sb', 'post-btn'],
      );
      expect(post.teachSpec!['deal'], {'mode': 'none'});

      expect(
        _list(act('act-02-01-02-unguided-wait'), 'cues').single['target'],
        'wait',
      );

      final cp = act('act-02-01-02-checkpoint-full');
      final cue = _list(cp, 'cues').single;
      expect(cue['target'], 'last-btn');
      expect(cue['kind'], 'none');
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
      expect(cp.coachMedia.where((m) => m.kind == 'hint'), isEmpty);
    });
  });

  group('Hand families (LPT-119)', () {
    test('random_in_class families + SoftPulse targets; checkpoint quiet', () {
      final pair = act('act-02-02-01-guided-pair');
      expect(pair.teachSpec!['deal'], {
        'mode': 'random_in_class',
        'handFamily': 'pair',
        'suitFamily': 'pair',
      });
      expect(_list(pair, 'cues').single['target'], 'hf-pair');
      expect(_list(pair, 'cues').single['kind'], 'soft_pulse');

      final bw = act('act-02-02-01-scaffolded-broadway');
      expect(bw.teachSpec!['deal']['handFamily'], 'broadway');
      expect(_list(bw, 'cues').single['target'], 'hf-broadway');

      final sc = act('act-02-02-01-unguided-sc');
      expect(sc.teachSpec!['deal'], {
        'mode': 'random_in_class',
        'handFamily': 'connector',
        'suitFamily': 'suited',
      });
      expect(_list(sc, 'cues').single['target'], 'hf-sc');

      final cp = act('act-02-02-01-checkpoint-trash');
      expect(cp.teachSpec!['deal'], {
        'mode': 'random_in_class',
        'handFamily': 'trash',
        'suitFamily': 'offsuit',
      });
      expect(_list(cp, 'cues').single['kind'], 'none');
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
      expect(cp.coachMedia.where((m) => m.kind == 'hint'), isEmpty);
    });
  });

  group('Open or fold baseline (LPT-122)', () {
    test('random_in_class + SoftPulse dock targets; checkpoint quiet', () {
      expect(act('act-02-03-01-guided-utg').teachSpec!['deal'], {
        'mode': 'random_in_class',
        'handFamily': 'trash',
        'suitFamily': 'offsuit',
      });
      expect(
        _list(act('act-02-03-01-guided-utg'), 'cues').single['target'],
        'fold',
      );
      expect(
        _list(act('act-02-03-01-scaffolded-qq'), 'cues').single['target'],
        'open-qq',
      );
      expect(
        act('act-02-03-01-unguided-btn').teachSpec!['deal']['suitFamily'],
        'suited',
      );
      expect(
        _list(act('act-02-03-01-unguided-btn'), 'cues').single['target'],
        'open-k9s',
      );
      final cp = act('act-02-03-01-checkpoint-hj');
      expect(_list(cp, 'cues').single['kind'], 'none');
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
    });
  });

  group('Versus an open (LPT-125)', () {
    test('random_in_class + SoftPulse dock targets; checkpoint quiet', () {
      expect(
        _list(act('act-02-04-01-guided-fold'), 'cues').single['target'],
        'fold-j3',
      );
      expect(
        act('act-02-04-01-scaffolded-call').teachSpec!['deal']['handFamily'],
        'connector',
      );
      expect(
        _list(act('act-02-04-01-unguided-3bet'), 'cues').single['target'],
        '3bet-kk',
      );
      final cp = act('act-02-04-01-checkpoint-aq');
      expect(_list(cp, 'cues').single['kind'], 'none');
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
    });
  });

  group('Effective stacks (LPT-128)', () {
    test('deal.mode none + SoftPulse tiles; checkpoint quiet', () {
      for (final e in {
        'act-02-05-01-guided-convert': 'bb-100',
        'act-02-05-01-scaffolded-eff': 'eff-60',
        'act-02-05-01-unguided-depth': 'depth-50',
      }.entries) {
        expect(act(e.key).teachSpec!['deal'], {'mode': 'none'});
        expect(_list(act(e.key), 'cues').single['target'], e.value);
      }
      final cp = act('act-02-05-01-checkpoint-200');
      expect(_list(cp, 'cues').single['kind'], 'none');
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
    });
  });

  group('Live table habits (LPT-131)', () {
    test('deal.mode none + SoftPulse habit tiles; checkpoint quiet', () {
      final explain = act('act-02-06-01-explain-habits');
      expect(
        [for (final c in _list(explain, 'cues')) c['target']],
        ['WATCH', 'SAY', 'COVER', 'WAIT'],
      );
      expect(explain.teachSpec!['deal'], {'mode': 'none'});
      expect(
        _list(act('act-02-06-01-guided-follow'), 'cues').single['target'],
        'watch',
      );
      expect(
        _list(act('act-02-06-01-scaffolded-verbal'), 'cues').single['target'],
        'say-raise',
      );
      expect(
        _list(act('act-02-06-01-unguided-protect'), 'cues').single['target'],
        'chip-on-cards',
      );
      final cp = act('act-02-06-01-checkpoint-oot');
      expect(_list(cp, 'cues').single['kind'], 'none');
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
    });
  });

  group('Full-ring baseline hand (LPT-135)', () {
    test('class deals + SoftPulse; habit checkpoint quiet', () {
      expect(
        act('act-02-07-01-guided-ep').teachSpec!['deal']['handFamily'],
        'broadway',
      );
      expect(
        _list(act('act-02-07-01-guided-ep'), 'cues').single['target'],
        'open-ajs',
      );
      expect(
        _list(act('act-02-07-01-scaffolded-vs'), 'cues').single['target'],
        'call-22',
      );
      expect(
        _list(act('act-02-07-01-unguided-lab'), 'cues').single['target'],
        'lab-3bet',
      );
      final cp = act('act-02-07-01-checkpoint-habit');
      expect(cp.teachSpec!['deal'], {'mode': 'none'});
      expect(_list(cp, 'cues').single['kind'], 'none');
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
    });
  });

  group('Baseline jump check (LPT-137)', () {
    test('all jump_test steps author deal + kind none cues; no pressHints', () {
      const ids = [
        'act-02-07-02-jump-pos',
        'act-02-07-02-jump-family',
        'act-02-07-02-jump-open',
        'act-02-07-02-jump-vs',
        'act-02-07-02-jump-stack',
      ];
      for (final id in ids) {
        final a = act(id);
        expect(a.assessmentRole, AssessmentRole.jumpTest, reason: id);
        expect(a.teachSpec!['deal'], isA<Map<String, dynamic>>(), reason: id);
        expect(a.teachSpec!.containsKey('pressHints'), isFalse, reason: id);
        expect(
          _list(a, 'cues').every((c) => c['kind'] == 'none'),
          isTrue,
          reason: id,
        );
      }
    });

    test('pos/family/open/vs/stack deal contracts', () {
      expect(act('act-02-07-02-jump-pos').teachSpec!['deal'], {'mode': 'none'});
      final family = act('act-02-07-02-jump-family').teachSpec!['deal'] as Map;
      expect(family['handFamily'], 'suited_ace');
      expect(family['suitFamily'], 'suited');
      final open = act('act-02-07-02-jump-open').teachSpec!['deal'] as Map;
      expect(open['handFamily'], 'trash');
      expect(open['suitFamily'], 'offsuit');
      final vs = act('act-02-07-02-jump-vs').teachSpec!['deal'] as Map;
      expect(vs['mode'], 'fixed');
      expect((vs['fixedCards'] as Map)['hero'], ['Ah', 'Ad']);
      expect(act('act-02-07-02-jump-stack').teachSpec!['deal'], {
        'mode': 'none',
      });
    });
  });

  group('Read the table first (LPT-138)', () {
    test('explain SoftPulse walks POT → STACKS → BUTTON → WHO ACTS', () {
      expect(
        _list(
          act('act-03-01-01-explain'),
          'cues',
        ).map((c) => c['target']).toList(),
        ['POT', 'STACKS', 'BUTTON', 'WHO ACTS'],
      );
    });

    test('guided/scaffolded SoftPulse; checkpoint quiet', () {
      expect(
        _list(act('act-03-01-01-guided'), 'cues').single['target'],
        'pot-21',
      );
      expect(
        _list(act('act-03-01-01-scaffolded'), 'cues').single['target'],
        'utg-first',
      );
      expect(
        _list(act('act-03-01-01-unguided'), 'cues').single['target'],
        'bound',
      );
      final cp = act('act-03-01-01-checkpoint');
      expect(cp.assessmentRole, AssessmentRole.checkpoint);
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
      expect(_list(cp, 'cues').single['kind'], 'none');
      expect(_list(cp, 'cues').single['target'], 'eff-55');
    });
  });

  group('Name your flop class (LPT-141)', () {
    test('explain SoftPulse walks MADE → DRAW → SDV → AIR', () {
      expect(
        _list(
          act('act-03-02-01-explain'),
          'cues',
        ).map((c) => c['target']).toList(),
        ['MADE', 'DRAW', 'SDV', 'AIR'],
      );
    });

    test('classify steps author fixed deals; checkpoint quiet', () {
      final g = act('act-03-02-01-guided').teachSpec!['deal'] as Map;
      expect(g['mode'], 'fixed');
      expect((g['fixedCards'] as Map)['hero'], ['Kh', 'Qh']);
      expect(
        _list(act('act-03-02-01-scaffolded'), 'cues').single['target'],
        'nfd',
      );
      expect(
        _list(act('act-03-02-01-unguided'), 'cues').single['target'],
        'air',
      );
      final cp = act('act-03-02-01-checkpoint');
      expect(cp.assessmentRole, AssessmentRole.checkpoint);
      expect(cp.teachSpec!.containsKey('pressHints'), isFalse);
      expect(_list(cp, 'cues').single['kind'], 'none');
      expect(_list(cp, 'cues').single['target'], 'oesd');
      final d = cp.teachSpec!['deal'] as Map;
      expect((d['fixedCards'] as Map)['hero'], ['Js', '8d']);
    });
  });
}
