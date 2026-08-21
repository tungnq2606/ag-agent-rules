#!/usr/bin/env bash
#
# Set up the agent-level (machine) layer on a new machine.
#
# Usage:
#   bash scripts/bootstrap-machine.sh              # install
#   DRY_RUN=1 bash scripts/bootstrap-machine.sh    # show what would change
#   FORCE=1 bash scripts/bootstrap-machine.sh      # overwrite existing (backup kept)
#
# Installs into ~/.claude:
#   rules/ecc/          agent-level rules only — model choice, hooks. No project policy.
#   skills/<name>       symlinks to this repo's cross-project skills. One source, no copies.
#
# The project layer is separate: run setup.sh inside a project repo for that.
#
# Symlinks point at this repo's path. Moving the repo breaks them — re-run this script.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
DRY_RUN="${DRY_RUN:-0}"
FORCE="${FORCE:-0}"

GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'; CYAN=$'\033[0;36m'; RED=$'\033[0;31m'; NC=$'\033[0m'
ok()   { printf '%s✓%s %s\n' "$GREEN" "$NC" "$1"; }
info() { printf '%s→%s %s\n' "$CYAN" "$NC" "$1"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$NC" "$1"; }
die()  { printf '%s✗%s %s\n' "$RED" "$NC" "$1" >&2; exit 1; }

# Cross-project skills: self-contained, no dependency on a project's .ai/ layout.
MACHINE_SKILLS="
codebase-design
react-native-reanimated
gitnexus-cli
gitnexus-debugging
gitnexus-exploring
gitnexus-guide
gitnexus-impact-analysis
gitnexus-pr-review
gitnexus-refactoring
"

[ -d "$REPO/global/rules" ] || die "global/rules not found — wrong repo?"
[ "$DRY_RUN" = "1" ] && warn "DRY_RUN: nothing will be written"

info "Repo:   $REPO"
info "Target: $CLAUDE_HOME"
echo

# ------------------------------------------------------------------ 1. rules

info "Agent-level rules"
RULES_DEST="$CLAUDE_HOME/rules"

if [ -d "$RULES_DEST/ecc" ] && [ "$FORCE" != "1" ] && [ "$DRY_RUN" != "1" ]; then
  BACKUP="$RULES_DEST/ecc.backup-$(date +%Y%m%d%H%M%S)"
  cp -R "$RULES_DEST/ecc" "$BACKUP"
  warn "backed up existing rules to $BACKUP"
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

info "Cross-project skills (symlinked to the repo)"
SKILLS_DEST="$CLAUDE_HOME/skills"
[ "$DRY_RUN" = "1" ] || mkdir -p "$SKILLS_DEST"

linked=0
skipped=0
for name in $MACHINE_SKILLS; do
  src="$REPO/.agents/skills/$name"
  dst="$SKILLS_DEST/$name"

  [ -d "$src" ] || { warn "missing in repo, skipped: $name"; continue; }

  if [ "$DRY_RUN" = "1" ]; then
    printf '  would link %s -> %s\n' "$name" "$src"
    continue
  fi

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    if [ "$FORCE" != "1" ]; then
      warn "real directory exists, kept: $name (FORCE=1 to replace)"
      skipped=$((skipped + 1))
      continue
    fi
    mv "$dst" "$dst.backup-$(date +%Y%m%d%H%M%S)"
    warn "moved aside: $name"
  fi

  ln -s "$src" "$dst"
  linked=$((linked + 1))
done

[ "$DRY_RUN" = "1" ] || ok "skills ($linked linked, $skipped kept)"
echo

# ------------------------------------------------------------------ 3. next

if [ "$DRY_RUN" = "1" ]; then
  warn "DRY_RUN finished — nothing written."
  exit 0
fi

printf '%sMachine layer ready.%s\n\n' "$GREEN" "$NC"
cat <<'NEXT'
Still manual on a new machine — see global/MACHINE-SETUP.md:
  1. Claude Code settings: model, hooks, permissions.
  2. Plugins: install what you want, and check global/MACHINE-SETUP.md for
     which ones conflict with this repository's routing.
  3. MCP servers (GitNexus and any connectors) need their own auth.

Then, inside each project repo:
  bash <repo>/setup.sh /path/to/project
NEXT
