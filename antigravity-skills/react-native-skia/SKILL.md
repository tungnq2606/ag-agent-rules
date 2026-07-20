---
name: react-native-skia
description: >-
  Design, build, debug, and optimise high-polish animated graphics in React Native or Expo using @shopify/react-native-skia, Reanimated, and Gesture Handler. Use when the user wants canvas-driven UI, shaders, paths, rich text, image filters, sprite fields, Skottie, video frames, snapshots, web CanvasKit setup, or performance tuning for custom motion-heavy elements such as loaders, hero art, cards, charts, progress indicators, particle systems, or gesture-driven surfaces. Also use when the user asks for fluid, glow, glass, blob, parallax, 60fps/120fps, or GPU-friendly animated effects in React Native, even if they do not explicitly say "Skia". Do not use for ordinary form/layout work with standard views.
compatibility: Designed for skill-compatible coding agents working in React Native or Expo repositories with shell access. Python 3 is recommended for the bundled audit script. Internet access helps with version-specific checks.
metadata:
  version: "2.0.0"
  documentation-snapshot: "2026-03-31"
  primary-doc-site: "shopify.github.io/react-native-skia"
  focus: "animated-elements performance motion-design"
---

# React Native Skia v2

## When to use this skill

Use this skill for React Native or Expo work that depends on `@shopify/react-native-skia`, especially when the user wants a custom animated element, canvas-driven interaction, shader effect, exported graphic, or performance-sensitive motion system.

Reach for it when the request mentions:

- Skia, Canvas, shaders, RuntimeEffect, RuntimeShader, paths, pictures, atlas, Paragraph, snapshots, Skottie, video, CanvasKit, or headless rendering
- visual language such as glass, glow, blob, liquid, particle, shimmer, parallax, neon, morph, premium loader, hero background, or "make this feel expensive"
- frame-rate or interaction concerns such as 60 fps, 120 fps, GPU-friendly, stutter, jank, gesture-driven, or "keep this off the JS thread"

Do **not** use this skill for ordinary layout, forms, lists, settings screens, or standard view animation unless the user clearly wants a Skia or canvas-based solution.

## Default workflow

1. **Audit the repo first in existing projects.**
   - Run:
     ```bash
     python3 scripts/audit_skia_repo.py --root . --format markdown
     ```
   - Read the findings before editing code.

2. **Lock the real constraints up front.**
   - Platforms: iOS / Android / Web
   - Desired feel: ambient, tactile, energetic, technical, playful, premium
   - Interaction model: passive loop, tap, drag, pinch, scrub, scroll-linked
   - Performance expectations: decorative only, hero element, many instances, always-on animation
   - Asset needs: custom fonts, images, video, Lottie JSON, captured React Native views
   - Accessibility: reduced motion, readable text, tappable overlays

3. **If the aesthetic is underspecified, propose 2-3 directions before coding.**
   - Give distinct options with trade-offs such as:
     - **Retained polish:** gradients, blur, layered shapes, safest and simplest
     - **Shader-led:** most distinctive, best for backgrounds and procedural effects
     - **High-instance field:** Atlas or Picture driven, best for particles / sprites / trails
   - Then implement the best fit.

4. **Choose the simplest architecture that satisfies the effect.**
   - Use `references/decision-tree.md`.
   - Default to retained mode.
   - Escalate to `Picture`, `Atlas`, textures, shaders, or headless only when the workload actually needs it.

5. **Implement a complete patch, not fragments.**
   - Update imports, assets, bootstrap code, and fallbacks together.
   - Include null guards for async fonts, images, and video frames.
   - If web matters, include CanvasKit bootstrapping as part of the change.

6. **Review both polish and performance before finishing.**
   - Run the review checklist in `references/performance-playbook.md` and `references/motion-design-playbook.md`.
   - Mention platform caveats, reduced-motion behaviour, and testing steps.

## Hard rules for expert Skia work

