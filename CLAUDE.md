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

Skill bodies live in `.agents/skills/`. `.claude/skills/` holds one symlink per skill so the `Skill` tool can discover them; the symlinks carry no content of their own.

Follow the mandatory routing in `AGENTS.md`. A skill reached by routing is read at its `.agents/skills/` path.

When `AGENTS.md` Task Routing says "read and follow" a skill, you MUST read that SKILL.md file in the current session. Do not assume you already know the content from a previous session.

## Completion Enforcement

The **Completion** group in `AGENTS.md` Task Routing (Steps 1-3: diff review, verification, checklist) is mandatory for every non-trivial code change. "Non-trivial" means anything beyond copy/spacing/constant edits. Do not skip these steps to save tokens or because the change "looks correct."

## Global Configuration

`~/.claude/rules/` holds agent-level configuration only — model choice, hooks, editor behavior. It ranks below this repository on every project matter. When something there states a testing policy, review policy, workflow, or code convention for this project, `AGENTS.md` wins; report the stale global rule rather than following it.

## Handoff

When the session becomes large or unfinished work should continue elsewhere, use the shared `handoff` workflow instead of carrying the full conversation forward.

