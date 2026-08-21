# Code & React Native Rules

Read this file when implementing or reviewing application code.

Project-specific rules override generic external skills.

## TypeScript

- Use `interface` for component props.
- Use `type` for other aliases.
- Never use `enum`; use string literal unions.
- Never use `any` without explicit user approval.
- Use `unknown` for data crossing a boundary (API response, deep-link parameter, notification payload, caught error), then narrow it.
- Give exported functions, shared utilities, and service methods explicit parameter and return types. Let local variables infer.
- Type component props with a named `interface`; do not use `React.FC`.
- If a type is unclear, inspect existing types before asking the user.
- TypeScript `strict` is on. Do not weaken it locally to make a change compile.
- No `typecheck` script exists; type-check with `npx tsc --noEmit`.

## Import paths

Aliases are bare, with no `@/` prefix: `components`, `screens`, `routers`, `services`, `hooks`, `utils`, `styles`, `constants`, `config`, `models`, `modules`, `containers`, `assets`, `lang`, `zustands`, `reduxConfig`.

```typescript
import CustomTouchableOpacity from 'components/button/CustomTouchableOpacity'
```

Use the alias instead of a deep relative import. Verify the path exists before using it — `@/components/...` is not a valid alias in this project.

Navigation lives in `src/routers/`, not `src/navigation/`. Zustand stores live in `src/zustands/`.

## Immutability

Return a new value instead of changing the one you were given.

```typescript
// Returns a new object
function withName(user: Readonly<User>, name: string): User {
  return { ...user, name }
}
```

Applies to Redux reducer logic outside Immer's draft, Zustand `set`, arrays (`toSorted`/spread rather than `sort` in place), and any helper receiving an object it does not own. Inside an Immer draft or a `useRef` container, local assignment is the intended pattern.

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

## Localization

The app ships 30+ languages, so every string is a layout risk as well as a translation.

- Never edit `src/lang/` directly; run `yarn lang`.
- Every user-facing string goes through the translation layer. No literal copy in a component.
- Use the i18next plural form (`count`) rather than building a plural with a conditional.
- Interpolate values; never concatenate a translated fragment with a variable, because word order differs per language.
- Format numbers, dates, and relative times through the locale-aware helper, not by string arithmetic.
- Give text room to grow: German and Russian run considerably longer than English, and Vietnamese wraps differently. Prefer flexible height with wrapping over a fixed height, and set `numberOfLines` deliberately when truncation is the intended behavior.
- Check the longest available locale when a layout is tight, not only English.

## Accessibility

- Every pressable needs an `accessibilityLabel` describing the action, plus `accessibilityRole`.
- Give small targets a hit area of at least 44×44, using `hitSlop` when the visual is smaller.
- Icon-only controls need a label — the icon name is not one.
- Announce loading and error state changes so a screen reader user learns the outcome.
- Read colors from the theme so both dark and light stay legible; do not hardcode a hex that only works in one theme.
- Allow text to scale with the OS font-size setting on screens carrying primary content.

## Hygiene

- Do not swallow errors.
- Avoid deep nesting; prefer early returns.
- Do not leave debug statements or temporary instrumentation in production code.
- Do not add dependencies without approval.
- Verify import paths before using them.
- Keep bug fixes focused and avoid unrelated refactors.