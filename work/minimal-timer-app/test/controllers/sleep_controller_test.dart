import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_dev_team_flutter/controllers/sleep_controller.dart';
import 'package:ai_dev_team_flutter/services/alarm_service.dart';
import 'package:ai_dev_team_flutter/services/haptic_service.dart';
import 'package:ai_dev_team_flutter/services/storage_service.dart';
import 'package:ai_dev_team_flutter/models/activity_log.dart';

class MockAlarmService implements AlarmService {
  bool isWakelockEnabled = false;
  String? ambientSoundPlaying;
  double ambientVolume = 1.0;
  String? alarmSoundPlaying;
  double alarmVolume = 1.0;
  bool stopAlarmCalled = false;
  bool stopAmbientCalled = false;
  bool isPlayingVal = false;

  @override
  bool get isPlaying => isPlayingVal;

  @override
  Future<void> setScreenWakelock(bool enabled) async {
    isWakelockEnabled = enabled;
  }

  @override
  Future<void> playAmbientSound(String soundId) async {
    ambientSoundPlaying = soundId;
  }

  @override
  Future<void> stopAmbientSound() async {
    stopAmbientCalled = true;
    ambientSoundPlaying = null;
  }

  @override
  Future<void> setAmbientVolume(double volume) async {
    ambientVolume = volume;
  }

  @override
  Future<void> playProgressiveAlarm(
    String soundId, {
    required double volume,
  }) async {
    alarmSoundPlaying = soundId;
    alarmVolume = volume;
    isPlayingVal = true;
  }

  @override
  Future<void> setAlarmVolume(double volume) async {
    alarmVolume = volume;
  }

  @override
  Future<void> stopAlarm() async {
    stopAlarmCalled = true;
    isPlayingVal = false;
    alarmSoundPlaying = null;
  }

  @override
  Future<AlarmConfig> getAlarmConfig() async =>
      const AlarmConfig(soundId: 'chime', isMuted: false);
  @override
  Future<void> saveAlarmConfig(AlarmConfig config) async {}
  @override
  Future<void> playPreview(String soundId) async {}
  @override
  Future<void> playLoopingAlarm() async {}
}

class MockHapticService implements HapticService {
  bool selectionTickCalled = false;
  bool lightTapCalled = false;
  bool mediumImpactCalled = false;
  bool heavyImpactCalled = false;
  bool doubleBeatCalled = false;
  bool cancelVibrationCalled = false;
  int? progressiveHeartbeatSpeedLevel;

  @override
  void setHapticsEnabled(bool enabled) {}

  @override
  Future<void> selectionTick() async {
    selectionTickCalled = true;
  }

  @override
  Future<void> lightTap() async {
    lightTapCalled = true;
  }

  @override
  Future<void> mediumImpact() async {
    mediumImpactCalled = true;
  }

  @override
  Future<void> heavyImpact() async {
    heavyImpactCalled = true;
  }

  @override
  Future<void> doubleBeat() async {
    doubleBeatCalled = true;
  }

  @override
  Future<void> startProgressiveHeartbeatHaptics({
    required int speedLevel,
  }) async {
    progressiveHeartbeatSpeedLevel = speedLevel;
  }

  @override
  Future<void> startAlarmVibration() async {}

  @override
  Future<void> cancelVibration() async {
    cancelVibrationCalled = true;
    progressiveHeartbeatSpeedLevel = null;
  }
}

class MockStorageService implements StorageService {
  TimeOfDay wakeTime = const TimeOfDay(hour: 7, minute: 30);
  String sleepSound = 'rain';
  int windDownSeconds = 1800;
  final List<ActivityLog> savedLogs = [];

  @override
  Future<TimeOfDay> getWakeTimePreference() async => wakeTime;

  @override
  Future<void> saveWakeTimePreference(TimeOfDay time) async {
    wakeTime = time;
  }

  @override
  Future<String> getSleepSoundPreference() async => sleepSound;

  @override
  Future<void> saveSleepSoundPreference(String soundId) async {
    sleepSound = soundId;
  }

  @override
  Future<int> getWindDownDurationPreference() async => windDownSeconds;

  @override
  Future<void> saveWindDownDurationPreference(int seconds) async {
    windDownSeconds = seconds;
  }

  @override
  Future<List<ActivityLog>> loadActivityLogs() async => savedLogs;

  @override
  Future<void> saveSleepSession(SleepSession session) async {
    savedLogs.add(session);
  }

  @override
  Future<void> saveFocusSession(FocusSession session) async {
    savedLogs.add(session);
  }

  @override
  Future<void> deleteLogItem(String id) async {
    savedLogs.removeWhere((log) => log.id == id);
  }
}

