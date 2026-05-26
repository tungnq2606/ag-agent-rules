---
name: gitnexus-guide
description: "Use when the user asks about GitNexus itself — available tools, how to query the knowledge graph, MCP resources, graph schema, or workflow reference. Examples: \"What GitNexus tools are available?\", \"How do I use GitNexus?\""
---

# GitNexus Guide

Quick reference for all GitNexus MCP tools, resources, and the knowledge graph schema.

## Always Start Here

For any task involving code understanding, debugging, impact analysis, or refactoring:

0. **If `.gitnexus/` does NOT exist** — ask the user:
   > "This project doesn't have a GitNexus index. Want me to run `npx gitnexus analyze` to build one?"
   Wait for approval before proceeding.
1. **Read `gitnexus://repo/{name}/context`** — codebase overview + check index freshness
2. **Match your task to a skill below** and **read that skill file**
3. **Follow the skill's workflow and checklist**

> If step 1 warns the index is stale, run `npx gitnexus analyze` in the terminal first.

## Answer Directly from the Graph

**Don't re-read files that GitNexus already returned.**

GitNexus's returned source is authoritative — treat it as already read. Reach for raw file reads or grep only to confirm a specific detail the graph didn't cover.

- `gitnexus_query` / `gitnexus_context` → contains source code and references → **don't re-open those files**
- A direct GitNexus answer = a handful of tool calls; a grep/read exploration = dozens
- Don't delegate to sub-agents for file scanning when the graph already has the answer

## Skills

| Task                                         | Skill to read                |
| -------------------------------------------- | ---------------------------- |
| Understand architecture / "How does X work?" | `gitnexus-exploring`         |
| Blast radius / "What breaks if I change X?"  | `gitnexus-impact-analysis`   |
| Trace bugs / "Why is X failing?"             | `gitnexus-debugging`         |
| Rename / extract / split / refactor          | `gitnexus-refactoring`       |
| Review a PR / "Is this safe to merge?"       | `gitnexus-pr-review`         |
| Tools, resources, schema reference           | `gitnexus-guide` (this file) |
| CLI: index, setup, doctor, group, clean      | `gitnexus-cli`               |

## Tools Reference

**Use in this order — start broad, drill down as needed:**

| Priority | Tool             | Use for                                                                  |
| -------- | ---------------- | ------------------------------------------------------------------------ |
| 1st      | `query`          | **Start here** — find execution flows related to a concept               |
| 2nd      | `context`        | 360-degree view of a specific symbol — callers, callees, processes       |
| 3rd      | `impact`         | Before editing — blast radius at depth 1/2/3 with confidence             |
| as needed | `detect_changes` | After editing — what do your current changes affect                      |
| as needed | `rename`         | Multi-file coordinated rename with confidence-tagged edits               |
| as needed | `cypher`         | Custom graph queries (read `gitnexus://repo/{name}/schema` first)        |
| as needed | `list_repos`     | Discover indexed repos                                                   |

## Resources Reference

Lightweight reads (~100-500 tokens) for navigation:

| Resource                                       | Content                                   |
| ---------------------------------------------- | ----------------------------------------- |
| `gitnexus://repo/{name}/context`               | Stats, staleness check                    |
| `gitnexus://repo/{name}/clusters`              | All functional areas with cohesion scores |
| `gitnexus://repo/{name}/cluster/{clusterName}` | Area members                              |
| `gitnexus://repo/{name}/processes`             | All execution flows                       |
| `gitnexus://repo/{name}/process/{processName}` | Step-by-step trace                        |
| `gitnexus://repo/{name}/schema`                | Graph schema for Cypher                   |

## Graph Schema

**Nodes:** File, Function, Class, Interface, Method, Community, Process
**Edges (via CodeRelation.type):** CALLS, IMPORTS, EXTENDS, IMPLEMENTS, DEFINES, MEMBER_OF, STEP_IN_PROCESS

```cypher
MATCH (caller)-[:CodeRelation {type: 'CALLS'}]->(f:Function {name: "myFunc"})
RETURN caller.name, caller.filePath
```
