# Changelog

## 1.0.0 — 2026-09-24

- 首次以 Claude Code plugin 形式發佈(含 marketplace.json,可直接 `/plugin install`)
- 新增 `SessionStart` hook:自動注入 `.claude/learnings/INDEX.md`(Workflow C 不再依賴 CLAUDE.md 指示)
- SKILL.md 去除原作者專案專屬內容(規則檔清單、benchmark workflow),改為通用寫法
- 修正 `scan-stars.sh`:無 ⭐ 時計數印兩次;topic 解析找不到檔案;移除 macOS 不支援的 `grep -P`
