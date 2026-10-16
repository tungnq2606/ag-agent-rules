# Device Matrix

Read this file when a change is runtime-visible and `.ai/rules/verification.md` calls for a device or simulator run.

Runtime-visible means the behavior depends on layout, navigation, gesture, keyboard, safe area, lifecycle, notification, native API, or locale. A typecheck cannot see any of those.

## Minimum coverage

Verify on the environment that most exposes the change, not the one that is already open.

| Change touches | Verify at least on |
|---|---|
| Bottom-anchored UI, tab bar, sheet, floating button | Android with 3-button navigation **and** an iPhone with a home indicator |
| Keyboard interaction, input, form | Both platforms — avoidance behavior differs |
| Top-of-screen layout, header, status bar | An iPhone with a notch/Dynamic Island and an Android with a punch-hole |
| Gesture, swipe, pan, drag | Both platforms — Android's back gesture competes with horizontal swipes |
| List scrolling and performance | The lowest-end Android device available, not the simulator |
| Notification, deep link | A real device on both platforms, in all three states: foreground, backgrounded, cold start |
| Persisted-state shape change | An install of the **previous** app version, then update over it |
| Long-text or locale-dependent layout | The longest supported locale, not English |
| Dark/light theme change | Both themes, plus a switch while the screen is open |
| Native module, permission | A real device — the simulator lies about permissions and hardware |

## Minimum supported versions

Android `minSdk` 24 (Android 7.0), `target` 35. iOS deployment target 15.1.

Verify on the minimum supported version when the change uses a platform API whose availability or behavior varies by version. That is where a version guard is either missing or wrong. Android 7 is a wide gap from Android 15 — a modern API used without a guard compiles fine and crashes on the floor.

Re-read `android/build.gradle` and `ios/Podfile` if these numbers look stale rather than trusting this line.

## Simulator versus device

A simulator is enough for layout, copy, theme, and navigation structure.

A real device is required for: performance and scroll feel, notifications, permissions, camera and sensors, background behavior, keyboard hardware differences, and anything reported as crashing in production.

Never report a performance improvement measured on a simulator.

## Reporting

State what you ran on and what you did not:

> Verified on Android 14 (Pixel 7, 3-button nav) and iOS 18 simulator. Not verified on a physical iPhone.

An unverified platform named plainly is useful. An unverified platform left unmentioned reads as verified, and that is the failure this file exists to prevent.

## Update-over-install

For any change to persisted state shape, migration, or startup path: install the previous version, use the affected flow, then update over it. A clean install passes while every existing user crashes. See `.ai/rules/native-platform.md`.
