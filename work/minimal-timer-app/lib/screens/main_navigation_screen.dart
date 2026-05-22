import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/timer_controller.dart';
import '../services/background_timer_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'alarm_tab.dart';
import 'timer_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.timerService});

  final BackgroundTimerService? timerService;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // Default to TimerTab as landing page
  late final TimerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TimerController(timerService: widget.timerService);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSleepTrackerPlaceholder() {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19), // Deep Obsidian backdrop
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Stylized Glowing Sleep Moon
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F5D4).withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00F5D4).withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F5D4).withValues(alpha: 0.1),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.nights_stay_outlined,
                      size: 44,
                      color: Color(0xFF00F5D4),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Sleep Tracker',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFF8FAFC),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Phase 3: Mascot & Tracker Integration',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Interactive Dashed Container for Junior Developer Invitation
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2530).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF2A3342),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF00F5D4),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'DEVELOPER PLAYGROUND',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF00F5D4),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hey Junior Dev! 👋',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFF8FAFC),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'This premium visual frame is ready for your creative touch! Insert the sleepy mascot avatar, sleep tracking charts, and sleep session triggers right here in Phase 3.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF94A3B8),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B0F19),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2A3342),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            'work/minimal-timer-app/lib/screens/sleep_tab.dart',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Stack(
        children: [
          // 1. IndexedStack to preserve states of our screen tabs
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildSleepTrackerPlaceholder(),
                TimerTab(controller: _controller),
                AlarmTab(controller: _controller),
              ],
            ),
          ),

          // 2. Custom Glassmorphic Floating Bottom Nav Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
