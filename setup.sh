#!/usr/bin/env bash
#
# Install the v2 agent-rules layout into a target repository.
#
# Usage:
#   bash /path/to/ag-agent-rules/setup.sh [target-repo]   # default: current directory
#   FORCE=1 bash setup.sh [target-repo]                   # overwrite existing files (.bak kept)
#
# Installs:
#   AGENTS.md            canonical instructions (Codex reads this natively)
#   CLAUDE.md            Claude Code adapter
#   CONTEXT.md           domain glossary
#   .agents/AGENTS.md    Antigravity adapter
#   .agents/skills/      shared skills
#   .ai/rules/           on-demand rules
#   .ai/memory/          session memory skeleton
#   .ai/plans/           persisted plans
#   .claude/skills/      Claude native skill discovery (pointers to .agents/skills/)

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(cd "${1:-$PWD}" && pwd)"
FORCE="${FORCE:-0}"

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'; CYAN=$'\033[0;36m'; NC=$'\033[0m'
ok()   { printf '%s✓%s %s\n' "$GREEN" "$NC" "$1"; }
info() { printf '%s→%s %s\n' "$CYAN" "$NC" "$1"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$NC" "$1"; }
die()  { printf '%s✗%s %s\n' "$RED" "$NC" "$1" >&2; exit 1; }

[ "$SOURCE_DIR" = "$TARGET_DIR" ] && die "Target must differ from the agent-rules repo itself."
[ -f "$SOURCE_DIR/AGENTS.md" ] || die "AGENTS.md not found in $SOURCE_DIR — wrong source repo?"

info "Source: $SOURCE_DIR"
info "Target: $TARGET_DIR"
[ -d "$TARGET_DIR/.git" ] || warn "$TARGET_DIR is not a git repository."
echo

# ---------------------------------------------------------------- copy helpers

copy_file() {
  local rel="$1" src="$SOURCE_DIR/$1" dst="$TARGET_DIR/$1"
  [ -f "$src" ] || { warn "missing in source, skipped: $rel"; return; }
  mkdir -p "$(dirname "$dst")"
  if [ -f "$dst" ] && [ "$FORCE" != "1" ]; then
    warn "exists, kept: $rel"
    return
  fi
  [ -f "$dst" ] && cp "$dst" "$dst.bak" && warn "backed up: $rel.bak"
  cp "$src" "$dst"
  ok "$rel"
}

copy_tree() {
  local rel="$1" src="$SOURCE_DIR/$1" dst="$TARGET_DIR/$1"
  [ -d "$src" ] || { warn "missing in source, skipped: $rel"; return; }
  mkdir -p "$dst"
  local flags=(-a --exclude='.DS_Store')
  [ "$FORCE" = "1" ] || flags+=(--ignore-existing)
  rsync "${flags[@]}" "$src/" "$dst/"
  ok "$rel ($(find "$dst" -type f ! -name '.DS_Store' | wc -l | tr -d ' ') files)"
}

# ------------------------------------------------------------------- 1. root

info "Instruction files"
copy_file AGENTS.md
copy_file CLAUDE.md
copy_file CONTEXT.md
echo

# ------------------------------------------------------- 2. shared skills/rules

info "Shared skills, rules, memory"
copy_file .agents/AGENTS.md
copy_tree .agents/skills
copy_tree .ai/rules
copy_tree .ai/memory
copy_tree .ai/plans
mkdir -p "$TARGET_DIR/.ai/plans/active" "$TARGET_DIR/.ai/plans/completed"
ok ".ai/plans/{active,completed}"
echo

# ------------------------------------------------- 3. Claude skill discovery

info "Claude native skill discovery (.claude/skills/)"
CLAUDE_SKILLS="$TARGET_DIR/.claude/skills"
mkdir -p "$CLAUDE_SKILLS"
linked=0
kept=0
for skill_dir in "$TARGET_DIR"/.agents/skills/*/; do
  [ -d "$skill_dir" ] || continue
  name="$(basename "$skill_dir")"
  link="$CLAUDE_SKILLS/$name"

  if [ -L "$link" ]; then
    # A symlink we made before: safe to refresh.
    rm "$link"
  elif [ -e "$link" ]; then
    # A real directory the project owns. Never delete it.
    warn "project skill kept, not linked: $name"
    kept=$((kept + 1))
    continue
  fi

  ln -s "../../.agents/skills/$name" "$link"
  linked=$((linked + 1))
done
ok ".claude/skills/ ($linked symlink, $kept project-owned kept)"
[ "$kept" -gt 0 ] && warn "A kept name shadows the shared skill. Rename one, or delete the project copy by hand."
echo

# -------------------------------------------------------------- 4. .gitignore

if [ -f "$TARGET_DIR/.gitignore" ] && ! grep -qx '\.DS_Store' "$TARGET_DIR/.gitignore"; then
  printf '\n.DS_Store\n' >> "$TARGET_DIR/.gitignore"
  ok ".gitignore += .DS_Store"
fi

# --------------------------------------------------------------- 5. validate

if [ -x "$SOURCE_DIR/scripts/validate-pointers.sh" ]; then
  info "Validating pointers in target"
  bash "$SOURCE_DIR/scripts/validate-pointers.sh" "$TARGET_DIR" || warn "pointer validation reported problems"
  echo
fi

# ------------------------------------------------------------------ 6. next

printf '%sDone.%s Next steps:\n\n' "$GREEN" "$NC"
cat <<'NEXT'
  1. Edit AGENTS.md — replace the Project and Always-On Invariants sections
     with this repository's real stack and invariants.
  2. Edit .ai/rules/code-style.md — real component names, path aliases, scripts.
  3. Edit .ai/rules/verification.md — real typecheck/test/build commands.
  4. Edit .ai/rules/build-release.md — real environments, schemes, gradle tasks.
  5. Leave .ai/memory/* empty until a session actually produces durable state.

Re-run with FORCE=1 to overwrite existing files (originals kept as *.bak).
NEXT
