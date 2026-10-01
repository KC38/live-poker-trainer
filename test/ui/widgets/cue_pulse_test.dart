/// CuePulse / GlowHighlight gold ring sits outside the child with even room.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/widgets/glow_highlight.dart';

void main() {
  testWidgets('reserved SoftPulse ring keeps outset around the child', (
    tester,
  ) async {
    const pad = EdgeInsets.all(GlowHighlight.outset);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlowHighlight(
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

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);
    final child = tester.getRect(
      find.byKey(const ValueKey<String>('pulse-child')),
    );
    final ring = tester.getRect(
      find.byKey(const ValueKey<String>('glow-highlight-ring')),
    );

    expect(GlowHighlight.outset, 6);
    expect(GlowHighlight.softBleed, 8);
    expect(GlowHighlight.gutter, GlowHighlight.outset * 2);
    expect(ring.top, closeTo(child.top - pad.top, 0.5));
    expect(ring.left, closeTo(child.left - pad.left, 0.5));
    expect(ring.right, closeTo(child.right + pad.right, 0.5));
    expect(ring.bottom, closeTo(child.bottom + pad.bottom, 0.5));
    // softBleed is reserved outside the ring so neighbors stay clear.
    expect(ring.width, closeTo(80 + pad.horizontal, 0.5));
    expect(ring.height, closeTo(60 + pad.vertical, 0.5));
  });

  testWidgets('reserved SoftPulse keeps the same face size when SoftPulse toggles', (
    tester,
  ) async {
    Future<Size> pumpActive(bool active) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 120,
                height: 80,
                child: GlowHighlight(
                  active: active,
                  animated: false,
                  child: const ColoredBox(
                    key: ValueKey<String>('pulse-child'),
                    color: Color(0xFF112233),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      return tester.getSize(find.byKey(const ValueKey<String>('pulse-child')));
    }

    final off = await pumpActive(false);
    final on = await pumpActive(true);
    expect(on, off);
    // Face is inset by outset on each side inside the fixed outer box.
    expect(off.width, closeTo(120 - 2 * GlowHighlight.softBleed - 2 * GlowHighlight.outset, 0.5));
    expect(off.height, closeTo(80 - 2 * GlowHighlight.softBleed - 2 * GlowHighlight.outset, 0.5));
  });

  testWidgets('felt SoftPulse paints the ring outside the child box', (
    tester,
  ) async {
    const pad = EdgeInsets.all(GlowHighlight.outset);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlowHighlight(
              reserveLayout: false,
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

    final child = tester.getRect(
      find.byKey(const ValueKey<String>('pulse-child')),
    );
    final ring = tester.getRect(
      find.byKey(const ValueKey<String>('glow-highlight-ring')),
    );
    expect(ring.top, closeTo(child.top - pad.top, 0.5));
    expect(ring.left, closeTo(child.left - pad.left, 0.5));
    expect(ring.right, closeTo(child.right + pad.right, 0.5));
    expect(ring.bottom, closeTo(child.bottom + pad.bottom, 0.5));
  });

  testWidgets('inactive felt SoftPulse draws the child only', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlowHighlight(
            active: false,
            reserveLayout: false,
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

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsNothing);
    expect(find.byKey(const ValueKey<String>('pulse-child')), findsOneWidget);
  });

  testWidgets('GlowHighlight wraps arbitrary children for reuse', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlowHighlight(
            child: Row(
              key: const ValueKey<String>('group-child'),
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(width: 20, height: 28),
                SizedBox(width: 20, height: 28),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey<String>('glow-highlight')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('group-child')), findsOneWidget);
  });
}
