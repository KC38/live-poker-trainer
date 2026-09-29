/// One permission-denied retry when creating `users/{uid}`.
///
/// Anonymous sign-in can write the profile before Firestore has the ID
/// token. [UserRepository.ensureUserDoc] retries that denial once and
/// leaves every other Firestore error alone.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/user_document.dart';
import 'package:live_poker_trainer/services/firestore/user_repository.dart';

void main() {
  test('the production denial retry waits briefly', () {
    expect(
      UserRepository().permissionDeniedRetryDelay,
      const Duration(milliseconds: 300),
    );
  });

  test('one permission-denied read retries and returns the doc', () async {
    final users = _ScriptedUserRepository(
      failures: 1,
      code: 'permission-denied',
    );
    final doc = await users.ensureUserDoc(uid: 'guest', displayName: 'Ada');

    expect(users.calls, 2);
    expect(doc.displayName, 'Ada');
    expect(users.requestedNames, ['Ada', 'Ada']);
  });

  test('a second permission-denied read is not retried', () async {
    final users = _ScriptedUserRepository(
      failures: 2,
      code: 'permission-denied',
    );

    await expectLater(
      users.ensureUserDoc(uid: 'guest'),
      throwsA(
        isA<FirebaseException>().having(
          (error) => error.code,
          'code',
          'permission-denied',
        ),
      ),
    );
    expect(users.calls, 2);
  });

  test('other Firestore errors are not retried', () async {
    final users = _ScriptedUserRepository(failures: 1, code: 'unavailable');

    await expectLater(
      users.ensureUserDoc(uid: 'guest'),
      throwsA(
        isA<FirebaseException>().having(
          (error) => error.code,
          'code',
          'unavailable',
        ),
      ),
    );
    expect(users.calls, 1);
  });

  test('a successful read does not retry', () async {
    final users = _ScriptedUserRepository(
      failures: 0,
      code: 'permission-denied',
    );
    final doc = await users.ensureUserDoc(uid: 'guest', displayName: 'Bea');

    expect(users.calls, 1);
    expect(doc.displayName, 'Bea');
  });
}

class _ScriptedUserRepository extends UserRepository {
  _ScriptedUserRepository({required this.failures, required this.code});

  final int failures;
  final String code;
  int calls = 0;
  final List<String> requestedNames = <String>[];

  @override
  Duration get permissionDeniedRetryDelay => Duration.zero;

  @override
  Future<UserDocument> ensureUserDocOnce({
    required String uid,
    required String requested,
    String? avatarRef,
    required GameSettingsModel preferences,
  }) async {
    calls += 1;
    requestedNames.add(requested);
    if (calls <= failures) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: code,
        message: 'scripted',
      );
    }
    final now = DateTime.utc(2026);
    return UserDocument(
      displayName: requested,
      avatarRef: avatarRef ?? '',
      createdAt: now,
      updatedAt: now,
      preferences: preferences,
    );
  }
}
