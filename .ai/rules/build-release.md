# Build & Release

Read this file when a change touches native code, native configuration, dependencies, environment configuration, or when preparing a build.

## Environments

Four, selected by `ENVFILE`: `.env.development`, `.env.staging`, `.env.beta`, `.env.production`.

| Environment | Metro | Android mode | iOS scheme | Android flavor |
|---|---|---|---|---|
| dev | `yarn start:development` | `devDebug` | `uniscoreDev` | `dev` |
| staging | `yarn start:staging` | `stagingDebug` | `uniscoreStag` | `staging` |
| beta | — | `betaDebug` | `uniscoreBeta` | `beta` |
| production | `yarn start:production` | `prodDebug` | `uniscore` | `prod` |

Run scripts rather than reconstructing the commands: `yarn android:dev:debug`, `yarn android:stag:debug`, `yarn android:beta:debug`, `yarn android:prod:debug`, `yarn ios:dev:debug`, `yarn ios:stag:debug`, `yarn ios:prod:debug`.

There is also a `LiveScoreWidgetExtension` scheme. A change to widget code or its shared data needs the widget built and checked separately — the app building does not prove the widget does.

Rules:

- Never hardcode an environment-dependent value — base URL, API key, bundle identifier, Firebase config, Sentry DSN. It comes from the `ENVFILE` config.
- `google-services.json` and `GoogleService-Info.plist` are per-flavor. Confirm the right file is wired to the right flavor before blaming a Firebase failure on code.
- A change to environment configuration affects all four. State which ones you checked.
- Never point a non-production build at production data to make it work.

## Architecture state — verify per platform

`newArchEnabled=false` in `android/gradle.properties`, but `yarn pod-install` and `yarn pod-i` run with `RCT_NEW_ARCH_ENABLED=1` and `USE_FRAMEWORKS=static`. The two platforms are not on the same architecture.

Consequence: never assume a TurboModule or Fabric behavior verified on iOS holds on Android, or the reverse. Any native-module or renderer-level change gets built and run on both.

## When a native rebuild is required

A Metro reload is not enough — rebuild and reinstall — after any of:

- adding, removing, or upgrading a dependency with a native part;
- any change under `android/` or `ios/`, including manifest, plist, gradle, and Podfile;
- a change under `patches/` (patch-package runs on `postinstall`);
- new or changed native permission;
- asset catalog, app icon, splash, or font registration change (`yarn font`);
- architecture, Hermes, or build-flag change;
- anything read at native startup.

iOS also needs pods reinstalled: `yarn pod-i` (clean) or `yarn fix:ios:pod` (with `--repo-update`). `yarn rs` is the full reset — node_modules, pods, watchman — and takes a long time; reach for it only when a targeted reinstall has already failed.

Android clean: `yarn c:and`.

Say plainly when a native change was verified on JS only.

## Verification for native changes

Compiling is the minimum bar.

- Kotlin fast check: `cd android && ./gradlew :app:kaptGenerateStubsStagingDebugKotlin`
- Android build of the affected flavor: `cd android && ./gradlew assembleDevDebug` (or the matching variant)
- iOS: build the affected scheme
- Then run the changed behavior on a device or simulator per `.ai/rules/device-matrix.md`

Report which platform you built and which you did not.

## Release builds

| Target | Script |
|---|---|
| Android APK | `yarn build:dev:apk`, `build:stag:apk`, `build:beta:apk`, `build:prod:apk` |
| iOS release | `yarn build:ios-dev-release`, `build:ios-stag-release`, `build:ios-beta-release`, `build:ios-prod-release` |
| JS bundle only | `yarn b:ios`, `yarn b:and` |

## Release — fastlane

Lanes in `fastlane/Fastfile`: `dev`, `staging`, `beta`, `beta_aab`, `upload_to_open_testing_play_store`, `ipa`, `testflight`, `testflight_stag`, `testflight_alpha`, `testflight_prod`.

Read the lane before running it. A lane that uploads is not reversible — confirm with the user first, every time.

## Versioning

- The user-facing version and build number are release decisions. Do not bump them as part of a feature change unless asked.
- A Sentry release must match the shipped build, or crashes from it arrive unsymbolicated. See `.agents/skills/triage-crash/SKILL.md`.

## Release gates

- No debug statement, temporary flag, or instrumentation left in the diff.
- No non-production endpoint or test credential reachable from a production build.
- Localization regenerated (`yarn lang`) when strings changed; check `yarn translate:stats` for missing translations before shipping.
- Crash-free rate for the previous release checked before shipping on top of it.
- Rollback path known: previous build available, and any persisted-state migration in this release forward-compatible.

## Signing and credentials

Keystore files, provisioning profiles, `.p8`/`.p12`, service-account JSON, and signing passwords never enter the repository. See `.ai/rules/security.md`.

A signing or provisioning change is Large / Risky work: plan it and get approval first.
