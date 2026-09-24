#!/usr/bin/env bash
# session-learnings 初始化腳本
# 用途：在專案中建立 learnings 目錄結構
# 使用：bash init.sh [project_root]

set -e

PROJECT_ROOT="${1:-.}"
LEARNINGS_DIR="${PROJECT_ROOT}/.claude/learnings"

# 建立目錄結構
mkdir -p "${LEARNINGS_DIR}/topics"
mkdir -p "${LEARNINGS_DIR}/archive"

# 建立 INDEX.md（如果不存在）
if [ ! -f "${LEARNINGS_DIR}/INDEX.md" ]; then
  cat > "${LEARNINGS_DIR}/INDEX.md" << 'EOF'
# Learnings Index

<!-- 此檔案由 session-learnings skill 自動維護 -->
<!-- 每行一條 learning 摘要，詳細內容存於 topics/ 子檔案 -->
<!-- ⭐ 標記 = 高通用性，等待整合到 rules/CLAUDE.md -->

| 日期 | 摘要 | 分類 | 標籤 |
|------|------|------|------|
EOF
  echo "✅ 已建立 ${LEARNINGS_DIR}/INDEX.md"
else
  echo "⏭️  INDEX.md 已存在，跳過"
fi

# 建立 .gitignore（learnings 通常不需要 git 追蹤，但可選）
if [ ! -f "${LEARNINGS_DIR}/.gitignore" ]; then
  cat > "${LEARNINGS_DIR}/.gitignore" << 'EOF'
# 取消註解下一行以排除 learnings 的 git 追蹤
# *
# !.gitignore
EOF
  echo "✅ 已建立 ${LEARNINGS_DIR}/.gitignore"
fi

echo ""
echo "📂 Learnings 目錄結構已就緒："
echo "   ${LEARNINGS_DIR}/"
echo "   ├── INDEX.md"
echo "   ├── topics/"
echo "   └── archive/"
echo ""
echo "💡 建議在 CLAUDE.md 加入："
echo '   - 開始任務時自動掃描 .claude/learnings/INDEX.md 中的相關經驗'
echo '   - 每次任務完成後，使用 /session-learnings 記錄本次經驗'
