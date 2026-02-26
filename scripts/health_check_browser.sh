#!/bin/bash
# 卫道 (Aegis) 浏览器服务巡检脚本 v1.0

LOG_FILE="/root/.openclaw/workspace/projects/active/ajiu-sight/audit/health.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 检查浏览器连接
if openclaw browser status > /dev/null 2>&1; then
    echo "[$TIMESTAMP] 🟢 Browser Service: OK" >> $LOG_FILE
else
    echo "[$TIMESTAMP] 🔴 Browser Service: FAILED. Attempting recovery..." >> $LOG_FILE
    # 重启网关以恢复 CDP
    openclaw gateway restart
    echo "[$TIMESTAMP] ⚠️ Gateway restarted by Aegis." >> $LOG_FILE
fi
