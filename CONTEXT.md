# Uniscore Domain Context

This file is the shared domain glossary for coding agents.

It contains domain vocabulary only. Do not store task progress, implementation state, handoffs, temporary debugging notes, or agent-specific instructions here.

Use code, API contracts, product documentation, and confirmed user guidance as the source of truth for exact semantics.

## Known Domain Scope

Uniscore is a multi-sport application centered on live scores and match details.

## Terms

### Sport

A top-level sport category used to organize sport-specific data and UI.

Exact identifiers and supported values must come from the existing code/API.

### Match

A sporting event represented in live-score and match-detail flows.

Do not assume fields, lifecycle states, or participant structure without checking the existing model/API.

### Match Status

The lifecycle/status of a match.

Use existing project string-literal types and backend mappings. Do not introduce a new enum.

### Competition

A grouping or competition context associated with matches when present in the existing data model.

Use the repository/API terminology exactly.

### Season

A competition-related period/edition when present in the existing data model.

Do not infer season behavior from UI component names alone.

## Glossary Maintenance

Add or change a term only when its meaning is confirmed and durable.

Prefer domain language over implementation names when documenting concepts.

If two parts of the codebase use conflicting terminology, record the confirmed canonical term here after the conflict is resolved.
