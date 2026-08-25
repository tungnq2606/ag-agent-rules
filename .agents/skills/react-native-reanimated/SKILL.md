---
name: react-native-reanimated
description: >-
  Build smooth 60fps animations in React Native with Reanimated — run animations
  on the UI thread without JS bridge delays. Use when someone asks to "animate
  in React Native", "Reanimated", "smooth mobile animations", "gesture
  animations", "shared element transitions", or "60fps React Native
  animations". Covers worklets, shared values, layout animations, gestures,
  and scroll-driven animations.
---

# React Native Reanimated

Reanimated 3.17 is already installed in this project. Do not add it again or change the babel config.

This is a **bare React Native 0.77** project — not Expo. Do not use Expo APIs, `className` props, or NativeWind. Use `StyleSheet.create` for all styles.

## When to Use

- Any animation beyond simple opacity/transform
- Gesture-driven interactions (swipe to delete, drag to reorder, pinch to zoom)
- Scroll-driven animations (parallax headers, sticky elements)
- Layout animations (items entering/leaving lists)

## Core Patterns

### Shared Values and Animated Styles

```tsx
import React, { useEffect } from 'react'
import { StyleSheet, ViewProps } from 'react-native'
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withTiming,
  withSpring,
} from 'react-native-reanimated'

interface FadeInCardProps extends ViewProps {
  children: React.ReactNode
}

const FadeInCard = ({ children, style, ...rest }: FadeInCardProps) => {
  const opacity = useSharedValue(0)
  const translateY = useSharedValue(20)

  useEffect(() => {
    opacity.value = withTiming(1, { duration: 600 })
    translateY.value = withSpring(0, { damping: 15 })
  }, [])

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }],
  }))

  return (
    <Animated.View style={[styles.card, animatedStyle, style]} {...rest}>
      {children}
    </Animated.View>
  )
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 12,
    padding: 16,
  },
})
```

### Gesture Animations

```tsx
import React from 'react'
import { StyleSheet } from 'react-native'
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  runOnJS,
} from 'react-native-reanimated'
import { Gesture, GestureDetector } from 'react-native-gesture-handler'

interface SwipeToDeleteProps {
  onDelete: () => void
  children: React.ReactNode
}

const SwipeToDelete = ({ onDelete, children }: SwipeToDeleteProps) => {
  const translateX = useSharedValue(0)

  const pan = Gesture.Pan()
    .onUpdate((event) => {
      translateX.value = Math.min(0, event.translationX)
    })
    .onEnd((event) => {
      if (event.translationX < -150) {
        translateX.value = withSpring(-400)
        runOnJS(onDelete)()
      } else {
        translateX.value = withSpring(0)
      }
    })

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
  }))

  return (
    <GestureDetector gesture={pan}>
      <Animated.View style={animatedStyle}>
        {children}
      </Animated.View>
    </GestureDetector>
  )
}
```

### Scroll-Driven Animations

```tsx
import React from 'react'
import { StyleSheet, Text } from 'react-native'
import Animated, {
  useAnimatedScrollHandler,
  useSharedValue,
  useAnimatedStyle,
  interpolate,
} from 'react-native-reanimated'

const ParallaxHeader = () => {
  const scrollY = useSharedValue(0)

  const scrollHandler = useAnimatedScrollHandler({
    onScroll: (event) => {
      scrollY.value = event.contentOffset.y
    },
  })

  const headerStyle = useAnimatedStyle(() => ({
    height: interpolate(scrollY.value, [-100, 0, 200], [400, 300, 100]),
    opacity: interpolate(scrollY.value, [0, 200], [1, 0.3]),
    transform: [
      { translateY: interpolate(scrollY.value, [0, 200], [0, -50]) },
    ],
  }))

  return (
    <>
      <Animated.View style={[styles.header, headerStyle]}>
        <Text style={styles.headerText}>Header</Text>
      </Animated.View>
      <Animated.ScrollView
        onScroll={scrollHandler}
        scrollEventThrottle={16}
      >
        {/* Content */}
      </Animated.ScrollView>
    </>
  )
}

const styles = StyleSheet.create({
  header: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerText: {
    fontSize: 24,
    fontWeight: 'bold',
  },
})
```

### Layout Animations

```tsx
import React from 'react'
import { StyleSheet, Text } from 'react-native'
import Animated, {
  FadeInDown,
  FadeOutLeft,
  LinearTransition,
} from 'react-native-reanimated'
import CustomTouchableOpacity from 'components/button/CustomTouchableOpacity'

interface AnimatedItemProps {
  item: { id: string; title: string }
  index: number
  onRemove: (id: string) => void
}

const AnimatedItem = ({ item, index, onRemove }: AnimatedItemProps) => (
  <Animated.View
    entering={FadeInDown.delay(index * 100).springify()}
    exiting={FadeOutLeft.duration(300)}
    style={styles.item}
  >
    <Text>{item.title}</Text>
    <CustomTouchableOpacity
      nameEvent="remove_item"
      onPress={() => onRemove(item.id)}
    >
      <Text style={styles.removeText}>Remove</Text>
    </CustomTouchableOpacity>
  </Animated.View>
)

const styles = StyleSheet.create({
  item: {
    padding: 16,
    marginHorizontal: 16,
    marginVertical: 4,
    borderRadius: 8,
  },
  removeText: {
    color: 'red',
  },
})
```

## Rules

- **Animate only GPU properties**: `transform` and `opacity`. Animating `width`, `height`, `margin`, or `borderRadius` drops frames.
- **Shared values, not React state**: `useSharedValue` runs on the UI thread. A value driven from `useState` crosses the bridge every frame.
- **`useDerivedValue`** for computed animated values — never compute inside `useAnimatedStyle`.
- **`runOnJS`** to bridge back to JS — worklets cannot access React state, closures, or JS objects directly.
- **`scrollEventThrottle={16}`** on scroll views driving animations — 60fps events.
- **Babel plugin is already configured** — `react-native-reanimated/plugin` is last in `babel.config.js`. Do not move it.
- **No JS objects in worklets** — only shared values and primitives.
- **Use `GestureDetector`** from `react-native-gesture-handler` for animated press/pan/pinch states — not `TouchableOpacity.onPressIn`.
- **`StyleSheet.create`** for all styles — no inline objects, no `className`.

