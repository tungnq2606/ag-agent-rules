# Components — `src/**/*.tsx`

## Blocking

- Import references an export that does not exist. Verify the path and the named export, not just the filename.
- Object or array access without a null check where the value can be absent — `Cannot convert undefined value to object` in production.
- `useEffect` with a timer, listener, subscription, or animation and no teardown returned.
- State written after unmount, or after an `await` whose component may be gone.
- No error boundary around a screen subtree that can throw on unexpected API data.

## Re-render cost

- Inline object, array, or arrow function passed as a prop to a memoized child or a list item. New reference every render, memoization dead.
- `React.memo` missing on a pure component rendered many times (list rows, table cells).
- Event handler recreated per render where a stable reference matters — see [hooks.md](hooks.md).
- Expensive computation in the render body without `useMemo`. Only when it is actually expensive; a `useMemo` around a string concat is noise.
- Context consumed for a value the component does not use, pulling it into every provider update.

## Lists

`AppList` (`components/common/List/AppList`) is the project's virtualized list. Findings:

- `ScrollView` + `map` for data-driven content — HIGH.
- `renderItem` or `keyExtractor` recreated inline instead of a stable reference.
- `keyExtractor` derived from the index while the list can reorder. Live score lists reorder constantly.
- Heterogeneous rows without item typing, so every row pays the tallest row's cost.
- Expensive work inside the item that belongs in the parent or the selector.

## Images

`@d11/react-native-fast-image` is the project's image component for network images.

- Plain `Image` for a remote URL — no cache policy, no priority.
- Missing `resizeMode`.
- No placeholder or error state on an image that can fail.
- Full-resolution asset rendered into a thumbnail slot.

## Touchables

- `TouchableOpacity`, `TouchableHighlight`, or bare `Pressable` instead of `CustomTouchableOpacity` (`components/button/CustomTouchableOpacity`).
- `CustomTouchableOpacity` without `nameEvent` — analytics silently lost. HIGH.
- Tap target under 44×44 with no `hitSlop`.

## Styling

- Style object built inline in the render path rather than `StyleSheet.create()` outside the component. Only the genuinely dynamic property belongs in the array form.
- Hardcoded color instead of a theme value — the app ships dark and light.
- Fixed height on a text container. Translations run longer in German and Russian; it clips.
- `shadow*` without `elevation` or the reverse — flat on the other platform.

## Rendering

- String not wrapped in `Text`.
- `&&` with a falsy non-boolean left side. `{count && <View/>}` renders `0` on Android.
- Conditional that returns `undefined` where a fragment is expected.

## Accessibility

- Interactive element without `accessibilityLabel`.
- Missing or wrong `accessibilityRole`.
- Icon-only control whose label is the icon name rather than the action.
- Loading and error transitions not announced.

## Localization

- Literal user-facing string instead of a translation key.
- Plural built with a conditional instead of the i18next `count` form.
- Translated fragment concatenated with a variable — word order differs per language.
