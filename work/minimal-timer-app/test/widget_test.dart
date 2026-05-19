import 'dart:async';

import 'package:ai_dev_team_flutter/main.dart';
import 'package:ai_dev_team_flutter/services/background_timer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([BackgroundTimerService])
void main() {
  late MockBackgroundTimerService mockService;
  late StreamController<int> stateController;

  setUp(() {
    mockService = MockBackgroundTimerService();
    stateController = StreamController<int>.broadcast();

    when(mockService.initialize()).thenAnswer((_) async {});
    when(mockService.requestPermissions()).thenAnswer((_) async {});
    when(mockService.isRunning()).thenAnswer((_) async => false);
    when(mockService.remainingSecondsStream).thenAnswer((_) => stateController.stream);
    when(mockService.start(any)).thenAnswer((_) async {});
    when(mockService.pause()).thenAnswer((_) async {});
    when(mockService.stop()).thenAnswer((_) async {});
  });

  tearDown(() {
    stateController.close();
  });

  testWidgets('shows the default timer controls', (tester) async {
    await tester.pumpWidget(TimerApp(timerService: mockService));

    expect(find.text('Timer'), findsOneWidget);
    expect(find.text('05:00'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Duration 5 min'), findsOneWidget);
    expect(find.byKey(const Key('start-pause-button')), findsOneWidget);
    expect(find.byKey(const Key('reset-button')), findsOneWidget);
  });

  testWidgets('changes duration with presets and steppers', (tester) async {
    await tester.pumpWidget(TimerApp(timerService: mockService));

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
    await tester.pumpWidget(TimerApp(timerService: mockService));

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
    await tester.pumpWidget(TimerApp(timerService: mockService));

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
}
