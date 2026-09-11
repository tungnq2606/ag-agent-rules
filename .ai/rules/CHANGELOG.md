# Rule System Changelog

Behavioral changes to `AGENTS.md`, `.ai/rules/`, `.agents/skills/`, and the agent adapters.

Record a change here when it alters what an agent does. A wording tidy-up that leaves behavior unchanged does not belong. The point is to be able to roll back a rule that made agents worse, which requires knowing which rule changed and when.

This file is installed into every project, so it must stay portable: name files that live outside the project layer in prose, never as a path. A path that does not resolve where this file lands is a dead pointer.

## 2026-09-10 — v2.4

**`AGENTS.md` §Rule Compliance.** Agents were treating the routing table as reference to consult rather than a contract, and skipping named skills mid-session. The new section sits ahead of §Project, at the top of the file where attention is highest, and states four obligations: read this file end to end before the first tool call, name the Task Routing group and read the rules and skills it names before the first production-code edit, keep that routing in force for the whole session rather than only the first turn, and name the files actually read so compliance is checkable. Token budget, session length, and "the change looks correct" are called out as non-exemptions because those were the observed rationalizations.

It adds no eager loading. `Session Start` still owns what to read and stays progressive; §Rule Compliance owns only the obligation. Both adapters now say "read `AGENTS.md` end to end, §Rule Compliance included, before the first tool call" instead of "read `AGENTS.md`".

**A `SessionStart` hook enforces it.** A markdown rule binds only an agent that opens the file, so `scripts/rule-compliance-hook.sh` now ships and `setup.sh` installs it at `<target>/.agents/hooks/rule-compliance.sh`, wiring it into `.claude/settings.json` under `hooks.SessionStart` (idempotent; skipped with a warning when python3 is absent). Every session gets the obligation in context whether or not the agent chose to read `AGENTS.md`. The hook also fails loudly in two states found in the wild: `AGENTS.md` missing, and `AGENTS.md` present but carrying no §Rule Compliance section — the signature of another tool's managed block having overwritten the file. A new hook reaches a running session only after `/hooks` is opened once or the session restarts.

**`setup.sh` no longer overwrites `.ai/memory/`.** `copy_tree` takes a second argument `keep`, and `.ai/memory` uses it: existing memory files survive even under `FORCE=1`. They had been replaced with the empty skeleton, which destroys the live handoff — and with `*.bak` gone there is no copy to fall back on. Memory is project state, not installer output.

**`setup.sh` no longer writes `*.bak`.** `copy_file` used to copy the existing file to `<file>.bak` before an overwrite, so every `FORCE=1` run left `AGENTS.md.bak`, `CLAUDE.md.bak`, `GEMINI.md.bak`, and `CONTEXT.md.bak` in the target root — a stale instruction file sitting beside the real one, ignored by the managed block so nothing ever cleaned it up. `copy_tree` never backed anything up anyway, so only root files got the treatment. Backups are gone; `FORCE=1` overwrites in place and git is the only recovery, which the closing message and the README now say. `*.bak` left the managed `.gitignore` block and the already-tracked warning, and the script warns once when it finds backups an older version left behind rather than deleting them itself.

`FORCE=1` stays the gate. A target repo's `AGENTS.md` carries hand-written Project and Always-On Invariants sections, and `.ai/rules/verification.md` carries its real commands — overwriting those by default would wipe the customization with no backup to fall back on.

## 2026-08-21 — v2.3

**Antigravity's read path confirmed**, and the adapter was in the wrong place. Antigravity reads workspace rules from `AGENTS.md` and `GEMINI.md` at the project root, and skills from `~/.gemini/config/skills/` (global) plus `.agents/skills/` (workspace).

So the old adapter under the .agents directory was never read by anything — deleted. `GEMINI.md` replaces it as the Antigravity adapter, and `setup.sh` installs it. `.agents/skills/` needed no change: it already is the workspace skill directory Antigravity looks in.

The machine bootstrap now symlinks the cross-project skills into `~/.gemini/config/skills/` as well, so Claude and Antigravity read the same files as the repo instead of three copies.

**Managed `.gitignore` block.** `setup.sh` writes an idempotent block between `# >>> ag-agent-rules >>>` markers covering `.DS_Store`, `*.bak` (its own backups), `.claude/settings.local.json`, `.claude/skills/`, and `**/*service-account*.json`. It deliberately does **not** ignore `AGENTS.md`, `CONTEXT.md`, `.agents/skills/`, or `.ai/` — the agent layer has to travel with the repo, or Codex and Antigravity get nothing on a teammate's clone. It also does not blanket-ignore credential extensions: this project tracks `.p12` and `.mobileprovision` under `.github/resources/` for CI on purpose. When a matching file is already tracked, the script says so rather than letting the user assume it got hidden.

