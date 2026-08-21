# Uniscore Domain Context

Domain glossary. Vocabulary only — no task progress, implementation state, handoffs, or agent instructions.

Uniscore is a multi-sport application centered on live scores and match details.

## Status

**Unpopulated.** Nothing below has been confirmed against the code yet, so this file currently saves no lookups.

Populate it the first time a session resolves one of the questions below from the codebase, and record the confirmed answer rather than a description of where to look. A term whose entry says "check the code" costs context and returns nothing.

## Terms to confirm

| Term | What to record once confirmed |
|------|-------------------------------|
| Sport | The real identifier set and how sport-specific data and UI are keyed off it |
| Match | The lifecycle and the fields that live-score and match-detail flows actually rely on |
| Match Status | The exact string-literal union and its backend mapping. No new enum — see `.ai/rules/code-style.md` |
| Competition | The repository's own term for the grouping, and whether it is always present |
| Season | What season identity is, and where it comes from |

Add a row's answer inline as a short section once it is confirmed. Remove the row from this table at the same time.

## Maintenance

- Record a term only when its meaning is confirmed and durable.
- Prefer domain language over implementation names.
- When two parts of the codebase disagree on a term, record the canonical one here after the disagreement is settled — that is exactly what this file is for.
- Source of truth order: code, API contract, product documentation, confirmed user guidance.
