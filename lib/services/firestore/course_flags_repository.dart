/// Reads `appConfig/courseFlags` for client-side course gating.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';

/// Repository for the server-authored course flag document.
class CourseFlagsRepository {
  /// Creates a repository.
  CourseFlagsRepository({FirebaseFirestore? firestore}) : _override = firestore;

  final FirebaseFirestore? _override;

  FirebaseFirestore get _db => _override ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _flagsDoc =>
      _db.collection('appConfig').doc('courseFlags');

  /// Loads flags once from the server. Fetch failures fail closed.
  Future<CourseFlags> load() async {
    try {
      final snap = await _flagsDoc.get(const GetOptions(source: Source.server));
      return CourseFlags.fromMap(snap.data());
    } catch (_) {
      return CourseFlags.disabled();
    }
  }

  /// Streams flag updates; errors emit disabled flags.
  Stream<CourseFlags> watch() {
    return _flagsDoc.snapshots().map((snap) {
      return CourseFlags.fromMap(snap.data());
    }).handleError((_) {
      // Stream providers treat errors separately; callers should prefer [load].
    });
  }
}
