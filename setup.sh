#!/usr/bin/env bash
#
# Install the v2 agent-rules layout into a target repository.
#
# Usage:
#   bash /path/to/ag-agent-rules/setup.sh [target-repo]   # default: current directory
#   FORCE=1 bash setup.sh [target-repo]                   # overwrite existing files (no backup)
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
#   .agents/hooks/       SessionStart hook putting AGENTS.md Rule Compliance in force

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
  cp "$src" "$dst"
  ok "$rel"
}

# Second argument "keep" pins a tree to fill-only: existing files survive even
# under FORCE. Session memory belongs to the project, not to this installer —
# overwriting it with the empty skeleton destroys the live handoff.
copy_tree() {
  local rel="$1" mode="${2:-}" src="$SOURCE_DIR/$1" dst="$TARGET_DIR/$1"
  [ -d "$src" ] || { warn "missing in source, skipped: $rel"; return; }
  mkdir -p "$dst"
  local flags=(-a --exclude='.DS_Store')
  if [ "$mode" = "keep" ] || [ "$FORCE" != "1" ]; then
    flags+=(--ignore-existing)
  fi
  rsync "${flags[@]}" "$src/" "$dst/"
  local note=""
  [ "$mode" = "keep" ] && [ "$FORCE" = "1" ] && note=", existing kept"
  ok "$rel ($(find "$dst" -type f ! -name '.DS_Store' | wc -l | tr -d ' ') files$note)"
}

# ------------------------------------------------------------------- 1. root

info "Instruction files"
copy_file AGENTS.md
copy_file CLAUDE.md
copy_file GEMINI.md
copy_file CONTEXT.md

# Older versions of this script left <file>.bak beside the real file. A stale
# AGENTS.md.bak in the root is a second instruction file an agent can read.
stale_bak=$(find "$TARGET_DIR" -maxdepth 1 -name '*.bak' -type f | head -5)
if [ -n "$stale_bak" ]; then
  warn "backups from an older setup.sh, no longer written or ignored:"
  printf '    %s\n' $stale_bak
  warn "delete them: rm $TARGET_DIR/*.bak"
fi
echo

# ------------------------------------------------------- 2. shared skills/rules

info "Shared skills, rules, memory"
copy_tree .agents/skills
copy_tree .ai/rules
copy_tree .ai/memory keep
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

# ------------------------------------------- 3b. Rule Compliance session hook

info "Rule Compliance session hook"

HOOK_DIR="$TARGET_DIR/.agents/hooks"
mkdir -p "$HOOK_DIR"
cp "$SOURCE_DIR/scripts/rule-compliance-hook.sh" "$HOOK_DIR/rule-compliance.sh"
chmod +x "$HOOK_DIR/rule-compliance.sh"
ok ".agents/hooks/rule-compliance.sh"

# A markdown rule binds only an agent that opens the file. The hook is what
# makes it reach context every session, so wire it into Claude's settings too.
if command -v python3 >/dev/null 2>&1; then
  HOOK_MSG="$(python3 - "$TARGET_DIR/.claude/settings.json" <<'PY'
import json, os, sys

path = sys.argv[1]
command = 'bash "$CLAUDE_PROJECT_DIR/.agents/hooks/rule-compliance.sh"'

try:
    with open(path, encoding="utf-8") as fh:
        settings = json.load(fh)
except FileNotFoundError:
    settings = {}
except (OSError, ValueError) as exc:
    print("settings.json left alone (%s)" % exc)
    raise SystemExit(0)

if not isinstance(settings, dict):
    print("settings.json is not an object, left alone")
    raise SystemExit(0)

hooks = settings.setdefault("hooks", {})
entries = hooks.setdefault("SessionStart", [])

for entry in entries:
    for hook in (entry or {}).get("hooks", []):
        if "rule-compliance" in str(hook.get("command", "")):
            print("SessionStart hook already wired")
            raise SystemExit(0)

entries.append({"hooks": [{"type": "command", "command": command}]})
os.makedirs(os.path.dirname(path), exist_ok=True)
with open(path, "w", encoding="utf-8") as fh:
    json.dump(settings, fh, indent=2, ensure_ascii=False)
    fh.write("\n")
print("SessionStart hook added to .claude/settings.json")
PY
)"
  ok "$HOOK_MSG"
else
  warn "python3 not found — wire the SessionStart hook by hand, see the header of"
  warn "  .agents/hooks/rule-compliance.sh"
fi
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

# per-machine agent state
.claude/settings.local.json
.claude/skills/

# service-account keys are never a repo artifact
**/*service-account*.json
IGNORE_BLOCK

# Drop any pattern the project already ignores outside the block, so the managed
# block never duplicates a line the repo owns. Comments and blanks always stay.
if [ -f "$GITIGNORE" ]; then
  OUTSIDE="$(mktemp)"
  awk -v b="$BEGIN" -v e="$END" '
    index($0, b) { skip = 1; next }
    index($0, e) { skip = 0; next }
    !skip
  ' "$GITIGNORE" > "$OUTSIDE"

  BLOCK="$(printf '%s\n' "$BLOCK" | awk -v out="$OUTSIDE" '
    BEGIN { while ((getline line < out) > 0) seen[line] = 1 }
    /^#/                     { blank = 0; print; next }
    /^[[:space:]]*$/         { if (!blank) print; blank = 1; next }
    !($0 in seen)            { blank = 0; print }
  ')"
  rm -f "$OUTSIDE"
fi

if grep -qF "$BEGIN" "$GITIGNORE" 2>/dev/null; then
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
    | grep -E 'service-account.*\.json$' | head -5 || true)
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

Re-run with FORCE=1 to overwrite existing files. It keeps no backup, so
commit the target repo first.
NEXT
