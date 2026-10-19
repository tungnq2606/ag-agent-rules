#!/usr/bin/env bash
# Copy the personal uniscore-mobile agent layer from a project clone into this backup.
# Usage: bash sync-backup.sh [path-to-uniscore-mobile]   (default: ~/Documents/works/uniscore-mobile)
#   DRY_RUN=1  show what would change, write nothing
#   DELETE=1   also remove backup files that no longer exist in the project
# Never commits. Review with `git status` / `git diff`, then commit yourself.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
P="$(cd "${1:-$HOME/Documents/works/uniscore-mobile}" && pwd)"
[ -d "$P/.ai" ] || { echo "no .ai/ in $P: wrong path?" >&2; exit 1; }

RS=(rsync -rt --no-links --exclude .DS_Store)
[ "${DRY_RUN:-0}" = 1 ] && RS+=(-n -i)
[ "${DELETE:-0}" = 1 ] && RS+=(--delete)
run() { "${RS[@]}" "$@"; }
write() { [ "${DRY_RUN:-0}" = 1 ] && echo "(dry) would write $1" || cat > "$1"; }

run "$P/.ai/" "$HERE/ai/"
[ -d "$P/.agents/hooks" ] && run "$P/.agents/hooks/" "$HERE/agents/hooks/"

# hooks.json carries absolute paths; store a placeholder, restore.sh fills in the target
if [ -f "$P/.agents/hooks.json" ]; then
  sed "s|$P|__PROJECT__|g" "$P/.agents/hooks.json" | write "$HERE/agents/hooks.json"
fi
[ -f "$P/.claude/settings.local.json" ] && { [ "${DRY_RUN:-0}" = 1 ] || cp "$P/.claude/settings.local.json" "$HERE/claude/settings.local.json"; }

# skills: real dirs that the shared template does not carry, plus the list of symlinks
mkdir -p "$HERE/agents/skills"
links=()
for d in "$P"/.agents/skills/*; do
  n="$(basename "$d")"
  if [ -L "$d" ]; then links+=("$n")
  elif [ -d "$d" ] && [ ! -d "$REPO/.agents/skills/$n" ] && [ -n "$(find "$d" -type f ! -name .DS_Store | head -1)" ]; then
    run "$d/" "$HERE/agents/skills/$n/"
  fi
done
printf '%s\n' "${links[@]}" | sort | write "$HERE/agents/skills/SYMLINKS_TO_CLAUDE_SKILLS.txt"

# Antigravity truncates rule files over 24,000 bytes
size=$(wc -c < "$HERE/ai/AGENTS.mine.md" 2>/dev/null || echo 0)
[ "$size" -ge 24000 ] && echo "WARNING: AGENTS.mine.md is $size bytes (Antigravity limit 24000); the tail will be cut." >&2
echo "synced from $P. Review: git -C '$REPO' status --short projects/uniscore-mobile"
