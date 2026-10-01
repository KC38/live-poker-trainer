/// Unit banner shape and chrome coverage.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/home/course_path_view.dart';

void main() {
  testWidgets(
    'unit banner uses Duo hard-offset lip without chevron or notch',
    (tester) async {
      const face = Color(0xFF1CB0A0);
      final lip = Color.lerp(face, Colors.black, 0.2)!;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              // Room for the hard offset shadow under the face.
              padding: const EdgeInsets.only(bottom: 8),
              child: CourseUnitBanner(
                sectionOrder: 1,
                unitOrder: 2,
                unitTitle: 'What beats what',
                color: face,
                onTap: () {},
              ),
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
      final decoration = plate.decoration as BoxDecoration;
      expect(decoration.color, face);
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow, hasLength(1));
      final shadow = decoration.boxShadow!.single;
      expect(shadow.color, lip);
      expect(shadow.offset, const Offset(0, 4));
      expect(shadow.blurRadius, 0);
    },
  );

  testWidgets(
    'unit banner stretches to the parent width like Duo',
    (tester) async {
      const parentWidth = 360.0;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: parentWidth,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: CourseUnitBanner(
                  sectionOrder: 1,
                  unitOrder: 1,
                  unitTitle: 'Cards and the table',
                  color: Color(0xFF1CB0A0),
                ),
              ),
            ),
          ),
        ),
      );

      final bannerSize = tester.getSize(find.byType(CourseUnitBanner));
      expect(bannerSize.width, parentWidth - 32);

      final titleLeft = tester.getTopLeft(find.text('Cards and the table')).dx;
      final bannerLeft = tester.getTopLeft(find.byType(CourseUnitBanner)).dx;
      // Left-aligned title inset by the plate padding (16), not centered.
      expect(titleLeft, closeTo(bannerLeft + 16, 0.5));
    },
  );
}
