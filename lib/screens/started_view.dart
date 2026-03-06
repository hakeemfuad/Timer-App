import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/activity.dart';
import '../widgets/clock_badge_painter.dart';
import '../widgets/action_button.dart';
import '../widgets/first_then_overlay.dart';

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
  });

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView> {
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    final mins = widget.remainingSeconds ~/ 60;
    final secs = widget.remainingSeconds % 60;
    final timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _showSettings = !_showSettings;
            });
          },
          child: Stack(
            children: [
              Column(
                children: [
                  const Spacer(),

                  // Circle video + clock badge
                  Center(
                    child: SizedBox(
                      width: 440,
                      height: 440,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Main circular video frame
                          Container(
                            width: 420,
                            height: 420,
                            margin: const EdgeInsets.only(left: 10, top: 10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF5DAA60),
                              border: Border.all(
                                  color: const Color(0xFF2A2A2A), width: 6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: widget.videoReady && widget.videoController != null
                                ? FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: widget.videoController!.value.size.width,
                                      height: widget.videoController!.value.size.height,
                                      child: VideoPlayer(widget.videoController!),
                                    ),
                                  )
                                : const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white)),
                          ),
                          // High-contrast 'Live' clock badge
                          Positioned(
                            right: 0,
                            bottom: 10,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE05252),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.8), width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                painter: ClockBadgePainter(progress: widget.progress),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bold Typography for Timer
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 110,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                      fontFamily: 'SF Pro Display', // Apple style if available
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),

              // Settings/Controls Overlay
              if (_showSettings)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.8),
                    child: Column(
                      children: [
                        // Header row
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 22, 0),
                          child: Row(
                            children: [
                              if (widget.firstActivity != null || widget.thenActivity != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _showSettings = false);
                                    FirstThenOverlay.show(
                                      context,
                                      firstActivity: widget.firstActivity,
                                      thenActivity: widget.thenActivity,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F8FF),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          color: const Color(0xFF5B9FE8).withOpacity(0.4),
                                          width: 2.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Schedule',
                                          style: TextStyle(
                                            color: Color(0xFF5B9FE8),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded,
                                            size: 18, color: Color(0xFF5B9FE8)),
                                      ],
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Icon(Icons.music_note,
                                  color: Colors.amber[600], size: 36),
                              const SizedBox(width: 20),
                              Icon(Icons.notifications,
                                  color: Colors.amber[600], size: 36),
                            ],
                          ),
                        ),
                        const Spacer(),

                        // Adjustments
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AdjustmentButton(
                              icon: Icons.add,
                              onTap: widget.onAddMinute,
                            ),
                            const SizedBox(width: 40),
                            AdjustmentButton(
                              icon: Icons.remove,
                              onTap: widget.onRemoveMinute,
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Play / Stop buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ActionButton(
                              color: const Color(0xFF4ECBA3),
                              icon: widget.isRunning ? Icons.pause : Icons.play_arrow,
                              onTap: widget.onPlayPauseTap,
                            ),
                            const SizedBox(width: 24),
                            ActionButton(
                              color: const Color(0xFF66CCDD),
                              icon: Icons.stop,
                              onTap: widget.onStopTap,
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),
                        const Text(
                          "Tap anywhere to hide controls",
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdjustmentButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const AdjustmentButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFDDDDDD), width: 2),
        ),
        child: Icon(icon, color: const Color(0xFF333333), size: 32),
      ),
    );
  }
}
