import 'dart:async';
import 'dart:io' show Platform;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration for the Alarm, holding choice of sound and mute status.
class AlarmConfig {
  final String soundId; // chime, beep, echo
  final bool isMuted;

  const AlarmConfig({required this.soundId, required this.isMuted});

  Map<String, dynamic> toJson() => {'soundId': soundId, 'isMuted': isMuted};

  factory AlarmConfig.fromJson(Map<String, dynamic> json) {
    return AlarmConfig(
      soundId: json['soundId'] ?? 'chime',
      isMuted: json['isMuted'] ?? false,
    );
  }

  AlarmConfig copyWith({String? soundId, bool? isMuted}) {
    return AlarmConfig(
      soundId: soundId ?? this.soundId,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

/// A service that manages timer alarm triggers, sound playback, vibrations,
/// and SharedPreferences persistence.
class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  static const String _prefsKey = 'alarm_config';

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _autoSilenceTimer;
  bool _isPlaying = false;

  bool get _isTest =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  /// Returns true if the alarm is currently active (ringing or vibrating).
  bool get isPlaying => _isPlaying;

  /// Fetch the alarm config from SharedPreferences.
  Future<AlarmConfig> getAlarmConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final soundId = prefs.getString('${_prefsKey}_soundId') ?? 'chime';
      final isMuted = prefs.getBool('${_prefsKey}_isMuted') ?? false;
      return AlarmConfig(soundId: soundId, isMuted: isMuted);
    } catch (e) {
      debugPrint('Error getting AlarmConfig: $e');
      return const AlarmConfig(soundId: 'chime', isMuted: false);
    }
  }

  /// Save the alarm config to SharedPreferences.
  Future<void> saveAlarmConfig(AlarmConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_prefsKey}_soundId', config.soundId);
      await prefs.setBool('${_prefsKey}_isMuted', config.isMuted);
    } catch (e) {
      debugPrint('Error saving AlarmConfig: $e');
    }
  }

  /// Play a one-shot preview of a sound.
  /// Previews bypass the general mute setting so users can test the sound,
  /// but they do not trigger vibration.
  Future<void> playPreview(String soundId) async {
    await stopAlarm();
    if (_isTest) {
      return;
    }
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('audio/$soundId.wav'));
    } catch (e) {
      debugPrint('Error playing sound preview: $e');
    }
  }

  /// Starts the looping alarm sound and custom vibrations.
  /// Automatically silences after 5 minutes to prevent battery drain.
  Future<void> playLoopingAlarm() async {
    await stopAlarm();
    _isPlaying = true;

    final config = await getAlarmConfig();

    // 1. Play loop audio if not muted
    if (!config.isMuted) {
      if (!_isTest) {
        try {
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
          await _audioPlayer.setVolume(1.0);
          await _audioPlayer.play(AssetSource('audio/${config.soundId}.wav'));
        } catch (e) {
          debugPrint('Error playing looping alarm: $e');
        }
      }
    }

    // 2. Play custom double-beat vibration
    try {
      if (!kIsWeb && await Vibration.hasVibrator() == true) {
        await Vibration.vibrate(pattern: [0, 150, 150, 150], repeat: 0);
      }
    } catch (e) {
      debugPrint('Error triggering custom vibration: $e');
    }

    // 3. Start auto-silence timer (5 minutes)
    _startAutoSilenceTimer();
  }

  /// Stops any playing alarm sound, cancels vibration, and cancels auto-silence.
  Future<void> stopAlarm() async {
    _isPlaying = false;
    _stopAutoSilenceTimer();

    if (!_isTest) {
      try {
        await _audioPlayer.stop();
      } catch (e) {
        debugPrint('Error stopping alarm audio: $e');
      }
    }

    try {
      if (!kIsWeb) {
        await Vibration.cancel();
      }
    } catch (e) {
      debugPrint('Error canceling vibration: $e');
    }
  }

  void _startAutoSilenceTimer() {
    _autoSilenceTimer?.cancel();
    if (_isTest) {
      return;
    }
    _autoSilenceTimer = Timer(const Duration(minutes: 5), () {
      debugPrint('Alarm auto-silenced after 5 minutes of continuous play.');
      stopAlarm();
    });
  }

  void _stopAutoSilenceTimer() {
    _autoSilenceTimer?.cancel();
    _autoSilenceTimer = null;
  }
}
