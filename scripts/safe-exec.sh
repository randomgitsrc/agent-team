#!/bin/bash
# safe-exec.sh - 高风险命令检查
# 用法: safe-exec.sh <命令>

set -e

CMD="$*"

# 高风险命令模式
RISKY_PATTERNS=(
    "rm -rf /"
    "chmod 777"
    "chown root"
    "dd of=/dev"
    "openclaw gateway restart"
    "openclaw gateway stop"
    "systemctl restart"
    "systemctl stop"
    "kill -9"
    "iptables"
    "ufw"
    "mount"
    "umount"
    "format"
    "mkfs"
    "fdisk"
)

for pattern in "${RISKY_PATTERNS[@]}"; do
    if [[ "$CMD" == *"$pattern"* ]]; then
        echo "❌ 检测到高风险命令: $pattern"
        echo "命令: $CMD"
        echo ""
        echo "## ⚠️ 高风险命令确认"
        echo "- 命令: \`$CMD\`"
        echo "- 影响范围: 服务中断/系统配置变更"
        echo "- 触发原因: 需要人工确认"
        echo "- 替代方案: 暂无"
        echo "- 等待确认: ✅ 老板确认后执行"
        exit 1
    fi
done

# 执行命令
eval "$CMD"