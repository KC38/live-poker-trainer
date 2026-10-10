/// Widget tests for the heart refill sheet (Theme type, no Nunito).
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

  testWidgets('uses Theme Manrope / Mono and never Nunito at mini size', (
    tester,
  ) async {
    final nextAt = DateTime.now()
        .add(const Duration(hours: 1, minutes: 5))
        .millisecondsSinceEpoch;
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(375, 812)),
          child: Scaffold(
            body: HeartRefillSheet(
              livesRemaining: 2,
              livesMax: 5,
              gems: 700,
              livesNextRefillAtMs: nextAt,
              adClaimsRemainingToday: 3,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    final titleStyle = tester.widget<Text>(find.text('Restore hearts')).style;
    expect(titleStyle?.fontFamily?.toLowerCase(), contains('manrope'));

    final countdown = tester.widget<Text>(find.textContaining('Next heart in'));
    expect(
      countdown.style?.fontFamily?.toLowerCase(),
      contains('jetbrainsmono'),
    );

    final practiceStyle = tester.widget<Text>(find.text('Practice')).style;
    expect(practiceStyle?.fontFamily?.toLowerCase(), contains('manrope'));

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      final family = text.style?.fontFamily?.toLowerCase() ?? '';
      expect(family.contains('nunito'), isFalse, reason: text.data);
    }
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
