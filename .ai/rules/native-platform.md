# Native Platform

Read this file when working on notifications, persisted storage, deep links, or anything whose behavior differs between iOS and Android.

## New Architecture status

Determine this from the repository before relying on any Fabric or TurboModule guidance, and record the answer here once confirmed:

- Android: `newArchEnabled` in `android/gradle.properties`
- iOS: `RCT_NEW_ARCH_ENABLED` in `ios/Podfile` or the pod install output
- Hermes: `hermesEnabled` in `android/gradle.properties`

Status: **not yet recorded — check the two flags above and fill this in.**

Until it is recorded, do not propose a TurboModule, a Fabric component, or an interop-layer workaround. The advice differs completely between the two architectures, and guessing produces code that compiles on one and fails on the other.

## Notifications (Notifee + Firebase)

- Permission is requested, not assumed. On both platforms a user can deny it, and on Android 13+ it is a runtime permission — handle the denied path in the UI rather than silently doing nothing.
- The background and quit-state handler is registered outside the React component tree, at module scope. Registering it inside a component means it does not exist when the app is not running.
- A notification payload is untrusted input. Validate the route and its parameters before navigating. See `.ai/rules/security.md`.
- Android needs an explicit channel with the intended importance before a notification will display; a missing channel fails silently.
- iOS and Android differ on foreground display: iOS suppresses the system banner while the app is foregrounded unless it is presented explicitly. Test both states.
- Deep-linking from a notification has three entry paths — app running foreground, backgrounded, and cold-started from terminated. All three need testing; the cold-start path is the one that breaks, because navigation may not be mounted when the event arrives.
- Badge counts and delivered-notification cleanup are platform-specific. Do not assume clearing on one clears on the other.

## Persisted storage (MMKV)

- Use separate instances for cache data and credential data, so clearing one cannot clear the other. Credentials belong in the keychain, not plain MMKV — see `.ai/rules/security.md`.
- Keys are a contract. Changing the shape of a stored value without a migration crashes on the first launch after update, for users only — never in development, where the old value does not exist. This is the single most common update-only crash.
- On any stored-shape change: read defensively, validate what came back, and fall back to a safe default rather than trusting the persisted type.
- Namespace keys by environment where a shared device could hold two builds.
- Storage reads are synchronous. A large read on the main path at startup shows up as slow launch or an ANR.
- Clear the user's persisted data on logout, including query caches holding user content.

## Deep links and universal links

- Validate the route, the parameter types, and the user's permission to view the target before navigating.
- Handle the cold-start case: the link may arrive before navigation is ready. Queue it rather than dropping it.
- iOS universal links and Android app links each need their association file served and their manifest/entitlement entry correct — a link that opens the browser instead of the app is usually configuration, not code.
- Test a link the app does not recognise; it must not crash or land on a blank screen.

## Platform differences to check every time

- **Safe area.** Bottom-anchored UI keeps the reported inset. Android 3-button navigation is the case that breaks. See `.ai/rules/code-style.md`.
- **Keyboard.** Avoidance behavior differs; verify that an offset does not double-count an inset already included.
- **Back gesture / hardware back.** Android has a hardware back to handle; a modal or sheet that ignores it traps the user.
- **Permissions.** Request timing, denial semantics, and the "ask again" path differ. Handle permanent denial explicitly.
- **Background execution.** iOS grants far less. Work that completes on Android may be suspended on iOS.
- **Fonts and text metrics.** The same `fontSize` renders at different heights; a fixed-height text container clips on one platform.
- **Shadows.** `shadow*` properties are iOS; `elevation` is Android. Setting only one gives a flat card on the other platform.

## Rules

- A change described as platform-specific must state which platform was verified and which was not.
- Do not add a `Platform.OS` branch to hide a bug whose cause is not understood.
- When native behavior is uncertain, a device run answers the question faster than more reading.
