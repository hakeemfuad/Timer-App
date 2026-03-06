import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/activity.dart';
import '../models/app_settings.dart';
import '../widgets/scene_background.dart';

class StartedView extends StatefulWidget {
  final bool isRunning;
  final int remainingSeconds;
  final double progress;
  final bool videoReady;
  final VideoPlayerController? videoController;
  final VoidCallback onPlayPauseTap;
  final VoidCallback onStopTap;
  final VoidCallback onAddMinute;
  final VoidCallback onRemoveMinute;
  final Activity? firstActivity;
  final Activity? thenActivity;
  final AppSettings settings;

  const StartedView({
    super.key,
    required this.isRunning,
    required this.remainingSeconds,
    required this.progress,
    required this.videoReady,
    required this.videoController,
    required this.onPlayPauseTap,
    required this.onStopTap,
    required this.onAddMinute,
    required this.onRemoveMinute,
    this.firstActivity,
    this.thenActivity,
    required this.settings,
  });

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView>
    with SingleTickerProviderStateMixin {
  bool _showFirstThen = false;

  // Smooth ring animation — tweens between 1-second progress steps
  late AnimationController _ringCtrl;
  late Animation<double> _ringAnim;

  bool get _isSkyBlue =>
      widget.settings.backgroundTheme == BackgroundTheme.skyBlue;

  bool get _hasActivities =>
      widget.firstActivity != null || widget.thenActivity != null;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _ringAnim = Tween<double>(
      begin: widget.progress,
      end: widget.progress,
    ).animate(_ringCtrl);
  }

  @override
  void didUpdateWidget(StartedView old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      // Animate from wherever the ring currently is to the new target
      _ringAnim = Tween<double>(
        begin: _ringAnim.value,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.linear));
      _ringCtrl.forward(from: 0);
    }
    // Pause animation when timer is paused
    if (!widget.isRunning && _ringCtrl.isAnimating) {
      _ringCtrl.stop();
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mins = widget.remainingSeconds ~/ 60;
    final secs = widget.remainingSeconds % 60;
    final timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background (same as NotStartedView) ────────────────
          SceneBackground(
            isSkyBlue: _isSkyBlue,
            cloudSpeedMultiplier: widget.settings.cloudSpeedMultiplier,
          ),

          // ── Main content ───────────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_hasActivities) {
                HapticFeedback.lightImpact();
                setState(() => _showFirstThen = true);
              }
            },
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(),

                  // Liquid glass timer inside progress ring
                  _buildTimerCenter(timeStr),

                  const SizedBox(height: 36),

                  // Controls row: [Cancel]   [Pause/Resume]
                  _buildControlsRow(),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),

          // ── FirstThen full-screen overlay ──────────────────────
          if (_showFirstThen) _buildFirstThenOverlay(),
        ],
      ),
    );
  }

  // ── Liquid glass timer inside progress ring ────────────────────────
  Widget _buildTimerCenter(String timeStr) {
    return Center(
      child: SizedBox(
        width: 400,
        height: 400,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Progress ring — driven by smooth animation, not raw seconds
            AnimatedBuilder(
              animation: _ringAnim,
              builder: (_, __) => CustomPaint(
                size: const Size(400, 400),
                painter: _VideoRingPainter(progress: _ringAnim.value),
              ),
            ),

            // Liquid glass circle — sized to exactly fill the ring's inner edge
            // Ring: 400px container, 14px stroke → inner diameter = (200-7)*2 - 14 = 372px
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  width: 372,
                  height: 372,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(-0.3, -0.4),
                      radius: 1.0,
                      colors: [
                        Colors.white.withValues(alpha: 0.16),
                        Colors.white.withValues(alpha: 0.06),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.30),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      timeStr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 96,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Controls row: [Cancel]   [Pause/Resume] ────────────────────────
  Widget _buildControlsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Cancel button
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onStopTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: kCoral,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: kCoral.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(width: 32),

        // Pause / Resume button
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            widget.onPlayPauseTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: widget.isRunning ? kAmber : kSage,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: (widget.isRunning ? kAmber : kSage)
                      .withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              widget.isRunning ? 'PAUSE' : 'RESUME',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── FirstThen full-screen overlay ──────────────────────────────────
  Widget _buildFirstThenOverlay() {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.6;

    return GestureDetector(
      onTap: () => setState(() => _showFirstThen = false),
      child: Container(
        color: Colors.black.withValues(alpha: 0.88),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildFullScreenCard(
                      'FIRST',
                      widget.firstActivity,
                      kCoral,
                      cardHeight,
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _buildFullScreenCard(
                      'THEN',
                      widget.thenActivity,
                      kDustyBlue,
                      cardHeight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenCard(
    String label,
    Activity? activity,
    Color color,
    double height,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title above card
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 16),
        // Card
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 3),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.30),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: activity != null
              ? Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(37),
                        ),
                        child: Image.asset(
                          activity.imagePath,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        activity.label.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: kEspresso,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline_rounded,
                        color: color.withValues(alpha: 0.20),
                        size: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Not set',
                        style: TextStyle(
                          color: color.withValues(alpha: 0.40),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Video ring painter: orange depleting counterclockwise ────────────
class _VideoRingPainter extends CustomPainter {
  final double progress; // 1.0 = full time remaining, 0.0 = empty

  _VideoRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    const strokeWidth = 14.0;
    final drawRadius = radius - strokeWidth / 2;

    // Gray background ring (revealed as orange depletes)
    final grayPaint = Paint()
      ..color = const Color(0xFFCCCCCC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, drawRadius, grayPaint);

    // Orange progress arc (counterclockwise from 12 o'clock)
    if (progress > 0.005) {
      final orangePaint = Paint()
        ..color = kAmber
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: drawRadius),
        -pi / 2, // start at 12 o'clock
        -2 * pi * progress, // counterclockwise
        false,
        orangePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_VideoRingPainter old) => old.progress != progress;
}
