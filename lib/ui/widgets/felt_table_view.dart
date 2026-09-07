/// Elliptical felt table with auto-scaling 2–9 seat layout.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/providers/settings_provider.dart';
import 'package:live_poker_trainer/ui/widgets/community_cards_view.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';

/// Responsive elliptical table view.
class FeltTableView extends ConsumerWidget {
  /// Creates the felt table.
  const FeltTableView({super.key, required this.game});

  final GameState game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chipMode = ref.watch(settingsProvider).chipDisplayMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final shortest = math.min(w, h);
        final micro = game.players.length >= 7 || shortest < 360;
        final scale = (shortest / 420).clamp(0.75, 1.35);

        final cx = w / 2;
        final cy = h / 2;
        final rx = w * 0.38;
        final ry = h * 0.34;

        final seats = <Widget>[];
        final n = game.players.length;
        for (var i = 0; i < n; i++) {
          final player = game.players[i];
          final angle = (math.pi / 2) + (2 * math.pi * i / n);
          final x = cx + rx * math.cos(angle);
          final y = cy + ry * math.sin(angle);

          seats.add(
            Positioned(
              left: x - (micro ? 36 : 48),
              top: y - (micro ? 40 : 52),
              child: PlayerSeatWidget(
                player: player,
                bigBlind: game.bigBlind,
                chipDisplayMode: chipMode,
                isActive: game.activePlayerIndex == i &&
                    !game.isHandOver &&
                    game.waitingForHero &&
                    player.isHero,
                isDealer: game.dealerIndex == i,
                isSmallBlind: game.sbIndex == i,
                isBigBlind: game.bbIndex == i,
                micro: micro,
                showCards: player.isHero || game.isHandOver,
              ),
            ),
          );
        }

        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _FeltPainter()),
            ),
            Center(
              child: CommunityCardsView(
                community: game.community,
                pot: game.totalPot,
                street: game.street,
                bigBlind: game.bigBlind,
                chipDisplayMode: chipMode,
                scale: scale,
              ),
            ),
            ...seats,
          ],
        );
      },
    );
  }
}

class _FeltPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.92,
      height: size.height * 0.82,
    );

    final rim = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.feltRim, AppColors.feltBorder, AppColors.feltRim],
      ).createShader(rect);
    canvas.drawOval(rect.inflate(12), rim);

    final felt = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.15),
        radius: 0.95,
        colors: [
          AppColors.feltLight.withValues(alpha: 0.95),
          AppColors.feltDark,
        ],
      ).createShader(rect);
    canvas.drawOval(rect, felt);

    final rail = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.gold.withValues(alpha: 0.22);
    canvas.drawOval(rect.deflate(8), rail);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
