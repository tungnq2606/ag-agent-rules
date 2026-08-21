# Uniscore Mobile — Agent Instructions

This is the canonical instruction file for all coding agents in this repository.

Agent-specific files such as `CLAUDE.md` and `.agents/AGENTS.md` are adapters only. Keep shared project rules here or in the referenced on-demand files; do not duplicate them across adapters.

## Project

Uniscore is a React Native sports app for live scores and match details across 11+ sports, 30+ languages, dark/light themes, and dev/staging/beta/production environments.

Core stack: React Native 0.77.3, TypeScript strict, Redux Toolkit + redux-saga, Zustand, React Query + Axios, Notifee, Firebase, MMKV, Sentry, i18next, React Navigation v7.

## Always-On Invariants

- Redux is for global/app-wide state.
- Zustand is for UI-only state.
- React Query is for server state and caching.
- API calls belong in `src/services/`, never directly in components.
- Never edit `src/lang/` directly; use `yarn lang`.
- Never use `any` without explicit user approval.
- Never add dependencies without explicit user approval.
- Prefer existing shared components before creating duplicates.
- Bug fixes should be minimal; avoid unrelated refactors.
- Bottom-anchored UI must preserve the bottom safe-area inset, especially Android 3-button navigation.
- Verify import paths before using them; do not invent paths.

For implementation details, read `.ai/rules/code-style.md` only when relevant.

## Session Start

Read `.ai/memory/COMPACT.md`.

Then load progressively:

- If it declares an active handoff, read `.ai/memory/HANDOFF.md`.
- Read `.ai/memory/STATE.md` only when deeper current project state is needed.
- Read `CONTEXT.md` only when domain vocabulary is relevant.
- Read `.ai/memory/LESSONS.md` only when historical lessons are relevant.

Do not eagerly load all memory, rules, or skills.

## Working Principle

Use the smallest effective amount of context, exploration, tools, MCP calls, skills, agents, and verification needed for the task.

Start narrow. Reuse information already established in the current session. Do not perform broad repository scans or repeated tool calls without a concrete reason.

## Task Routing

### Small / Local Work

For copy, styling, spacing, local constants, obvious one-line guards, isolated low-risk bugs, and other changes with a clear local blast radius:

- inspect only the relevant code;
- implement directly;
- do not create a formal plan;
- do not require an approval round-trip;
- verify proportionally using `.ai/rules/verification.md`.

If the scope grows materially, reclassify before continuing.

### Medium Work

For multiple related files, a shared hook/service, contained state changes, or non-trivial behavior within one feature:

- inspect the relevant code and callers;
- use a short implementation outline when useful;
- read `.ai/rules/verification.md`;
- use GitNexus only when the blast radius is not obvious.

A persistent plan is optional unless the work becomes Large / Risky.

### Large / Risky Work

For architecture or data-flow changes, cross-module behavior, shared contracts, global state/navigation changes, refactors, migrations, dependency changes, unclear blast radius, significant regression risk, or work likely to span multiple sessions:

1. MUST use `.agents/skills/plan-work/SKILL.md`.
2. If module boundaries, interfaces, seams, adapters, or responsibility placement are involved, MUST consult `.agents/skills/codebase-design/SKILL.md`.
3. If shared/public symbols or downstream effects are unclear, read `.ai/rules/gitnexus.md` and perform the appropriate impact analysis.
4. Persist the plan under `.ai/plans/active/`.
5. Present the concise plan to the user.
6. STOP and wait for explicit approval before production-code edits.
7. If implementation later changes scope, architecture, dependencies, or risk materially, update the plan and request approval again.

Never skip the approval gate merely to save tokens.

### Difficult Bugs

Start with targeted inspection.

If the cause remains unclear, the issue is intermittent, several plausible hypotheses exist, or instrumentation/reproduction is needed, use `.agents/skills/diagnosing-bugs/SKILL.md`.

Do not invoke the full diagnostic workflow for an obvious local bug.

### React Native Implementation

For non-trivial React Native-specific UI, rendering, lists, animations, navigation behavior, or native-platform concerns, consult `.agents/skills/vercel-react-native-skills/SKILL.md`. 

Project rules in this repository override generic skill recommendations when they conflict.

### React Native Performance

For FPS/jank, excessive re-renders, memory leaks, startup/TTI, bundle size, Hermes/JS-thread issues, or native performance profiling, use `.agents/skills/react-native-best-practices/SKILL.md`.

Do not apply performance optimizations without evidence or a concrete performance goal.

### TDD

Use `.agents/skills/tdd/SKILL.md` only when the user requests test-first/TDD, or an approved plan explicitly identifies a valuable regression-test seam.

Do not force TDD for trivial changes.

### Handoff

When unfinished work moves to another session or another agent, or when the current session has grown too large, MUST use `.agents/skills/handoff/SKILL.md`.

The shared handoff lives at `.ai/memory/HANDOFF.md`.

### Agent-System Maintenance

When substantially changing `AGENTS.md`, `CLAUDE.md`, `.agents/AGENTS.md`, memory protocols, or skills, use `.agents/skills/writing-for-agents/SKILL.md`.

### Documentation — Explicit Request Only

NEVER create or update documentation automatically after development, refactoring, bug fixing, verification, or plan completion.

Only when the user explicitly requests documentation:

1. Read `.ai/rules/documentation.md`.
2. Use `.agents/skills/document-feature/SKILL.md`.
3. Inspect and follow the existing Docusaurus structure and conventions.
4. Document the final implementation, not merely the original plan.

Documentation changes require explicit user intent.
An approved plan does NOT count as an explicit documentation request.

Documentation may appear in a plan as an optional follow-up, but it MUST NOT be executed unless the user explicitly requests documentation.

## Rules On Demand

Read only when relevant:

- Application conventions → `.ai/rules/code-style.md`
- Testing and verification → `.ai/rules/verification.md`
- GitNexus usage → `.ai/rules/gitnexus.md`
- Documentation → `.ai/rules/documentation.md`

## Memory Rules

Shared memory must be agent-neutral.

- `COMPACT.md` is a small current snapshot and pointer map.
- `STATE.md` stores deeper current implementation/project state.
- `HANDOFF.md` stores only live continuation state.
- `LESSONS.md` stores durable reusable lessons.
- `CONTEXT.md` stores domain vocabulary, not implementation progress.

Do not copy whole plans, diffs, ADRs, or commits into memory. Reference their paths instead.

Update memory only when durable information changes.

## Instruction Priority

When instructions compete, use this order:

1. User's explicit current request
2. Safety and correctness
3. Approved active plan
4. This `AGENTS.md`
5. Relevant project rule
6. Relevant specialized skill
7. Shared memory
8. Agent-specific adapter

A specialized skill may refine a workflow but must not silently override project architecture, approval gates, or verification policy.
