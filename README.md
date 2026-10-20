# Claude Starter Kit

Bộ cấu hình Claude Code dùng chung cho mọi dự án: sub agent, skill (lệnh `/...`), hook an toàn và mẫu `CLAUDE.md`.
Clone repo này một lần, rồi chạy script cài vào từng dự án.

## Cách bộ kit chia việc

Phiên Claude chính đóng vai **dev chính**: hỏi yêu cầu, lập kế hoạch, viết code. Mấy việc này dùng chung nhiều context, nên tách ra agent khác thì sẽ mất thông tin.
Sub agent chỉ làm những việc **được lợi khi chạy trong context riêng**: những việc sinh ra nhiều output (log test, tài liệu bên ngoài), hoặc cần góc nhìn độc lập (review).

| "Vai" trong team | Nằm ở đâu | Model |
|---|---|---|
| Tech lead / BA | Phiên chính + `/spec` | model của phiên |
| Tìm hiểu code | Agent **Explore** có sẵn của Claude Code | — |
| Dev | Phiên chính + `/feature`, `/fix` | model của phiên (nên dùng Sonnet) |
| Tester | Agent `test-runner`: chạy test, chỉ báo phần lỗi | Haiku |
| Code reviewer | Agent `reviewer`: chỉ đọc, review diff so với spec | Opus |
| Security | Agent `security-reviewer`: chỉ đọc | Opus |
| Tra cứu tài liệu | Agent `docs-researcher`: tra docs đúng version thư viện dự án đang dùng | Sonnet |
| Release | `/ship`: kiểm tra, commit, PR | model của phiên |
| Bảo vệ | Hook `guard-commands` + quyền `deny`/`ask` trong settings | — |

## Có gì bên trong

```
template/                        ← được copy vào dự án
├── CLAUDE.md                    ← mẫu, điền bằng /kit-setup
└── .claude/
    ├── settings.json            ← chặn đọc/sửa file bí mật, hỏi trước khi push, gắn hook
    ├── hooks/guard-commands.mjs ← chặn hoặc hỏi trước lệnh nguy hiểm (Bash và PowerShell)
    ├── agents/
    │   ├── test-runner.md
    │   ├── reviewer.md
    │   ├── security-reviewer.md
    │   └── docs-researcher.md
    └── skills/
        ├── kit-setup/   /kit-setup  ← chạy 1 lần sau khi cài
        ├── spec/        /spec       ← phỏng vấn rồi viết docs/specs/<ngày>-<tên>.md
        ├── feature/     /feature    ← plan → code → test → review → tóm tắt
        ├── fix/         /fix        ← tái hiện bằng test fail → sửa gốc → chứng minh
        └── ship/        /ship       ← kiểm tra → quét diff → commit (→ PR)
install.ps1 / install.sh         ← script cài
tests/guard-commands.test.mjs    ← test cho hook
```

Hook `guard-commands` làm hai việc:
- **Chặn hẳn** các lệnh: `rm -rf` nhắm vào `/`, `~`, `.`, `*`; `Remove-Item -Recurse C:\`; `curl ... | bash`; format ổ đĩa; đọc `.env` hoặc private key qua shell.
- **Hỏi bạn trước** các lệnh: `git push --force`, `git reset --hard`, `git clean -f`, `git branch -D`; SQL `DROP`, `TRUNCATE`, `DELETE` không có `WHERE`; `npm publish`; `terraform destroy`; `kubectl delete`.

## Yêu cầu

- Claude Code
- Git
- **Node.js 18+** có trong PATH, vì hook chạy bằng Node. Nếu thiếu Node, hook sẽ báo lỗi và bị bỏ qua, tức là không chặn được lệnh nào.
- Không bắt buộc: `gh` (GitHub CLI), dùng cho `/fix #issue` và `/ship pr`

## Cài vào một dự án

Clone kit một lần:

```powershell
git clone https://github.com/<you>/claude-starter-kit.git C:\tools\claude-starter-kit
```

Cài vào dự án, dùng được cho cả dự án mới lẫn dự án đang làm:

```powershell
# Windows
C:\tools\claude-starter-kit\install.ps1 -Target C:\code\my-app
```

```bash
# macOS / Linux / Git Bash
~/tools/claude-starter-kit/install.sh ~/code/my-app
```

Script **không bao giờ ghi đè** file đã có:
- Nếu dự án đã có `CLAUDE.md` hoặc `.claude/settings.json`, bản của kit được lưu riêng thành `.claude/CLAUDE.kit-template.md` và `.claude/settings.kit.json`. `/kit-setup` sẽ gộp chúng vào file của bạn.
- Script thêm `CLAUDE.local.md` và `.claude/settings.local.json` vào `.gitignore`.

Sau đó mở Claude Code trong thư mục dự án và chạy:

```
/kit-setup
```

Claude sẽ đọc dự án, tìm và **chạy thử** các lệnh build, test, lint, rồi điền `CLAUDE.md`, thêm quyền chạy các lệnh đó không cần hỏi, và hỏi bạn có muốn tự format file sau mỗi lần sửa không.
Với repo trống, Claude sẽ hỏi bạn về stack. Có thể mô tả luôn trong lệnh, ví dụ `/kit-setup Java 21 TCP server + Next.js 15 + PostgreSQL 16`.

