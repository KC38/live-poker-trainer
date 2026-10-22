/// Choice / number drills on the full poker table (Kushal: SPR drill should
/// look like a hand — players around the felt, pot in the middle, stacks on
/// the seats, answers in the action-button row).
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
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';
import 'package:live_poker_trainer/ui/widgets/table_features.dart';

final _catalog = CourseCatalog.fromJson(
  jsonDecode(File('assets/course/v2/catalog.json').readAsStringSync())
      as Map<String, dynamic>,
);

({String lessonId, CourseActivity activity}) _step(String id) {
  for (final s in _catalog.sections) {
    for (final u in s.units) {
      for (final l in u.lessons) {
        for (final a in l.activities) {
          if (a.id == id) return (lessonId: l.id, activity: a);
        }
      }
    }
  }
  throw StateError('missing $id');
}

LessonTableDrillSpec _spec(String id) =>
    resolveLessonTableDrillSpec(activity: _step(id).activity);

Widget _host(Widget child, {String lessonId = 'lesson-04-10-02'}) {
  return ProviderScope(
    child: MaterialApp(
      theme: buildPokerTheme(),
      home: Scaffold(
        body: TableFeaturesScope(
          features: TableFeatures.forLessonId(lessonId),
          child: child,
        ),
      ),
    ),
  );
}

