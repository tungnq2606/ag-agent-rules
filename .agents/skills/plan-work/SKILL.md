---
name: plan-work
description: Plan Large or Risky work before implementation. Persist the plan, present it to the user, and wait for explicit approval before production-code edits.
---

# Plan Work

Use for Large / Risky work as defined in `AGENTS.md`.

## Workflow

1. Inspect only the minimum relevant code and context.
2. If architecture, module boundaries, interfaces, seams, adapters, or responsibility placement are involved, read `.agents/skills/codebase-design/SKILL.md`.
3. If shared/public symbols or downstream effects are unclear, read `.ai/rules/gitnexus.md` and perform targeted impact analysis.
4. Read `.ai/rules/verification.md` and define proportional verification.
5. Resolve only unknowns that could materially change scope, architecture, dependencies, data flow, or risk.
6. Write the plan to `.ai/plans/active/<task-slug>.md`.
7. Present a concise summary to the user.
8. STOP and wait for explicit approval.
9. After approval, implement within the approved scope.
10. If scope, architecture, dependencies, or risk changes materially, update the plan, set status to `NEEDS_REAPPROVAL`, and STOP again.

## Plan Format

Use:

    # <Title>

    Status: PENDING_APPROVAL

    ## Goal

    <What this work must achieve>

    ## Scope

    <What will change>

    ## Out of Scope

    <Important things intentionally not changed>

    ## Proposed Approach

    1. <Step>
    2. <Step>
    3. <Step>

    ## Affected Areas

    - `<path/module>` — <why it is affected>

    ## Risks

    - <Meaningful risk>

    ## Verification

    - <Relevant verification>

Add `Architecture / Data Flow` only when relevant.

Do not paste large code blocks, full diffs, GitNexus output, or conversation history into the plan.

## Interfaces between steps

When steps depend on each other's output — and especially when the work may be finished in a later session or by another agent — name the contract instead of leaving it implied:

    ### Step 3: <name>

    Consumes: `fetchMatchTimeline(matchId: string): Promise<TimelineEvent[]>` from step 2
    Produces: `useMatchTimeline(matchId: string): { events, isLoading }` for step 4

The executor of a step sees the plan, not your reasoning. Exact names and types are how step 4 learns what step 3 called things. A name that drifts between steps — `clearLayers` in one, `clearFullLayers` in another — is a bug planted in advance.

## No placeholders

A step that does not say what to do is not a step. These are plan failures:

- "TBD", "implement later", "fill in details"
- "add appropriate error handling", "handle edge cases", "add validation" — which errors, which cases, validating what
- "same as step N" — repeat it; steps get read out of order
- a reference to a type, function, or file that no step defines
- a step naming an outcome with no indication of where the change goes

Vagueness in a plan converts into invention at implementation time, and invention is what the approval gate exists to prevent.

## Self-review before presenting

Read the plan once against the request, cold:

1. **Coverage.** Every requirement in the request maps to a step. List anything unmapped.
2. **Placeholders.** Scan for the patterns above.
3. **Name consistency.** Types, functions, and files named in later steps match what earlier steps define.

Fix what you find inline. Then present.

## Status

Use only:

- `PENDING_APPROVAL`
- `APPROVED`
- `IN_PROGRESS`
- `NEEDS_REAPPROVAL`
- `COMPLETED`

After explicit approval, set the plan to `APPROVED`.

When implementation begins, set it to `IN_PROGRESS`.

If material scope or risk changes, set it to `NEEDS_REAPPROVAL` and wait for approval again.

After successful implementation and proportional verification, set it to `COMPLETED`.

Move completed plans worth retaining to `.ai/plans/completed/`.

## Rules

- Do not edit production code before explicit approval.
- The original implementation request does not replace the approval gate.
- Do not request reapproval for minor implementation details that stay within the approved scope.
- Keep plans concise and execution-oriented.
- Prefer targeted inspection over broad repository scans.
- Do not use GitNexus or additional skills unless their routing condition applies.
- Do not automatically create documentation after implementation.
- Documentation requires a separate explicit user request.