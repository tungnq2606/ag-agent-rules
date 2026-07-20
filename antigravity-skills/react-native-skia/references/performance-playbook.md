# Performance playbook

Use this file when the task is explicitly about performance or when a visually ambitious element risks becoming too expensive.

## 1. Keep work on the right thread

### Preferred

- shared values for animated state
- derived values for computed geometry or props
- worklets for per-frame transforms or buffers
- Skia props driven directly from those values

### Avoid

- React state updates every frame
- reading shared values on the JS thread during ordinary render logic
- routing simple Skia prop animation through `createAnimatedComponent` or `useAnimatedProps`

## 2. Prefer non-layout animation

Cheaper / safer:

- `transform`
- opacity
- radius
- path trim
- gradient positions
- shader uniforms

More expensive / awkward:

- layout-affecting view changes as the main animation vehicle
- rebuilding large React trees for visual-only motion

## 3. Use the right render mode

- **Retained mode**: best default for UI-like animated elements
- **Picture**: when command count changes frame-to-frame
- **Atlas**: when many instances share one texture
- **Texture hooks**: when a composed result should be cached and reused

### Quick smell tests

- Hundreds of identical sparkles? `Atlas`
- Trail length changes every frame? `Picture`
- One premium card with three animated orbs? retained mode
- Procedural animated background? shader or retained shapes, depending on complexity

## 4. Reduce draw-cost before reducing visual ambition

Common wins:

- reuse one blurred orb texture instead of drawing many slightly different ones
- clip once at a parent group instead of repeating clipping on many children
- apply one parent transform instead of many child transforms
- pre-render recurring motifs as textures when reuse is heavy
- memoise paths, paragraphs, and gesture objects

## 5. Handle resources explicitly

- `useImage()` is async; treat `null` as a normal loading state
- custom fonts must be loaded before `Paragraph` construction
- video frames may be `null` until ready
- snapshots and headless work should be explicit, not accidental

## 6. Web-specific guidance

- Gate Skia rendering until CanvasKit is loaded.
- In Expo web, rerun `setup-skia-web` after Skia upgrades unless using a CDN.
- Static canvases can use `__destroyWebGLContextAfterRender={true}` to release the WebGL context after render.
- If Reanimated runs on web without the Babel plugin, remember dependency arrays for `useDerivedValue`, `useAnimatedStyle`, `useAnimatedProps`, and `useAnimatedReaction`.

## 7. Native-specific guidance

- `androidWarmup` is only for static, fully opaque drawings.
- If ultra-smooth 120 fps animation matters on iOS, verify `CADisableMinimumFrameDurationOnPhone`.
- Reanimated 4 requires `react-native-worklets` and correct Babel setup in Community CLI apps.

## 8. Gesture guidance

- Memoise gesture objects.
- Keep transforms in shared values.
- Use `GestureHandlerRootView` close to the app root.
- For element-specific hit regions, mirror transforms onto overlay views.

## 9. Anti-patterns worth flagging immediately

- `interpolateColor` from Reanimated used for Skia colours instead of Skia `interpolateColors`
- `makeImageFromView` without `collapsable={false}` on the captured root
- `RuntimeShader` used as an image filter without considering pixel density
- rich text implemented with ad hoc text nodes instead of `Paragraph`
- large particle systems built as many individual React Native views
- layered blurs and translucency everywhere with no focal hierarchy

## 10. Reduced motion and degradation strategy

For decorative motion:

- provide a static frame or slower version when reduced motion is enabled
- degrade signature effects in layers:
  - remove secondary motion first
  - reduce blur radius second
  - switch to static gradient last

## Final review checklist

Before finishing, ask:

1. Is the chosen render mode the simplest one that works?
2. Are Skia props driven directly from shared/derived values?
3. Is there any avoidable JS-thread churn?
4. Are gesture objects memoised?
5. Are fonts/images/video handled asynchronously and safely?
6. Does web bootstrapping need patching too?
7. Is reduced motion handled?
8. Can the user understand why the implementation is performant?
