# Technical Plan: Timer Onboarding

## Overview

The onboarding feature requires tracking whether a user has seen the welcome flow and providing a smooth transition to the main timer interface. We will implement this using `shared_preferences` for persistence and a simple named-route system for navigation.

## Architecture

### 1. Persistence Layer
We will add `shared_preferences` to manage the `onboarding_complete` flag.
- **Key**: `onboarding_complete` (boolean)
- **Default**: `false`

### 2. Navigation & Routing
We will refactor `TimerApp` to use named routes to support navigation from Onboarding to Timer and back.
- **`/`**: TimerScreen (Home)
- **`/onboarding`**: OnboardingScreen

**First-Launch Logic**:
The `main()` function will be updated to be asynchronous. It will:
1. Initialize `SharedPreferences`.
2. Check the `onboarding_complete` flag.
3. Pass this flag to the `TimerApp` widget to determine the `initialRoute`.

### 3. Transition Animation
To achieve the requested cross-fade and "pop" effect:
- Use `PageRouteBuilder` for the navigation from `/onboarding` to `/`.
- Implement a `FadeTransition` combined with a `ScaleTransition` for the timer dial.

## Work Slices

### Slice 1: Infrastructure & State
- Add `shared_preferences` to `pubspec.yaml`.
- Update `main.dart` to support named routes and async initialization.
- Create a simple `OnboardingService` (or handle directly in `main`) to get/set the completion flag.

### Slice 2: UI Implementation
- Create `lib/screens/onboarding_screen.dart`.
- Implement `OnboardingScreen` with the Material 3 "Welcome" layout.
- Create a reusable `FeatureRow` widget.
- Add the `?` (Help) button to `TimerScreen` in `lib/main.dart`.

### Slice 3: Transitions & Wiring
- Implement the cross-fade navigation logic.
- Wire the "Start Timing" button to save the state and navigate.
- Wire the "?" button to navigate back to onboarding.

### Slice 4: Verification
- Add widget tests for `OnboardingScreen`.
- Add a test case to verify that `onboarding_complete` is set correctly.
- Verify responsive layout on mobile and tablet.

## Risks & Mitigations
- **Async Initialization Delay**: Brief splash/loading state might be needed if `SharedPreferences` is slow. Mitigation: Standard `FutureBuilder` or simple conditional `home` in `MaterialApp`.
- **Navigation Complexity**: Since we are moving from a single-screen app to a multi-screen app, we must ensure the "Back" button behavior on Android is intuitive (e.g., exiting the app from the Timer screen instead of going back to onboarding if already completed).
