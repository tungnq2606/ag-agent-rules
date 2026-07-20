# Official doc notes for React Native Skia, Reanimated, and Gesture Handler

This file distils the official docs reviewed on 2026-03-31. Re-check version-sensitive items when internet access is available.

## React Native Skia

### Installation and compatibility

- Current installation docs require:
  - `react-native@>=0.79`
  - `react@>=19`
  - `iOS 14+`
  - `Android API 21+`
- Video support needs Android API 26+.
- For older apps (`react-native <= 0.78`, `react <= 18`), stay on `@shopify/react-native-skia@<=1.12.4`.
- The package uses a postinstall step to place prebuilt binaries in native build locations.
- Bun projects must trust `@shopify/react-native-skia` in `trustedDependencies`.
- Yarn Berry must not disable scripts with `enableScripts: false`.
- Expo provides a `with-skia` template for new projects.

### Canvas, renderers, and render modes

- `Canvas` is the root drawing surface and can be styled like a regular React Native view.
- Skia uses its own React renderer. React Native context does not flow into the drawing tree automatically.
- Prefer preparing theme, business data, and layout values outside the canvas tree, or explicitly re-inject context if needed.
- `onSize` writes canvas dimensions into a Reanimated shared value on changes.
- `androidWarmup` is opt-in and is intended for static, fully opaque drawings only.

#### Choosing retained vs immediate mode

- **Retained mode** is the default and is best when the scene structure is stable and only props animate.
- **Immediate mode** is powered by `Picture` and is better when the number of drawing commands changes on each frame.
- Since both modes share the same `Canvas`, you can combine them.

### Animation and gestures

- React Native Skia integrates with Reanimated v3+.
- Shared and derived values can be passed directly to Skia props.
- You do not need `createAnimatedComponent` or `useAnimatedProps` just to animate Skia nodes.
- Gesture integration is documented with `react-native-gesture-handler`.
- For tracking individual canvas elements, the docs recommend overlaying views that mirror the same transforms.

### Geometry and drawing primitives

- `Path` is semantically identical to SVG path data and can be created from SVG strings or programmatically.
- Path trimming uses `start` / `end` values from `0..1`.
- Stroke conversion on a path can fail for hairline paths.
- `Group` applies shared paint, transforms, clipping, and layer effects to descendants.
- Skia transforms differ from React Native view transforms in two ways:
  - default origin is top-left
  - rotations are in radians
- `zIndex` is local to the parent `Group`.

### Text

- Prefer `Paragraph` for wrapped, multi-style, or dependable rich text layout.
- Use `useFonts` for custom font loading when specific families are required.
- `Paragraph` does not follow the same painting rules as regular shapes; effects should be applied through `layer`.
- On web, provide your own emoji font if you need coloured emoji in paragraphs.

### Pictures, atlas, and textures

- `Picture` is a strong fit for dynamic command lists such as trails, procedural scenes, or variable particle counts.
- `Atlas` is the efficient choice for many instances of the same texture or sprite.
- Atlas transforms can be animated with near-zero cost using worklets.
- Texture helpers:
  - `useTexture()` for a texture created from React elements
  - `useImageAsTexture()` for uploading an image to the GPU
  - `usePictureAsTexture()` for converting an `SkPicture` into a reusable texture

### Images, snapshots, and media

- `useImage()` loads bundle assets, named bundle images, or network URLs.
- `useImage()` is asynchronous and returns `null` until ready.
- `makeImageFromView()` captures a React Native subtree into an `SkImage`.
- The captured root should have `collapsable={false}` to avoid crashes or wrong output.
- Canvas refs can create snapshots with `makeImageSnapshot()` or `makeImageSnapshotAsync()`.
- `useVideo()` exposes current video frames as Skia images and works with `Image`, `ImageShader`, and `Atlas`.
- Video is supported on web too.

### Shaders and filters

- `Skia.RuntimeEffect.Make()` compiles shader code.
- Use `Shader` for custom fills.
- Use `RuntimeShader` when you need a custom image filter over already-drawn pixels.
- `RuntimeShader` image filters do **not** handle device pixel density automatically; supersample when crispness matters.

### Web, headless, Skottie, and size

