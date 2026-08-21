---
name: code-review
description: Review a diff before reporting work complete or opening a pull request. Use after writing or modifying code beyond a trivial edit, and when the user asks to review changes, a branch, or a pull request.
---

# Code Review

Review the diff, not the file. What changed is what can break.

Skip this for a copy string, a spacing value, or a local constant. Everything else gets a pass.

## Workflow

1. Read the diff: `git diff` for uncommitted work, `git diff <base>...HEAD` for a branch.
2. Read enough surrounding code to judge each change — a diff hunk alone hides the invariant it violates.
3. Walk the checklists below. Every rule applies to every change; the pass is not done until each has been considered.
4. For each finding, state the concrete failure: the input or state, and the wrong output or crash. A finding you cannot make concrete is a guess — drop it.
5. Fix CRITICAL and HIGH before reporting the work complete. Report MEDIUM and LOW without acting unless the user asks.
6. Verify the fixes per `.ai/rules/verification.md`.

## Severity

| Level | Meaning | Action |
|-------|---------|--------|
| CRITICAL | Crash, data loss, security exposure, or a broken release | Stop. Fix before anything else, and tell the user. |
| HIGH | Wrong behavior, regression, or a leak users will hit | Fix before reporting complete |
| MEDIUM | Maintainability cost, a rule bent without reason | Report; fix when it is in the same file you are already editing |
| LOW | Style, naming, a nit | Report only if asked |

Rank findings by severity, most severe first. Do not pad the list — three real findings beat twelve with nine nits.

## Project invariants

These are the rules this codebase actually breaks. Check each one:

- **State placement.** Redux for global/app-wide, Zustand for UI-only, React Query for server state. Server data copied into Redux without a stated reason is a finding.
- **API location.** Every request lives in `src/services/`. A component calling Axios directly is HIGH.
- **`src/lang/`** is generated. An edit inside it is CRITICAL — it will be overwritten and the string will vanish in another locale.
- **`CustomTouchableOpacity` requires `nameEvent`.** A missing one silently loses analytics.
- **Bottom safe area.** Anything anchored to the bottom preserves the reported inset. A fixed Android padding branch is HIGH — it breaks 3-button navigation. Check for double-counting when a keyboard offset already includes the inset.
- **Existing components.** A new button, modal, gradient, line, or list that duplicates `src/components/` is MEDIUM. Name the existing one.
- **`any`** without recorded user approval is HIGH.
- **New dependency** without recorded user approval is CRITICAL — revert it and ask.
- **Import paths** must exist. An invented path or alias is CRITICAL.
- **Scope.** A bug fix carrying an unrelated refactor is MEDIUM; split it.

## React Native correctness

- Missing cleanup: `useEffect` starting a timer, subscription, listener, or animation without returning a teardown. Leaks and fires after unmount.
- State set after unmount, or after an await whose component may be gone.
- New object, array, or function literal passed as a prop to a memoized child or a list item — kills the memoization it was added for.
- `key` derived from the index while the list can reorder or filter.
- A list rendering an unbounded array through `map` instead of the project's virtualized list.
- Animation driven from JS state where a shared value belongs, or animating a non-GPU property.
- Text not wrapped in `Text`.
- `&&` rendering with a falsy non-boolean left side — renders `0` on Android.
- Platform-conditional code that silently does nothing on the other platform.
- Navigation params typed loosely, or a screen reading a param it never receives.

## Errors, data, and boundaries

- A swallowed error: an empty `catch`, or one that logs and continues into code that needed the value.
- An API response field dereferenced without narrowing when it can be absent or `null`.
- A user-facing error message carrying backend internals.
- A loading or empty state missing, so the screen renders as broken while data is in flight.
- A cache key that collides across environments, users, or locales.

## Security and privacy

Read `.ai/rules/security.md` when the diff touches auth, tokens, user data storage, deep links, push payloads, WebView, network configuration, payments, or native permissions.

Always check: hardcoded secret or key, token in a log or a URL, credential in plain storage, diagnostic logging left behind.

## Hygiene

- Debug statement, commented-out block, or temporary instrumentation left in.
- Function past ~50 lines doing several jobs; file past ~300 lines.
- Nesting past four levels where an early return reads better.
- Dead code the change orphaned.

## Reporting

One line per finding:

```
path/to/file.ts:42 — HIGH: <what breaks, and when>. <the fix>.
```

Then state what you verified and what you deliberately did not.

Say "no findings" plainly when the diff is clean. An invented finding costs more than a silent pass.
