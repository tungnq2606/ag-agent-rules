# uniscore-mobile — personal agent layer (backup)

Backup of files that exist only on one machine because the team repo gitignores or excludes them:
`.ai/` (rules, memory, plans, `AGENTS.mine.md`, `scripts/keep-mine.sh`), `.agents/hooks*`, the two
project-only skills, and `.claude/settings.local.json`.

- `AGENTS.mine.md` is the AGENTS.md I use instead of the team's. Keep it under 24,000 bytes: Antigravity truncates larger rule files.
- Shared skills are not duplicated here; `restore.sh` takes them from the template in this repo (`../../.agents/skills`).
- Restore: `bash projects/uniscore-mobile/restore.sh [path]`. Never overwrites; `FORCE=1` overwrites.
- Snapshot of 2026-10-16. Re-sync with `rsync -rt --no-links --exclude .DS_Store <project>/.ai/ ai/` (and the same for `.agents/hooks`).
