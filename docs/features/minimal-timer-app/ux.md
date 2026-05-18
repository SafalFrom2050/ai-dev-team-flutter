# UX Notes: Minimal Timer App

## Flow

1. Open app.
2. Review the large countdown and status.
3. Choose a preset or adjust by one minute.
4. Start the timer.
5. Pause or reset as needed.
6. Restart after completion.

## States

- Ready: full duration is selected and Start is available.
- Running: duration controls are disabled, Pause is available, progress advances.
- Paused: remaining time is preserved, Start resumes, Reset restores duration.
- Done: display shows `00:00`, status says Done, primary action says Restart.

## Minimal Design Direction

Keep one centered column, one large timer dial, small preset controls, and two
main actions. The design should feel calm and useful rather than decorative.
