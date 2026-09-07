/// Elliptical felt with villain seats, live bets, and chips moving to the pot.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/chip_format.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/core/constants/money.dart';
import 'package:live_poker_trainer/models/game_state.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/ui/widgets/community_cards_view.dart';
import 'package:live_poker_trainer/ui/widgets/player_seat_widget.dart';

/// Responsive elliptical table view.
///
/// The hero is deliberately *not* drawn on the felt: hero cards live on their
/// own rail below, which is what keeps the coach shelf from ever covering them.
/// Every seat is laid out inside a fixed box and clamped to the felt band, so
/// nothing can spill into the bands below.
class FeltTableView extends StatelessWidget {
  /// Creates the felt table.
  const FeltTableView({
    super.key,
    required this.game,
    required this.chipDisplayMode,
    this.collectingChips = false,
    this.review = false,
  });

  final GameState game;

  /// Table amounts are currency-only; see [ChipDisplayMode.tableMode].
  final ChipDisplayMode chipDisplayMode;

  /// True while the street's bets animate into the pot.
  final bool collectingChips;

  /// True once the hand is over: the felt inherits the action dock's band and
  /// the board is allowed to grow into it (still bounded by the seat ring).
  final bool review;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final n = game.players.length;
        final compact = n >= 7 || w < 380 || h < 300;
        final seatBox = SeatMetrics.of(compactLayout: compact);

        final cx = w / 2;
        final cy = h / 2;
        final rx = math.max(0.0, (w - seatBox.width) / 2) * 0.96;
        final ry = math.max(0.0, (h - seatBox.height) / 2) * 0.94;

        final seats = <Widget>[];
        final bets = <Widget>[];

        for (var i = 0; i < n; i++) {
          final player = game.players[i];
          // Hero sits on the dedicated rail below the felt.
          if (player.isHero) continue;

          final angle = (math.pi / 2) + (2 * math.pi * i / n);
          final seatX = cx + rx * math.cos(angle);
          final seatY = cy + ry * math.sin(angle);

          seats.add(
            Positioned(
              left: _clamp(seatX - seatBox.width / 2, 0, w - seatBox.width),
              top: _clamp(seatY - seatBox.height / 2, 0, h - seatBox.height),
              child: PlayerSeatWidget(
                player: player,
                bigBlind: game.bigBlind,
                chipDisplayMode: chipDisplayMode,
                isActive: game.activePlayerIndex == i && !game.isHandOver,
                isDealer: game.dealerIndex == i,
                isSmallBlind: game.sbIndex == i,
                isBigBlind: game.bbIndex == i,
                compact: compact,
                showCards: game.isHandOver && !player.folded,
              ),
            ),
          );

          if (player.currentBet > Money.epsilon) {
            // Chips rest between the seat and the pot, then slide the rest of
            // the way in when the street's bets are collected. Bias further
            // toward the pot so the amount clears the seat box and pucks.
            final t = collectingChips ? 1.0 : 0.48;
            bets.add(
              _BetChip(
                key: ValueKey('bet-${player.id}'),
                left: _lerp(seatX, cx, t),
                top: _lerp(seatY, cy, t),
                label: ChipFormat.chips(
                  player.currentBet,
                  game.bigBlind,
                  chipDisplayMode,
                ),
                faded: collectingChips,
              ),
            );
          }

          if (player.lastActionLabel != null && !game.isHandOver) {
            seats.add(
              Positioned(
                left: _clamp(seatX - seatBox.width / 2, 0, w - seatBox.width),
                top: _clamp(
                  seatY + seatBox.height / 2 - 6,
                  0,
                  math.max(0.0, h - 18),
                ),
                width: seatBox.width,
                child: _ActionBadge(
                  key: ValueKey('act-${player.id}-${player.lastActionLabel}'),
                  label: player.lastActionLabel!,
                  archetype: player.archetype,
                ),
              ),
            );
          }
        }

        final boardScale = _boardScale(w, seatBox.width, review: review);

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _FeltPainter(seatBox: seatBox)),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: boardScale),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                builder: (context, scale, _) => CommunityCardsView(
                  community: game.community,
                  pot: game.displayPot,
                  street: game.street,
                  bigBlind: game.bigBlind,
                  chipDisplayMode: chipDisplayMode,
                  scale: scale,
                ),
              ),
            ),
            // Seats first, then bet chips above them so amounts are never
            // clipped by the seat box / D / SB / BB pucks.
            ...seats,
            ...bets,
          ],
        );
      },
    );
  }

  /// Board scale that always leaves a seat's width of clearance on each side.
  ///
  /// Review only lifts the ceiling — the seat-ring guard still binds, so a
  /// nine-handed phone keeps the same board and gains readability from the
  /// taller felt instead.
  static double _boardScale(
    double width,
    double seatWidth, {
    required bool review,
  }) {
    const naturalWidth = 5 * 43.0;
    final available = width - seatWidth * 2 - 12;
    if (available <= 0) return 0.62;
    return _clamp(available / naturalWidth, 0.62, review ? 1.34 : 1.2);
  }

  static double _clamp(double v, double lo, double hi) =>
      Money.clamp(v, lo, hi);

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

/// A chip pill representing a player's bet on the current street.
class _BetChip extends StatelessWidget {
  const _BetChip({
    super.key,
    required this.left,
    required this.top,
    required this.label,
    required this.faded,
  });

  final double left;
  final double top;
  final String label;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
      left: left,
      top: top,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 320),
        opacity: faded ? 0 : 1,
        // Transform anchors the pill on its center without a fixed width that
        // would clip long amounts under a seat-sized box.
        child: Transform.translate(
          offset: const Offset(0, -10),
          child: FractionalTranslation(
            translation: const Offset(-0.5, 0),
            child: Material(
              color: Colors.transparent,
              elevation: 6,
              shadowColor: Colors.black54,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.bgDark.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.85),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pops the villain's most recent action so the replay reads as live play.
class _ActionBadge extends StatefulWidget {
  const _ActionBadge({
    super.key,
    required this.label,
    required this.archetype,
  });

  final String label;
  final PlayerArchetype archetype;

  @override
  State<_ActionBadge> createState() => _ActionBadgeState();
}

class _ActionBadgeState extends State<_ActionBadge> {
  double _scale = 0.7;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _scale = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final color = switch (label) {
      'FOLD' => AppColors.slate,
      'CHECK' => AppColors.slate,
      'BLIND' => AppColors.goldMuted,
      'CALL' => AppColors.warning,
      _ => AppColors.danger,
    };
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: AppColors.bgDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeltPainter extends CustomPainter {
  const _FeltPainter({required this.seatBox});

  final Size seatBox;

  @override
  void paint(Canvas canvas, Size size) {
    final width = math.max(60.0, size.width - seatBox.width * 0.75);
    final height = math.max(60.0, size.height - seatBox.height * 0.7);
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: width,
      height: height,
    );

    final rim = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.feltRim, AppColors.feltBorder, AppColors.feltRim],
      ).createShader(rect);
    canvas.drawOval(rect.inflate(11), rim);

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
  bool shouldRepaint(covariant _FeltPainter oldDelegate) =>
      oldDelegate.seatBox != seatBox;
}
