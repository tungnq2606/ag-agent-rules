---
title: Virtualize Every List
impact: CRITICAL
impactDescription: lower memory, faster mount, smooth scroll
tags: lists, performance, virtualization, scrollview, applist
---

## Virtualize Every List

A `ScrollView` with mapped children mounts every item upfront. A virtualizer mounts only what is visible. The gap grows with the data, and match lists in this app grow.

Use the project's existing list abstraction — `AppList` from `src/components/` — or whichever virtualized list the surrounding screens already use. Do not introduce another list library; that is a dependency change and needs explicit user approval.

**Incorrect (every item mounted):**

```tsx
function MatchFeed({ matches }: { matches: Match[] }) {
  return (
    <ScrollView>
      {matches.map((match) => (
        <MatchRow key={match.id} match={match} />
      ))}
    </ScrollView>
  )
}
// 200 matches = 200 rows mounted, ~12 visible
```

**Correct (only visible items mounted):**

```tsx
function MatchFeed({ matches }: { matches: Match[] }) {
  return (
    <AppList
      data={matches}
      renderItem={renderMatchRow}
      keyExtractor={keyExtractor}
    />
  )
}
```

`renderItem` and `keyExtractor` are stable references defined outside the component or wrapped in `useCallback` — see `list-performance-callbacks.md` and `list-performance-function-references.md`.

Verify `AppList`'s actual props before using it rather than assuming this shape.

## Where this applies

Any scrollable content whose length is driven by data: match feeds, standings, search results, notification lists, competition and season lists.

A genuinely fixed, short list — a settings screen with eight rows that will never grow — can stay a `ScrollView`. Data-driven length is the trigger, not item count.

## Keys

`keyExtractor` returns a stable identity from the data. An index-derived key breaks as soon as the list reorders or filters, and live score lists reorder constantly.
