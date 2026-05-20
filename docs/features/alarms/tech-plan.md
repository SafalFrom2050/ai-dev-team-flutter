# Technical Plan: Alarms

## Summary

This feature introduces an audible and tactile alarm system that is minimal, reliable, and highly configurable. When the timer hits zero, the app will play a continuous looping sound and vibrate in a heartbeat cadence. Users can select from 3 minimalist tones (Chime, Beep, Echo) or quick-mute the audio. The feature supports foreground full-screen "Time's Up!" overlay alerts as well as high-priority Android background notification alerts with a "Dismiss" action.

## Architecture

- **App Workspace**: `work/minimal-timer-app/`
- **Feature Module**: `work/minimal-timer-app/lib/features/alarms/`
- **State Management**: Extended `TimerScreen` state for configuration UI, and custom `AlarmService` (singleton) for foreground playback, along with state-synced `SharedPreferences` for local persistence.
- **Navigation & Overlay**: The fullscreen alert will render as a stacked overlay (`RingingOverlay`) using standard Flutter `OverlayEntry` or a dedicated modal route on top of the main `TimerScreen`.
- **Data Source / Persistence**: `SharedPreferences` for loading/saving `AlarmConfig` (mute state, selected sound ID).
- **Background Execution**: Custom audio/haptics running on the main thread when foregrounded, combined with native Foreground Service notification alerts and actions on Android using `flutter_foreground_task` inside the background isolate `TimerTaskHandler`.

```
┌────────────────────────────────────────────────────────┐
│                      MAIN ISOLATE                      │
│                                                        │
│  ┌───────────────┐               ┌───────────────┐     │
│  │  TimerScreen  │ ──(state)───► │ RingingOverlay│     │
│  └───────▼───────┘               └───────▼───────┘     │
│          │                               │             │
│   (load/save preferences)            (play/vibrate)    │
│          ▼                               ▼             │
│  ┌───────────────┐               ┌───────────────┐     │
│  │SharedPrefs    │               │ AlarmService  │     │
│  └───────▲───────┘               └───────────────┘     │
└──────────┼─────────────────────────────────────────────┘
           │ (read settings natively)
┌──────────┼─────────────────────────────────────────────┐
│          ▼           BACKGROUND ISOLATE                │
│  ┌───────────────┐                                     │
│  │TimerTaskHandle│ ──(on zero)─► High-Priority Notification│
│  └───────────────┘               (with Sound & Dismiss Button)
└────────────────────────────────────────────────────────┘
```

## File Ownership

| Agent | Files or Modules |
| --- | --- |
| **Product Engineer** | `docs/features/alarms/tech-plan.md`, technical architecture documentation |
| **Flutter Developer** | `lib/features/alarms/` services, models, and UI controls, `lib/main.dart` integration, `pubspec.yaml` updates |
| **QA/Test Engineer** | `test/features/alarms/` widget, unit, and integration tests |

## Data Model

```dart
/// Represents the user alarm configuration settings.
class AlarmConfig {
  final bool isMuted;
  final String soundId; // 'chime', 'beep', 'echo'

  const AlarmConfig({
    required this.isMuted,
    required this.soundId,
  });

  factory AlarmConfig.defaultConfig() {
    return const AlarmConfig(
      isMuted: false,
      soundId: 'chime',
    );
  }

  AlarmConfig copyWith({
    bool? isMuted,
    String? soundId,
  }) {
    return AlarmConfig(
      isMuted: isMuted ?? this.isMuted,
      soundId: soundId ?? this.soundId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isMuted': isMuted,
      'soundId': soundId,
    };
  }

  factory AlarmConfig.fromJson(Map<String, dynamic> json) {
    return AlarmConfig(
      isMuted: json['isMuted'] ?? false,
      soundId: json['soundId'] ?? 'chime',
    );
  }
}
```

## Implementation Slices

- [ ] **Slice 1: Dependencies, Audio Assets, and Core Alarm Service**
  - Add dependencies to `work/minimal-timer-app/pubspec.yaml`:
    - `audioplayers: ^6.0.0`
    - `vibration: ^2.1.0`
  - Add minimalist tone assets to assets (e.g. `assets/audio/chime.wav`, `assets/audio/beep.wav`, `assets/audio/echo.wav`). Register the assets in `pubspec.yaml`.
  - Place matching raw resources (e.g. `.mp3` or `.wav`) under `android/app/src/main/res/raw/` for native notification channel sounds.
  - Implement `AlarmService` to encapsulate:
    - Audio playback (with loop mode support and stop actions).
    - Play preview action (plays sound for 1.5 seconds, then stops).
    - Looping vibration pattern based on the design token heartbeat cadence: `[0, 150, 150, 150]` using the `vibration` package.

