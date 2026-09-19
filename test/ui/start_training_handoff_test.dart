/// Start-training handoff: deal/SFX must wait until the table is visible.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/providers/game_provider.dart';
import 'package:live_poker_trainer/ui/screens/home_screen.dart';
import 'package:live_poker_trainer/ui/screens/poker_table_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';

/// Records prepare / start ordering without running the real engine or audio.
class _TrackingController extends GameController {
  _TrackingController(super.ref);

  final List<String> log = <String>[];
  final Completer<void> started = Completer<void>();

  @override
  void prepareTraining() {
    log.add('prepare');
    super.prepareTraining();
  }

  @override
  Future<void> startTraining({bool continueTable = false}) async {
    log.add('start');
    state = state.copyWith(loading: true);
    if (!started.isCompleted) started.complete();
  }
}

_TrackingController _readController(WidgetTester tester, Finder root) {
  final container = ProviderScope.containerOf(tester.element(root));
  return container.read(gameControllerProvider.notifier) as _TrackingController;
}

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() done, {
  int maxPumps = 40,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    if (done()) return;
    await tester.pump(const Duration(milliseconds: 20));
  }
  fail('timed out after $maxPumps pumps');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Start training prepares on Home, starts only after table is visible',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameControllerProvider.overrideWith(_TrackingController.new),
          ],
          child: MaterialApp(
            theme: buildPokerTheme(),
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pump();

      final controller = _readController(tester, find.byType(HomeScreen));
      expect(find.text('Start training'), findsOneWidget);
      expect(controller.log, isEmpty);

      await tester.tap(find.text('Start training'));
      await tester.pump(); // setState + prepare + Navigator.push

      expect(controller.log, contains('prepare'));
      expect(
        controller.log,
        isNot(contains('start')),
        reason: 'Deal/SFX must not start on the same frame as navigation',
      );

      // Soft-fade is 320ms; keep pumping short of that and ensure no start yet,
      // while the Training route appears.
      await _pumpUntil(
        tester,
        () => find.byType(PokerTableScreen).evaluate().isNotEmpty,
        maxPumps: 10,
      );
      expect(find.text('Preparing hand…'), findsOneWidget);
      expect(controller.log, isNot(contains('start')));

      await tester.pump(const Duration(milliseconds: 320));
      await _pumpUntil(tester, () => controller.log.contains('start'));

      expect(controller.log, ['prepare', 'start']);
    },
  );

  testWidgets(
    'PokerTableScreen defers startTraining until route presentation completes',
    (tester) async {
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameControllerProvider.overrideWith(_TrackingController.new),
          ],
          child: MaterialApp(
            navigatorKey: navKey,
            theme: buildPokerTheme(),
            home: const Scaffold(body: Text('landing')),
          ),
        ),
      );
      await tester.pump();

      final controller = _readController(tester, find.text('landing'));
      controller.prepareTraining();
      unawaited(
        navKey.currentState!.push(softFadeRoute(const PokerTableScreen())),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(controller.log, ['prepare']);
      expect(find.byType(PokerTableScreen), findsOneWidget);
      expect(controller.log, isNot(contains('start')));

      await tester.pump(const Duration(milliseconds: 320));
      await _pumpUntil(tester, () => controller.log.contains('start'));

      expect(controller.log, ['prepare', 'start']);
    },
  );
}
