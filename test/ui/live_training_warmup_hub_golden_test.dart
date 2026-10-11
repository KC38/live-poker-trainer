/// Golden for Live Training warm-up hub copy (375 × 812).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/live_access.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/live_access_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/screens/live_training_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('warm-up hub at iPhone 13 mini width', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(enabled: false),
          ),
          liveAccessProvider.overrideWith(
            (ref) async => const LiveAccessSnapshot(
              tier: LiveAccessTier.warmUp,
              source: 'section2_checkpoint',
              unrestrictedAccess: false,
              warmUpAvailable: true,
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const LiveTrainingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/live_training_warmup_hub.png'),
    );
  });
}
