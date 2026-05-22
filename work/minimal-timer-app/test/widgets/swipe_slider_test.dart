import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_dev_team_flutter/widgets/swipe_slider.dart';

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;

    // Mock platform channels for Haptics and Vibration
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
  });

  testWidgets('renders track, puck, and helper text', (WidgetTester tester) async {
    bool completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwipeToWakeSlider(
            onComplete: () {
              completed = true;
            },
          ),
        ),
      ),
    );

    // Verify background text helper "SLIDE TO WAKE"
    expect(find.text('SLIDE TO WAKE'), findsOneWidget);

    // Verify puck icon "chevron_right"
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    // Verify arrow_forward_ios helper icon
    expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);

    expect(completed, isFalse);
  });

  testWidgets('snaps back when drag is less than threshold (e.g. 100dp)', (WidgetTester tester) async {
    bool completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SwipeToWakeSlider(
              onComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      ),
    );

    final puckFinder = find.byIcon(Icons.chevron_right);
    final initialPos = tester.getTopLeft(puckFinder);

    // Drag puck 100dp horizontally
    await tester.drag(puckFinder, const Offset(100.0, 0.0));
    await tester.pumpAndSettle();

    final finalPos = tester.getTopLeft(puckFinder);

    // Puck should snap back to initial x position
    expect(finalPos.dx, closeTo(initialPos.dx, 0.01));
    expect(completed, isFalse);
  });

  testWidgets('triggers onComplete when drag is past threshold (e.g. 240dp)', (WidgetTester tester) async {
    bool completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SwipeToWakeSlider(
              onComplete: () {
                completed = true;
              },
            ),
          ),
        ),
      ),
    );

    final puckFinder = find.byIcon(Icons.chevron_right);

    // Drag puck 240dp horizontally (threshold is 179.2)
    await tester.drag(puckFinder, const Offset(240.0, 0.0));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });
}
