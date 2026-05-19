# Package Decision: flutter_foreground_task

## Use Case

We need to keep the timer running on Android when the app is in the background or the screen is locked. A Foreground Service with a persistent notification is the most reliable Android mechanism to prevent the OS from suspending the Flutter engine or killing the process during a countdown.

## Options Compared

| Package | Pros | Cons |
| --- | --- | --- |
| `flutter_foreground_task` | High quality, active maintenance, clear API for task handlers, supports notification buttons, built-in permission handling. | Android-only (for our use case), slightly more complex setup than basic plugins. |
| `flutter_background_service` | Popular, simple API, supports both iOS and Android. | Less granular control over notification behavior than `flutter_foreground_task`. |
| `workmanager` | Standard for periodic background tasks. | Not suitable for a real-time countdown timer; minimum interval is 15 minutes. |

## Decision

Chosen package: `flutter_foreground_task`

Reason: It provides the most robust control over Android Foreground Services, which is our primary target. Its task handler pattern is well-suited for a dedicated timer tick isolate, and it offers great flexibility for notification updates and action buttons.

## Risk

- Maintenance: High (active commits, good pub score).
- License: MIT.
- Platform support: Android (primary), iOS (limited support, but out of scope for this brief).
- Bundle size: Minimal impact.
- API stability: Stable (9.x.x).

## Exit Strategy

The logic will be encapsulated in a `BackgroundTimerService` wrapper. Replacing it would involve swapping the platform-specific service implementation while keeping the timer logic relatively stable.
