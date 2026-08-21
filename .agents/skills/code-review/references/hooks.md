# Custom hooks — `src/hooks/**`

## Blocking — cleanup

Every one of these leaks, and the leak shows up as a crash or a battery complaint, not as a failing test:

- `setInterval` / `setTimeout` with no `clearInterval` / `clearTimeout`.
- Event listener, `AppState` subscription, or Firebase listener added with no removal.
- In-flight request not aborted on unmount.
- Reanimated or gesture handler left attached.
- State set after unmount, or after an `await` whose component may be gone.

## Dependencies

- Dependency array missing a value the effect reads — stale closure, and the bug appears only after the value changes.
- Dependency array with an object or array literal, so the effect runs every render.
- `useEffect` used to derive state that could just be computed during render.
- Effect that writes state read by the same effect, creating a loop.

## Shape

- Name without the `use` prefix.
- Hook doing several unrelated jobs — split it.
- Return type unstated, so callers guess.
- Returned object or callback recreated every render, forcing consumers to re-render. Stabilize what callers depend on.

## Performance

- Frequent updates (scroll, gesture, live score tick) driving React state instead of a Reanimated shared value or a ref.
- Debounce or throttle missing on an input-driven request.
- Expensive computation without `useMemo` where it is genuinely expensive.

## Boundaries

- Request issued here rather than in `src/services/`.
- Hook reaching into a screen's local concerns, so it cannot be reused.
