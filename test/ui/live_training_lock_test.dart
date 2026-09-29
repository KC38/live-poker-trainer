/// Locked Live Training names the Home lesson and still offers the warm-up.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_catalog.dart';
import 'package:live_poker_trainer/models/live_access.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/course_catalog_provider.dart';
import 'package:live_poker_trainer/providers/live_access_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/ui/screens/live_training_screen.dart';
import 'package:live_poker_trainer/ui/screens/poker_table_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the warm-up unlock lesson title is on the course catalog', () async {
    final raw = await rootBundle.loadString(kCourseCatalogAssetPath);
    final catalog = CourseCatalog.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    expect(
      catalog.lessonById(kLiveWarmUpUnlockLessonId)?.title,
      kLiveWarmUpUnlockLessonTitle,
    );
  });

  testWidgets('a locked guest sees the Home lesson title and no table', (
    tester,
  ) async {
    var openedHome = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService(enabled: false),
          ),
          liveAccessProvider.overrideWith(
            (ref) async => LiveAccessSnapshot.locked(),
          ),
          courseCatalogProvider.overrideWith((ref) async {
            final raw = await rootBundle.loadString(kCourseCatalogAssetPath);
            return CourseCatalog.fromJson(
              jsonDecode(raw) as Map<String, dynamic>,
            );
          }),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: LiveTrainingScreen(onOpenHome: () => openedHome = true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start training'), findsNothing);
    expect(find.byType(PokerTableScreen), findsNothing);
    expect(find.text('Start Rex warm-up'), findsNothing);
    expect(_logoMark(), findsOneWidget);
    expect(
      find.text(
        'Live Training is advanced. Finish Section 2 jump check on Home '
        'to unlock a coached warm-up.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Section 2 checkpoint'), findsNothing);

    await tester.tap(find.text('Continue on Home'));
    await tester.pump();
    expect(openedHome, isTrue);
    expect(find.byType(PokerTableScreen), findsNothing);
  });

  testWidgets('a finished checkpoint still offers the Rex warm-up', (
    tester,
  ) async {
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
    await tester.pump();

    expect(find.text('Start Rex warm-up'), findsOneWidget);
    expect(_logoMark(), findsOneWidget);
    expect(find.text('Start training'), findsNothing);
    expect(find.byType(PokerTableScreen), findsNothing);
    expect(find.textContaining('Rex warm-ups are open'), findsOneWidget);
    expect(find.textContaining('Section 2 jump check'), findsNothing);
  });
}

Finder _logoMark() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName == 'assets/brand/logo_mark.png',
  );
}
