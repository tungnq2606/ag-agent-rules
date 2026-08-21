# Machine Setup

What a new machine needs beyond `scripts/bootstrap-machine.sh`. The script handles agent-level rules and cross-project skill symlinks; everything below is manual because it holds machine-local paths, credentials, or personal preference.

## Order

```bash
git clone git@github.com:tungnq2606/ag-agent-rules.git ~/dev/ag-agent-rules
cd ~/dev/ag-agent-rules

DRY_RUN=1 bash scripts/bootstrap-machine.sh   # look first
bash scripts/bootstrap-machine.sh             # machine layer

bash setup.sh /path/to/project                # project layer, per repo
```

Symlinks point at the clone path. Move the clone, re-run the bootstrap.

## 1. Claude Code settings

`~/.claude/settings.json`. Current shape:

```json
{
  "model": "opus[1m]",
  "effortLevel": "xhigh",
  "permissions": {
    "allow": ["..."],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git reset --hard *)",
      "Edit(.git/**)",
      "Edit(.claude/**)"
    ],
    "additionalDirectories": ["..."]
  },
  "hooks": { "PreToolUse": [], "PostToolUse": [] },
  "enabledPlugins": {},
  "extraKnownMarketplaces": {}
}
```

Keep the `deny` list — it is the cheapest guard against an irreversible command, and it costs nothing when nothing goes wrong.

The `allow` list accumulates project-specific absolute paths. Do not copy it verbatim to a new machine; let it rebuild, or run `/fewer-permission-prompts` in the project.

## 2. Hooks

| Hook | Command | Purpose |
|---|---|---|
| PreToolUse `Grep\|Glob\|Bash` | `~/.claude/hooks/gitnexus/gitnexus-hook.cjs` | Enrich searches with graph context |
| PostToolUse `Bash` | same | Keep the graph current |
| PreToolUse `*` | Antigravity `claude-auto-yes` extension | IDE auto-approval |

The GitNexus hook script is not in this repo — it ships with GitNexus. Install GitNexus first, then point the hook at it.

The Antigravity auto-yes hook path lives inside the IDE's extension storage and will differ on a new machine. Re-derive it rather than copying the path.

## 3. Plugins

Marketplaces: `claude-plugins-official`, `knowledge-work-plugins` (anthropics), `last30days-skill` (mvanhorn), `caveman` (JuliusBrussee).

Enabled: `code-review`, `playground`, `superpowers`, `last30days`, `engineering`, `caveman`, `figma`.

### Plugin skills that conflict with this repository

`AGENTS.md` has an **External Skills** section listing which plugin skills are adopted and which are retired. Read it before installing plugins on a new machine — most of the overlap is with `superpowers` and `engineering`.

The `superpowers` plugin also installs a **SessionStart hook** that instructs the agent to invoke its own skills before responding. That competes with this repository's Task Routing. Two ways to live with it:

- Keep the plugin and rely on `AGENTS.md` §External Skills to settle precedence. Its `using-git-worktrees` and `dispatching-parallel-agents` stay available. The hook still fires, so expect occasional wrong-skill starts.
- Disable it, and lose nothing this repository needs — the one skill worth keeping is already vendored at `.agents/skills/verification-before-completion/`:

```bash
python3 - <<'PY'
import json, pathlib
p = pathlib.Path.home() / ".claude/settings.json"
s = json.loads(p.read_text())
s.setdefault("enabledPlugins", {})["superpowers@claude-plugins-official"] = False
p.write_text(json.dumps(s, indent=2) + "\n")
print("superpowers disabled")
PY
```

## 4. MCP servers

GitNexus needs installing and indexing per repository:

```bash
npx gitnexus@latest analyze
```

Connector-based servers (Figma, Atlassian, Linear, Notion, Slack, and the rest) authenticate interactively per machine. Nothing to copy; sign in from an interactive session via `/mcp`.

## 5. Verify the machine

```bash
bash scripts/validate-pointers.sh          # 0 dead pointers
ls -l ~/.claude/skills | grep ag-agent     # symlinks resolve
ls ~/.claude/rules/ecc/common              # hooks.md, performance.md only
```

`~/.claude/rules/ecc/` must contain agent-level rules only. If a file there states a testing policy, review policy, workflow, or code convention for a project, it is stale — the project's own `AGENTS.md` owns those. See `.ai/rules/CHANGELOG.md` for what was removed and why.
