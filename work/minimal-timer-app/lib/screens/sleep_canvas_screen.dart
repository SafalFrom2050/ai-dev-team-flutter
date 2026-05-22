import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/sleep_controller.dart';
import '../widgets/nebula_mascot.dart';
import '../widgets/swipe_slider.dart';
import '../widgets/wake_modal.dart';
import '../services/haptic_service.dart';

class SleepCanvasScreen extends StatefulWidget {
  final SleepController controller;

  const SleepCanvasScreen({super.key, required this.controller});

  @override
  State<SleepCanvasScreen> createState() => _SleepCanvasScreenState();
}

class _SleepCanvasScreenState extends State<SleepCanvasScreen>
    with TickerProviderStateMixin {
  late final AnimationController _holdController;
  late final AnimationController _pulseController;
  late final HapticService _hapticService;

  late DateTime _currentTime;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _hapticService = HapticService();
    _currentTime = DateTime.now();

    // 2.0s Hold-to-exit controller
    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleHoldComplete();
      }
    });

    // Ringing pulsating background controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Keep updating current time every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    // Check ringing state
    _updateControllers();
  }

  @override
  void didUpdateWidget(covariant SleepCanvasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateControllers();
  }

  void _updateControllers() {
    if (widget.controller.isAlarmRinging) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
      _holdController.reset();
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _holdController.dispose();
    _pulseController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    final min = time.minute.toString().padLeft(2, '0');
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$min $amPm';
  }

  void _handleHoldComplete() {
    _hapticService.heavyImpact();
    widget.controller.cancelSleepEarly();
    _holdController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isRinging = widget.controller.isAlarmRinging;

    return PopScope(
      canPop: false, // Prevent physical back navigation during sleep mode
      child: Scaffold(
        backgroundColor: const Color(0xFF060913),
        body: isRinging ? _buildAlarmRingingUI() : _buildSleepActiveUI(),
      ),
    );
  }

  // --- Sleep Mode Active Screen ---
  Widget _buildSleepActiveUI() {
    return Stack(
      children: [
        // 1. Cozy black-sapphire cosmic gradient background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B0F19), // Deep Obsidian
                  Color(0xFF060913), // Midnight Sapphire
                ],
              ),
            ),
          ),
        ),

        // 2. Cosmic neon orb highlights (Extremely faint ambient aura)
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00FFCC).withValues(alpha: 0.03), // Neon Mint glow
                  blurRadius: 100,
                  spreadRadius: 60,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB39DDB).withValues(alpha: 0.02), // Soft Lavender glow
                  blurRadius: 110,
                  spreadRadius: 70,
                ),
              ],
            ),
          ),
        ),

        // 3. Faint digital clock in Slate Obsidian
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Opacity(
              opacity: 0.35,
              child: Text(
                _formatTime(_currentTime),
                style: GoogleFonts.outfit(
                  color: const Color(0xFF161B26), // Slate Obsidian
                  fontSize: 54,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                ),
              ),
            ),
          ),
        ),

        // 4. Crescent Moon Icon Ambient Deco
        Positioned(
          top: 180,
          left: 0,
          right: 0,
          child: Center(
            child: Icon(
              Icons.nights_stay_outlined,
              size: 40,
              color: const Color(0xFF00FFCC).withValues(alpha: 0.08),
            ),
          ),
        ),

        // 5. Sleeping Mascot Center Screen
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: NebulaMascot(isAwake: false),
          ),
        ),

        // 6. Hold-to-Exit Action at Bottom
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'HOLD BUTTON TO EXIT',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFE8D3FF).withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTapDown: (_) {
                  _hapticService.selectionTick();
                  _holdController.forward();
                },
                onTapUp: (_) {
                  if (_holdController.value < 1.0) {
                    _holdController.reverse();
                  }
                },
                onTapCancel: () {
                  if (_holdController.value < 1.0) {
                    _holdController.reverse();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Faint Background Circle
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B26).withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE8D3FF).withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.power_settings_new,
                          color: Color(0xFFE8D3FF),
                          size: 24,
                        ),
                      ),
                    ),
                    // Clockwise filling ring
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: AnimatedBuilder(
                        animation: _holdController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _HoldRingPainter(
                              progress: _holdController.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Alarm Ringing Mode UI ---
  Widget _buildAlarmRingingUI() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final val = _pulseController.value;

        // Shift between deep indigo/sapphire and deep violet
        final bgGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(
              const Color(0xFF0F0624), // Deep Indigo
              const Color(0xFF3B0B59), // Deep Violet
              val,
            )!,
            Color.lerp(
              const Color(0xFF060913), // Midnight Sapphire
              const Color(0xFF1F0338), // Dark Plum
              val,
            )!,
          ],
        );

        // Mascot jumps vertically in sync with the pulse
        final jumpOffset = 22.0 * math.sin(math.pi * val);

        return Stack(
          children: [
            // 1. Pulsing Gradient Background
            Positioned.fill(
              child: Container(decoration: BoxDecoration(gradient: bgGradient)),
            ),

            // 2. Bold Alarm Header & Ringing Time
            Positioned(
              top: 100,
              left: 24,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated alarm ringing bell icon
                  Transform.rotate(
                    angle:
                        0.15 *
                        math.sin(
                          2 * math.pi * val * 4,
                        ), // fast ringing vibration rotation
                    child: const Icon(
                      Icons.alarm_on,
                      color: Color(0xFFFFD369), // Starry Gold
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'RISE AND SHINE',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFFFD369), // Starry Gold
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(_currentTime),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFF8FAFC),
                      fontSize: 62,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Awake Jumping Mascot
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: Offset(0.0, -jumpOffset.abs()),
                  child: NebulaMascot(isAwake: true),
                ),
              ),
            ),

            // 4. Swipe Slider at Bottom
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwipeToWakeSlider(
                    onComplete: () {
                      _hapticService.heavyImpact();
                      // Show wake modal bottom sheet
                      WakeModal.show(
                        context,
                        onRatingSelected: (rating) {
                          widget.controller.dismissAlarm(rating);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HoldRingPainter extends CustomPainter {
  final double progress;

  _HoldRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF00B4D8) // Soft Teal progress ring
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - paint.strokeWidth) / 2;

    // Draw the full thin track first
    final trackPaint = Paint()
      ..color = const Color(0xFFE8D3FF).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc starting from top (-pi / 2) clockwise
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _HoldRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