- Web support runs through CanvasKit WASM, loaded asynchronously.
- The current docs quote the CanvasKit WASM payload at about `2.9 MB` gzipped.
- For Expo web, rerun `setup-skia-web` after Skia upgrades unless CanvasKit is loaded from a CDN.
- Load Skia before importing Skia-dependent web components via `WithSkiaWeb` or `LoadSkiaWeb()`.
- Static web canvases can opt into `__destroyWebGLContextAfterRender={true}` to release the WebGL context after drawing.
- Headless mode runs on Node, defaults to CPU rendering, and can use GPU acceleration with an OffscreenCanvas polyfill.
- Skottie renders Lottie/Bodymovin animations and works smoothly with `useClock()` + Reanimated derived values.
- Bundle-size guidance in the docs is order-of-magnitude:
  - about `4 MB` extra Android download size via App Bundles
  - about `6 MB` extra iOS download size
  - about `2.9 MB` gzipped CanvasKit on web

## React Native Reanimated

### Installation and setup

- Reanimated 4.x targets the New Architecture.
- Reanimated 4 requires `react-native-worklets`.
- In Community CLI apps, `react-native-worklets/plugin` must be added to Babel and listed **last**.
- On web, if you are not using the Babel plugin, dependency arrays are required for hooks such as `useDerivedValue`, `useAnimatedStyle`, `useAnimatedProps`, and `useAnimatedReaction`.

### Performance guidance

- Worklets are short-running functions executed on the UI thread.
- Avoid reading shared values on the JS thread during normal React rendering logic.
- Prefer animating non-layout properties (`transform`, `opacity`, etc.) over layout-affecting ones.
- Memoise frame callbacks and gesture objects.
- If you need to animate lots of simultaneously moving visuals, using Skia instead of many individual React components is explicitly recommended.
- iOS 120 fps support depends on `CADisableMinimumFrameDurationOnPhone` in `Info.plist`.
- `useReducedMotion()` lets you synchronously query the system reduced-motion setting.

## React Native Gesture Handler

### Core setup

- Gesture Handler uses the platform native touch system and integrates closely with Reanimated.
- Wrap the app as close to the root as possible with `GestureHandlerRootView`.
- Gestures are not recognised outside that root, and gesture relations only work within the same root view.
- Gesture-driven interactions on the UI thread are documented primarily with Reanimated.

## Source URLs

### React Native Skia

- https://shopify.github.io/react-native-skia/docs/getting-started/installation/
- https://shopify.github.io/react-native-skia/docs/canvas/overview/
- https://shopify.github.io/react-native-skia/docs/canvas/rendering-modes/
- https://shopify.github.io/react-native-skia/docs/canvas/contexts/
- https://shopify.github.io/react-native-skia/docs/animations/animations/
- https://shopify.github.io/react-native-skia/docs/animations/gestures/
- https://shopify.github.io/react-native-skia/docs/animations/hooks/
- https://shopify.github.io/react-native-skia/docs/animations/textures/
- https://shopify.github.io/react-native-skia/docs/shapes/path/
- https://shopify.github.io/react-native-skia/docs/shapes/pictures/
- https://shopify.github.io/react-native-skia/docs/shapes/atlas/
- https://shopify.github.io/react-native-skia/docs/group/
- https://shopify.github.io/react-native-skia/docs/text/paragraph/
- https://shopify.github.io/react-native-skia/docs/images/
- https://shopify.github.io/react-native-skia/docs/snapshotviews/
- https://shopify.github.io/react-native-skia/docs/shaders/overview/
- https://shopify.github.io/react-native-skia/docs/shaders/gradients/
- https://shopify.github.io/react-native-skia/docs/image-filters/runtime-shader/
- https://shopify.github.io/react-native-skia/docs/getting-started/web/
- https://shopify.github.io/react-native-skia/docs/getting-started/headless/
- https://shopify.github.io/react-native-skia/docs/getting-started/bundle-size/
- https://shopify.github.io/react-native-skia/docs/video/
- https://shopify.github.io/react-native-skia/docs/skottie/

### React Native Reanimated

- https://docs.swmansion.com/react-native-reanimated/docs/fundamentals/getting-started/
- https://docs.swmansion.com/react-native-reanimated/docs/guides/worklets/
- https://docs.swmansion.com/react-native-reanimated/docs/guides/performance/
- https://docs.swmansion.com/react-native-reanimated/docs/guides/web-support/
- https://docs.swmansion.com/react-native-reanimated/docs/core/useSharedValue/
- https://docs.swmansion.com/react-native-reanimated/docs/core/useDerivedValue/
- https://docs.swmansion.com/react-native-reanimated/docs/device/useReducedMotion/

### React Native Gesture Handler

- https://docs.swmansion.com/react-native-gesture-handler/docs/
- https://docs.swmansion.com/react-native-gesture-handler/docs/fundamentals/installation/
- https://docs.swmansion.com/react-native-gesture-handler/docs/gestures/use-pinch-gesture/
- https://docs.swmansion.com/react-native-gesture-handler/docs/2.x/gestures/pan-gesture/
