# Feature Status Index

This file is the Office Assistant's first stop for progress checks. Keep it
current so status requests do not require reading the whole app or relying on
hidden chat history.

## Minimal Timer App

- Slug: `minimal-timer-app`
- App workspace: `work/minimal-timer-app/`
- Source of truth: `main`
- Historical branch: `integrate/minimal-timer-app`
- State: `shipped to main`
- Last quality gates: `fvm flutter pub get`, `fvm dart format --set-exit-if-changed .`, `fvm flutter analyze`, and `fvm flutter test` were recorded as passing in `docs/features/minimal-timer-app/handoff.md`
- Manual QA: `partial`; web server smoke was recorded, but interactive emulator/browser QA was not completed in the original handoff
- Current owner: `Release Engineer`
- Open risks: background timing and persistence were out of scope for the original minimal timer slice
- Docs: `docs/features/minimal-timer-app/`
- Handoff: `docs/features/minimal-timer-app/handoff.md`
- Last updated: `2026-05-19 by CEO`

## Android Background Timer

- Slug: `android-background-timer`
- App workspace: `work/minimal-timer-app/`
- Source of truth: `main`
- Historical branch: `feat/android-background-timer/impl`
- State: `implemented on main; needs verification pass`
- Last quality gates: `unknown from docs`; run the Flutter quality gates before release claims
- Manual QA: `not started`; physical device or Android emulator background behavior still needs validation
- Current owner: `QA/Test Engineer`
- Open risks: Android foreground-service policy, notification permission flow, isolate communication, and battery/background behavior
- Docs: `docs/features/android-background-timer/`
- Handoff: `missing`; create or update `docs/features/android-background-timer/handoff.md`
- Last updated: `2026-05-19 by CEO`

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
- Source of truth: `product/alarms`
- State: `In Planning`
- Last quality gates: `n/a`
- Current owner: `Product Lead`
- Open risks: audio and vibration execution in background service / battery optimization policies
- Docs: `docs/features/alarms/`
- Handoff: `docs/features/alarms/async/outbox/product-lead.md`
- Last updated: `2026-05-20 by Product Lead`

