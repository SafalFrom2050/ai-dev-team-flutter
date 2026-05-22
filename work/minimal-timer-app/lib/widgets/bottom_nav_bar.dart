import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/haptic_service.dart';
import 'spring_scale_button.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const int totalTabs = 3;

    final tabs = [
      {
        'icon': Icons.bedtime_outlined,
        'activeIcon': Icons.bedtime,
        'label': 'Sleep',
      },
      {
        'icon': Icons.timer_outlined,
        'activeIcon': Icons.timer,
        'label': 'Timer',
      },
      {
        'icon': Icons.graphic_eq_outlined,
        'activeIcon': Icons.graphic_eq,
        'label': 'Studio',
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.06),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: Stack(
            children: [
              // 1. Sliding Neon Active Pill Backing
              AnimatedAlign(
                alignment: Alignment(
                  -1.0 + (currentIndex * 2.0 / (totalTabs - 1)),
                  0.0,
                ),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: FractionallySizedBox(
                  widthFactor: 1.0 / totalTabs,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F5D4).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF00F5D4).withValues(alpha: 0.4),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF00F5D4,
                          ).withValues(alpha: 0.15),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Interactive Navigation Buttons
              Row(
                children: List.generate(totalTabs, (index) {
                  final tab = tabs[index];
                  final isSelected = index == currentIndex;
                  final icon = isSelected
                      ? tab['activeIcon'] as IconData
                      : tab['icon'] as IconData;
                  final label = tab['label'] as String;

                  return Expanded(
                    child: SpringScaleButton(
                      enabled: true,
                      onTap: () {
                        if (index != currentIndex) {
                          // Play system sound & custom double-beat haptic trigger
                          SystemSound.play(SystemSoundType.click);
                          HapticService().doubleBeat();
                          onTap(index);
                        }
                      },
                      child: Container(
                        height: double.infinity,
                        alignment: Alignment.center,
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              icon,
                              color: isSelected
                                  ? const Color(0xFF00F5D4)
                                  : const Color(0xFF94A3B8),
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFFF8FAFC)
                                    : const Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