**Two more instances of the backup-inside-a-scanned-directory bug.** `bootstrap-machine.sh` was writing `<name>.backup-<ts>` inside `~/.gemini/config/skills/`, where Antigravity loads it as another skill, and `ecc.backup-<ts>` inside `rules/`. Both now go to `~/.claude/backups/`. That is three occurrences of the same mistake in one day — treat "where does the backup land" as part of any cleanup, not an afterthought.

**Validator went from 120s to 0.8s on a real project.** Its ambiguity check ran a fresh `find` per candidate, which walked `node_modules`. It now counts from the already-scoped file list.

## 2026-08-21 — v2.2

**Facts replaced guesses.** The real project at `~/Documents/work/uniscore-mobile` was read and six statements in these rules were wrong:

| Was | Actually |
|---|---|
| `yarn typecheck` | no such script — `npx tsc --noEmit` |
| Notifee | `@react-native-firebase/messaging` + MoEngage + AppsFlyer |
| New Architecture unknown | Android `newArchEnabled=false`, iOS pods `RCT_NEW_ARCH_ENABLED=1` — mixed |
| `@/components/...` alias | aliases are bare: `components/...`, `services/...` |
| `src/navigation/` | `src/routers/`; Zustand dir is `src/zustand/` while its alias is `zustands` |
| min versions unrecorded | Android `minSdk` 24 / target 35, iOS 15.1 |

`build-release.md` now carries the real flavors (`dev`/`staging`/`beta`/`prod`), iOS schemes (`uniscore`, `uniscoreDev`, `uniscoreStag`, `uniscoreBeta`, `LiveScoreWidgetExtension`), env files, yarn scripts, and the ten fastlane lanes.

**External skills settled.** `AGENTS.md` gained an **External Skills** section: four plugin skills adopted, eleven retired in favour of a skill in this repository. Includes the note that a session-start hook mandating a retired skill does not override this file.

**code-review merged with `code-review-rn`.** The globally-installed `code-review-rn` skill's path-scoped structure was folded in as ten reference files (`components`, `typescript`, `redux`, `state-stores`, `api-services`, `hooks`, `routers`, `styles`, `android`, `ios`), corrected to the real stack — FastImage rather than FlashList, `AppList`, `src/routers/`, redux-persist migrations, no RTK Query push.

**Two skills vendored** so all three agents can read them: `verification-before-completion` (MIT, from superpowers) and `react-native-reanimated` (Apache-2.0). Routed from `AGENTS.md`.

**Borrowed into existing skills.** `plan-work` gained step interfaces (Consumes/Produces), a no-placeholders rule, and a self-review pass. `diagnosing-bugs` gained boundary instrumentation for multi-layer failures and the rule that three failed fixes means the design is wrong, not the hypothesis.

**Machine layer.** `global/rules/` holds the three surviving agent-level rule files; `scripts/bootstrap-machine.sh` installs them and symlinks nine cross-project skills into `~/.claude/skills/`. A machine-setup document in the rules repo covers settings, hooks, plugins, and MCP auth. Skills now exist in exactly one place, with symlinks from both consumers.

**Global skills cleaned.** `~/.claude/skills/` went from 30 real directories to 15 real plus 9 symlinks into this repo. Retired: `code-architect`, `code-review-rn` (merged here), `coding-standards`, `search-first`, `security-review`, `tdd-workflow`, `verification-loop`. Kept untouched: the design/image skills, `output-skill`, and `gitnexus-pdg-query` / `gitnexus-taint-analysis` (for working on GitNexus internals, not on this app).

**A backup inside `~/.claude/rules/` is loaded as rules.** The v2.1 backup at `~/.claude/rules/ecc.backup-20260821/` was being read as active configuration — the twelve removed files were still reaching the agent. All backups now live at `~/.claude/backups/`, outside every directory the agent loads. Never leave a backup under `rules/` or inside `skills/`.

**Validator hardened.** `scripts/validate-pointers.sh` resolves four path forms — owner-relative with a leading dot, parent-relative with two, repo-relative starting from a directory that exists at the root, and a bare filename — each against the right base. A regression that silently reported 72 false positives was caught by injecting a known-bad link of each form and confirming exactly four findings.

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
