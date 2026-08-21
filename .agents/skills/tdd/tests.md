# Tests and mocking

Reference for the red → green loop in this project. Consulted from `SKILL.md`, not read at session start.

Runner is Jest with the React Native preset. Component tests use `@testing-library/react-native` when the project already has it — verify before importing rather than assuming.

## Shape of a test

Arrange, act, assert, in that order, with the assertion reading like the capability under test.

```typescript
test('shows the live minute while a match is in play', () => {
  // Arrange
  const match = buildMatch({ status: 'inplay', minute: 63 })

  // Act
  render(<MatchRow match={match} />)

  // Assert
  expect(screen.getByText('63′')).toBeTruthy()
})
```

The name states the behavior, not the mechanism. `'shows the live minute while a match is in play'` survives a rewrite of `MatchRow`; `'renders minute Text when status is inplay'` does not.

## Expected values come from outside the code

The assertion must be able to disagree with the implementation.

```typescript
// Tautological: recomputes the result the way the code does, so it always passes
expect(formatScore(home, away)).toBe(`${home} - ${away}`)

// Independent: a literal from the spec
expect(formatScore(2, 1)).toBe('2 - 1')
```

A snapshot written by running the code and accepting the output is the same failure in a bigger costume. Snapshot only what a human read and agreed was correct.

## Builders over fixtures

Give each test a builder with defaults so the test body names only the fields it cares about.

```typescript
function buildMatch(overrides: Partial<Match> = {}): Match {
  return { id: '1', status: 'notstarted', minute: null, ...overrides }
}
```

A shared mutable fixture object couples tests to each other; a builder returning a fresh object does not.

## Mocking

Mock at the seam the module already depends on, and mock as little as possible.

**Mock**: the network boundary, the clock, native modules, and anything non-deterministic.

**Do not mock**: the module under test, its private collaborators, or a store you could simply populate with real state. Mocking an internal collaborator is how a test starts passing while the behavior is broken.

```typescript
// Network boundary — mock the service, not Axios internals
jest.mock('services/match-service', () => ({
  fetchMatch: jest.fn(),
}))

// Time — freeze it rather than asserting on Date.now()
jest.useFakeTimers().setSystemTime(new Date('2026-01-01T12:00:00Z'))
```

Native modules that appear in almost every render path (MMKV, Notifee, Firebase, Reanimated) belong in the Jest setup file once, not re-mocked per test. Check the existing setup file before adding another mock.

React Query needs a fresh `QueryClient` per test with retries off, otherwise a failing query retries into a timeout and the failure reads as a hang:

```typescript
const client = new QueryClient({ defaultOptions: { queries: { retry: false } } })
```

## What not to test

- Styling values, layout numbers, and snapshot trees of whole screens — they change constantly and the failure never tells you what broke.
- Third-party library behavior. Test your use of it, not it.
- Navigation wiring, unless the wiring itself holds the logic under test.

Prefer a device or simulator run for gesture, keyboard, safe-area, lifecycle, and native behavior. A unit test that mocks all of those verifies the mock.
