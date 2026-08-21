# Rule System Changelog

Behavioral changes to `AGENTS.md`, `.ai/rules/`, `.agents/skills/`, and the agent adapters.

Record a change here when it alters what an agent does. A wording tidy-up that leaves behavior unchanged does not belong. The point is to be able to roll back a rule that made agents worse, which requires knowing which rule changed and when.

## 2026-08-21 — v2.1

**Conflict resolution.** The repository is now the single source of truth for every project matter. `~/.claude/rules/ecc/` was cut to three agent-level files (`~/.claude/rules/ecc/common/hooks.md`, `~/.claude/rules/ecc/common/performance.md`, `~/.claude/rules/ecc/typescript/hooks.md`); the twelve files stating project policy were removed. Backup at `~/.claude/rules/ecc.backup-20260821/`.

Conflicts resolved in favor of this repository:

| Topic | Was (global) | Now |
|---|---|---|
| TDD | mandatory, 80% coverage | on request only — `AGENTS.md` §TDD |
| Test runs | three test types required | proportional — `.ai/rules/verification.md` |
| Subagents | always parallelize | main agent for routine work — `CLAUDE.md` |
| Pre-implementation | `gh search` required | routed by blast radius — `AGENTS.md` §Task Routing |
| File size | 800 lines | ~300 lines — `.ai/rules/code-style.md` |
| E2E framework | Playwright | not specified; Playwright is wrong for React Native |
| Validation | Zod required | narrow at the boundary; no new dependency |
| `enum` | allowed for interop | never — string literal unions |

`AGENTS.md` §Instruction Priority gained a ninth rank for agent-level global configuration, below everything in the repository.

**New rules.** `.ai/rules/security.md`, `.ai/rules/build-release.md`, `.ai/rules/native-platform.md`, `.ai/rules/device-matrix.md`. `.ai/rules/verification.md` gained a Performance Budget section; `.ai/rules/code-style.md` gained Immutability, Localization, and Accessibility.

**New skills.** `code-review`, `ship-change`, `triage-crash`. `AGENTS.md` routes to all three.

**Renamed skill.** `vercel-react-native-skills` → `react-native-project-rules`. Ten Expo-only or inapplicable rules removed; `ui-pressable`, `ui-styling`, `ui-native-modals`, `list-performance-virtualize`, `navigation-native-navigators` rewritten against this project's components.

**Pointers.** Five dead pointers fixed: codebase-design's DEEPENING and DESIGN-IT-TWICE references folded into its own body, tdd's two test references merged into `.agents/skills/tdd/tests.md`, and `.agents/skills/writing-for-agents/SKILL-MECHANICS.md` written. `scripts/validate-pointers.sh` added and now gates changes. GitNexus skill bodies vendored into `.agents/skills/` so Codex and Antigravity can read them. `.claude/skills/` symlinks added for Claude skill discovery.

**Bootstrap.** The v1 setup script and scan prompt moved under legacy/; a v2 setup script replaces them. The repository README was rewritten.

## 2026-08-21 — v2.0

Migration from the v1 layout (`agents-skills/`, `antigravity-skills/`, `templates/`, `memory/`) to v2 (`AGENTS.md` canonical, `.agents/skills/`, `.ai/`). Committed as `chore: complete v2 agent-rules layout and fix bootstrap`.
