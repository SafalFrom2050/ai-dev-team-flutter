import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NebulaMascot extends StatefulWidget {
  final bool isAwake;

  const NebulaMascot({super.key, required this.isAwake});

  @override
  State<NebulaMascot> createState() => _NebulaMascotState();
}

class _ZParticle {
  final DateTime spawnTime;
  final double initialX;
  final double initialY;
  final double speed;
  final double swayAmp;
  final double swayFreq;

  _ZParticle({
    required this.spawnTime,
    required this.initialX,
    required this.initialY,
    required this.speed,
    required this.swayAmp,
    required this.swayFreq,
  });
}

class _NebulaMascotState extends State<NebulaMascot>
    with TickerProviderStateMixin {
  late final AnimationController _breathController;
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnimation;

  final List<_ZParticle> _particles = [];
  Timer? _particleTimer;

  @override
  void initState() {
    super.initState();

    // 0.8Hz Breathing Cycle -> 1.25 seconds per full cycle
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();

    // Tap scale bounce -> rebound over 600ms
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Bounce animation goes from 0.0 to 1.0 using elasticOut to settle back to 1.0 (deviation 0.0)
    _bounceAnimation = CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    );

    // Particle spawning timer: every 2.5 seconds
    _particleTimer = Timer.periodic(const Duration(milliseconds: 2500), (
      timer,
    ) {
      if (!widget.isAwake) {
        _spawnParticle();
      }
    });

    // Spawn first particle immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isAwake) {
        _spawnParticle();
      }
    });
  }

  void _spawnParticle() {
    if (!mounted) return;
    setState(() {
      final now = DateTime.now();
      _particles.add(
        _ZParticle(
          spawnTime: now,
          initialX: 35.0,
          initialY: 5.0,
          speed: 35.0 + (math.Random().nextDouble() * 15.0), // 35-50 px/sec
          swayAmp: 8.0 + (math.Random().nextDouble() * 6.0), // 8-14 px sway
          swayFreq: 2.0 + (math.Random().nextDouble() * 1.5),
        ),
      );
    });
  }

  void _handleTap() {
    if (_bounceController.isAnimating) return;
    // Instantly set to squished state by running from 0.0
    _bounceController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _bounceController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onDoubleTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_breathController, _bounceAnimation]),
        builder: (context, child) {
          // Breathing scale calculations
          // scaleY = 1.0 + (0.04 * sin(2 * pi * t / 1.25))
          final breathProgress = _breathController.value;
          final scaleYBreath =
              1.0 + (0.04 * math.sin(2 * math.pi * breathProgress));

          // Tap bounce scale calculations
          // Tapped squishes to scaleX: 1.1, scaleY: 0.9 instantly, rebounds to 1.0
          // _bounceAnimation.value goes from 0.0 (tapped) to 1.0 (settled)
          final bounceDeviation = 1.0 - _bounceAnimation.value;
          final scaleX = 1.0 + (0.10 * bounceDeviation);
          final scaleY = (scaleYBreath - (0.10 * bounceDeviation)).clamp(
            0.5,
            1.5,
          );

          // Sway rotation calculation for cap tip pom-pom
          // rotation = 4.0 * cos(2 * pi * t / 1.25) (degrees)
          final capRotationDegrees =
              4.0 * math.cos(2 * math.pi * breathProgress);
          final capRotationRad = capRotationDegrees * math.pi / 180.0;

          // Filter old particles
          final now = DateTime.now();
          _particles.removeWhere(
            (p) => now.difference(p.spawnTime).inMilliseconds > 3000,
          );

          return Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
            child: SizedBox(
              width: 280,
              height: 280,
              child: CustomPaint(
                painter: _NebulaPainter(
                  isAwake: widget.isAwake,
                  capRotationRad: capRotationRad,
                  particles: List.from(_particles),
                  now: now,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NebulaPainter extends CustomPainter {
  final bool isAwake;
  final double capRotationRad;
  final List<_ZParticle> particles;
  final DateTime now;

  _NebulaPainter({
    required this.isAwake,
    required this.capRotationRad,
    required this.particles,
    required this.now,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // --- Paint Definitions ---
    final bodyPaint = Paint()
      ..color =
          const Color(0xFF161B26) // Slate Obsidian body
      ..style = PaintingStyle.fill;

    final innerEarPaint = Paint()
      ..color =
          const Color(0xFFE8D3FF) // Faded Lavender inner ear
      ..style = PaintingStyle.fill;

    final capPaint = Paint()
      ..color =
          const Color(0xFFB39DDB) // Soft Lavender cap body
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;

    final goldPaint = Paint()
      ..color =
          const Color(0xFFFFD369) // Starry Gold
      ..style = PaintingStyle.fill;

    final goldStrokePaint = Paint()
      ..color = const Color(0xFFFFD369)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final blushPaint = Paint()
      ..color = const Color(0xFFE8D3FF).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    // --- 1. Draw Torso/Body (Pivots from Alignment.bottomCenter) ---
    final bodyPath = Path();
    bodyPath.moveTo(center.dx - 60, size.height);
    bodyPath.quadraticBezierTo(
      center.dx,
      center.dy + 40,
      center.dx + 60,
      size.height,
    );
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // --- 2. Draw Ears ---
    // Outer Left Ear
    final leftEarPath = Path()
      ..moveTo(center.dx - 70, center.dy - 25)
      ..lineTo(center.dx - 80, center.dy - 85)
      ..lineTo(center.dx - 30, center.dy - 55)
      ..close();
    canvas.drawPath(leftEarPath, bodyPaint);

    // Inner Left Ear
    final leftInnerEarPath = Path()
      ..moveTo(center.dx - 66, center.dy - 32)
      ..lineTo(center.dx - 74, center.dy - 77)
      ..lineTo(center.dx - 36, center.dy - 52)
      ..close();
    canvas.drawPath(leftInnerEarPath, innerEarPaint);

    // Outer Right Ear
    final rightEarPath = Path()
      ..moveTo(center.dx + 70, center.dy - 25)
      ..lineTo(center.dx + 80, center.dy - 85)
      ..lineTo(center.dx + 30, center.dy - 55)
      ..close();
    canvas.drawPath(rightEarPath, bodyPaint);

    // Inner Right Ear
    final rightInnerEarPath = Path()
      ..moveTo(center.dx + 66, center.dy - 32)
      ..lineTo(center.dx + 74, center.dy - 77)
      ..lineTo(center.dx + 36, center.dy - 52)
      ..close();
    canvas.drawPath(rightInnerEarPath, innerEarPaint);

    // --- 3. Draw Head (Squished Oval) ---
    // Oval rect: center is at center, width is 150, height is 115
    final headRect = Rect.fromCenter(center: center, width: 154, height: 118);
    canvas.drawOval(headRect, bodyPaint);

    // --- 4. Draw Cute Blush ---
    // Soft blush under left/right eyes
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 40, center.dy + 15),
        width: 18,
        height: 10,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 40, center.dy + 15),
        width: 18,
        height: 10,
      ),
      blushPaint,
    );

    // --- 5. Draw Cute Nightcap (Swaying in sync) ---
    // Nightcap trim base is on top of head. We'll anchor at (center.dx - 15, center.dy - 50).
    final capBaseX = center.dx - 10;
    final capBaseY = center.dy - 50;

    canvas.save();
    canvas.translate(capBaseX, capBaseY);
    canvas.rotate(capRotationRad); // Sway rotation anchored at base

    // Draw the fluffy cap trim band at base (using a rounded rect)
    final trimRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-35, -8, 70, 16),
      const Radius.circular(8),
    );
    canvas.drawRRect(trimRect, whitePaint);

    // Draw cap body (curving and draping to the side)
    final capPath = Path();
    capPath.moveTo(-30, -8);
    // Left edge arching up and to the right
    capPath.cubicTo(-20, -65, 45, -55, 65, -30);
    // Fluffy pom-pom attachment point
    capPath.lineTo(75, -28);
    // Right edge draping down and back to base
    capPath.cubicTo(50, -45, 10, -35, 30, -8);
    capPath.close();
    canvas.drawPath(capPath, capPaint);

    // Draw pom-pom ball at the tip
    canvas.drawCircle(const Offset(75, -28), 12, whitePaint);

    canvas.restore();

    // --- 6. Draw Face (Eyelids / Eyes & Mouth) ---
    if (!isAwake) {
      // Sleeping State: Closed curved golden eyelids curving downwards (u-shape)
      // Left eye arc
      final leftEyeRect = Rect.fromCenter(
        center: Offset(center.dx - 32, center.dy - 4),
        width: 22,
        height: 16,
      );
      canvas.drawArc(
        leftEyeRect,
        0, // Start angle (0 radians = right side)
        math.pi, // Sweep angle (pi radians = semi-circle going down)
        false,
        goldStrokePaint,
      );

      // Right eye arc
      final rightEyeRect = Rect.fromCenter(
        center: Offset(center.dx + 32, center.dy - 4),
        width: 22,
        height: 16,
      );
      canvas.drawArc(rightEyeRect, 0, math.pi, false, goldStrokePaint);

      // Tiny cozy curved mouth (sleeping 'w' shape)
      final mouthPath = Path();
      // Left curve
      mouthPath.moveTo(center.dx - 8, center.dy + 12);
      mouthPath.quadraticBezierTo(
        center.dx - 4,
        center.dy + 16,
        center.dx,
        center.dy + 12,
      );
      // Right curve
      mouthPath.quadraticBezierTo(
        center.dx + 4,
        center.dy + 16,
        center.dx + 8,
        center.dy + 12,
      );
      final mouthStroke = Paint()
        ..color = const Color(0xFFFFD369).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(mouthPath, mouthStroke);
    } else {
      // Awake/Ringing State: Perfect vector 5-pointed gold stars for eyes
      _drawStar(canvas, Offset(center.dx - 32, center.dy - 6), 14, goldPaint);
      _drawStar(canvas, Offset(center.dx + 32, center.dy - 6), 14, goldPaint);

      // Excited open mouth (little circle 'O' or happy curve)
      final mouthPaint = Paint()
        ..color = const Color(0xFFFFD369)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(center.dx, center.dy + 16), 7, mouthPaint);
    }

    // --- 7. Draw Whisker details ---
    // Left Whiskers
    canvas.drawLine(
      Offset(center.dx - 65, center.dy + 8),
      Offset(center.dx - 85, center.dy + 5),
      goldStrokePaint..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(center.dx - 65, center.dy + 14),
      Offset(center.dx - 87, center.dy + 16),
      goldStrokePaint,
    );

    // Right Whiskers
    canvas.drawLine(
      Offset(center.dx + 65, center.dy + 8),
      Offset(center.dx + 85, center.dy + 5),
      goldStrokePaint,
    );
    canvas.drawLine(
      Offset(center.dx + 65, center.dy + 14),
      Offset(center.dx + 87, center.dy + 16),
      goldStrokePaint,
    );

    // --- 8. Draw "zZz" Particle Overlays (Sleeping state only) ---
    if (!isAwake) {
      for (final p in particles) {
        final dt = now.difference(p.spawnTime).inMilliseconds / 1000.0;
        if (dt < 0 || dt > 3.0) continue;

        // Drift calculations
        final y = p.initialY - (p.speed * dt);
        final x =
            p.initialX + (18.0 * dt) + (p.swayAmp * math.sin(p.swayFreq * dt));
        final opacity = (1.0 - (dt / 3.0)).clamp(0.0, 1.0);
        final fontSize = 12.0 + (8.0 * (dt / 3.0));

        final textPainter = TextPainter(
          text: TextSpan(
            text: 'z',
            style: GoogleFonts.outfit(
              color: const Color(0xFFFFD369).withValues(alpha: opacity),
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        // Paint the 'z' particle centered on the offset
        textPainter.paint(
          canvas,
          center +
              Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }
  }

  // Helper method to draw a perfect 5-pointed star
  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const double pi = 3.1415926535897932;
    const double doublePi = 2 * pi;

    for (int i = 0; i < 5; i++) {
      // Outer vertex angle
      double angle = -pi / 2 + (i * doublePi / 5);
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Inner vertex angle
      double innerAngle = angle + pi / 5;
      double ix = center.dx + (radius * 0.40) * math.cos(innerAngle);
      double iy = center.dy + (radius * 0.40) * math.sin(innerAngle);
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NebulaPainter oldDelegate) {
    return oldDelegate.isAwake != isAwake ||
        oldDelegate.capRotationRad != capRotationRad ||
        oldDelegate.particles.length != particles.length ||
        oldDelegate.now != now;
  }
}
