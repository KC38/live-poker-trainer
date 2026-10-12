/// Locks the `tree` agent query: labels, tap state, and glow on screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_soft_pulse_scope.dart';
import 'package:live_poker_trainer/ui/debug/agent_screen_tree.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';

Map<String, Object?> _entry(Map<String, Object?> tree, String label) {
  final entries = (tree['entries']! as List).cast<Map<String, Object?>>();
  return entries.firstWhere((e) => e['label'] == label);
}

void main() {
  testWidgets('reports tap state, gold cue, and cyan selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const GlowHighlight(child: Text('A♠')),
              const GlowHighlight(
                kind: GlowKind.selection,
                ignoreSoftPulse: true,
                child: Text('K♥'),
              ),
              const GlowHighlight(active: false, child: Text('Q♦')),
              FilledButton(onPressed: () {}, child: const Text('CHECK')),
              const FilledButton(onPressed: null, child: Text('HINT')),
            ],
          ),
        ),
      ),
    );

    final tree = describeAgentScreen();
    expect(_entry(tree, 'A♠')['glow'], 'gold');
    expect(_entry(tree, 'K♥')['glow'], 'cyan');
    expect(_entry(tree, 'Q♦')['glow'], isNull);
    expect(_entry(tree, 'CHECK')['tap'], 'enabled');
    expect(_entry(tree, 'HINT')['tap'], 'disabled');
    expect(_entry(tree, 'A♠')['tap'], isNull);
    expect(tree['gold'], ['A♠']);
  });

  testWidgets('a closed SoftPulse wave hides gold but keeps selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LessonSoftPulseScope(
            allowed: false,
            child: Column(
              children: [
                GlowHighlight(child: Text('Hint target')),
                GlowHighlight(
                  kind: GlowKind.selection,
                  ignoreSoftPulse: true,
                  child: Text('Picked'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final tree = describeAgentScreen();
    expect(_entry(tree, 'Hint target')['glow'], isNull);
    expect(_entry(tree, 'Picked')['glow'], 'cyan');
    expect(tree['gold'], isEmpty);
  });

  testWidgets('only the current route is described', (tester) async {
    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        home: const Scaffold(body: Text('Buried home')),
      ),
    );
    nav.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: Text('On top'))),
      ),
    );
    await tester.pumpAndSettle();

    final labels = [
      for (final e in (describeAgentScreen()['entries']! as List)) e['label'],
    ];
    expect(labels, contains('On top'));
    expect(labels, isNot(contains('Buried home')));
  });
}
