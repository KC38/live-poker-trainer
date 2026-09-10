/// Leak Finder: leaks grouped by opponent, with the boundary stated once.
///
/// The case worth guarding is the one that confused players: against the same
/// opponent, "folded, call was best" and "called, fold was best" sit next to
/// each other. Grouped under the threshold that produced both, they read as
/// one line missed from either side instead of contradictory advice.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/leak_finder_section.dart';

final _now = DateTime(2026, 9, 7, 3, 25);

MistakeSummary _leak({
  required String key,
  required MistakeTag tag,
  required String archetype,
  required String taken,
  required String best,
  String street = 'preflop',
  int count = 1,
  double evLostBb = 1,
}) {
  return MistakeSummary(
    key: key,
    tag: tag,
    street: street,
    archetype: archetype,
    taken: taken,
    best: best,
    count: count,
    lastSeen: _now.subtract(const Duration(minutes: 3)),
    improvements: 0,
    currentStreak: 0,
    lastEventWasImprovement: false,
    evLostBb: evLostBb,
  );
}

/// The shape of the screenshot that started this: both directions vs a LAG,
/// plus a single one-directional leak against a nit.
final _twoSidedVsLag = MistakeStats(
  totalMistakes: 8,
  totalImprovements: 1,
  topMistakes: [
    _leak(
      key: 'preflop:lag:fold->call',
      tag: MistakeTag.foldingTooMuchVsAggro,
      archetype: 'LAG',
      taken: 'fold',
      best: 'call',
      count: 3,
      evLostBb: 1.4,
    ),
    _leak(
      key: 'preflop:lag:call->fold',
      tag: MistakeTag.chasingVsAggro,
      archetype: 'LAG',
      taken: 'call',
      best: 'fold',
      count: 3,
      evLostBb: 2.5,
    ),
    _leak(
      key: 'preflop:nit:call->fold',
      tag: MistakeTag.payingOffNits,
      archetype: 'Nit',
      taken: 'call',
      best: 'fold',
      count: 2,
      evLostBb: 0.7,
    ),
  ],
  byArchetype: {'LAG': 6, 'Nit': 2},
  byStreet: {'preflop': 8},
);

Future<void> _pump(WidgetTester tester, MistakeStats stats) async {
  tester.view.physicalSize = const Size(1000, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: buildPokerTheme(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: LeakFinderSection(stats: stats, now: _now),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('leaks are grouped under the opponent they were made against', (
    tester,
  ) async {
    await _pump(tester, _twoSidedVsLag);

    expect(find.text('vs LAG'), findsOneWidget);
    expect(find.text('vs Nit'), findsOneWidget);

    // The group carries the archetype, so rows no longer repeat it.
    expect(find.text('Preflop: folded, call was best'), findsOneWidget);
    expect(find.text('Preflop: called, fold was best'), findsNWidgets(2));
    expect(find.textContaining('Preflop vs LAG'), findsNothing);
  });

  testWidgets('each group states the boundary the coach graded against', (
    tester,
  ) async {
    await _pump(tester, _twoSidedVsLag);

    expect(find.text('Where the line is'), findsNWidgets(2));

    // The rule the player is shown is the price arithmetic the grader
    // actually uses, not a minimum hand to call with.
    expect(
      find.textContaining('a half-pot bet needs 33% equity'),
      findsNWidgets(2),
    );
    expect(
      find.textContaining('the hand class alone is never the reason'),
      findsNWidgets(2),
    );

    // Each archetype's read is stated with its own numbers, so a LAG and a
    // nit cannot present the player with the same boundary.
    expect(find.textContaining('LAG fires with nothing'), findsOneWidget);
    expect(find.textContaining('Nit fires with nothing'), findsOneWidget);

    // The close band is stated apart from the rule, so a decision that turns
    // on price cannot read as an arbitrary flip.
    expect(find.textContaining('Too close to grade'), findsNWidgets(2));
    expect(
      find.textContaining('never scores as a mistake'),
      findsNWidgets(2),
    );
  });

  testWidgets('a group with mistakes in both directions says so', (
    tester,
  ) async {
    await _pump(tester, _twoSidedVsLag);

    expect(
      find.textContaining('Price and equity decide it'),
      findsOneWidget,
    );
  });

  testWidgets('a one-directional group is not flagged as two-sided', (
    tester,
  ) async {
    await _pump(
      tester,
      MistakeStats(
        totalMistakes: 2,
        topMistakes: [_twoSidedVsLag.topMistakes.last],
        byArchetype: {'Nit': 2},
        byStreet: {'preflop': 2},
      ),
    );

    expect(find.text('vs Nit'), findsOneWidget);
    expect(
      find.textContaining('Price and equity decide it'),
      findsNothing,
    );
  });

  testWidgets('the biggest group comes first and totals its own damage', (
    tester,
  ) async {
    await _pump(tester, _twoSidedVsLag);

    final groups = _twoSidedVsLag.archetypeGroups;
    expect(groups.map((g) => g.label), ['LAG', 'Nit']);
    expect(groups.first.mistakeCount, 6);
    expect(groups.first.evLostBb, closeTo(3.9, 0.001));
    expect(groups.first.isTwoSided, isTrue);
    expect(groups.last.isTwoSided, isFalse);

    expect(find.text('×6  '), findsOneWidget);
    expect(find.text('-3.9 BB'), findsOneWidget);
  });

  testWidgets('an empty leak finder still explains what will land here', (
    tester,
  ) async {
    await _pump(tester, const MistakeStats());

    expect(find.textContaining('No leaks recorded yet'), findsOneWidget);
    expect(find.text('Where the line is'), findsNothing);
  });
}
