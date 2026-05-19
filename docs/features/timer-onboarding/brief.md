# Feature Brief: Timer Onboarding

## Problem

While the app is designed for "zero-config" speed, recent additions like background execution and minimal gesture-based duration adjustments (taps/drags) may not be immediately obvious to new users. 

Users need a high-speed "sanity check" on first launch to:
1. Understand that the timer persists in the background (trust).
2. Discover how to change durations quickly without a complex settings menu.
3. Confirm the app's "no-noise" philosophy.

## User Flow

1. **First Launch**: App detects no `onboarding_complete` flag.
2. **Welcome Screen**: A single, elegant screen with three core value points:
   - "Stays with you": Explain background behavior.
   - "Fast Adjust": Visual hint on how to change time (e.g., tap or swipe).
   - "Silence is Golden": Reiterate no accounts, no noise.
3. **Dismissal**: User taps "Start Timing".
4. **Transition**: Smooth fade into the main Timer screen.

## Persistence

- **One-Time Show**: Onboarding is stored in local persistence and shown only once.
- **Manual Re-access**: A subtle "info" or "?" icon on the main screen allows users to re-trigger the onboarding if they forget the gestures.

## Acceptance Criteria

- [ ] Onboarding appears exactly once on first install/clear-cache.
- [ ] Onboarding is skippable with a single tap.
- [ ] Onboarding clearly illustrates the "background timer" notification behavior.
- [ ] Main Timer screen remains accessible and focused after onboarding.
- [ ] Onboarding state is verified by widget/integration tests.
