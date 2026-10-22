/// Every lesson step draws the full poker table in the lesson frame.
///
/// Choice / number drills (SPR 4 / 2 / 8, player types, pot math, …) used to
/// render a standalone green panel of answer tiles. They now sit on the
/// six-max table — players around the ring, the pot in the middle, stacks on
/// the seats — with the answers in the action-button row. This contract pumps
/// every catalog step at 375×812 inside the lesson frame and fails when one
/// renders without the table, unless `content/course/v2/table_layout_allowlist.json`
/// lists it with a reason. Drill felts must also match their own copy: every
/// stack / pot amount the prompt states shows on the felt, and a numeric
/// answer the prompt does not state never shows as the pot.
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/ui/course/activity_registry.dart';
import 'package:live_poker_trainer/ui/course/lesson_activity_controller.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_frame_scope.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_drill_scene.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/felt_table_view.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

typedef _Step = ({String lessonId, CourseActivity activity});

List<_Step> _catalogSteps() {
  final catalog = CourseCatalog.fromJson(
    jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  return [
    for (final section in catalog.sections)
      for (final unit in section.units)
        for (final lesson in unit.lessons)
          for (final activity in lesson.activities)
            (lessonId: lesson.id, activity: activity),
  ];
}

Map<String, String> _allowlist() {
  final raw =
      jsonDecode(
            File(
              'content/course/v2/table_layout_allowlist.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  return (raw['allow'] as Map<String, dynamic>).map(
    (id, reason) => MapEntry(id, reason as String),
  );
}

/// Choice grading lives in the server bank; the client catalog only has ids.
Map<String, String> _recommendedLabels() {
  final bank =
      jsonDecode(
            File('content/course/v2/course.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  final out = <String, String>{};
  void walk(Object? node) {
    if (node is List) {
      node.forEach(walk);
    } else if (node is Map) {
      final choices = node['choices'];
      if (node['id'] is String && choices is List) {
        for (final c in choices) {
          if (c is Map &&
              (c['grading'] as Map?)?['grade'] == 'recommended' &&
              c['label'] is String) {
            out[node['id'] as String] = c['label'] as String;
          }
        }
      }
      node.values.forEach(walk);
    }
  }

  walk(bank);
  return out;
}

Future<LessonActivityController> _pumpFramed(
  WidgetTester tester,
  _Step step,
) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  final controller = LessonActivityController(activity: step.activity);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: buildPokerTheme(),
        home: Scaffold(
          body: TableFeaturesScope(
            features: TableFeatures.forLessonId(step.lessonId),
            child: LessonFrameScope(
              onLocalMiss: (_) {},
              activityController: controller,
              child: Column(
                children: [
                  Expanded(
                    child: activityRegistry.build(
                      activity: step.activity,
                      controller: controller,
                      showGuidance: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  return controller;
}

Future<void> _unmount(
  WidgetTester tester,
  LessonActivityController controller,
) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 10));
  controller.dispose();
  tester.view.reset();
}

List<String> _feltTexts(WidgetTester tester) => [
  for (final text in tester.widgetList<Text>(
    find.descendant(
      of: find.byType(FeltTableView),
      matching: find.byType(Text),
    ),
  ))
    if (text.data != null) text.data!,
];

/// Problems with a drill felt versus the step's own copy.
List<String> drillMoneyProblems({
  required String prompt,
  required List<String> feltTexts,
  String? recommendedLabel,
}) {
  final problems = <String>[];
  final felt = feltTexts.join(' | ');
  final potPill = RegExp(r'POT (\$?[\d.]+(?: BB)?)').firstMatch(felt)?.group(1);
  double? potValue() =>
      potPill == null ? null : double.tryParse(potPill.replaceAll(RegExp(r'[^\d.]'), ''));

  // Stated stack / depth amounts in big blinds must show on a seat or the pot.
  for (final m in RegExp(r'(?<![\d–-])(\d+)\s*bb\b', caseSensitive: false)
      .allMatches(prompt)) {
    final after = prompt.substring(m.end);
    if (after.startsWith(RegExp(r'\s*[–-]'))) continue; // range "150–300bb"
    final n = m.group(1)!;
    if (!RegExp('(^|[^\\d])$n BB').hasMatch(felt)) {
      problems.add('prompt says ${n}bb but the felt never shows $n BB');
    }
  }
  // Stated chips ("You have 200 chips") show on the hero seat.
  for (final m in RegExp(r'(\d+)\s*chips', caseSensitive: false)
      .allMatches(prompt)) {
    if (!felt.contains('\$${m.group(1)}')) {
      problems.add('prompt says ${m.group(1)} chips but no seat shows \$${m.group(1)}');
    }
  }
  // Stated pot shows in the pill (plus any bet the prompt names on top).
  final pot = RegExp(r'\bpot\s*(?:is\s*)?(\d+)\b', caseSensitive: false)
      .firstMatch(prompt);
  if (pot != null) {
    final stated = double.parse(pot.group(1)!);
    final bet = RegExp(r'bets\s*(\d+)', caseSensitive: false).firstMatch(prompt);
    final allowed = {
      stated,
      if (bet != null) stated + double.parse(bet.group(1)!),
    };
    final shown = potValue();
    if (shown == null || !allowed.contains(shown)) {
      problems.add('prompt pot $stated but the pill shows ${potPill ?? 'nothing'}');
    }
  }
  // A numeric answer the prompt does not state must never be the pot pill.
  final answer = RegExp(r'^\s*(\d+)\s*(bb)?\s*$', caseSensitive: false)
      .firstMatch(recommendedLabel ?? '');
  if (answer != null &&
      !RegExp('\\b${answer.group(1)}\\b').hasMatch(prompt) &&
      potValue() == double.parse(answer.group(1)!)) {
    problems.add('pot pill spoils the answer ${answer.group(1)}');
  }
  if (RegExp(r'pot now\?', caseSensitive: false).hasMatch(prompt) &&
      potPill != null) {
    problems.add('pot-count question shows the pot total $potPill');
  }
  return problems;
}

void main() {
  final steps = _catalogSteps();
  final allow = _allowlist();
  final recommended = _recommendedLabels();
  final violations = <String>[];
  var drills = 0;

  for (final step in steps) {
    final a = step.activity;
    testWidgets('table layout: ${a.id}', (tester) async {
      final controller = await _pumpFramed(tester, step);
      final exception = tester.takeException();
      final onTable = find.byType(FeltTableView).evaluate().isNotEmpty;
      final panel =
          find.byKey(const ValueKey('outcome-phases-felt')).evaluate().isNotEmpty ||
          find.byKey(const ValueKey('outs-clean-aces-felt')).evaluate().isNotEmpty;
      if (exception != null) {
        violations.add('${a.id}: threw while rendering: $exception');
      }
      if (allow.containsKey(a.id)) {
        if (onTable) {
          violations.add('${a.id}: allowlisted but already on the table — drop it');
        }
      } else {
        if (!onTable) violations.add('${a.id}: renders without the poker table');
        if (panel) violations.add('${a.id}: still draws a standalone answer panel');
      }
      if (find.byKey(const ValueKey('lesson-table-drill-scene')).evaluate().isNotEmpty) {
        drills += 1;
        for (final p in drillMoneyProblems(
          prompt: a.prompt ?? '',
          feltTexts: _feltTexts(tester),
          recommendedLabel: recommended[a.id],
        )) {
          violations.add('${a.id}: $p');
        }
      }
      await _unmount(tester, controller);
    });
  }

  test('every lesson step is on the table (allowlist only with reasons)', () {
    expect(drills, greaterThanOrEqualTo(180));
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  group('drillMoneyProblems', () {
    test('accepts SPR felt that shows stack and pot', () {
      expect(
        drillMoneyProblems(
          prompt: 'Stack 60bb, pot 15bb. SPR?',
          feltTexts: const ['You', '60 BB', 'POT 15 BB'],
          recommendedLabel: '4',
        ),
        isEmpty,
      );
    });
    test('flags a missing stack, a wrong pot, and a spoiled pot answer', () {
      expect(
        drillMoneyProblems(
          prompt: 'Stack 60bb, pot 15bb. SPR?',
          feltTexts: const ['You', '\$200', 'POT 4 BB'],
          recommendedLabel: '4',
        ),
        hasLength(3),
      );
      expect(
        drillMoneyProblems(
          prompt: 'Blinds 1/2. UTG opens to 6, BTN calls, BB calls. Pot now?',
          feltTexts: const ['PREFLOP  ·  POT \$19'],
          recommendedLabel: '19',
        ),
        hasLength(2),
      );
    });
  });
}
