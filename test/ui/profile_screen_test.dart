/// Player Profile screen: the low-sample contract and identity editing.
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/database/app_database.dart';
import 'package:live_poker_trainer/core/database/profile_database.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/providers/profile_provider.dart';
import 'package:live_poker_trainer/ui/screens/profile_screen.dart';
import 'package:live_poker_trainer/ui/theme/app_theme.dart';
import 'package:live_poker_trainer/ui/widgets/profile_avatar.dart';
import 'package:live_poker_trainer/ui/widgets/profile_identity_sheet.dart';

void main() {
  late ProfileDatabase db;
  late AppDatabase appDb;

  setUp(() {
    db = ProfileDatabase(NativeDatabase.memory());
    appDb = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
    await appDb.close();
  });

  /// Pumps the profile screen against in-memory databases.
  ///
  /// The app database is real but empty and has no hand-log tables, which is
  /// exactly the state a fresh install is in: the screen has to render the
  /// low-sample story rather than fall over.
  ///
  /// The viewport is made tall so the whole page is laid out; a ListView only
  /// builds what is on screen, and this test is auditing the full contents.
  Future<void> pumpProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 4200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileDatabaseProvider.overrideWithValue(db),
          appDatabaseProvider.overrideWithValue(appDb),
        ],
        child: MaterialApp(
          theme: buildPokerTheme(),
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('with no hands the screen withholds every rate and the style',
      (tester) async {
    await pumpProfile(tester);

    expect(find.text('Progress'), findsOneWidget);
    // No style is claimed, and the reason is spelled out.
    expect(find.text('Style forming'), findsOneWidget);
    expect(find.textContaining('0 hands logged'), findsOneWidget);
    // Both the banner and the offline review explain the missing sample.
    expect(find.textContaining('style shows up here'), findsWidgets);
    // Every rate tile renders an em dash rather than a fabricated 0%.
    expect(find.text('—'), findsWidgets);
    expect(find.textContaining('needs '), findsWidgets);
    // The default identity falls back to initials.
    expect(find.byType(ProfileAvatar), findsWidgets);
  });

  testWidgets('a stat tile explains itself in plain English', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.text('VPIP'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('How often you put money in preflop'),
      findsOneWidget,
    );
    expect(find.text('Healthy range'), findsOneWidget);
    expect(find.textContaining('Not shown yet'), findsOneWidget);
  });

  testWidgets('the coach review shows offline copy without a model',
      (tester) async {
    await pumpProfile(tester);

    expect(find.text('Coach review'), findsOneWidget);
    expect(find.text('Offline read from your stats'), findsOneWidget);
    expect(find.textContaining('Not enough hands yet'), findsOneWidget);
  });

  testWidgets('editing the display name updates the header and persists',
      (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileIdentitySheet), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Kushal');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileIdentitySheet), findsNothing);
    expect(find.text('Kushal'), findsOneWidget);
    expect((await db.readIdentity()).displayName, 'Kushal');
  });

  testWidgets('a blank name reverts to the default rather than an empty seat',
      (tester) async {
    await db.saveDisplayName('Kushal');
    await pumpProfile(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text(HeroIdentity.defaultDisplayName), findsOneWidget);
    expect(
      (await db.readIdentity()).displayName,
      HeroIdentity.defaultDisplayName,
    );
  });

  testWidgets('picking a built-in avatar applies and persists immediately',
      (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // The choices are unlabelled circles, so they are found by the avatar
    // each one previews.
    final choice = BuiltInAvatar.values.first;
    await tester.tap(
      find
          .byWidgetPredicate(
            (w) => w is ProfileAvatar && w.identity.avatar.builtIn == choice,
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect((await db.readIdentity()).avatar.builtIn, choice);
    // Applying immediately means a remove affordance now exists.
    expect(find.text('Remove picture'), findsOneWidget);

    await tester.tap(find.text('Remove picture'));
    await tester.pumpAndSettle();

    expect((await db.readIdentity()).avatar.kind, AvatarKind.none);
    expect(find.text('Remove picture'), findsNothing);
  });

  testWidgets('a saved identity is loaded on open', (tester) async {
    await db.saveDisplayName('Kushal C');
    await db.saveAvatar(AvatarRef.builtIn(BuiltInAvatar.values.last));

    await pumpProfile(tester);

    expect(find.text('Kushal C'), findsOneWidget);
  });
}
