/// App shell smoke test (not wired into production routing yet).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/screens/app_shell.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  testWidgets('AppShell shows four tabs and Learn by default', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildPokerTheme(),
        home: const AppShell(),
      ),
    );

    expect(find.text('Learn'), findsWidgets);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(
      find.textContaining('13 sections'),
      findsOneWidget,
    );

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Due reviews'), findsOneWidget);
  });
}
