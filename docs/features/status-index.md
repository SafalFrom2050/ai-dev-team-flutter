# Feature Status Index

This file is the Office Assistant's first stop for progress checks. Keep it
current so status requests do not require reading the whole app or relying on
hidden chat history.

## Minimal Timer App

- Slug: `minimal-timer-app`
- App workspace: `work/minimal-timer-app/`
- Source of truth: `main`
- Historical branch: `integrate/minimal-timer-app`
- State: `shipped to main; interactive browser/emulator QA evidence incomplete`
- Last quality gates: `fvm flutter pub get`, `fvm dart format --set-exit-if-changed .`, `fvm flutter analyze`, and `fvm flutter test` were recorded as passing in `docs/features/minimal-timer-app/handoff.md`
- Manual QA: `partial`; web server smoke was recorded, but interactive emulator/browser QA was not completed in the original handoff
- Current owner: `QA/Test Engineer`
- Open risks: background timing and persistence were out of scope for the original minimal timer slice
- Docs: `docs/features/minimal-timer-app/`
- Handoff: `docs/features/minimal-timer-app/handoff.md`
- Last updated: `2026-05-19 by CEO`

## Android Background Timer

- Slug: `android-background-timer`
- App workspace: `work/minimal-timer-app/`
- Source of truth: `main`
- Historical branch: `feat/android-background-timer/impl`
- State: `code present on main; release verification pending`
- Last quality gates: `unknown from docs`; run the Flutter quality gates before release claims
- Manual QA: `not started`; physical device or Android emulator background behavior still needs validation
- Current owner: `QA/Test Engineer`
- Open risks: Android foreground-service policy, notification permission flow, isolate communication, and battery/background behavior
- Docs: `docs/features/android-background-timer/`
- Handoff: `docs/features/android-background-timer/handoff.md`
- Last updated: `2026-06-04 by CEO`

## Timer Onboarding

- Slug: `timer-onboarding`
- App workspace: `work/minimal-timer-app/`
- Source of truth: `main`
- State: `shipped to main`
- Last quality gates: `fvm flutter analyze` and `fvm flutter test` recorded as passing on 2026-05-19
- Current owner: `Release Engineer`
- Open risks: finding a balance between helpful guidance and breaking the "minimal" flow
- Docs: `docs/features/timer-onboarding/`
- Handoff: `docs/features/timer-onboarding/handoff.md`
- Last updated: `2026-05-19 by Release Engineer`

## Alarms

- Slug: `alarms`
- App workspace: `work/minimal-timer-app/`
- Source of truth: `main`
- State: `shipped to main`
- Last quality gates: `fvm dart format --set-exit-if-changed .`, `fvm flutter analyze`, and `fvm flutter test` passing cleanly on 2026-05-20
- Current owner: `Release Engineer`
- Open risks: background execution and battery optimization constraints (mitigated via native alarm notification and vibration triggers)
- Docs: `docs/features/alarms/`
- Handoff: `docs/features/alarms/walkthrough.md`
- Last updated: `2026-05-20 by Release Engineer`

## Fluent Minimal Redesign

- Slug: `fluent-minimal-redesign`
- App workspace: `work/minimal-timer-app/`
- Source of truth: `main`
- Historical branch: `integrate/fluent-minimal-redesign`
- State: `code/design docs present; release-grade UI verification pending`
- Last quality gates: `fvm dart format .`, `fvm flutter analyze` (clean), and `fvm flutter test` (all 9 tests passed)
- Manual QA: `not started in current evidence`; browser screenshots are still required before release-grade UI claims
- Current owner: `QA/Test Engineer`
- Open risks: balancing intense physics-based animations (springs, glows) with low-end device performance; ensuring seamless Android/iOS background persistence is maintained after visual restructuring
- Docs: `docs/features/fluent-minimal-redesign/`
- Brief: `docs/features/fluent-minimal-redesign/brief.md`
- Design Contract: `docs/features/fluent-minimal-redesign/design-contract.md`
- Handoff: `docs/features/fluent-minimal-redesign/handoff.md`
- Last updated: `2026-06-04 by CEO`

## Sleep Tracker

- Slug: `sleep-tracker`
- App workspace: `work/minimal-timer-app/`
- Source of truth: `main`
- Historical branch: `integrate/sleep-tracker`
- State: `code present; QA and release verification pending`
- Last quality gates: `fvm dart format .` (clean), `fvm flutter analyze` (clean - no warnings or errors)
- Manual QA: `not started`
- Current owner: `QA/Test Engineer`
- Open risks: wake-up alarm exact scheduling, background isolate power/battery optimization limits, crescendo sound/haptic reliability
- Docs: `docs/features/sleep-tracker/`
- Brief: `docs/features/sleep-tracker/brief.md`
- Handoff: `docs/features/sleep-tracker/handoff.md`
- Last updated: `2026-06-04 by CEO`




