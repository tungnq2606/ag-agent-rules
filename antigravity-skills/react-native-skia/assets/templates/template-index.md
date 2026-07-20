# Template index

These templates are starting points, not one-size-fits-all answers.

## Visual surfaces

- `ambient-gradient-card.tsx` — premium ambient card with blurred orbs
- `shimmer-cta-button.tsx` — clipped shimmer button with paragraph label
- `shader-noise-background.tsx` — procedural shader background
- `morphing-blob.tsx` — path interpolation for organic motion
- `tilt-spotlight-card.tsx` — gesture-led spotlight / card depth
- `video-frame-surface.tsx` — video-backed hero / media surface
- `skottie-loader.tsx` — Lottie/Skottie playback with runtime tinting

## Data / status / text

- `progress-ring.tsx` — animated ring / HUD pattern
- `custom-font-paragraph-badge.tsx` — wrapped rich text with explicit font loading

## Interaction / high-instance patterns

- `pan-zoom-image-stage.tsx` — memoised pan + pinch image surface
- `sprite-atlas-field.tsx` — repeated textured sprites via `Atlas`
- `snapshot-composite.tsx` — capture React Native content into Skia

## Adaptation advice

1. Preserve the architecture choice unless the workload changes.
2. Rename colours, dimensions, and copy to match the product.
3. If the user asks for "lighter" or "safer", remove secondary motion before rewriting the whole component.
4. If the user asks for "more premium", strengthen hierarchy and lighting before adding more moving parts.
