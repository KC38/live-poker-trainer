/// Cloud preference hydration must follow uid, not every auth event.
library;

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/user_document.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/auth_service.dart';
import 'package:live_poker_trainer/services/firestore/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SettingsNotifier settings;
  late _CountingUserRepository users;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'sfxEnabled': false,
      'musicEnabled': true,
    });
    prefs = await SharedPreferences.getInstance();
    settings = SettingsNotifier(prefs);
    users = _CountingUserRepository(
      const GameSettingsModel(seatCount: 6, smallBlind: 1, bigBlind: 2),
    );
  });

  test('token refresh keeps an in-memory table-setup edit', () async {
    final user = MockUser(uid: 'user-1', displayName: 'Ada');
    final auth = MockFirebaseAuth(mockUser: user);
    final container = _container(
      auth: auth,
      prefs: prefs,
      settings: settings,
      users: users,
    );
    addTearDown(container.dispose);
    container.listen(userDocProvider, (_, _) {});
    container.listen(appAuthProvider, (_, _) {});

    await auth.signInWithCredential(null);
    await _until(() => users.ensureCalls >= 1);
    await container.read(userDocProvider.future);

    expect(users.ensureCalls, 1);
    expect(container.read(settingsProvider).seatCount, 6);
    await settings.setSeatCount(8);
    expect(container.read(settingsProvider).seatCount, 8);

    auth.userChangedStreamController.add(auth.currentUser);
    await _settle(const Duration(milliseconds: 100));

    expect(users.ensureCalls, 1);
    expect(container.read(settingsProvider).seatCount, 8);
    expect(container.read(settingsProvider).smallBlind, 1);
  });

  test(
    'linking the same uid updates anonymous state without rehydrating',
    () async {
      final guest = MockUser(
        uid: 'user-1',
        isAnonymous: true,
        displayName: 'Guest',
      );
      final auth = MockFirebaseAuth(mockUser: guest);
      final container = _container(
        auth: auth,
        prefs: prefs,
        settings: settings,
        users: users,
      );
      addTearDown(container.dispose);
      container.listen(userDocProvider, (_, _) {});
      container.listen(appAuthProvider, (_, _) {});

      await auth.signInAnonymously();
      await _until(() => users.ensureCalls >= 1);
      await container.read(userDocProvider.future);
      await settings.setSeatCount(8);
      expect(container.read(appAuthProvider).asData?.value.isAnonymous, isTrue);

      final linked = MockUser(uid: 'user-1', displayName: 'Ada');
      auth.mockUser = linked;
      auth.userChangedStreamController.add(linked);
      await _settle(const Duration(milliseconds: 100));

      expect(
        container.read(appAuthProvider).asData?.value.isAnonymous,
        isFalse,
      );
      expect(container.read(appAuthProvider).asData?.value.uid, 'user-1');
      expect(users.ensureCalls, 1);
      expect(container.read(settingsProvider).seatCount, 8);
    },
  );

  test('a different uid hydrates that account', () async {
    final user = MockUser(uid: 'user-1', displayName: 'Ada');
    final auth = MockFirebaseAuth(mockUser: user);
    final container = _container(
      auth: auth,
      prefs: prefs,
      settings: settings,
      users: users,
    );
    addTearDown(container.dispose);
    container.listen(userDocProvider, (_, _) {});

    await auth.signInWithCredential(null);
    await _until(() => users.ensureCalls >= 1);
    await container.read(userDocProvider.future);
    await settings.setSeatCount(8);

    final other = MockUser(uid: 'user-2', displayName: 'Bea');
    auth.mockUser = other;
    auth.userChangedStreamController.add(other);
    await _until(() => users.ensureCalls >= 2);
    await container.read(userDocProvider.future);

    expect(users.ensureCalls, 2);
    expect(users.uids, ['user-1', 'user-2']);
    expect(container.read(settingsProvider).seatCount, 6);
  });
}

ProviderContainer _container({
  required MockFirebaseAuth auth,
  required SharedPreferences prefs,
  required SettingsNotifier settings,
  required _CountingUserRepository users,
}) {
  return ProviderContainer(
    overrides: [
      authServiceProvider.overrideWithValue(AuthService(firebaseAuth: auth)),
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
      settingsProvider.overrideWith((ref) => settings),
      userRepositoryProvider.overrideWithValue(users),
    ],
  );
}

Future<void> _settle([
  Duration duration = const Duration(milliseconds: 20),
]) async {
  await Future<void>.delayed(duration);
}

Future<void> _until(bool Function() ready) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    if (ready()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Timed out waiting for user-doc hydration.');
}

class _CountingUserRepository extends UserRepository {
  _CountingUserRepository(this.remote);

  final GameSettingsModel remote;
  int ensureCalls = 0;
  final List<String> uids = [];

  @override
  Future<UserDocument> ensureUserDoc({
    required String uid,
    String? displayName,
    String? avatarRef,
    GameSettingsModel preferences = const GameSettingsModel(),
  }) async {
    ensureCalls += 1;
    uids.add(uid);
    final now = DateTime.utc(2026);
    return UserDocument(
      displayName: displayName ?? 'Hero',
      avatarRef: avatarRef ?? '',
      createdAt: now,
      updatedAt: now,
      preferences: remote,
    );
  }
}
