import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../services/timer_persistence.dart';
import '../services/notification_service.dart';
import '../services/settings_persistence.dart';
import '../models/activity.dart';
import '../models/app_settings.dart';
import '../models/quick_time.dart';
import '../widgets/quick_timer_editor.dart';
import 'not_started_view.dart';
import 'started_view.dart';

enum TimerState { notStarted, running, paused }

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // State
  TimerState _state = TimerState.notStarted;
  int _selectedMinutes = 2;
  int _selectedSeconds = 0;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  DateTime? _timerEndTime;

  // Settings
  AppSettings _settings = const AppSettings();

  // Quick times
  List<QuickTime> _quickTimes = List.from(QuickTime.defaults);

  // First / Then
  bool _firstThenMode = false;
  Activity? _firstActivity;
  Activity? _thenActivity;

  // Timer & Video
  Timer? _timer;
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;

  // Drum controllers
  late FixedExtentScrollController _minCtrl;
  late FixedExtentScrollController _secCtrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _minCtrl = FixedExtentScrollController(initialItem: 300 + _selectedMinutes);
    _secCtrl = FixedExtentScrollController(initialItem: 300);
    _requestNotificationPermissions();
    _restoreTimerIfActive();
    _loadQuickTimes();
    _loadSettings();
    _initVideo();

    // Sync state with controllers after a frame to ensure values are consistent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncDrumState();
    });
  }

  Future<void> _initVideo() async {
    try {
      final ctrl = VideoPlayerController.asset('little_blue_truck_mini_sequence.mp4');
      await ctrl.initialize();
      await ctrl.setLooping(true);
      if (mounted) {
        setState(() {
          _videoCtrl = ctrl;
          _videoReady = true;
        });
        // Auto-play if timer was restored
        if (_state == TimerState.running) ctrl.play();
      }
    } catch (_) {
      // Video unavailable — app still works without the animation
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _videoCtrl?.dispose();
    _minCtrl.dispose();
    _secCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _timerEndTime != null) {
      final remaining = _timerEndTime!.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        _timerFinished();
      } else if (_state == TimerState.running) {
        setState(() => _remainingSeconds = remaining);
        _tick();
      }
    }
  }

  /// Restore timer from persistent storage if it's still active
  /// Synchronize state variables with drum controller positions
  void _syncDrumState() {
    final minItem = _minCtrl.selectedItem;
    final secItem = _secCtrl.selectedItem;

    if (minItem >= 0 && secItem >= 0) {
      setState(() {
        _selectedMinutes = minItem % 60;
        _selectedSeconds = secItem % 60;
      });
    }
  }

  Future<void> _restoreTimerIfActive() async {
    final savedTimer = await TimerPersistence.getSavedTimer();
    if (savedTimer == null) return;

    // If state has changed (user started a new timer), don't restore
    if (_state != TimerState.notStarted) return;

    // Only restore if timer is still active
    if (!savedTimer.isActive) {
      // Timer has expired, clean up
      await TimerPersistence.clearTimer();
      return;
    }

    // Restore the active timer
    _timerEndTime = savedTimer.endTime;
    _totalSeconds = savedTimer.totalSeconds;
    final remaining = savedTimer.getRemainingSeconds();

    if (mounted) {
      setState(() {
        _remainingSeconds = remaining;
        _state = TimerState.running;
      });
      // Re-persist so we don't lose it again
      await TimerPersistence.saveTimer(_timerEndTime!, _totalSeconds);
      _tick();
    }
  }

  Future<void> _loadQuickTimes() async {
    final times = await TimerPersistence.loadQuickTimes();
    if (mounted) setState(() => _quickTimes = times);
  }

  Future<void> _loadSettings() async {
    final settings = await SettingsPersistence.load();
    if (mounted) setState(() => _settings = settings);
  }

  void _updateSettings(AppSettings settings) {
    setState(() => _settings = settings);
    SettingsPersistence.save(settings);
  }

  void _editQuickTimer(int index) {
    HapticFeedback.mediumImpact();
    QuickTimerEditor.show(
      context,
      index: index,
      initialTime: _quickTimes[index],
      onSave: (updated) {
        setState(() => _quickTimes[index] = updated);
        TimerPersistence.saveQuickTimes(_quickTimes);
      },
    );
  }

  void _selectQuickTimer(int minutes, int seconds) {
    setState(() {
      _selectedMinutes = minutes;
      _selectedSeconds = seconds;
    });
    // Animate both drum wheels to the selected values
    final minTarget = 300 + minutes;
    final secTarget = 300 + seconds;
    _minCtrl.animateToItem(
      minTarget,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
    _secCtrl.animateToItem(
      secTarget,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _startTimer() {
    final total = _selectedMinutes * 60 + _selectedSeconds;
    if (total == 0) return;

    HapticFeedback.mediumImpact();
    _totalSeconds = total;
    _remainingSeconds = total;
    _timerEndTime = DateTime.now().add(Duration(seconds: total));

    TimerPersistence.saveTimer(_timerEndTime!, _totalSeconds);
    NotificationService.scheduleTimerNotification(_totalSeconds);

    setState(() {
      _state = TimerState.running;
    });

    _videoCtrl?.play();
    _tick();
  }

  void _pauseTimer() {
    _timer?.cancel();
    _videoCtrl?.pause();
    setState(() => _state = TimerState.paused);
  }

  void _resumeTimer() {
    _videoCtrl?.play();
    setState(() => _state = TimerState.running);
    _tick();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timerEndTime = null;
    _totalSeconds = 0;
    TimerPersistence.clearTimer();
    NotificationService.cancelTimerNotification();
    _videoCtrl?.pause();
    _videoCtrl?.seekTo(Duration.zero);
    HapticFeedback.mediumImpact();

    // Reset to default time and sync state
    setState(() {
      _state = TimerState.notStarted;
      _remainingSeconds = 0;
      _selectedMinutes = 2;
      _selectedSeconds = 0;
    });

    // Reset drum controllers to defaults
    _minCtrl.jumpToItem(300 + 2);
    _secCtrl.jumpToItem(300 + 0);
  }

  void _timerFinished() {
    _timer?.cancel();
    _timerEndTime = null;
    _totalSeconds = 0;
    TimerPersistence.clearTimer();
    NotificationService.cancelTimerNotification();
    _videoCtrl?.pause();
    _videoCtrl?.seekTo(Duration.zero);
    HapticFeedback.heavyImpact();

    if (mounted) {
      setState(() {
        _state = TimerState.notStarted;
        _remainingSeconds = 0;
        _selectedMinutes = 2;
        _selectedSeconds = 0;
      });

      // Reset drum controllers to defaults
      _minCtrl.jumpToItem(300 + 2);
      _secCtrl.jumpToItem(300 + 0);
    }
  }

  void _tick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _timerFinished();
          t.cancel();
        }
      });
    });
  }

  Future<void> _requestNotificationPermissions() async {
    await NotificationService.requestPermissions();
  }

  void _toggleFirstThen() {
    setState(() => _firstThenMode = !_firstThenMode);
  }

  void _setFirstActivity(Activity a) {
    setState(() => _firstActivity = a);
  }

  void _setThenActivity(Activity a) {
    setState(() => _thenActivity = a);
  }

  double get _progress =>
      _totalSeconds == 0 ? 1.0 : _remainingSeconds / _totalSeconds;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: _state == TimerState.notStarted
          ? NotStartedView(
              key: const ValueKey('notStarted'),
              selectedMinutes: _selectedMinutes,
              selectedSeconds: _selectedSeconds,
              quickTimes: _quickTimes,
              minController: _minCtrl,
              secController: _secCtrl,
              onMinutesChanged: (v) {
                setState(() => _selectedMinutes = v % 60);
                if (v < 60) {
                  Future.microtask(() => _minCtrl.jumpToItem(v + 540));
                } else if (v >= 540) {
                  Future.microtask(() => _minCtrl.jumpToItem(v - 540));
                }
              },
              onSecondsChanged: (v) {
                setState(() => _selectedSeconds = v % 60);
                if (v < 60) {
                  Future.microtask(() => _secCtrl.jumpToItem(v + 540));
                } else if (v >= 540) {
                  Future.microtask(() => _secCtrl.jumpToItem(v - 540));
                }
              },
              onStartPressed: _startTimer,
              onQuickTimerSelected: _selectQuickTimer,
              onQuickTimerLongPress: _editQuickTimer,
              firstThenMode: _firstThenMode,
              firstActivity: _firstActivity,
              thenActivity: _thenActivity,
              onFirstThenToggle: _toggleFirstThen,
              onFirstActivitySelected: _setFirstActivity,
              onThenActivitySelected: _setThenActivity,
              settings: _settings,
              onSettingsChanged: _updateSettings,
            )
          : StartedView(
              key: const ValueKey('started'),
              isRunning: _state == TimerState.running,
              remainingSeconds: _remainingSeconds,
              progress: _progress,
              videoReady: _videoReady,
              videoController: _videoCtrl,
              onPlayPauseTap: _state == TimerState.running
                  ? _pauseTimer
                  : _resumeTimer,
              onStopTap: _stopTimer,
              onAddMinute: () {
                setState(() {
                  _remainingSeconds = (_remainingSeconds + 60).clamp(0, 5999);
                  _totalSeconds = (_totalSeconds + 60).clamp(0, 5999);
                });
              },
              onRemoveMinute: () {
                setState(() {
                  _remainingSeconds = (_remainingSeconds - 60).clamp(0, 5999);
                  if (_remainingSeconds == 0) _stopTimer();
                });
              },
              firstActivity: _firstActivity,
              thenActivity: _thenActivity,
            ),
    );
  }
}
