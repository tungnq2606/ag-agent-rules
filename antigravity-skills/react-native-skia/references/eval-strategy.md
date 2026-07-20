# Eval strategy for this skill

This skill ships with:

- `evals/evals.json` for output-quality checks
- `evals/trigger-train.json` for description tuning
- `evals/trigger-validation.json` for held-out trigger validation
- `evals/rubric.md` for human or LLM review

## How to iterate

1. Run the trigger sets multiple times and compute trigger rates.
2. Improve the `description` using only failures from the train split.
3. Re-check on the validation split.
4. Run the output-quality evals with and without the skill (or against the previous skill version).
5. Use the rubric to compare visual polish, architecture choice, and performance reasoning, not just syntax.

## What this skill should outperform

A strong run should consistently:

- choose retained mode, `Picture`, `Atlas`, or shader approaches for the right reasons
- keep Reanimated state on the UI thread
- avoid `createAnimatedComponent` / `useAnimatedProps` around Skia nodes
- remember web bootstrap and snapshot caveats
- address reduced motion for decorative or always-on motion
- produce visually directed output rather than generic examples

## High-value failure patterns to watch

- returns valid Skia code but with no aesthetic concept
- uses the wrong render mode for the workload
- animates via React state or JS-thread churn
- forgets `GestureHandlerRootView` or `LoadSkiaWeb`
- uses generic text nodes when `Paragraph` is clearly the right API
- answers "performance" questions without talking about render mode or workload shape
