# Rendering and primitive decision tree

Use this file to decide whether Skia is appropriate and, if so, which architecture to use.

## Step 1: Should this be Skia at all?

Choose **ordinary React Native views** when the task is mainly:

- forms, settings, lists, app chrome, or ordinary layout
- text-heavy UI without special visual treatment
- standard button presses or simple view transitions

Choose **Skia** when the value comes from:

- custom drawing
- shader or filter effects
- gesture-heavy canvas interaction
- exportable graphics or snapshots
- lots of animated visual elements
- exact visual parity across platforms
- a motion-heavy hero surface or decorative system

## Step 2: Pick the rendering mode

### Retained mode (default)

Choose retained mode when:

- the scene structure is mostly fixed
- you animate positions, opacity, radii, trims, colors, or uniforms
- the element behaves like UI, not a mini game engine

Good fits:

- cards
- loaders
- progress rings
- charts with stable geometry
- hero backgrounds with a small set of layered shapes
- gesture-driven panels where transforms change but draw-node count does not

### Immediate mode with `Picture`

Choose `Picture` when:

- the number of draw commands changes every frame
- you need a variable trail, generative art, dynamic scribbles, or particle counts
- you would otherwise create and destroy many draw nodes on every frame

Good fits:

- trails
- changing particle counts
- brush strokes
- generative visuals
- dynamic debug overlays

## Step 3: Pick the right primitive

### `Canvas` + basic shapes

Use when:

- geometry is small and easy to reason about
- you can express the effect with `Circle`, `Rect`, `RoundedRect`, `Path`, `Fill`, and gradients
- you want the most maintainable solution

### `Path`

Use when:

- you already have SVG path data
- you need trim animations or precise vector geometry
- you need morphing between matched path structures

Notes:

- Reuse SVG path data when available.
- For morphing, the paths must be interpolatable: same number and types of commands.

### `Paragraph`

Use when:

- text wraps
- text mixes styles
- custom font families matter
- text metrics or layout width must be controlled

Avoid simpler text nodes when the request includes badges, hero headings, counters with styling, or wrapped labels.

### `Atlas`

Use when:

- many instances share the same texture or sprite
- per-instance transforms vary
- you need hundreds of repeated glyphs, particles, tiles, or sparkles

Typical pattern:

1. create or load one texture
2. reuse it with `Atlas`
3. drive transforms with worklets or shared-value buffers

### Texture hooks

Use when:

- the visual can be pre-rendered once and then reused as an image
- a procedural or composed element should be cached
- an existing image needs GPU upload before heavy reuse

Choose:

- `useTexture()` for texture-from-React-element
- `useImageAsTexture()` for uploaded images
- `usePictureAsTexture()` for prebuilt picture data

### `Shader` / `RuntimeEffect`

Use when:

- the effect is naturally procedural
- the element is mostly a fill or background
- the desired look comes from warping, noise, gradients, or texture sampling

Prefer this for:

- premium backgrounds
- noise overlays
- glows
- procedural liquid or plasma-style effects

### `RuntimeShader`

Use when:

- you need a custom **image filter** over already-rendered pixels
- the effect must inspect and transform the current image content

Notes:

- This is more specialised than plain `Shader`.
- Remember supersampling when crispness matters.

### `makeImageFromView`

Use when:

- you need to capture a React Native view tree and then composite or display it in Skia
- the result mixes normal React Native layout with Skia effects

### `useVideo`

Use when:

- the element should use video frames inside Skia
- video is being filtered, masked, shaded, or composed inside a canvas

### `Skottie`

Use when:

- the source is a Lottie / Bodymovin animation
- programmatic control over playback or slots is required
- design already exists in After Effects

## Complexity ladder

Start low and escalate only when needed:

1. retained shapes + gradients
2. retained shapes + blur / masks / path trim
3. retained shapes + gesture transforms
4. retained shapes + shader fills
5. `Picture` for variable command lists
6. `Atlas` for many repeated instances
7. headless or offscreen textures for export / reuse

## Common pairings

- **Glass card:** retained shapes + clip + blur + subtle gradient + optional spotlight gesture
- **Shimmer CTA:** retained clip + moving gradient band
- **Morphing blob:** `Path` + `usePathInterpolation`
- **Particle field:** `Atlas` or `Picture`, depending on whether texture is shared
- **Image editor / viewer:** `useImage()` + memoised gestures + group transforms
- **Rich badge:** `Paragraph` + explicit fonts + restrained effects
- **Canvas over app UI:** overlay real React Native views for taps and accessibility
