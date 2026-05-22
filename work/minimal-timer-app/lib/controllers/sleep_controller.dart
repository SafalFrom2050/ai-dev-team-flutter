import 'dart:async';
import 'package:flutter/material.dart';
import '../services/alarm_service.dart';
import '../services/haptic_service.dart';
import '../services/storage_service.dart';
import '../models/activity_log.dart';

class SleepController extends ChangeNotifier {
  SleepController({
    AlarmService? alarmService,
    HapticService? hapticService,
    StorageService? storageService,
  }) : _alarmService = alarmService ?? AlarmService(),
       _hapticService = hapticService ?? HapticService(),
       _storageService = storageService ?? StorageService();

  final AlarmService _alarmService;
  final HapticService _hapticService;
  final StorageService _storageService;

  // --- Configuration State ---
  TimeOfDay _targetWakeTime = const TimeOfDay(hour: 7, minute: 30);
  String _selectedSoundId = 'rain';
  int _windDownSeconds = 1800; // 30 mins default (0 = Off)

  // --- Active Session State ---
  bool _isSleepActive = false;
  bool _isAlarmRinging = false;
  double _progressiveVolume = 0.1;
  double _swipeDismissProgress = 0.0;
  DateTime? _sleepStartTime;
  Timer? _windDownTimer;
  Timer? _alarmCheckTimer;
  Timer? _progressiveCrescendoTimer;

  // --- Getters ---
  TimeOfDay get targetWakeTime => _targetWakeTime;
  String get selectedSoundId => _selectedSoundId;
  int get windDownSeconds => _windDownSeconds;
  bool get isSleepActive => _isSleepActive;
  bool get isAlarmRinging => _isAlarmRinging;
  double get progressiveVolume => _progressiveVolume;
  double get swipeDismissProgress => _swipeDismissProgress;

  String get estimatedRestDuration {
    final now = DateTime.now();
    var target = DateTime(
      now.year,
      now.month,
      now.day,
      _targetWakeTime.hour,
      _targetWakeTime.minute,
    );
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    final diff = target.difference(now);
    final hrs = diff.inHours;
    final mins = diff.inMinutes % 60;
    return '$hrs hrs $mins min';
  }

  // --- Life Cycle ---
  Future<void> initialize() async {
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _targetWakeTime = await _storageService.getWakeTimePreference();
    _selectedSoundId = await _storageService.getSleepSoundPreference();
    _windDownSeconds = await _storageService.getWindDownDurationPreference();
    notifyListeners();
  }

  // --- User Operations ---
  void setTargetWakeTime(TimeOfDay time) {
    if (_isSleepActive) return;
    _targetWakeTime = time;
    _hapticService.selectionTick();
    _storageService.saveWakeTimePreference(time);
    notifyListeners();
  }

  void selectWindDownSound(String soundId) {
    if (_isSleepActive) return;
    _selectedSoundId = soundId;
    _hapticService.selectionTick();
    _storageService.saveSleepSoundPreference(soundId);
    _alarmService.playPreview(soundId);
    notifyListeners();
  }

  void setWindDownSeconds(int seconds) {
    if (_isSleepActive) return;
    _windDownSeconds = seconds;
    _hapticService.lightTap();
    _storageService.saveWindDownDurationPreference(seconds);
    notifyListeners();
  }

  Future<void> enterSleepMode() async {
    _isSleepActive = true;
    _sleepStartTime = DateTime.now();
    _hapticService.mediumImpact();
    notifyListeners();

    // 1. Activate Wakelock (Screen stays dim but active)
    await _alarmService.setScreenWakelock(true);

    // 2. Play wind-down sound with active loop
    if (_selectedSoundId != 'silent') {
      await _alarmService.playAmbientSound(_selectedSoundId);
      _startWindDownFadeOut();
    }

    // 3. Register Alarm timer callback
    _startAlarmCheckScheduler();
  }

  void _startWindDownFadeOut() {
    _windDownTimer?.cancel();
    if (_windDownSeconds == 0) return; // Infinity loop

    final totalTicks = 20;
    final milliseconds = (_windDownSeconds * 1000) ~/ totalTicks;
    final tickInterval = milliseconds > 50
        ? Duration(milliseconds: milliseconds)
        : const Duration(milliseconds: 50);
    var currentTick = 0;

    _windDownTimer = Timer.periodic(tickInterval, (timer) async {
      currentTick++;
      final volume = 1.0 - (currentTick / totalTicks);
      if (volume <= 0.0) {
        await _alarmService.stopAmbientSound();
        timer.cancel();
      } else {
        await _alarmService.setAmbientVolume(volume);
      }
    });
  }

  void _startAlarmCheckScheduler() {
    _alarmCheckTimer?.cancel();
    _alarmCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.hour == _targetWakeTime.hour &&
          now.minute == _targetWakeTime.minute &&
          !_isAlarmRinging) {
        _triggerAlarm();
        timer.cancel();
      }
    });
  }

  Future<void> _triggerAlarm() async {
    _isAlarmRinging = true;
    _progressiveVolume = 0.1;
    _swipeDismissProgress = 0.0;
    notifyListeners();

    // Sound linear volume crescendo (0.1 to 1.0 over 60s)
    await _alarmService.playProgressiveAlarm(
      _selectedSoundId,
      volume: _progressiveVolume,
    );
    _hapticService.startProgressiveHeartbeatHaptics(speedLevel: 1);

    var secondsPassed = 0;
    _progressiveCrescendoTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      secondsPassed++;
      _progressiveVolume = 0.1 + (0.9 * (secondsPassed / 60.0));
      if (_progressiveVolume >= 1.0) {
        _progressiveVolume = 1.0;
        timer.cancel();
      }
      await _alarmService.setAlarmVolume(_progressiveVolume);

      // Upgrade heartbeat haptic intensities
      if (secondsPassed == 16) {
        _hapticService.startProgressiveHeartbeatHaptics(speedLevel: 2);
      } else if (secondsPassed == 31) {
        _hapticService.startProgressiveHeartbeatHaptics(speedLevel: 3);
      }
    });
  }

  void updateSwipeProgress(double value) {
    _swipeDismissProgress = value;
    notifyListeners();
  }

  Future<void> dismissAlarm(String rating) async {
    _progressiveCrescendoTimer?.cancel();
    _alarmCheckTimer?.cancel();
    _windDownTimer?.cancel();

    await _alarmService.stopAlarm();
    await _hapticService.cancelVibration();
    await _alarmService.setScreenWakelock(false);

    // Save sleep session metrics to database
    final now = DateTime.now();
    final durationSecs = _sleepStartTime != null
        ? now.difference(_sleepStartTime!).inSeconds
        : 8 * 3600; // Mock fallback if empty

    final session = SleepSession(
      id: UniqueKey().toString(),
      timestamp: now,
      durationSeconds: durationSecs,
      rating: rating,
    );

    await _storageService.saveSleepSession(session);

    _isSleepActive = false;
    _isAlarmRinging = false;
    _swipeDismissProgress = 0.0;
    notifyListeners();
  }

  Future<void> cancelSleepEarly() async {
    _windDownTimer?.cancel();
    _alarmCheckTimer?.cancel();
    _progressiveCrescendoTimer?.cancel();
    await _alarmService.stopAmbientSound();
    await _alarmService.stopAlarm();
    await _hapticService.cancelVibration();
    await _alarmService.setScreenWakelock(false);

    _isSleepActive = false;
    _isAlarmRinging = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _windDownTimer?.cancel();
    _alarmCheckTimer?.cancel();
    _progressiveCrescendoTimer?.cancel();
    super.dispose();
  }
}
