#!/bin/bash

# Healthchecks.io Ping URL
PING_URL="https://hc-ping.com/e08438a4-0ee2-4ffa-9658-13d09c8cbdda"

# 1. 进程检查 (OpenClaw Gateway)
PGATEWAY=$(pgrep -f "openclaw.*gateway")

# 2. 模型连通性检查 (E2E Check)
# 使用 openclaw list agents 做一个极简的内部逻辑链路测试
# 这是为了确认 Gateway 不仅活着，还能处理逻辑请求
LINK_OK=$(openclaw status --json 2>/dev/null | grep -c "\"ok\":true")

if [ -n "$PGATEWAY" ] && [ "$LINK_OK" -gt 0 ]; then
    # 进程和链路都正常
    curl -fsS --retry 3 "$PING_URL" > /dev/null 2>&1
    echo "$(date): [PASS] Gateway running, Logic Link OK. Ping sent."
else
    # 任何一项失败则告警
    curl -fsS --retry 3 "$PING_URL/fail" > /dev/null 2>&1
    echo "$(date): [CRITICAL] Status check failed (Gateway: $PGATEWAY, Link: $LINK_OK). Fail signal sent."
fi
