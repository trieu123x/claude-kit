# claude-kit

Bộ cấu hình Claude Code dùng chung cho mọi dự án. Repo này **chính là thư mục `.claude`**: clone thẳng vào dự án là dùng được.

## Dùng

Mở terminal ở thư mục gốc của dự án, rồi chạy:

```bash
git clone https://github.com/trieu123x/claude-kit.git .claude
```

Sau đó mở Claude Code trong dự án và gõ `/kit-setup`. Lệnh này sẽ:
- dò stack và chạy thử các lệnh build, test, lint, rồi điền chúng vào `.claude/CLAUDE.md`
- cho phép các lệnh đó chạy mà không cần hỏi
- thêm `CLAUDE.local.md` và `.claude/settings.local.json` vào `.gitignore`
- hỏi bạn có xoá `.claude/.git` không. Phải xoá thì mới commit được `.claude` cùng dự án.

Nếu dự án **đã có** thư mục `.claude`, git sẽ không clone vào được. Khi đó clone ra một chỗ khác rồi chép các file sang.

Yêu cầu: **Node.js 18+**, vì hook chạy bằng Node. Không bắt buộc: `gh`, dùng cho `/fix #issue` và `/ship pr`.

## Bên trong

| File | Vai trò |
|---|---|
| `CLAUDE.md` | Hướng dẫn dự án. `/kit-setup` điền phần còn trống |
| `settings.json` | Chặn đọc/sửa `.env` và key; hỏi trước khi `git push`; gắn hook |
| `hooks/guard-commands.mjs` | Chặn `rm -rf ~`, `curl \| bash`. Hỏi trước force push, `reset --hard`, `DROP TABLE` |
| `agents/test-runner.md` | Chạy test và chỉ báo phần lỗi (Haiku) |
| `agents/reviewer.md` | Review diff so với spec, chỉ đọc (Opus) |
| `agents/security-reviewer.md` | Audit bảo mật, chỉ đọc (Opus) |
| `agents/docs-researcher.md` | Tra tài liệu đúng version thư viện dự án đang dùng (Sonnet) |
| `skills/` | Các lệnh `/kit-setup`, `/spec`, `/feature`, `/fix`, `/ship` |

Phiên Claude chính tự lập kế hoạch và viết code. Sub agent chỉ nhận những việc sinh nhiều output hoặc cần góc nhìn độc lập.

## Hằng ngày

| Việc | Gõ |
|---|---|
| Tính năng lớn hoặc chưa rõ | `/spec <ý tưởng>` → đọc lại spec → `/clear` → `/feature docs/specs/<file>.md` |
| Việc nhỏ | Nói thẳng với Claude, hoặc `/feature <mô tả>` |
| Sửa bug | `/fix <mô tả lỗi>` hoặc `/fix #42` |
| Commit | `/ship`, hoặc `/ship pr` để mở pull request |

Hook chỉ là lưới an toàn, không phải ranh giới bảo mật. Mỗi lần gọi sub agent đều trừ vào hạn mức gói, nên việc nhỏ thì cứ làm thẳng trong phiên chính.