void main() {
  group('SleepController Tests', () {
    late MockAlarmService mockAlarm;
    late MockHapticService mockHaptic;
    late MockStorageService mockStorage;
    late SleepController controller;

    setUp(() {
      mockAlarm = MockAlarmService();
      mockHaptic = MockHapticService();
      mockStorage = MockStorageService();
      controller = SleepController(
        alarmService: mockAlarm,
        hapticService: mockHaptic,
        storageService: mockStorage,
      );
    });

    test('initial values are loaded correctly from preferences', () async {
      await controller.initialize();
      expect(controller.targetWakeTime, const TimeOfDay(hour: 7, minute: 30));
      expect(controller.selectedSoundId, 'rain');
      expect(controller.windDownSeconds, 1800);
      expect(controller.isSleepActive, isFalse);
      expect(controller.isAlarmRinging, isFalse);
    });

    test('setTargetWakeTime updates state and persists preference', () async {
      const newTime = TimeOfDay(hour: 6, minute: 15);
      controller.setTargetWakeTime(newTime);

      expect(controller.targetWakeTime, newTime);
      expect(mockHaptic.selectionTickCalled, isTrue);
      expect(mockStorage.wakeTime, newTime);
    });

    test(
      'selectWindDownSound updates state, persists, and previews sound',
      () async {
        controller.selectWindDownSound('waves');

        expect(controller.selectedSoundId, 'waves');
        expect(mockHaptic.selectionTickCalled, isTrue);
        expect(mockStorage.sleepSound, 'waves');
      },
    );

    test('setWindDownSeconds updates state and persists preference', () async {
      controller.setWindDownSeconds(600);

      expect(controller.windDownSeconds, 600);
      expect(mockHaptic.lightTapCalled, isTrue);
      expect(mockStorage.windDownSeconds, 600);
    });

    test('estimatedRestDuration returns structured duration string', () {
      controller.setTargetWakeTime(const TimeOfDay(hour: 8, minute: 0));
      final duration = controller.estimatedRestDuration;
      expect(duration, contains('hrs'));
      expect(duration, contains('min'));
    });

    test(
      'enterSleepMode activates wakelock, plays ambient loop, and starts timers',
      () async {
        await controller.enterSleepMode();

        expect(controller.isSleepActive, isTrue);
        expect(mockHaptic.mediumImpactCalled, isTrue);
        expect(mockAlarm.isWakelockEnabled, isTrue);
        expect(mockAlarm.ambientSoundPlaying, 'rain');
      },
    );

    test(
      'cancelSleepEarly cancels timers, stops ambient sound, disables wakelock',
      () async {
        await controller.enterSleepMode();
        await controller.cancelSleepEarly();

        expect(controller.isSleepActive, isFalse);
        expect(mockAlarm.ambientSoundPlaying, isNull);
        expect(mockAlarm.isWakelockEnabled, isFalse);
        expect(mockAlarm.stopAlarmCalled, isTrue);
      },
    );

    test(
      'dismissAlarm cancels timers, stops alarm sound, resets active state, and saves sleep log',
      () async {
        await controller.enterSleepMode();
        await controller.dismissAlarm('restored');

        expect(controller.isSleepActive, isFalse);
        expect(controller.isAlarmRinging, isFalse);
        expect(mockAlarm.stopAlarmCalled, isTrue);
        expect(mockHaptic.cancelVibrationCalled, isTrue);
        expect(mockAlarm.isWakelockEnabled, isFalse);

        expect(mockStorage.savedLogs.length, 1);
        final savedLog = mockStorage.savedLogs.first;
        expect(savedLog, isA<SleepSession>());
        expect((savedLog as SleepSession).rating, 'restored');
      },
    );

    test('alarm triggers when target wake time matches current time', () async {
      // Set target wake time to current time
      final nowTime = TimeOfDay.fromDateTime(DateTime.now());
      controller.setTargetWakeTime(nowTime);

      await controller.enterSleepMode();

      // Wait for check scheduler (runs every 1s) to trigger alarm
      await Future.delayed(const Duration(milliseconds: 1100));

      expect(controller.isAlarmRinging, isTrue);
      expect(mockAlarm.alarmSoundPlaying, 'rain');
      expect(mockHaptic.progressiveHeartbeatSpeedLevel, 1);

      await controller.cancelSleepEarly();
    });
    group('Wind-down volume fade out logic', () {
      test('fade out updates volume and cancels player at 0.0', () async {
        // Set a ultra short wind down duration for quick tick check
        controller.setWindDownSeconds(1); // 1s wind down
        await controller.enterSleepMode();

        // Let the periodic timer tick (takes 20 ticks, so 1000ms / 20 = 50ms interval)
        await Future.delayed(const Duration(milliseconds: 1200));

        // It should have faded completely to 0.0 and stopped
        expect(mockAlarm.ambientSoundPlaying, isNull);
      });
    });
  });
}
