/// Circular hero avatar: user photo, built-in design, or initials.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/hero_profile_model.dart';

/// Renders the hero's avatar at [size], always as a circle.
///
/// Network failures fall back to initials.
class ProfileAvatar extends StatelessWidget {
  /// Creates an avatar.
  const ProfileAvatar({
    super.key,
    required this.identity,
    this.size = 40,
    this.ring = true,
  });

  final HeroIdentity identity;

  /// Diameter in logical pixels.
  final double size;

  /// Whether to draw the gold accent ring.
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final avatar = identity.avatar;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
            ring
                ? Border.all(
                  color: AppColors.gold.withValues(alpha: 0.75),
                  width: size >= 56 ? 2 : 1.4,
                )
                : null,
      ),
      child: ClipOval(
        child: switch (avatar.kind) {
          AvatarKind.network => _NetworkAvatar(
            url: avatar.networkUrl!,
            size: size,
            fallback: _InitialsAvatar(identity: identity, size: size),
          ),
          AvatarKind.builtIn => _GlyphAvatar(
            avatar: avatar.builtIn!,
            size: size,
          ),
          AvatarKind.none => _InitialsAvatar(identity: identity, size: size),
        },
      ),
    );
  }
}

class _NetworkAvatar extends StatelessWidget {
  const _NetworkAvatar({
    required this.url,
    required this.size,
    required this.fallback,
  });

  final String url;
  final double size;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

class _GlyphAvatar extends StatelessWidget {
  const _GlyphAvatar({required this.avatar, required this.size});

  final BuiltInAvatar avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [avatar.base, Color.lerp(avatar.base, Colors.black, 0.45)!],
        ),
      ),
      child: Center(
        child: Text(
          avatar.glyph,
          style: TextStyle(
            fontSize: size * 0.5,
            height: 1,
            color: avatar.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.identity, required this.size});

  final HeroIdentity identity;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgElevated, AppColors.bgDark],
        ),
      ),
      child: Center(
        child: Text(
          identity.initials,
          style: GoogleFonts.cinzel(
            fontSize: size * 0.42,
            height: 1,
            fontWeight: FontWeight.w700,
            color: AppColors.goldBright,
          ),
        ),
      ),
    );
  }
}
