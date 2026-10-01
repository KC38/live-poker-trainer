/// CuePulse gold ring sits outside the child with top breathing room.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/widgets/cue_arrows.dart';

void main() {
  testWidgets('active CuePulse expands the gold ring above the child', (
    tester,
  ) async {
    const pad = EdgeInsets.fromLTRB(4, 6, 4, 4);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CuePulse(
              padding: pad,
              child: SizedBox(
                key: ValueKey<String>('pulse-child'),
                width: 80,
                height: 60,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('cue-pulse')), findsOneWidget);
    final child = tester.getRect(
      find.byKey(const ValueKey<String>('pulse-child')),
    );
    final ring = tester.getRect(
      find.byKey(const ValueKey<String>('cue-pulse-ring')),
    );

    expect(ring.top, closeTo(child.top - pad.top, 0.5));
    expect(ring.left, closeTo(child.left - pad.left, 0.5));
    expect(ring.right, closeTo(child.right + pad.right, 0.5));
    expect(ring.bottom, closeTo(child.bottom + pad.bottom, 0.5));
    // Extra top air so hole cards are not flush with the gold line.
    expect(pad.top, greaterThan(pad.left));
  });

  testWidgets('inactive CuePulse draws the child only', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CuePulse(
            active: false,
            child: SizedBox(
              key: ValueKey<String>('pulse-child'),
              width: 40,
              height: 40,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('cue-pulse')), findsNothing);
    expect(find.byKey(const ValueKey<String>('pulse-child')), findsOneWidget);
  });
}
