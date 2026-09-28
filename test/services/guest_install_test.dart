/// Fresh-install guest identity: a keychain user must not keep old XP.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/services/guest_install.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a fresh install discards a restored anonymous user', () {
    expect(
      guestInstallAction(
        anonymous: true,
        uid: 'previous-guest',
        storedInstallUid: null,
        discardRestoredAnonymous: true,
        hasOnboardingDraft: false,
      ),
      GuestInstallAction.signOut,
    );
    expect(
      guestInstallAction(
        anonymous: true,
        uid: 'previous-guest',
        storedInstallUid: null,
        discardRestoredAnonymous: false,
        hasOnboardingDraft: false,
      ),
      GuestInstallAction.signOut,
    );
  });

  test('a draft written after the discard mark still signs out', () {
    expect(
      guestInstallAction(
        anonymous: true,
        uid: 'previous-guest',
        storedInstallUid: null,
        discardRestoredAnonymous: true,
        hasOnboardingDraft: true,
      ),
      GuestInstallAction.signOut,
    );
  });

  test('an update with a draft adopts the current guest', () {
    expect(
      guestInstallAction(
        anonymous: true,
        uid: 'this-guest',
        storedInstallUid: null,
        discardRestoredAnonymous: false,
        hasOnboardingDraft: true,
      ),
      GuestInstallAction.adopt,
    );
  });

  test('a claimed uid is kept', () {
    expect(
      guestInstallAction(
        anonymous: true,
        uid: 'this-guest',
        storedInstallUid: 'this-guest',
        discardRestoredAnonymous: true,
        hasOnboardingDraft: true,
      ),
      GuestInstallAction.keep,
    );
  });

  test('a linked account is not a guest install', () {
    expect(
      guestInstallAction(
        anonymous: false,
        uid: 'account',
        storedInstallUid: null,
        discardRestoredAnonymous: true,
        hasOnboardingDraft: false,
      ),
      GuestInstallAction.keep,
    );
  });

  test(
    'the first launch with no draft marks the keychain user for discard',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      await markGuestInstallGeneration(prefs);
      expect(prefs.getBool(discardRestoredAnonymousKey), isTrue);

      await prefs.setString(onboardingDraftPrefsKey, '{"step":"experience"}');
      await markGuestInstallGeneration(prefs);
      expect(prefs.getBool(discardRestoredAnonymousKey), isTrue);
    },
  );

  test('the first launch with a draft keeps the guest', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      onboardingDraftPrefsKey: '{"step":"done"}',
    });
    final prefs = await SharedPreferences.getInstance();
    await markGuestInstallGeneration(prefs);
    expect(prefs.getBool(discardRestoredAnonymousKey), isFalse);
  });
}
