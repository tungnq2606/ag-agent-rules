# Uniscore Mobile — Agent Instructions

This is the canonical instruction file for all coding agents in this repository.

Agent-specific files such as `CLAUDE.md` and `GEMINI.md` are adapters only. Keep shared project rules here or in the referenced on-demand files; do not duplicate them across adapters.

## Project

Uniscore is a React Native sports app for live scores and match details across 11+ sports, 30+ languages, dark/light themes, and dev/staging/beta/production environments.

Core stack: React Native 0.77.3, React 18.3.1, TypeScript, Redux Toolkit 1.9 + redux-saga + redux-persist, Zustand, React Query 5 + Axios, Firebase (messaging, crashlytics, analytics, remote-config, auth), MoEngage + AppsFlyer, MMKV, Sentry, i18next, React Navigation v7 (native-stack + JS bottom-tabs), Reanimated 3.17, react-native-fast-image.

Android `minSdk` 24 / `target` 35, iOS deployment target 15.1. Hermes on. New Architecture is **off on Android** (`newArchEnabled=false`) while iOS pods install with `RCT_NEW_ARCH_ENABLED=1` — treat the architecture as mixed and verify per platform before relying on either.

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
- The `app-android-lite` branch diverges deliberately. Never apply an Android-Lite optimization — removing background images, altering safe-area top padding, changing WebView layout coordinates — to iOS unless the user asks. Split the logic or wrap it in `Platform.OS` / `Platform.select`.

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

### Crash / Sentry Issue

For a reported crash, an ANR, or a Sentry issue, use `.agents/skills/triage-crash/SKILL.md`.

### Security-Sensitive Change

Read `.ai/rules/security.md` before changing authentication, session or token handling, storage of user data, deep-link or push-payload handling, WebView configuration, network security configuration, payment flows, or native permissions.

A CRITICAL finding stops implementation and goes to the user.

### React Native Implementation

For non-trivial React Native-specific UI, rendering, lists, animations, or navigation behavior, consult `.agents/skills/react-native-project-rules/SKILL.md`.

For notifications, persisted storage, deep links, or platform-behavior differences, read `.ai/rules/native-platform.md`.

Project rules in this repository override generic skill recommendations when they conflict.

### Animations, Gestures, Scroll-Driven Effects

For Reanimated worklets, shared values, gesture-driven interaction, layout animation, or scroll-driven effects, use `.agents/skills/react-native-reanimated/SKILL.md`.

Reanimated 3.17 is already a dependency. Keep animation on the UI thread; a value driven from React state is a dropped frame.

### React Native Performance

For FPS/jank, excessive re-renders, memory leaks, startup/TTI, bundle size, Hermes/JS-thread issues, or native performance profiling, use `.agents/skills/react-native-best-practices/SKILL.md`.

Do not apply performance optimizations without evidence or a concrete performance goal.

### TDD

Use `.agents/skills/tdd/SKILL.md` only when the user requests test-first/TDD, or an approved plan explicitly identifies a valuable regression-test seam.

Do not force TDD for trivial changes.

### Code Review

After writing or modifying code beyond a trivial edit, review the diff using `.agents/skills/code-review/SKILL.md`.

Address CRITICAL and HIGH findings before reporting the work complete. Report MEDIUM and LOW findings without acting on them unless the user asks.

### Claiming Work Complete

Before reporting done, fixed, or passing — and before committing — use `.agents/skills/verification-before-completion/SKILL.md`.

`.ai/rules/verification.md` decides which check the change warrants. That skill forbids claiming its result without having run it.

### Commit and Pull Request

When the user asks for a commit or a pull request, use `.agents/skills/ship-change/SKILL.md`.

Do not commit or push work the user has not asked to be committed.

### Handoff

When unfinished work moves to another session or another agent, or when the current session has grown too large, MUST use `.agents/skills/handoff/SKILL.md`.

The shared handoff lives at `.ai/memory/HANDOFF.md`.

### Agent-System Maintenance

