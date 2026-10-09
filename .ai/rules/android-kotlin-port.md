# Android Kotlin port

Read when the task touches `android/**/*.kt`, Jetpack Compose, or Gradle for the React Native → Kotlin migration. The condition → skill table lives in `AGENTS.md` under "Android Kotlin (native port)". This file holds the port loop and the mapping.

The RN app is the **behavioural reference**: iOS and RN Android define what a screen must do. Kotlin code reproduces behaviour, not RN structure. A bug already fixed in RN stays fixed in Kotlin: search the project's past-fix and pitfall notes for the area before porting it.

## Port loop (one slice at a time)

1. **Slice**: one screen or one module. Name its RN source files and its data hooks.
2. **Contract**: list the API endpoints, socket events, Redux/Zustand state, MMKV keys and Remote Config flags the slice reads. This list is the Kotlin data layer's spec.
3. **Map** each RN piece with the table below. One skill per row; do not mix patterns inside a slice.
4. **Build** behind a Remote Config or build flag until parity. Done = every item from step 2 is accounted for in Kotlin and the slice matches the Figma/iOS reference.
5. **Verify** per `.ai/rules/verification.md`; use `.agents/skills/android-testing-setup/SKILL.md` for the test harness. List unverified behaviour in the end-of-change "Test:" list.

## RN → Kotlin map

| RN piece | Kotlin target |
|---|---|
| Screen / component | Composable + stateless UI |
| React Query hook | Repository + `Flow` (Retrofit/OkHttp, cache) |
| Redux persist / MMKV | DataStore or MMKV (same keys while both apps ship) |
| Zustand / socket state | `StateFlow` in ViewModel, one owner per screen |
| React Navigation 7, deep links | Navigation 3 |
| Reanimated | Compose animation APIs |
| `AppList` (FlatList) | `LazyColumn` with stable keys |
| Safe area, status bar | Edge-to-edge insets |
| `react-native-iap` | Play Billing Library |
| Hand-written `*Module.kt` bridges | Plain Kotlin classes, bridge deleted |

## Constraints

- RN and Kotlin screens coexist during the migration. Mount a Compose screen from RN through a native Activity or a view manager, and keep one owner of state per feature; never mirror the same state in both worlds.
- Reuse existing native code (notification rendering, live updates, OkHttp/DNS quirks) instead of rewriting it.
- Keep application IDs and flavors unchanged so Play and Firebase see the same app. Read `.ai/rules/build-release.md` before touching Gradle or signing.
- Compose and Navigation 3 need newer Kotlin/AGP than the RN toolchain may pin. A toolchain upgrade is its own Large / Risky change, done first.
- iOS stays on RN. Change JS screens or shared JS contracts for Android-only reasons only when asked.

## Vendored skills

The Android skills come from the official `android/skills` repository (Apache-2.0; license text in `.agents/skills/LICENSE-android-skills.txt`) and the `compose-*` and `kotlin-*` skills from `chrisbanes/skills` (Apache-2.0). Edit them only to add project facts, so a refresh stays a plain overwrite.
