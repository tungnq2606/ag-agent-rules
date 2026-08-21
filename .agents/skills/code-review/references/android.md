# Android — `android/**`

`minSdk` 24, `compile`/`target` 35, Hermes on, `newArchEnabled=false`. Flavors: `dev`, `staging`, `beta`, `prod`.

## Blocking

- Modern platform API used with no availability guard. It compiles against SDK 35 and crashes on API 24.
- New permission in `AndroidManifest.xml` that the feature does not need, or one added without telling the user.
- Secret, key, or password in `gradle.properties`, the manifest, or a resource file.
- Keystore, service-account JSON, or signing password committed.
- `google-services.json` wired to the wrong flavor.
- Cleartext traffic permitted, or the network security config relaxed, outside a debug-only manifest.

## Kotlin / Java

- Nullable platform value dereferenced without a check.
- Work on the main thread that belongs on a background dispatcher — a JSON parse, a disk read, a synchronous network call. This is what an ANR looks like.
- Statement placed directly in a `companion object` body rather than inside a function.
- Coroutine launched with no scope tied to a lifecycle, so it outlives the screen.
- Context leaked into a static or long-lived reference.

## Gradle

- Dependency version bumped without a build of every flavor.
- ProGuard/R8 rule missing for a newly added library that uses reflection — it works in debug and crashes in release.
- Flavor-specific config added to one flavor and silently missing from the other three.
- Build config changed without stating which variants were built.

## Firebase

- Messaging change made without testing the quit-state path. `setBackgroundMessageHandler` lives in `index.js`.
- Notification channel not created, or created with the wrong importance — it fails silently.
- Crashlytics or Sentry release identity broken by a versioning change, so crashes arrive unsymbolicated.

## Verification

Fast Kotlin check: `cd android && ./gradlew :app:kaptGenerateStubsStagingDebugKotlin`

Real build: `cd android && ./gradlew assembleDevDebug` (or the matching variant). Compiling is the minimum bar — run the behavior on a device per `.ai/rules/device-matrix.md`.
