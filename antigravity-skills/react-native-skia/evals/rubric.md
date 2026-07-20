# Review rubric

Use this rubric for human review or blind LLM comparison between skill versions.

## 1. Architecture choice

- Did the answer pick retained mode, `Picture`, `Atlas`, textures, `Paragraph`, or shaders for the right reason?
- Did it explain the trade-off clearly?

## 2. Thread discipline

- Are Reanimated shared or derived values used directly on Skia props?
- Is JS-thread churn avoided?
- Are gesture objects and heavy derived constructs memoised where appropriate?

## 3. Visual direction

- Does the element have a clear design concept?
- Is there a sensible motion hierarchy rather than many random moving parts?
- Does the output look intentional rather than like a generic demo?

## 4. Performance reasoning

- Does the answer discuss workload shape (fixed scene vs dynamic command list vs repeated texture)?
- Are big-ticket anti-patterns avoided?
- Is reduced motion handled for decorative or always-on effects?

## 5. Platform completeness

- Does the answer mention web bootstrap, native setup, or asset-loading caveats when relevant?
- Are async image/font/snapshot cases handled properly?

## 6. Delivery quality

- Is the code complete enough to run or patch in?
- Does the explanation say *why* the primitives were chosen?
- Would an engineer trust this as a starting point for production work?
