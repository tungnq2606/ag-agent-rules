#!/usr/bin/env bash
# Restore the personal uniscore-mobile agent layer into a clone of the repo.
# Usage: bash restore.sh [path-to-uniscore-mobile]   (default: ~/Documents/works/uniscore-mobile)
# Safe by default: never overwrites an existing file; FORCE=1 overwrites.
set -euo pipefail
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
T="$(cd "${1:-$HOME/Documents/works/uniscore-mobile}" && pwd)"
[ -d "$T/.git" ] || { echo "not a git repo: $T" >&2; exit 1; }
put() { # put <src-dir> <dst-dir>
  mkdir -p "$2"
  if [ "${FORCE:-0}" = 1 ]; then rsync -rt --exclude .DS_Store "$1/" "$2/"
  else rsync -rt --ignore-existing --exclude .DS_Store "$1/" "$2/"; fi
}
put "$SRC/ai" "$T/.ai"
put "$SRC/agents/hooks" "$T/.agents/hooks"
put "$SRC/agents/skills" "$T/.agents/skills"; rm -f "$T/.agents/skills/SYMLINKS_TO_CLAUDE_SKILLS.txt"
# hooks.json carries absolute paths; point them at this clone
[ -e "$T/.agents/hooks.json" ] && [ "${FORCE:-0}" != 1 ] || sed "s|/Users/quoctung/Documents/works/uniscore-mobile|$T|g" "$SRC/agents/hooks.json" > "$T/.agents/hooks.json"
mkdir -p "$T/.claude"
[ -e "$T/.claude/settings.local.json" ] && [ "${FORCE:-0}" != 1 ] || cp "$SRC/claude/settings.local.json" "$T/.claude/settings.local.json"
# shared skills come from the repo template; the team-owned ones are symlinks into .claude/skills
put "$SRC/../../.agents/skills" "$T/.agents/skills"
while read -r s; do [ -n "$s" ] && [ -d "$T/.claude/skills/$s" ] && ln -sfn "../../.claude/skills/$s" "$T/.agents/skills/$s"; done < "$SRC/agents/skills/SYMLINKS_TO_CLAUDE_SKILLS.txt"
chmod +x "$T/.agents/hooks/"*.sh "$T/.ai/scripts/"*.sh
# keep my AGENTS.md instead of the team's (see .ai/scripts/keep-mine.sh)
for h in post-merge post-checkout post-rewrite; do
  printf '#!/usr/bin/env bash\nexec "$(git rev-parse --show-toplevel)/.ai/scripts/keep-mine.sh" restore\n' > "$T/.git/hooks/$h"; chmod +x "$T/.git/hooks/$h"
done
git -C "$T" config alias.up '!bash "$(git rev-parse --show-toplevel)/.ai/scripts/keep-mine.sh" up'
# .ai is not in .gitignore; exclude it locally. .agents/ is already gitignored upstream.
grep -qxF '/.ai' "$T/.git/info/exclude" || echo '/.ai' >> "$T/.git/info/exclude"
grep -qxF '/.claude/settings.local.json' "$T/.git/info/exclude" || echo '/.claude/settings.local.json' >> "$T/.git/info/exclude"
if [ "${FORCE:-0}" = 1 ] || ! cmp -s "$T/.ai/AGENTS.mine.md" "$T/AGENTS.md"; then cp "$T/.ai/AGENTS.mine.md" "$T/AGENTS.md"; fi
"$T/.ai/scripts/keep-mine.sh" restore
echo "restored into $T. Start a new Claude Code / Antigravity session."
