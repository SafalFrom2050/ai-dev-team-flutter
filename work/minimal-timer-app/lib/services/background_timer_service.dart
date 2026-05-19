import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

/// The entry point for the background task isolate.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(TimerTaskHandler());
}

class TimerTaskHandler extends TaskHandler {
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Initialization if needed
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Not using this since we use an internal Timer for precision
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool withStopService) async {
    _timer?.cancel();
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map<String, dynamic>) {
      final command = data['command'];
      if (command == 'start') {
        _remainingSeconds = data['seconds'] ?? 0;
        _startTimer();
      } else if (command == 'pause') {
        _stopTimer();
      } else if (command == 'resume') {
        _startTimer();
      } else if (command == 'reset') {
        _stopTimer();
        _remainingSeconds = 0;
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _updateNotification();
        FlutterForegroundTask.sendDataToMain(_remainingSeconds);
      } else {
        _stopTimer();
        _updateNotification(isDone: true);
        FlutterForegroundTask.sendDataToMain(0);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _updateNotification({bool isDone = false}) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    FlutterForegroundTask.updateService(
      notificationTitle: isDone ? 'Timer Done' : 'Timer Running',
      notificationText: isDone ? 'Time is up!' : 'Remaining: $timeStr',
    );
  }
}

class BackgroundTimerService {
  static final BackgroundTimerService _instance = BackgroundTimerService._internal();
  factory BackgroundTimerService() => _instance;
  BackgroundTimerService._internal();

  final _stateController = StreamController<int>.broadcast();
  Stream<int> get remainingSecondsStream => _stateController.stream;

  Future<void> initialize() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'timer_service',
        channelName: 'Timer Service',
        channelDescription: 'Running the countdown timer in the background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
      ),
    );

    FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.addTaskDataCallback(_onTaskDataReceived);
  }

  void _onTaskDataReceived(Object data) {
    if (data is int) {
      _stateController.add(data);
    }
  }

  Future<bool> isRunning() async {
    return await FlutterForegroundTask.isRunningService;
  }

  Future<void> requestPermissions() async {
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
    
    NotificationPermission notificationPermissionStatus = 
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  Future<void> start(int seconds) async {
    if (await isRunning()) {
      FlutterForegroundTask.sendDataToTask({'command': 'start', 'seconds': seconds});
    } else {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Timer Starting',
        notificationText: 'Preparing countdown...',
        callback: startCallback,
      );
      
      // Give it a moment to start before sending data
      await Future.delayed(const Duration(milliseconds: 500));
      FlutterForegroundTask.sendDataToTask({'command': 'start', 'seconds': seconds});
    }
  }

  Future<void> pause() async {
    FlutterForegroundTask.sendDataToTask({'command': 'pause'});
  }

  Future<void> resume() async {
    FlutterForegroundTask.sendDataToTask({'command': 'resume'});
  }

  Future<void> stop() async {
    await FlutterForegroundTask.stopService();
  }
}
