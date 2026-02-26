---
name: remind
description: 设置定时提醒。当用户说"提醒我X分钟/小时后做Y"、"X分钟后提醒我"、"半小时后叫我"等时使用此技能。通过 cron 创建一次性任务，时间到后发送 Telegram 消息，发完自动清理。
---

# Remind

通过 cron 设置一次性提醒，时间到后发 Telegram 消息，自动清理。

## 使用方式

### 设置提醒
```bash
bash skills/remind/scripts/remind.sh set <分钟数> "<提醒内容>"
```

示例：
- "提醒我30分钟后站起来休息" → `remind.sh set 30 "站起来休息一下"`
- "1小时后提醒我喝水" → `remind.sh set 60 "喝水"`

### 查看当前提醒
```bash
bash skills/remind/scripts/remind.sh list
```

### 取消提醒
```bash
bash skills/remind/scripts/remind.sh cancel <job_id>
```

## 时间换算
- X分钟 → 直接传数字
- X小时 → 乘以60
- 半小时 → 30

## 注意
- 脚本路径基于 workspace 根目录
- CHAT_ID 已硬编码为当前用户
- 提醒发送后 cron 任务自动删除
