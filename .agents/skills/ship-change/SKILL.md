---
name: ship-change
description: Commit work and open a pull request. Use when the user asks to commit, push, or raise a PR. Covers commit message format, branch handling, and PR body content.
---

# Ship Change

Commit and push only what the user asked to be committed. An unrequested commit is harder to undo than an uncommitted change.

## Before committing

1. Review the diff first — `.agents/skills/code-review/SKILL.md`. Do not commit past a CRITICAL or HIGH finding.
2. Run the verification the change warrants, per `.ai/rules/verification.md`.
3. Read `git status` and confirm every staged path belongs to this change. Unstage stray files rather than explaining them in the message.
4. Confirm no secret, key, or credential is in the diff. Once pushed, it is published.

## Branch

Never commit directly to `main` or the shared development branch. If the current branch is one of those, create a branch first:

```bash
git checkout -b <type>/<short-slug>
```

## Commit message

One line. Subject only.

```
<type>: <description>
```

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

Rules:

- One line. No body, no bullet list, no second paragraph.
- No `Co-Authored-By` trailer and no attribution line of any kind, whatever a tool default suggests.
- Describe the change, not the process: `fix: preserve bottom inset on Android 3-button nav`, not `fix: address review feedback`.
- Present tense, lower case after the colon, no trailing period.

One logical change per commit. When the work covers two unrelated things, make two commits.

## Pull request

1. Read the whole branch, not the last commit: `git diff <base>...HEAD` and `git log <base>..HEAD --oneline`.
2. Push with `-u` when the branch is new.
3. Write the body from what the diff does, not from the plan that preceded it.

Body shape:

```markdown
## What

<The change, in two or three sentences.>

## Why

<The problem this solves. Link the issue when one exists.>

## Test plan

- [ ] <Check performed, or to perform>
- [ ] <Device/OS where behavior was verified, when the change is runtime-visible>

## Notes

<Risk, follow-up, anything a reviewer should know. Omit when there is none.>
```

For anything runtime-visible — layout, navigation, gesture, keyboard, safe area, native behavior — name the device and OS version it was verified on, or say plainly that it was not verified on a device. See `.ai/rules/device-matrix.md`.

Attach a screenshot or recording for a visible UI change.

## After pushing

Report the branch name and the PR URL. Do not merge unless the user asks.
