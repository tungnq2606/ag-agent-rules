# Animated element recipes

Use these as pattern shortcuts. Each recipe names the best-fit primitives, the performance profile, and the closest bundled template.

## Premium ambient card

Best when:

- the user wants "premium", "glass", "expensive", or "hero card"
- text or UI sits on top of the animation
- motion should feel calm and continuous

Primitives:

- retained mode
- clipped `Fill` + gradient
- blurred circles / shapes
- thin highlight stroke

Watch out for:

- too many blur layers
- losing foreground contrast
- over-animating the whole card

Template:
`assets/templates/ambient-gradient-card.tsx`

## Shimmer CTA

Best when:

- the element is a button or promo strip
- the user wants a "scan", "shine", or "luxury" motion accent

Primitives:

- retained mode
- clip
- moving gradient band
- crisp foreground label

Watch out for:

- shimmer band too wide
- loop too fast
- too much opacity in the highlight

Template:
`assets/templates/shimmer-cta-button.tsx`

## Morphing organic blob

Best when:

- the user wants fluid, blob, or liquid motion
- the geometry can be expressed as matched paths

Primitives:

- `Path`
- `usePathInterpolation`
- optional glow / soft shadow

Watch out for:

- non-interpolatable paths
- overly aggressive wobble
- too many simultaneous morphs

Template:
`assets/templates/morphing-blob.tsx`

## Progress ring / HUD

Best when:

- the user wants readable status or progress
- motion should support comprehension rather than dominate the scene

Primitives:

- `Path`
- trim animation
- restrained gradients or glow

Watch out for:

- too much blur near the reading surface
- overly decorative animation in data-first contexts

Template:
`assets/templates/progress-ring.tsx`

## Tilt spotlight card

Best when:

- the user wants a tactile interactive card
- subtle pointer-following or drag-following light is enough

Primitives:

- retained shapes
- memoised gestures
- radial gradient spotlight
- shared-value transforms

Watch out for:

- excessive tilt
- no rest state
- gesture math without clamps

Template:
`assets/templates/tilt-spotlight-card.tsx`

## Sprite field

Best when:

- there are many similar instances
- the user asks for sparks, particles, tiles, or repeated glyphs

Primitives:

- `Atlas`
- `useTexture`
- worklet-driven transform buffers

Watch out for:

- drawing each instance as its own view
- generating lots of unique textures unnecessarily

Template:
`assets/templates/sprite-atlas-field.tsx`

## Shader background

Best when:

- the visual is primarily a procedural fill or atmospheric background
- the user wants a more distinctive "signature" effect

Primitives:

- `RuntimeEffect`
- `Shader`
- animated uniforms

Watch out for:

- using shader complexity where retained shapes would do
- burying interactive UI under a loud shader

Template:
`assets/templates/shader-noise-background.tsx`

## Custom-font paragraph badge

Best when:

- typography matters
- the element includes multi-style or wrapped text

Primitives:

- `Paragraph`
- `useFonts`
- explicit font-family mapping

Watch out for:

- assuming fonts are available synchronously
- using a simpler text node and then fighting layout

Template:
`assets/templates/custom-font-paragraph-badge.tsx`

## Pan / zoom image stage

Best when:

- the user wants a gesture-driven image surface
- the image should stay inside Skia for further compositing or filtering

Primitives:

- `useImage`
- memoised `Pan` + `Pinch` gestures
- group transforms

Watch out for:

- missing root gesture setup
- no scale clamps
- rebuilding image state via React state every frame

Template:
`assets/templates/pan-zoom-image-stage.tsx`

## Snapshot composite

Best when:

- the user wants a React Native view captured and then stylised in Skia
- mixed React Native layout + Skia compositing is needed

Primitives:

- `makeImageFromView`
- `Image`
- ordinary React Native subtree with `collapsable={false}`

Watch out for:

- missing `collapsable={false}`
- forgetting that the capture is async

Template:
`assets/templates/snapshot-composite.tsx`


## Video-backed hero surface

Best when:

- the user wants live motion texture rather than procedural motion
- a hero card, backdrop, or promo surface should use video frames inside Skia

Primitives:

- `useVideo`
- `Image` or `ImageShader`
- optional colour grading or filters

Watch out for:

- forgetting that `currentFrame` can be `null`
- missing Android API 26 support on native
- using video where a lighter procedural background would be enough

Template:
`assets/templates/video-frame-surface.tsx`

## Skottie loader or branded motion mark

Best when:

- design already exists as Lottie / Bodymovin JSON
- the user wants a polished loader or branded animation with programmatic control

Primitives:

- `Skia.Skottie.Make()`
- `Skottie`
- `useClock()` + derived frame values
- optional slot or property overrides

Watch out for:

- assuming Skottie follows ordinary paint rules without `layer`
- ignoring reduced-motion fallbacks
- scaling the animation without checking its native size

Template:
`assets/templates/skottie-loader.tsx`
