#!/usr/bin/env bash
# 掃描 INDEX.md 中的 ⭐ 標記 entries
# 用途：Workflow B 的第一步，找出待整合的高通用性經驗
# 使用：bash scan-stars.sh [learnings_dir]

set -e

LEARNINGS_DIR="${1:-.claude/learnings}"
INDEX_FILE="${LEARNINGS_DIR}/INDEX.md"

if [ ! -f "$INDEX_FILE" ]; then
  echo "❌ 找不到 ${INDEX_FILE}"
  exit 1
fi

# grep -c 無命中時印 0 但 exit 1,不可再 || echo 0(會印兩次)
STAR_COUNT=$(grep -c '^|.*⭐' "$INDEX_FILE" || true)

echo "📊 掃描結果："
echo "   INDEX.md 總行數：$(wc -l < "$INDEX_FILE" | tr -d ' ')"
echo "   ⭐ 高通用性 entries：${STAR_COUNT} 條"
echo ""

if [ "$STAR_COUNT" -gt 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━"
  echo "⭐ 標記的 entries："
  echo "━━━━━━━━━━━━━━━━━━━━"
  grep '^|.*⭐' "$INDEX_FILE"
  echo ""

  # 第 3 欄(以 | 分隔的第 4 段)是分類,可能以逗號列多個
  echo "📁 涉及的 topics 檔案："
  grep '^|.*⭐' "$INDEX_FILE" | awk -F'|' '{print $4}' | tr ',' '\n' \
    | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/\.md$//' | grep -v '^$' | sort -u \
    | while read -r topic; do
        TOPIC_FILE="${LEARNINGS_DIR}/topics/${topic}.md"
        if [ -f "$TOPIC_FILE" ]; then
          echo "   ✅ topics/${topic}.md ($(wc -l < "$TOPIC_FILE" | tr -d ' ') 行)"
        else
          echo "   ⚠️  topics/${topic}.md (不存在)"
        fi
      done

  if [ "$STAR_COUNT" -ge 5 ]; then
    echo ""
    echo "💡 建議：⭐ entries 已達 ${STAR_COUNT} 條，建議執行「總結經驗」整合到 rules。"
  fi
else
  echo "✨ 目前沒有待整合的 ⭐ entries。"
fi