- [ ] **Slice 2: Persistence and Configuration UI**
  - Implement local storage persistence for `AlarmConfig` via `SharedPreferences`.
  - Create the `SoundMuteToggle` widget to show high-contrast mute state transitions (`Icons.volume_up` / `Icons.volume_off`).
  - Create the `SoundSelectorShelf` and `SoundToneChip` widgets displaying the 3 selectable tones with smooth selection visuals.
  - Integrate these controls seamlessly onto the `TimerScreen` under the duration presets.

- [ ] **Slice 3: Fullscreen Ringing Overlay (Foreground)**
  - Create the `RingingOverlay` widget:
    - Safe-area responsive layout centering a 520dp wide card on tablet/desktop, and 100% bleed on mobile.
    - Ambient pulsing radial animation (scaling `1.0` to `1.15`).
    - Large pulsing notification bell icon (`Icons.notifications_active`).
    - Oversized high-contrast white rounded "DISMISS" button (80dp height) at the bottom.
  - Implement full-screen Route overlay displaying automatically when the remaining seconds timer hits `0` in foreground.
  - Wire the "Dismiss" action to silence audio/vibration and reset/dismiss the state.
  - Add interception of device physical volume keys via `RawKeyboardListener` or `KeyboardListener` to quickly silence active audio.

- [ ] **Slice 4: Background Service Upgrades and Actions**
  - Configure `flutter_foreground_task` settings inside `BackgroundTimerService.initialize()` to support notification action buttons and high-priority channels:
    - Upgrade importance to `NotificationChannelImportance.HIGH`.
    - Set priority to `NotificationPriority.HIGH`.
    - Set up a custom sound using the registered raw notification sound resource matching the selected user tone.
    - Add a "Dismiss" action button (`NotificationButton(id: 'dismiss_alarm', text: 'DISMISS')`).
  - Update `TimerTaskHandler` background isolate class to:
    - Read persistence config natively on completion.
    - Trigger high-priority sound and vibration natively when countdown hits zero in background.
    - Intercept the `'dismiss_alarm'` button action in `onNotificationButtonPressed(String id)` (or callback), silence background alert, stop the service, and notify the main app isolate.

- [ ] **Slice 5: Accessibility and Test Coverage**
  - Verify screen-reader accessibility labels on all new UI controls (mute buttons, sound chips).
  - Add `liveRegion: true` to the `RingingOverlay` screen semantic container so that screen-readers announce timer completion immediately.
  - Write unit tests for `AlarmConfig` serialization/deserialization.
  - Write widget tests for `SoundSelectorShelf`, `SoundMuteToggle`, and `RingingOverlay` verifying state synchronization.
  - Create mocked `AudioPlayer` and `Vibration` classes to verify proper method invocations and looping cadence.

## Test Strategy

- **Unit tests**:
  - Test `AlarmConfig` default factory constructors and JSON parsing edge cases.
  - Test state machine transitions of the alarm system when toggling settings.
- **Widget tests**:
  - Test `SoundMuteToggle` flips state on tap and triggers local persistence storage calls.
  - Test `SoundSelectorShelf` lists all three choices, highlights the selected item, and triggers `AlarmService.playPreview()` on unselected chip tap.
  - Test `RingingOverlay` renders with full accessibility live-region announcements when timer completes.
  - Verify tapping "DISMISS" in the overlay terminates sound and vibration.
- **Mock Verification**:
  - Utilize `mockito` to generate mocks for `audioplayers` and `vibration` package entry-points, ensuring exact parameters (volume, loop mode, vibration durations) are dispatched.
- **Manual Verification**:
  - Perform real-world verification on Android emulator/physical device for background alarms, validating that lockscreen notification actions work and silence the alarm immediately.

## Risks And Tradeoffs

- **Risk: Dart background isolate plugin communication limitations.**
  - *Mitigation*: Instead of trying to run complex Dart plugin instances inside the restricted background isolate (which often fails on older Android/iOS versions), we delegate background alerting to native Android notification channel sound/vibrations which are fully managed by the OS and immune to isolate limitations.
- **Risk: Loop battery drainage.**
  - *Mitigation*: In alignment with UI/UX designer recommendations, we will implement an automatic safety timeout of **5 minutes** of unattended ringing, after which the app will auto-dismiss and reset to prevent battery depletion.
- **Risk: System mute override.**
  - *Mitigation*: We will respect system "Do Not Disturb" modes out of the box by using standard notification and audio stream categories. Clear visual labels will inform the user if the device is currently silenced.

## Decisions

- **Use `vibration` package** instead of standard `HapticFeedback` to support continuous custom heartbeat-like haptic rhythms.
- **Limit built-in tones to 3 distinct minimalist files** to avoid bloating the application package.
- **Configure native Android high-priority channel** with raw audio resources for robust background wakeups rather than relying on background Dart isolate thread audio playback.
