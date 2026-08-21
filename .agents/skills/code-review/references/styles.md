# Styles — `src/styles/**` and theme usage

## Blocking

- Hardcoded color. The app ships dark and light; a literal hex is correct in at most one of them.
- `StyleSheet.create()` called inside a component or inside a render callback — a new sheet per render.
- Fixed height on a container holding translated text. German and Russian run longer; it clips at 30+ locales.

## Conventions

- Style objects in `StyleSheet.create()` outside the component. Only the genuinely dynamic property goes in the array form.
- `gap` on the parent rather than a margin repeated on every child.
- `borderCurve: 'continuous'` paired with `borderRadius`.
- Spacing and typography from the project scale, not ad-hoc numbers.
- Gradients through `GradientView` / `GradientBorderView`, not a new gradient library.

## Cross-platform

- `shadow*` set without `elevation`, or the reverse — flat on the other platform. Do not mix approaches within one screen.
- Platform-specific branch where a single value would work.
- Dimensions read once at module scope instead of `useWindowDimensions`, so rotation and split-screen break.

## Animation

- `useAnimatedStyle` for Reanimated-driven values; a plain style object recomputed on the JS thread is a dropped frame.
- Animating a layout property (`width`, `height`, `top`) where `transform` and `opacity` would do.
