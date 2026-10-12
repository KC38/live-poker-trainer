/// Lessons that follow the Your two cards pilot author `teachSpec` on every
/// interactive step (docs/agents/11-lesson-content-agent.md). Each content
/// ticket adds its lesson to [_lessons] plus any lesson-specific checks.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
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
}
