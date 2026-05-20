import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/background_timer_service.dart';
import '../services/alarm_service.dart';
import '../services/haptic_service.dart';

class TimerController extends ChangeNotifier {
  TimerController({
    BackgroundTimerService? timerService,
    AlarmService? alarmService,
    HapticService? hapticService,
  }) : _timerService = timerService ?? BackgroundTimerService(),
       _alarmService = alarmService ?? AlarmService(),
       _hapticService = hapticService ?? HapticService();

  final BackgroundTimerService _timerService;
  final AlarmService _alarmService;
  final HapticService _hapticService;

  StreamSubscription<int>? _timerSubscription;
  StreamSubscription<String>? _eventSubscription;

  // --- Internal State Constants ---
  static const int _defaultSeconds = 5 * 60;
  static const int _minimumSeconds = 60;
  static const int _maximumSeconds = 99 * 60;

  int _durationSeconds = _defaultSeconds;
  int _remainingSeconds = _defaultSeconds;
  bool _isRunning = false;
  bool _alarmTriggered = false;
  bool _isSoundSelectorExpanded = false;

  AlarmConfig _alarmConfig = const AlarmConfig(
    soundId: 'chime',
    isMuted: false,
  );

  // --- Getters ---
  int get durationSeconds => _durationSeconds;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get alarmTriggered => _alarmTriggered;
  bool get isSoundSelectorExpanded => _isSoundSelectorExpanded;
  AlarmConfig get alarmConfig => _alarmConfig;

  double get elapsedProgress {
    if (_durationSeconds == 0) return 0.0;
    return 1.0 - (_remainingSeconds / _durationSeconds);
  }

  String get statusLabel {
    if (_remainingSeconds == 0) return 'Done';
    if (_isRunning) return 'Running';
    if (_remainingSeconds < _durationSeconds) return 'Paused';
    return 'Ready';
  }

  // --- Life Cycle & Initialization ---
  Future<void> initialize() async {
    await _timerService.initialize();
    await _timerService.requestPermissions();
    await _loadAlarmConfig();

    _timerSubscription = _timerService.remainingSecondsStream.listen((seconds) {
      if (seconds == -1) return;

      _remainingSeconds = seconds;
      _isRunning = seconds > 0;

      if (seconds == 0 && !_alarmTriggered) {
        _alarmTriggered = true;
        _alarmService.playLoopingAlarm();
        _hapticService.startAlarmVibration();
      }
      notifyListeners();
    });

    _eventSubscription = _timerService.eventStream.listen((event) {
      if (event == 'dismiss') {
        dismissAlarm();
      }
    });

    if (await _timerService.isRunning()) {
      _isRunning = true;
      notifyListeners();
    }
  }

  Future<void> _loadAlarmConfig() async {
    _alarmConfig = await _alarmService.getAlarmConfig();
    notifyListeners();
  }

  @override
  void dispose() {
    _timerSubscription?.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }

  // --- Business Operations ---
  void selectDuration(int minutes) {
    if (_isRunning) return;
    _hapticService.lightTap();
    final seconds = minutes * 60;
    _durationSeconds = seconds;
    _remainingSeconds = seconds;
    notifyListeners();
  }

  void adjustDuration(int deltaSeconds) {
    if (_isRunning) return;
    _hapticService.selectionTick();
    _durationSeconds = math.min(
      _maximumSeconds,
      math.max(_minimumSeconds, _durationSeconds + deltaSeconds),
    );
    _remainingSeconds = _durationSeconds;
    notifyListeners();
  }

  void setDirectSeconds(int seconds) {
    if (_isRunning) return;
    _durationSeconds = math.min(
      _maximumSeconds,
      math.max(_minimumSeconds, seconds),
    );
    _remainingSeconds = _durationSeconds;
    notifyListeners();
  }

  Future<void> toggleTimer() async {
    _hapticService.lightTap();
    if (_isRunning) {
      await _timerService.pause();
      _isRunning = false;
    } else {
      if (_remainingSeconds == 0) {
        _remainingSeconds = _durationSeconds;
      }
      await _timerService.start(_remainingSeconds);
      _isRunning = true;
    }
    notifyListeners();
  }

  Future<void> resetTimer() async {
    _hapticService.mediumImpact();
    await _timerService.stop();
    await _alarmService.stopAlarm();
    await _hapticService.cancelVibration();
    _isRunning = false;
    _remainingSeconds = _durationSeconds;
    _alarmTriggered = false;
    notifyListeners();
  }

  Future<void> dismissAlarm() async {
    await _alarmService.stopAlarm();
    await _hapticService.cancelVibration();
    await resetTimer();
  }

  Future<void> toggleMute() async {
    if (_isRunning) return;
    _hapticService.lightTap();
    final newConfig = _alarmConfig.copyWith(isMuted: !_alarmConfig.isMuted);
    await _alarmService.saveAlarmConfig(newConfig);
    _alarmConfig = newConfig;
    notifyListeners();
  }

  Future<void> selectSound(String soundId) async {
    if (_isRunning) return;
    _hapticService.lightTap();
    final newConfig = _alarmConfig.copyWith(soundId: soundId);
    await _alarmService.saveAlarmConfig(newConfig);
    _alarmConfig = newConfig;
    notifyListeners();
    await _alarmService.playPreview(soundId);
  }

  void toggleSoundSelector() {
    if (_isRunning) return;
    _hapticService.lightTap();
    _isSoundSelectorExpanded = !_isSoundSelectorExpanded;
    notifyListeners();
  }
}
