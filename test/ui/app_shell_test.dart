/// App shell smoke test (not wired into production routing by default).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/curriculum/curriculum_models.dart';
import 'package:live_poker_trainer/providers/learning_provider.dart';
import 'package:live_poker_trainer/ui/screens/app_shell.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  testWidgets('AppShell shows four tabs and Learn by default', (tester) async {
    const catalog = CurriculumCatalog(
      catalogVersion: '1.0.0',
      minClientVersion: '1.0.0',
      sections: [
        CurriculumSection(
          id: 'sec-00-start-safely',
          order: 0,
          title: 'Start safely',
          summary: 'Foundations',
          units: [
            CurriculumUnit(
              id: 'unit-00-01-cash-poker-map',
              order: 1,
              title: 'Cash poker map',
              summary: '',
              objectiveIds: [],
              lessons: [],
            ),
          ],
        ),
      ],
      objectives: [],
      milestoneGates: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          curriculumCatalogProvider.overrideWith((ref) async => catalog),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const AppShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Learn'), findsWidgets);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.textContaining('13 sections'), findsOneWidget);
    expect(find.text('Cash poker map'), findsOneWidget);

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();
    expect(find.textContaining('deep-link'), findsOneWidget);
  });
}
