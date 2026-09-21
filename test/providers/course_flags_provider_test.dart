import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_poker_trainer/models/course/course_flags.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/course_flags_provider.dart';
import 'package:live_poker_trainer/services/firestore/course_flags_repository.dart';

class _CountingFlagsRepository extends CourseFlagsRepository {
  _CountingFlagsRepository(this._flags);

  final CourseFlags _flags;
  int loads = 0;

  @override
  Future<CourseFlags> load({String? clientVersion}) async {
    loads += 1;
    return _flags;
  }
}

void main() {
  test('course flags reload when the auth uid changes', () async {
    const flags = CourseFlags(
      courseEnabled: true,
      courseStartsEnabled: true,
      guestCourseEnabled: true,
      placementTestsEnabled: false,
      catalogVersion: '2.0.0',
      minimumClientVersion: '2.0.0',
    );
    final repo = _CountingFlagsRepository(flags);
    final uid = StateProvider<String?>((ref) => null);
    final container = ProviderContainer(
      overrides: [
        courseFlagsRepositoryProvider.overrideWithValue(repo),
        authUidProvider.overrideWith((ref) => ref.watch(uid)),
      ],
    );
    addTearDown(container.dispose);

    final first = await container.read(courseFlagsProvider.future);
    expect(first.canStartAsGuest, isTrue);
    expect(repo.loads, 1);

    container.read(uid.notifier).state = 'anon-uid';
    final second = await container.read(courseFlagsProvider.future);
    expect(second.guestCourseEnabled, isTrue);
    expect(repo.loads, 2);
  });
}
