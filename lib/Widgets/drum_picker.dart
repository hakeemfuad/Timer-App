import 'package:flutter/material.dart';

/// Rolling drum/wheel selector for time input
class DrumPicker extends StatelessWidget {
  final String label;
  final FixedExtentScrollController controller;
  final int count;
  final String Function(int) display;
  final ValueChanged<int> onChanged;
  final Color textColor;
  final Color labelColor;
  final Color accentColor;

  const DrumPicker({
    super.key,
    required this.label,
    required this.controller,
    required this.count,
    required this.display,
    required this.onChanged,
    this.textColor = const Color(0xFF2D2D2D),
    this.labelColor = const Color(0xFF999999),
    this.accentColor = const Color(0xFF4ECBA3),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 72,
          height: 126,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Accent underline on selected row
              Positioned(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: accentColor, width: 2.5),
                    ),
                  ),
                ),
              ),
              ListWheelScrollView.useDelegate(
                controller: controller,
                itemExtent: 42,
                diameterRatio: 1.8,
                perspective: 0.003,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: onChanged,
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: count,
                  builder: (ctx, i) => Center(
                    child: Text(
                      display(i),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
