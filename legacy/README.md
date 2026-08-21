# Legacy (v1 layout) — không dùng nữa

Hai file trong thư mục này thuộc thế hệ v1 của repo và **không còn chạy được**.

| File | Vì sao không dùng |
|------|-------------------|
| `setup-v1.sh` | `rsync` từ `agents-skills/`, `antigravity-skills/`, `templates/` — cả ba đã bị xoá khi chuyển sang layout v2. Chạy script này ra skeleton rỗng. |
| `scan-project-v1.md` | Populate `memory/COMPACT.md`, `memory/context.md`, `GEMINI.md` — schema memory v1, không còn tồn tại. |

Giữ lại chỉ để tra cứu lịch sử. Đường bootstrap hiện tại là `setup.sh` ở root, xem `README.md`.

## Bản đồ v1 → v2

| v1 | v2 |
|----|-----|
| `agents-skills/`, `antigravity-skills/` | `.agents/skills/` |
| `templates/CLAUDE.md.template`, `GEMINI.md.template` | `CLAUDE.md`, `.agents/AGENTS.md` (adapter mỏng trỏ về `AGENTS.md`) |
| `memory/COMPACT.md` | `.ai/memory/COMPACT.md` |
| `memory/context.md` | `.ai/memory/STATE.md` |
| `memory/lessons-learned.md` | `.ai/memory/LESSONS.md` |
| `memory/handoff.md` | `.ai/memory/HANDOFF.md` |
| `memory/decisions.md` | `.ai/plans/` + ADR trong project |
| `memory/INDEX.md`, `capture.sh`, `validate.sh`, `consolidate.sh` | bỏ — không thay thế |
| `~/.agents/skills/`, `~/.gemini/antigravity/skills/` | skill nằm trong repo tại `.agents/skills/` |
| `.agent/scan-project.md` | bỏ — populate thủ công `AGENTS.md` |
