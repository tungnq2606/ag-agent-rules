# Native Platform

Read this file when working on notifications, persisted storage, deep links, or anything whose behavior differs between iOS and Android.

## Architecture state

`newArchEnabled=false` in `android/gradle.properties`; iOS pods install with `RCT_NEW_ARCH_ENABLED=1` and `USE_FRAMEWORKS=static`. Hermes is on. The two platforms are **not** on the same architecture.

So: no TurboModule or Fabric advice may be applied from one platform's result. Build and run both. When a native-module change is proposed, say which architecture each platform is on in the same breath.

Minimums: Android `minSdk` 24, `target` 35; iOS deployment target 15.1.

## Notifications (Firebase Messaging + MoEngage)

Push is `@react-native-firebase/messaging`, with MoEngage (`src/moengage`) and AppsFlyer (`src/appsflyer`) alongside for campaigns and attribution.

- `setBackgroundMessageHandler` is registered in `index.js`, at module scope outside the React tree. Moving it inside a component breaks quit-state delivery, and nothing fails loudly when it does.
- Permission is requested, not assumed. Android 13+ makes it a runtime permission and the user can deny — handle the denied path in the UI instead of silently doing nothing.
- A notification payload is untrusted input. Validate the route and its parameters before navigating. See `.ai/rules/security.md`.
- Android needs an explicit channel with the intended importance before a notification displays; a missing channel fails silently.
- iOS suppresses the system banner while the app is foregrounded unless it is presented explicitly. Test foreground and background separately.
- Deep-linking from a notification has three entry paths — foreground, backgrounded, and cold start from terminated. All three need testing; cold start is the one that breaks, because navigation may not be mounted when the event arrives.
- Two SDKs can both claim a notification. When adding or changing a payload shape, check MoEngage and Firebase do not fight over the same message.
- Badge counts and delivered-notification cleanup are platform-specific. Clearing on one does not clear the other.

## Persisted storage (MMKV + redux-persist)

Storage keys are centralised in `src/config/data/storage-key.ts`. Add a key there, not inline at the call site.

- Keys are a contract. Changing the shape of a stored value without a migration crashes on the first launch after update — for existing users only, never in development where the old value does not exist. This is the most common update-only crash.
- redux-persist needs a `version` bump plus a migration when a persisted slice's shape changes. Shipping a new shape on the old version means the old blob rehydrates into code that no longer understands it.
- Read defensively on any shape change: validate what came back and fall back to a safe default rather than trusting the declared type.
- Credentials belong in the keychain, not plain MMKV. See `.ai/rules/security.md`.
- Storage reads are synchronous. A large read on the startup path shows up as slow launch or an ANR.
- Clear the user's persisted data on logout, including React Query caches holding user content.

## Deep links and universal links

- Validate the route, the parameter types, and the user's permission to view the target before navigating. Navigation lives in `src/routers/`.
- Handle the cold-start case: the link may arrive before navigation is ready. Queue it rather than dropping it.
- iOS universal links and Android app links each need their association file served and their manifest/entitlement entry correct — a link opening the browser instead of the app is usually configuration, not code.
- Test a link the app does not recognise; it must not crash or land on a blank screen.

## Platform differences to check every time

- **Safe area.** Bottom-anchored UI keeps the reported inset. Android 3-button navigation is the case that breaks. See `.ai/rules/code-style.md`.
- **Keyboard.** Avoidance behavior differs; verify an offset does not double-count an inset already included.
- **Hardware back.** Android has one. A modal or sheet ignoring it traps the user.
- **Permissions.** Request timing, denial semantics, and the "ask again" path differ. Handle permanent denial explicitly.
- **Background execution.** iOS grants far less. Work that completes on Android may be suspended on iOS.
- **Fonts and text metrics.** The same `fontSize` renders at different heights; a fixed-height text container clips on one platform. Fonts are registered via `yarn font`.
- **Shadows.** `shadow*` is iOS, `elevation` is Android. Setting only one gives a flat surface on the other platform.
- **Widget.** `LiveScoreWidgetExtension` is iOS-only and reads shared data. A change to that shared shape needs the widget checked, not just the app.

## Rules

- A change described as platform-specific must state which platform was verified and which was not.
- Do not add a `Platform.OS` branch to hide a bug whose cause is not understood.
- When native behavior is uncertain, a device run answers the question faster than more reading.