- Keep animation state on the UI thread with Reanimated shared or derived values whenever practical.
- Pass shared or derived values **directly** to Skia props. Do **not** wrap Skia nodes with `createAnimatedComponent` or `useAnimatedProps` just to animate them.
- Avoid reading shared values on the JS thread during normal rendering logic.
- Prefer animating `transform`, opacity, shader uniforms, and other non-layout properties over layout-affecting view changes.
- Memoise gesture objects and frame callbacks in component code.
- Use retained mode by default. Use `Picture` when the number of draw commands changes frame to frame. Use `Atlas` when many instances share the same texture. Use texture hooks when a pre-rendered result is reused often.
- Keep business data, theme context, and layout decisions outside the canvas tree unless you explicitly re-inject context.
- Use `Paragraph` for wrapped or multi-style text. Load fonts explicitly when custom families matter.
- Treat `Paragraph`, `Picture`, `Skottie`, and SVG as special cases for effects: use `layer` when you need blur, filters, or other paint effects on them.
- Treat `useImage()` returning `null` as normal. Never assume the image is synchronously ready.
- When capturing React Native content with `makeImageFromView`, keep `collapsable={false}` on the captured root view.
- When using `RuntimeShader` as an image filter, account for pixel density and supersample if the result looks soft.
- On web, gate rendering until CanvasKit has loaded. In Expo web, rerun `setup-skia-web` after Skia upgrades unless CanvasKit comes from a CDN.
- Only use `androidWarmup` for static, fully opaque canvases. Avoid it for animated or translucent scenes.
- Respect reduced motion. Offer a static or lighter fallback when the effect is decorative.

## Motion-design heuristics

Use these rules unless the user asks for a very specific visual style:

- Anchor each scene with **one stable focal layer**. Let one hero motion lead, one secondary motion support, and keep the rest quiet.
- Put **soft, large, low-frequency motion** in the background and **small, sharp highlights** in the foreground.
- Phase-offset loops so everything does not crest at the same time.
- Keep blur and transparency doing compositional work, not hiding weak geometry.
- Place the brightest contrast near the point of action or label, not the canvas edge.
- Clamp gesture-driven motion and spring back to rest states.
- Prefer visuals that can degrade gracefully to a static frame.

See `references/motion-design-playbook.md` for deeper guidance and pattern recipes.

## Deliverable expectations

When you produce code with this skill:

- provide a **full runnable TSX component** or a coherent repository patch
- explain **why** the chosen primitives and rendering mode fit the task
- call out the likely performance profile and any trade-offs
- mention web/native setup needs if relevant
- include reduced-motion behaviour for decorative or always-on motion
- when the request is broad, provide **2-3 concept options first** and then implement the best one

## Bundled resources

- Official doc distillation: `references/official-doc-notes.md`
- Architecture and primitive selection: `references/decision-tree.md`
- Motion direction and polish heuristics: `references/motion-design-playbook.md`
- Performance rules and anti-patterns: `references/performance-playbook.md`
- Symptom-to-fix guide: `references/debugging-matrix.md`
- Pattern cookbook: `references/animated-element-recipes.md`
- Eval workflow notes: `references/eval-strategy.md`
- Ready-to-adapt TSX templates: `assets/templates/`
- Repo audit script: `scripts/audit_skia_repo.py`
- Trigger and output-quality evals: `evals/`

## Quick path by task

### New animated decorative element
1. Read `references/animated-element-recipes.md`.
2. Pick a concept lane from `references/motion-design-playbook.md`.
3. Start from the closest file in `assets/templates/`.
4. Keep the structure retained-mode unless the workload clearly needs `Picture`, `Atlas`, or a shader.

### Gesture-driven surface
1. Confirm `react-native-gesture-handler` and Reanimated are correctly installed.
2. Prefer shared values for transforms and memoised gestures.
3. If per-element hit-testing is needed, use overlay views that mirror the canvas transforms.

### Performance tuning
1. Run `scripts/audit_skia_repo.py`.
2. Read `references/performance-playbook.md`.
3. Decide whether the real problem is JS-thread churn, too many draw nodes, wrong render mode, missing web bootstrap, or expensive filters.
4. Only escalate complexity when there is clear evidence.

### Text or badge UI
1. Prefer `Paragraph`.
2. Load fonts explicitly if typography matters.
3. Keep text crisp; do not bury active text inside broad blur/filter layers.

### Web blank screen or setup problems
1. Check web bootstrap and CanvasKit loading first.
2. Check `setup-skia-web`, Babel/worklets config, and version compatibility before rewriting components.

### Sprite or particle fields
1. Use retained mode only if the structure is fixed and modest.
2. Use `Atlas` for many instances of the same texture.
3. Use `Picture` for dynamic command lists such as trails, generative art, or changing entity counts.
4. Use texture hooks if pre-rendering saves repeated work.
