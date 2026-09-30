# Machine Setup

## One run

```bash
git clone git@github.com:tungnq2606/ag-agent-rules.git ~/dev/ag-agent-rules
cd ~/dev/ag-agent-rules

DRY_RUN=1 bash scripts/bootstrap-machine.sh   # look first
bash scripts/bootstrap-machine.sh             # rules, skills, settings, MCP

bash setup.sh /path/to/project                # project layer, per repo
```

That installs `~/.claude/rules/ecc/`, symlinks every skill this repo carries into `~/.claude/skills` (and `~/.gemini/config/skills` when Antigravity is present), merges the portable keys into `~/.claude/settings.json`, and registers the MCP servers. Run `--help`-style detail from the script header; it is the source of truth for what lands where.

Symlinks point at the clone path. Move the clone, re-run the script.

A real directory already sitting at a skill's name is kept, not replaced. `FORCE=1` moves it to `~/.claude/backups/` and links the repo copy instead — that is how a machine holding hand-installed copies converts to symlinks.

## What the script deliberately leaves alone

**Hooks and the status line.** GitNexus, the caveman CLI, and the Antigravity auto-approval extension each write their own hook entries, pointing at paths that exist only after that tool is installed. Copying those paths from another machine produces hooks that fail silently. Install the tools instead:

```bash
npm i -g @caveman-ai/cli       # statusLine + 8 hook entries + its MCP server
npx gitnexus@latest analyze    # 2 hook entries, and the per-repo index
```

Antigravity's extension hook path lives in the IDE's `globalStorage`. Re-derive it on the machine.

**`permissions.allow` and `additionalDirectories`.** Both accumulate absolute project paths. Let them rebuild, or run `/fewer-permission-prompts` inside a project.

**Connector MCP auth.** Figma, Atlassian, Claude Docs, Linear, Notion, Slack authenticate interactively per machine. Sign in with `/mcp`.

## Plugins

The script writes the four marketplaces and seven plugins into `settings.json`; Claude Code installs them on the next start.

`AGENTS.md` §External Skills decides precedence where a plugin skill overlaps one of this repository's. Most of the overlap is `superpowers` and `engineering`.

`superpowers` also installs a **SessionStart hook** that tells the agent to invoke its own skills before responding, which competes with this repository's Task Routing. Either keep it and rely on §External Skills to settle precedence — the hook still fires, so expect occasional wrong-skill starts — or disable it and lose nothing this repository needs, since the one skill worth keeping is vendored at `.agents/skills/verification-before-completion/`:

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

## Skills that do not come from here

`~/.claude/skills/synced/` holds the skills enabled on claude.ai. They download on their own once signed in — nothing to install, nothing to back up.

## Antigravity

Antigravity reads workspace rules from `AGENTS.md` and `GEMINI.md` at the project root — both installed by `setup.sh`, `AGENTS.md` canonical and `GEMINI.md` the thin adapter. Skills come from `~/.gemini/config/skills/` (global, symlinked by the bootstrap) and `.agents/skills/` in the workspace, which needs nothing extra.

Where the global directory holds a skill that duplicates a workspace one, the workspace copy is the one this repository maintains.

## Verify

The bootstrap ends with its own checks. To re-check later:

```bash
bash scripts/validate-pointers.sh                     # 0 dead pointers
find ~/.claude/skills -maxdepth 1 -type l ! -exec test -e {} \; -print   # no broken symlinks
ls ~/.claude/rules/ecc/common                         # hooks.md, performance.md only
```

`~/.claude/rules/ecc/` holds agent-level rules only. A file there stating a testing policy, review policy, workflow, or code convention for a project is stale — the project's own `AGENTS.md` owns those. `.ai/rules/CHANGELOG.md` records what was removed and why.
