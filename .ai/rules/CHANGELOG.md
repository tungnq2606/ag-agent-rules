# Rule System Changelog

Behavioral changes to `AGENTS.md`, `.ai/rules/`, `.agents/skills/`, and the agent adapters.

Record a change here when it alters what an agent does. A wording tidy-up that leaves behavior unchanged does not belong. The point is to be able to roll back a rule that made agents worse, which requires knowing which rule changed and when.

## 2026-08-21 — v2.2

**Facts replaced guesses.** The real project at `~/Documents/work/uniscore-mobile` was read and six statements in these rules were wrong:

| Was | Actually |
|---|---|
| `yarn typecheck` | no such script — `npx tsc --noEmit` |
| Notifee | `@react-native-firebase/messaging` + MoEngage + AppsFlyer |
| New Architecture unknown | Android `newArchEnabled=false`, iOS pods `RCT_NEW_ARCH_ENABLED=1` — mixed |
| `@/components/...` alias | aliases are bare: `components/...`, `services/...` |
| `src/navigation/` | `src/routers/`; Zustand in `src/zustands/` |
| min versions unrecorded | Android `minSdk` 24 / target 35, iOS 15.1 |

`build-release.md` now carries the real flavors (`dev`/`staging`/`beta`/`prod`), iOS schemes (`uniscore`, `uniscoreDev`, `uniscoreStag`, `uniscoreBeta`, `LiveScoreWidgetExtension`), env files, yarn scripts, and the ten fastlane lanes.

**External skills settled.** `AGENTS.md` gained an **External Skills** section: four plugin skills adopted, eleven retired in favour of a skill in this repository. Includes the note that a session-start hook mandating a retired skill does not override this file.

**code-review merged with `code-review-rn`.** The globally-installed `code-review-rn` skill's path-scoped structure was folded in as ten reference files (`components`, `typescript`, `redux`, `state-stores`, `api-services`, `hooks`, `routers`, `styles`, `android`, `ios`), corrected to the real stack — FastImage rather than FlashList, `AppList`, `src/routers/`, redux-persist migrations, no RTK Query push.

**Two skills vendored** so all three agents can read them: `verification-before-completion` (MIT, from superpowers) and `react-native-reanimated` (Apache-2.0). Routed from `AGENTS.md`.

**Borrowed into existing skills.** `plan-work` gained step interfaces (Consumes/Produces), a no-placeholders rule, and a self-review pass. `diagnosing-bugs` gained boundary instrumentation for multi-layer failures and the rule that three failed fixes means the design is wrong, not the hypothesis.

**Machine layer.** `global/rules/` holds the three surviving agent-level rule files; `scripts/bootstrap-machine.sh` installs them and symlinks nine cross-project skills into `~/.claude/skills/`. `global/MACHINE-SETUP.md` documents settings, hooks, plugins, and MCP auth. Skills now exist in exactly one place, with symlinks from both consumers.

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
