import 'dart:async';

import 'package:ai_dev_team_flutter/main.dart';
import 'package:ai_dev_team_flutter/services/background_timer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([BackgroundTimerService, SharedPreferences])
void main() {
  late MockBackgroundTimerService mockService;
  late MockSharedPreferences mockPrefs;
  late StreamController<int> stateController;
  late StreamController<String> eventController;

  setUp(() {
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

  testWidgets('shows the default timer controls', (tester) async {
    await tester.pumpWidget(
      TimerApp(
        timerService: mockService,
        onboardingComplete: true,
        prefs: mockPrefs,
      ),
    );

    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('05:00'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Duration 5 min'), findsOneWidget);
    expect(find.byKey(const Key('start-pause-button')), findsOneWidget);
    expect(find.byKey(const Key('reset-button')), findsOneWidget);
  });

  testWidgets('changes duration with presets and steppers', (tester) async {
    await tester.pumpWidget(
      TimerApp(
        timerService: mockService,
        onboardingComplete: true,
        prefs: mockPrefs,
      ),
    );

    await tester.tap(find.byKey(const Key('duration-1-minute-chip')));
    await tester.pump();

    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('Duration 1 min'), findsOneWidget);

    await tester.tap(find.byKey(const Key('increase-duration-button')));
    await tester.pump();

    expect(find.text('02:00'), findsOneWidget);
    expect(find.text('Duration 2 min'), findsOneWidget);

    await tester.tap(find.byKey(const Key('decrease-duration-button')));
    await tester.pump();

    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('Duration 1 min'), findsOneWidget);
  });

  testWidgets('starts, pauses, and resets the countdown', (tester) async {
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

    await tester.tap(find.byKey(const Key('duration-1-minute-chip')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('start-pause-button')));
    await tester.pump();

    expect(find.text('Running'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);

    // Simulate ticking
    stateController.add(59);
    await tester.pump();

    expect(find.text('00:59'), findsOneWidget);

    await tester.tap(find.byKey(const Key('start-pause-button')));
    await tester.pump();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('00:59'), findsOneWidget);

    await tester.tap(find.byKey(const Key('reset-button')));
    await tester.pump();

    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
  });

  testWidgets('shows completion and restart action at zero', (tester) async {
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

    await tester.tap(find.byKey(const Key('duration-1-minute-chip')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('start-pause-button')));
    await tester.pump();

    // Simulate ticking to zero
    stateController.add(0);
    await tester.pump();

    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
  });

  testWidgets('shows onboarding on first launch', (tester) async {
    await tester.pumpWidget(
      TimerApp(
        timerService: mockService,
        onboardingComplete: false,
        prefs: mockPrefs,
      ),
    );

    expect(find.text('Minimal Timer'), findsOneWidget);
    expect(find.text('Stays with you'), findsOneWidget);
    expect(find.text('Start Timing'), findsOneWidget);

    await tester.tap(find.text('Start Timing'));
    await tester.pumpAndSettle();

    // Should navigate to Timer screen
    expect(find.text('Timer'), findsOneWidget);
    verify(mockPrefs.setBool('onboarding_complete', true)).called(1);
  });

  testWidgets('can re-open onboarding from help button', (tester) async {
    await tester.pumpWidget(
      TimerApp(
        timerService: mockService,
        onboardingComplete: true,
        prefs: mockPrefs,
      ),
    );

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.text('Minimal Timer'), findsOneWidget);
    expect(find.text('Start Timing'), findsOneWidget);
  });

  testWidgets('can toggle mute state', (tester) async {
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

    // Verify initial mute status is showing Chime (Zen Bowl)
    expect(find.text('Chime (Zen Bowl)'), findsOneWidget);

    // Tap mute toggle
    await tester.tap(find.byKey(const Key('volume-mute-toggle')));
    await tester.pumpAndSettle();

    // Verify mute state is showing Muted
    expect(find.text('Muted'), findsOneWidget);

    // Tap mute toggle again to unmute
    await tester.tap(find.byKey(const Key('volume-mute-toggle')));
    await tester.pumpAndSettle();

    // Verify it is unmuted
    expect(find.text('Chime (Zen Bowl)'), findsOneWidget);
  });

  testWidgets('can expand sound selector and pick sound tone chip', (
    tester,
  ) async {
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

    // Sound chips should initially be collapsed/hidden
    expect(find.byKey(const Key('sound-chip-chime')), findsNothing);

    // Tap expand button
    await tester.tap(find.byKey(const Key('expand-sound-selector-button')));
    await tester.pumpAndSettle();

    // Sound chips should now be visible
    expect(find.byKey(const Key('sound-chip-chime')), findsOneWidget);
    expect(find.byKey(const Key('sound-chip-beep')), findsOneWidget);
    expect(find.byKey(const Key('sound-chip-echo')), findsOneWidget);

    // Tap Beep chip
    await tester.tap(find.byKey(const Key('sound-chip-beep')));
    await tester.pumpAndSettle();

    // Label should update to Beep (Digital)
    expect(find.text('Beep (Digital)'), findsNWidgets(2));
  });

  testWidgets('shows RingingOverlay at zero and dismissing resets timer', (
    tester,
  ) async {
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

    await tester.tap(find.byKey(const Key('duration-1-minute-chip')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('start-pause-button')));
    await tester.pump();

    // Simulate reaching zero
    stateController.add(0);
    await tester.pump(const Duration(seconds: 1));

    // Verify RingingOverlay is visible
    expect(find.text("Time's Up!"), findsOneWidget);
    expect(find.byKey(const Key('ringing-dismiss-button')), findsOneWidget);

    // Tap Dismiss
    await tester.tap(find.byKey(const Key('ringing-dismiss-button')));
    await tester.pumpAndSettle();

    // RingingOverlay should be gone and timer reset to Ready / 01:00
    expect(find.text("Time's Up!"), findsNothing);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('01:00'), findsOneWidget);
  });
}
