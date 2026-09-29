/// Rex mascot slot: one full-body coach, posed from separate pieces.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mood of the Rex drawing. The prompt stays calm.
enum RexMood {
  /// Teaching prompt. Arms down, one blink.
  calm,

  /// Right-answer beat. One arm rises and the mouth opens.
  celebrate,

  /// Both arms come in front of the chest.
  think,
}

/// Full-body Rex. Calm stands still, celebrate raises an arm, think folds both.
class RexMascot extends StatefulWidget {
  /// Creates Rex. Defaults to the calm standing drawing.
  const RexMascot({super.key, this.size = 36, this.mood = RexMood.calm});

  /// Full idle drawing, kept for the asset contract.
  static const asset = 'assets/brand/mascot_idle.png';

  /// Full celebrate drawing, kept for the asset contract.
  static const celebrateAsset = 'assets/brand/mascot_celebrate.png';

  /// Torso, head, and legs. The arms are separate so they can move.
  static const bodyAsset = 'assets/brand/mascot_body.png';

  /// Viewer's left arm, including the hand.
  static const armLeftAsset = 'assets/brand/mascot_arm_left.png';

  /// Viewer's right arm, including the hand.
  static const armRightAsset = 'assets/brand/mascot_arm_right.png';

  /// Open smile placed on the calm face.
  static const mouthAsset = 'assets/brand/mascot_mouth_happy.png';

  /// Width of the figure. Height follows the full-body drawing.
  final double size;

  /// Which pose to play.
  final RexMood mood;

  @override
  State<RexMascot> createState() => _RexMascotState();
}

class _RexMascotState extends State<RexMascot> with TickerProviderStateMixin {
  late final AnimationController _pose;
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _pose = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    )..forward();
  }

  @override
  void didUpdateWidget(RexMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      _pose.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pose.dispose();
    _blink.dispose();
    super.dispose();
  }

  String get _label {
    return switch (widget.mood) {
      RexMood.calm => 'Rex, calm',
      RexMood.celebrate => 'Rex, celebrating',
      RexMood.think => 'Rex, thinking',
    };
  }

  /// Radians at the end of the pose. Zero is arms at the sides.
  double _leftTarget() {
    return switch (widget.mood) {
      RexMood.calm => 0,
      RexMood.celebrate => 120 * math.pi / 180,
      RexMood.think => -100 * math.pi / 180,
    };
  }

  double _rightTarget() {
    return switch (widget.mood) {
      RexMood.calm => 0,
      RexMood.celebrate => 0,
      RexMood.think => 100 * math.pi / 180,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      image: true,
      label: _label,
      child: _CelebrateEntrance(
        enabled: widget.mood == RexMood.celebrate,
        child: SizedBox(
          width: widget.size,
          height: widget.size * 1.5,
          child: AnimatedBuilder(
            animation: Listenable.merge([_pose, _blink]),
            builder: (context, _) {
              final t = _pose.value;
              final blink = _blink.value < 0.5
                  ? _blink.value * 2
                  : (1 - _blink.value) * 2;
              return _Rig(
                leftAngle: _leftTarget() * t,
                rightAngle: _rightTarget() * t,
                mouthOpacity: widget.mood == RexMood.celebrate ? t : 0,
                blink: blink,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Rig extends StatelessWidget {
  const _Rig({
    required this.leftAngle,
    required this.rightAngle,
    required this.mouthOpacity,
    required this.blink,
  });

  final double leftAngle;
  final double rightAngle;
  final double mouthOpacity;
  final double blink;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: _LayerImage(RexMascot.bodyAsset)),
        Positioned.fill(
          child: Transform.rotate(
            angle: rightAngle,
            alignment: const Alignment(0.27, -0.17),
            child: const _LayerImage(RexMascot.armRightAsset),
          ),
        ),
        Positioned.fill(
          child: Transform.rotate(
            angle: leftAngle,
            alignment: const Alignment(-0.27, -0.17),
            child: const _LayerImage(RexMascot.armLeftAsset),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: mouthOpacity.clamp(0, 1),
            child: const _LayerImage(RexMascot.mouthAsset),
          ),
        ),
        Positioned.fill(child: _BlinkLids(close: blink)),
      ],
    );
  }
}

class _LayerImage extends StatelessWidget {
  const _LayerImage(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(asset, fit: BoxFit.fill, excludeFromSemantics: true);
  }
}

class _BlinkLids extends StatelessWidget {
  const _BlinkLids({required this.close});

  final double close;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return Stack(
            children: [
              _lid(width, height, 0.362, 0.194, 0.11, 0.072),
              _lid(width, height, 0.534, 0.192, 0.112, 0.072),
            ],
          );
        },
      ),
    );
  }

  Widget _lid(
    double boxWidth,
    double boxHeight,
    double left,
    double top,
    double width,
    double height,
  ) {
    return Positioned(
      left: left * boxWidth,
      top: top * boxHeight,
      width: width * boxWidth,
      height: height * boxHeight,
      child: Transform.scale(
        scaleY: close,
        alignment: Alignment.topCenter,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFFC67A46),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }
}

/// Short rise-in for a right answer. It finishes, so tests can settle.
class _CelebrateEntrance extends StatelessWidget {
  const _CelebrateEntrance({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  static const duration = Duration(milliseconds: 420);

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.86, end: 1),
      duration: duration,
      curve: Curves.easeOutBack,
      child: child,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
    );
  }
}
