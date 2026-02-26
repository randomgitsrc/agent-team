---
task_id: T-TEST-ARCHIVE-001
title: 测试归档任务
priority: P3
owner: 测试
creator: 系统
created_at: 2026-01-01 10:00
due_at: 2026-01-10 12:00

status: DONE
status_since: 2026-01-01 10:00
status_history:
  - status: PENDING
    at: 2026-01-01 10:00
  - status: DOING
    at: 2026-01-05 14:00
  - status: DONE
    at: 2026-02-01 10:00

completed_at: 2026-02-01 10:00

blockers: []
last_blocker_resolved: null

checkpoints:
  design: { done: true, at: 2026-01-03, evidence: "设计完成" }
  test: { done: true, at: 2026-02-01, evidence: "测试完成" }

next_check_at: 2026-02-02 10:00
check_count: 3
---

## 任务描述

这是一个用于测试归档机制的测试任务。
完成时间设定为2026-02-01，超过7天前，应该会被归档。

## 交付物

- [x] 测试文件
- [x] 归档验证
