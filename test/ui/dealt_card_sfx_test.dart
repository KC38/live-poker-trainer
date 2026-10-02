/// Deal SFX fires once per felt card reveal.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/audio/sound_service.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/ui/widgets/dealt_card_reveal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DealtCardReveal plays deal once when a card appears', (
    tester,
  ) async {
    final sound = SoundService.silent();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [soundServiceProvider.overrideWithValue(sound)],
        child: const MaterialApp(
          home: DealtCardReveal(child: SizedBox(width: 8, height: 8)),
        ),
      ),
    );
    await tester.pump();
    expect(sound.played, [SfxKind.deal]);
    await sound.dispose();
  });

  testWidgets('showdown-style reveal does not play deal', (tester) async {
    final sound = SoundService.silent();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [soundServiceProvider.overrideWithValue(sound)],
        child: const MaterialApp(
          home: DealtCardReveal(
            playSound: false,
            child: SizedBox(width: 8, height: 8),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(sound.played, isEmpty);
    await sound.dispose();
  });
}
