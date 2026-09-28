/// Whether a keychain anonymous user belongs to this install.
///
/// Uninstall deletes SharedPreferences and leaves the Firebase anonymous
/// user in the iOS keychain. That user still has course XP. A fresh install
/// that shows Welcome must start a new guest so Home XP is only this lesson.
library;

import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding draft key. Cleared when the app is uninstalled.
const onboardingDraftPrefsKey = 'onboarding_draft_v1';

/// Anonymous uid this install has claimed.
const guestInstallUidKey = 'guest_install_uid_v1';

/// Set on the first launch of an install that has no draft and no claimed uid.
///
/// True means a restored anonymous user is from a previous install.
const discardRestoredAnonymousKey = 'discard_restored_anonymous_v1';

/// What to do with the current anonymous user.
enum GuestInstallAction {
  /// This install already claimed the uid.
  keep,

  /// An update kept the onboarding draft. Claim the current uid.
  adopt,

  /// The uid belongs to a previous install. Sign out before the lesson.
  signOut,
}

/// Chooses [GuestInstallAction] from prefs and the restored user.
GuestInstallAction guestInstallAction({
  required bool anonymous,
  required String? uid,
  required String? storedInstallUid,
  required bool discardRestoredAnonymous,
  required bool hasOnboardingDraft,
}) {
  if (!anonymous || uid == null || uid.isEmpty) {
    return GuestInstallAction.keep;
  }
  if (storedInstallUid == uid) return GuestInstallAction.keep;
  if (discardRestoredAnonymous) return GuestInstallAction.signOut;
  if (storedInstallUid != null && storedInstallUid.isNotEmpty) {
    return GuestInstallAction.signOut;
  }
  if (hasOnboardingDraft) return GuestInstallAction.adopt;
  return GuestInstallAction.signOut;
}

/// Records the install generation once, before onboarding writes a draft.
///
/// A missing draft and a missing claimed uid means this process is the first
/// launch after install (or a never-started install). Any anonymous user
/// already in the keychain must be discarded.
Future<void> markGuestInstallGeneration(SharedPreferences prefs) async {
  if (prefs.containsKey(guestInstallUidKey)) return;
  if (prefs.containsKey(discardRestoredAnonymousKey)) return;
  final draft = prefs.getString(onboardingDraftPrefsKey);
  final hasDraft = draft != null && draft.isNotEmpty;
  await prefs.setBool(discardRestoredAnonymousKey, !hasDraft);
}
