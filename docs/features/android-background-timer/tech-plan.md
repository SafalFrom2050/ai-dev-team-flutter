# Tech Plan: Android Background Timer

## Architecture Overview

The background timer will use a **Foreground Service** via the `flutter_foreground_task` package. This creates a separate Android service that runs in the background with a persistent notification, allowing our Dart code to continue executing even when the main UI is not visible.

## State Synchronization

The biggest challenge is syncing the "UI Timer" and the "Background Service Timer".

1. **Active State:** When the timer starts in the UI, we will launch the Foreground Service.
2. **One Source of Truth:** The Background Service will own the "Master Ticker" while active.
3. **Communication:**
   - **UI -> Service:** Commands like `start`, `pause`, `reset`.
   - **Service -> UI:** Stream of "remaining seconds" and "status".
   - **Persistence:** The current target end time and duration will be saved to the service's memory/data channel.

## Implementation Steps

### 1. Dependency
Add `flutter_foreground_task: ^9.2.2` to `pubspec.yaml`.

### 2. Android Configuration
Update `AndroidManifest.xml`:
- Add `FOREGROUND_SERVICE` and `FOREGROUND_SERVICE_SPECIAL_USE` (or `DATA_SYNC` depending on Android 14+ requirements) permissions.
- Add `POST_NOTIFICATIONS` permission for Android 13+.
- Declare the service component.

### 3. Background Task Handler
Create a `TimerTaskHandler` class that:
- Implements `TaskHandler`.
- Manages an internal `Timer.periodic`.
- Updates the foreground notification every second.
- Sends progress updates back to the main isolate.

### 4. Background Timer Service Wrapper
Create a `BackgroundTimerService` class in `lib/services/background_timer_service.dart`:
- Handles initialization.
- Wraps `FlutterForegroundTask` calls.
- Provides a `Stream<TimerState>` for the UI to consume.

### 5. UI Integration
Refactor `TimerScreen` in `lib/main.dart`:
- Use `BackgroundTimerService` instead of local `Timer`.
- Listen to the state stream to update the dial and labels.

## Risks & Mitigations

- **Isolate Communication:** Background services run in a separate isolate. We must use the package's built-in communication channel to pass data back to the UI.
- **Android 14+ Restrictions:** Android 14 introduced stricter rules for foreground services. We will use `specialUse` or `dataSync` and ensure the notification is prominent to comply with "user-visible" requirements.
- **Battery Impact:** Ticking every second in the background has a minor battery impact. We will ensure the service is killed immediately when the timer is reset or reaches zero.

## Verification Plan

### Manual Testing
1. Start timer -> Minimize app -> Verify notification exists and ticks.
2. Lock screen -> Wait 2 minutes -> Unlock -> Verify UI is in sync.
3. Tap notification -> Verify app returns to foreground.
4. Let timer reach zero in background -> Verify notification says "Done".

### Automated Testing
- Add unit tests for `BackgroundTimerService` (mocking the plugin).
- Ensure existing widget tests still pass with the refactored state management.
