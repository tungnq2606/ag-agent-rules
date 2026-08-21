---
title: Styling with StyleSheet
impact: MEDIUM
impactDescription: consistent layout, fewer re-created style objects
tags: styling, layout, shadows, gradients, stylesheet
---

## Styling with StyleSheet

Styles go in `StyleSheet.create()`. No Nativewind, no styled-components, no inline style objects in the render path — an inline object is a new reference every render, which breaks memoization on the child receiving it.

**Incorrect:**

```tsx
<View style={{ padding: 16, backgroundColor: theme.card }}>
```

**Correct:**

```tsx
const styles = StyleSheet.create({
  container: { padding: 16 },
})

<View style={[styles.container, { backgroundColor: theme.card }]}>
```

A theme-dependent value that cannot live in the static sheet goes in the array form, kept to the one property that actually varies.

## Spacing

`padding` for space within, `gap` for space between. `gap` on the parent replaces a margin repeated on every child.

```tsx
// Incorrect — margin on each child
<View>
  <Text style={styles.spaced}>Title</Text>
  <Text style={styles.spaced}>Subtitle</Text>
</View>

// Correct — gap on the parent
<View style={styles.stack}>
  <Text>Title</Text>
  <Text>Subtitle</Text>
</View>
```

## Corners

Pair `borderCurve: 'continuous'` with `borderRadius` for smoother corners on iOS. It is inert on Android, so there is no branch to write.

```tsx
{ borderRadius: 12, borderCurve: 'continuous' }
```

## Gradients

Use the project's `GradientView` or `GradientBorderView` from `src/components/` rather than introducing another gradient library. Check them before writing a gradient by hand.

## Shadows

Follow whatever the surrounding components already do, and do not mix approaches within one screen — `shadowColor`/`shadowOffset`/`shadowOpacity` are iOS-only and `elevation` is Android-only, so a component setting just one renders flat on the other platform. React Native 0.77 also accepts the CSS `boxShadow` string, which covers both platforms at once; adopting it is a project-wide decision, not a per-component one.

## Colors

Read colors from the theme. A hardcoded hex works in one theme and fails in the other, and the app ships both. See `.ai/rules/code-style.md`.
