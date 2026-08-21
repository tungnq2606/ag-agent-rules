# Build & Release

Read this file when a change touches native code, native configuration, dependencies, environment configuration, or when preparing a build.

## Find the real names, do not guess them

Variant, scheme, and script names change. Look them up rather than recalling them:

| What | Where it is defined |
|------|---------------------|
| JS entry points and helper commands | `package.json` → `scripts` |
| Android flavors and build types | `android/app/build.gradle` → `productFlavors`, `buildTypes` |
| Android signing and per-flavor config | `android/app/build.gradle`, `android/gradle.properties` |
| iOS schemes and configurations | `ios/*.xcodeproj/xcshareddata/xcschemes/`, `ios/*.xcworkspace` |
| Per-environment values | the env files / config module the project already uses |
| Fastlane lanes, when present | `fastlane/Fastfile` |

An invented gradle task or scheme name fails slowly and confusingly. Read the file, then run.

## Environments

The app ships four: dev, staging, beta, production. Android variants combine the flavor with the build type (`stagingDebug`, `productionRelease`, and so on).

Rules:

- Never hardcode an environment-dependent value — base URL, API key, bundle identifier, Firebase config, Sentry DSN. It goes through the existing per-environment configuration.
- `google-services.json` and `GoogleService-Info.plist` are per-environment. Confirm the right file is wired to the right flavor before blaming a Firebase failure on code.
- A change to environment configuration affects all four. State which ones you checked.
- Never point a non-production build at production data to make it work.

## When a native rebuild is required

A Metro reload is not enough — the app must be rebuilt and reinstalled — after any of:

- adding, removing, or upgrading a dependency with a native part;
- any change under `android/` or `ios/`, including manifest, plist, gradle, and Podfile;
- new or changed native permission;
- asset catalog, app icon, splash, or font registration change;
- New Architecture, Hermes, or build-flag change;
- changing anything read at native startup.

For iOS, a dependency change also needs the pods reinstalled before the build. Say so rather than reporting a JS-only verification for a native change.

## Verification for native changes

Compiling is the minimum bar; a native change that only typechecks is unverified.

- Android: build the affected variant. `.ai/rules/verification.md` names the Kotlin stub-generation task used as the fast check.
- iOS: build the affected scheme.
- Then run the changed behavior on a device or simulator per `.ai/rules/device-matrix.md`.

Report which platform you built and which you did not. A change touching both platforms verified on one is half-verified — say that plainly.

## Versioning

- The user-facing version and the build number are release decisions, not implementation details. Do not bump them as part of a feature change unless asked.
- Keep the version consistent across platforms unless the project deliberately diverges.
- A Sentry release must match the shipped build, or every crash from it arrives unsymbolicated. See `.agents/skills/triage-crash/SKILL.md`.

## Release gates

Before a release build:

- No debug statement, temporary flag, or instrumentation left in the diff.
- No non-production endpoint or test credential reachable from a production build.
- Localization regenerated (`yarn lang`) when strings changed, and the new keys present in every locale.
- Crash-free rate for the previous release checked before shipping on top of it.
- Rollback path known: the previous build available, and any migration in this release reversible or forward-compatible.

## Signing and credentials

Keystore files, provisioning profiles, `.p8`/`.p12`, service-account JSON, and signing passwords never enter the repository. See `.ai/rules/security.md`.

A signing or provisioning change is Large / Risky work: plan it and get approval before touching it.
