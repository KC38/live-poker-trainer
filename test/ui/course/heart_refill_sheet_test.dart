/// Widget tests for the Duolingo-style heart refill sheet.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/course/widgets/heart_refill_sheet.dart';

void main() {
  testWidgets('shows timer and refill options when hearts are missing', (
    tester,
  ) async {
    final nextAt = DateTime.now()
        .add(const Duration(hours: 2, minutes: 15))
        .millisecondsSinceEpoch;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeartRefillSheet(
            livesRemaining: 2,
            livesMax: 5,
            gems: 700,
            livesNextRefillAtMs: nextAt,
            adClaimsRemainingToday: 3,
          ),
        ),
      ),
    );

    expect(find.text('Restore hearts'), findsOneWidget);
    expect(find.textContaining('Next heart in'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(
      find.text('Earn +1 heart when you finish Practice'),
      findsOneWidget,
    );
    expect(find.text('Watch an ad'), findsOneWidget);
    expect(find.text('Refill with gems'), findsOneWidget);
    expect(find.textContaining('650 gems'), findsOneWidget);
  });

  testWidgets('shows cooldown copy when next ad claim is in the future', (
    tester,
  ) async {
    final nextAd = DateTime.now()
        .add(const Duration(seconds: 40))
        .millisecondsSinceEpoch;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HeartRefillSheet(
            livesRemaining: 3,
            livesMax: 5,
            gems: 0,
            adClaimsRemainingToday: 4,
            nextAdClaimAtMs: nextAd,
          ),
        ),
      ),
    );

    expect(find.textContaining('Available in'), findsOneWidget);
    expect(find.textContaining('4 left today'), findsNothing);
  });

  testWidgets('disables spend options when full', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeartRefillSheet(
            livesRemaining: 5,
            livesMax: 5,
            gems: 1000,
          ),
        ),
      ),
    );

    expect(find.text('Hearts are full'), findsOneWidget);
    await tester.tap(find.text('Practice'));
    await tester.pump();
    expect(find.text('Hearts are full'), findsOneWidget);
  });
}
