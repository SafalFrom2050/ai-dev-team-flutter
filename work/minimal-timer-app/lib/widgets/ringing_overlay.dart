import 'package:flutter/material.dart';

class RingingOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const RingingOverlay({super.key, required this.onDismiss});

  @override
  State<RingingOverlay> createState() => _RingingOverlayState();
}

class _RingingOverlayState extends State<RingingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  final FocusNode _dismissFocusNode = FocusNode();
  double _dragDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Autofocus on entry for accessibility/screen readers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dismissFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dismissFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      label: "Timer completed. Time's Up! Tap bottom button to dismiss.",
      child: Scaffold(
        backgroundColor: Colors.black.withValues(
          alpha: 0.6,
        ), // Dimmed background
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTabletOrDesktop = constraints.maxWidth > 600;

              final content = Container(
                width: isTabletOrDesktop ? 520 : double.infinity,
                height: isTabletOrDesktop ? 600 : double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF2F6F63),
                  borderRadius: isTabletOrDesktop
                      ? BorderRadius.circular(24)
                      : BorderRadius.zero,
                  boxShadow: isTabletOrDesktop
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 20),
                        // Central Bell Icon with Pulsing Animation
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(24),
                                    child: const Icon(
                                      Icons.notifications_active,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                const Text(
                                  "Time's Up!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Your timer has completed successfully.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Massive Dismiss button in the lower third
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 80,
                            child: ElevatedButton(
                              focusNode: _dismissFocusNode,
                              key: const Key('ringing-dismiss-button'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2F6F63),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                elevation: 4,
                              ),
                              onPressed: widget.onDismiss,
                              child: const Text(
                                "DISMISS",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              return GestureDetector(
                onVerticalDragUpdate: (details) {
                  _dragDistance += details.delta.dy;
                },
                onVerticalDragEnd: (details) {
                  if (_dragDistance < -80.0) {
                    widget.onDismiss();
                  }
                  _dragDistance = 0.0;
                },
                child: content,
              );
            },
          ),
        ),
      ),
    );
  }
}
