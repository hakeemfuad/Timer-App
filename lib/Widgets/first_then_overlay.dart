import 'package:flutter/material.dart';
import '../models/activity.dart';

class FirstThenOverlay extends StatefulWidget {
  final Activity? firstActivity;
  final Activity? thenActivity;

  const FirstThenOverlay({
    super.key,
    required this.firstActivity,
    required this.thenActivity,
  });

  static const _firstColor = Color(0xFFFF8C42); // orange
  static const _thenColor  = Color(0xFF5B9FE8); // blue

  static Future<void> show(
    BuildContext context, {
    required Activity? firstActivity,
    required Activity? thenActivity,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => FirstThenOverlay(
        firstActivity: firstActivity,
        thenActivity: thenActivity,
      ),
    );
  }

  @override
  State<FirstThenOverlay> createState() => _FirstThenOverlayState();
}

class _FirstThenOverlayState extends State<FirstThenOverlay> {
  Activity? _focusedActivity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap the barrier to close
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            // Prevent taps inside the card from bubbling to barrier
            onTap: () {},
            child: _focusedActivity != null
                ? _buildFocusedCard(context)
                : _buildFullCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top bar: X button ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 32, 32, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DAILY SCHEDULE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF333333),
                    letterSpacing: 2.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Color(0xFF333333), size: 28),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ── First / Then panels ────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (widget.firstActivity != null) {
                        setState(() => _focusedActivity = widget.firstActivity);
                      }
                    },
                    child: _ActivityPanel(
                      label: 'FIRST',
                      color: FirstThenOverlay._firstColor,
                      activity: widget.firstActivity,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Icon(Icons.arrow_forward_rounded,
                      color: Color(0xFFDDDDDD), size: 60),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (widget.thenActivity != null) {
                        setState(() => _focusedActivity = widget.thenActivity);
                      }
                    },
                    child: _ActivityPanel(
                      label: 'THEN',
                      color: FirstThenOverlay._thenColor,
                      activity: widget.thenActivity,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildFocusedCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 600,
      margin: const EdgeInsets.symmetric(horizontal: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(56),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 80,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Massive scaled-up image
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(56)),
                  child: Image.asset(
                    _focusedActivity!.imagePath,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    alignment: const Alignment(0, -0.4), // Move image up
                  ),
                ),
              ),
              // Focused Activity Label
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(56)),
                ),
                child: Column(
                  children: [
                    Text(
                      _focusedActivity!.label.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "CURRENT ACTIVITY",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Back button
          Positioned(
            top: 24,
            left: 24,
            child: GestureDetector(
              onTap: () => setState(() => _focusedActivity = null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "BACK",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityPanel extends StatelessWidget {
  final String label;
  final Color color;
  final Activity? activity;

  const _ActivityPanel({
    required this.label,
    required this.color,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 340,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(color: color.withOpacity(0.2), width: 3),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Massive Image Area
          Expanded(
            child: Stack(
              children: [
                if (activity != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(33)),
                      child: Image.asset(
                        activity!.imagePath,
                        fit: BoxFit.contain,
                        alignment: const Alignment(0, -0.3), // Move up
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(33)),
                    ),
                    child: Center(
                      child: Icon(Icons.help_outline_rounded,
                          color: color.withOpacity(0.2), size: 100),
                    ),
                  ),
                
                // Label Overlay (Bottom-aligned)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      activity?.label ?? 'Not set',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Top Label Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
