import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/background_timer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(TimerApp(onboardingComplete: onboardingComplete, prefs: prefs));
}

class TimerApp extends StatelessWidget {
  const TimerApp({
    super.key,
    this.timerService,
    required this.onboardingComplete,
    required this.prefs,
  });

  final BackgroundTimerService? timerService;
  final bool onboardingComplete;
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minimal Timer',
      debugShowCheckedModeBanner: false,
      // System Theme: Enforced Dark Mode Only
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(
          0xFF0B0F19,
        ), // Deep Obsidian backdrop
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F5D4), // Electric Mint
          surface: Color(0xFF1E2530), // Slate Container
          outline: Color(0xFF2A3342), // Slate Muted
          onSurface: Color(0xFFF8FAFC), // Text Primary
          onSurfaceVariant: Color(0xFF94A3B8), // Text Secondary
        ),
        useMaterial3: true,
      ),
      initialRoute: onboardingComplete ? '/' : '/onboarding',
      onGenerateRoute: (settings) {
        if (settings.name == '/onboarding') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                OnboardingScreen(
                  onStartTiming: () async {
                    await prefs.setBool('onboarding_complete', true);
                    if (context.mounted) {
                      Navigator.of(context).pushReplacementNamed('/');
                    }
                  },
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        }

        if (settings.name == '/') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MainNavigationScreen(timerService: timerService),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        }

        return null;
      },
    );
  }
}
