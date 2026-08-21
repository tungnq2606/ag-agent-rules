# TypeScript — `src/**/*.ts`

`strict` is on (extends `@tsconfig/react-native`). There is no `typecheck` script; check with `npx tsc --noEmit`.

## Blocking

- `any` without recorded user approval.
- Non-null assertion `!` with no preceding check. It compiles and crashes at runtime.
- `as` cast that changes the shape rather than narrowing it — a cast hiding a real mismatch.
- `@ts-ignore` or `@ts-expect-error` without a comment saying why and what would remove it.
- Import path that does not resolve. Aliases are bare: `services/...`, `components/...`, never `@/...`.
- `strict` weakened locally to make the change compile.

## Types

- Exported function, shared utility, or service method without explicit parameter and return types. Local variables may infer.
- `interface` for component props; `type` for unions, intersections, and other aliases.
- `enum` anywhere — the project uses string literal unions. A new `enum` is a finding.
- Repeated inline object shape that should be a named type.
- Union state modelled as several optional booleans instead of a discriminated union, so impossible combinations typecheck.

## Boundaries

- Data crossing a boundary typed as its optimistic shape rather than `unknown` then narrowed. API responses, deep-link params, push payloads, persisted values, caught errors.
- `catch (error)` used as though it were an `Error`. It is `unknown`; narrow before reading `.message`.
- A declared non-optional field that the backend can omit. The type lies and the crash is at the call site, not here.

## Errors

- Empty `catch`.
- `catch` that logs and then continues into code that needed the value.
- Error re-thrown after losing its cause.
- Error message carrying backend internals into the UI.

## Immutability

- In-place mutation of a parameter the function does not own.
- `sort`, `splice`, `reverse`, or `push` on an array received from props, a selector, or a store.
- Direct assignment into Redux state outside an Immer draft.
