/// ShellBottomNav: illustrated tabs, active ring, semantic labels.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/ui/widgets/shell_bottom_nav.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const tabs = <ShellNavTab>[
    ShellNavTab(label: 'Home', asset: 'assets/brand/nav_home.svg'),
    ShellNavTab(label: 'Live Training', asset: 'assets/brand/nav_live.svg'),
    ShellNavTab(label: 'Profile', asset: 'assets/brand/nav_profile.svg'),
  ];

  testWidgets('renders three SVG icons and selects via semantics', (
    tester,
  ) async {
    var selected = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: StatefulBuilder(
            builder: (context, setState) {
              return ShellBottomNav(
                selectedIndex: selected,
                onDestinationSelected: (i) => setState(() => selected = i),
                tabs: tabs,
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SvgPicture), findsNWidgets(3));
    expect(find.bySemanticsLabel('Home'), findsOneWidget);
    expect(find.bySemanticsLabel('Live Training'), findsOneWidget);
    expect(find.bySemanticsLabel('Profile'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Live Training'));
    await tester.pumpAndSettle();
    expect(selected, 1);

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();
    expect(selected, 2);
  });
}
