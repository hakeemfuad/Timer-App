import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/app_settings.dart';
import '../models/quick_time.dart';
import '../widgets/activity_picker.dart';
import '../widgets/drum_picker.dart';
import '../widgets/settings_modal.dart';

// ── Palette: "Scandinavian Warmth" ────────────────────────────────
const _espresso  = Color(0xFF3B2E2A);
const _cream     = Color(0xFFFFF5EB);
const _amber     = Color(0xFFE8A838);
const _sage      = Color(0xFF6B9F7E);
const _coral     = Color(0xFFD4735E);
const _dustyBlue = Color(0xFF7BA3BE);
const _warmGray  = Color(0xFFA09088);

const _qtAccents = [_coral, _amber, _sage, _dustyBlue];

// Cloud configs: speed (seconds at 1x), vertical position, scale, start offset
const _cloudConfigs = [
  (speed: 38, top: 55.0,  scale: 1.35, offset: 0.0),
  (speed: 52, top: 140.0, scale: 0.88, offset: 0.4),
  (speed: 30, top: 30.0,  scale: 1.01, offset: 0.7),
  (speed: 46, top: 200.0, scale: 0.68, offset: 0.2),
];

class NotStartedView extends StatefulWidget {
  final int selectedMinutes;
  final int selectedSeconds;
  final List<QuickTime> quickTimes;
  final FixedExtentScrollController minController;
  final FixedExtentScrollController secController;
  final ValueChanged<int> onMinutesChanged;
  final ValueChanged<int> onSecondsChanged;
  final VoidCallback onStartPressed;
  final void Function(int minutes, int seconds) onQuickTimerSelected;
  final void Function(int index) onQuickTimerLongPress;

  // First/Then
  final bool firstThenMode;
  final Activity? firstActivity;
  final Activity? thenActivity;
  final VoidCallback onFirstThenToggle;
  final void Function(Activity) onFirstActivitySelected;
  final void Function(Activity) onThenActivitySelected;

  // Settings
  final AppSettings settings;
  final void Function(AppSettings) onSettingsChanged;

