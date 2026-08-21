# Verification Policy

Verification must be proportional to the actual change and risk.

Do not run expensive checks merely as a ritual.

## Tiny / Local

Examples:

- copy/text
- spacing/style
- local constants
- obvious one-line guards
- trivial isolated UI fixes

Verify by inspecting affected code and the diff.

Normally do not run `yarn test` or full `yarn typecheck`.

Run a check only when the specific change can realistically affect what that check validates.

## Small Logic / Type Change

Examples:

- one component
- one hook
- one utility
- one isolated function
- straightforward local behavior

Verify the affected code/diff.

Run the narrowest relevant test if one exists and provides useful confidence.

Run `yarn typecheck` only when TypeScript contracts may be affected.

Do not run the full test suite by default.

## Medium

Examples:

- multiple related files
- shared hook/service
- contained state logic
- non-trivial feature behavior

Usually run:

- `yarn typecheck`
- relevant targeted tests

Add other checks only when justified by the affected area.

## Large / Risky

Examples:

- cross-module behavior
- architecture/data-flow changes
- shared APIs/state/navigation
- major refactors/migrations

Run:

- `yarn typecheck`
- relevant tests for the changed behavior

Run full `yarn test` only when broad regression risk justifies it.

Large does not automatically mean every available check must run.

## Platform-Specific Checks

After relevant Android/Kotlin changes, use:

`cd android && ./gradlew :app:kaptGenerateStubsStagingDebugKotlin`

For iOS, native, dependency, or environment-configuration changes, read `.ai/rules/build-release.md` — it covers when a native rebuild is required and where the real scheme and variant names live.

Run device/simulator verification when the changed behavior depends on runtime layout, navigation, native APIs, lifecycle, gestures, keyboard behavior, safe areas, notifications, persisted state, or locale. `.ai/rules/device-matrix.md` says which device and OS version the change needs.

## Performance Budget

Performance work needs a number to move. Without one, an optimization cannot be verified and should not be made.

Measure before changing, and report both numbers. Measurement method matters more than the target:

| Dimension | How to measure | Target |
|---|---|---|
| Cold-start TTI | `react-native-performance` markers, cold starts only — exclude warm, hot, and prewarm | not yet recorded |
| Bundle size | production bundle, minified, per platform | not yet recorded |
| List scroll FPS | on the lowest-end supported Android device, never a simulator | no sustained drop below 55 |
| Frame drops during animation | UI-thread frame timing while the animation runs | no dropped frame in a steady-state animation |
| Memory after navigating a flow and returning | heap snapshot before and after, repeated three times | flat, not growing |

Targets marked "not yet recorded" must be measured once on the current release and written down here. An unrecorded target means the first measurement becomes the baseline, not that any number is acceptable.

Profiling method and deeper analysis: `.agents/skills/react-native-best-practices/SKILL.md`.

## Rules

- Prefer targeted checks over full-suite checks.
- Do not repeat a successful check when no relevant code changed afterward.
- If a check is intentionally skipped, state why.
- Report unrelated pre-existing failures separately.
- Do not expand the task only to make unrelated checks pass.