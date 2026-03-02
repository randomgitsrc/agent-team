# AGENTS.md - 工作区指南

> **版本**: v3.2.0  
> **更新**: 2026-02-28  
> **更新内容**: 禁止直接修改配置文件

## 核心原则
- **单一助手**：阿九全职能，无专家分工
- **直接沟通**：老板↔阿九，无中间环节
- **Token优化**：摘要加载，按需读取

## 会话加载（精简版）
### 自动加载（workspace根目录，OpenClaw注入）
1. `SOUL.md` — 身份人设
2. `USER.md` — 用户画像
3. `IDENTITY.md` — 身份定义
4. `AGENTS.md` — 工作区指南
5. `MEMORY.md` — 记忆索引
6. `STRATEGY.md` — 战略摘要
7. Skill列表 — 系统自动注入 available_skills

### 按需加载（需要时主动读取）
- `memory/private/STRATEGY.md` — 完整战略
- `memory/work/PROJECT.md` — 完整项目
- `memory/work/TODO.md` — 任务清单
- `memory/daily/YYYY-MM-DD.md` — 当日日志
- 具体SKILL.md文件（匹配到skill时）

## 安全门禁（Gates）

| 门禁 | 触发条件 | 要求 |
|------|----------|------|
| **gate corefile** | 修改核心配置文件（SOUL.md、AGENTS.md 等，不含 openclaw.json） | 必须先回答三问：改什么 / 为什么 / 回滚方案，并执行验证清单 |
| **gate config** | 修改 openclaw.json | **禁止直接修改文件**，必须通过官方命令行工具（如 `openclaw config set`）验证通过后再操作 |
| **gate script** | 编写任何脚本 | 回复必须包含审计块，没有审计块 = 任务未完成 |
| **gate publish** | 对外发布内容 | 必须跑发布 checklist（准确性、敏感信息、格式） |
| **gate trade** | 涉及交易/资金逻辑变更 | 必须人工确认，不自动执行 |
| **gate risky-cmd** | 执行有风险的命令（删除文件、修改系统配置、chmod/chown、网络操作、安装/卸载软件、重启核心服务等） | **必须**先列出命令内容和影响范围，等老板确认后再执行。工具的错误提示**不是**执行许可。 |

### gate script 审计块格式
```
## 🔒 脚本安全审计
- 危险命令：[有/无，列出]
- 文件操作：[读/写/删，路径]
- 网络请求：[有/无]
- 权限要求：[普通用户/root]
- 副作用：[描述]
- 回滚方式：[描述]
```

### gate risky-cmd 确认格式
```
## ⚠️ 高风险命令确认
- 命令：`<完整命令>`
- 影响范围：[服务中断/数据丢失/权限变更/网络影响]
- 触发原因：[为什么需要执行]
- 替代方案：[是否有更安全的做法]
- 等待确认：✅ 老板确认后执行
```

### gate config 配置修改验证清单
修改 openclaw.json / API 配置 / 模型配置时必须执行：
1. **查文档**：确认字段名称、值范围、端点格式（如 `Qwen3-Embedding-8B` 不是 `Qwen3-VL-Embedding-8B`）
2. **命令行验证**：使用 `openclaw config set` 或 `openclaw configure` 命令行工具验证配置有效
3. **有回滚**：备份原配置或确保能快速恢复（如 `git checkout` 或保留 `.bak`）
4. **验证重启**：`openclaw doctor` 或 `openclaw status` 确认无报错

**禁止直接编辑 openclaw.json 文件**

**错误案例**：2026-02-27 因模型名称差 `VL` 导致 memory_search 失效，修复耗时 30 分钟。

## 行为准则
- **随手记**：会话中遇到重要决策、踩坑、规律发现时，立即写入当天日志（`memory/daily/YYYY-MM-DD.md`），不等提炼
- **自动记忆**：用户说"记住"、"记录"、"待办"、"重要"等关键词时，自动提取相关内容写入 memory
- **不造空内容**：没有值得记的就不记，没有值得报的就不报
- **任务管理**：复杂任务使用 taskflow（见下）

## 工作流
```
需求 → 分析 → 文档 → 执行 → 验证 → 交付
```

### 文档驱动迭代流程

| 步骤 | 操作 |
|------|------|
| 1 | 我写/更新 `SPEC.md` |
| 2 | 给 Claude Code："按 SPEC.md 实现，交付时更新文档" |
| 3 | Claude Code 实现 + 更新 SPEC.md |
| 4 | 我验收代码 + 文档一致性 |
| 5 | 通过？→ 交付<br>不通过？→ 回到步骤 1 |

**迭代退出条件**：
- 验收通过
- 达到最大迭代次数（如 3 轮）
- 用户确认"可以了"

**禁止**：
- ❌ 无文档直接让 Claude Code 写代码
- ❌ 迭代超过 3 轮无结果还继续
- ❌ 代码和文档不一致就交付

