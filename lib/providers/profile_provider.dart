/// Riverpod wiring for the hero profile: identity and metrics.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/engine/hero_profiler.dart';
import 'package:live_poker_trainer/models/hero_metrics.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/user_document.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/services/avatar_store.dart';

/// Avatar picker and Firebase Storage uploader.
final avatarStoreProvider = Provider<AvatarStore>((ref) => AvatarStore());

/// Loads, computes, and mutates the hero profile.
class HeroProfileController extends StateNotifier<AsyncValue<HeroProfileView>> {
  /// Creates the controller and kicks off the initial load.
  HeroProfileController(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen<AsyncValue<UserDocument?>>(userDocProvider, (_, next) {
      _applyRemoteIdentity(next.valueOrNull);
    });
    _bootstrap();
  }

  final Ref _ref;

  HeroProfileView? get _view => state.valueOrNull;

  void _applyRemoteIdentity(UserDocument? doc) {
    final current = _view;
    if (doc == null || current == null) return;
    if (current.identity.displayName == doc.identity.displayName &&
        current.identity.avatar == doc.identity.avatar) {
      return;
    }
    state = AsyncValue.data(current.copyWith(identity: doc.identity));
  }

  Future<void> _bootstrap() async {
    final uid = _ref.read(authUidProvider);
    if (uid == null) {
      state = AsyncValue.data(
        HeroProfileView(
          identity: const HeroIdentity(),
          metrics: HeroMetrics.empty(),
        ),
      );
      return;
    }
    try {
      final user = await _ref.read(userDocProvider.future);
      final hands = await _ref
          .read(progressRepositoryProvider)
          .loadHandSamples(uid);
      if (!mounted) return;
      state = AsyncValue.data(
        HeroProfileView(
          identity: user?.identity ?? const HeroIdentity(),
          metrics: HeroProfiler.compute(hands, computedAt: DateTime.now()),
        ),
      );
      _applyRemoteIdentity(_ref.read(userDocProvider).valueOrNull);
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Reloads server-authored hand history and recomputes hero metrics.
  Future<void> refreshMetrics() async {
    final current = _view;
    if (current == null) return;
    final uid = _ref.read(authUidProvider);
    if (uid == null) return;
    try {
      final hands = await _ref
          .read(progressRepositoryProvider)
          .loadHandSamples(uid);
      if (!mounted) return;
      state = AsyncValue.data(
        current.copyWith(
          metrics: HeroProfiler.compute(hands, computedAt: DateTime.now()),
          summary: null,
        ),
      );
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Writes a new display name to Firestore before updating the hero seat.
  Future<void> setDisplayName(String rawName) async {
    final current = _view;
    if (current == null) return;
    final uid = _ref.read(authUidProvider);
    if (uid == null) return;
    final name = HeroIdentity.sanitizeName(rawName);
    try {
      await _ref
          .read(userRepositoryProvider)
          .updateProfile(uid: uid, displayName: name);
      if (!mounted) return;
      state = AsyncValue.data(
        current.copyWith(
          identity: current.identity.copyWith(displayName: name),
        ),
      );
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Selects one of the built-in avatars.
  Future<void> selectBuiltInAvatar(BuiltInAvatar avatar) async {
    await _setAvatar(AvatarRef.builtIn(avatar));
  }

  /// Clears the avatar back to initials.
  Future<void> clearAvatar() async {
    await _setAvatar(const AvatarRef.none());
  }

  /// Opens the photo library, uploads to Storage when signed in, and saves.
  Future<AvatarPickResult> pickAvatarFromLibrary() async {
    final current = _view;
    if (current == null) {
      return const AvatarPickResult(
        AvatarPickStatus.failed,
        message: 'Your profile is still loading.',
      );
    }
    final store = _ref.read(avatarStoreProvider);
    final uid = _ref.read(authUidProvider);
    final result = await store.pickFromGallery(uploadUid: uid);
    if (result.isSaved) {
      await _setAvatar(result.avatar!);
    }
    return result;
  }

  Future<void> _setAvatar(AvatarRef avatar) async {
    final current = _view;
    if (current == null) return;
    final uid = _ref.read(authUidProvider);
    if (uid == null) return;
    try {
      await _ref
          .read(userRepositoryProvider)
          .updateProfile(uid: uid, avatarRef: avatar.storageValue);
      if (!mounted) return;
      state = AsyncValue.data(
        current.copyWith(identity: current.identity.copyWith(avatar: avatar)),
      );
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

/// The hero profile controller.
final heroProfileControllerProvider =
    StateNotifierProvider<HeroProfileController, AsyncValue<HeroProfileView>>(
      HeroProfileController.new,
    );

/// Hero identity for the table: always resolves, defaulting to `Hero`.
final heroIdentityProvider = Provider<HeroIdentity>((ref) {
  return ref.watch(heroProfileControllerProvider).valueOrNull?.identity ??
      const HeroIdentity();
});
