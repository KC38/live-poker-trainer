/// CuePulse / GlowHighlight gold ring sits outside the child with even room.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_soft_pulse_scope.dart';
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
    // SoftPulse cues one tile at a time — gutter clears a single outset.
    expect(GlowHighlight.gutter, GlowHighlight.outset);
    expect(ring.top, closeTo(child.top - pad.top, 0.5));
    expect(ring.left, closeTo(child.left - pad.left, 0.5));
    expect(ring.right, closeTo(child.right + pad.right, 0.5));
    expect(ring.bottom, closeTo(child.bottom + pad.bottom, 0.5));
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
    // Face is inset by outset only (no per-tile softBleed).
    expect(off.width, closeTo(120 - 2 * GlowHighlight.outset, 0.5));
    expect(off.height, closeTo(80 - 2 * GlowHighlight.outset, 0.5));
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

  testWidgets('inactive felt SoftPulse keeps the child mounted', (tester) async {
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
    final ring = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey<String>('glow-highlight-ring')),
    );
    expect(ring.decoration, const BoxDecoration());
  });

  testWidgets('toggling felt SoftPulse does not remount the child', (
    tester,
  ) async {
    var mounts = 0;

    Widget host(bool active, {bool allowed = true}) {
      return MaterialApp(
        home: Scaffold(
          body: LessonSoftPulseScope(
            allowed: allowed,
            child: GlowHighlight(
              active: active,
              reserveLayout: false,
              child: _MountProbe(onMount: () => mounts += 1),
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(host(true));
    await tester.pump();
    expect(mounts, 1);

    await tester.pumpWidget(host(false));
    await tester.pump();
    expect(mounts, 1);

    await tester.pumpWidget(host(true, allowed: false));
    await tester.pump();
    expect(mounts, 1);

    await tester.pumpWidget(host(true));
    await tester.pump();
    expect(mounts, 1);
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

class _MountProbe extends StatefulWidget {
  const _MountProbe({required this.onMount});

  final VoidCallback onMount;

  @override
  State<_MountProbe> createState() => _MountProbeState();
}

class _MountProbeState extends State<_MountProbe> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(width: 12, height: 12);
  }
}
