#!/usr/bin/env bash
#
# Install the v2 agent-rules layout into a target repository.
#
# Usage:
#   bash /path/to/ag-agent-rules/setup.sh [target-repo]   # default: current directory
#   FORCE=1 bash setup.sh [target-repo]                   # overwrite existing files (.bak kept)
#
# Installs:
#   AGENTS.md            canonical instructions (Codex and Antigravity read this natively)
#   CLAUDE.md            Claude Code adapter
#   GEMINI.md            Antigravity adapter
#   CONTEXT.md           domain glossary
#   .agents/skills/      shared skills (Antigravity reads workspace skills here)
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
copy_file GEMINI.md
copy_file CONTEXT.md
echo

# ------------------------------------------------------- 2. shared skills/rules

info "Shared skills, rules, memory"
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

info "Managed .gitignore block"

GITIGNORE="$TARGET_DIR/.gitignore"
BEGIN='# >>> ag-agent-rules >>>'
END='# <<< ag-agent-rules <<<'

# Only what this install generates, plus the credential shape that has no
# legitimate reason to be committed. Deliberately NOT here: .agents/, .ai/,
# AGENTS.md, CONTEXT.md — those must be committed or Codex and Antigravity
# get nothing on a teammate's clone. Nor blanket credential extensions:
# many repos track signing assets for CI on purpose.
read -r -d '' BLOCK <<'IGNORE_BLOCK' || true
# Managed by ag-agent-rules setup.sh. Edits between the markers are overwritten.
#
# Committed on purpose (do not add them here): AGENTS.md, CONTEXT.md,
# .agents/skills/, .ai/rules/, .ai/memory/, .ai/plans/ — the agent layer has to
# travel with the repo for Codex and Antigravity to read it.

.DS_Store

# setup.sh writes these when overwriting an existing file
*.bak

# per-machine agent state
.claude/settings.local.json
.claude/skills/

# service-account keys are never a repo artifact
**/*service-account*.json
IGNORE_BLOCK

if [ -f "$GITIGNORE" ] && grep -qF "$BEGIN" "$GITIGNORE"; then
  # Replace the existing block in place, leaving the rest of the file alone.
  awk -v b="$BEGIN" -v e="$END" '
    index($0, b) { skip = 1; print "@@BLOCK@@"; next }
    index($0, e) { skip = 0; next }
    !skip
  ' "$GITIGNORE" > "$GITIGNORE.tmp"

  {
    while IFS= read -r line; do
      if [ "$line" = "@@BLOCK@@" ]; then
        printf '%s\n%s\n%s\n' "$BEGIN" "$BLOCK" "$END"
      else
        printf '%s\n' "$line"
      fi
    done < "$GITIGNORE.tmp"
  } > "$GITIGNORE"
  rm -f "$GITIGNORE.tmp"
  ok ".gitignore block refreshed"
else
  [ -f "$GITIGNORE" ] || : > "$GITIGNORE"
  printf '\n%s\n%s\n%s\n' "$BEGIN" "$BLOCK" "$END" >> "$GITIGNORE"
  ok ".gitignore block added"
fi

# A tracked file is not affected by a new ignore rule — say so rather than
# letting the user assume something got hidden.
if [ -d "$TARGET_DIR/.git" ]; then
  already_tracked=$(cd "$TARGET_DIR" && git ls-files 2>/dev/null \
    | grep -E 'service-account.*\.json$|\.bak$' | head -5 || true)
  if [ -n "$already_tracked" ]; then
    warn "already tracked, so the new rules do not hide them:"
    printf '    %s\n' $already_tracked
    warn "untrack with: git rm --cached <path>  (rotate the credential too)"
  fi
fi
echo

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
