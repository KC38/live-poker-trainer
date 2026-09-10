/// Riverpod wiring for the hero profile: identity, metrics, cached AI review.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/constants/config.dart';
import 'package:live_poker_trainer/core/database/hand_history_source.dart';
import 'package:live_poker_trainer/core/database/profile_database.dart';
import 'package:live_poker_trainer/engine/hero_profiler.dart';
import 'package:live_poker_trainer/models/hero_metrics.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/mistake_model.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/avatar_store.dart';
import 'package:live_poker_trainer/services/profile_coach.dart';

/// Profile Drift database singleton.
final profileDatabaseProvider = Provider<ProfileDatabase>((ref) {
  final db = ProfileDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Avatar file store.
final avatarStoreProvider = Provider<AvatarStore>((ref) => AvatarStore());

/// Reader over the shared hand log.
final handHistorySourceProvider = Provider<HandHistorySource>(
  (ref) => HandHistorySource(ref.watch(appDatabaseProvider)),
);

/// Profile review generator. Falls back to offline copy without an API key.
final profileCoachProvider = Provider<ProfileCoach>((ref) {
  return Config.hasGeminiKey ? ProfileCoach.gemini() : ProfileCoach();
});

/// Loads, computes, and mutates the hero profile.
///
/// Load order matters for perceived speed: the persisted identity and the last
/// metric snapshot paint first, then the metrics are recomputed from the hand
/// log, and only then is a new AI review considered. Every step is wrapped so
/// a missing plugin, a missing hand log, or an offline device degrades to a
/// usable screen instead of an error state.
class HeroProfileController extends StateNotifier<AsyncValue<HeroProfileView>> {
  /// Creates the controller and kicks off the initial load.
  HeroProfileController(this._ref) : super(const AsyncValue.loading()) {
    _bootstrap();
  }

  final Ref _ref;
  bool _busySummary = false;

  ProfileDatabase get _db => _ref.read(profileDatabaseProvider);

  /// Firebase uid when signed in; falls back to local Drift key in tests.
  String get _userId =>
      _ref.read(authUidProvider) ?? Config.defaultUserId;

  HeroProfileView? get _view => state.valueOrNull;

  Future<void> _bootstrap() async {
    final identity = await _readIdentity();
    final snapshot = await _guard(() => _db.readSnapshot(userId: _userId));
    final cached = await _guard(() => _db.readSummary(userId: _userId));

    if (!mounted) return;
    state = AsyncValue.data(
      HeroProfileView(
        identity: identity,
        metrics: snapshot ?? HeroMetrics.empty(),
        summary: cached,
      ),
    );

    await refreshMetrics();
  }

  /// Recomputes metrics from the hand log and persists the snapshot.
  Future<void> refreshMetrics() async {
    final current = _view;
    if (current == null) return;

    final hands = await _guard(
          () => _ref.read(handHistorySourceProvider).recentHands(),
        ) ??
        const [];
    final metrics = HeroProfiler.compute(hands, computedAt: DateTime.now());
    if (!mounted) return;

    state = AsyncValue.data(current.copyWith(metrics: metrics));
    await _guard(() => _db.saveSnapshot(metrics, userId: _userId));
    await refreshSummary();
  }

  /// Regenerates the coach review when the cache is stale.
  ///
  /// Without [force] this is a no-op unless
  /// [ProfileCoachSummary.needsRefresh] says the cached copy no longer
  /// describes the player — the screen must not spend an API call per open.
  Future<void> refreshSummary({bool force = false}) async {
    final current = _view;
    if (current == null || _busySummary) return;

    final metrics = current.metrics;
    final cached = current.summary;
    final now = DateTime.now();
    if (!force && cached != null && !cached.needsRefresh(metrics, now)) {
      return;
    }

    // Never show an empty card: derive local copy first, then try the model.
    final mistakes = await _guard(
          () => _ref.read(mistakeDaoProvider).loadStats(),
        ) ??
        const MistakeStats();

    if (cached == null) {
      final offline = ProfileCoach.offlineSummary(
        metrics,
        mistakes: mistakes,
        now: now,
      );
      state = AsyncValue.data(
        current.copyWith(summary: offline, summaryRefreshing: true),
      );
    } else {
      state = AsyncValue.data(current.copyWith(summaryRefreshing: true));
    }

    _busySummary = true;
    try {
      final coach = _ref.read(profileCoachProvider);
      final summary = await coach.summarize(
        metrics,
        mistakes: mistakes,
        now: now,
      );
      if (!mounted) return;
      await _guard(() => _db.saveSummary(summary, userId: _userId));
      final latest = _view;
      if (latest == null || !mounted) return;
      state = AsyncValue.data(
        latest.copyWith(summary: summary, summaryRefreshing: false),
      );
    } finally {
      _busySummary = false;
      final latest = _view;
      if (mounted && latest != null && latest.summaryRefreshing) {
        state = AsyncValue.data(latest.copyWith(summaryRefreshing: false));
      }
    }
  }

  /// Saves a new display name (sanitized) and updates the hero seat.
  Future<void> setDisplayName(String rawName) async {
    final current = _view;
    if (current == null) return;
    final saved = await _guard(
      () => _db.saveDisplayName(rawName, userId: _userId),
    );
    final uid = _ref.read(authUidProvider);
    if (uid != null) {
      await _guard(
        () => _ref.read(userRepositoryProvider).updateProfile(
              uid: uid,
              displayName: HeroIdentity.sanitizeName(rawName),
            ),
      );
    }
    if (!mounted) return;
    state = AsyncValue.data(
      current.copyWith(
        identity: saved ??
            current.identity.copyWith(
              displayName: HeroIdentity.sanitizeName(rawName),
            ),
      ),
    );
  }

  /// Selects one of the built-in avatars, removing any stored photo.
  Future<void> selectBuiltInAvatar(BuiltInAvatar avatar) async {
    await _setAvatar(AvatarRef.builtIn(avatar), deletePrevious: true);
  }

  /// Clears the avatar back to initials, removing any stored photo.
  Future<void> clearAvatar() async {
    await _setAvatar(const AvatarRef.none(), deletePrevious: true);
  }

  /// Opens the photo library and stores the chosen picture.
  ///
  /// Returns the raw result so the screen can explain a permission denial
  /// instead of silently doing nothing.
  Future<AvatarPickResult> pickAvatarFromLibrary() async {
    final current = _view;
    if (current == null) {
      return const AvatarPickResult(AvatarPickStatus.failed);
    }
    final store = _ref.read(avatarStoreProvider);
    final result = await store.pickFromGallery(
      replacing: current.identity.avatar,
    );
    if (result.isSaved) {
      await _setAvatar(result.avatar!, deletePrevious: false);
    }
    return result;
  }

  Future<void> _setAvatar(
    AvatarRef avatar, {
    required bool deletePrevious,
  }) async {
    final current = _view;
    if (current == null) return;
    final previous = current.identity.avatar;
    final saved = await _guard(() => _db.saveAvatar(avatar, userId: _userId));
    final uid = _ref.read(authUidProvider);
    if (uid != null) {
      await _guard(
        () => _ref.read(userRepositoryProvider).updateProfile(
              uid: uid,
              avatarRef: avatar.storageValue,
            ),
      );
    }
    if (deletePrevious && previous.filePath != null) {
      await _guard(
        () => _ref.read(avatarStoreProvider).deleteStoredFile(previous),
      );
    }
    if (!mounted) return;
    state = AsyncValue.data(
      current.copyWith(
        identity: saved ?? current.identity.copyWith(avatar: avatar),
      ),
    );
  }

  Future<HeroIdentity> _readIdentity() async {
    final uid = _ref.read(authUidProvider);
    if (uid != null) {
      final cloud = await _guard(() => _ref.read(userDocProvider.future));
      if (cloud != null) return cloud.identity;
    }
    final identity = await _guard(() => _db.readIdentity(userId: _userId));
    return identity ?? const HeroIdentity();
  }

  /// Runs [action], swallowing storage and platform failures.
  ///
  /// The profile is a read-mostly convenience surface; a database that cannot
  /// open (web without WASM assets, a widget test with no plugins) must not
  /// take the screen down with it.
  Future<T?> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }
}

/// The hero profile controller.
final heroProfileControllerProvider =
    StateNotifierProvider<HeroProfileController, AsyncValue<HeroProfileView>>(
  HeroProfileController.new,
);

/// Hero identity for the table: always resolves, defaulting to `Hero`.
///
/// The felt reads this synchronously, so it can never be a loading state.
final heroIdentityProvider = Provider<HeroIdentity>((ref) {
  return ref.watch(heroProfileControllerProvider).valueOrNull?.identity ??
      const HeroIdentity();
});
