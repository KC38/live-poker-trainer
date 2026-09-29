/// The celebrate mood plays a short entrance and then holds.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/widgets/rex_mascot.dart';

void main() {
  testWidgets('celebrate scales up from the feet and then holds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RexMascot(size: 80, mood: RexMood.celebrate),
      ),
    );

    expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
    await tester.pumpAndSettle();
    final settled = tester.widget<Transform>(
      find.byWidgetPredicate(
        (widget) => widget is Transform && widget.alignment == Alignment.bottomCenter,
      ),
    );
    expect(settled.transform.getMaxScaleOnAxis(), closeTo(1, 0.02));
  });

  testWidgets('calm drawing does not run the celebrate entrance', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: RexMascot(size: 80)),
    );
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
  });

  testWidgets('think brings both arms in front of the chest', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RexMascot(size: 80, mood: RexMood.think),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Rex, thinking'), findsOneWidget);
    final turns = tester.widgetList<Transform>(find.byType(Transform)).where((
      transform,
    ) {
      final angle = math.atan2(
        transform.transform.storage[1],
        transform.transform.storage[0],
      );
      return angle.abs() > 0.4;
    });
    expect(turns.length, 2);
  });
}
