import 'dart:math';
import 'package:flutter/material.dart';

/// Paints the high-contrast 'Live State' progress ring and clock badge.
class ClockBadgePainter extends CustomPainter {
  final double progress; // 1.0 = full remaining, 0.0 = empty

  const ClockBadgePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final strokeWidth = radius * 0.15;
    final drawRadius = radius - strokeWidth / 2;

    // 1. Background Track (Darker, sleek)
    final trackPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, drawRadius, trackPaint);

    // 2. Progress Ring (High contrast white/primary)
    // We use a slight gradient or pure white for that 'Live' look
    final progressPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw the arc representing remaining time
    // progress = 1.0 means full 360 degrees
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: drawRadius),
      -pi / 2, // Start at 12 o'clock
      2 * pi * progress,
      false,
      progressPaint,
    );

    // 3. Optional: Subtle glow/shadow for the progress ring
    // (Skipping for now to keep it clean, but could add mask filter)

    // 4. Center indicator / Dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, strokeWidth * 0.8, dotPaint);
  }

  @override
  bool shouldRepaint(ClockBadgePainter old) => old.progress != progress;
}
