---
title: Use CustomTouchableOpacity for Tappable UI
impact: HIGH
impactDescription: consistent press feedback, analytics coverage
tags: ui, touchable, press, analytics
---

## Use CustomTouchableOpacity for Tappable UI

This project taps through `CustomTouchableOpacity` from `src/components/`, not through bare `TouchableOpacity` or `Pressable`. It carries the project's press feedback and, critically, the analytics event.

`nameEvent` is required. A tap without it is invisible in analytics, and nothing at build time catches the omission.

**Incorrect (bare Touchable, no analytics):**

```tsx
import { TouchableOpacity } from 'react-native'

function FollowButton({ onPress }: { onPress: () => void }) {
  return (
    <TouchableOpacity onPress={onPress} activeOpacity={0.7}>
      <Text>Follow</Text>
    </TouchableOpacity>
  )
}
```

**Incorrect (missing `nameEvent`):**

```tsx
<CustomTouchableOpacity onPress={onPress}>
  <Text>Follow</Text>
</CustomTouchableOpacity>
```

**Correct:**

```tsx
import CustomTouchableOpacity from '@/components/CustomTouchableOpacity'

function FollowButton({ onPress }: { onPress: () => void }) {
  return (
    <CustomTouchableOpacity nameEvent="match_detail_follow" onPress={onPress}>
      <Text>Follow</Text>
    </CustomTouchableOpacity>
  )
}
```

Verify the import path and the prop names against the component before using it; do not assume this snippet's shape.

**Hit area.** A visual smaller than 44×44 needs `hitSlop` to reach an accessible target size. See `.ai/rules/code-style.md`.

**Animated press states.** For a press that drives a scale or opacity animation on the UI thread, use `GestureDetector` with Reanimated shared values rather than a style callback — see `animation-gesture-detector-press.md`. Keep the analytics event on the same interaction.
