---
name: gitnexus-cli
description: "Use when the user needs to run GitNexus CLI commands like analyze/index a repo, check status, clean the index, generate a wiki, or list indexed repos. Examples: \"Index this repo\", \"Reanalyze the codebase\", \"Generate a wiki\", \"Check diagnostics\""
---

# GitNexus CLI Commands (v1.6.5)

All commands work via `npx` — no global install required.

## Commands

### analyze — Build or refresh the index

```bash
npx gitnexus analyze
```

Run from the project root. Parses all source files, builds the knowledge graph, writes to `.gitnexus/`, and updates CLAUDE.md / AGENTS.md context sections.

| Flag               | Effect                                                           |
| ------------------ | ---------------------------------------------------------------- |
| `--force`          | Force full re-index even if up to date                           |
| `--embeddings`     | Enable embedding generation for semantic search (off by default) |
| `--skills`         | Generate repo-specific skill files from detected communities     |
| `--index-only`     | Pure index mode: skip all file injection (AGENTS.md, CLAUDE.md, skills) |
| `--skip-agents-md` | Skip updating gitnexus section in AGENTS.md and CLAUDE.md        |
| `--skip-skills`    | Skip installing standard skill files under .claude/skills/gitnexus/ |
| `--name <alias>`   | Register repo under a custom name (for disambiguation)           |
| `-v, --verbose`    | Enable verbose ingestion warnings                                |

**When to run:** First time in a project, after major code changes, or when `gitnexus://repo/{name}/context` reports the index is stale.

### setup — One-time MCP configuration

```bash
npx gitnexus setup
```

Configures MCP for Cursor, Claude Code, OpenCode, and Codex. Run once after installing GitNexus.

### index — Register existing index

```bash
npx gitnexus index [path...]
```

Register an existing `.gitnexus/` folder into the global registry without re-analysis. Useful when you clone a repo that already has a `.gitnexus/` directory.

### status — Check index freshness

```bash
npx gitnexus status
```

Shows whether the current repo has a GitNexus index, when it was last updated, and symbol/relationship counts.

### doctor — Runtime diagnostics

```bash
npx gitnexus doctor
```

Shows runtime platform capabilities: OS, Node version, GitNexus version, graph store availability, embedding configuration. Use when debugging index or embedding issues.

### list — Show all indexed repos

```bash
npx gitnexus list
```

Lists all repositories registered in `~/.gitnexus/registry.json`.

### clean — Delete the index (current repo)

```bash
npx gitnexus clean
```

Deletes the `.gitnexus/` directory and unregisters the repo from the global registry.

| Flag      | Effect                                            |
| --------- | ------------------------------------------------- |
| `--force` | Skip confirmation prompt                          |
| `--all`   | Clean all indexed repos, not just the current one |

### remove — Delete index by name/path

```bash
npx gitnexus remove <target>
```

Delete the GitNexus index for a registered repo by alias, name, or absolute path. Unlike `clean`, does not require being inside the repo. Idempotent on unknown targets.

### wiki — Generate documentation from the graph

```bash
npx gitnexus wiki
```

Generates repository documentation from the knowledge graph using an LLM.

| Flag                | Effect                                    |
| ------------------- | ----------------------------------------- |
| `--force`           | Force full regeneration                   |
| `--model <model>`   | LLM model (default: minimax/minimax-m2.5) |
| `--base-url <url>`  | LLM API base URL                          |
| `--api-key <key>`   | LLM API key                               |
| `--concurrency <n>` | Parallel LLM calls (default: 3)           |
| `--gist`            | Publish wiki as a public GitHub Gist      |

### group — Cross-repo impact analysis

```bash
npx gitnexus group create <name>     # Create a group
npx gitnexus group add <group> <path> <name>  # Add repo to group
npx gitnexus group sync <name>       # Build cross-links
npx gitnexus group impact <name>     # Cross-repo impact analysis
npx gitnexus group query <name> <q>  # Search across group
```

Manage repository groups for cross-index impact analysis. Useful for monorepos or multi-service architectures.

### serve — Web UI server

```bash
npx gitnexus serve
```

Start local HTTP server for web UI connection.

## After Indexing

1. **Read `gitnexus://repo/{name}/context`** to verify the index loaded
2. Use the other GitNexus skills (`exploring`, `debugging`, `impact-analysis`, `refactoring`) for your task

## Troubleshooting

- **"Not inside a git repository"**: Run from a directory inside a git repo
- **Index is stale after re-analyzing**: Restart the agent to reload the MCP server
- **Embeddings slow**: Omit `--embeddings` (it's off by default) or set `OPENAI_API_KEY` for faster API-based embedding
- **Corrupt index**: Run `npx gitnexus clean --force` then `npx gitnexus analyze`
- **Runtime issues**: Run `npx gitnexus doctor` to check platform capabilities