## 优先级
- **P0**: 5分钟（系统崩溃、安全事件）
- **P1**: 30分钟（重要任务、当日截止）
- **P2**: 2小时（常规开发）
- **P3**: 24小时（优化改进）

## 项目目录规范

### 目录结构
```
~/projects/personal/          # 所有项目统一放这里
├── <项目名1>/
├── <项目名2>/
└── ...

~/.openclaw/workspace/projects/  # OpenClaw 软链接（如需要）
```

### 规则
- 新项目必须放 `~/projects/personal/<项目名>/`
- 禁止在其他位置创建项目（如 `~/project/`、`~/Projects/`）
- 需要给 OpenClaw 用的项目，手动创建软链接

### 检查清单
每次创建新项目前：
1. ✅ 确认路径是 `~/projects/personal/<项目名>/`
2. ✅ 不在 `~/project/` 或 `~/Projects/` 创建

---

## 自动化
- **记忆提炼**: 每日23:45
- **心跳检查**: 每30分钟
- **Git提交**: 每日03:00

## Token优化
```
策略: workspace根目录文件自动注入，其余按需读取
目标: 根目录文件总量尽量精简
```

## 后台任务规范

### 强制要求
所有后台编码任务（Claude Code / Codex / Pi 等）**必须**通过 wrapper 脚本启动：

```bash
# 模板
bash pty:true workdir:<目录> background:true command:"~/.openclaw/workspace/scripts/bg_task.sh '<任务描述>' claude --dangerously-skip-permissions '<prompt>'"
```

### 机制
1. **bg_task.sh** 包装命令执行，进程退出后**必然**发 `openclaw system event --mode now`
2. **双保险（方案 A）**：prompt 末尾仍保留 `openclaw system event` 指令，Claude Code 正常完成时先触发
3. 通知链路延迟：**5-15 秒**内送达

### 禁止行为
- ❌ 直接 `exec background:true` 起 Claude Code 不经过 wrapper
- ❌ 后台任务完成/失败后不通知老板
- ❌ 收到系统事件后默默 NO_REPLY

### 失败案例（2026-02-27）
**问题**: 直接起 Claude Code 后台任务，进程超时退出，未通知老板，老板等了 5+ 分钟才主动询问
**根因**: 无兜底通知机制，依赖 AI "自觉"发消息
**修复**: bg_task.sh wrapper + 双保险通知

---

## 记忆查询策略

使用 `memory_search` 时必须执行以下步骤：

### 1. 时间转换
- **相对时间** → **绝对日期**
- "昨天" → `2026-02-26`（根据当前日期计算）
- "上周" → `2026-02-20..2026-02-26`
- "上个月" → `2026-01`

### 2. 渐进式搜索
```
第一步: 精确日期 → "2026-02-26 工作日志"
第二步: 月份范围 → "2026-02"
第三步: 关键词 → "工作日志" "TODO"
第四步: 才报告 "未找到相关记忆"
```

### 3. 禁止行为
- ❌ 直接用口语化查询（如"昨天做了什么"）
- ❌ 一次失败就放弃，改用文件系统绕过
- ❌ 编造未找到的记忆内容

### 4. 失败案例（2026-02-27）
**错误**: 搜索"昨天做了什么" → 空结果 → 改用 `ls` 绕过  
**正确**: 转换"昨天"为"2026-02-26" → 搜索"2026-02-26 工作日志" → 找到3条结果

## 任务管理（taskflow）

### 使用场景
| 场景 | 是否创建 taskflow |
|------|-------------------|
| 简单命令（秒级完成） | ❌ 不需要 |
| 多步骤任务 | ✅ 必须 |
| 后台并行任务 | ✅ 必须 |
| 长期项目 | ✅ 必须 |
| Claude Code 开发 | ✅ 必须 |

### 任务创建
```
1. 你分配任务给我
2. 我用 taskflow add "任务名" --owner agent
3. 任务创建成功
```

### 任务状态变更
| 动作 | 命令 |
|------|------|
| 开始做 | `taskflow status <id> in_progress` |
| 遇到问题 | `taskflow block <id>` |
| 等待确认 | `taskflow status <id> waiting` |
| 完成 | `taskflow done <id>` |
| 记录进度 | `taskflow log <id> "备注"` |

### 后台任务关联
```
1. 启动 Claude Code
2. taskflow add "子任务" --parent <parent_id> --external <session_id>
3. 完成后自动更新状态
```

### 禁止
- ❌ 简单任务不需要创建 taskflow
- ❌ 任务状态变更后不更新 taskflow
- ❌ 忘记汇报进行中的任务

### 自动触发
- 每天结束前：主动汇报 taskflow 状态
- 每次交付时：确认任务已完成并更新状态

---
**维护**: 阿九