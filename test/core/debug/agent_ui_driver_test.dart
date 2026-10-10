/// Exact-match rules and route choice for debug agent taps.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/debug/agent_commands.dart';
import 'package:live_poker_trainer/core/debug/agent_ui_driver.dart';

void main() {
  test('short lesson CTAs match only the exact label', () {
    const ctas = [
      'continue',
      'check',
      'got it',
      'try again',
      'undo last',
      'hint',
      'back',
    ];
    for (final cta in ctas) {
      expect(agentTapLabelMatches(cta, cta), isTrue, reason: cta);
      expect(
        agentTapLabelMatches(cta, 'prefix $cta suffix'),
        isFalse,
        reason: cta,
      );
    }
    expect(agentTapLabelMatches('Check', 'CHECK'), isTrue);
    expect(agentTapLabelMatches('check', 'Fold, check, call'), isFalse);
    expect(agentTapLabelMatches('continue', 'continue on home'), isFalse);
    expect(agentTapLabelMatches('back', 'back to the flop'), isFalse);
  });

  test('SoftPulse tiles do not fuzzy-match longer lesson titles', () {
    const labels = [
      'value',
      'c-bet',
      'cbet',
      'call',
      'fold',
      'raise',
      'clean',
      'dirty',
      'price',
      'thin',
      'catch',
      'barrels',
      'brick',
      'change',
      'barrel',
      'delay',
      'jam',
      'quit',
      'guard',
      'first',
      '3bet',
      '4bet',
      'depth',
      'high commit',
      '300bb deep',
      'avoid ego',
      'ego 4-bet',
      'spr / commit',
      'felt suits',
      'small c-bet',
      'jam forever',
    ];
    for (final label in labels) {
      expect(agentTapLabelMatches(label, label), isTrue, reason: label);
      expect(
        agentTapLabelMatches(label, 'lesson: thin $label and bluff-catches'),
        isFalse,
        reason: label,
      );
    }
    expect(agentTapLabelMatches('value', 'Value'), isTrue);
    expect(agentTapLabelMatches('call', 'call the river'), isFalse);
    expect(agentTapLabelMatches('fold', 'call'), isFalse);
    expect(
      agentTapLabelMatches(
        'depth',
        'resume navigate 3-bet and 4-bet pots by depth',
      ),
      isFalse,
    );
    expect(
      agentTapLabelMatches(
        'high commit',
        '100bb 4-bet pot · top pair — tap High commit.',
      ),
      isFalse,
    );
  });

  test('You and Them match seat captions, not mid-sentence copy', () {
    expect(agentTapLabelMatches('you', 'You'), isTrue);
    expect(agentTapLabelMatches('you', 'You (AQ)'), isTrue);
    expect(agentTapLabelMatches('you', 'you(AQ)'), isTrue);
    expect(agentTapLabelMatches('you', 'Your hole cards'), isTrue);
    expect(agentTapLabelMatches('you', 'your holes'), isTrue);
    expect(agentTapLabelMatches('you', 'where you left off'), isFalse);

    expect(agentTapLabelMatches('them', 'Them'), isTrue);
    expect(agentTapLabelMatches('them', 'Them (KQ)'), isTrue);
    expect(agentTapLabelMatches('them', 'Them—folded'), isTrue);
    expect(agentTapLabelMatches('them', 'see them fold'), isFalse);
  });

  test('longer teach labels still match by substring', () {
    expect(agentTapLabelMatches('narrow', 'Stronger, narrower range'), isTrue);
    expect(agentTapLabelMatches('strong-narrow', 'Any two cards'), isFalse);
    expect(agentTapLabelMatches('  ', 'continue'), isFalse);
    expect(agentTapLabelMatches('continue', '   '), isFalse);
  });

  testWidgets('tap fires CONTINUE on the current route, not a buried one', (
    tester,
  ) async {
    var buried = 0;
    var current = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: FilledButton(
              onPressed: () => buried++,
              child: const Text('CONTINUE'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(
          MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: FilledButton(
                  onPressed: () => current++,
                  child: const Text('CONTINUE'),
                ),
              ),
            ),
          ),
        );
    await tester.pumpAndSettle();

    // Both buttons stay in the tree. The buried one sits lower, which is the
    // tie-break that used to win before route order was checked.
    expect(
      find.widgetWithText(FilledButton, 'CONTINUE', skipOffstage: false),
      findsNWidgets(2),
    );

    AgentUiDriver.install();
    AgentCommands.debugEmit('tap:continue');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(current, 1);
    expect(buried, 0);
  });

  testWidgets('back pops a modal bottom sheet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (_) => const SizedBox(
                      height: 120,
                      child: Center(child: Text('Hearts sheet')),
                    ),
                  );
                },
                child: const Text('Open sheet'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Hearts sheet'), findsOneWidget);

    AgentUiDriver.install();
    AgentCommands.debugEmit('back');
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Hearts sheet'), findsNothing);
  });
}
