# Release Notes: Minimal Timer App

## Summary

Adds the first Flutter product surface: a minimal countdown timer.

## User-Visible Changes

- Single timer screen with a large countdown dial.
- 1, 5, and 10 minute presets.
- One-minute duration increase and decrease controls.
- Start, pause, reset, and restart actions.
- **Background Execution**: Timer now continues counting and notifies you when the app is in the background.
- **Onboarding**: A new welcome flow for first-time users explaining background behavior and controls.
- **Help Button**: A new '?' icon to re-access the onboarding tutorial at any time.

## Notes

- Background execution is supported via a foreground service and notification.
- Onboarding state is persisted locally.
