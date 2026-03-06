import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quick_time.dart';

/// Handles timer persistence across app sessions
class TimerPersistence {
  static const String _endMsKey = 'timer_end_ms';
  static const String _totalSecsKey = 'timer_total_secs';

  /// Save timer end time and total duration
  static Future<void> saveTimer(DateTime endTime, int totalSeconds) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_endMsKey, endTime.millisecondsSinceEpoch),
      prefs.setInt(_totalSecsKey, totalSeconds),
    ]);
  }

  /// Retrieve saved timer data
  static Future<SavedTimer?> getSavedTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final endMs = prefs.getInt(_endMsKey);
    final totalSecs = prefs.getInt(_totalSecsKey);

    if (endMs == null) return null;

    return SavedTimer(
      endTime: DateTime.fromMillisecondsSinceEpoch(endMs),
      totalSeconds: totalSecs ?? 0,
    );
  }

  // ── Quick Times ───────────────────────────────
  static const String _quickTimesKey = 'quick_times';

  static Future<List<QuickTime>> loadQuickTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_quickTimesKey);
    if (encoded == null) return List.from(QuickTime.defaults);
    try {
      final list = jsonDecode(encoded) as List;
      return list
          .map((j) => QuickTime.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return List.from(QuickTime.defaults);
    }
  }

  static Future<void> saveQuickTimes(List<QuickTime> times) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _quickTimesKey,
      jsonEncode(times.map((t) => t.toJson()).toList()),
    );
  }

  /// Clear all persisted timer data
  static Future<void> clearTimer() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_endMsKey),
      prefs.remove(_totalSecsKey),
    ]);
  }
}

class SavedTimer {
  final DateTime endTime;
  final int totalSeconds;

  SavedTimer({
    required this.endTime,
    required this.totalSeconds,
  });

  /// Calculate remaining seconds from now
  int getRemainingSeconds() {
    return endTime.difference(DateTime.now()).inSeconds;
  }

  /// Check if timer is still active (hasn't expired)
  bool get isActive => getRemainingSeconds() > 0;
}
