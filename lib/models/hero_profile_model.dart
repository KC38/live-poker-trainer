/// Hero identity (display name, avatar) and the cached AI style summary.
library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/hero_metrics.dart';

/// Where an avatar image comes from.
enum AvatarKind {
  /// No picture chosen — initials are drawn instead.
  none,

  /// One of the [BuiltInAvatar] designs, painted at render time.
  builtIn,

  /// A user photo copied into the app documents directory.
  file,
}

/// Procedurally drawn avatars offered as one-tap defaults.
///
/// These are painted from a gradient plus a glyph rather than shipped as image
/// assets: they stay crisp at any size, add nothing to the bundle, and work
/// offline. [id] is persisted — never rename one.
enum BuiltInAvatar {
  spade('spade', 'Spade', '\u2660', Color(0xFF243447), AppColors.cream),
  heart('heart', 'Heart', '\u2665', Color(0xFF4A1220), Color(0xFFF08A8A)),
  diamond('diamond', 'Diamond', '\u2666', Color(0xFF102A4A), Color(0xFF7FB2F0)),
  club('club', 'Club', '\u2663', Color(0xFF0E3423), Color(0xFF6FD79B)),
  chip('chip', 'Chip', '\u25C9', Color(0xFF3A2A08), AppColors.goldBright),
  crown('crown', 'Crown', '\u265B', Color(0xFF2C1A3E), Color(0xFFCBA6F7)),
  button('button', 'Dealer', 'D', Color(0xFF1F2A38), AppColors.gold),
  star('star', 'Star', '\u2605', Color(0xFF07312C), Color(0xFF6FE3D2));

  const BuiltInAvatar(this.id, this.label, this.glyph, this.base, this.accent);

  /// Persisted identifier.
  final String id;

  /// Name shown in the picker.
  final String label;

  /// Character painted in the middle.
  final String glyph;

  /// Background base color (the gradient darkens from here).
  final Color base;

  /// Glyph and ring color.
  final Color accent;

  /// Resolves a persisted id, defaulting to [BuiltInAvatar.spade].
  static BuiltInAvatar fromId(String id) {
    for (final avatar in values) {
      if (avatar.id == id) return avatar;
    }
    return BuiltInAvatar.spade;
  }
}

/// A reference to the hero's avatar, persisted as a single string.
///
/// Encoded as `builtin:<id>`, `file:<absolute path>`, or the empty string. The
/// file variant stores a path rather than bytes so the database stays small
/// and the image can be replaced without a schema change.
@immutable
class AvatarRef {
  const AvatarRef._(this.kind, this.value);

  /// No avatar chosen.
  const AvatarRef.none() : this._(AvatarKind.none, '');

  /// One of the [BuiltInAvatar] designs.
  ///
  /// Not `const`: reading `avatar.id` off an enum is not a constant
  /// expression, and the id is what gets persisted.
  AvatarRef.builtIn(BuiltInAvatar avatar)
      : this._(AvatarKind.builtIn, avatar.id);

  /// A photo stored at [path] inside the app documents directory.
  const AvatarRef.file(String path) : this._(AvatarKind.file, path);

  final AvatarKind kind;

  /// Built-in id or absolute file path; empty for [AvatarKind.none].
  final String value;

  static const String _builtInPrefix = 'builtin:';
  static const String _filePrefix = 'file:';

  /// Parses a persisted value, tolerating null, empty, and bare paths.
  static AvatarRef parse(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return const AvatarRef.none();
    if (text.startsWith(_builtInPrefix)) {
      final id = text.substring(_builtInPrefix.length);
      return AvatarRef.builtIn(BuiltInAvatar.fromId(id));
    }
    if (text.startsWith(_filePrefix)) {
      final path = text.substring(_filePrefix.length);
      return path.isEmpty ? const AvatarRef.none() : AvatarRef.file(path);
    }
    // Bare absolute path (older writes).
    return text.startsWith('/')
        ? AvatarRef.file(text)
        : const AvatarRef.none();
  }

  /// The string written to the database.
  String get storageValue => switch (kind) {
        AvatarKind.none => '',
        AvatarKind.builtIn => '$_builtInPrefix$value',
        AvatarKind.file => '$_filePrefix$value',
      };

  /// The built-in design, when this is a built-in avatar.
  BuiltInAvatar? get builtIn =>
      kind == AvatarKind.builtIn ? BuiltInAvatar.fromId(value) : null;

  /// The absolute file path, when this is a photo.
  String? get filePath => kind == AvatarKind.file ? value : null;

  bool get isEmpty => kind == AvatarKind.none;

  @override
  bool operator ==(Object other) =>
      other is AvatarRef && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => 'AvatarRef(${storageValue.isEmpty ? 'none' : storageValue})';
}

/// The hero's editable identity.
@immutable
class HeroIdentity {
  /// Creates an identity.
  const HeroIdentity({
    this.displayName = defaultDisplayName,
    this.avatar = const AvatarRef.none(),
  });

  /// Name used before the player picks one.
  static const String defaultDisplayName = 'Hero';

  /// Longest accepted display name.
  static const int maxNameLength = 18;

  final String displayName;
  final AvatarRef avatar;

