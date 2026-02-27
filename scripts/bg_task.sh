#!/bin/bash
# bg_task.sh - 后台任务 wrapper，确保任务完成后发通知
# 用法: bg_task.sh <描述> <命令...>
# 示例: bg_task.sh "迷宫游戏开发" claude --dangerously-skip-permissions 'Build a game'
#
# 机制：
# 1. 执行传入的命令
# 2. 无论成功/失败/超时，都通过 openclaw system event 发通知
# 3. 通知走 --mode now，触发即时唤醒（5-15秒内送达）

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "用法: bg_task.sh <描述> <命令...>"
  echo "示例: bg_task.sh \"迷宫游戏\" claude --dangerously-skip-permissions 'Build a game'"
  exit 1
fi

DESC="$1"
shift

START_TIME=$(date +%s)

# 执行命令，捕获退出码（不让 set -e 中断）
set +e
"$@"
EXIT_CODE=$?
set -e

END_TIME=$(date +%s)
ELAPSED=$(( END_TIME - START_TIME ))

# 格式化耗时
if [ $ELAPSED -ge 60 ]; then
  MINS=$(( ELAPSED / 60 ))
  SECS=$(( ELAPSED % 60 ))
  DURATION="${MINS}m${SECS}s"
else
  DURATION="${ELAPSED}s"
fi

# 发通知
if [ $EXIT_CODE -eq 0 ]; then
  openclaw system event --text "✅ ${DESC} 完成（耗时 ${DURATION}）" --mode now
elif [ $EXIT_CODE -eq 143 ]; then
  # 143 = SIGTERM，通常是 timeout kill
  openclaw system event --text "⏱ ${DESC} 超时退出（耗时 ${DURATION}，可能已完成部分工作）" --mode now
else
  openclaw system event --text "❌ ${DESC} 失败（exit ${EXIT_CODE}，耗时 ${DURATION}）" --mode now
fi

exit $EXIT_CODE
