import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vibration/vibration.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  bool _hapticsEnabled = true;
  Timer? _heartbeatTimer;

  /// Globally toggle haptic feedback accessibility state.
  void setHapticsEnabled(bool enabled) {
    _hapticsEnabled = enabled;
  }

  /// Subtle light selection tick for incremental adjustments (e.g., rotating the dial).
  Future<void> selectionTick() async {
    if (!_hapticsEnabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Snappy impact confirming micro-interactions (e.g., button press, chip selection).
  Future<void> lightTap() async {
    if (!_hapticsEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Standard medium impact for state updates (e.g., stopping active timers).
  Future<void> mediumImpact() async {
    if (!_hapticsEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Rigid, heavy feedback for high-emphasis triggers.
  Future<void> heavyImpact() async {
    if (!_hapticsEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Double-beat haptic trigger.
  Future<void> doubleBeat() async {
    if (!_hapticsEnabled) return;
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Starts repeating heartbeat haptic tick at varying speed levels.
  /// Level 1: 1500ms, Level 2: 1000ms, Level 3: 500ms.
  Future<void> startProgressiveHeartbeatHaptics({
    required int speedLevel,
  }) async {
    _heartbeatTimer?.cancel();
    if (!_hapticsEnabled) return;

    final duration = switch (speedLevel) {
      1 => const Duration(milliseconds: 1500),
      2 => const Duration(milliseconds: 1000),
      3 => const Duration(milliseconds: 500),
      _ => const Duration(milliseconds: 1000),
    };

    // Trigger immediately
    await doubleBeat();

    _heartbeatTimer = Timer.periodic(duration, (timer) async {
      await doubleBeat();
    });
  }

  /// Triggers repeating heavy pulses when the timer reaches zero.
  /// Falls back to physical device vibration loops.
  Future<void> startAlarmVibration() async {
    if (!_hapticsEnabled || kIsWeb) return;
    try {
      if (await Vibration.hasVibrator() == true) {
        // High frequency double-beat pulse sequence repeating indefinitely
        await Vibration.vibrate(pattern: [0, 150, 150, 150], repeat: 0);
      } else {
        // Fallback to basic system warning pulses
        await HapticFeedback.heavyImpact();
      }
    } catch (_) {}
  }

  /// Gracefully cancels any ongoing vibration loops.
  Future<void> cancelVibration() async {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    if (kIsWeb) return;
    try {
      await Vibration.cancel();
    } catch (_) {}
  }
}