  const NotStartedView({
    super.key,
    required this.selectedMinutes,
    required this.selectedSeconds,
    required this.quickTimes,
    required this.minController,
    required this.secController,
    required this.onMinutesChanged,
    required this.onSecondsChanged,
    required this.onStartPressed,
    required this.onQuickTimerSelected,
    required this.onQuickTimerLongPress,
    required this.firstThenMode,
    required this.firstActivity,
    required this.thenActivity,
    required this.onFirstThenToggle,
    required this.onFirstActivitySelected,
    required this.onThenActivitySelected,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<NotStartedView> createState() => _NotStartedViewState();
}

class _NotStartedViewState extends State<NotStartedView>
    with TickerProviderStateMixin {
  final List<AnimationController> _cloudCtrls = [];

  @override
  void initState() {
    super.initState();
    _initCloudControllers();
  }

  void _initCloudControllers({List<double>? startOffsets}) {
    final multiplier = widget.settings.cloudSpeedMultiplier;
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

  void _rebuildCloudControllers() {
    final offsets = _cloudCtrls.map((c) => c.value).toList();
    for (final c in _cloudCtrls) {
      c.dispose();
    }
    _cloudCtrls.clear();
    _initCloudControllers(startOffsets: offsets);
  }

  @override
  void didUpdateWidget(NotStartedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSpeed = oldWidget.settings.cloudSpeedMultiplier;
    final newSpeed = widget.settings.cloudSpeedMultiplier;
    if ((oldSpeed - newSpeed).abs() > 0.02) {
      _rebuildCloudControllers();
    }
  }

  @override
  void dispose() {
    for (final c in _cloudCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isSkyBlue =>
      widget.settings.backgroundTheme == BackgroundTheme.skyBlue;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background gradient ──────────────────────────────────
          _buildBackground(),

          // ── Sky Blue: sun ────────────────────────────────────────
          if (_isSkyBlue)
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
                  child: _Cloud(scale: cfg.scale, isSkyBlue: _isSkyBlue),
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
                color: _isSkyBlue
                    ? const Color(0xFF6B9F7E).withValues(alpha: 0.55)
                    : const Color(0xFFE8D8C8).withValues(alpha: 0.40),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(300),
                ),
              ),
            ),
          ),

          // ── Little Blue Truck (right side of hill) ───────────────
          const Positioned(
            bottom: 128,
            right: 55,
            child: IgnorePointer(child: _LittleBlueTruck()),
          ),

          // ── Content ──────────────────────────────────────────────
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildTimerSurface(),
                        const SizedBox(height: 22),
                        _buildQuickTimers(),
                        const SizedBox(height: 16),
                        _buildFirstThenToggle(),
                        const SizedBox(height: 20),
                        _buildGoButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Settings button (on top so it receives touches) ──────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _buildSettingsRow(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Background gradient ──────────────────────────────────────────
  Widget _buildBackground() {
    if (_isSkyBlue) {
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

  // ── Settings row ─────────────────────────────────────────────────
  Widget _buildSettingsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => SettingsModal.show(
              context,
              settings: widget.settings,
              onChanged: widget.onSettingsChanged,
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _isSkyBlue
                    ? Colors.white.withValues(alpha: 0.25)
                    : _espresso.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_outlined,
                color: _isSkyBlue
                    ? Colors.white.withValues(alpha: 0.85)
                    : _espresso.withValues(alpha: 0.35),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Timer surface (unified dark card with optional FT strip) ─────
  Widget _buildTimerSurface() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 240),
      child: Container(
        decoration: BoxDecoration(
          color: _espresso,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _espresso.withValues(alpha: 0.30),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── FT strip (inside the card) ───────────────────────
            if (widget.firstThenMode) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: _buildFTStrip(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: _cream.withValues(alpha: 0.07),
                  height: 1,
                ),
              ),
            ],

            // ── Drum pickers ─────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DrumPicker(
                    label: 'MIN',
                    controller: widget.minController,
                    count: 600,
                    display: (i) => (i % 60).toString(),
                    onChanged: widget.onMinutesChanged,
                    textColor: _cream,
                    labelColor: _cream.withValues(alpha: 0.35),
                    accentColor: _amber,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: _cream.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  DrumPicker(
                    label: 'SEC',
                    controller: widget.secController,
                    count: 600,
                    display: (i) => (i % 60).toString().padLeft(2, '0'),
                    onChanged: widget.onSecondsChanged,
                    textColor: _cream,
                    labelColor: _cream.withValues(alpha: 0.35),
                    accentColor: _amber,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── First → Then strip ───────────────────────────────────────────
  Widget _buildFTStrip() {
    return Row(
      children: [
        Expanded(child: _buildFTCell(isFirst: true)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.arrow_forward_rounded,
              color: _cream.withValues(alpha: 0.18), size: 16),
        ),
        Expanded(child: _buildFTCell(isFirst: false)),
      ],
    );
  }

  Widget _buildFTCell({required bool isFirst}) {
    final color = isFirst ? _coral : _dustyBlue;
    final label = isFirst ? 'FIRST' : 'THEN';
    final activity = isFirst ? widget.firstActivity : widget.thenActivity;

    return GestureDetector(
      onTap: () => ActivityPicker.show(
        context,
        title: 'Choose $label activity',
        accentColor: color,
        onSelected: isFirst
            ? widget.onFirstActivitySelected
            : widget.onThenActivitySelected,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: _cream.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: color.withValues(alpha: 0.30), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (activity != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  activity.imagePath,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                activity.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _cream.withValues(alpha: 0.8),
                ),
              ),
            ] else ...[
              Icon(Icons.add_rounded,
                  color: color.withValues(alpha: 0.5), size: 30),
              const SizedBox(height: 4),
              Text(
                'Tap to set',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _cream.withValues(alpha: 0.30),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Quick timers ─────────────────────────────────────────────────
  Widget _buildQuickTimers() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.quickTimes.length, (i) {
            final qt = widget.quickTimes[i];
            final isSelected = widget.selectedMinutes == qt.minutes &&
                widget.selectedSeconds == qt.seconds;
            final accent = _qtAccents[i % _qtAccents.length];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () =>
                    widget.onQuickTimerSelected(qt.minutes, qt.seconds),
                onLongPress: () => widget.onQuickTimerLongPress(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 64,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isSelected ? accent : _espresso,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? accent.withValues(alpha: 0.35)
                            : _espresso.withValues(alpha: 0.18),
                        blurRadius: isSelected ? 14 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        qt.label,
                        style: const TextStyle(
                          color: _cream,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 20 : 14,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _cream.withValues(alpha: 0.5)
                              : accent.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'hold to edit',
          style: TextStyle(
            color: _warmGray.withValues(alpha: 0.50),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // ── First → Then toggle ──────────────────────────────────────────
  Widget _buildFirstThenToggle() {
    final active = widget.firstThenMode;
    return GestureDetector(
      onTap: widget.onFirstThenToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? _espresso
              : (_isSkyBlue
                  ? Colors.white.withValues(alpha: 0.22)
                  : _espresso.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? _coral : _coral.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'First -> Then',
              style: TextStyle(
                color: active
                    ? _cream
                    : (_isSkyBlue
                        ? Colors.white.withValues(alpha: 0.85)
                        : _espresso.withValues(alpha: 0.40)),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? _dustyBlue
                    : _dustyBlue.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GO button ────────────────────────────────────────────────────
  Widget _buildGoButton() {
    return GestureDetector(
      onTap: widget.onStartPressed,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: _sage,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _sage.withValues(alpha: 0.40),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'GO',
            style: TextStyle(
              color: _cream,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sun widget (sky blue theme only) ────────────────────────────────
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

// ── Cloud widget (35% larger than original) ──────────────────────────
class _Cloud extends StatelessWidget {
  final double scale;
  final bool isSkyBlue;
  const _Cloud({this.scale = 1.0, this.isSkyBlue = false});

  @override
  Widget build(BuildContext context) {
    // Warm: semi-transparent white, Sky: more opaque for contrast
    final c = Colors.white.withValues(alpha: isSkyBlue ? 0.88 : 0.65);
    final g = (isSkyBlue ? const Color(0xFFB5D5EF) : const Color(0xFFE0D8D0))
        .withValues(alpha: isSkyBlue ? 0.35 : 0.25);
    final s = scale;

    return SizedBox(
      width: 160 * s,
      height: 73 * s,
      child: Stack(
        children: [
          // Bottom body
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
          // Main puff
          Positioned(
            left: 19 * s,
            top: 0,
            child: Container(
              width: 65 * s,
              height: 65 * s,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
          ),
          // Right lobe
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
          // Subtle underbelly
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

// ── Little Blue Truck ────────────────────────────────────────────────
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

    // ── Ground shadow ─────────────────────────────────────────────
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

    // ── WHEELS (drawn first so body covers their tops) ────────────
    void drawWheel(double cx) {
      const cy = 0.83;
      const r  = 0.155;
      canvas.drawCircle(Offset(cx, h * cy), h * r,        p(_wheelDark));
      canvas.drawCircle(Offset(cx, h * cy), h * r * 0.76, p(const Color(0xFF1A120E)));
      canvas.drawCircle(Offset(cx, h * cy), h * r * 0.52, p(_hubcap));
      canvas.drawCircle(Offset(cx, h * cy), h * r * 0.22, p(_wheelDark));
    }
    drawWheel(w * 0.215); // front wheel (under cab, left)
    drawWheel(w * 0.775); // rear wheel  (under bed, right)

    // ── BED right side, cargo area ────────────────────────────────
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.44, h * 0.30,
        w,        h * 0.72,
        topRight:    Radius.circular(h * 0.08),
        bottomRight: Radius.circular(h * 0.07),
      ),
      p(_bodyBlue),
    );
    // Bed top rail — raised, lighter
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.46, h * 0.23,
        w * 0.99, h * 0.33,
        topRight: Radius.circular(h * 0.06),
      ),
      p(_lightBlue),
    );
    // Bed interior recess — darker
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.47, h * 0.37, w * 0.46, h * 0.21),
        Radius.circular(h * 0.04),
      ),
      p(_deepBlue),
    );

    // ── CAB left side, front of truck ────────────────────────────
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0,        h * 0.10,
        w * 0.50, h * 0.72,
        topLeft:    Radius.circular(h * 0.26),
        topRight:   Radius.circular(h * 0.08),
        bottomLeft: Radius.circular(h * 0.07),
      ),
      p(_bodyBlue),
    );
    // Cab lower panel — darker for depth
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.01, h * 0.50,
        w * 0.50, h * 0.72,
        bottomLeft: Radius.circular(h * 0.07),
      ),
      p(_deepBlue),
    );
    // Cab top highlight — lighter strip to sell the roundness
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.04, h * 0.10,
        w * 0.46, h * 0.24,
        topLeft:  Radius.circular(h * 0.23),
        topRight: Radius.circular(h * 0.06),
      ),
      p(_lightBlue),
    );

    // ── WINDSHIELD ────────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.15, w * 0.32, h * 0.30),
        Radius.circular(h * 0.08),
      ),
      p(_window),
    );
    // Glass glare streak
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.17, w * 0.09, h * 0.10),
        Radius.circular(h * 0.04),
      ),
      p(const Color(0xBFFFFFFF)),
    );

    // ── HEADLIGHT front-left ──────────────────────────────────────
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.003, h * 0.47,
        w * 0.075, h * 0.60,
        bottomLeft: Radius.circular(h * 0.05),
      ),
      p(_headlight),
    );
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.008, h * 0.49,
        w * 0.055, h * 0.58,
        bottomLeft: Radius.circular(h * 0.04),
      ),
      p(const Color(0xCCFFFFFF)),
    );

    // ── TAILLIGHT rear-right ──────────────────────────────────────
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        w * 0.928, h * 0.46,
        w,          h * 0.58,
        topRight:    Radius.circular(h * 0.05),
        bottomRight: Radius.circular(h * 0.05),
      ),
      p(_taillight),
    );

    // ── FRONT BUMPER ──────────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        0,        h * 0.62,
        w * .09, h * 0.72,
        bottomLeft: Radius.circular(h * 0.05),
      ),
      p(_deepBlue),
    );

    // ── UNDERCARRIAGE BAR ─────────────────────────────────────────
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
