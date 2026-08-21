# Execution Plans

Persistent plans for non-trivial engineering work live here.

Use plans only when planning is required by `AGENTS.md` or explicitly requested by the user.

## Locations

- `.ai/plans/active/` — current approved/pending work
- `.ai/plans/completed/` — completed plans worth retaining

Do not create persistent plans for trivial work.

## Status

Use one of:

- `PENDING_APPROVAL`
- `APPROVED`
- `IN_PROGRESS`
- `NEEDS_REAPPROVAL`
- `COMPLETED`

Production-code implementation must not begin while a required plan is `PENDING_APPROVAL` or `NEEDS_REAPPROVAL`.

## Recommended Plan Shape

- Goal
- Scope
- Out of Scope
- Affected Areas
- Design / Approach
- Implementation Steps
- Risks / Blast Radius
- Verification
- Open Questions

Reference existing ADRs, specs, and code instead of duplicating them.

When a plan is completed, move it to `completed/` only if retaining it has future value.