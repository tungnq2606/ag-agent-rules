# Antigravity — Uniscore Adapter

The canonical repository instructions are in `AGENTS.md`, which Antigravity also reads. This file adds only what is specific to running here.

Before project work:

1. Read `AGENTS.md`.
2. Read `.ai/memory/COMPACT.md`.
3. If COMPACT declares an active handoff, read `.ai/memory/HANDOFF.md`.
4. Load deeper memory, rules, and skills only when `AGENTS.md` routes to them.

Do not duplicate shared project rules in this file.

## Skills

Workspace skills live in `.agents/skills/` and are the ones this project's routing points at. Read a skill at the path `AGENTS.md` names.

Global skills in `~/.gemini/config/skills/` may duplicate a workspace skill under the same or a similar name. The workspace copy wins — it is the one this repository maintains. `AGENTS.md` §External Skills lists which external skills are adopted and which are retired.

When `AGENTS.md` Task Routing says "read and follow" a skill, you MUST open and read that SKILL.md file using `view_file`. Do not assume you already know the content — workspace skills are project-specific and override any global skill with the same name.

## Completion Enforcement

The **Completion** group in `AGENTS.md` Task Routing (Steps 1-3: diff review, verification, checklist) is mandatory for every non-trivial code change. "Non-trivial" means anything beyond copy/spacing/constant edits. Do not skip these steps to save tokens or because the change "looks correct."

## Efficiency

- Prefer one primary agent for routine work.
- Use additional agents only when independent parallel investigation or context isolation clearly justifies them.
- Avoid broad repository scans; reuse what the session already established.

## Approval

Large / Risky work follows the planning and user-approval gate in `AGENTS.md`. A skill may refine that workflow but must not skip the gate.

