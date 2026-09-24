# session-learnings — Claude Code plugin

讓 Claude Code 在每次任務結束時記錄經驗、下次開工時自動召回,並把反覆出現的經驗升級成專案規則。
以「混合索引」管理:只有一份短索引常駐 context,細節按需載入,不浪費 token。

*English summary: a Claude Code plugin that records lessons learned at the end of each task into
`.claude/learnings/` (a one-line-per-entry index + topic files), injects the index at session start,
and suggests promoting high-value entries into `.claude/rules/` or `CLAUDE.md` after your confirmation.
Skill prompts are written in Traditional Chinese; learnings are recorded in the language you use with Claude.*

## 安裝

在 Claude Code 裡:

```
/plugin marketplace add FSTuba/claude-session-learnings
/plugin install session-learnings@fstuba-plugins
```

重啟 session 後,`/skills` 應看得到 `session-learnings`。

## 它會做什麼

| Workflow | 觸發 | 功能 |
|---|---|---|
| **A 記錄經驗** | 任務結束時自動 / 說「記錄經驗」「save learnings」 | 摘要 ✅成功 ❌失敗 🔧優化 💡知識 → 你確認後寫入 `topics/*.md` + `INDEX.md` |
| **B 總結經驗** | 說「總結經驗」「consolidate learnings」;⭐ 累積 ≥5 條時提醒 | 把 ⭐ 高通用性經驗合併成規則建議,**你選了才寫入** `.claude/rules/` 或 `CLAUDE.md` |
| **C 經驗檢索** | 每個 session 開始(`SessionStart` hook) | 把 `INDEX.md` 注入 context,Claude 依任務關鍵字只載入相關 topics |

沒有 `.claude/learnings/` 的專案,hook 什麼都不輸出;第一次記錄經驗時 skill 會自動建立目錄。

## 儲存結構(在你的專案內)

```
.claude/learnings/
├── INDEX.md        ← 常駐 context(< 80 行,每條一行:日期 | 摘要 | 分類 | 標籤)
├── topics/         ← 按需載入:tool-xxx.md、lang-xxx.md、debug.md、workflow.md…
└── archive/        ← INDEX 超過上限時歸檔舊條目
```

要不要把 learnings 進版控由你決定:`init.sh` 會放一個預設不排除任何檔案的 `.gitignore`,
取消註解即可排除。**skill 被要求絕不記錄密碼、API key 等實際值**,但進版控前仍建議自己看一眼。

## Context 開銷

- 常駐:skill description(約 50 tokens)+ INDEX.md(約 500 tokens)
- 按需:相關的 topics 檔
- 從不載入:archive/、不相關的 topics

## 需求

- Claude Code(支援 plugin 的版本)
- `bash`(macOS / Linux 內建;Windows 版 Claude Code 使用 Git Bash)

## 不裝 plugin、只要 skill

把 `skills/session-learnings/` 複製到 `~/.claude/skills/` 或專案的 `.claude/skills/`。
這樣沒有 SessionStart hook,請在 `CLAUDE.md` 加一行:

```markdown
- 開始任務前先讀 .claude/learnings/INDEX.md,依關鍵字載入相關 topics;任務結束時用 session-learnings skill 記錄經驗
```

## License

MIT
