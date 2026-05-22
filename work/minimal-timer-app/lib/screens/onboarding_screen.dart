import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/alarm_service.dart';
import '../services/haptic_service.dart';
import '../utils/test_helper.dart';
import '../widgets/spring_scale_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onStartTiming});

  final VoidCallback onStartTiming;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    if (!isTesting) {
      _pulseController.repeat(reverse: true);
    }

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    HapticService().selectionTick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Deep Obsidian backdrop
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              // App Branding Header
              Text(
                'Minimal Timer',
                key: const Key('onboarding-header-title'),
                style: GoogleFonts.outfit(
                  color: const Color(0xFFF8FAFC),
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Simple. Silent. Persistent.',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 24),

              // Interactive Multistep Slider
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildDialIntroStep(),
                    _buildSoundscapeStep(),
                    _buildProtectionStep(),
                  ],
                ),
              ),

              // Horizontal indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => _buildIndicatorDot(index),
                ),
              ),
              const SizedBox(height: 28),

              // Core Spring Action Button
              SpringScaleButton(
                onTap: () {
                  HapticService().lightTap();
                  widget.onStartTiming();
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00F5D4), // vibrant Electric Mint
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F5D4).withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Start Timing',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(
                        0xFF0B0F19,
                      ), // Deep obsidian contrasting text
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                "You can see these tips again by tapping the '?' on the timer screen.",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8).withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // Dot Stepper Widget
  Widget _buildIndicatorDot(int index) {
    final bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00F5D4) : const Color(0xFF2A3342),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // Slide 1: Tactile Control Dial Intro
  Widget _buildDialIntroStep() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing dial graphic
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2A3342), width: 4),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glowing Mint ring
                    Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF00F5D4).withValues(alpha: 0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF00F5D4,
                            ).withValues(alpha: 0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    // Monospace numerical text
                    Text(
                      '25:00',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFF8FAFC),
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -1,
                      ),
                    ),
                    // Glowing rotating tick dot
                    Positioned(
                      top: 10,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00F5D4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'Tactile Control',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFF8FAFC),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Sculpt your focus duration by dragging your finger smoothly along the dial perimeter, snapping to precise minutes with spring physics.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Slide 2: Interactive Sound preview and settings
  Widget _buildSoundscapeStep() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Bell icon breathing inside glowing card
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2530),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0x0DFFFFFF), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.blur_on,
                size: 56,
                color: Color(0xFF00F5D4),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            'Organic Soundscapes',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFF8FAFC),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Atmosphere preview: Tap sound chips to test our high-fidelity chimes and bells, built to wake you gently and maintain focus peace.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF94A3B8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Sound Chip Selectors
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildOnboardingSoundChip('chime', 'Zen Bowl'),
              _buildOnboardingSoundChip('echo', 'Classic Bell'),
              _buildOnboardingSoundChip('beep', 'Synth Beep'),
            ],
          ),
        ],
      ),
    );
  }

  // Onboarding sound preview chip
  Widget _buildOnboardingSoundChip(String soundId, String label) {
    return SpringScaleButton(
      onTap: () async {
        HapticService().lightTap();
        await AlarmService().playPreview(soundId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2530),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00F5D4).withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF00F5D4),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Slide 3: Keep Focus Alive (Notification/Background permission info)
  Widget _buildProtectionStep() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Background execution badge
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E2530),
                border: Border.all(color: const Color(0xFF2A3342), width: 1.5),
              ),
              child: const Icon(
                Icons.security,
                size: 48,
                color: Color(0xFF00F5D4),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'Stays with you',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFF8FAFC),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Timer keeps running in the background and sends a notification when done. Our custom background engine protects your flow. Even when your phone sleeps, your timer stays alive and triggers alarm chimes.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