Cuối cùng, commit `CLAUDE.md` và `.claude/` vào repo của dự án.

## Dùng hằng ngày

| Việc | Gõ |
|---|---|
| Tính năng lớn hoặc chưa rõ | `/spec thêm đăng nhập Google` → đọc lại spec → `/clear` → `/feature docs/specs/2026-10-21-google-login.md` |
| Việc nhỏ, rõ ràng | Nói thẳng với Claude, hoặc `/feature đổi timeout socket thành 30s` |
| Sửa bug | `/fix lỗi NullPointer khi client ngắt kết nối` hoặc `/fix #42` |
| Commit | `/ship` (thêm `pr` để push và mở pull request: `/ship pr`) |
| Hỏi về thư viện | "dùng docs-researcher xem Next.js 15 cache fetch thế nào" |
| Audit bảo mật | "dùng security-reviewer audit thư mục src/auth" |

Thói quen nên có (theo [best practices chính thức](https://code.claude.com/docs/en/best-practices)):
- `/clear` khi chuyển sang việc không liên quan. Nếu đã sửa Claude hai lần mà vẫn sai, `/clear` rồi viết lại prompt rõ hơn.
- Luôn để Claude có cách tự kiểm tra (test, build). Yêu cầu Claude đưa ra bằng chứng, không chấp nhận câu "chắc là chạy".
- Thỉnh thoảng xem `/usage`. Mục Attribution cho biết sub agent chiếm bao nhiêu phần trăm hạn mức.

## Cập nhật kit

Khi bạn sửa kit (thêm rule, chỉnh agent), push lên GitHub, rồi ở mỗi dự án chạy:

```powershell
git -C C:\tools\claude-starter-kit pull
C:\tools\claude-starter-kit\install.ps1 -Target C:\code\my-app -Update
```

`-Update` (hoặc `--update`) ghi đè các file do kit quản lý: agents, skills, hooks.
`CLAUDE.md` và `.claude/settings.json` thì **không bao giờ** bị ghi đè, vì chúng đã được chỉnh riêng cho từng dự án. Nếu kit thay đổi hai file này, bạn tự so sánh với `template/` rồi chép phần cần thiết.
Phiên bản kit đang cài được ghi trong `.claude/kit-version`. Tăng số trong file `VERSION` mỗi lần đổi kit.

## Tuỳ chỉnh

- **Đổi model cho agent:** sửa dòng `model:` trong `template/.claude/agents/*.md`. Các giá trị: `haiku`, `sonnet`, `opus`, `inherit` (dùng model của phiên chính).
- **Thêm agent:** chỉ thêm khi có một việc **lặp lại**, **tự chứa**, và **sinh nhiều output** hoặc cần **giới hạn quyền**. Mô tả trong `description` phải nói rõ *khi nào* thì dùng agent đó. Không nên tạo agent theo vai kiểu "frontend dev" hay "backend dev", vì tách như vậy là mất context.
- **Thêm rule cho hook:** sửa mảng `RULES` trong `template/.claude/hooks/guard-commands.mjs`, thêm ca kiểm tra vào `tests/guard-commands.test.mjs`, rồi chạy:
  ```
  node --test tests/guard-commands.test.mjs
  ```
- **Quy ước cho một phần dự án** (ví dụ chỉ áp dụng cho `frontend/`): tạo `.claude/rules/frontend.md` có frontmatter `paths:` trong dự án đó. Quy ước này không thuộc kit.
- **Sở thích cá nhân cho mọi dự án** (ngôn ngữ trả lời, phong cách): ghi vào `~/.claude/CLAUDE.md` trên máy bạn. Kit không chứa phần này.

## Giới hạn cần biết

- Hook và quyền `deny` là **lưới an toàn, không phải ranh giới bảo mật**. Lệnh viết kiểu khác (ví dụ `bash -c '...'`, đường dẫn tuyệt đối tới `rm`) có thể lọt qua. Đừng để bí mật thật trong thư mục dự án nếu không cần.
- Mỗi sub agent đều tiêu tốn hạn mức gói của bạn. `/feature` gọi `test-runner` và `reviewer` mỗi lần chạy. Với việc nhỏ, cứ nói thẳng với Claude cho rẻ.
- `/kit-setup` chỉ chạy những lệnh nhanh và an toàn. Nó không khởi động dev server và không chạy lệnh cần service ngoài nếu bạn chưa đồng ý.

## Nguồn

- Subagents: https://code.claude.com/docs/en/sub-agents
- Skills: https://code.claude.com/docs/en/skills
- Hooks: https://code.claude.com/docs/en/hooks
- Permissions: https://code.claude.com/docs/en/permissions
- Best practices: https://code.claude.com/docs/en/best-practices
- Chọn giữa CLAUDE.md, skill, subagent, hook: https://code.claude.com/docs/en/features-overview
- Chi phí và hạn mức: https://code.claude.com/docs/en/costs
