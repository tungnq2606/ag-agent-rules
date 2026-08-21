# Claude Code — Uniscore Adapter

The canonical repository instructions are in `AGENTS.md`.

Before project work:

1. Read `AGENTS.md`.
2. Read `.ai/memory/COMPACT.md`.
3. If COMPACT declares an active handoff, read `.ai/memory/HANDOFF.md`.
4. Load deeper memory, rules, and skills only when `AGENTS.md` routes to them.

Do not duplicate shared project rules in this file.

## Claude-Specific Efficiency

- Prefer the main agent for routine work.
- Do not spawn subagents for small or straightforward tasks.
- Do not automatically invoke broad engineering/debug/review agents for routine changes.
- Use subagents only when independent parallel investigation or context isolation clearly justifies the extra usage.
- Avoid broad repository scans.
- Reuse information already present in the current context.
- Do not repeat MCP/GitNexus calls when existing results already answer the question.

## Skills

Canonical shared skills live in `.agents/skills/`.

Where Claude native skill discovery is required, expose the selected shared skills through `.claude/skills/` without maintaining separate skill bodies.

Follow the mandatory routing in `AGENTS.md`.

When the session becomes large or unfinished work should continue elsewhere, use the shared `handoff` workflow instead of carrying the full conversation forward.
