/// Profile persistence: identity, metric snapshot, and cached coach summary.
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/core/database/profile_database.dart';
import 'package:live_poker_trainer/engine/hero_profiler.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/hand_history_sample.dart';
import 'package:live_poker_trainer/models/hero_metrics.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';

/// Builds metrics over [hands] identical raise-and-c-bet hands.
HeroMetrics _metrics(int hands) {
  return HeroProfiler.compute([
    for (var i = 0; i < hands; i++)
      HeroHandSample(
        handId: i + 1,
        playedAt: DateTime(2026, 1, 1).add(Duration(minutes: i)),
        actions: [
          const HandActionSample(
            seat: 0,
            street: Street.preflop,
            kind: HandActionKind.raise,
            isHero: true,
            archetype: PlayerArchetype.hero,
            amountBb: 3,
          ),
          const HandActionSample(
            seat: 3,
            street: Street.preflop,
            kind: HandActionKind.call,
            amountBb: 3,
          ),
          const HandActionSample(
            seat: 0,
            street: Street.flop,
            kind: HandActionKind.bet,
            isHero: true,
            archetype: PlayerArchetype.hero,
            amountBb: 4,
          ),
          const HandActionSample(
            seat: 3,
            street: Street.flop,
            kind: HandActionKind.fold,
          ),
        ],
        heroNetBb: 4,
      ),
  ]);
}

