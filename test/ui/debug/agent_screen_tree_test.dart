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

  testWidgets(
    'seat Semantics above hero SoftPulse reports gold (LPT-840)',
    (tester) async {
      // Face-down hero SoftPulse wraps GlowHighlight under seat Semantics —
      // the same nesting as PlayerSeatWidget hole backs.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Semantics(
                button: true,
                label: 'Your hole cards',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlowHighlight(
                      active: true,
                      animated: true,
                      child: SizedBox(
                        width: 40,
                        height: 56,
                        child: ColoredBox(color: Colors.red.shade900),
                      ),
                    ),
                    const SizedBox(width: 4),
                    GlowHighlight(
                      active: true,
                      animated: true,
                      child: SizedBox(
                        width: 40,
                        height: 56,
                        child: ColoredBox(color: Colors.red.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final tree = describeAgentScreen();
      expect(_entry(tree, 'Your hole cards')['glow'], 'gold');
      expect(tree['gold'], contains('Your hole cards'));
    },
  );

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

  testWidgets(
    'IndexedStack Offstage tabs are hidden from tree (LPT-876)',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IndexedStack(
              index: 1,
              children: const [
                _NamedHomeScreen(label: 'Your two cards'),
                _NamedLiveTrainingScreen(label: 'Create an account before Live Training.'),
                _NamedProfileScreen(label: 'GUEST'),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      final tree = describeAgentScreen();
      final labels = [
        for (final e in (tree['entries']! as List)) e['label'],
      ];
      expect(tree['screen'], '_NamedLiveTrainingScreen');
      expect(labels, contains('Create an account before Live Training.'));
      expect(labels, isNot(contains('Your two cards')));
      expect(labels, isNot(contains('GUEST')));
    },
  );
}

class _NamedHomeScreen extends StatelessWidget {
  const _NamedHomeScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(child: Text(label));
}

class _NamedLiveTrainingScreen extends StatelessWidget {
  const _NamedLiveTrainingScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(child: Text(label));
}

class _NamedProfileScreen extends StatelessWidget {
  const _NamedProfileScreen({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Center(child: Text(label));
}
