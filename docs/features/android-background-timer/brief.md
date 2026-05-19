# Feature Brief: Android Background Timer

## Problem

Currently, the Minimal Timer App only ticks while it is in the foreground. If a user switches to another app or locks their screen, the timer effectively pauses or stops because the Flutter engine is suspended by the OS. Users need the timer to continue running and notify them even when the app is not visible.

## Target User

Android users who need to multi-task or lock their phones while waiting for a focus or task timer to complete.

## Goal

Ensure the timer continues to countdown and remains accurate when the app is minimized or the screen is locked on Android devices.

## Non-Goals

- iOS background support (this is a scoped Android-first slice).
- Background audio/alarms (we will start with a persistent notification/foreground service).
- Complex scheduling or "alarm clock" style wake-ups (keep it as a running service).
- Persistence across device reboots.

## User Flow

1. User sets a duration and taps "Start".
2. User minimizes the app or locks the screen.
3. App displays a persistent notification showing the current countdown and status.
4. User taps the notification to return to the app.
5. App displays the current, accurate time remaining.
6. When the timer reaches zero, the notification updates to show "Done".

## Acceptance Criteria

- [ ] The app uses an Android Foreground Service to prevent the OS from killing the timer process.
- [ ] A persistent notification is displayed while the timer is running.
- [ ] The notification shows the real-time countdown (updating at least every minute, ideally every second).
- [ ] Tapping the notification restores the app to the foreground.
- [ ] The UI seamlessly syncs with the background service state upon resume.
- [ ] The background service stops automatically when the timer is reset or reaches zero (and the user dismisses the completion state).

## Data And Integrations

- **Permissions:** `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE`.
- **Integrations:** Android Foreground Service via a suitable Flutter package (to be decided by Product Engineer).

## Risks

- **Product risk:** Users might expect an audible alarm when the timer ends, which is currently a non-goal.
- **Technical risk:** Background execution on Android is subject to aggressive battery optimization; we must ensure the "Foreground Service" is correctly implemented to stay alive.
- **Design risk:** The notification UI should be minimal but helpful; we need to decide what actions (Pause/Reset) are available directly from the notification.
- **QA risk:** Testing background behavior requires physical devices or specific emulator configurations to simulate "real world" process suspension.
