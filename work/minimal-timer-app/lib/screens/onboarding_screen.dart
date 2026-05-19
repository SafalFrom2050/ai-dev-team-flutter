import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, required this.onStartTiming});

  final VoidCallback onStartTiming;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section
                  Text(
                    'Minimal Timer',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Simple. Silent. Persistent.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 48),

                  // Feature Section
                  const _FeatureRow(
                    icon: Icons.notifications_active_outlined,
                    title: 'Stays with you',
                    description:
                        'Timer keeps running in the background and sends a notification when done.',
                    semanticsLabel: 'Background notification indicator',
                  ),
                  const SizedBox(height: 24),
                  const _FeatureRow(
                    icon: Icons.touch_app_outlined,
                    title: 'Fast Adjust',
                    description:
                        'Tap the preset chips or use the +/- buttons to change duration instantly.',
                    semanticsLabel: 'Gesture control tutorial',
                  ),
                  const SizedBox(height: 24),
                  const _FeatureRow(
                    icon: Icons.nights_stay_outlined,
                    title: 'Silence is Golden',
                    description: 'No accounts, no ads, no noise. Just focus.',
                    semanticsLabel: 'Privacy and silence guarantee',
                  ),
                  const SizedBox(height: 48),

                  // Action Section
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onStartTiming,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Start Timing'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "You can see these tips again by tapping the '?' on the timer screen.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
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
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.semanticsLabel,
  });

  final IconData icon;
  final String title;
  final String description;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: semanticsLabel,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
