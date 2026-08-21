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

Run device/simulator verification when the changed behavior depends on runtime layout, navigation, native APIs, lifecycle, gestures, keyboard behavior, safe areas, or platform-specific code.

## Rules

- Prefer targeted checks over full-suite checks.
- Do not repeat a successful check when no relevant code changed afterward.
- If a check is intentionally skipped, state why.
- Report unrelated pre-existing failures separately.
- Do not expand the task only to make unrelated checks pass.