  /// Name shown at the hero seat, never empty.
  String get seatName =>
      displayName.trim().isEmpty ? defaultDisplayName : displayName.trim();

  /// Whether the player has chosen a name of their own.
  bool get hasCustomName => seatName != defaultDisplayName;

  /// Label for the hero rail.
  ///
  /// The default name is replaced with `YOU`: at the table the player needs
  /// to spot their own seat instantly, and "HERO" reads as jargon until they
  /// have deliberately named themselves something.
  String get railLabel =>
      hasCustomName ? seatName.toUpperCase() : 'YOU';

  /// One or two letters for the avatar fallback.
  String get initials {
    final parts = seatName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'H';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  /// Trims and clamps [raw] to a storable display name.
  static String sanitizeName(String raw) {
    final collapsed = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.isEmpty) return defaultDisplayName;
    return collapsed.length <= maxNameLength
        ? collapsed
        : collapsed.substring(0, maxNameLength).trim();
  }

  HeroIdentity copyWith({String? displayName, AvatarRef? avatar}) =>
      HeroIdentity(
        displayName: displayName ?? this.displayName,
        avatar: avatar ?? this.avatar,
      );
}

/// Cached AI (or offline) read on the hero's game.
@immutable
class ProfileCoachSummary {
  /// Creates a summary.
  const ProfileCoachSummary({
    required this.styleSummary,
    required this.leaks,
    required this.adjustments,
    required this.source,
    required this.modelId,
    required this.handsPlayedAt,
    required this.styleId,
    required this.generatedAt,
  });

  /// Deserializes a stored summary.
  factory ProfileCoachSummary.fromStorage({
    required String styleSummary,
    required String leaksJson,
    required String adjustmentsJson,
    required String source,
    required String modelId,
    required int handsPlayedAt,
    required String styleId,
    required int generatedAtMs,
  }) {
    return ProfileCoachSummary(
      styleSummary: styleSummary,
      leaks: _decodeList(leaksJson),
      adjustments: _decodeList(adjustmentsJson),
      source: source,
      modelId: modelId,
      handsPlayedAt: handsPlayedAt,
      styleId: styleId,
      generatedAt: DateTime.fromMillisecondsSinceEpoch(
        generatedAtMs,
        isUtc: true,
      ),
    );
  }

  /// Two or three sentences on how the player plays.
  final String styleSummary;

  /// Biggest leaks, one punchy line each.
  final List<String> leaks;

  /// Concrete adjustments to make next session.
  final List<String> adjustments;

  /// `gemini` or `offline`.
  final String source;

  /// Model that produced it (empty for offline copy).
  final String modelId;

  /// Hands played when this summary was written.
  final int handsPlayedAt;

  /// [PlayingStyle.name] at generation time.
  final String styleId;

  final DateTime generatedAt;

  bool get isFromAi => source == geminiSource;

  /// Source tag for Gemini-written summaries.
  static const String geminiSource = 'gemini';

  /// Source tag for locally derived copy.
  static const String offlineSource = 'offline';

  /// Hands that must be added before a refresh is worth the API call.
  static const int refreshEveryHands = 25;

  /// A summary older than this is refreshed even without new hands.
  static const Duration maxAge = Duration(days: 14);

  /// Whether this summary should be regenerated for the current [metrics].
  ///
  /// The screen must not call Gemini on every open: a refresh only happens
  /// after a meaningful number of new hands, when the style label changes, or
  /// when the cached copy is stale or was written offline.
  bool needsRefresh(HeroMetrics metrics, DateTime now) {
    if (styleId != metrics.style.style.name) return true;
    if (metrics.handsPlayed - handsPlayedAt >= refreshEveryHands) return true;
    if (now.toUtc().difference(generatedAt) > maxAge) return true;
    return !isFromAi;
  }

  String get leaksJson => jsonEncode(leaks);

  String get adjustmentsJson => jsonEncode(adjustments);

  static List<String> _decodeList(String raw) {
    if (raw.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return List.unmodifiable(
          decoded.map((e) => '$e').where((e) => e.trim().isNotEmpty),
        );
      }
    } catch (_) {
      // Corrupt cache is not worth crashing the profile for.
    }
    return const [];
  }
}

/// Everything the profile screen needs, identity plus derived numbers.
@immutable
class HeroProfileView {
  /// Creates a view.
  const HeroProfileView({
    required this.identity,
    required this.metrics,
    this.summary,
    this.summaryRefreshing = false,
  });

  final HeroIdentity identity;
  final HeroMetrics metrics;

  /// Cached coach summary, null until one has been generated.
  final ProfileCoachSummary? summary;

  /// True while a fresh summary is being fetched in the background.
  final bool summaryRefreshing;

  HeroProfileView copyWith({
    HeroIdentity? identity,
    HeroMetrics? metrics,
    ProfileCoachSummary? summary,
    bool? summaryRefreshing,
  }) {
    return HeroProfileView(
      identity: identity ?? this.identity,
      metrics: metrics ?? this.metrics,
      summary: summary ?? this.summary,
      summaryRefreshing: summaryRefreshing ?? this.summaryRefreshing,
    );
  }
}
