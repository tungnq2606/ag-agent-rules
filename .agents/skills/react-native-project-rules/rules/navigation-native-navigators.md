---
title: Use Native Navigators
impact: HIGH
impactDescription: UI-thread transitions, platform-correct behavior
tags: navigation, react-navigation, native-stack
---

## Use Native Navigators

Native navigators drive transitions through platform APIs — `UINavigationController` on iOS, Fragments on Android — so the animation and gesture run on the UI thread instead of over the JS bridge.

The project uses React Navigation v7. For stacks, that means `@react-navigation/native-stack`, not `@react-navigation/stack`.

**Incorrect (JS stack):**

```tsx
import { createStackNavigator } from '@react-navigation/stack'

const Stack = createStackNavigator()
```

**Correct (native stack):**

```tsx
import { createNativeStackNavigator } from '@react-navigation/native-stack'

const Stack = createNativeStackNavigator()

function RootNavigator() {
  return (
    <Stack.Navigator>
      <Stack.Screen name="Home" component={HomeScreen} />
      <Stack.Screen name="MatchDetail" component={MatchDetailScreen} />
    </Stack.Navigator>
  )
}
```

Follow the navigator setup the project already has rather than introducing a second pattern beside it. Swapping the tab navigator for a native-tabs library is a dependency change and needs explicit user approval.

## Prefer native header options over a custom header

**Incorrect:**

```tsx
options={{ header: () => <CustomHeader title="Profile" /> }}
```

**Correct:**

```tsx
options={{
  title: 'Profile',
  headerLargeTitleEnabled: true,
  headerSearchBarOptions: { placeholder: 'Search' },
}}
```

Native headers handle large titles, search bars, blur, and safe area without a custom layout. Reach for a custom header only when the design genuinely cannot be expressed through the options.

## Screen params

Type screen params explicitly, and validate anything arriving from a deep link or a notification before using it — those params are untrusted input. See `.ai/rules/native-platform.md` and `.ai/rules/security.md`.

## Why

- Transitions and gestures run on the UI thread.
- Platform behavior comes free: iOS large titles, Android back handling, scroll-to-top on tab tap, safe areas.
- Platform accessibility features work without extra wiring.

Reference: [React Navigation Native Stack](https://reactnavigation.org/docs/native-stack-navigator)
