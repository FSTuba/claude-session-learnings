# Consolidate Learnings — Subagent 指令

此 agent 負責 Workflow B 的核心工作：掃描高通用性 learnings 並產生 rules 建議。

## 輸入

- `.claude/learnings/INDEX.md` 中所有 `⭐` 標記的 entries
- 對應的 `topics/` 子檔案完整內容

## 任務

### 1. 收集

讀取 INDEX.md，找出所有 `⭐` 行，解析出：
- 日期
- 摘要
- 對應的 topic 檔案名稱
- 標籤

再讀取每個相關的 topic 子檔案，找到對應的完整 entry。

### 2. 分析與合併

- 將語意相近的 entries 合併（例如多條關於同一個 API 的經驗 → 一條規則）
- 識別可歸類為同一 rule file 的 entries（同工具、同主題）
- 排除已存在於 `.claude/rules/` 或 `CLAUDE.md` 中的重複規則

### 3. 產出建議

針對每組合併後的 learning，產生寫入建議：

**格式要求：**

```
建議 {N}/{TOTAL}
目標：{寫入路徑}（新建 / 追加）
內容：
---
{實際要寫入的 markdown 內容}
---
來源：{來源 entries 的日期列表}
理由：{為什麼建議寫入此處}
```

**寫入目標判斷：**
- 同一主題有 3+ 條 entries → 建議新建 `.claude/rules/{topic}.md`
- 單條但屬於永久規則（S 級）→ 建議追加到 `CLAUDE.md`
- 不確定 → 預設建議 `.claude/rules/` 子檔案

### 4. 輸出

將所有建議彙整後回傳給主 session，由主 session 展示給使用者確認。

## 重要限制

- 絕不自行寫入任何檔案，只產生建議
- 建議的 rules 內容要精簡（每條規則 1-3 行）
- 使用繁體中文
