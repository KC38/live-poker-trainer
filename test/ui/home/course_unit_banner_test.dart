/// Unit banner shape and chrome coverage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/home/course_path_view.dart';

void main() {
  testWidgets('unit banner is extruded, fully rounded, without chevron or notch', (
    tester,
  ) async {
    const face = Color(0xFF1CB0A0);
    final lip = Color.lerp(face, Colors.black, 0.22)!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CourseUnitBanner(
            sectionOrder: 1,
            unitOrder: 2,
            unitTitle: 'What beats what',
            color: face,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('SECTION 1, UNIT 2'), findsOneWidget);
    expect(find.text('What beats what'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);

    final plate = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(CourseUnitBanner),
        matching: find.byType(DecoratedBox),
      ),
    );
    final plateDecoration = plate.decoration as BoxDecoration;
    expect(plateDecoration.color, lip);
    expect(plateDecoration.borderRadius, BorderRadius.circular(16));

    final faceMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byType(CourseUnitBanner),
        matching: find.byWidgetPredicate(
          (widget) => widget is Material && widget.color == face,
        ),
      ),
    );
    expect(faceMaterial.borderRadius, BorderRadius.circular(16));
  });
}
