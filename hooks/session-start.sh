#!/usr/bin/env bash
# Workflow C:session 開始時把專案的 learnings 索引注入 context。
# 沒有 .claude/learnings/INDEX.md 的專案什麼都不輸出,零開銷。
INDEX="${CLAUDE_PROJECT_DIR:-.}/.claude/learnings/INDEX.md"
[ -f "$INDEX" ] || exit 0

echo "<session-learnings>"
echo "本專案有累積的 session learnings。開始任務前,依任務關鍵字掃描下方索引,"
echo "只載入相關的 .claude/learnings/topics/*.md;任務結束時用 session-learnings skill 記錄新經驗。"
echo
# 索引設計上 < 80 行;保險起見截斷,避免異常膨脹的索引吃掉 context
head -n 120 "$INDEX"
STARS=$(grep -c '^|.*⭐' "$INDEX" || true)
if [ "${STARS:-0}" -ge 5 ]; then
  echo
  echo "💡 有 ${STARS} 條 ⭐ 高通用性經驗尚未整合進 rules,可提醒使用者「總結經驗」。"
fi
echo "</session-learnings>"
