import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_log.dart';

class StorageService {
  static const String _keyLogs = 'key_activity_logs_json';
  static const String _keyHour = 'pref_sleep_alarm_time_hour';
  static const String _keyMin = 'pref_sleep_alarm_time_minute';
  static const String _keySound = 'pref_sleep_sound_id';
  static const String _keyWindDown = 'pref_sleep_wind_down_duration';

  // --- Preference Setters & Getters ---
  Future<TimeOfDay> getWakeTimePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_keyHour) ?? 7;
    final min = prefs.getInt(_keyMin) ?? 30;
    return TimeOfDay(hour: hour, minute: min);
  }

  Future<void> saveWakeTimePreference(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHour, time.hour);
    await prefs.setInt(_keyMin, time.minute);
  }

  Future<String> getSleepSoundPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySound) ?? 'rain';
  }

  Future<void> saveSleepSoundPreference(String soundId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySound, soundId);
  }

  Future<int> getWindDownDurationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyWindDown) ?? 1800;
  }

  Future<void> saveWindDownDurationPreference(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyWindDown, seconds);
  }

  // --- Activity Timeline Database Operations ---
  Future<List<ActivityLog>> loadActivityLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString(_keyLogs);
    if (logsJson == null) return [];

    try {
      final List<dynamic> decodedList = jsonDecode(logsJson);
      return decodedList
          .map((item) => ActivityLog.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort(
          (a, b) => b.timestamp.compareTo(a.timestamp),
        ); // Descending order
    } catch (e) {
      // Return empty array if file corruption occurs
      return [];
    }
  }

  Future<void> saveSleepSession(SleepSession session) async {
    final logs = await loadActivityLogs();
    logs.add(session);
    await _flushLogs(logs);
  }

  Future<void> saveFocusSession(FocusSession session) async {
    final logs = await loadActivityLogs();
    logs.add(session);
    await _flushLogs(logs);
  }

  Future<void> deleteLogItem(String id) async {
    final logs = await loadActivityLogs();
    logs.removeWhere((item) => item.id == id);
    await _flushLogs(logs);
  }

  Future<void> _flushLogs(List<ActivityLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final listJson = logs.map((log) => log.toJson()).toList();
    await prefs.setString(_keyLogs, jsonEncode(listJson));
  }
}
