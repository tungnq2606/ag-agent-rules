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