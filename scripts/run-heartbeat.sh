#!/bin/bash
# 自动心跳检测包装脚本，由 OpenClaw Cron 触发或系统 Cron 触发

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/heartbeat.sh" >> "$SCRIPT_DIR/heartbeat.log" 2>&1
