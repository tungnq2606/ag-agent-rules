# Agent Performance

> Agent-level guidance only. A repository's `AGENTS.md` and its project rules outrank everything here.

## Model Selection Strategy

Current family is Claude 5 (`claude-opus-5`, `claude-sonnet-5`, `claude-fable-5`) plus `claude-haiku-4-5-20251001`.

- **Haiku 4.5** — lightweight, frequently invoked agents; mechanical worker steps in a multi-agent run.
- **Sonnet 5** — main development work, orchestration, most coding tasks.
- **Opus 5** — architectural decisions, hardest reasoning, research and analysis.

Default to the session model. Override only when a specific tier clearly fits the step.

## Context Window Management

Keep the last 20% of the window free for:

- large-scale refactoring
- feature work spanning many files
- debugging interactions across modules

Low-sensitivity tasks that can run near the limit: single-file edits, independent utilities, documentation updates, simple bug fixes.

## Extended Thinking

Extended thinking is on by default.

- Toggle: Option+T (macOS) / Alt+T (Windows/Linux)
- Config: `alwaysThinkingEnabled` in `~/.claude/settings.json`
- Budget cap: `export MAX_THINKING_TOKENS=10000`
- Verbose: Ctrl+O

## Build Failures

Read the first failing error rather than the last, fix incrementally, and re-run the same check after each fix.
