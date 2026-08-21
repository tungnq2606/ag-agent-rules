---
name: diagnosing-bugs
description: Diagnose difficult bugs when targeted inspection does not reveal a clear root cause. Use for intermittent failures, multiple plausible hypotheses, unclear regressions, or issues requiring reproduction or instrumentation.
---

# Diagnosing Bugs

Use only when the root cause is not clear after targeted inspection.

Do not use this workflow for obvious local bugs with a clear cause.

## Workflow

1. Define the observed behavior and expected behavior.
2. Find the smallest practical reproduction or feedback loop.
3. Gather evidence before expanding the investigation.
4. List a small number of plausible hypotheses, ranked by likelihood.
5. Test the highest-value hypothesis first.
6. Narrow the search based on evidence.
7. Identify the root cause before making a broad fix.
8. Implement the smallest fix that addresses the confirmed cause.
9. Verify according to `.ai/rules/verification.md`.

## Feedback Loop

Choose the smallest useful feedback loop for the bug.

Depending on the issue, this may be:

- a targeted unit or integration test;
- reproducible simulator/device steps;
- runtime logs;
- temporary instrumentation;
- assertions;
- React Native profiler output;
- network inspection;
- a minimal reproduction harness.

For visual, lifecycle, gesture, keyboard, safe-area, or native-platform bugs, a reliable device/simulator reproduction may be more useful than forcing a unit test.

Do not require a regression test when the project verification policy does not justify one.

## Multi-layer failures: instrument the boundaries

When the failure crosses components — JS → native module, saga → service → API, CI → build → signing, notification → navigation — do not guess which layer breaks. Log at each boundary once, then read.

For each boundary: what value enters, what value exits, and whether the config or environment propagated. One run tells you which layer fails; only then investigate that layer.

This replaces a sequence of hypotheses about five layers with one measurement.

## Three failed fixes means the design is wrong

Count the fixes you have attempted.

Under three: return to evidence, form a new hypothesis with what the failed fix taught you.

At three, stop. Do not attempt a fourth. The pattern where each fix reveals a new problem somewhere else, or where the next fix would need a large refactor, is not a run of bad hypotheses — it is a design that cannot hold the behavior being asked of it.

Say so to the user, name what the three attempts revealed, and route through `.agents/skills/plan-work/SKILL.md` rather than continuing to patch.

## Investigation

Start narrow.

Prefer:

1. the failing code path;
2. direct callers/callees;
3. relevant state or data flow;
4. targeted logs or runtime evidence;
5. GitNexus only when dependency or blast-radius information is needed.

Do not broadly scan the repository before forming a concrete hypothesis.

If shared/public symbols or downstream effects become relevant, read `.ai/rules/gitnexus.md`.

## Hypotheses

Keep hypotheses explicit and evidence-based.

Example:

    1. State is stale after returning from background.
       Evidence: value changes only after remount.

    2. Query cache is not invalidated.
       Evidence: API response is correct but UI keeps previous data.

Avoid changing multiple unrelated areas at once to "see if it works."

Prefer experiments that distinguish between hypotheses.

## Fix

Once the root cause is confirmed:

- fix the cause, not only the visible symptom;
- keep the change minimal;
- avoid unrelated refactors;
- preserve existing architecture unless the root cause requires a broader change.

If the required fix becomes Large / Risky, stop debugging implementation and route through `.agents/skills/plan-work/SKILL.md`.

## Temporary Debugging Code

Temporary logs, instrumentation, flags, or assertions may be used during diagnosis.

Remove temporary debugging code before completion unless it has clear long-term value.

Do not leave sensitive data in logs.

## Verification

After the fix:

- reproduce the original failure scenario;
- confirm the expected behavior;
- check the nearest meaningful regression scenario;
- follow `.ai/rules/verification.md`.

Do not automatically run the full test suite.

## Rules

- Evidence before speculation.
- Prefer one strong feedback loop over many weak checks.
- Do not invoke subagents merely because debugging is difficult.
- Do not repeat tool calls that already established the same fact.
- Separate confirmed facts from assumptions.
- Do not expand the scope beyond the confirmed root cause without a reason.
- Do not automatically create documentation after fixing the bug.