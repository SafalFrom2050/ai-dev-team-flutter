import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/haptic_service.dart';
import '../utils/test_helper.dart';
import 'spring_scale_button.dart';

class RingingOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final VoidCallback? onRestart;

  const RingingOverlay({super.key, required this.onDismiss, this.onRestart});

  @override
  State<RingingOverlay> createState() => _RingingOverlayState();
}

class _RingingOverlayState extends State<RingingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _radialController;
  late final AnimationController _springController;

  final FocusNode _dismissFocusNode = FocusNode();

  double _dragPosition = 0.0;
  final double _trackWidth = 260.0;
  final double _handleSize = 56.0;

  @override
  void initState() {
    super.initState();

    // Slow breathing animation for the central bell scale
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    if (!isTesting) {
      _pulseController.repeat(reverse: true);
    }

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Continuous radial glow animation
    _radialController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    if (!isTesting) {
      _radialController.repeat(reverse: true);
    }

    // Spring controller for returning slider handle back to 0
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Autofocus for A11y
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dismissFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _radialController.dispose();
    _springController.dispose();
    _dismissFocusNode.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(
        0.0,
        _trackWidth - _handleSize,
      );
    });
    // Trigger lightweight ticking haptics as we drag
    HapticService().selectionTick();
  }

  void _onDragEnd(DragEndDetails details) {
    final double completionRatio = _dragPosition / (_trackWidth - _handleSize);
    if (completionRatio > 0.82) {
      // Completed drag swipe - trigger dismiss
      HapticService().heavyImpact();
      widget.onDismiss();
    } else {
      // Snappy physics spring rebound back to starting coordinates
      final double startVal = _dragPosition;
      _springController.reset();

      final Animation<double> springAnim =
          Tween<double>(begin: startVal, end: 0.0).animate(
            CurvedAnimation(
              parent: _springController,
              curve: const ElasticOutCurve(0.7), // Snappy spring rebound curve
            ),
          );

      springAnim.addListener(() {
        setState(() {
          _dragPosition = springAnim.value;
        });
      });

      _springController.forward();
      HapticService().lightTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      label:
          "Timer completed! Focus session done. Swipe slider or tap dismiss button to exit.",
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // transparent to let acrylic show through
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Acrylic Backdrop Filter: Frosted glass overlaid on dark base
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                  child: Container(
                    color: const Color(0xFF0B0F19).withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),

            // Continuous breathing radial glows
            AnimatedBuilder(
              animation: _radialController,
              builder: (context, child) {
                final double opacity = 0.05 + (_radialController.value * 0.1);
                return Positioned(
                  child: Container(
                    height: 500,
                    width: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00F5D4).withValues(alpha: opacity),
                          const Color(0xFF00B4D8).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Layout Container
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTabletOrDesktop = constraints.maxWidth > 600;

                  return Container(
                    width: isTabletOrDesktop ? 500 : double.infinity,
                    height: isTabletOrDesktop ? 620 : double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 48,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B26).withValues(alpha: 0.4),
                      borderRadius: isTabletOrDesktop
                          ? BorderRadius.circular(32)
                          : BorderRadius.zero,
                      border: isTabletOrDesktop
                          ? Border.all(
                              color: const Color(0x0DFFFFFF),
                              width: 1.2,
                            )
                          : null,
                      boxShadow: isTabletOrDesktop
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ]
                          : null,
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top Header / Subtitle
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x1F00F5D4),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00F5D4,
                                    ).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'COMPLETE',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF00F5D4),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Central glowing bell icon & large Outfits countdown
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: Container(
                                  height: 120,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF1E2530),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF00F5D4,
                                      ).withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF00F5D4,
                                        ).withValues(alpha: 0.2),
                                        blurRadius: 24,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(24),
                                  child: const Icon(
                                    Icons.notifications_active_outlined,
                                    size: 64,
                                    color: Color(0xFF00F5D4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                              Text(
                                "Time's Up!",
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFF8FAFC),
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Your focus block has finished successfully.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "00:00",
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF00F5D4),
                                  fontSize: 54,
                                  fontWeight: FontWeight.w600,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Swipe Slider & Secondary Restart Row
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Secondary springy restart button
                              if (widget.onRestart != null) ...[
                                SpringScaleButton(
                                  onTap: () {
                                    HapticService().lightTap();
                                    widget.onRestart!();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E2530),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0x0DFFFFFF),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.replay_outlined,
                                          color: Color(0xFF94A3B8),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Restart Session',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: const Color(0xFF94A3B8),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Swipe-to-dismiss Slider Track
                              Container(
                                height: _handleSize + 8,
                                width: _trackWidth,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2530),
                                  borderRadius: BorderRadius.circular(
                                    _handleSize / 2 + 4,
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF2A3342),
                                    width: 1.2,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Track Background Text Hint
                                    Center(
                                      child: Text(
                                        'Swipe to dismiss',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(
                                            0xFF94A3B8,
                                          ).withValues(alpha: 0.5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),

                                    // Slidable glowing handle
                                    Positioned(
                                      left: _dragPosition,
                                      top: 0,
                                      bottom: 0,
                                      child: GestureDetector(
                                        onHorizontalDragUpdate: _onDragUpdate,
                                        onHorizontalDragEnd: _onDragEnd,
                                        child: Semantics(
                                          button: true,
                                          label: "Dismiss alarm",
                                          child: SpringScaleButton(
                                            key: const Key(
                                              'ringing-dismiss-button',
                                            ),
                                            onTap: () {
                                              // Fallback tap trigger for tests & screen-readers
                                              HapticService().heavyImpact();
                                              widget.onDismiss();
                                            },
                                            child: Container(
                                              height: _handleSize,
                                              width: _handleSize,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00F5D4),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF00F5D4,
                                                    ).withValues(alpha: 0.4),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.chevron_right,
                                                color: Color(0xFF0B0F19),
                                                size: 32,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
