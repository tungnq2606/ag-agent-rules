# Redux — `src/redux/**`

Redux Toolkit 1.9 + redux-saga + redux-persist. Redux holds global/app-wide state only.

## Blocking

- Server data from React Query copied into Redux without a stated reason. Two sources of truth for the same data.
- UI-only state (a sheet's open flag, a local toggle) added to Redux instead of Zustand.
- Persisted slice shape changed with no `version` bump and no migration. Crashes on first launch after update, for existing users only. CRITICAL — see `.ai/rules/native-platform.md`.
- New slice added to the persist whitelist without considering size. Everything persisted is read synchronously at startup.
- Secret, token, or credential persisted into Redux.

## Slices

- `createSlice` for reducers; no hand-written action-type constants.
- Direct assignment outside the Immer draft, or a draft returned *and* mutated in the same reducer.
- Initial state without a type.
- Deeply nested state where a normalized shape (id map + id list) would avoid rewriting a whole branch on every update.

## Selectors

- Selecting a whole slice where the component uses one field — every unrelated update re-renders it.
- Derived value computed in the component instead of a memoized selector.
- Selector returning a new object or array literal each call — a new reference every time, so the equality check never holds.
- `createSelector` whose input selectors themselves return new references, defeating the memoization.

## Sagas

- `takeEvery` where `takeLatest` is meant. Live-score screens fire the same action repeatedly, and stale responses land last.
- No cancellation path — a saga still running after the screen is gone.
- `try/catch` missing around the API call, so a rejection kills the watcher for the rest of the session.
- Error caught and swallowed with no failure action dispatched, leaving the UI in a permanent loading state.
- Business logic in a saga that belongs in a service, or a request issued from the saga rather than `src/services/`.

## Performance

- Several dispatches in a row that could be one action.
- An action dispatched on every frame or every scroll event.
- A reducer doing expensive work (sorting a large list, parsing) that belongs in a selector or a worker.
