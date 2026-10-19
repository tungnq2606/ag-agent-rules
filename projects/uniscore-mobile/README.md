# uniscore-mobile — lớp agent cá nhân

Repo team của `uniscore-mobile` gitignore hoặc không chứa một số file agent. Thư mục này giữ bản sao của chúng
để dựng lại trên máy khác và để không mất khi hỏng máy.

Hướng dẫn này gồm: [Có gì trong đây](#có-gì-trong-đây) · [Dùng hằng ngày](#dùng-hằng-ngày) ·
[Cập nhật backup](#cập-nhật-backup) · [Sang máy mới](#sang-máy-mới) · [Kiểm tra](#kiểm-tra) ·
[Sự cố thường gặp](#sự-cố-thường-gặp) · [Giới hạn](#giới-hạn).

## Có gì trong đây

| Đường dẫn | Chép về project thành | Vai trò |
|---|---|---|
| `ai/AGENTS.mine.md` | `.ai/AGENTS.mine.md`, rồi `AGENTS.md` | `AGENTS.md` của tôi, dùng thay bản team |
| `ai/scripts/keep-mine.sh` | `.ai/scripts/keep-mine.sh` | giữ `AGENTS.md` của tôi khi pull |
| `ai/rules/` | `.ai/rules/` | rule on-demand (`code-style`, `verification`, `jira-subtasks`...) |
| `agents/hooks/` | `.agents/hooks/` | `rule-compliance.sh`, `ag-session-start.sh`, `ag-stop.sh` |
| `agents/hooks.json` | `.agents/hooks.json` | đăng ký hook cho Antigravity (đường dẫn là `__PROJECT__`) |
| `claude/settings.local.json` | `.claude/settings.local.json` | hook SessionStart cho Claude Code |
| `agents/skills/` | `.agents/skills/` | skill chỉ có ở project, và danh sách 9 symlink |
| `restore.sh`, `sync-backup.sh` | — | khôi phục và đồng bộ backup |

`ai/plans/` và `ai/memory/` được gitignore. Chúng nằm trên đĩa của máy này nhưng không vào git, vì chứa chi tiết công việc nội bộ.

Skill dùng chung không chép lại ở đây. `restore.sh` lấy chúng từ template ở root repo (`../../.agents/skills`).

## Cách hoạt động

**Một nguồn instruction.** `AGENTS.md` là canonical. Claude Code đọc nó qua `CLAUDE.md` (`@AGENTS.md`), Antigravity đọc trực tiếp và đọc thêm `GEMINI.md`.

**Giữ `AGENTS.md` của tôi thay bản team.** File này được git theo dõi, nên pull có thể ghi đè nó. Cách xử lý:
- `git update-index --skip-worktree AGENTS.md`: git coi file như không đổi, `git status` sạch, `git stash` không bắt nó.
- Nguồn thật là `.ai/AGENTS.mine.md`. `keep-mine.sh` chép nó về `AGENTS.md`.
- Các hook git `post-merge`, `post-checkout`, `post-rewrite` gọi `keep-mine.sh restore` để tự khôi phục nếu cờ bị gỡ.

**Hook ép buộc** (instruction là văn bản, hook mới là cơ chế):
- `rule-compliance.sh` đưa §Rule Compliance vào context mỗi session. Claude Code gọi nó qua `settings.local.json` (SessionStart).
- Antigravity gọi `ag-session-start.sh` ở `SessionStart` và `PreInvocation`. Script chuyển đầu ra sang `injectSteps` và chỉ inject một lần mỗi conversation (marker `/tmp/uniscore-rc-<conversationId>`). CLI 1.4.0 không liệt kê SessionStart trong `/hooks` nhưng vẫn gọi nó.
- `ag-stop.sh` (Stop): giữ agent lại **một lần** nếu conversation này đã ghi file trong `src/` hoặc `lib/`, cây git còn thay đổi ở đó, và chưa có `run_command` nào chứa `yarn verify`. Marker: `/tmp/uniscore-stop-<conversationId>`.

## Dùng hằng ngày

- **Pull bằng `git up`**, không dùng `git pull`. Nó gỡ khóa, trả `AGENTS.md` về bản team, pull, rồi đặt lại bản của tôi. Nhận mọi tham số của `git pull`.
  Nếu lỡ chạy `git pull` khi team vừa sửa `AGENTS.md`, git báo "local changes would be overwritten". Chạy `git up`.
- **Khi team sửa `AGENTS.md`**, `keep-mine.sh` in cảnh báo. Xem họ đổi gì rồi gộp phần cần vào `.ai/AGENTS.mine.md`:
  ```bash
  git diff --no-index .ai/AGENTS.mine.md <(git show HEAD:AGENTS.md)
  # sửa .ai/AGENTS.mine.md, rồi:
  cp .ai/AGENTS.mine.md AGENTS.md
  git show HEAD:AGENTS.md | shasum | cut -d' ' -f1 > .ai/AGENTS.team.sha
  ```
- **Sửa `AGENTS.md` của tôi:** sửa `.ai/AGENTS.mine.md` rồi `cp` về `AGENTS.md`. Đừng sửa trực tiếp `AGENTS.md`, lần sau `keep-mine.sh` sẽ ghi đè.
- **Giữ `AGENTS.md` dưới 24,000 byte.** Antigravity cắt phần đuôi file rule dài hơn và ghi `truncated by N bytes` trong log. Kiểm tra: `wc -c AGENTS.md`.
  `npx gitnexus analyze` sinh lại khối GitNexus đầy đủ (~4KB) và có thể làm file vượt giới hạn. Chạy lại `wc -c` sau mỗi lần analyze.

## Cập nhật backup

Mỗi khi sửa hook, `AGENTS.mine.md`, rule trong `.ai/rules/` hay `settings.local.json`:

```bash
cd ~/dev/ag-agent-rules            # hoặc nơi bạn clone
DRY_RUN=1 bash projects/uniscore-mobile/sync-backup.sh   # xem trước
bash projects/uniscore-mobile/sync-backup.sh             # ghi vào backup
git status --short projects/uniscore-mobile
git add projects/uniscore-mobile && git commit -m "chore: sync uniscore-mobile agent layer"
git push
```

- Tham số tùy chọn: đường dẫn tới project (mặc định `~/Documents/works/uniscore-mobile`).
- `DELETE=1` xóa luôn file trong backup mà project không còn. Mặc định không xóa gì.
- Script không bao giờ commit. Nó cảnh báo nếu `AGENTS.mine.md` từ 24,000 byte trở lên.
- Đường dẫn trong `hooks.json` được lưu dạng `__PROJECT__`, nên diff không bị nhiễu giữa các máy.

## Sang máy mới

1. **Tầng máy** (rule và skill global, settings, MCP):
   ```bash
   git clone git@github.com:tungnq2606/ag-agent-rules.git ~/dev/ag-agent-rules
   cd ~/dev/ag-agent-rules && git checkout <nhánh có projects/uniscore-mobile>
   DRY_RUN=1 bash scripts/bootstrap-machine.sh
   bash scripts/bootstrap-machine.sh
   ```
2. **Clone project** `uniscore-mobile` từ GitLab của team.
3. **Tầng project cá nhân:**
   ```bash
   bash ~/dev/ag-agent-rules/projects/uniscore-mobile/restore.sh /đường/dẫn/uniscore-mobile
   ```
   Không ghi đè file đang có; `FORCE=1` để ghi đè. Script tạo `.ai/`, `.agents/hooks*`, `.agents/skills/` (skill chung + project-only + 9 symlink),
   `settings.local.json`, hook git, alias `git up`, dòng `.git/info/exclude`, và đưa `AGENTS.md` về bản của tôi. Đường dẫn trong `hooks.json` tự đổi sang clone mới.
4. **Làm tay** (xem `global/MACHINE-SETUP.md`): cài lại công cụ ghi hook riêng (`npm i -g @caveman-ai/cli`, `npx gitnexus@latest analyze`),
   đăng nhập MCP bằng `/mcp`, để `permissions.allow` tự xây lại.
5. Mở session mới và [kiểm tra](#kiểm-tra).

Muốn mang theo `plans/` và `memory/`: copy tay `.ai/plans` và `.ai/memory` sang máy mới (`rsync` hoặc `scp`).

## Kiểm tra

Chạy trong project, mọi dòng phải đạt:

```bash
wc -c AGENTS.md                              # dưới 24000
git ls-files -v AGENTS.md                    # "S AGENTS.md"
cmp AGENTS.md .ai/AGENTS.mine.md && echo ok
git config alias.up                          # có giá trị
ls -la .agents/skills | grep -c -- '-> ../../.claude'   # 9
```

**Claude Code:** mở session mới. `/hooks` phải có hai hook SessionStart (nhãn `Project` và `Local`).
Bằng chứng chắc nhất là transcript trong `~/.claude/projects/<project>/*.jsonl` có entry `hook_additional_context` chứa "is in force for this session".

**Antigravity:** khởi động lại `agy`, gõ `/hooks`: `PreInvocation` và `Stop` mỗi loại "1 hook". Gửi một tin bất kỳ, rồi:
```bash
ls /tmp/uniscore-rc-*                                     # có marker
grep -i "hook\|truncated" ~/.gemini/antigravity-cli/log/cli-*.log | tail
```
Không được có dòng `Failed to parse hooks file` hay `truncated by`.
Chạy không tương tác: `agy -p "chào"`.

## Sự cố thường gặp

| Triệu chứng | Nguyên nhân | Cách xử lý |
|---|---|---|
| `AGENTS.md` mất §Rule Compliance / Task Routing | bản team ghi đè (pull, checkout, stash) | `cp .ai/AGENTS.mine.md AGENTS.md`; lần sau dùng `git up` |
| Log CLI: `truncated by N bytes ... limit 24000` | `AGENTS.md` quá dài | rút gọn, chuyển phần dài sang `.ai/rules/` |
| Log CLI: `command hook must specify 'command'` | `hooks.json` lồng sai | event không có matcher dùng danh sách handler phẳng `[{"type":"command","command":"..."}]`, không có mảng `hooks` bên trong |
| `/hooks` của Antigravity không có hook | CLI chưa nạp | thoát `agy`, mở lại; đây là bước bắt buộc sau khi sửa `hooks.json` |
| Hook Antigravity "nạp rồi mà không chạy" | đường dẫn trong `hooks.json` sai máy | chạy lại `restore.sh` (sẽ đổi đường dẫn), hoặc sửa tay |
| `git pull` báo "would be overwritten" ở `AGENTS.md` | team sửa file đang bị skip-worktree | `git up` |
| Agent bị giữ lại ở Stop dù không đụng code | cây git có thay đổi ở `src/` *và* conversation có ghi file `src/` | hành vi đúng: chạy `yarn verify` rồi kết thúc bằng dòng `Test:` |
| Hook Claude Code không có hiệu lực | thêm `settings.local.json` giữa session | mở `/hooks` một lần hoặc khởi động lại |
| Cần xem hook nhận gì | — | thêm tạm `printf '%s\n' "$in" >> /tmp/uniscore-ag-hook.log` sau dòng `in=$(cat)`; xóa khi xong |

## Giới hạn

- Hook `Stop` chỉ nhận biết ghi file qua tool có tên chứa `replace`, `write` hoặc `edit`. Tool ghi file mang tên khác sẽ bị bỏ sót.
- Hook `Stop` mới được thử bằng chạy thật ở nhánh "chưa ghi file thì cho qua"; nhánh "đã ghi `src/` mà chưa verify" chỉ được thử bằng transcript giả.
- `.git/hooks/*` và alias `git up` nằm trong `.git/` nên không được git theo dõi; `restore.sh` dựng lại chúng.
- Backup này là ảnh chụp tại thời điểm chạy `sync-backup.sh`. Quên đồng bộ thì máy mới nhận bản cũ.
