#!/bin/bash
# remind.sh - 创建/删除一次性提醒 cron 任务
# 用法:
#   remind.sh set <分钟数> <提醒内容>   # 设置提醒
#   remind.sh list                      # 列出当前提醒
#   remind.sh cancel <job_id>           # 取消提醒

set -e

REMIND_TAG="openclaw-remind"
TELEGRAM_BOT_TOKEN=$(openclaw config get channels.telegram.botToken 2>/dev/null | tr -d '"')
CHAT_ID="1967179893"

case "$1" in
  set)
    MINUTES="$2"
    MESSAGE="$3"

    if [[ -z "$MINUTES" || -z "$MESSAGE" ]]; then
      echo "用法: remind.sh set <分钟数> <提醒内容>"
      exit 1
    fi

    # 计算触发时间
    TRIGGER=$(date -d "+${MINUTES} minutes" "+%M %H %d %m")
    JOB_ID="remind-$(date +%s)"

    # 发送 Telegram 消息的命令
    SEND_CMD="curl -s -X POST https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text='⏰ 提醒：${MESSAGE}' > /dev/null 2>&1"

    # 自删除：发完消息后删除自己这条 cron
    SELF_DELETE="crontab -l | grep -v '${JOB_ID}' | crontab -"

    # 写入 cron
    (crontab -l 2>/dev/null; echo "${TRIGGER} * ${SEND_CMD} && ${SELF_DELETE} # ${REMIND_TAG} ${JOB_ID}") | crontab -

    echo "✅ 提醒已设置"
    echo "   内容：${MESSAGE}"
    echo "   触发：$(date -d "+${MINUTES} minutes" "+%H:%M")"
    echo "   ID：${JOB_ID}"
    ;;

  list)
    echo "当前提醒："
    crontab -l 2>/dev/null | grep "${REMIND_TAG}" || echo "（无）"
    ;;

  cancel)
    JOB_ID="$2"
    if [[ -z "$JOB_ID" ]]; then
      echo "用法: remind.sh cancel <job_id>"
      exit 1
    fi
    crontab -l 2>/dev/null | grep -v "${JOB_ID}" | crontab -
    echo "✅ 已取消提醒 ${JOB_ID}"
    ;;

  *)
    echo "用法: remind.sh set <分钟数> <提醒内容>"
    echo "      remind.sh list"
    echo "      remind.sh cancel <job_id>"
    exit 1
    ;;
esac
