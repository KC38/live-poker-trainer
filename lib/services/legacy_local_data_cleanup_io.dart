/// Deletes databases and avatars created by older edge-persistence builds.
library;

import 'dart:io';

import 'package:path_provider/path_provider.dart';

const _databaseNames = {'poker_lab', 'poker_profile'};
const _databaseSuffixes = {
  '',
  '.db',
  '.sqlite',
  '-journal',
  '-shm',
  '-wal',
  '.db-journal',
  '.db-shm',
  '.db-wal',
  '.sqlite-journal',
  '.sqlite-shm',
  '.sqlite-wal',
};

/// Idempotently removes known obsolete SQLite files and avatar directories.
Future<bool> deleteLegacyLocalData() async {
  final directories = <Directory>[];
  final lookupSucceeded = await runLegacyCleanupAttempts(
    <Future<void> Function()>[
      for (final lookup in <Future<Directory> Function()>[
        getApplicationSupportDirectory,
        getApplicationDocumentsDirectory,
      ])
        () async {
          final directory = await lookup();
          if (directories.every(
            (candidate) => candidate.path != directory.path,
          )) {
            directories.add(directory);
          }
        },
    ],
  );

  final deletionAttempts = <Future<void> Function()>[];
  for (final directory in directories) {
    for (final name in _databaseNames) {
      for (final suffix in _databaseSuffixes) {
        final file = File(
          '${directory.path}${Platform.pathSeparator}$name$suffix',
        );
        deletionAttempts.add(() => _deleteFile(file));
      }
    }
    final avatarDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}avatars',
    );
    deletionAttempts.add(() => _deleteDirectory(avatarDirectory));
  }

  final deletionSucceeded = await runLegacyCleanupAttempts(deletionAttempts);
  return lookupSucceeded && deletionSucceeded;
}

/// Runs every cleanup attempt and reports whether all of them succeeded.
///
/// This is public to allow deterministic tests without touching the real file
/// system. A failed attempt never prevents later paths from being attempted.
Future<bool> runLegacyCleanupAttempts(
  Iterable<Future<void> Function()> attempts,
) async {
  var succeeded = true;
  for (final attempt in attempts) {
    try {
      await attempt();
    } on Object {
      succeeded = false;
    }
  }
  return succeeded;
}

Future<void> _deleteFile(File file) async {
  if (await file.exists()) await file.delete();
}

Future<void> _deleteDirectory(Directory directory) async {
  if (await directory.exists()) await directory.delete(recursive: true);
}
