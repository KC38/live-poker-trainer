/// Unit banner shape and chrome coverage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/home/course_path_view.dart';

void main() {
  testWidgets('unit banner is fully rounded without chevron or notch', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CourseUnitBanner(
            sectionOrder: 1,
            unitOrder: 2,
            unitTitle: 'What beats what',
            color: const Color(0xFF1CB0A0),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('SECTION 1, UNIT 2'), findsOneWidget);
    expect(find.text('What beats what'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);

    final ink = tester.widget<Ink>(find.byType(Ink));
    final decoration = ink.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(16));
  });
}
