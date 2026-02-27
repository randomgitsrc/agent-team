#!/bin/bash
# safe-output.sh - 强制输出文件到 workspace 目录
# 用法: safe-output.sh <原始命令>

set -e

WORKSPACE="$HOME/.openclaw/workspace"
TMP_DIR="$WORKSPACE/tmp"

# 确保 tmp 目录存在
mkdir -p "$TMP_DIR"

CMD="$*"

# 检查是否有输出文件参数
if [[ "$CMD" == *"--screenshot="* ]] || \
   [[ "$CMD" == *"-o "* ]] || \
   [[ "$CMD" == *"> "* ]] || \
   [[ "$CMD" == *"--output="* ]] || \
   [[ "$CMD" == *" > "* ]]; then
    
    # 替换 /tmp/ 开头的路径
    CMD=$(echo "$CMD" | sed "s|--screenshot=/tmp/|--screenshot=$TMP_DIR/|g")
    CMD=$(echo "$CMD" | sed "s|--screenshot=/tmp/|--screenshot=$TMP_DIR/|g")
    CMD=$(echo "$CMD" | sed "s|-o /tmp/|-o $TMP_DIR/|g")
    CMD=$(echo "$CMD" | sed "s|--output=/tmp/|--output=$TMP_DIR/|g")
    CMD=$(echo "$CMD" | sed "s|> /tmp/|> $TMP_DIR/|g")
    
    # 替换相对路径到 tmp 目录
    CMD=$(echo "$CMD" | sed "s|--screenshot=tmp/|--screenshot=$TMP_DIR/|g")
    CMD=$(echo "$CMD" | sed "s|-o tmp/|-o $TMP_DIR/|g")
    
    echo "🔒 路径已重定向到 workspace/tmp/"
    echo "执行命令: $CMD"
fi

# 执行命令
eval "$CMD"

# 检查是否有文件输出到非法路径
if find /tmp -name "*.png" -o -name "*.jpg" -o -name "*.log" -o -name "*.txt" 2>/dev/null | grep -q .; then
    echo "⚠️ 警告：有文件输出到 /tmp/，请使用 workspace/tmp/"
    find /tmp -name "*.png" -o -name "*.jpg" -o -name "*.log" -o -name "*.txt" 2>/dev/null | head -5
fi