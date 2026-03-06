import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quick_time.dart';
import 'drum_picker.dart';

class QuickTimerEditor extends StatefulWidget {
  final int index;
  final QuickTime initialTime;
  final void Function(QuickTime updated) onSave;

  const QuickTimerEditor({
    super.key,
    required this.index,
    required this.initialTime,
    required this.onSave,
  });

  /// Show as a modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required int index,
    required QuickTime initialTime,
    required void Function(QuickTime) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickTimerEditor(
        index: index,
        initialTime: initialTime,
        onSave: onSave,
      ),
    );
  }

  @override
  State<QuickTimerEditor> createState() => _QuickTimerEditorState();
}

class _QuickTimerEditorState extends State<QuickTimerEditor> {
  static const _teal = Color(0xFF4ECBA3);
  static const _forest = Color(0xFF5DAA60);

  late FixedExtentScrollController _minCtrl;
  late FixedExtentScrollController _secCtrl;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialTime.minutes;
    _seconds = widget.initialTime.seconds;
    _minCtrl = FixedExtentScrollController(initialItem: 300 + _minutes);
    _secCtrl = FixedExtentScrollController(initialItem: 300 + _seconds);
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _secCtrl.dispose();
    super.dispose();
  }

  void _save() {
    HapticFeedback.mediumImpact();
    widget.onSave(QuickTime(_minutes, _seconds));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle ──────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Header ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _forest.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.timer_outlined,
                        color: _forest, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Timer ${widget.index + 1}',
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Set a custom time',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Divider ─────────────────────────
            Divider(color: Colors.grey[100], thickness: 1, height: 1),

            const SizedBox(height: 24),

            // ── Live preview ────────────────────
            Text(
              '$_minutes:${_seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: _teal,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 20),

            // ── Drum pickers ────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DrumPicker(
                    label: 'Min',
                    controller: _minCtrl,
                    count: 600,
                    display: (i) => (i % 60).toString(),
                    onChanged: (v) {
                      setState(() => _minutes = v % 60);
                      if (v < 60) {
                        Future.microtask(() => _minCtrl.jumpToItem(v + 540));
                      } else if (v >= 540) {
                        Future.microtask(() => _minCtrl.jumpToItem(v - 540));
                      }
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                  DrumPicker(
                    label: 'Sec',
                    controller: _secCtrl,
                    count: 600,
                    display: (i) =>
                        (i % 60).toString().padLeft(2, '0'),
                    onChanged: (v) {
                      setState(() => _seconds = v % 60);
                      if (v < 60) {
                        Future.microtask(() => _secCtrl.jumpToItem(v + 540));
                      } else if (v >= 540) {
                        Future.microtask(() => _secCtrl.jumpToItem(v - 540));
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Save button ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _teal,
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: _teal.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