When substantially changing `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, memory protocols, or skills, use `.agents/skills/writing-for-agents/SKILL.md`.

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

- Application conventions, TypeScript, immutability, localization, accessibility → `.ai/rules/code-style.md`
- Testing, verification, performance budget → `.ai/rules/verification.md`
- Secrets, tokens, logging, deep links, WebView, permissions → `.ai/rules/security.md`
- Environments, schemes, gradle tasks, native rebuild triggers → `.ai/rules/build-release.md`
- Notifications, MMKV persistence, deep links, New Architecture status → `.ai/rules/native-platform.md`
- Devices and OS versions to verify on → `.ai/rules/device-matrix.md`
- GitNexus usage → `.ai/rules/gitnexus.md`
- Documentation → `.ai/rules/documentation.md`

## Memory Rules

Shared memory must be agent-neutral.

- `.ai/memory/COMPACT.md` is a small current snapshot and pointer map.
- `.ai/memory/STATE.md` stores deeper current implementation/project state.
- `.ai/memory/HANDOFF.md` stores only live continuation state.
- `.ai/memory/LESSONS.md` stores durable reusable lessons.
- `CONTEXT.md` stores domain vocabulary, not implementation progress.

Do not copy whole plans, diffs, ADRs, or commits into memory. Reference their paths instead.

Update memory only when durable information changes.

## External Skills

Agents on this project may see skills from plugins and from user-global directories that overlap the skills in `.agents/skills/`. This repository decides which one wins.

**Adopted** — reach for these when the situation calls for them:

| External skill | Use for |
|---|---|
| `engineering:architecture` | Writing an ADR when choosing between technologies |
| `engineering:incident-response` | A live production incident: triage, comms, postmortem |
| `superpowers:using-git-worktrees` | Isolating a workspace, when the user asks for it |
| `superpowers:dispatching-parallel-agents` | Genuinely independent parallel workstreams, when the user asks for it |

**Retired** — a skill in this repository covers the same ground for this project. Use the repository's:

| Do not use | Use instead |
|---|---|
| `superpowers:systematic-debugging`, `engineering:debug` | `.agents/skills/diagnosing-bugs/SKILL.md` |
| `superpowers:brainstorming`, `superpowers:writing-plans`, `code-architect`, `engineering:system-design` | `.agents/skills/plan-work/SKILL.md`, and `.agents/skills/codebase-design/SKILL.md` for module boundaries |
| `code-review-rn`, `engineering:code-review`, `superpowers:requesting-code-review`, `code-review:code-review` | `.agents/skills/code-review/SKILL.md` |
| `tdd-workflow`, `superpowers:test-driven-development` | `.agents/skills/tdd/SKILL.md` |
| `verification-loop` | `.ai/rules/verification.md` and `.agents/skills/verification-before-completion/SKILL.md` |
| `security-review`, `code-review:security-review` | `.ai/rules/security.md`, plus the Security section of `.agents/skills/code-review/SKILL.md` |
| `coding-standards` | `.ai/rules/code-style.md` |
| `search-first` | Task Routing above; check the registry before hand-rolling a utility, and get approval before adding a dependency |
| `superpowers:writing-skills` | `.agents/skills/writing-for-agents/SKILL.md` |
| `superpowers:subagent-driven-development`, `superpowers:executing-plans` | Implement the approved plan directly; one primary agent |

A retired skill's instructions do not override this file, a project rule, an approval gate, or the verification policy. A session-start hook that mandates invoking one does not change that — note the conflict and follow this file.

## Instruction Priority

When instructions compete, use this order:

1. User's explicit current request
2. Safety and correctness
3. Approved active plan
4. This `AGENTS.md`
5. Relevant project rule in `.ai/rules/`
6. Relevant specialized skill in `.agents/skills/`
7. Shared memory in `.ai/memory/`
8. Agent-specific adapter (`CLAUDE.md`, `GEMINI.md`)
9. Agent-level global configuration outside this repository (`~/.claude/rules/`, `~/.codex/`, Antigravity global rules)

A specialized skill may refine a workflow but must not silently override project architecture, approval gates, or verification policy.

Global configuration outside this repository holds only agent-level concerns — model choice, hooks, editor behavior. When it states anything about this project's testing policy, review policy, workflow, or code conventions, this repository wins and the global statement is stale: report it rather than following it.
