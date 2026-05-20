import 'package:flutter/material.dart';

/// A snappy custom spring-scale gesture detector that provides a physics-based
/// tactile bounce on tap, matching the Fluent Minimal design language spec.
class SpringScaleButton extends StatefulWidget {
  const SpringScaleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<SpringScaleButton> createState() => _SpringScaleButtonState();
}

class _SpringScaleButtonState extends State<SpringScaleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      upperBound: 1.0,
      lowerBound: 0.92,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    _controller.animateTo(
      0.92,
      duration: const Duration(milliseconds: 60),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget.enabled) return;
    _triggerSpringBack();
    widget.onTap();
  }

  void _handleTapCancel() {
    if (!widget.enabled) return;
    _triggerSpringBack();
  }

  void _triggerSpringBack() {
    _controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.elasticOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(scale: _controller, child: widget.child),
    );
  }
}
