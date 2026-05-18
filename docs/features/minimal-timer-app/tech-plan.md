# Technical Plan: Minimal Timer App

## Summary

Scaffold a Flutter app in the existing office repo and replace the starter
counter with a single-screen Material 3 countdown timer.

## Architecture

- Feature module: `lib/main.dart` for this first small slice.
- State management: Local `StatefulWidget` with in-memory state.
- Navigation: Single `MaterialApp` home route.
- Data source: None.
- Persistence: None.

## File Ownership

| Agent | Files or Modules |
| --- | --- |
| Office Assistant | Feature docs and branch setup |
| Flutter Developer | `lib/main.dart`, `pubspec.yaml` |
| QA/Test Engineer | `test/widget_test.dart`, test plan |

## Data Model

```dart
int durationSeconds;
int remainingSeconds;
Timer? ticker;
```

## Implementation Slices

- [x] Slice 1: Scaffold Flutter app with FVM.
- [x] Slice 2: Implement timer UI, duration controls, and countdown behavior.
- [x] Slice 3: Replace stock widget test with timer behavior coverage.

## Test Strategy

- Unit tests: Not required; logic is small and covered through widget behavior.
- Widget tests: Default state, duration controls, start/pause/reset, completion.
- Integration tests: Not required for this first route-only feature.
- Golden tests: Deferred until design stabilizes.

## Risks And Tradeoffs

- Keeping all code in `main.dart` is acceptable for the first product slice, but
  future timer features should move state and widgets into feature files.
- `Timer.periodic` is simple and testable, but it does not solve background
  timing, notifications, or persisted elapsed time.

## Decisions

- Use only Flutter SDK and Material components.
- Disable duration edits while running to avoid ambiguous countdown math.
- Keep the UI centered and constrained instead of adding navigation.
