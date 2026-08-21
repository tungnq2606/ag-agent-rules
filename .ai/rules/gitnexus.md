# GitNexus Usage

Project: `uniscore-mobile`.

Use GitNexus proportionally. Do not call it for every touched symbol.

## Impact Analysis

Run impact analysis before implementation when:

- changing shared/public functions, classes, hooks, services, or stores;
- changing navigation contracts;
- refactoring behavior with unclear callers;
- changing multiple modules;
- downstream effects are not obvious;
- the user requests blast-radius/risk analysis.

Impact analysis is optional for:

- local/private helpers;
- copy/style/layout-only changes;
- obvious isolated low-risk fixes.

If impact is HIGH or CRITICAL:

1. report the meaningful blast radius;
2. stop before implementation;
3. wait for user approval.

If the task already requires a plan, include the impact result in the plan.

## Exploration

For unfamiliar cross-module behavior, prefer targeted GitNexus `query` over broad repository scanning when it can answer the question efficiently.

Use symbol `context` only when caller/callee/process information is actually needed.

Do not call `context` merely because a function is being edited.

## Refactoring

Use GitNexus semantic rename for meaningful symbol renames.

Do not use blind global find-and-replace for semantic renames.

## Change Verification

Before committing meaningful code changes, use `detect_changes()` to verify expected affected symbols and execution flows.

For regression comparison against the normal development branch, use `app-develop` as the base when appropriate.

Do not run `detect_changes()` for trivial non-code edits unless the commit workflow specifically requires it.

## Existing GitNexus Skills

Use GitNexus-specific skill/reference material only when the corresponding GitNexus workflow is actually needed.

Do not load all GitNexus skills at session start.