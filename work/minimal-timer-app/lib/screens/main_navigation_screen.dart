import 'package:flutter/material.dart';

import '../controllers/timer_controller.dart';
import '../controllers/sleep_controller.dart';
import '../services/background_timer_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'alarm_tab.dart';
import 'timer_tab.dart';
import 'sleep_tab_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.timerService});

  final BackgroundTimerService? timerService;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // Default to TimerTab as landing page
  late final TimerController _controller;
  late final SleepController _sleepController;

  @override
  void initState() {
    super.initState();
    _controller = TimerController(timerService: widget.timerService);
    _controller.initialize();
    _sleepController = SleepController();
    _sleepController.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _sleepController.dispose();
    super.dispose();
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
                SleepTabScreen(controller: _sleepController),
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
