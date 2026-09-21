/// Live Training access derived from getLiveAccess.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/models/live_access.dart';
import 'package:live_poker_trainer/providers/auth_provider.dart';
import 'package:live_poker_trainer/providers/service_providers.dart';

/// Server-backed Live access. Anonymous users are always locked.
///
/// Network failures fall open on the client so grandfathered users are not
/// stuck behind a gate; Live callables still enforce the real restriction.
final liveAccessProvider = FutureProvider<LiveAccessSnapshot>((ref) async {
  final user = ref.watch(authServiceProvider).currentUser;
  if (user == null || user.isAnonymous) {
    return LiveAccessSnapshot.locked();
  }
  try {
    final data = await ref.read(liveHandServiceProvider).getLiveAccess();
    return LiveAccessSnapshot.fromJson(data);
  } catch (_) {
    return const LiveAccessSnapshot(
      tier: LiveAccessTier.unrestricted,
      source: 'unavailable',
      unrestrictedAccess: true,
      warmUpAvailable: true,
    );
  }
});
