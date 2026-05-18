# agent-skills

Bộ skill, memory system, và templates cho các AI agents: **Claude · Gemini (Antigravity) · Codex**.

## Quick Start (2 bước)

### Bước 1: Chạy setup (tạo skeleton)

```bash
git clone https://github.com/<your-username>/agent-skills.git
cd /path/to/your-project
bash /path/to/agent-skills/setup.sh
```

Setup tự động tạo:
- `~/.agents/skills/` — global skills (RN best practices, GitNexus)
- `~/.gemini/antigravity/skills/` — Antigravity skills (14 skills)
- `~/.agents/memory/` — global cross-project memory
- `memory/` — project memory (8 files: COMPACT, INDEX, capture.sh, ...)
- `CLAUDE.md`, `GEMINI.md` — instruction file templates
- `.agent/scan-project.md` — scan prompt

### Bước 2: Chạy scan (AI auto-fill)

Mở bất kỳ AI agent nào (Claude, Gemini, Codex), paste prompt từ:

```
.agent/scan-project.md
```

Agent sẽ tự động:
1. **Deep scan** codebase (package.json, structure, patterns, conventions)
2. **Populate** `COMPACT.md`, `context.md` với tech stack thật
3. **Generate** `CLAUDE.md`, `GEMINI.md` với rules project-specific

**Xong.** Agent đã sẵn sàng làm việc với full context.

## Cấu trúc

```
agent-skills/
├── agents-skills/              # → ~/.agents/skills/
│   ├── react-native-best-practices/
│   └── gitnexus-*/
├── antigravity-skills/         # → ~/.gemini/antigravity/skills/
│   ├── brainstorming/
│   ├── executing-plans/
│   └── ...  (14 skills)
├── templates/                  # Instruction file templates
│   ├── CLAUDE.md.template
│   └── GEMINI.md.template
├── scan-project.md             # Deep scan prompt
├── setup.sh                    # Bootstrap script
└── README.md
```

## Cập nhật skills

```bash
# Pull từ máy
rsync -av --exclude='.DS_Store' ~/.agents/skills/ agents-skills/
rsync -av --exclude='.DS_Store' --exclude='react-native-best-practices' \
  ~/.gemini/antigravity/skills/ antigravity-skills/

git add -A && git commit -m "chore: update skills" && git push
```

## Memory System

Mỗi project có `memory/` folder:

| File | Mục đích | Agent đọc? |
|------|---------|:----------:|
| `COMPACT.md` | Quick context (~30 dòng) | ⚡ ĐỌC TRƯỚC |
| `INDEX.md` | Keyword → lesson mapping | 🔍 Khi cần search |
| `context.md` | Project state chi tiết | Khi COMPACT chưa đủ |
| `lessons-learned.md` | Lỗi → quy tắc | Smart-scan by tags |
| `decisions.md` | Quyết định kiến trúc | Titles first |
| `handoff.md` | Chuyển giao agent→agent | Luôn đọc |
| `capture.sh` | Helper ghi session log | Agent gọi khi cần |

Global memory: `~/.agents/memory/` (lessons áp dụng mọi project)

## Tùy chọn

```bash
# Superpowers plugin (1 lần per máy)
/plugin install superpowers@claude-plugins-official

# AgentMemory server (persistent memory nâng cao)
npm install -g @agentmemory/agentmemory

# GitNexus (code intelligence)
npx gitnexus@latest analyze
```
