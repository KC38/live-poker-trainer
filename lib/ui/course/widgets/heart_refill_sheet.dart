/// Duolingo-style heart refill sheet: practice, ad, gems, and timer.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:live_poker_trainer/core/constants/colors.dart';
import 'package:live_poker_trainer/models/course/course_session_models.dart';
import 'package:live_poker_trainer/services/firestore/course_service.dart';

/// Cost of a full gem refill (matches server [GEMS_FULL_HEART_REFILL]).
const int kGemsFullHeartRefill = 650;

/// Success snackbar copy after a heart refill, or `null` to show nothing.
///
/// The heart chrome already shows remaining/max, so confirmation toasts are
/// suppressed for every refill method (ad, gems, practice grant).
String? heartRefillSuccessSnackBarMessage(RefillCourseHeartsResult result) {
  // Keep the result parameter so call sites stay typed if copy returns later.
  return switch (result.method) {
    'ad' || 'gems' || 'practice' || _ => null,
  };
}

/// Result of a refill action chosen in the sheet.
enum HeartRefillAction {
  /// Start a heart-refill Practice run (+1 heart on completion only).
  practice,

  /// Claim +1 after a rewarded ad.
  ad,

  /// Spend gems for a full refill.
  gems,
}

/// Shows the heart refill bottom sheet. Returns the chosen action, or null.
Future<HeartRefillAction?> showHeartRefillSheet({
  required BuildContext context,
  required int livesRemaining,
  required int livesMax,
  required int gems,
  int? livesNextRefillAtMs,
  int adClaimsRemainingToday = 5,
  int? nextAdClaimAtMs,
  bool busy = false,
}) {
  return showModalBottomSheet<HeartRefillAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.feltDark,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return HeartRefillSheet(
        livesRemaining: livesRemaining,
        livesMax: livesMax,
        gems: gems,
        livesNextRefillAtMs: livesNextRefillAtMs,
        adClaimsRemainingToday: adClaimsRemainingToday,
        nextAdClaimAtMs: nextAdClaimAtMs,
        busy: busy,
      );
    },
  );
}

/// Bottom sheet listing Duo-style ways to restore hearts.
class HeartRefillSheet extends StatefulWidget {
  /// Creates the sheet.
  const HeartRefillSheet({
    super.key,
    required this.livesRemaining,
    required this.livesMax,
    required this.gems,
    this.livesNextRefillAtMs,
    this.adClaimsRemainingToday = 5,
    this.nextAdClaimAtMs,
    this.busy = false,
  });

  final int livesRemaining;
  final int livesMax;
  final int gems;
  final int? livesNextRefillAtMs;
  final int adClaimsRemainingToday;
  final int? nextAdClaimAtMs;
  final bool busy;

  @override
  State<HeartRefillSheet> createState() => _HeartRefillSheetState();
}

class _HeartRefillSheetState extends State<HeartRefillSheet> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  bool get _full => widget.livesRemaining >= widget.livesMax;

  String _countdownLabel(int? atMs) {
    if (atMs == null) return '';
    final remaining = Duration(milliseconds: atMs - DateTime.now().millisecondsSinceEpoch);
    if (remaining <= Duration.zero) return 'Ready';
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final nextLabel = _countdownLabel(widget.livesNextRefillAtMs);
    final adReady = widget.adClaimsRemainingToday > 0 &&
        (widget.nextAdClaimAtMs == null ||
            widget.nextAdClaimAtMs! <= DateTime.now().millisecondsSinceEpoch);
    final canAffordGems = widget.gems >= kGemsFullHeartRefill;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.livesMax; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(
                      i < widget.livesRemaining
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: AppColors.hearts,
                      size: 28,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _full ? 'Hearts are full' : 'Restore hearts',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (!_full && nextLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Next heart in $nextLabel',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 20),
            _RefillOption(
              icon: Icons.fitness_center_rounded,
              title: 'Practice',
              subtitle: 'Earn +1 heart when you finish Practice',
              enabled: !_full && !widget.busy,
              onTap: () => Navigator.of(context).pop(HeartRefillAction.practice),
            ),
            const SizedBox(height: 10),
            _RefillOption(
              icon: Icons.ondemand_video_rounded,
              title: 'Watch an ad',
              subtitle: adReady
                  ? 'Earn +1 heart · ${widget.adClaimsRemainingToday} left today'
                  : 'Available in ${_countdownLabel(widget.nextAdClaimAtMs)}',
              enabled: !_full && !widget.busy && adReady,
              onTap: () => Navigator.of(context).pop(HeartRefillAction.ad),
            ),
            const SizedBox(height: 10),
            _RefillOption(
              icon: Icons.diamond_rounded,
              title: 'Refill with gems',
              subtitle: canAffordGems
                  ? 'Full hearts for $kGemsFullHeartRefill gems'
                  : 'Need $kGemsFullHeartRefill gems (you have ${widget.gems})',
              enabled: !_full && !widget.busy && canAffordGems,
              onTap: () => Navigator.of(context).pop(HeartRefillAction.gems),
            ),
          ],
        ),
      ),
    );
  }
}

class _RefillOption extends StatelessWidget {
  const _RefillOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.feltLight : const Color(0xFF0B3D2E),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: enabled ? Colors.white : Colors.white38, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        color: enabled ? Colors.white : Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        color: enabled ? Colors.white70 : Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: enabled ? Colors.white54 : Colors.white24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Plays a short rewarded placeholder, then claims an ad heart on the server.
///
/// Production AdMob units can replace [playReward] later without changing the
/// claim callable.
Future<RefillCourseHeartsResult> watchAdAndClaimHeart({
  required BuildContext context,
  required CourseService service,
  Future<bool> Function()? playReward,
}) async {
  final bool completed;
  if (playReward != null) {
    completed = await playReward();
  } else {
    if (!context.mounted) {
      throw const CourseServiceException(
        'Ad was not completed.',
        code: 'cancelled',
      );
    }
    completed = await _showPlaceholderAd(context);
  }
  if (!completed) {
    throw const CourseServiceException(
      'Ad was not completed.',
      code: 'cancelled',
    );
  }
  return service.refillHearts(
    method: 'ad',
    idempotencyKey: CourseService.newRequestKey('heart_ad'),
  );
}

Future<bool> _showPlaceholderAd(BuildContext context) async {
  var finished = false;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      Future<void>.delayed(const Duration(seconds: 3), () {
        if (dialogContext.mounted) {
          finished = true;
          Navigator.of(dialogContext).pop();
        }
      });
      return AlertDialog(
        backgroundColor: AppColors.feltDark,
        title: Text(
          'Sponsored break',
          style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Thanks for watching. Your heart is on the way…',
          style: GoogleFonts.nunito(color: Colors.white70),
        ),
      );
    },
  );
  return finished;
}
