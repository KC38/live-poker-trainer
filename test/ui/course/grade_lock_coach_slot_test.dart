/// gradeLockCoachSlot keeps layout under Nice!/Oops! (no felt remount).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/course/widgets/rex_coach_line.dart';

void main() {
  testWidgets('locked slot keeps child size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              gradeLockCoachSlot(
                locked: true,
                child: const SizedBox(
                  key: ValueKey<String>('coach-probe'),
                  width: 120,
                  height: 40,
                ),
              ),
              const SizedBox(key: ValueKey<String>('felt-probe'), height: 80),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.getSize(find.byKey(const ValueKey<String>('coach-probe'))).height,
      40,
    );
    expect(find.byKey(const ValueKey<String>('felt-probe')), findsOneWidget);
  });
}
