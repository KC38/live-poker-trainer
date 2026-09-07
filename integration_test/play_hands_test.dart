/// On-device play-test: deals and finishes many full hands without crashing.
///
/// Run against a booted simulator or device:
///
/// ```bash
/// flutter test integration_test/play_hands_test.dart -d <device-id>
/// ```
///
/// The test drives the real widget tree, engine, replay pacing, database, and
/// audio stack, taking a mix of fold, check/call, and raise lines so both the
/// fold-out and showdown paths run repeatedly. Each hand plays in real time
/// (replay pacing plus coach narration), so budget roughly 30s per hand.
///
/// Note: after the hands finish, the harness may report "An animation is still
/// running even after the widget tree was disposed" from `audioplayers`'
/// position updater. That is a plugin teardown artifact, not an app failure —
/// the per-hand assertions inside the loop are what guard against crashes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:live_poker_trainer/main.dart' as app;

/// How many hands to play in the soak run.
const _handCount = 5;

/// Pumps a fixed number of frames.
///
/// `pumpAndSettle` is deliberately avoided: the live binding keeps scheduling
/// frames while coach narration and font loading are in flight, so settling
/// never completes and the run hangs instead of playing.
Future<void> _settle(
  WidgetTester tester, {
  int frames = 14,
  Duration frame = const Duration(milliseconds: 140),
}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(frame);
  }
}

Future<bool> _tapText(WidgetTester tester, String label) async {
  final finder = find.text(label);
  if (finder.evaluate().isEmpty) return false;
  await tester.tap(finder.first, warnIfMissed: false);
  await _settle(tester);
  return true;
}

Future<bool> _tapStartingWith(WidgetTester tester, String prefix) async {
  final finder = find.byWidgetPredicate(
    (w) => w is Text && (w.data ?? '').startsWith(prefix),
  );
  if (finder.evaluate().isEmpty) return false;
  await tester.tap(finder.first, warnIfMissed: false);
  await _settle(tester);
  return true;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plays $_handCount hands end to end without crashing',
      (tester) async {
    await app.main();
    await _settle(tester);

    expect(find.text('Start training'), findsOneWidget);
    await _tapText(tester, 'Start training');

    for (var hand = 0; hand < _handCount; hand++) {
      var guard = 0;
      // Act until the hand-review sheet offers the next hand.
      while (guard++ < 90) {
        expect(
          tester.takeException(),
          isNull,
          reason: 'exception during hand $hand',
        );

        if (find.text('Next hand').evaluate().isNotEmpty) break;

        // The dock ignores pointers while villains act, so wait for the hero
        // rail to hand us the turn instead of tapping into the void.
        if (find.text('YOUR TURN').evaluate().isEmpty) {
          await _settle(tester, frames: 6, frame: const Duration(seconds: 1));
          continue;
        }

        // Vary the line so folds, showdowns, and raises all get exercised.
        switch ((hand + guard) % 3) {
          case 0 when hand.isEven:
            await _tapText(tester, 'Fold');
          case 1:
            if (!await _tapText(tester, 'Check')) {
              await _tapStartingWith(tester, 'Call ');
            }
          default:
            if (!await _tapText(tester, 'Raise') &&
                !await _tapText(tester, 'Bet') &&
                !await _tapText(tester, 'Check')) {
              await _tapStartingWith(tester, 'Call ');
            }
        }
      }

      expect(guard, lessThan(90), reason: 'hand $hand never resolved');
      debugPrint('[soak] hand ${hand + 1}/$_handCount resolved');
      await _tapText(tester, 'Next hand');
      expect(
        tester.takeException(),
        isNull,
        reason: 'exception starting hand ${hand + 1}',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 25)));
}
