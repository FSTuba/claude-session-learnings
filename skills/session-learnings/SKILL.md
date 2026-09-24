---
name: session-learnings
description: |
  Capture and persist lessons learned during coding sessions. Use at the END of every task, debugging session, or implementation cycle. Also activate when user says "記錄經驗", "save learnings", "retrospective", "回顧", or when a task completes (successfully or with failures). Proactively invoke this skill whenever a meaningful task concludes, even if the user doesn't explicitly ask.
---

# Session Learnings — 任務經驗自動記錄與累積

## 儲存架構：混合索引（Hybrid Index）

所有 learnings 存放於 `{project_root}/.claude/learnings/`，結構如下：

```
.claude/learnings/
├── INDEX.md              ← 永遠載入，每條 learning 僅一行摘要+標籤（控制 < 80 行）
├── topics/               ← 按需載入的分類子檔案
│   ├── tool-redmine.md
│   ├── tool-gas.md
│   ├── lang-javascript.md
│   ├── debug.md
│   ├── workflow.md
│   ├── api.md
│   └── ...
└── archive/              ← 過期 entries 歸檔
    └── INDEX-archive-2026.md
```

### 為什麼這樣設計

- **INDEX.md** 很短（每條一行），可安全載入 context 而不浪費 token
- **topics/** 子檔案只在任務相關時才讀取，例如做 Redmine 相關任務時才載入 `tool-redmine.md`
- Claude Code 開始任務時，讀 INDEX.md 掃描有哪些相關經驗 → 再決定是否載入對應子檔案

---

## Workflow A：記錄經驗（任務結束時觸發）

### 觸發時機

- 任務完成（成功或失敗）
- Debug session 結束
- 使用者說「記錄經驗」「save learnings」「/session-learnings」

### Step 1：回顧本次任務，提煉 learnings

**完成標準**：四個維度都檢視過，並篩掉不值得記錄的項目。

依以下四個維度整理：

| 維度 | 要記什麼 | 不要記什麼 |
|------|---------|-----------|
| ✅ 成功 | 哪個方法有效、為什麼比其他方案好 | 顯而易見的常識 |
| ❌ 失敗 | 錯誤訊息 + 根因 + 解法 + 曾嘗試但無效的方案 | 純粹的手誤 |
| 🔧 優化 | 更快的替代方案、可自動化的步驟、瓶頸 | 模糊的「應該更好」 |
| 💡 知識 | API 參數、版本相容性、工具 workaround、專案慣例 | 密碼/API key 等敏感值 |

### Step 2：向使用者報告摘要

**完成標準**：以下格式輸出摘要，並取得使用者同意（或未反對）。

<output_format>
```
📋 本次任務經驗摘要：
- ✅ [成功經驗，1-2 句]
- ❌ [失敗教訓，1-2 句]
- 🔧 [可優化，1-2 句]
- 💡 [可複用知識]
是否要記錄這些經驗？（Y/n）
```
</output_format>

如果使用者同意（或未反對），進入 Step 3。

### Step 3：寫入 topics 子檔案

**完成標準**：每條 learning 已寫入正確的 topic 檔案，且無重複 entry。

根據本次 learning 的內容，決定寫入哪個 topic 檔案。

**分類規則：**
- 涉及特定工具 → `topics/tool-{工具名}.md`（如 `tool-redmine.md`）
- 涉及特定語言 → `topics/lang-{語言}.md`（如 `lang-javascript.md`）
- Debug 相關 → `topics/debug.md`
- 流程/自動化相關 → `topics/workflow.md`
- API/設定相關 → `topics/api.md`
- 不確定 → `topics/general.md`
- 一條 learning 可以同時寫入多個 topic 檔案（交叉引用）

**子檔案中的 entry 格式：**

<output_format>
```markdown
### [YYYY-MM-DD] 簡述標題

**結果**: ✅ / ❌ / ⚠️

- 具體內容（1-5 行，重點是「下次遇到同樣問題時能直接套用」）
- 如果是失敗教訓，包含：錯誤訊息片段 → 根因 → 解法
- 如果有已排除的方案，標記「❌ 已排除：XXX，原因：YYY」

`#tag1` `#tag2`
```
</output_format>

**失敗教訓優先用「正反例配對」格式**——讓下次遇到相同情境時能直接對照行為，而非只知道結論：

<output_format>
```markdown
### [YYYY-MM-DD] 簡述標題

**情境觸發**: [什麼樣的任務/症狀會進入這個情境，寫得可被關鍵字匹配]
- ❌ **錯誤做法**: [當時實際做了什麼、為何失敗]
- ✅ **正確做法**: [應該怎麼做、第一步是什麼]

`#tag1` `#tag2`
```
</output_format>

**寫入前檢查：**
1. 讀取目標 topic 檔案，檢查是否有重複或高度相似的 entry。（寫入多個 topic 檔案時，彼此獨立的檔案讀取可平行執行。）
2. 如果已存在類似 entry，更新/補充而非新增——重複 entry 會稀釋索引的檢索價值。
3. 如果 topic 檔案不存在，建立新檔案。若整個 `.claude/learnings/` 都不存在，先執行
   `bash "${CLAUDE_PLUGIN_ROOT}/skills/session-learnings/scripts/init.sh"`（非 plugin 安裝時改用 skill 目錄下的 `scripts/init.sh`）。

### Step 4：更新 INDEX.md

**完成標準**：INDEX.md 已追加本次摘要行，且總行數未超過上限。

在 INDEX.md 追加一行摘要。

**INDEX.md 格式：**

<output_format>
```markdown
# Learnings Index

<!-- 每行格式：日期 | 摘要 | 分類檔案 | 標籤 -->
<!-- 此檔案會在每次 session 開始時載入，請保持精簡 -->

| 日期 | 摘要 | 分類 | 標籤 |
|------|------|------|------|
| 2026-03-15 | GAS 同步 Redmine 用 URL 當 key 而非 ID | tool-redmine, tool-gas | `#api` `#config` |
| 2026-03-16 | n8n Chat Trigger 不支援檔案上傳，需改用 Webhook | tool-n8n | `#workflow` `#debug` |
```
</output_format>

**INDEX.md 容量管理：**
- 上限 80 行（約 60 條 entries + header）——INDEX.md 每次 session 都會載入，過長會浪費 context
- 超過時，將最舊的 entries 移入 `archive/INDEX-archive-YYYY.md`
- 歸檔時在 INDEX.md 頂部加入：`> 📦 更早的記錄見 archive/INDEX-archive-YYYY.md`

### Step 5：通用性判斷

**完成標準**：每條 learning 都已評級，S/A 級已在 INDEX.md 標記 `⭐`。

對本次每條 learning 評估通用性等級：

| 等級 | 標準 | 處理方式 |
|------|------|---------|
| **S — 永久規則** | 違反會導致錯誤的硬限制（如「此 API 必須用 Bearer token」） | 標記為候選 rules |
| **A — 高頻適用** | 大多數 session 會用到（如「此專案 commit 格式為 conventional commits」） | 標記為候選 rules |
| **B — 偶爾適用** | 特定情境才需要（如「Redmine API 分頁用 limit+offset」） | 留在 topics 子檔案 |
| **C — 一次性** | 純粹的事件紀錄 | 留在 topics 子檔案 |

將 S 和 A 等級的 entries 標記在 INDEX.md 中（加 `⭐` 前綴）：

<example>
```markdown
| 2026-03-15 | ⭐ 此專案 Redmine API 認證必須用 X-Redmine-API-Key header | tool-redmine | `#api` |
```
</example>

這些 `⭐` 標記會在 Workflow B 中被掃描處理。

---

## Workflow B：總結經驗 → 產生 Rules 建議（使用者手動觸發）

### 觸發方式

- 使用者說「總結經驗」「consolidate learnings」「/session-learnings consolidate」
- 當 INDEX.md 中 `⭐` 標記的 entries 累積達 **5 條以上**時，主動提醒：

<output_format>
```
💡 目前有 N 條高通用性經驗尚未整合到專案規則中。
   要執行經驗總結嗎？（輸入「總結經驗」開始）
```
</output_format>

### Step 1：掃描 ⭐ 標記的 entries

讀取 INDEX.md，找出所有 `⭐` 標記的行（可用 `bash "${CLAUDE_PLUGIN_ROOT}/skills/session-learnings/scripts/scan-stars.sh"` 快速列出），再載入對應的 topics 子檔案取得完整內容。
需要平行處理時，可把 `agents/consolidate-agent.md` 的內容當作 subagent 指令交給一個子 agent。（多個 topics 子檔案的讀取彼此獨立，可平行執行。）

**完成標準**：所有 ⭐ entries 的完整內容都已取得。

### Step 2：分類與合併

將收集到的高通用性 learnings 合併歸類：
- 合併重複/相似的 entries
- 按主題分組（API 規則、程式碼慣例、工具設定等）

**完成標準**：每組主題下無重複項目。

### Step 3：產生建議內容

**完成標準**：每組 learning 都有一則含目標檔案、內容、來源的建議。

為每組 learning 產生具體的寫入建議，格式如下：

<output_format>
```
📝 建議寫入的規則（共 N 條）：

━━━━━━━━━━━━━━━━━━━━
建議 1/N
目標：.claude/rules/redmine-api.md（新建）
內容：
---
Redmine API 呼叫規則：
- 認證使用 X-Redmine-API-Key header，不使用 query parameter
- 分頁使用 limit + offset 參數，預設 limit=25
- 回傳格式指定 .json 結尾
---
來源：2026-03-15, 2026-03-18 的經驗
━━━━━━━━━━━━━━━━━━━━

建議 2/N
目標：CLAUDE.md（追加到既有區塊）
內容：
---
- GAS 定時觸發器中不可使用 getActiveSheet()，必須用 openById()
---
來源：2026-03-15 的經驗
━━━━━━━━━━━━━━━━━━━━

要執行哪些？（輸入編號，如 1,2 或 all）
```
</output_format>

**寫入目標的判斷邏輯：**
- **優先歸入既有檔案，避免 rules 碎片化**（碎片化會讓後續檢索與維護困難）：
  先 `ls .claude/rules/`，主題吻合就追加到既有檔。常見分法供參考：
  - 環境限制（OS / shell / 編碼）→ `rules/dev-environment.md`
  - 排查與判定紀律 → `rules/debug-strategy.md`
  - 特定外部系統 / API 的硬事實 → `rules/{系統名}.md`
- 確實不屬既有主題的規則集（3+ 條同主題）→ 才新建 `.claude/rules/{topic}.md`
- 單一但重要的規則 → 追加到 `CLAUDE.md`
- 不確定時 → 預設建議寫入 rules 子檔案（比 CLAUDE.md 更安全，因為 CLAUDE.md 每次 session 都載入）

### Step 4：等待使用者確認

只有使用者明確選擇後才執行寫入。寫入完成後：
- 從 INDEX.md 中移除已寫入的 `⭐` 標記（改為普通行或刪除）
- 在 INDEX.md 頂部記錄：`> ✅ 上次總結：YYYY-MM-DD，已寫入 N 條規則`

**完成標準**：使用者選擇的建議都已寫入，且 INDEX.md 的 ⭐ 狀態已同步更新。

---

## Workflow C：任務開始時的經驗檢索（自動）

> 以 plugin 安裝時，`SessionStart` hook 會在每個 session 開始時自動把 INDEX.md 注入 context，
> 不必依賴本 skill 被動觸發。若只複製 skill 而未裝 hook，請在 CLAUDE.md 加入
> 「開始任務前先讀 .claude/learnings/INDEX.md」的指示。

當開始一個新任務時，如果 `.claude/learnings/INDEX.md` 存在，依序執行：

1. 讀取 INDEX.md
2. 根據當前任務的關鍵字（工具名、語言、問題類型）掃描相關 entries
3. 如果找到相關 entries，載入對應的 topics 子檔案（多個子檔案讀取可平行執行）
4. 簡短提示使用者：

<output_format>
```
📂 找到 N 條相關經驗（來自 tool-redmine.md, debug.md）
   [可選] 要查看摘要嗎？
```
</output_format>

此行為可由使用者在 CLAUDE.md 中開啟/關閉：
```markdown
## 經驗檢索
- 開始任務時自動掃描 .claude/learnings/INDEX.md 中的相關經驗
```

---

## 子檔案模板

### topics 子檔案的標準 header

每個 topics 子檔案的開頭：

<output_format>
```markdown
# Learnings: {分類名稱}

<!-- 此檔案由 session-learnings skill 自動維護 -->
<!-- 僅在相關任務時載入，不會佔用每次 session 的 context -->

---

### [YYYY-MM-DD] 第一條 entry
...
```
</output_format>

---

## 重要原則

- **語言**：learnings 使用與使用者對話相同的語言；專案已有 learnings 時沿用其既有語言
- **主動性**：任務完成時主動提出記錄，不等使用者要求——經驗未即時記錄就會隨 session 結束流失
- **精簡**：每條 entry 控制在 1-5 行，INDEX.md 每條僅一行
- **只記錄非顯而易見的 insight**：常識性內容會稀釋索引價值，略過不記
- **安全性**：絕不記錄密碼、API key 的實際值——learnings 檔案會進入版控與 context
- **只追加、不覆蓋**：Workflow B 寫入 CLAUDE.md/rules 時永遠追加，絕不覆蓋既有內容，以免流失既有規則
