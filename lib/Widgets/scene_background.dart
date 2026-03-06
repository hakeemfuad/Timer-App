import 'package:flutter/material.dart';

// ── Palette: "Scandinavian Warmth" ────────────────────────────────
const kEspresso  = Color(0xFF3B2E2A);
const kCream     = Color(0xFFFFF5EB);
const kAmber     = Color(0xFFE8A838);
const kSage      = Color(0xFF6B9F7E);
const kCoral     = Color(0xFFD4735E);
const kDustyBlue = Color(0xFF7BA3BE);
const kWarmGray  = Color(0xFFA09088);

// Cloud configs: speed (seconds at 1x), vertical position, scale, start offset
const _cloudConfigs = [
  (speed: 38, top: 55.0,  scale: 1.35, offset: 0.0),
  (speed: 52, top: 140.0, scale: 0.88, offset: 0.4),
  (speed: 30, top: 30.0,  scale: 1.01, offset: 0.7),
  (speed: 46, top: 200.0, scale: 0.68, offset: 0.2),
];

/// Self-contained animated background with gradient, sun, drifting clouds,
/// green hill, and the Little Blue Truck.
class SceneBackground extends StatefulWidget {
  final bool isSkyBlue;
  final double cloudSpeedMultiplier;

  const SceneBackground({
    super.key,
    this.isSkyBlue = false,
    this.cloudSpeedMultiplier = 1.0,
  });

  @override
  State<SceneBackground> createState() => _SceneBackgroundState();
}

class _SceneBackgroundState extends State<SceneBackground>
    with TickerProviderStateMixin {
  final List<AnimationController> _cloudCtrls = [];

  @override
  void initState() {
    super.initState();
    _initCloudControllers();
  }

  void _initCloudControllers({List<double>? startOffsets}) {
    final multiplier = widget.cloudSpeedMultiplier;
    for (int i = 0; i < _cloudConfigs.length; i++) {
      final cfg = _cloudConfigs[i];
      final speedSecs =
          (cfg.speed / multiplier).clamp(4.0, 300.0).round();
      final startOffset = startOffsets != null ? startOffsets[i] : cfg.offset;
      final ctrl = AnimationController(
        vsync: this,
        duration: Duration(seconds: speedSecs),
      );
      ctrl.forward(from: startOffset);
      ctrl.addStatusListener((status) {
        if (status == AnimationStatus.completed) ctrl.forward(from: 0);
      });
      _cloudCtrls.add(ctrl);
    }
  }

  @override
  void didUpdateWidget(SceneBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.cloudSpeedMultiplier - widget.cloudSpeedMultiplier).abs() >
        0.02) {
      final offsets = _cloudCtrls.map((c) => c.value).toList();
      for (final c in _cloudCtrls) {
        c.dispose();
      }
      _cloudCtrls.clear();
      _initCloudControllers(startOffsets: offsets);
    }
  }

  @override
  void dispose() {
    for (final c in _cloudCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Gradient background ──────────────────────────────────
        _buildGradient(),

        // ── Sun (sky blue only) ──────────────────────────────────
        if (widget.isSkyBlue)
          Positioned(
            right: screenWidth * 0.18,
            top: 72,
            child: const _Sun(),
          ),

        // ── Drifting clouds ──────────────────────────────────────
        ...List.generate(_cloudConfigs.length, (i) {
          final cfg = _cloudConfigs[i];
          final cloudWidth = 160.0 * cfg.scale;
          return AnimatedBuilder(
            animation: _cloudCtrls[i],
            builder: (_, __) {
              final left = -cloudWidth +
                  (screenWidth + cloudWidth) * _cloudCtrls[i].value;
              return Positioned(
                left: left,
                top: cfg.top,
                child: _Cloud(scale: cfg.scale, isSkyBlue: widget.isSkyBlue),
              );
            },
          );
        }),

        // ── Bottom hill ──────────────────────────────────────────
        Positioned(
          bottom: -80,
          left: -60,
          right: -60,
          child: Container(
            height: 240,
            decoration: BoxDecoration(
              color: widget.isSkyBlue
                  ? const Color(0xFF6B9F7E).withValues(alpha: 0.55)
                  : const Color(0xFFE8D8C8).withValues(alpha: 0.40),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(300),
              ),
            ),
          ),
        ),

        // ── Little Blue Truck ────────────────────────────────────
        const Positioned(
          bottom: 128,
          right: 55,
          child: IgnorePointer(child: _LittleBlueTruck()),
        ),
      ],
    );
  }

  Widget _buildGradient() {
    if (widget.isSkyBlue) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.45, 1.0],
            colors: [
              Color(0xFF4BAEE0),
              Color(0xFF72C8F0),
              Color(0xFFB8E8FF),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.55, 1.0],
          colors: [
            Color(0xFFFFF8F0),
            Color(0xFFFFECD2),
            Color(0xFFFFE0C7),
          ],
        ),
      ),
    );
  }
}

// ── Sun widget ────────────────────────────────────────────────────────
class _Sun extends StatelessWidget {
  const _Sun();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD04A),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD04A).withValues(alpha: 0.50),
            blurRadius: 32,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFFFFB800).withValues(alpha: 0.20),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}

