# ag-agent-rules

Instruction, rule, và skill dùng chung cho ba coding agent — **Claude Code · Codex · Antigravity** — trên dự án React Native `uniscore-mobile`.

Một nguồn canonical, ba adapter mỏng. Không agent nào có bộ luật riêng.

## Nguyên tắc thiết kế

1. **Một canonical.** [AGENTS.md](AGENTS.md) là nguồn duy nhất. `CLAUDE.md` và `.agents/AGENTS.md` chỉ trỏ về nó.
2. **Progressive disclosure.** Session start chỉ đọc `AGENTS.md` + `.ai/memory/COMPACT.md`. Rule và skill nạp khi routing yêu cầu, không nạp sẵn.
3. **Proportional effort.** Quy trình nặng chỉ áp cho việc có blast radius lớn. Sửa một dòng copy không cần plan, không cần approval, không chạy full test suite.
4. **Pointer phải sống.** Link chết còn tệ hơn không có link — agent với tới, không thấy gì, rồi tự bịa. Có CI check.

## Layout

```
AGENTS.md                    canonical — Codex đọc trực tiếp
CLAUDE.md                    adapter Claude Code
CONTEXT.md                   domain glossary
.agents/
  AGENTS.md                  adapter Antigravity
  skills/                    skill dùng chung, nạp theo routing
.ai/
  rules/                     rule on-demand (code style, verification, security, ...)
  memory/                    COMPACT · STATE · HANDOFF · LESSONS
  plans/                     plan được persist cho việc Large/Risky
.claude/skills/              symlink để Skill tool của Claude discover được
scripts/validate-pointers.sh CI check cho pointer chết
legacy/                      layout v1, không dùng nữa
```

## Cài vào một project

```bash
git clone git@github.com:tungnq2606/ag-agent-rules.git
cd /path/to/your-project
bash /path/to/ag-agent-rules/setup.sh

# ghi đè file đã tồn tại (bản cũ giữ thành *.bak)
FORCE=1 bash /path/to/ag-agent-rules/setup.sh
```

Script không ghi đè file có sẵn nếu không có `FORCE=1`. Sau khi chạy, phải sửa tay:

| File | Sửa gì |
|------|--------|
| [AGENTS.md](AGENTS.md) | Section `Project` + `Always-On Invariants` theo stack thật |
| [.ai/rules/code-style.md](.ai/rules/code-style.md) | Tên component thật, path alias, script |
| [.ai/rules/verification.md](.ai/rules/verification.md) | Lệnh typecheck/test/build thật |
| [.ai/rules/build-release.md](.ai/rules/build-release.md) | Environment, scheme iOS, gradle task Android |

Để `.ai/memory/*` rỗng cho tới khi có session tạo ra state thật. Memory rỗng là đúng; memory bịa là sai.

## Skill

| Skill | Khi nào |
|-------|---------|
| [plan-work](.agents/skills/plan-work/SKILL.md) | Việc Large/Risky — plan + approval gate |
| [codebase-design](.agents/skills/codebase-design/SKILL.md) | Module boundary, interface, seam |
| [diagnosing-bugs](.agents/skills/diagnosing-bugs/SKILL.md) | Bug không rõ nguyên nhân sau khi soi trúng chỗ |
| [code-review](.agents/skills/code-review/SKILL.md) | Review diff trước khi commit |
| [ship-change](.agents/skills/ship-change/SKILL.md) | Commit + PR |
| [triage-crash](.agents/skills/triage-crash/SKILL.md) | Crash Sentry |
| [tdd](.agents/skills/tdd/SKILL.md) | Chỉ khi user yêu cầu test-first |
| [handoff](.agents/skills/handoff/SKILL.md) | Chuyển việc dở sang session/agent khác |
| [document-feature](.agents/skills/document-feature/SKILL.md) | Chỉ khi user yêu cầu doc |
| [writing-for-agents](.agents/skills/writing-for-agents/SKILL.md) | Sửa chính hệ instruction/skill này |
| [react-native-best-practices](.agents/skills/react-native-best-practices/SKILL.md) | FPS, TTI, bundle, memory, native profiling |
| [react-native-project-rules](.agents/skills/react-native-project-rules/SKILL.md) | Rule RN theo convention project |

## Bảo trì

```bash
bash scripts/validate-pointers.sh    # 0 dead pointer trước khi commit
```

Trước khi sửa `AGENTS.md`, adapter, memory protocol, hay skill: đọc [writing-for-agents](.agents/skills/writing-for-agents/SKILL.md).

## Instruction priority

Khi rule đụng nhau, thứ tự ở [AGENTS.md](AGENTS.md#instruction-priority) là trọng tài. Rule global của từng agent (`~/.claude/rules/`, v.v.) đứng **dưới** project rule — chúng chỉ chứa thứ không thuộc project.
