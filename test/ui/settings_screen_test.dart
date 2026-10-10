/// Settings Account CTAs match Theme elevated / outlined metrics (LPT-45).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/screens/settings_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Account CTAs use Theme radius 14 at iPhone 13 mini size',
    (tester) async {
      final view = tester.view;
      view.physicalSize = const Size(375, 812);
      view.devicePixelRatio = 1;
      addTearDown(view.resetPhysicalSize);
      addTearDown(view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appAuthProvider.overrideWithValue(
              const AsyncData(
                AppAuthSnapshot(uid: 'guest', isAnonymous: true),
              ),
            ),
            analyticsServiceProvider.overrideWithValue(
              AnalyticsService(enabled: false),
            ),
          ],
          child: MaterialApp(
            theme: buildPokerTheme(),
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final createFinder = find.widgetWithText(
        ElevatedButton,
        'Create an account',
      );
      final signOutFinder = find.widgetWithText(OutlinedButton, 'Sign out');
      expect(createFinder, findsOneWidget);
      expect(signOutFinder, findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Create an account'), findsNothing);

      final create = tester.widget<ElevatedButton>(createFinder);
      final signOut = tester.widget<OutlinedButton>(signOutFinder);
      final createContext = tester.element(createFinder);
      final signOutContext = tester.element(signOutFinder);
      const states = <WidgetState>{};

      expect(tester.getSize(createFinder).height, 54);
      final createStyle =
          create.style ?? Theme.of(createContext).elevatedButtonTheme.style;
      final createShape =
          createStyle!.shape!.resolve(states)! as RoundedRectangleBorder;
      expect(createShape.borderRadius, BorderRadius.circular(14));
      expect(createStyle.backgroundColor!.resolve(states), AppColors.gold);

      expect(tester.getSize(signOutFinder).height, 50);
      final signOutStyle =
          signOut.style ?? Theme.of(signOutContext).outlinedButtonTheme.style;
      final signOutShape =
          signOutStyle!.shape!.resolve(states)! as RoundedRectangleBorder;
      expect(signOutShape.borderRadius, BorderRadius.circular(14));

      expect(tester.takeException(), isNull);
    },
  );
}
