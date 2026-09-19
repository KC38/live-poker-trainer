/// One-time migration for removing obsolete edge-persisted training data.
library;

import 'package:shared_preferences/shared_preferences.dart';

import 'legacy_local_data_cleanup_stub.dart'
    if (dart.library.io) 'legacy_local_data_cleanup_io.dart'
    if (dart.library.js_interop) 'legacy_local_data_cleanup_web.dart'
    as platform;

/// SharedPreferences key for operational cleanup migration metadata.
const legacyCleanupVersionKey = 'legacyCleanupVersion';

/// Current local cleanup migration version.
const legacyCleanupVersion = 1;

/// Runs platform cleanup once for each cleanup migration version.
///
/// The marker is operational metadata, not training data. Platform cleanup is
/// idempotent. Failed cleanup is left unmarked so a later launch can retry.
Future<bool> runLegacyLocalDataCleanupMigration({
  SharedPreferences? preferences,
  Future<bool> Function()? cleanup,
}) async {
  final prefs = preferences ?? await SharedPreferences.getInstance();
  final completedVersion = prefs.getInt(legacyCleanupVersionKey) ?? 0;
  if (completedVersion >= legacyCleanupVersion) return true;

  final cleanupSucceeded = await (cleanup ?? platform.deleteLegacyLocalData)();
  if (!cleanupSucceeded) return false;

  return prefs.setInt(legacyCleanupVersionKey, legacyCleanupVersion);
}
