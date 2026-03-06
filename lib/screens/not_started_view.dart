import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/app_settings.dart';
import '../models/quick_time.dart';
import '../widgets/activity_picker.dart';
import '../widgets/drum_picker.dart';
import '../widgets/scene_background.dart';
import '../widgets/settings_modal.dart';

const _qtAccents = [kCoral, kAmber, kSage, kDustyBlue];

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
  final Activity? firstActivity;
  final Activity? thenActivity;
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
    required this.firstActivity,
    required this.thenActivity,
    required this.onFirstActivitySelected,
    required this.onThenActivitySelected,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<NotStartedView> createState() => _NotStartedViewState();
}

class _NotStartedViewState extends State<NotStartedView> {
  bool get _isSkyBlue =>
      widget.settings.backgroundTheme == BackgroundTheme.skyBlue;

  bool get _hasAnyActivity =>
      widget.firstActivity != null || widget.thenActivity != null;

  // ── FirstThen picker flow ─────────────────────────────────────────
  void _openFirstThenFlow() async {
    bool firstSelected = false;

    await ActivityPicker.show(
      context,
      title: 'Choose FIRST activity',
      accentColor: kCoral,
      onSelected: (activity) {
        widget.onFirstActivitySelected(activity);
        firstSelected = true;
      },
    );

    if (firstSelected && mounted) {
      await ActivityPicker.show(
        context,
        title: 'Now choose THEN activity',
        accentColor: kDustyBlue,
        onSelected: widget.onThenActivitySelected,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background (shared widget) ─────────────────────────
          SceneBackground(
            isSkyBlue: _isSkyBlue,
            cloudSpeedMultiplier: widget.settings.cloudSpeedMultiplier,
          ),

          // ── Content ────────────────────────────────────────────
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
                        _buildTimerRow(),
                        const SizedBox(height: 22),
                        _buildQuickTimers(),
                        const SizedBox(height: 16),
                        _buildFirstThenButton(),
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

          // ── Settings button (on top so it receives touches) ────
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

  // ── Settings row ───────────────────────────────────────────────────
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
                    : kEspresso.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.settings_outlined,
                color: _isSkyBlue
                    ? Colors.white.withValues(alpha: 0.85)
                    : kEspresso.withValues(alpha: 0.35),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Timer row: [FIRST card] [Timer] [THEN card] ────────────────────
  Widget _buildTimerRow() {
    return Center(
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FIRST card slot (left)
            _buildSideCardSlot(isFirst: true),
            const SizedBox(width: 16),
            // Timer card (center)
            _buildTimerCard(),
            const SizedBox(width: 16),
            // THEN card slot (right)
            _buildSideCardSlot(isFirst: false),
          ],
        ),
      ),
    );
  }

  // ── Side card slot (always occupies space, animated show/hide) ─────
  Widget _buildSideCardSlot({required bool isFirst}) {
    final activity = isFirst ? widget.firstActivity : widget.thenActivity;
    final visible = activity != null;

    return SizedBox(
      width: 160,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutBack,
        scale: visible ? 1.0 : 0.80,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          opacity: visible ? 1.0 : 0.0,
          child: visible
              ? _buildSideCardContent(activity, isFirst: isFirst)
              : null,
        ),
      ),
    );
  }

  // ── Side card content (PECS-style photo card) ──────────────────────
  Widget _buildSideCardContent(Activity activity, {required bool isFirst}) {
    final color = isFirst ? kCoral : kDustyBlue;
    final label = isFirst ? 'FIRST' : 'THEN';

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Badge
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            // Photo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    activity.imagePath,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            // Label
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Text(
                activity.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kEspresso.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Timer card (center, fixed width) ───────────────────────────────
  Widget _buildTimerCard() {
    return SizedBox(
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          color: kEspresso,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: kEspresso.withValues(alpha: 0.30),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DrumPicker(
                label: 'MIN',
                controller: widget.minController,
                count: 600,
                display: (i) => (i % 60).toString(),
                onChanged: widget.onMinutesChanged,
                textColor: kCream,
                labelColor: kCream.withValues(alpha: 0.35),
                accentColor: kAmber,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: kCream.withValues(alpha: 0.18),
                  ),
                ),
              ),
              DrumPicker(
                label: 'SEC',
                controller: widget.secController,
                count: 600,
                display: (i) => (i % 60).toString().padLeft(2, '0'),
                onChanged: widget.onSecondsChanged,
                textColor: kCream,
                labelColor: kCream.withValues(alpha: 0.35),
                accentColor: kAmber,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Quick timers ───────────────────────────────────────────────────
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
                    color: isSelected ? accent : kEspresso,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? accent.withValues(alpha: 0.35)
                            : kEspresso.withValues(alpha: 0.18),
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
                          color: kCream,
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
                              ? kCream.withValues(alpha: 0.5)
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
            color: kWarmGray.withValues(alpha: 0.50),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  // ── First → Then button ────────────────────────────────────────────
  Widget _buildFirstThenButton() {
    final active = _hasAnyActivity;
    return GestureDetector(
      onTap: _openFirstThenFlow,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active
              ? kEspresso
              : (_isSkyBlue
                  ? Colors.white.withValues(alpha: 0.22)
                  : kEspresso.withValues(alpha: 0.06)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? kCoral : kCoral.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'First -> Then',
              style: TextStyle(
                color: active
                    ? kCream
                    : (_isSkyBlue
                        ? Colors.white.withValues(alpha: 0.85)
                        : kEspresso.withValues(alpha: 0.40)),
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
                    ? kDustyBlue
                    : kDustyBlue.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GO button ──────────────────────────────────────────────────────
  Widget _buildGoButton() {
    return GestureDetector(
      onTap: widget.onStartPressed,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: kSage,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kSage.withValues(alpha: 0.40),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'GO',
            style: TextStyle(
              color: kCream,
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
