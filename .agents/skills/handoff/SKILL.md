---
name: handoff
description: Create a compact cross-session or cross-agent handoff for unfinished work. Use when work is moving to another session or agent, or when the current context has grown too large.
---

# Handoff

Use for unfinished work that must continue in another session or with another agent.

The shared handoff file is:

`.ai/memory/HANDOFF.md`

## Workflow

1. Read `.ai/memory/COMPACT.md`.
2. Read the active plan if one exists.
3. Inspect only the current task state needed to continue safely.
4. Write or update `.ai/memory/HANDOFF.md`.
5. Keep the handoff concise and agent-neutral.
6. Update `.ai/memory/COMPACT.md` only if the active task, plan pointer, or handoff pointer materially changed.

## Handoff Format

Use:

    # Handoff

    Status: ACTIVE

    ## Goal

    <What the current task is trying to achieve>

    ## Active Plan

    <Path to the active plan, or None>

    ## Completed

    - <Meaningful completed work>

    ## Current State

    <Where the work currently stands>

    ## Key Files

    - `<path>` — <why it matters>

    ## Verified Facts

    - <Fact confirmed from code, tools, tests, or runtime>

    ## Assumptions / Unverified

    - <Anything not yet confirmed>

    ## Verification Already Done

    - <Checks already completed>

    ## Blockers / Open Questions

    - <Anything preventing safe continuation>

    ## Next Step

    <The single best next action>

    ## Suggested Skills

    - `<skill>` — <why it may be useful>

## Rules

- Distinguish verified facts from assumptions.
- Do not copy full plans, diffs, commits, ADRs, or large code blocks into the handoff.
- Reference existing artifacts by path instead.
- Do not include secrets, credentials, tokens, or sensitive values.
- Do not repeat information already available in the active plan unless needed for immediate continuation.
- Prefer one clear next step over a long task list.
- Keep the handoff useful for Claude Code, Codex, Antigravity, or any future compatible agent.
- Do not create feature documentation as part of handoff.
- Documentation requires a separate explicit user request.

## Completion

When the unfinished work is completed:

- set `Status: NONE`;
- remove obsolete continuation details;
- keep `.ai/memory/COMPACT.md` consistent with the cleared handoff state.

The handoff is temporary continuation state, not long-term project documentation.