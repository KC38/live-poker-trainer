/// Reads `appConfig/courseFlags` for client-side course gating.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/services/firestore/live_hand_service.dart';

/// Repository for the server-authored course flag document.
class CourseFlagsRepository {
  /// Creates a repository.
  CourseFlagsRepository({FirebaseFirestore? firestore}) : _override = firestore;

  final FirebaseFirestore? _override;

  FirebaseFirestore get _db => _override ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _flagsDoc =>
      _db.collection('appConfig').doc('courseFlags');

  /// Loads flags once from the server. Fetch failures fail closed.
  ///
  /// [clientVersion] defaults to the shipping app version. Clients older
  /// than `minimumClientVersion` are treated as course-disabled.
  Future<CourseFlags> load({String? clientVersion}) async {
    final version = clientVersion ?? liveClientVersion;
    try {
      final snap = await _flagsDoc.get(const GetOptions(source: Source.server));
      return CourseFlags.resolve(
        fetched: true,
        data: snap.data(),
        clientVersion: version,
      );
    } catch (_) {
      return CourseFlags.resolve(fetched: false, clientVersion: version);
    }
  }

  /// Streams flag updates; errors emit disabled flags.
  Stream<CourseFlags> watch({String? clientVersion}) {
    final version = clientVersion ?? liveClientVersion;
    return _flagsDoc
        .snapshots()
        .map((snap) {
          return CourseFlags.resolve(
            fetched: true,
            data: snap.data(),
            clientVersion: version,
          );
        })
        .handleError((_) {
          // Stream providers treat errors separately; callers should prefer [load].
        });
  }
}
