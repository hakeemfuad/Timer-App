import 'package:flutter/material.dart';
import '../models/app_settings.dart';

// ── Palette (shared with app) ──────────────────────────────────────
const _espresso = Color(0xFF3B2E2A);
const _cream = Color(0xFFFFF8F0);
const _amber = Color(0xFFE8A838);
const _warmGray = Color(0xFFA09088);

class SettingsModal extends StatefulWidget {
  final AppSettings settings;
  final void Function(AppSettings) onChanged;

  const SettingsModal({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required AppSettings settings,
    required void Function(AppSettings) onChanged,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => Center(
        child: SettingsModal(settings: settings, onChanged: onChanged),
      ),
    );
  }

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late AppSettings _current;

  @override
  void initState() {
    super.initState();
    _current = widget.settings;
  }

  void _update(AppSettings updated) {
    setState(() => _current = updated);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: (screen.width * 0.88).clamp(300.0, 520.0),
        decoration: BoxDecoration(
          color: _cream,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('APPEARANCE'),
                  const SizedBox(height: 20),
                  _buildBackgroundSelector(),
                  const SizedBox(height: 28),
                  _buildCloudSpeedSlider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildHandle() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Container(
          width: 40,
          height: 4.5,
          decoration: BoxDecoration(
            color: _espresso.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 16, 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _espresso.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings_outlined,
                color: _espresso, size: 20),
          ),
          const SizedBox(width: 12),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _espresso,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _espresso.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close,
                  color: _espresso.withValues(alpha: 0.6), size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _amber.withValues(alpha: 0.0),
                  _amber.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _amber,
              letterSpacing: 2.0,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _amber.withValues(alpha: 0.4),
                  _amber.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Background',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _espresso,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose your visual style',
          style: TextStyle(
            fontSize: 12,
            color: _warmGray.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: BackgroundTheme.values.map((theme) {
            final isSelected = _current.backgroundTheme == theme;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () =>
                    _update(_current.copyWith(backgroundTheme: theme)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? _amber
                              : _espresso.withValues(alpha: 0.10),
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _amber.withValues(alpha: 0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.5),
                        child: SizedBox(
                          width: 114,
                          height: 72,
                          child: _BackgroundPreview(theme: theme),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 5),
                            decoration: const BoxDecoration(
                              color: _amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Text(
                          theme.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected ? _espresso : _warmGray,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCloudSpeedSlider() {
    final speed = _current.cloudSpeedMultiplier;

    String speedLabel;
    if (speed < 0.6) {
      speedLabel = 'Very Slow';
    } else if (speed < 0.9) {
      speedLabel = 'Slow';
    } else if (speed < 1.15) {
      speedLabel = 'Default';
    } else if (speed < 2.0) {
      speedLabel = 'Fast';
    } else {
      speedLabel = 'Very Fast';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Cloud Speed',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _espresso,
                letterSpacing: 0.2,
              ),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(speedLabel),
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  speedLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _amber,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _amber,
            inactiveTrackColor: _espresso.withValues(alpha: 0.10),
            thumbColor: _amber,
            overlayColor: _amber.withValues(alpha: 0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
            trackHeight: 5,
          ),
          child: Slider(
            value: speed,
            min: 0.3,
            max: 3.0,
            onChanged: (v) =>
                _update(_current.copyWith(cloudSpeedMultiplier: v)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Slow',
                style: TextStyle(
                  fontSize: 11,
                  color: _warmGray.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Fast',
                style: TextStyle(
                  fontSize: 11,
                  color: _warmGray.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Background preview thumbnails ──────────────────────────────────
class _BackgroundPreview extends StatelessWidget {
  final BackgroundTheme theme;
  const _BackgroundPreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    switch (theme) {
      case BackgroundTheme.warmCream:
        return _buildWarmCream();
      case BackgroundTheme.skyBlue:
        return _buildSkyBlue();
    }
  }

  Widget _buildWarmCream() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF8F0), Color(0xFFFFE0C7)],
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: _miniCloud(Colors.white.withValues(alpha: 0.75), 32, 18),
        ),
        Positioned(
          top: 24,
          right: 8,
          child: _miniCloud(Colors.white.withValues(alpha: 0.55), 22, 13),
        ),
        Positioned(
          bottom: -6,
          left: -8,
          right: -8,
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFE8D8C8).withValues(alpha: 0.50),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkyBlue() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4FB3E8), Color(0xFFABDFF7)],
            ),
          ),
        ),
        // Sun
        Positioned(
          top: 8,
          right: 10,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD04A),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD04A).withValues(alpha: 0.45),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 8,
          child: _miniCloud(Colors.white.withValues(alpha: 0.92), 34, 19),
        ),
        Positioned(
          top: 30,
          right: 30,
          child: _miniCloud(Colors.white.withValues(alpha: 0.75), 24, 14),
        ),
        Positioned(
          bottom: -6,
          left: -8,
          right: -8,
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF6B9F7E).withValues(alpha: 0.65),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniCloud(Color color, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
