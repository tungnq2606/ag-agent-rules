# Skill mechanics

The packaging layer: frontmatter, how a skill gets invoked, and when one skill should route to another. Read alongside `SKILL.md`, which covers the writing itself.

## Layout

One directory per skill under `.agents/skills/`, named in kebab-case, containing `SKILL.md`. Disclosed reference sits beside it as sibling files; bulk reference goes in `references/`, rule sets in `rules/`.

```
.agents/skills/<skill-name>/
  SKILL.md          steps and in-file reference
  <topic>.md        disclosed reference, reached by a pointer in SKILL.md
  references/       bulk reference the router indexes
```

The directory name is the skill's address. Renaming it breaks every pointer aimed at it, so grep for the old name before renaming.

## Frontmatter

Two fields, both required:

```yaml
---
name: diagnosing-bugs
description: Diagnose difficult bugs when targeted inspection does not reveal a clear root cause. Use for intermittent failures, multiple plausible hypotheses, unclear regressions, or issues requiring reproduction or instrumentation.
---
```

`name` matches the directory exactly.

`description` is a context pointer, and it is the only part of the skill loaded on every turn. It does two jobs and nothing else: say what the material is, then list the branches that should trigger reaching it.

- **Front-load the triggering word.** "Diagnose difficult bugs" earns its position; "This skill provides guidance for…" spends four tokens saying nothing.
- **One trigger per branch.** "bugs, defects, issues, problems" is one branch written four times. "intermittent failures, multiple plausible hypotheses, unclear regressions" is three real branches.
- **State the negative boundary when the skill is easy to over-invoke.** A workflow skill that should not fire on trivial work says so in the description, not only in the body.
- **Cut identity the body already carries.** The description is not a summary of the skill.

Anything beyond `name` and `description` — `license`, `metadata`, `author`, `version` — is inherited from an upstream source and carries no meaning here. Drop it when editing a skill, unless attribution is a licence condition.

## Invocation

Three ways a skill gets reached, in descending reliability:

1. **Routed from `AGENTS.md`.** A named branch under Task Routing points at the skill path. The strongest hook: the condition is stated in always-loaded context, so the agent reaches the skill without having to recognise the situation on its own. Use this for anything with a gate — approval, verification, review.
2. **Discovered from the description.** The agent matches the situation against skill descriptions. Reliability lives entirely in the description's wording. Use for skills that apply across many task shapes.
3. **Requested by the user.** Always available; needs nothing from you but a memorable name.

Every skill carrying a gate belongs in category 1. A skill reachable only through category 2 will be skipped sometimes, so never put a mandatory step behind one.

## Router skills

A **router** is a skill whose body is mostly an index: a priority-ordered map from problem to reference file. `react-native-best-practices` is one — a Quick Reference, a table per category, and a problem → file mapping.

A router earns its shape when the reference set is large and each task needs one or two entries. It fails when it turns into a table of contents the agent must read in full before it can pick, so:

- Order entries by impact, and say what the impact is. `CRITICAL` next to an entry does work that alphabetical order does not.
- Include a problem → start-here mapping. The agent arrives with a symptom, not a filename.
- Keep each row to one line. A router with paragraphs is not a router.
- Point at real files. A router is the easiest place for a dead pointer to hide, because nothing reads every row.

Run `scripts/validate-pointers.sh` after editing a router.

## When one skill points at another

Point, don't inline. Two skills describing the same rule drift apart, and the drift is invisible until they disagree mid-task.

- Use a full repo-relative path: `.agents/skills/code-review/SKILL.md`. A bare `AGENTS.md` or `CONTEXT.md` may resolve against the skill's own directory, the repo root, or a same-named neighbour — three different files, one of them wrong.
- State the condition for following the pointer, not just the target.
- A skill may hand off to another (stop here, continue there) or consult it as reference (borrow the vocabulary, keep running). Say which one you mean; "see also" says neither.

## Before finishing a skill edit

- `name` matches the directory.
- The description front-loads its trigger and lists distinct branches.
- Every pointer resolves — `bash scripts/validate-pointers.sh`.
- Steps that must not be skipped are routed from `AGENTS.md`, not left to discovery.
- Nothing in the body restates what `AGENTS.md` or a project rule already says.
