# Motion-design playbook for "amazing but performant" Skia work

This file is intentionally opinionated. Use it when the user asks for something that should feel premium, distinctive, or visually "expensive".

## Start by choosing a concept lane

Pick one primary lane before coding. Mixing three big ideas at once usually produces muddy visuals.

### 1. Premium glass

Mood:

- calm
- layered
- soft depth
- high-end product marketing

Ingredients:

- clipped background gradient
- 2-3 blurred colour orbs
- thin highlight border
- restrained motion with slow drift
- bright focal edge or specular strip

Best for:

- cards
- finance/productivity dashboards
- premium CTA surfaces
- hero modules behind text

### 2. Editorial gradient

Mood:

- expressive
- elegant
- less technical than neon
- easy to keep cheap

Ingredients:

- asymmetric gradients
- one slow moving highlight
- no more than one strong blur layer
- typography kept crisp in foreground

Best for:

- splash blocks
- onboarding
- section headers
- subscription / upsell panels

### 3. Organic liquid / blob

Mood:

- playful
- dynamic
- contemporary

Ingredients:

- matched paths or control-point modulation
- subtle wobble or breathing loop
- optional inner glow or soft shadow
- phase offsets between shape and highlight

Best for:

- loaders
- avatars
- ambient backgrounds
- touch-reactive hero surfaces

### 4. Technical HUD

Mood:

- precise
- data-rich
- instrument-panel feel

Ingredients:

- rings, arcs, ticks, paths, trim animations
- stronger contrast and crisper edges
- minimal blur
- predictable motion that supports reading

Best for:

- progress indicators
- health / sensor panels
- charts
- scanning or status UI

### 5. Particle / sprite field

Mood:

- energetic
- playful
- spatial

Ingredients:

- many repeated instances
- coherent flow field or pointer attraction
- one small repeated texture
- minimal per-instance complexity

Best for:

- interactive hero backgrounds
- sparkle / dust effects
- playful loaders
- maps or tile-like compositions

## Core composition rules

### Use one hero motion

Good animated elements usually have:

- one hero motion
- one supporting motion
- one still anchor

Example:

- hero motion: drifting orb
- support: moving highlight band
- anchor: crisp card edge + label

### Keep the focal area readable

- Do not place the brightest highlight behind body text.
- Do not blur text unless the blur is explicitly part of the design and readability is preserved.
- Treat active labels and icons as foreground UI, not decoration.

### Use blur as depth, not camouflage

Blur is strongest when it:

- separates back and front layers
- softens large background masses
- adds luminous bloom

Blur is weakest when it:

- replaces good geometry
- covers the entire frame evenly
- touches core text or action affordances

### Use asymmetry

Symmetry often reads as synthetic and cheap once animated. Prefer:

- slightly offset orbs
- uneven timing
- gradients not centred by default
- highlights that track an interaction or bias toward a corner

### Keep loops phase-shifted

If two animated layers use the same period, offset them or give them different amplitudes. Synchronous loops feel robotic.

## Timing guidance

These are starting points, not hard rules.

- Ambient drift: `3000-8000 ms`
- Loader cycles: `900-1600 ms`
- Microinteraction emphasis: `160-280 ms`
- Spring-back after drag: fast enough to feel connected, soft enough to avoid snap

Prefer easing that matches the concept lane:

- premium glass: slow in-out
- liquid / blob: soft in-out or spring
- technical HUD: more linear, measured timing
- shimmer: constant travel, not bouncing

## Gesture design rules

- Clamp all gesture-driven offsets.
- Use the gesture to modulate a stable scene, not completely rebuild it.
- The resting state should look intentional.
- Interactive depth should usually be subtle; avoid theatrical tilt unless explicitly requested.

## Fallback tiers

Always know the lighter version.

### Tier A: cheapest

- static gradient
- single subtle highlight
- no blur or one small blur
- reduced motion or low-end fallback

### Tier B: standard premium

- retained-mode layered shapes
- slow shared-value animation
- restrained blur
- best default for most product UI

### Tier C: signature effect

- shader, Atlas, or Picture
- higher implementation complexity
- reserve for hero surfaces or user-facing brand moments

## When the user says "make it amazing"

Translate that into explicit design moves:

- add depth, not just more colour
- add a motion hierarchy, not just faster motion
- add a clear focal point
- add one signature flourish that can be explained in plain language

Good answer pattern:

1. offer 2-3 concept directions
2. explain the trade-offs
3. implement the strongest fit
4. mention one lighter fallback
