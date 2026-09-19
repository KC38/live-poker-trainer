/// Tests for the version-gated legacy local data cleanup migration.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/services/legacy_local_data_cleanup.dart';
import 'package:live_poker_trainer/services/legacy_local_data_cleanup_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('first run executes cleanup and stores migration version', () async {
    final preferences = await SharedPreferences.getInstance();
    var cleanupCalls = 0;

    final executed = await runLegacyLocalDataCleanupMigration(
      preferences: preferences,
      cleanup: () async {
        cleanupCalls += 1;
        return true;
      },
    );

    expect(executed, isTrue);
    expect(cleanupCalls, 1);
    expect(preferences.getInt(legacyCleanupVersionKey), legacyCleanupVersion);
  });

  test('subsequent run skips cleanup', () async {
    SharedPreferences.setMockInitialValues({
      legacyCleanupVersionKey: legacyCleanupVersion,
    });
    final preferences = await SharedPreferences.getInstance();
    var cleanupCalls = 0;

    final executed = await runLegacyLocalDataCleanupMigration(
      preferences: preferences,
      cleanup: () async {
        cleanupCalls += 1;
        return true;
      },
    );

    expect(executed, isTrue);
    expect(cleanupCalls, 0);
  });

  test('failed cleanup leaves no marker and retries next run', () async {
    final preferences = await SharedPreferences.getInstance();
    var cleanupCalls = 0;

    Future<bool> failCleanup() async {
      cleanupCalls += 1;
      return false;
    }

    final firstResult = await runLegacyLocalDataCleanupMigration(
      preferences: preferences,
      cleanup: failCleanup,
    );
    final secondResult = await runLegacyLocalDataCleanupMigration(
      preferences: preferences,
      cleanup: failCleanup,
    );

    expect(firstResult, isFalse);
    expect(secondResult, isFalse);
    expect(cleanupCalls, 2);
    expect(preferences.containsKey(legacyCleanupVersionKey), isFalse);
  });

  test('file cleanup aggregation continues after a failure', () async {
    final attempted = <int>[];

    final succeeded = await runLegacyCleanupAttempts([
      () async => attempted.add(1),
      () async {
        attempted.add(2);
        throw const FileSystemException('locked');
      },
      () async => attempted.add(3),
    ]);

    expect(succeeded, isFalse);
    expect(attempted, [1, 2, 3]);
  });
}
