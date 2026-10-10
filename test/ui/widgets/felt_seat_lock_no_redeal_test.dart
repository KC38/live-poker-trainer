/// Locking seat taps must not remount dealt cards (no redeal animation).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/deal/card_deal_pace.dart';
import 'package:live_poker_trainer/ui/course/widgets/lesson_table_stage.dart';
import 'package:live_poker_trainer/ui/widgets/dealt_card_reveal.dart';
import 'package:live_poker_trainer/ui/widgets/table_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    CardDealPace.debugInstant = null;
    CardDealPace.testScale = 1;
  });

  testWidgets('disabling seat taps keeps the same dealt card states', (
    tester,
  ) async {
    CardDealPace.debugInstant = true;
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    Future<void> pumpTable({required bool enabled}) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 390,
              height: 560,
              child: LessonTableStage(
                villainCount: lessonBlindsVillainCount,
                dealerIndex: lessonBlindsButtonIndex,
                sbIndex: lessonBlindsSmallBlindIndex,
                bbIndex: lessonBlindsBigBlindIndex,
                positionLabels: true,
                enabled: enabled,
                selectedSeatIndexes: enabled ? const {} : const {3},
                onSeatIndexTap: enabled ? (_) {} : null,
              ),
            ),
          ),
        ),
      );
    }

    await pumpTable(enabled: true);
    await tester.pumpAndSettle();

    final heroBack = find.byKey(const ValueKey<String>('dealt-back-0-0'));
    expect(heroBack, findsOneWidget);
    expect(find.byType(TableCardBack), findsWidgets);

    final before = tester.state<DealtCardReveal>(heroBack);

    await pumpTable(enabled: false);
    await tester.pump();

    expect(heroBack, findsOneWidget);
    final after = tester.state<DealtCardReveal>(heroBack);
    expect(
      identical(before, after),
      isTrue,
      reason: 'locking seat taps remounted DealtCardReveal (redeal)',
    );
    expect(find.byKey(const ValueKey<String>('lesson-seat-3')), findsOneWidget);
  });
}