void main() {
  late ProfileDatabase db;

  setUp(() => db = ProfileDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('identity', () {
    test('an unseen user reads back the default identity', () async {
      final identity = await db.readIdentity();

      expect(identity.displayName, HeroIdentity.defaultDisplayName);
      expect(identity.avatar.kind, AvatarKind.none);
      expect(identity.railLabel, 'YOU');
    });

    test('a display name round-trips and is sanitized on the way in',
        () async {
      final saved = await db.saveDisplayName('  Kushal   C  ');

      expect(saved.displayName, 'Kushal C');
      expect((await db.readIdentity()).displayName, 'Kushal C');
      expect(saved.initials, 'KC');
      expect(saved.railLabel, 'KUSHAL C');
    });

    test('a blank name falls back to the default rather than an empty seat',
        () async {
      await db.saveDisplayName('Kushal');
      final cleared = await db.saveDisplayName('    ');

      expect(cleared.displayName, HeroIdentity.defaultDisplayName);
      expect(cleared.seatName, HeroIdentity.defaultDisplayName);
    });

    test('an over-long name is clamped to the storable length', () async {
      final saved = await db.saveDisplayName('a' * 80);

      expect(saved.displayName.length, HeroIdentity.maxNameLength);
    });

    test('an avatar file path round-trips without touching the name',
        () async {
      await db.saveDisplayName('Kushal');
      const path = '/tmp/documents/avatars/avatar_1234.png';

      final saved = await db.saveAvatar(const AvatarRef.file(path));
      final reread = await db.readIdentity();

      expect(saved.avatar.kind, AvatarKind.file);
      expect(saved.avatar.filePath, path);
      expect(reread.avatar.filePath, path);
      expect(reread.displayName, 'Kushal', reason: 'name must survive');
    });

    test('a built-in avatar round-trips by id, not by index', () async {
      await db.saveAvatar(AvatarRef.builtIn(BuiltInAvatar.values.last));

      final reread = await db.readIdentity();

      expect(reread.avatar.kind, AvatarKind.builtIn);
      expect(reread.avatar.builtIn, BuiltInAvatar.values.last);
    });

    test('clearing the avatar leaves no dangling path behind', () async {
      await db.saveAvatar(const AvatarRef.file('/tmp/a/avatar_1.png'));
      await db.saveAvatar(const AvatarRef.none());

      final reread = await db.readIdentity();

      expect(reread.avatar.kind, AvatarKind.none);
      expect(reread.avatar.filePath, isNull);
      expect(reread.avatar.isEmpty, isTrue);
    });

    test('watchIdentity emits the saved identity', () async {
      expect(
        db.watchIdentity(),
        emitsThrough(
          isA<HeroIdentity>().having((i) => i.displayName, 'name', 'Villain'),
        ),
      );

      await db.saveDisplayName('Villain');
    });

    test('two users do not read each other\'s identity', () async {
      await db.saveDisplayName('Kushal', userId: 'a');
      await db.saveDisplayName('Someone else', userId: 'b');

      expect((await db.readIdentity(userId: 'a')).displayName, 'Kushal');
      expect((await db.readIdentity(userId: 'b')).displayName, 'Someone else');
    });
  });

  group('metric snapshot', () {
    test('there is no snapshot before one is written', () async {
      expect(await db.readSnapshot(), isNull);
    });

    test('a snapshot round-trips its rates and style', () async {
      final metrics = _metrics(40);
      await db.saveSnapshot(metrics);

      final reread = await db.readSnapshot();

      expect(reread, isNotNull);
      expect(reread!.handsPlayed, 40);
      expect(reread.style.style, metrics.style.style);
      expect(reread.style.confidence, metrics.style.confidence);
      expect(
        reread.sample(HeroMetricId.vpip).value,
        closeTo(metrics.sample(HeroMetricId.vpip).value!, 0.001),
      );
      expect(
        reread.sample(HeroMetricId.cbet).made,
        metrics.sample(HeroMetricId.cbet).made,
      );
      expect(reread.netBb, closeTo(metrics.netBb, 0.001));
    });

    test('the snapshot is a first-frame cache, not the source of truth', () {
      // Tendencies and the trend are deliberately not persisted: they are
      // bulky, and the hand log they come from is always available to
      // recompute. Anything that reads them must tolerate empty.
      final metrics = _metrics(40);
      expect(metrics.archetypeTendencies, isNotEmpty);

      return db.saveSnapshot(metrics).then((_) async {
        final reread = (await db.readSnapshot())!;

        expect(reread.archetypeTendencies, isEmpty);
        expect(reread.streetTendencies, isEmpty);
        expect(reread.trend, isEmpty);
        expect(reread.handsPlayed, 40, reason: 'rates still round-trip');
      });
    });

    test('saving again replaces the snapshot instead of stacking rows',
        () async {
      await db.saveSnapshot(_metrics(25));
      await db.saveSnapshot(_metrics(60));

      expect((await db.readSnapshot())!.handsPlayed, 60);
    });
  });

  group('cached coach summary', () {
    ProfileCoachSummary summary({
      int hands = 40,
      bool fromAi = true,
      String styleId = 'tag',
      DateTime? generatedAt,
    }) {
      return ProfileCoachSummary(
        styleSummary: 'You open a lot and follow through on the flop.',
        leaks: const ['You give up on the turn too often.'],
        adjustments: const ['Barrel one more street versus a Nit.'],
        source: fromAi
            ? ProfileCoachSummary.geminiSource
            : ProfileCoachSummary.offlineSource,
        modelId: fromAi ? 'gemini-test' : '',
        handsPlayedAt: hands,
        styleId: styleId,
        generatedAt: generatedAt ?? DateTime.utc(2026, 3, 1),
      );
    }

    test('there is no summary before one is written', () async {
      expect(await db.readSummary(), isNull);
    });

    test('a summary round-trips with its provenance intact', () async {
      await db.saveSnapshot(_metrics(40));
      await db.saveSummary(summary());

      final reread = await db.readSummary();

      expect(reread, isNotNull);
      expect(reread!.styleSummary, contains('follow through'));
      expect(reread.leaks, hasLength(1));
      expect(reread.adjustments, hasLength(1));
      expect(reread.handsPlayedAt, 40);
      expect(reread.modelId, 'gemini-test');
      expect(reread.styleId, 'tag');
      expect(reread.isFromAi, isTrue);
      expect(reread.generatedAt, DateTime.utc(2026, 3, 1));
    });

    test('an offline summary is stored as such, so it can be upgraded later',
        () async {
      await db.saveSummary(summary(fromAi: false));

      final reread = await db.readSummary();

      expect(reread!.isFromAi, isFalse);
      expect(reread.modelId, isEmpty);
    });

    test('a summary survives a later snapshot write', () async {
      await db.saveSummary(summary(hands: 40));
      await db.saveSnapshot(_metrics(90));

      final reread = await db.readSummary();

      expect(reread, isNotNull);
      expect(
        reread!.handsPlayedAt,
        40,
        reason: 'staleness is judged against the hand count it was written at',
      );
      expect((await db.readSnapshot())!.handsPlayed, 90);
    });

    test('clearProfile wipes identity, snapshot, and summary together',
        () async {
      await db.saveDisplayName('Kushal');
      await db.saveAvatar(AvatarRef.builtIn(BuiltInAvatar.values.first));
      await db.saveSnapshot(_metrics(40));
      await db.saveSummary(summary());

      await db.clearProfile();

      final identity = await db.readIdentity();
      expect(identity.displayName, HeroIdentity.defaultDisplayName);
      expect(identity.avatar.kind, AvatarKind.none);
      expect(await db.readSnapshot(), isNull);
      expect(await db.readSummary(), isNull);
    });
  });
}
