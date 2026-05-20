# Agent Outbox: Product Engineer

## Role

Product Engineer / Architect

## Branch

`arch/alarms`

## Summary

Created the technical architecture plan (`docs/features/alarms/tech-plan.md`) for the "alarms" feature. Defined the implementation details for audio playback and vibration haptics, detailed the integration with the existing `flutter_foreground_task` background service/isolate, established the local configuration data models, mapped out development slices, and formulated the QA testing strategy.

## Changed Files

- `docs/features/alarms/tech-plan.md`
- `docs/features/status-index.md`
- `docs/features/alarms/async/outbox/product-engineer.md`

## Commit

```text
docs(alarms): add technical architecture plan
```

## Decisions Made

- **Package Selection**:
  - **Audio**: `audioplayers: ^6.0.0` was chosen for smooth, customizable, multi-instance, and looping audio playback of asset files during foreground ringing.
  - **Vibration**: `vibration: ^2.1.0` was chosen over standard SDK `HapticFeedback` because it supports looping customized vibration patterns (essential for the rhythmic double-beat heartbeat cadence: `[0, 150, 150, 150]`).
- **Foreground vs. Background Isolation**:
  - **Foreground Alerting**: Triggered dynamically when `remainingSeconds` hits `0` via the main isolate, displaying a high-contrast fullscreen `RingingOverlay` widget, looping chosen audio streams, and vibrating via the `vibration` plugin.
  - **Background Alerting**: Spawning complex player plugins or custom haptics in the background Dart isolate `TimerTaskHandler` can be unreliable due to native OS battery/isolate thread sleep policies. Therefore, we delegate background alerting to the **native Android/iOS Foreground Service Notification system** itself, upgrading the notification channel to high-priority (`HIGH`/`MAX`) with native default sounds/vibrations and custom raw sound assets. This ensures immune, bulletproof background alarms.
- **Background Dismissal Action**:
  - Configured `flutter_foreground_task` with action buttons (specifically a "Dismiss" action button directly in the notification widget).
  - Tapping "Dismiss" notifies `TimerTaskHandler` natively, which stops the active foreground service, cancels alarm routines, and communicates the reset state back to the main UI isolate.
- **Local Persistence Model**:
  - Created an `AlarmConfig` model carrying `isMuted` (bool) and `soundId` (String).
  - Configured local reads/writes backed by `SharedPreferences`, which is natively accessible by both the foreground main isolate and the background isolate on startup/fire.
- **Safety Auto-Timeout**:
  - Integrated a **5-minute safety threshold** of unattended continuous ringing, automatically resetting the timer to avoid battery drainage.

## Tests Or Checks

- Verified Markdown formatting.
- Updated `docs/features/status-index.md` changing status to `In Architecture/Planning` and owner to `Product Engineer`.

## Open Questions / Notes for Developers

- **Assets Preparation**: Developers should ensure that the three minimalist audio files (chime, beep, echo) are added to `assets/audio/` and registered in `pubspec.yaml`, and copies are also placed in `android/app/src/main/res/raw/` (without subfolders, lowercase filenames only, e.g. `chime.mp3`) to enable native Android background notification channel playback.
- **Physical Keys Override**: Intercepting physical volume keys can be handled cleanly via a `KeyboardListener` on the `RingingOverlay` widget, or using a package if needed. Standard focus must be set to this listener on widget mount.

## Status Index

Yes, updated.

## Next Agent Handoff

- **Flutter Developer** to implement **Slice 1** (Add packages, audio files, and core singleton `AlarmService`) and **Slice 2** (Implement configuration UI and SharedPreferences persistence).
