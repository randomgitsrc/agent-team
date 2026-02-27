#!/bin/bash
#
# Session 文件定期清理脚本
# 功能：移动 session 记录到非Git目录，保留最近7天
#
# 运行方式：
#   ./scripts/cleanup_sessions.sh        # 手动执行
#   或加入 crontab: 0 3 * * * /path/to/cleanup_sessions.sh

set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_DIR="$WORKSPACE_DIR/memory"           # Git 目录（符号链接位置）
TARGET_DIR="$HOME/.openclaw/sessions"        # 非Git目录（实际存储）
KEEP_DAYS=7                                  # 保留最近7天

# 确保目标目录存在
mkdir -p "$TARGET_DIR"

# 移动 session 文件（20*-.md 模式）到非Git目录
find "$SOURCE_DIR" -maxdepth 1 -type f -name "20*.md" 2>/dev/null | while read -r file; do
    filename=$(basename "$file")
    
    # 检查是否是真正的文件（不是符号链接）
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        mv "$file" "$TARGET_DIR/$filename"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Moved: $filename"
    fi
done

# 清理旧文件（超过 KEEP_DAYS 天）
find "$TARGET_DIR" -maxdepth 1 -type f -name "20*.md" -mtime +$KEEP_DAYS -delete 2>/dev/null || true

echo "$(date '+%Y-%m-%d %H:%M:%S') - Session cleanup completed. Kept last $KEEP_DAYS days."
