# 规则执行分层方案

## 目标
将规则从文字描述转为可执行的约束机制，分三层实现。

---

## 第一层：绝对硬约束（底线）

### 1. 路径安全约束
**规则**: 所有输出文件必须在 workspace 目录下
**实现**: `safe-output.sh` wrapper
```bash
#!/bin/bash
# safe-output.sh
# 包装任何可能输出文件的命令
if [[ "$*" == *"--screenshot="* ]] || [[ "$*" == *"-o "* ]] || [[ "$*" == *"> "* ]]; then
    # 自动重定向 /tmp/ 到 workspace/tmp/
    CMD=$(echo "$*" | sed "s|--screenshot=/tmp/|--screenshot=$WORKSPACE/tmp/|g")
    CMD=$(echo "$CMD" | sed "s|-o /tmp/|-o $WORKSPACE/tmp/|g")
    CMD=$(echo "$CMD" | sed "s|> /tmp/|> $WORKSPACE/tmp/|g")
    eval "$CMD"
else
    eval "$*"
fi
```

### 2. 后台任务通知约束
**规则**: 后台任务完成必须通知老板
**实现**: `bg_task.sh`（已存在）
```bash
# 已实现，强制 openclaw system event
```

### 3. 高风险命令确认
**规则**: 删除/修改系统文件需确认
**实现**: `safe-exec.sh`
```bash
#!/bin/bash
# safe-exec.sh
RISKY_PATTERNS="rm -rf /|chmod 777|chown root|dd of=/dev"
if echo "$*" | grep -qE "$RISKY_PATTERNS"; then
    echo "⚠️ 高风险命令，需要人工确认"
    exit 1
fi
eval "$*"
```

---

## 第二层：引导式约束（默认+可覆盖）

### 1. 代码修改约束
**规则**: 默认使用 Claude Code 修改代码
**实现**: `edit-code.sh`
```bash
#!/bin/bash
# edit-code.sh <文件> <描述>
FILE="$1"
DESC="$2"
if [[ "$3" != "--force-edit" ]]; then
    # 默认走 Claude Code
    claude --dangerously-skip-permissions "修改文件 $FILE: $DESC"
else
    # 人工覆盖模式
    $EDITOR "$FILE"
fi
```

### 2. 系统事件响应约束
**规则**: 收到系统事件需在 30 秒内响应
**实现**: 心跳检查 + 提醒
```bash
# 在 HEARTBEAT.md 中增加检查
# 每 30 秒检查是否有未处理的系统事件
```

### 3. 大额 API 调用约束
**规则**: 单次调用预估超过 $1 需确认
**实现**: `cost-check.sh`
```bash
#!/bin/bash
# cost-check.sh <模型> <输入token> <输出token>
MODEL=$1
IN=$2
OUT=$3
# 查价表，计算预估成本
COST=$(calculate_cost "$MODEL" "$IN" "$OUT")
if (( $(echo "$COST > 1.0" | bc -l) )); then
    echo "预估成本 $COST > $1，需要确认"
    exit 1
fi
```

---

## 第三层：纯建议（靠自觉）

### 1. 代码风格建议
- 提交前运行 `prettier` / `eslint`
- 但不强制，只提示

### 2. 文档规范建议
- PRD 模板、验收 checklist
- 可用可不用

### 3. 沟通礼仪建议
- 回复结构、信息密度
- 完全靠我判断

---

## 实施路线图

### 第一阶段（本周）
1. 创建 `workspace/tmp/` 目录
2. 实现 `safe-output.sh`（路径约束）
3. 更新 `AGENTS.md` 规则，标注哪些是硬约束

### 第二阶段（下周）
1. 实现 `edit-code.sh`（代码修改约束）
2. 实现 `safe-exec.sh`（高风险命令约束）
3. 测试覆盖场景

### 第三阶段（下月）
1. 实现成本检查
2. 集成到心跳系统
3. 回顾优化

---

## 关键原则

1. **硬约束必须极少**，只针对会出大事的底线
2. **可覆盖的约束要有明确覆盖方式**（如 `--force-edit`）
3. **所有约束工具必须开源透明**，我知道它在做什么
4. **定期回顾**，移除不必要的约束，增加新的底线
