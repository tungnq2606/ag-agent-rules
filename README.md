# ag-agent-rules

Instruction, rule, và skill dùng chung cho ba coding agent — **Claude Code · Codex · Antigravity** — trên dự án React Native `uniscore-mobile`.

Một nguồn canonical, ba adapter mỏng. Không agent nào có bộ luật riêng.

## Nguyên tắc thiết kế

1. **Một canonical.** [AGENTS.md](AGENTS.md) là nguồn duy nhất. `CLAUDE.md` và `GEMINI.md` chỉ trỏ về nó.
2. **Progressive disclosure.** Session start chỉ đọc `AGENTS.md` + `.ai/memory/COMPACT.md`. Rule và skill nạp khi routing yêu cầu, không nạp sẵn.
3. **Proportional effort.** Quy trình nặng chỉ áp cho việc có blast radius lớn. Sửa một dòng copy không cần plan, không cần approval, không chạy full test suite.
4. **Pointer phải sống.** Link chết còn tệ hơn không có link — agent với tới, không thấy gì, rồi tự bịa. Có CI check.

## Layout

```
AGENTS.md                     canonical — Codex và Antigravity đọc trực tiếp
CLAUDE.md                     adapter Claude Code
GEMINI.md                     adapter Antigravity
CONTEXT.md                    domain glossary
.agents/skills/               skill dùng chung — cũng là workspace skill của Antigravity
.ai/
  rules/                      rule on-demand (code style, verification, security, ...)
  memory/                     COMPACT · STATE · HANDOFF · LESSONS
  plans/                      plan được persist cho việc Large/Risky
.claude/skills/               symlink để Skill tool của Claude discover được
global/
  rules/                      → ~/.claude/rules/ — chỉ rule tầng agent
  MACHINE-SETUP.md            phần phải làm tay khi lên máy mới
scripts/
  bootstrap-machine.sh        cài tầng máy
  validate-pointers.sh        CI check pointer chết
setup.sh                      cài tầng project vào một repo
legacy/                       layout v1, không dùng nữa
```

Hai tầng, một nguồn. Skill chỉ tồn tại một bản trong `.agents/skills/`; `.claude/skills/`, `~/.claude/skills/` và `~/.gemini/config/skills/` đều là symlink trỏ về đó. Không có bản copy nào để lệch nhau.

Mỗi agent đọc gì:

| Agent | Instruction | Skill |
|---|---|---|
| Codex | `AGENTS.md` | theo path mà `AGENTS.md` trỏ |
| Claude Code | `CLAUDE.md` → `AGENTS.md` | `.claude/skills/` (symlink) + path |
| Antigravity | `AGENTS.md` + `GEMINI.md` | workspace `.agents/skills/`, global `~/.gemini/config/skills/` |

## Máy mới

```bash
git clone git@github.com:tungnq2606/ag-agent-rules.git ~/dev/ag-agent-rules
cd ~/dev/ag-agent-rules

DRY_RUN=1 bash scripts/bootstrap-machine.sh   # xem trước
bash scripts/bootstrap-machine.sh             # tầng máy
```

Phần còn lại (settings, hook, plugin, MCP auth) ở [global/MACHINE-SETUP.md](global/MACHINE-SETUP.md).

Symlink trỏ vào đường dẫn clone. Di chuyển clone thì chạy lại script.

## Cài vào một project

```bash
cd /path/to/your-project
bash ~/dev/ag-agent-rules/setup.sh

# ghi đè file đã tồn tại (không backup — commit target repo trước khi chạy)
FORCE=1 bash ~/dev/ag-agent-rules/setup.sh
```

Script không ghi đè file có sẵn nếu không có `FORCE=1`. Sau khi chạy, phải sửa tay:

| File | Sửa gì |
|------|--------|
| [AGENTS.md](AGENTS.md) | Section `Project` + `Always-On Invariants` theo stack thật |
| [.ai/rules/code-style.md](.ai/rules/code-style.md) | Tên component thật, path alias, script |
| [.ai/rules/verification.md](.ai/rules/verification.md) | Lệnh typecheck/test/build thật |
| [.ai/rules/build-release.md](.ai/rules/build-release.md) | Environment, scheme iOS, gradle task Android |

Để `.ai/memory/*` rỗng cho tới khi có session tạo ra state thật. Memory rỗng là đúng; memory bịa là sai.

Script cài `SessionStart` hook ở `.agents/hooks/rule-compliance.sh` và nối vào `.claude/settings.json`. Mỗi session hook đẩy nghĩa vụ đọc rule vào context, và báo động khi `AGENTS.md` mất section `Rule Compliance` — dấu hiệu file bị managed block của tool khác ghi đè. Hook mới có hiệu lực sau khi mở `/hooks` một lần hoặc khởi động lại session.

`.ai/memory/*` không bị `FORCE=1` ghi đè: memory là state của project, không phải output của installer.

## Skill

| Skill | Khi nào |
|-------|---------|
| [plan-work](.agents/skills/plan-work/SKILL.md) | Việc Large/Risky — plan + approval gate |
| [codebase-design](.agents/skills/codebase-design/SKILL.md) | Module boundary, interface, seam |
| [diagnosing-bugs](.agents/skills/diagnosing-bugs/SKILL.md) | Bug không rõ nguyên nhân sau khi soi trúng chỗ |
| [triage-crash](.agents/skills/triage-crash/SKILL.md) | Crash Sentry, ANR, stack trace |
| [code-review](.agents/skills/code-review/SKILL.md) | Review diff — có reference theo path |
| [verification-before-completion](.agents/skills/verification-before-completion/SKILL.md) | Trước khi nói "xong / pass" |
| [ship-change](.agents/skills/ship-change/SKILL.md) | Commit + PR |
| [tdd](.agents/skills/tdd/SKILL.md) | Chỉ khi user yêu cầu test-first |
| [handoff](.agents/skills/handoff/SKILL.md) | Chuyển việc dở sang session/agent khác |
| [document-feature](.agents/skills/document-feature/SKILL.md) | Chỉ khi user yêu cầu doc |
| [writing-for-agents](.agents/skills/writing-for-agents/SKILL.md) | Sửa chính hệ instruction/skill này |
| [react-native-project-rules](.agents/skills/react-native-project-rules/SKILL.md) | UI, list, nav, styling theo convention project |
| [react-native-reanimated](.agents/skills/react-native-reanimated/SKILL.md) | Worklet, shared value, gesture, scroll-driven |
| [react-native-best-practices](.agents/skills/react-native-best-practices/SKILL.md) | FPS, TTI, bundle, memory, native profiling |
| `gitnexus-*` (7) | Impact analysis, explore, refactor, PR review |

Skill từ plugin và từ `~/.claude/skills/` trùng việc với các skill trên: xem mục **External Skills** trong [AGENTS.md](AGENTS.md) — nó nói rõ cái nào adopted, cái nào retired.

## Bảo trì

```bash
bash scripts/validate-pointers.sh    # 0 dead pointer trước khi commit
```

Trước khi sửa `AGENTS.md`, adapter, memory protocol, hay skill: đọc [writing-for-agents](.agents/skills/writing-for-agents/SKILL.md).

## Instruction priority

Khi rule đụng nhau, thứ tự ở [AGENTS.md](AGENTS.md#instruction-priority) là trọng tài. Rule global của từng agent (`~/.claude/rules/`, v.v.) đứng **dưới** project rule — chúng chỉ chứa thứ không thuộc project.
