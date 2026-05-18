#!/usr/bin/env bash
# =============================================================================
# setup.sh — AI Agent Skills Bootstrap
# =============================================================================
# Chạy script này trên máy mới để thiết lập toàn bộ skill cho các AI agents:
#   Claude · Gemini (Antigravity) · Codex
#
# Usage (chạy từ thư mục gốc của bất kỳ repo nào):
#   bash /path/to/agent-skills/setup.sh
#   hoặc:
#   bash /path/to/agent-skills/setup.sh --repo /path/to/your-repo
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Xác định repo target: arg --repo hoặc thư mục hiện tại
TARGET_REPO="$(pwd)"
if [[ "${1:-}" == "--repo" && -n "${2:-}" ]]; then
  TARGET_REPO="$2"
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${CYAN}→${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

echo ""
echo "════════════════════════════════════════"
echo "  AI Agent Skills Setup"
echo "════════════════════════════════════════"
echo "  Target repo: $TARGET_REPO"
echo ""

# -----------------------------------------------------------------------------
# 1. ~/.agents/skills/ — Global skills (Codex + symlink target for Antigravity)
# -----------------------------------------------------------------------------
info "Thiết lập ~/.agents/skills/ ..."

mkdir -p "$HOME/.agents/skills"

rsync -a --exclude='.DS_Store' \
  "$SCRIPT_DIR/agents-skills/" \
  "$HOME/.agents/skills/"

log "~/.agents/skills/ OK (react-native-best-practices + gitnexus skills)"

# -----------------------------------------------------------------------------
# 2. ~/.gemini/antigravity/skills/ — Antigravity skills
# -----------------------------------------------------------------------------
info "Thiết lập ~/.gemini/antigravity/skills/ ..."

mkdir -p "$HOME/.gemini/antigravity/skills"

rsync -a --exclude='.DS_Store' \
  "$SCRIPT_DIR/antigravity-skills/" \
  "$HOME/.gemini/antigravity/skills/"

# Symlink react-native-best-practices
SYMLINK_TARGET="$HOME/.gemini/antigravity/skills/react-native-best-practices"
SYMLINK_SOURCE="../../../.agents/skills/react-native-best-practices"

if [ -L "$SYMLINK_TARGET" ]; then
  warn "Symlink react-native-best-practices đã tồn tại, bỏ qua."
elif [ -d "$SYMLINK_TARGET" ]; then
  warn "Thư mục react-native-best-practices đã tồn tại (không phải symlink). Bỏ qua."
else
  ln -s "$SYMLINK_SOURCE" "$SYMLINK_TARGET"
  log "Symlink react-native-best-practices → ~/.agents/skills/"
fi

log "~/.gemini/antigravity/skills/ OK"

# -----------------------------------------------------------------------------
# 3. ~/.agents/.skill-lock.json
# -----------------------------------------------------------------------------
info "Tạo ~/.agents/.skill-lock.json ..."

cat > "$HOME/.agents/.skill-lock.json" << 'EOF'
{
  "version": 3,
  "skills": {
    "react-native-best-practices": {
      "source": "callstackincubator/agent-skills",
      "sourceType": "github",
      "sourceUrl": "https://github.com/callstackincubator/agent-skills.git",
      "skillPath": "skills/react-native-best-practices/SKILL.md",
      "installedAt": "auto-setup",
      "updatedAt": "auto-setup"
    }
  }
}
EOF

log "~/.agents/.skill-lock.json OK"

# -----------------------------------------------------------------------------
# 4. memory/ — Khởi tạo shared memory cho AI agents trong repo target
# -----------------------------------------------------------------------------
info "Khởi tạo memory/ trong $TARGET_REPO ..."

MEMORY_DIR="$TARGET_REPO/memory"

if [ -d "$MEMORY_DIR" ]; then
  warn "memory/ đã tồn tại, bỏ qua (không ghi đè)."
else
  mkdir -p "$MEMORY_DIR"

  # context.md
  cat > "$MEMORY_DIR/context.md" << 'EOF'
# Project Context

> This file reflects current project state. AI agents MUST update this when starting/completing tasks. Can be overwritten (not append-only). **Max 100 lines** — keep it compact.

## Current Focus

(no active task)

## Recently Completed

(none yet)

## Known Issues

(none)

## Tech Stack Summary

(fill in: language, framework, key tools — or run scan-project.md to auto-populate)

## Session Log (last 5 sessions)

(no sessions yet)
EOF

  # lessons-learned.md
  cat > "$MEMORY_DIR/lessons-learned.md" << 'EOF'
# Lessons Learned

> Append-only. Never delete entries. Mark outdated entries `[ARCHIVED]`.
> All entries MUST include Tags for searchability. Max 30 active entries.

## Active Lessons

<!-- Add new lessons here. Format:
### [YYYY-MM-DD] Short descriptive title
- **Tags**: keyword1, keyword2, keyword3
- **Confidence**: LOW | MEDIUM | HIGH
- **Domain**: code-style | testing | performance | architecture | workflow | android | ios | state-management | socket | notification
- **What went wrong**: concrete description
- **Root cause**: why it happened (not symptoms)
- **Rule**: actionable rule to prevent recurrence
- **Last confirmed**: YYYY-MM-DD
-->

---

## Archived Lessons

<!-- Move outdated/superseded lessons here. Agents skip this section. -->
EOF


  # decisions.md
  cat > "$MEMORY_DIR/decisions.md" << 'EOF'
# Architecture Decisions

> Append-only. Never delete entries. Format below.

<!-- Add new decisions here. Format:
### [YYYY-MM-DD] Decision title
- **Tags**: keyword1, keyword2, keyword3
- **Context**: what problem we were solving
- **Decision**: what we chose
- **Alternatives**: what we rejected and why
- **Consequences**: what this means going forward
-->
EOF

  # handoff.md
  cat > "$MEMORY_DIR/handoff.md" << 'EOF'
# Handoff

**Status**: IDLE
**From**: —
**To**: —
**Date**: —
**Task**: —
**Plan file**: — (none)

---

## Current State

(no active handoff)

## Files Modified

(none)

## Next Steps

(none)

## Open Questions

(none)
EOF

  # README.md
  cat > "$MEMORY_DIR/README.md" << 'EOF'
# Memory System

Shared memory for all AI agents (Claude, Gemini, Codex, Antigravity).

## Files

| File | Purpose | Read order |
|------|---------|:----------:|
| `COMPACT.md` | Quick context (~30 lines) | ⚡ 1st |
| `handoff.md` | Agent-to-agent transfer | 2nd |
| `INDEX.md` | Keyword → lesson search | 3rd (if needed) |
| `context.md` | Project state (detailed) | 4th (if needed) |
| `lessons-learned.md` | Mistakes → rules (append-only) | Smart-scan |
| `decisions.md` | Architecture decisions (append-only) | Titles first |
| `capture.sh` | Helper script for session logging | N/A |

Global memory: `~/.agents/memory/` (cross-project lessons)

## On Session Start (MANDATORY)

1. Read `COMPACT.md` — instant project awareness
2. Read `handoff.md` — if ACTIVE, pick up the task
3. **If `Plan file` is listed**, read that file before doing anything
4. **If task is complex**, scan `INDEX.md` for matching keywords → deep-read relevant lessons
5. Read `context.md` — only if COMPACT.md lacks needed detail
6. Read `~/.agents/memory/global-lessons.md` — universal rules
7. Prove you read them:
   > **Memory loaded.** Recent lessons: (1) [title], (2) [title], (3) [title].

## On Session End (MANDATORY)

1. Update `context.md` — refresh Current Focus + session log
2. Update `COMPACT.md` — refresh Active Task, Last Session
3. Update `INDEX.md` — if new lessons were added
4. Write new lessons to `lessons-learned.md` if any
5. Or run: `bash memory/capture.sh "<agent>" "<task>" "<files>" "<status>"`

## On Handoff

1. Fill in `handoff.md`, set status to ACTIVE
2. If plan file exists, add absolute path under `Plan file`
3. Update `context.md`

## Writing Lessons (MANDATORY format)

```markdown
### [2026-01-15] Short descriptive title
- **Tags**: keyword1, keyword2, keyword3 (3-5 tags)
- **Confidence**: LOW | MEDIUM | HIGH
- **Domain**: code-style | testing | performance | architecture | workflow
- **What went wrong**: concrete description
- **Root cause**: why it happened
- **Rule**: actionable rule to prevent recurrence
- **Last confirmed**: 2026-01-15
```

## Maintenance

- **Max 30 active lessons** — archive stale entries when exceeded
- **Quarterly review** — check relevance of all active lessons
- **Graduation** — critical lessons → instruction file rules, mark `[GRADUATED]`
- **Never delete** — only archive or graduate
EOF

  # COMPACT.md
  cat > "$MEMORY_DIR/COMPACT.md" << 'EOF'
# Compact Context

> **Agent**: Read this FIRST on session start. Max 30 lines.
> **Update**: Agent refreshes this every session end.

## Project

(fill in: language, framework, key tools)

## Active Task

(none)

## Critical Rules (top 5 lessons)

(none yet — will be populated as lessons accumulate)

## Blockers

(none)

## Last Session

(no sessions yet)
EOF

  # INDEX.md
  cat > "$MEMORY_DIR/INDEX.md" << 'EOF'
# Lesson Index — Keyword → Lesson Mapping

> **Purpose**: Fast keyword lookup. Agent scans this BEFORE reading full lessons.
> **Update rule**: Agent MUST update this when adding/archiving lessons.

## By Domain

(no lessons yet)

## By Keyword

| Keyword | Lessons (dates) |
|---------|----------------|
| (none yet) | |
EOF

  # capture.sh
  cat > "$MEMORY_DIR/capture.sh" << 'SCRIPT'
#!/bin/bash
# Quick session capture helper for AI agents
# Usage: bash memory/capture.sh "<agent>" "<task>" "<files>" "<status>"
set -euo pipefail
AGENT="${1:-Unknown}"
TASK="${2:-Untitled task}"
FILES="${3:-none}"
STATUS="${4:-completed}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
MEMORY_DIR="$(cd "$(dirname "$0")" && pwd)"
CONTEXT_FILE="$MEMORY_DIR/context.md"
COMPACT_FILE="$MEMORY_DIR/COMPACT.md"

# Cross-platform sed -i
sedi() {
  if [[ "$OSTYPE" == "darwin"* ]]; then sed -i '' "$@"; else sed -i "$@"; fi
}

if [ -f "$CONTEXT_FILE" ]; then
  if grep -q "## Session Log" "$CONTEXT_FILE"; then
    ENTRY="\n### [$TIMESTAMP] Agent: $AGENT | Task: $TASK\n- Files: $FILES\n- Status: $STATUS"
    TMPFILE=$(mktemp)
    awk -v entry="$ENTRY" '/## Session Log/{print; print entry; next}1' "$CONTEXT_FILE" > "$TMPFILE"
    mv "$TMPFILE" "$CONTEXT_FILE"
  else
    cat >> "$CONTEXT_FILE" << EOF

## Session Log (last 5 sessions)

### [$TIMESTAMP] Agent: $AGENT | Task: $TASK
- Files: $FILES
- Status: $STATUS
EOF
  fi
fi

if [ -f "$COMPACT_FILE" ]; then
  sedi "s|^\[.*\] .*: .*|[$TIMESTAMP] $AGENT: $TASK|" "$COMPACT_FILE"
fi
echo "✅ Session captured: $AGENT | $TASK | $STATUS"
SCRIPT
  chmod +x "$MEMORY_DIR/capture.sh"

  log "memory/ đã được khởi tạo với 8 files (COMPACT, INDEX, capture.sh, + 5 core files)"
fi

# -----------------------------------------------------------------------------
# 5. Global memory — ~/.agents/memory/ (cross-project lessons)
# -----------------------------------------------------------------------------
info "Khởi tạo global memory (~/.agents/memory/) ..."

GLOBAL_MEMORY="$HOME/.agents/memory"

if [ -d "$GLOBAL_MEMORY" ]; then
  warn "~/.agents/memory/ đã tồn tại, bỏ qua."
else
  mkdir -p "$GLOBAL_MEMORY"

  cat > "$GLOBAL_MEMORY/README.md" << 'EOF'
# Global Agent Memory

> Cross-project lessons and decisions. Per-project memory stays in `<project>/memory/`.

## Rules
- Only add here if a lesson is NOT project-specific
- Examples: TypeScript patterns, React Native gotchas, workflow rules
- Agents read this AFTER project-specific memory
EOF

  cat > "$GLOBAL_MEMORY/global-lessons.md" << 'EOF'
# Global Lessons — Cross-Project

> Universal lessons. Append-only. Skip [GRADUATED] and [ARCHIVED].

## Active Lessons

(none yet)

---

## Archived Lessons
EOF

  cat > "$GLOBAL_MEMORY/global-decisions.md" << 'EOF'
# Global Decisions — Cross-Project

> Universal architecture decisions. Append-only.

(none yet)
EOF

  log "~/.agents/memory/ OK (3 files)"
fi

# -----------------------------------------------------------------------------
# 6. Templates + Scan Prompt — copy vào repo target
# -----------------------------------------------------------------------------
info "Copy templates + scan prompt ..."

TEMPLATES_SRC="$SCRIPT_DIR/templates"
SCAN_PROMPT="$SCRIPT_DIR/scan-project.md"

# Copy instruction file templates (nếu chưa có CLAUDE.md/GEMINI.md)
if [ -d "$TEMPLATES_SRC" ]; then
  for TEMPLATE in "$TEMPLATES_SRC"/*.template; do
    [ -f "$TEMPLATE" ] || continue
    BASENAME=$(basename "$TEMPLATE" .template)
    TARGET_FILE="$TARGET_REPO/$BASENAME"
    if [ ! -f "$TARGET_FILE" ]; then
      cp "$TEMPLATE" "$TARGET_FILE"
      log "Tạo $BASENAME (template — cần chạy scan để populate)"
    else
      warn "$BASENAME đã tồn tại, bỏ qua."
    fi
  done
fi

# Copy scan-project.md
if [ -f "$SCAN_PROMPT" ]; then
  mkdir -p "$TARGET_REPO/.agent"
  cp "$SCAN_PROMPT" "$TARGET_REPO/.agent/scan-project.md"
  log "Copied scan-project.md → .agent/"
fi

# -----------------------------------------------------------------------------
# 7. Git hook for memory validation
# -----------------------------------------------------------------------------
HOOKS_DIR="$TARGET_REPO/.githooks"
if [ ! -f "$HOOKS_DIR/pre-commit" ]; then
  info "Setting up git hook for memory validation..."
  mkdir -p "$HOOKS_DIR"
  cat > "$HOOKS_DIR/pre-commit" << 'HOOK'
#!/bin/bash
MEMORY_STAGED=$(git diff --cached --name-only -- 'memory/*.md' 2>/dev/null)
if [ -z "$MEMORY_STAGED" ]; then exit 0; fi
echo "🔍 Validating memory files..."
if [ -f "memory/validate.sh" ]; then
  bash memory/validate.sh
  if [ $? -ne 0 ]; then
    echo "❌ Memory validation failed. Fix errors before committing."
    exit 1
  fi
fi
exit 0
HOOK
  chmod +x "$HOOKS_DIR/pre-commit"
  cd "$TARGET_REPO" && git config core.hooksPath .githooks 2>/dev/null || true
  log "Git hook installed (.githooks/pre-commit)"
else
  warn "Git hook already exists, skipping."
fi

# -----------------------------------------------------------------------------
# 8. AgentMemory (optional — if installed)
# -----------------------------------------------------------------------------
if command -v agentmemory &>/dev/null; then
  info "AgentMemory detected — connecting to agents..."
  agentmemory connect --all 2>/dev/null && log "AgentMemory connected to all agents" || warn "AgentMemory connect failed (non-critical)"
else
  info "AgentMemory not installed (optional). Install: npm install -g @agentmemory/agentmemory"
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo "════════════════════════════════════════"
echo -e "${GREEN}  Setup hoàn tất!${NC}"
echo "════════════════════════════════════════"
echo ""
echo "Đã tạo:"
echo "  ✓ ~/.agents/skills/              (global skills)"
echo "  ✓ ~/.gemini/antigravity/skills/  (Antigravity skills)"
echo "  ✓ ~/.agents/memory/             (global cross-project memory)"
echo "  ✓ $TARGET_REPO/memory/          (project memory — 8 files)"
echo "  ✓ $TARGET_REPO/.agent/scan-project.md  (scan prompt)"
echo "  ✓ $TARGET_REPO/.githooks/pre-commit    (memory validation)"
echo ""
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  BƯỚC TIẾP THEO (BẮT BUỘC):           ║${NC}"
echo -e "${CYAN}║                                        ║${NC}"
echo -e "${CYAN}║  Mở AI agent và paste prompt từ:       ║${NC}"
echo -e "${CYAN}║  .agent/scan-project.md                ║${NC}"
echo -e "${CYAN}║                                        ║${NC}"
echo -e "${CYAN}║  Agent sẽ tự động:                     ║${NC}"
echo -e "${CYAN}║  1. Scan codebase                      ║${NC}"
echo -e "${CYAN}║  2. Populate COMPACT.md, context.md    ║${NC}"
echo -e "${CYAN}║  3. Generate CLAUDE.md, GEMINI.md      ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Scripts có sẵn:"
echo "  bash memory/validate.sh         # Kiểm tra memory files"
echo "  bash memory/consolidate.sh      # Archive lessons cũ"
echo "  bash memory/capture.sh ...      # Ghi session log"
echo ""

