/// ShellTabBody: nested AppShell tab sizing clears ShellBottomNav.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/widgets/shell_bottom_nav.dart';
import 'package:live_poker_trainer/ui/widgets/shell_tab_body.dart';

void main() {
  test('resolveSize uses finite max height when shell body is tight', () {
    const media = MediaQueryData(size: Size(375, 812));
    final size = ShellTabBody.resolveSize(
      const BoxConstraints.tightFor(width: 375, height: 700),
      media,
    );
    expect(size, const Size(375, 700));
  });

  test('resolveSize subtracts nav when max height is infinite', () {
    const media = MediaQueryData(
      size: Size(375, 812),
      padding: EdgeInsets.only(bottom: 34),
    );
    final size = ShellTabBody.resolveSize(
      const BoxConstraints(maxWidth: 375),
      media,
    );
    expect(
      size.height,
      812 - ShellBottomNav.barHeight - 34,
    );
    expect(size.width, 375);
  });

  testWidgets('ShellTabBody sizes child when parent max height is infinite', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(
          size: Size(375, 812),
          padding: EdgeInsets.only(bottom: 34),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          // Loose max height — same class of constraint IndexedStack can give.
          child: OverflowBox(
            minWidth: 0,
            maxWidth: 375,
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: ShellTabBody(
              child: ColoredBox(color: Color(0xFF112233)),
            ),
          ),
        ),
      ),
    );

    final box = tester.renderObject<RenderBox>(
      find.byType(ColoredBox),
    );
    expect(box.size.height, 812 - ShellBottomNav.barHeight - 34);
    expect(box.size.width, 375);
  });
}
