#!/usr/bin/env bash
#
# Set up a new machine in one run: agent-level rules, every skill, Claude Code
# settings, plugin marketplaces, and MCP servers.
#
# Usage:
#   bash scripts/bootstrap-machine.sh              # install
#   DRY_RUN=1 bash scripts/bootstrap-machine.sh    # show what would change
#   FORCE=1 bash scripts/bootstrap-machine.sh      # replace a real directory that blocks a symlink
#
# Installs into ~/.claude:
#   rules/ecc/          agent-level rules only — model choice, hooks. No project policy.
#   skills/<name>       symlinks to this repo's skills. One source, no copies.
#   settings.json       model, effort, deny rules, marketplaces, enabled plugins (merged)
#   MCP servers         gitnexus, agentmemory, caveman (user scope)
#
# Hooks and the status line are deliberately not written here. GitNexus, the
# caveman plugin, and the Antigravity extension each register their own, at
# paths that only exist once that tool is installed. Install the tools and let
# them write their hooks; this script never fabricates those paths.
#
# The project layer is separate: run setup.sh inside a project repo for that.
#
# Symlinks point at this repo's path. Moving the repo breaks them — re-run this script.
#
# Written for bash 3.2 (macOS system bash): no mapfile, no associative arrays.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
SETTINGS="$CLAUDE_HOME/settings.json"
DRY_RUN="${DRY_RUN:-0}"
FORCE="${FORCE:-0}"

# Backups live outside every directory an agent scans. A backup left inside
# rules/ is read as active configuration; one left inside skills/ is read as
# another skill. Both have happened.
BACKUP_ROOT="${BACKUP_ROOT:-$CLAUDE_HOME/backups/bootstrap-$(date +%Y%m%d%H%M%S)}"

GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'; CYAN=$'\033[0;36m'; RED=$'\033[0;31m'; NC=$'\033[0m'
ok()   { printf '%s✓%s %s\n' "$GREEN" "$NC" "$1"; }
info() { printf '%s→%s %s\n' "$CYAN" "$NC" "$1"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$NC" "$1"; }
die()  { printf '%s✗%s %s\n' "$RED" "$NC" "$1" >&2; exit 1; }

# Cross-project skills: self-contained, no dependency on a project's .ai/ layout.
# They live in .agents/skills/ because setup.sh installs them into projects too.
MACHINE_SKILLS="
codebase-design
react-native-reanimated
gitnexus-cli
gitnexus-debugging
gitnexus-exploring
gitnexus-guide
gitnexus-impact-analysis
gitnexus-pdg-query
gitnexus-pr-review
gitnexus-refactoring
gitnexus-taint-analysis
"

[ -d "$REPO/global/rules" ] || die "global/rules not found — wrong repo?"
[ "$DRY_RUN" = "1" ] && warn "DRY_RUN: nothing will be written"

info "Repo:   $REPO"
info "Target: $CLAUDE_HOME"
echo

# --------------------------------------------------------------- 0. preflight

info "Preflight"
missing=""
for bin in git rsync python3; do
  command -v "$bin" >/dev/null 2>&1 || missing="$missing $bin"
done
[ -n "$missing" ] && die "required and not on PATH:$missing"
ok "git, rsync, python3"

for bin in node npm; do
  command -v "$bin" >/dev/null 2>&1 || warn "$bin not found — GitNexus and caveman need it"
done
command -v claude >/dev/null 2>&1 || warn "claude CLI not found — MCP servers will be printed, not registered"
echo

# ------------------------------------------------------------------ 1. rules

info "Agent-level rules"
RULES_DEST="$CLAUDE_HOME/rules"

if [ -d "$RULES_DEST/ecc" ] && [ "$FORCE" != "1" ] && [ "$DRY_RUN" != "1" ]; then
  mkdir -p "$BACKUP_ROOT"
  cp -R "$RULES_DEST/ecc" "$BACKUP_ROOT/rules-ecc"
  warn "backed up existing rules to $BACKUP_ROOT/rules-ecc"
fi

if [ "$DRY_RUN" = "1" ]; then
  find "$REPO/global/rules" -type f | sed "s|$REPO/global/rules|  would install ~/.claude/rules|"
else
  mkdir -p "$RULES_DEST"
  rsync -a --exclude='.DS_Store' "$REPO/global/rules/" "$RULES_DEST/"
  ok "rules/ecc ($(find "$RULES_DEST/ecc" -type f ! -name '.DS_Store' | wc -l | tr -d ' ') files)"
fi
echo

# ----------------------------------------------------------------- 2. skills

# $1 destination dir, $2 label, $3 source dir, $4 newline-separated names
# (empty $4 means every directory in $3).
link_skills_into() {
  local dest="$1" label="$2" src_root="$3" names="$4"
  local linked=0 skipped=0 name src dst

  if [ -z "$names" ]; then
    names="$(cd "$src_root" && find . -maxdepth 1 -mindepth 1 -type d | sed 's|^\./||' | sort)"
  fi

  [ "$DRY_RUN" = "1" ] || mkdir -p "$dest"

  for name in $names; do
    src="$src_root/$name"
    dst="$dest/$name"

    [ -d "$src" ] || { warn "missing in repo, skipped: $name"; continue; }

    if [ "$DRY_RUN" = "1" ]; then
      printf '  would link %s/%s -> repo\n' "$label" "$name"
      continue
    fi

    if [ -L "$dst" ]; then
      rm "$dst"
    elif [ -e "$dst" ]; then
      if [ "$FORCE" != "1" ]; then
        warn "$label: real directory exists, kept: $name (FORCE=1 to replace)"
        skipped=$((skipped + 1))
        continue
      fi
      # Never leave the backup inside a directory the agent scans — a
      # "<name>.backup-<ts>" sitting in skills/ is loaded as another skill.
      mkdir -p "$BACKUP_ROOT"
      mv "$dst" "$BACKUP_ROOT/$name"
      warn "$label: moved aside to $BACKUP_ROOT/$name"
    fi

    ln -s "$src" "$dst"
    linked=$((linked + 1))
  done

  [ "$DRY_RUN" = "1" ] || ok "$label ($linked linked, $skipped kept)"
}

info "Cross-project skills (symlinked to the repo)"
link_skills_into "$CLAUDE_HOME/skills" "~/.claude/skills" "$REPO/.agents/skills" "$MACHINE_SKILLS"

# Machine-only skills: design, frontend direction, product management. They are
# not project rules, so setup.sh does not install them into a repo.
info "Machine-only skills (design, frontend, product)"
link_skills_into "$CLAUDE_HOME/skills" "~/.claude/skills" "$REPO/global/skills" ""

# Antigravity reads global skills from here, and workspace skills from a
# project's own .agents/skills/. Only the global side needs linking.
GEMINI_SKILLS="${GEMINI_SKILLS:-$HOME/.gemini/config/skills}"
if [ -d "$(dirname "$GEMINI_SKILLS")" ] || [ -d "$GEMINI_SKILLS" ]; then
  link_skills_into "$GEMINI_SKILLS" "~/.gemini/config/skills" "$REPO/.agents/skills" "$MACHINE_SKILLS"
else
  warn "Antigravity not set up here, skipped: $GEMINI_SKILLS"
fi
echo

# --------------------------------------------------------------- 3. settings

# Only the portable keys. permissions.allow and additionalDirectories hold
# absolute project paths, hooks and statusLine hold tool-install paths; all four
# are left to rebuild on this machine.
info "Claude Code settings"

if [ "$DRY_RUN" = "1" ]; then
  echo "  would merge into ~/.claude/settings.json: model, effortLevel,"
  echo "  permissions.deny, extraKnownMarketplaces, enabledPlugins"
else
  mkdir -p "$CLAUDE_HOME"
  SETTINGS_MSG="$(python3 - "$SETTINGS" <<'PY'
import json, sys, os

path = sys.argv[1]

DENY = [
    "Bash(rm -rf *)",
    "Bash(git push --force *)",
    "Bash(git reset --hard *)",
    "PowerShell(Remove-Item * -Recurse -Force *)",
    "Edit(.git/**)",
    "Edit(.claude/**)",
]
MARKETPLACES = {
    "claude-plugins-official": {"source": {"source": "github", "repo": "anthropics/claude-plugins-official"}},
    "knowledge-work-plugins": {"source": {"source": "github", "repo": "anthropics/knowledge-work-plugins"}},
    "last30days-skill": {"source": {"source": "github", "repo": "mvanhorn/last30days-skill"}},
    "caveman": {"source": {"source": "github", "repo": "JuliusBrussee/caveman"}},
}
PLUGINS = [
    "code-review@claude-plugins-official",
    "figma@claude-plugins-official",
    "playground@claude-plugins-official",
    "superpowers@claude-plugins-official",
    "engineering@knowledge-work-plugins",
    "last30days@last30days-skill",
    "caveman@caveman",
]

try:
    with open(path, encoding="utf-8") as fh:
        settings = json.load(fh)
except FileNotFoundError:
    settings = {}
except (OSError, ValueError) as exc:
    print("left alone, unreadable (%s)" % exc)
    raise SystemExit(0)

if not isinstance(settings, dict):
    print("left alone, not a JSON object")
    raise SystemExit(0)

changed = []

if "model" not in settings:
    settings["model"] = "opus"
    changed.append("model")
if "effortLevel" not in settings:
    settings["effortLevel"] = "high"
    changed.append("effortLevel")

perms = settings.setdefault("permissions", {})
deny = perms.setdefault("deny", [])
added = [d for d in DENY if d not in deny]
deny.extend(added)
if added:
    changed.append("permissions.deny +%d" % len(added))

markets = settings.setdefault("extraKnownMarketplaces", {})
added = [k for k in MARKETPLACES if k not in markets]
for k in added:
    markets[k] = MARKETPLACES[k]
if added:
    changed.append("marketplaces +%d" % len(added))

plugins = settings.setdefault("enabledPlugins", {})
added = [p for p in PLUGINS if p not in plugins]
for p in added:
    plugins[p] = True
if added:
    changed.append("plugins +%d" % len(added))

if not changed:
    print("already current")
    raise SystemExit(0)

tmp = path + ".tmp"
with open(tmp, "w", encoding="utf-8") as fh:
    json.dump(settings, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
os.replace(tmp, path)
print(", ".join(changed))
PY
)"
  ok "settings.json: $SETTINGS_MSG"
  warn "hooks and statusLine not written — GitNexus, the caveman plugin, and the"
  warn "  Antigravity extension register their own once installed"
fi
echo

# ------------------------------------------------------------ 4. MCP servers

info "MCP servers (user scope)"

add_mcp() {
  local name="$1" spec="$2"
  if [ "$DRY_RUN" = "1" ]; then
    printf '  would add mcp %s\n' "$name"
    return
  fi
  if ! command -v claude >/dev/null 2>&1; then
    printf "  claude mcp add-json --scope user %s '%s'\n" "$name" "$spec"
    return
  fi
  if claude mcp get "$name" >/dev/null 2>&1; then
    ok "$name already registered"
    return
  fi
  if claude mcp add-json --scope user "$name" "$spec" >/dev/null 2>&1; then
    ok "$name added"
  else
    warn "$name failed — add by hand:"
    printf "    claude mcp add-json --scope user %s '%s'\n" "$name" "$spec"
  fi
}

command -v claude >/dev/null 2>&1 || warn "claude CLI absent — run these once it is installed:"

add_mcp gitnexus '{"command":"npx","args":["-y","gitnexus@latest","mcp"]}'
add_mcp agentmemory '{"command":"npx","args":["-y","@agentmemory/mcp"],"env":{"AGENTMEMORY_URL":"${AGENTMEMORY_URL:-http://localhost:3111}","AGENTMEMORY_SECRET":"${AGENTMEMORY_SECRET:-}","AGENTMEMORY_TOOLS":"${AGENTMEMORY_TOOLS:-all}"}}'

if [ -x "$HOME/.caveman/bin/caveman-mcp" ]; then
  add_mcp caveman "{\"type\":\"stdio\",\"command\":\"$HOME/.caveman/bin/caveman-mcp\",\"args\":[],\"env\":{}}"
else
  warn "caveman CLI not installed — its MCP server and hooks come with it"
fi
echo

# ---------------------------------------------------------------- 5. verify

if [ "$DRY_RUN" != "1" ]; then
  info "Verify"
  bash "$REPO/scripts/validate-pointers.sh" "$REPO" || warn "pointer validation reported problems"
  linked=$(find "$CLAUDE_HOME/skills" -maxdepth 1 -type l 2>/dev/null | wc -l | tr -d ' ')
  broken=$(find "$CLAUDE_HOME/skills" -maxdepth 1 -type l ! -exec test -e {} \; -print 2>/dev/null | wc -l | tr -d ' ')
  ok "~/.claude/skills: $linked symlinks, $broken broken"
  if python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$SETTINGS" 2>/dev/null; then
    ok "settings.json valid JSON"
  else
    warn "settings.json does not parse — Claude Code ignores every setting in a broken file"
  fi
  echo
fi

# ------------------------------------------------------------------ 6. next

if [ "$DRY_RUN" = "1" ]; then
  warn "DRY_RUN finished — nothing written."
  exit 0
fi

printf '%sMachine layer ready.%s\n\n' "$GREEN" "$NC"
cat <<'NEXT'
Install the tools that register their own hooks:

  npm i -g @caveman-ai/cli          # caveman: statusLine + 8 hooks + MCP
  npx gitnexus@latest analyze       # GitNexus: 2 hooks + per-repo index

Restart Claude Code once, so it installs the plugins the settings now enable.

Sign in to the connector MCP servers from an interactive session — Figma,
Atlassian, Claude Docs, Linear, Notion, Slack. Nothing here can copy that auth:
  /mcp

Then, inside each project repo:
  bash <this repo>/setup.sh /path/to/project

Antigravity only: its auto-approval extension writes a PreToolUse hook whose
path lives in the IDE's globalStorage. Re-derive it on this machine.
NEXT
