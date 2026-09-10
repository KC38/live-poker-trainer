/// Firestore shape for `users/{uid}` (profile + preferences + stats).
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';
import 'package:live_poker_trainer/models/user_stats_model.dart';

/// Cloud user document — source of truth for synced prefs/stats/identity.
@immutable
class UserDocument {
  /// Creates a user document.
  const UserDocument({
    required this.displayName,
    required this.avatarRef,
    required this.createdAt,
    required this.updatedAt,
    required this.preferences,
    required this.stats,
  });

  final String displayName;

  /// [AvatarRef.storageValue] string (may be empty).
  final String avatarRef;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Gameplay prefs; audio fields are ignored when writing to Firestore.
  final GameSettingsModel preferences;
  final UserStatsModel stats;

  /// Identity view for the table / Progress screen.
  HeroIdentity get identity => HeroIdentity(
        displayName: displayName,
        avatar: AvatarRef.parse(avatarRef),
      );

  /// Serializes for a full document write.
  Map<String, Object?> toFirestoreMap() => {
        'displayName': displayName,
        'avatarRef': avatarRef,
        'createdAt': Timestamp.fromDate(createdAt.toUtc()),
        'updatedAt': Timestamp.fromDate(updatedAt.toUtc()),
        'preferences': preferences.toFirestorePreferences(),
        'stats': stats.toFirestoreMap(),
      };

  /// Parses a Firestore map; tolerates missing / partial fields.
  factory UserDocument.fromFirestore(Map<String, dynamic> data) {
    final prefsRaw = data['preferences'];
    final statsRaw = data['stats'];
    return UserDocument(
      displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
          ? data['displayName'] as String
          : HeroIdentity.defaultDisplayName,
      avatarRef: data['avatarRef'] as String? ?? '',
      createdAt: _readTime(data['createdAt']) ?? DateTime.now().toUtc(),
      updatedAt: _readTime(data['updatedAt']) ?? DateTime.now().toUtc(),
      preferences: prefsRaw is Map
          ? GameSettingsModel.fromFirestorePreferences(
              Map<String, dynamic>.from(prefsRaw),
            )
          : const GameSettingsModel(),
      stats: statsRaw is Map
          ? UserStatsModel.fromFirestoreMap(Map<String, dynamic>.from(statsRaw))
          : const UserStatsModel(),
    );
  }

  static DateTime? _readTime(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    return null;
  }
}