// ── Cloud widget ──────────────────────────────────────────────────────
class _Cloud extends StatelessWidget {
  final double scale;
  final bool isSkyBlue;
  const _Cloud({this.scale = 1.0, this.isSkyBlue = false});

  @override
  Widget build(BuildContext context) {
    final c = Colors.white.withValues(alpha: isSkyBlue ? 0.88 : 0.65);
    final g = (isSkyBlue ? const Color(0xFFB5D5EF) : const Color(0xFFE0D8D0))
        .withValues(alpha: isSkyBlue ? 0.35 : 0.25);
    final s = scale;

    return SizedBox(
      width: 160 * s,
      height: 73 * s,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 24 * s,
            child: Container(
              width: 92 * s,
              height: 54 * s,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(27 * s),
              ),
            ),
          ),
          Positioned(
            left: 19 * s,
            top: 0,
            child: Container(
              width: 65 * s,
              height: 65 * s,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
          ),
          Positioned(
            left: 65 * s,
            top: 14 * s,
            child: Container(
              width: 81 * s,
              height: 57 * s,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(28 * s),
              ),
            ),
          ),
          Positioned(
            left: 10 * s,
            top: 50 * s,
            child: Container(
              width: 120 * s,
              height: 22 * s,
              decoration: BoxDecoration(
                color: g,
                borderRadius: BorderRadius.circular(11 * s),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Little Blue Truck ─────────────────────────────────────────────────
class _LittleBlueTruck extends StatelessWidget {
  const _LittleBlueTruck();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 110,
      height: 72,
      child: CustomPaint(painter: _TruckPainter()),
    );
  }
}

class _TruckPainter extends CustomPainter {
  const _TruckPainter();

  static const _bodyBlue  = Color(0xFF4A8EC2);
  static const _deepBlue  = Color(0xFF3577A8);
  static const _lightBlue = Color(0xFF5CAAD6);
  static const _window    = Color(0xFFCCE8F8);
  static const _headlight = Color(0xFFFFE890);
  static const _taillight = Color(0xFFE05050);
  static const _wheelDark = Color(0xFF2D2420);
  static const _hubcap    = Color(0xFFD8C8B4);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    Paint p(Color c) => Paint()..color = c..isAntiAlias = true;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.96),
        width: w * 0.84,
        height: h * 0.08,
      ),
      Paint()
        ..color = const Color(0x26000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    void drawWheel(double cx) {
      const cy = 0.83;
      const r  = 0.155;
      canvas.drawCircle(Offset(cx, h * cy), h * r,        p(_wheelDark));
      canvas.drawCircle(Offset(cx, h * cy), h * r * 0.76, p(const Color(0xFF1A120E)));
      canvas.drawCircle(Offset(cx, h * cy), h * r * 0.52, p(_hubcap));
      canvas.drawCircle(Offset(cx, h * cy), h * r * 0.22, p(_wheelDark));
    }
    drawWheel(w * 0.215);
    drawWheel(w * 0.775);

    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.44, h * 0.30, w, h * 0.72,
        topRight: Radius.circular(h * 0.08),
        bottomRight: Radius.circular(h * 0.07),
      ),
      p(_bodyBlue),
    );
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.46, h * 0.23, w * 0.99, h * 0.33,
        topRight: Radius.circular(h * 0.06),
      ),
      p(_lightBlue),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.47, h * 0.37, w * 0.46, h * 0.21),
        Radius.circular(h * 0.04),
      ),
      p(_deepBlue),
    );
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0, h * 0.10, w * 0.50, h * 0.72,
        topLeft: Radius.circular(h * 0.26),
        topRight: Radius.circular(h * 0.08),
        bottomLeft: Radius.circular(h * 0.07),
      ),
      p(_bodyBlue),
    );
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.01, h * 0.50, w * 0.50, h * 0.72,
        bottomLeft: Radius.circular(h * 0.07),
      ),
      p(_deepBlue),
    );
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.04, h * 0.10, w * 0.46, h * 0.24,
        topLeft: Radius.circular(h * 0.23),
        topRight: Radius.circular(h * 0.06),
      ),
      p(_lightBlue),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.15, w * 0.32, h * 0.30),
        Radius.circular(h * 0.08),
      ),
      p(_window),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.17, w * 0.09, h * 0.10),
        Radius.circular(h * 0.04),
      ),
      p(const Color(0xBFFFFFFF)),
    );
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.003, h * 0.47, w * 0.075, h * 0.60,
        bottomLeft: Radius.circular(h * 0.05),
      ),
      p(_headlight),
    );
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.008, h * 0.49, w * 0.055, h * 0.58,
        bottomLeft: Radius.circular(h * 0.04),
      ),
      p(const Color(0xCCFFFFFF)),
    );
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.928, h * 0.46, w, h * 0.58,
        topRight: Radius.circular(h * 0.05),
        bottomRight: Radius.circular(h * 0.05),
      ),
      p(_taillight),
    );
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0, h * 0.62, w * .09, h * 0.72,
        bottomLeft: Radius.circular(h * 0.05),
      ),
      p(_deepBlue),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.66, w * 0.90, h * 0.055),
        Radius.circular(h * 0.03),
      ),
      p(_deepBlue),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
