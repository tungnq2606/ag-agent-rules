# Zustand stores — `src/zustand/**`

Zustand holds UI-only, ephemeral state. Anything app-wide belongs in Redux; anything from the server belongs in React Query.

## Blocking

- Server data cached here instead of React Query.
- App-wide state that survives navigation put here instead of Redux.
- A store selected wholesale (`useStore()`), so every field's change re-renders the component. Select the field.
- State that only one component reads, kept in a store instead of `useState`.

## Correctness

- `set` mutating the previous state object instead of returning a new one.
- Derived value stored alongside its source, so the two drift. Derive it in the selector.
- Subscription created outside React with no matching unsubscribe.
- Store never reset on logout while it holds user-specific content.

## Boundaries

- A store reaching into Redux or issuing an API request. Stores hold state; services fetch.
- Two stores holding the same flag. One owner per piece of state.
