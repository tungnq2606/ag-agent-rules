# API services — `src/services/**`

Axios + React Query 5. Every request lives here; a component calling Axios directly is a finding in the component, not here.

## Blocking

- Base URL, key, or token hardcoded instead of read from the `ENVFILE` config.
- Response field dereferenced without narrowing when the backend can omit it or send `null`.
- Token or full response body written to a log.
- HTTP used instead of HTTPS, or a cleartext exception added for convenience.
- Error swallowed so the caller cannot distinguish success from failure.

## Request shape

- No timeout. A live-score request that hangs holds the screen in loading forever.
- No cancellation on unmount — `AbortController` or the React Query signal.
- Retry without backoff, or retry on a non-idempotent call.
- Polling interval that keeps running when the screen is not focused, or when the app is backgrounded. Battery and data.
- Several sequential awaits that could run concurrently.
- The same request fired from two places instead of one shared query key.

## React Query

- Query key missing a variable the request depends on — two different requests share a cache entry.
- Query key that does not include the environment or locale where the response varies by them.
- `staleTime` and `gcTime` left at defaults on live data, so the screen either refetches constantly or shows stale scores.
- Mutation with no invalidation, so the list the user just changed still shows the old value.
- `retry` left on for a request whose failure is expected (a 404 lookup), turning a fast negative into a slow one.
- Server state duplicated into Redux or a Zustand store after the query resolves.

## Error handling

- Network failure, HTTP status failure, and parse failure treated identically when the UI should differ.
- Offline not handled where the flow can be reached offline.
- Backend error text passed straight to the UI.
- 401 handled per call site instead of once in an interceptor.

## Types

- Response typed as its optimistic shape rather than narrowed from `unknown`.
- Model type defined here duplicating one in `src/models/`.
