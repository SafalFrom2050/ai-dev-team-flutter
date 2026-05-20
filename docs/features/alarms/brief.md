# Feature Brief: Alarms

## Problem

A countdown timer that only provides a visual state update is easily missed when the user is not actively staring at the screen. If a user places their device in their pocket, turns their back to wash dishes, or switches focus to another task, they can easily overshoot their target time. To make the timer truly useful and trustworthy, the app must provide an unmistakable audible and physical (tactile) alert when the duration ends.

## Target User

Users seeking focus, break, or time-blocked tasks (e.g., cooking, studying, stretching) who need a reliable, multi-sensory notification when their timer reaches zero, regardless of whether the app is in the foreground, background, or the device is locked.

## Goal

Introduce an audible and tactile alarm system that is minimal, reliable, and configurable.
- Play a looping alert sound when a timer completes (both in foreground and background modes).
- Vibrate the device in a synchronized pattern when the timer completes.
- Provide a clear, prominent completion UI ("Time's Up!") in the foreground to dismiss the alarm.
- Enable basic sound selection (from 3 built-in minimalist tones) and a quick mute/unmute toggle.
- Integrate with the existing Android foreground service/notification system to trigger alerts in the background.

## Non-Goals

- No snooze or delay options (dismiss only, to maintain a zero-friction, minimal design).
- No customized sound uploads (users cannot select custom files or MP3s from their device).
- No integration with third-party streaming services (Spotify, YouTube Music, etc.).
- No complex alarm scheduling (e.g., repeating alarms, specific times of day, calendar integration).
- No multiple concurrent alarms.
- No override of system volume if the device is set to total Do Not Disturb / completely silent mode (though we will use standard audio channel settings to respect user preferences but remain audible under normal mute configurations if allowed by system APIs).

## User Flow

### 1. Configuration & Customization
1. User opens the app to the main timer screen.
2. User sees a clean audio status icon (e.g., a bell or speaker) indicating if the alarm is active.
3. User taps the sound icon, which toggles between Muted/Unmuted or reveals a minimal overlay listing three minimalist alert tones:
   - **Chime (Zen Bowl):** A soothing, gentle tone.
   - **Beep (Digital):** A crisp, classic timer tone.
   - **Echo (Classic Bell):** A traditional alarm tone.
4. User selects a sound, which plays a brief preview, and then closes the overlay.
5. The setting is stored locally (persistence) for subsequent sessions.

### 2. Foreground Alert
1. User starts a 5-minute timer.
2. The timer countdown ticks to `00:00`.
3. The screen immediately transitions to a high-visibility, full-screen completion state ("Time's Up!").
4. The selected sound plays in a continuous loop and the device vibrates in a steady heartbeat rhythm.
5. User taps the large, prominent "Stop" / "Dismiss" button on the screen.
6. The sound and vibration stop immediately, and the app resets to the default/previous timer selection screen.

### 3. Background Alert (Android/Mobile)
1. User starts a 5-minute timer and minimizes the app / locks the screen.
2. The Android Foreground Service continues the countdown in the background, updating the persistent notification.
3. The timer reaches `00:00`.
4. The persistent notification upgrades to a high-priority heads-up notification that sounds the alert, vibrates the device, and shows action buttons: "Stop / Dismiss".
5. User taps "Stop / Dismiss" directly on the notification.
6. The sound and vibration stop immediately. Tapping the notification body opens the app and displays the reset timer screen.

## Acceptance Criteria

- [ ] **Mute & Volume Control:** A toggle exists on the main timer screen to quickly mute or unmute the alarm sound.
- [ ] **Sound Selection:** A minimalist picker allows users to choose from at least 3 distinct built-in alarm sounds: "Chime (Zen Bowl)", "Beep (Digital)", and "Echo (Classic Bell)".
- [ ] **Preference Persistence:** Sound state (muted/unmuted) and the selected alarm tone must be saved locally and persist across app launches.
- [ ] **Foreground Ringing State:** When the timer hits zero in the foreground, the app displays a prominent "Time's Up!" screen or sheet, loops the chosen audio, and vibrates the device continuously.
- [ ] **Immediate Dismissal:** Tapping the dismiss action on the ringing screen must halt all sound and vibration instantly and return the app to the idle/configuration screen.
- [ ] **Background Integration:** When the timer hits zero in the background, a high-priority notification triggers an audible alarm and vibration, matching the system notification priority guidelines.
- [ ] **Notification Actions:** The background notification includes a "Dismiss" action button that silences the alarm and clears the active service without needing to open the full app.
- [ ] **Unit & Widget Coverage:** Tests must cover the mute toggle state, sound selection, persistence loading, transitioning into the completion/ringing state at `00:00`, and calling stop/dismiss handlers to reset state.

## Data And Integrations

- **Storage:** Local persistence (e.g., using `shared_preferences` or a lightweight local key-value store) to remember:
  - `alarm_enabled` (boolean)
  - `selected_sound_id` (string)
- **Permissions:** Standard notification permissions and vibration permissions where applicable.
- **Audio & Haptics:** Use stable, cross-platform audio playback and haptics/vibration plugins that work reliably within background isolates.

## Risks

- **Product risk:** Users might forget their device is on vibrate-only or silent mode, causing them to miss alarms. The onboarding or UI should clearly indicate if system settings will override the alarm.
- **Technical risk:** Background audio execution and vibration are notoriously strict on newer versions of Android/iOS. Background tasks might not have permission to play audio continuously if not properly registered under the foreground service.
- **Design risk:** The "Time's Up!" completion UI must be incredibly clean yet impossible to ignore, avoiding any visual clutter.
- **QA risk:** Simulating background alarms in widget and integration tests requires testing boundary conditions when background services are terminated or interrupted by standard phone calls/alarms.
