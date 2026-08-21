---
name: react-native-project-rules
description: React Native implementation rules for this project — lists, animations, rendering, state, styling, navigation, safe area. Use when building or changing React Native UI, list behavior, Reanimated animations, or navigation.
---

# React Native Project Rules

Implementation rules for React Native work in this repository: 28 rules in `rules/`, one per file.

Forked from Vercel's React Native skill and trimmed to this project. The Expo-only rules (expo-image, expo config plugins, Galeria, expo-router) and the monorepo rules were removed because this is a bare React Native 0.77 app. Four rules were rewritten to match this project's components: `ui-pressable`, `ui-styling`, `ui-native-modals`, `list-performance-virtualize`.

`.ai/rules/code-style.md` outranks everything here. When a rule below suggests a component or library this project does not use, follow the project.

## When to read a rule

Read the specific rule file, not all of them. The tables below map a task to its rule.

## Lists — CRITICAL

Live score lists reorder constantly and grow with the data, so these are the rules that actually break this app.

| Rule | What it says |
|------|--------------|
| `list-performance-virtualize` | Use `AppList`, never `ScrollView` + `map`, for data-driven lists |
| `list-performance-item-memo` | Memoize the item component |
| `list-performance-callbacks` | Stabilize `renderItem` and `keyExtractor` |
| `list-performance-function-references` | Define item handlers outside render |
| `list-performance-inline-objects` | No inline style or object props on items |
| `list-performance-images` | Image sizing and caching inside items |
| `list-performance-item-expensive` | Move expensive work out of the item |
| `list-performance-item-types` | Item types for heterogeneous lists |

## Rendering — CRITICAL

| Rule | What it says |
|------|--------------|
| `rendering-text-in-text-component` | Every string lives in a `Text` |
| `rendering-no-falsy-and` | `&&` with a falsy non-boolean renders `0` on Android |

## Animation — HIGH

| Rule | What it says |
|------|--------------|
| `animation-gpu-properties` | Animate `transform` and `opacity` only |
| `animation-derived-value` | `useDerivedValue` for computed animated values |
| `animation-gesture-detector-press` | `GestureDetector` for animated press states |

## Scroll and safe area — HIGH

| Rule | What it says |
|------|--------------|
| `scroll-position-no-state` | Scroll position belongs in a shared value, not state |
| `ui-safe-area-scroll` | Safe area inside scrollable content |
| `ui-scrollview-content-inset` | `contentInset` for headers |

Bottom-anchored UI must preserve the bottom inset, including Android 3-button navigation. That rule lives in `.ai/rules/code-style.md` and is not optional.

## Navigation — HIGH

| Rule | What it says |
|------|--------------|
| `navigation-native-navigators` | Native stack, native header options |
| `ui-native-modals` | Reuse `AppModalV2` / `BottomSheetModal`, or a native presentation |

## UI — MEDIUM

| Rule | What it says |
|------|--------------|
| `ui-pressable` | `CustomTouchableOpacity` with a required `nameEvent` |
| `ui-styling` | `StyleSheet.create`, `gap`, `borderCurve`, theme colors |
| `ui-measure-views` | `onLayout`, not `measure()` |

## State — MEDIUM

| Rule | What it says |
|------|--------------|
| `react-state-minimize` | Fewer subscriptions, fewer re-renders |
| `react-state-dispatcher` | Dispatcher pattern for callbacks |
| `react-state-fallback` | Fallback on first render |
| `state-ground-truth` | One ground truth, derive the rest |
| `react-compiler-destructure-functions` | Destructuring for React Compiler |
| `react-compiler-reanimated-shared-values` | Shared values under React Compiler |

State *placement* — Redux vs Zustand vs React Query — is decided in `AGENTS.md`, not here.

## JavaScript — LOW

| Rule | What it says |
|------|--------------|
| `js-hoist-intl` | Hoist `Intl` construction out of render — matters at 30+ locales |

## Problem → rule

| Symptom | Start with |
|---------|-----------|
| List scroll stutters | `list-performance-virtualize` → `list-performance-item-memo` |
| Item re-renders on every parent render | `list-performance-inline-objects` → `list-performance-callbacks` |
| Animation drops frames | `animation-gpu-properties` → `animation-derived-value` |
| Re-render on every scroll pixel | `scroll-position-no-state` |
| Content hidden behind a header or tab bar | `ui-scrollview-content-inset` → `ui-safe-area-scroll` |
| A stray `0` on screen, Android only | `rendering-no-falsy-and` |
| Tap not tracked in analytics | `ui-pressable` |
| Date or number formatting is slow | `js-hoist-intl` |

For FPS measurement, TTI, bundle size, memory profiling, and native profiling, use `.agents/skills/react-native-best-practices/SKILL.md` instead. This skill is about how to write the code; that one is about how to measure it.
