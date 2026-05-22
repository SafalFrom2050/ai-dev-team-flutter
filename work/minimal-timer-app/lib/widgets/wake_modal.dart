import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/haptic_service.dart';

class WakeModal extends StatelessWidget {
  final Function(String) onRatingSelected;

  const WakeModal({super.key, required this.onRatingSelected});

  static Future<void> show(
    BuildContext context, {
    required Function(String) onRatingSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF060913).withValues(alpha: 0.7),
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return WakeModal(onRatingSelected: onRatingSelected);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final haptic = HapticService();

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(36.0),
        topRight: Radius.circular(36.0),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(
              0xFF0B0F19,
            ).withValues(alpha: 0.85), // Deep Obsidian glass
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(36.0),
              topRight: Radius.circular(36.0),
            ),
            border: Border.all(
              color: const Color(0xFFE8D3FF).withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 28.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Accent handle bar
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A3342).withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title Text
                  Text(
                    'GOOD MORNING',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFFFD369), // Starry Gold
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'How was your rest?',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFF8FAFC),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rate your wake quality to optimize future cycles.',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRatingChip(
                        emoji: '😔',
                        label: 'Restless',
                        ratingKey: 'restless',
                        haptic: haptic,
                        context: context,
                      ),
                      _buildRatingChip(
                        emoji: '😐',
                        label: 'Neutral',
                        ratingKey: 'neutral',
                        haptic: haptic,
                        context: context,
                      ),
                      _buildRatingChip(
                        emoji: '😌',
                        label: 'Restored',
                        ratingKey: 'restored',
                        haptic: haptic,
                        context: context,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingChip({
    required String emoji,
    required String label,
    required String ratingKey,
    required HapticService haptic,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        haptic.mediumImpact();
        Navigator.of(context).pop();
        onRatingSelected(ratingKey);
      },
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(
                0xFF161B26,
              ).withValues(alpha: 0.5), // Slate Obsidian
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFD369).withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF060913).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFF8FAFC),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
