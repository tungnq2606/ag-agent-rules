# Navigation — `src/routers/**`

React Navigation v7: `@react-navigation/native-stack` for stacks, `@react-navigation/bottom-tabs` for tabs.

## Blocking

- Route params untyped, or a screen reading a param the navigator never passes.
- Param arriving from a deep link or push payload used without validation — route name, param types, and the user's permission to view the target. See `.ai/rules/security.md`.
- Cold-start link dropped because navigation was not mounted yet. Queue it.
- Unrecognised link crashing or landing on a blank screen.
- Android hardware back not handled on a screen or modal that intercepts navigation.

## Structure

- `createStackNavigator` (JS) where `createNativeStackNavigator` is meant.
- Custom `header` component where native header options would do — native gets large titles, blur, and safe area for free.
- A navigator swapped for a new library. That is a dependency change and needs explicit user approval.
- Screen registered twice, or a name string duplicated instead of referenced from the param-list type.

## Performance and memory

- Heavy screen kept mounted when it should detach on blur.
- Expensive work on focus that runs on every return to the screen.
- Listener added on focus with no removal on blur.
- Navigation state held in Redux in parallel with the navigator's own state.

## Safe area

- Bottom-anchored element inside a screen that drops the bottom inset. Android 3-button navigation is where it shows.
- Tab bar height hardcoded rather than read.
