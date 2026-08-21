# Code & React Native Rules

Read this file when implementing or reviewing application code.

Project-specific rules override generic external skills.

## TypeScript

- Use `interface` for component props.
- Use `type` for other aliases.
- Never use `enum`; use string literal unions.
- Never use `any` without explicit user approval.
- If a type is unclear, inspect existing types before asking the user.
- Use project path aliases instead of deep relative imports when aliases exist.

## Components

- Functional components + hooks only.
- Keep files below roughly 300 lines when practical.
- Use `StyleSheet.create()`.
- Avoid inline styles.
- Avoid anonymous render callbacks when a named handler or `useCallback` is appropriate.
- Use memoization only when it has a concrete readability or performance benefit.
- Use `useRef` for mutable values that should not trigger renders.
- For large data sets, prefer the project's existing list abstraction (`AppList`) or established virtualized-list convention before introducing another list library.

## Naming

- Components: PascalCase
- Functions/hooks: camelCase
- Files/folders: kebab-case
- Constants: UPPERCASE
- Boolean values: prefer `is`, `has`, `can`, or `should` prefixes

## State

- Redux → global/app-wide state
- Zustand → UI-only/ephemeral state
- React Query → server state and caching

Do not duplicate React Query server state into Redux without a project-specific reason.

## API

All API calls belong in `src/services/`.

Do not call remote APIs directly from components.

## Existing Components

Search `src/components/` before creating reusable UI.

Important existing components include:

- `CustomTouchableOpacity`
- `GradientView`
- `GradientBorderView`
- `AppList`
- `DropDownSeason`
- `AppModalV2`
- `BottomSheetModal`
- `LineApp`
- `LineCus`
- `LineHeight`

`CustomTouchableOpacity` must receive `nameEvent`.

## Bottom Safe Area

Anything anchored to the bottom must preserve the reported bottom inset, especially Android 3-button navigation.

Preferred patterns include:

- `paddingBottom: Math.max(bottomInset, MIN_GAP)`
- `paddingBottom: BOTTOM_X_HEIGHT + 12`

Never branch away the inset with a fixed Android padding.

If keyboard offset already includes the inset, avoid double-counting it.

## Generated Files

Never edit `src/lang/` directly.

Run `yarn lang` when localization generation is required.

## Hygiene

- Do not swallow errors.
- Avoid deep nesting; prefer early returns.
- Do not leave debug statements or temporary instrumentation in production code.
- Do not add dependencies without approval.
- Verify import paths before using them.
- Keep bug fixes focused and avoid unrelated refactors.