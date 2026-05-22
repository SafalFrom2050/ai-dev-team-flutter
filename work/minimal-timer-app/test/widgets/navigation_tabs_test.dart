import 'dart:async';

import 'package:ai_dev_team_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget_test.mocks.dart';

void main() {
  late MockBackgroundTimerService mockService;
  late MockSharedPreferences mockPrefs;
  late StreamController<int> stateController;
  late StreamController<String> eventController;

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (message) async {
          if (message.method == 'HapticFeedback.vibrate') {
            return null;
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('vibration'), (
          message,
        ) async {
          if (message.method == 'hasVibrator') {
            return true;
          }
          if (message.method == 'vibrate' || message.method == 'cancel') {
            return null;
          }
          return null;
        });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers'),
          (message) async {
            return null;
          },
        );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers/audioplayers'),
          (message) async {
            return null;
          },
        );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers/global'),
          (message) async {
            return null;
          },
        );

    mockService = MockBackgroundTimerService();
    mockPrefs = MockSharedPreferences();
    stateController = StreamController<int>.broadcast();
    eventController = StreamController<String>.broadcast();

    when(mockService.initialize()).thenAnswer((_) async {});
    when(mockService.requestPermissions()).thenAnswer((_) async {});
    when(mockService.isRunning()).thenAnswer((_) async => false);
    when(
      mockService.remainingSecondsStream,
    ).thenAnswer((_) => stateController.stream);
    when(mockService.eventStream).thenAnswer((_) => eventController.stream);
    when(mockService.start(any)).thenAnswer((_) async {});
    when(mockService.pause()).thenAnswer((_) async {});
    when(mockService.stop()).thenAnswer((_) async {});

    when(mockPrefs.setBool(any, any)).thenAnswer((_) async => true);
  });

  tearDown(() {
    stateController.close();
    eventController.close();
  });

  testWidgets('navigation tabs switch views correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      TimerApp(
        timerService: mockService,
        onboardingComplete: true,
        prefs: mockPrefs,
      ),
    );
    await tester.pumpAndSettle();

    // Landing screen is Timer Tab (index 1)
    expect(find.byKey(const Key('timer-screen-title')), findsOneWidget);

    // Switch to Sleep Tab (index 0)
    await tester.tap(find.text('Sleep'));
    await tester.pumpAndSettle();

    // Verify Sleep Screen content
    expect(find.text('Rest & Restore'), findsOneWidget);
    expect(find.text('ENTER DEEP SLEEP MODE'), findsOneWidget);

    // Switch to Studio Tab (index 2)
    await tester.tap(find.text('Studio'));
    await tester.pumpAndSettle();

    // Verify Alarm/Sound Studio Screen content
    expect(find.text('Sound Studio'), findsOneWidget);
    expect(find.text('PRESET SOUNDS'), findsOneWidget);

    // Switch back to Timer Tab (index 1)
    await tester.tap(find.text('Timer'));
    await tester.pumpAndSettle();

    // Verify back to Timer Screen
    expect(find.byKey(const Key('timer-screen-title')), findsOneWidget);
  });

  testWidgets('preserves timer countdown state perfectly when switching tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      TimerApp(
        timerService: mockService,
        onboardingComplete: true,
        prefs: mockPrefs,
      ),
    );
    await tester.pumpAndSettle();

    // Start a 1 min focus timer
    await tester.tap(find.byKey(const Key('duration-1-minute-chip')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('start-pause-button')));
    await tester.pump();

    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);

    // Tick down to 59 seconds
    stateController.add(59);
    await tester.pump();

    // Verify state: showing 00:59 running
    expect(find.text('00:59'), findsOneWidget);
    expect(find.text('Running'), findsOneWidget);

    // Switch to Sleep Tab
    await tester.tap(find.text('Sleep'));
    await tester.pumpAndSettle();

    // Verify we are in Sleep tab
    expect(find.text('Rest & Restore'), findsOneWidget);

    // Switch back to Timer Tab
    await tester.tap(find.text('Timer'));
    await tester.pumpAndSettle();

    // Assert that the state is preserved perfectly (still Running and countdown at 00:59)
    expect(find.text('Running'), findsOneWidget);
    expect(find.text('00:59'), findsOneWidget);
  });
}