void main() {
  group('resolveLessonTableDrillSpec', () {
    test('SPR jump: 60bb stacks, 15bb pot, past preflop, in big blinds', () {
      final spec = _spec('act-04-10-02-jump-spr');
      expect(spec.showInBigBlinds, isTrue);
      expect(spec.heroStackChips, 120);
      expect(spec.villainStackChips, 120);
      expect(spec.potChips, 30);
      expect(spec.postflop, isTrue);
      expect(spec.format(spec.potChips!), '15 BB');
      expect(spec.format(spec.heroStackChips!), '60 BB');
      // Heads-up: one live opponent, the other four folded.
      expect(spec.liveVillainPositions, hasLength(1));
      expect(spec.foldedSeatIndexes, hasLength(4));
    });

    test('SPR guided: effective stack 80bb, pot 20bb', () {
      final spec = _spec('act-04-05-01-guided');
      expect(spec.format(spec.heroStackChips!), '80 BB');
      expect(spec.format(spec.potChips!), '20 BB');
    });

    test('effective stack: hero and villain stacks differ', () {
      final spec = _spec('act-02-07-02-jump-stack');
      expect(spec.format(spec.heroStackChips!), '120 BB');
      expect(spec.format(spec.villainStackChips!), '55 BB');
    });

    test('bb convert stays in dollars so the felt never shows the answer', () {
      final convert = _spec('act-02-05-01-guided-convert');
      expect(convert.showInBigBlinds, isFalse);
      expect(convert.heroStackChips, 200);
      expect(convert.bigBlind, 2);
      final checkpoint = _spec('act-02-05-01-checkpoint-200');
      expect(checkpoint.heroStackChips, 1000);
      expect(checkpoint.smallBlind, 2);
      expect(checkpoint.bigBlind, 5);
    });

    test('pot count: chips in front of seats add to the answer, pot hidden', () {
      final spec = _spec('act-03-01-01-guided');
      expect(spec.hidePot, isTrue);
      final total = spec.streetBets!.fold<double>(0, (a, b) => a + b);
      expect(total, 19);
      expect(spec.seatActionLabels[spec.seatIndexOf('UTG')], 'RAISE');
      expect(spec.seatActionLabels[0], 'CALL');
      expect(spec.seatActionLabels[spec.seatIndexOf('BB')], 'CALL');
      // SB folded its posted blind; HJ / CO folded too.
      expect(spec.foldedSeatIndexes, containsAll([
        spec.seatIndexOf('SB'),
        spec.seatIndexOf('HJ'),
        spec.seatIndexOf('CO'),
      ]));
    });

    test('call price: 20 in the middle plus their 10', () {
      final spec = _spec('act-03-03-01-scaffolded');
      expect(spec.potChips, 30);
      expect(spec.streetBets![spec.seatIndexOf('BTN')], 10);
    });

    test('player-count words set live opponents', () {
      expect(_spec('act-05-01-01-guided').liveVillainPositions, hasLength(3));
      expect(_spec('act-07-05-01-guided').liveVillainPositions, hasLength(3));
    });

    test('hero seat follows the copy', () {
      expect(_spec('act-07-01-01-scaffolded').heroPosition, 'BTN');
      final spec = resolveLessonTableDrillSpec(
        activity: _step('act-04-10-02-jump-spr').activity,
        caption: 'You are in the big blind',
      );
      expect(spec.heroPosition, 'BB');
      expect(spec.seatIndexOf('BB'), 0);
    });
  });

  group('LessonTableDrillActionRow', () {
    testWidgets('three answers share one row; taps grade; pulse glows', (
      tester,
    ) async {
      final taps = <String>[];
      await tester.pumpWidget(
        _host(
          LessonTableDrillActionRow(
            options: [
              for (final label in const ['SPR 4', 'SPR 2', 'SPR 8'])
                LessonTableDrillOption(
                  label: label,
                  highlighted: label == 'SPR 4',
                  onTap: () => taps.add(label),
                ),
            ],
          ),
        ),
      );
      final y = {
        for (var i = 0; i < 3; i++)
          tester.getCenter(find.byKey(ValueKey('drill-option-$i'))).dy,
      };
      expect(y, hasLength(1));
      await tester.tap(find.text('SPR 2'));
      expect(taps, ['SPR 2']);
      final glows = tester
          .widgetList<GlowHighlight>(find.byType(GlowHighlight))
          .where((g) => g.active);
      expect(glows, hasLength(1));
    });

    testWidgets('four answers wrap two by two', (tester) async {
      await tester.pumpWidget(
        _host(
          LessonTableDrillActionRow(
            options: [
              for (final label in const ['A', 'B', 'C', 'D'])
                LessonTableDrillOption(label: label, onTap: () {}),
            ],
          ),
        ),
      );
      final a = tester.getCenter(find.byKey(const ValueKey('drill-option-0')));
      final c = tester.getCenter(find.byKey(const ValueKey('drill-option-2')));
      expect(c.dy, greaterThan(a.dy));
    });

    testWidgets('locked row ignores taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          LessonTableDrillActionRow(
            enabled: false,
            options: [LessonTableDrillOption(label: 'X', onTap: () => taps++)],
          ),
        ),
      );
      await tester.tap(find.text('X'));
      expect(taps, 0);
    });
  });

  testWidgets('SPR drill in the lesson frame: full table, pot, stacks, dock', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final step = _step('act-04-10-02-jump-spr');
    final controller = LessonActivityController(activity: step.activity);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        LessonFrameScope(
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
        lessonId: step.lessonId,
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson-table-drill-scene')), findsOneWidget);
    expect(find.byKey(const ValueKey('outcome-phases-felt')), findsNothing);
    expect(find.textContaining('POT 15 BB'), findsOneWidget);
    expect(find.text('60 BB'), findsWidgets);
    // Six seats around the felt: hero + five opponents.
    expect(find.text('You'), findsOneWidget);
    for (final label in const ['SPR 4', 'SPR 2', 'SPR 8']) {
      expect(find.text(label), findsOneWidget);
    }
    // Answers sit under the felt, in one row.
    final feltBottom = tester.getBottomLeft(find.byType(FeltTableView)).dy;
    expect(tester.getTopLeft(find.text('SPR 4')).dy, greaterThan(feltBottom));

    await tester.tap(find.text('SPR 4'));
    await tester.pump();
    expect(controller.draft.choiceId, 'spr-4');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('outs drill: board and holes on the table, out cards below', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final step = _step('act-03-03-01-guided');
    final controller = LessonActivityController(activity: step.activity);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        LessonFrameScope(
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
        lessonId: step.lessonId,
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const ValueKey('outs-clean-aces-table')), findsOneWidget);
    expect(find.byKey(const ValueKey('outs-clean-aces-felt')), findsNothing);
    expect(find.byType(FeltTableView), findsOneWidget);
    expect(find.text('No clean outs'), findsOneWidget);
    await tester.tap(find.text('No clean outs'));
    await tester.pump();
    expect(controller.draft.choiceId, 'outs-0');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });
}
