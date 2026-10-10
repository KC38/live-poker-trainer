/// A hung guest user-doc write must not block the first lesson start.
library;

import 'dart:async';

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/user_document.dart';
import 'package:live_poker_trainer/providers/analytics_provider.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/services/analytics/analytics_service.dart';
import 'package:live_poker_trainer/services/auth_service.dart';
import 'package:live_poker_trainer/services/firestore/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ensureAnonymousSession returns the guest when the doc write hangs',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final auth = MockFirebaseAuth();
    final users = _HungUserRepository();
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(AuthService(firebaseAuth: auth)),
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        userRepositoryProvider.overrideWithValue(users),
        analyticsServiceProvider.overrideWithValue(
          AnalyticsService(enabled: false),
        ),
        authControllerProvider.overrideWith(
          (ref) => AuthController(
            ref,
            guestUserDocTimeout: const Duration(milliseconds: 50),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final user = await container
        .read(authControllerProvider.notifier)
        .ensureAnonymousSession()
        .timeout(const Duration(seconds: 2));

    expect(user.isAnonymous, isTrue);
    expect(users.ensureCalls, greaterThanOrEqualTo(1));
    expect(container.read(authControllerProvider).hasError, isFalse);
  });
}

class _HungUserRepository extends UserRepository {
  int ensureCalls = 0;

  @override
  Future<UserDocument> ensureUserDoc({
    required String uid,
    String? displayName,
    String? avatarRef,
    GameSettingsModel preferences = const GameSettingsModel(),
  }) {
    ensureCalls += 1;
    return Completer<UserDocument>().future;
  }
}
