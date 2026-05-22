import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/haptic_service.dart';

class SwipeToWakeSlider extends StatefulWidget {
  final VoidCallback onComplete;

  const SwipeToWakeSlider({super.key, required this.onComplete});

  @override
  State<SwipeToWakeSlider> createState() => _SwipeToWakeSliderState();
}

class _SwipeToWakeSliderState extends State<SwipeToWakeSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapController;
  late final HapticService _hapticService;

  double _dragOffset = 0.0;
  static const double _maxOffset = 224.0; // 280 width - 56 puck size
  static const double _threshold = 179.2; // 80% of 224.0

  @override
  void initState() {
    super.initState();
    _hapticService = HapticService();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _snapController.addListener(() {
      setState(() {
        // Linearly interpolate back to 0.0
        _dragOffset = _dragOffset * (1.0 - _snapController.value);
      });
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_snapController.isAnimating) return;
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, _maxOffset);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_snapController.isAnimating) return;

    if (_dragOffset >= _threshold) {
      // Animate remaining to the end and fire completion callback
      final remaining = _maxOffset - _dragOffset;
      if (remaining > 0) {
        setState(() {
          _dragOffset = _maxOffset;
        });
      }
      _hapticService.mediumImpact();
      widget.onComplete();
    } else {
      // Elastic snap back to 0.0
      _snapController.forward(from: 0.0);
      _hapticService.selectionTick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textOpacity = (1.0 - (_dragOffset / _threshold)).clamp(0.0, 1.0);

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 280.0,
            height: 64.0,
            decoration: BoxDecoration(
              color: const Color(
                0xFF161B26,
              ).withValues(alpha: 0.5), // Slate Obsidian glassmorphic
              borderRadius: BorderRadius.circular(32.0),
              border: Border.all(
                color: const Color(
                  0xFFE8D3FF,
                ).withValues(alpha: 0.15), // Soft Lavender highlight border
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF060913).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // 1. Sliding Faint Helper Text (fades out as puck moves)
                Positioned(
                  left: 72,
                  right: 16,
                  child: Opacity(
                    opacity: textOpacity,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SLIDE TO WAKE',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(
                                0xFFE8D3FF,
                              ).withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Color(0xFFFFD369),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Drag Puck
                Positioned(
                  left: 4.0 + _dragOffset,
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onHorizontalDragUpdate,
                    onHorizontalDragEnd: _onHorizontalDragEnd,
                    child: Container(
                      width: 56.0,
                      height: 56.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD369), // Starry Gold puck
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFFD369,
                            ).withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chevron_right,
                          color: Color(
                            0xFF060913,
                          ), // Midnight Sapphire dark contrast
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
