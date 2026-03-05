你现在是用 **Claude Code CLI** 做自动化开发，所以我直接给你一套**工程级最佳实践**，目标是：

> 让 Claude Code 变成“可控、可记忆、可进化”的开发 Agent
> 而不是一次性对话机器人

我会分成 5 个层级：

1. 调用方式最佳实践
2. 记忆管理架构
3. 任务中交互模式
4. 提效结构（让 Claude Code 更聪明）
5. 可进化增强（高级）

---

# 一、OpenClaw 调用 Claude Code 的最佳实践

## ✅ 1. 永远结构化调用（不要裸 prompt）

错误示例：

```bash
claude -p "修改 TaskTree.vue"
```

正确示例：

```bash
claude -p \
--dangerously-skip-permissions \
--model claude-3-7-sonnet \
--system "$(cat system.md)" \
--append-system-prompt "$(cat dev_rules.md)" \
--output-format json \
--verbose \
```

### 为什么？

因为 Claude Code 在 CLI 下是“无状态执行模型”。

如果你不显式传：

* system prompt
* 开发规则
* 项目上下文
* 输出结构

它会每次“失忆”。

---

# 二、记忆管理最佳实践（核心）

Claude Code 本质是 stateless。

你必须给它“外挂记忆层”。

推荐三层记忆模型：

```
L1: Session Memory （当前任务上下文）
L2: Project Memory （项目规则/架构）
L3: Evolution Memory （历史决策/踩坑记录）
```

---

## 🧠 L1：Session Memory（任务记忆）

做法：

* 每次运行前读取：

```
~/projects/xxx/yyy/session_context.md
```

包含：

```md
## 当前任务
重构 ABC.vue 组件

## 已完成
- 抽离节点状态管理
- 修复循环依赖

## 未完成
- 性能优化
- 单元测试
```

调用时自动注入：

```bash
--append-system-prompt "$(cat ~/projects/xxx/yyy/session_context.md)"
```

任务结束后自动更新这个文件。

---

## 🧠 L2：Project Memory（项目记忆）

放在：

```
.openclaw/workspace/skills/claude-code/project_rules.md
```

例如：

```md
- 使用 Composition API
- 所有 API 调用走 apiClient.ts
- 禁止在组件内直接 fetch
- 必须写单元测试
```

每次都自动附加：

```bash
--append-system-prompt "$(cat .openclaw/workspace/skills/claude-code/project_rules.md)"
```

---

## 🧠 L3：Evolution Memory（进化记忆）

这是高手玩法。

维护一个：

```
.openclaw/workspace/skills/claude-code/lessons.md
```

例如：

```md
2026-03-02:
- 避免 useEffect 中直接 setState
- 避免 TaskTree 出现深度递归渲染
```

每次任务结束：

让 Claude 自动写：

```bash
claude -p "总结本次修改的架构决策，追加到 lessons.md"
```

这样 Claude 会“学会不犯同样错误”。

---

# 三、任务中如何与 Claude Code 交互（高效模式）

不要只给任务。

用三阶段模式：

---

## 🧩 阶段1：Planner

先让它规划。

```bash
claude -p "
你是高级前端架构师。
不要写代码。
请输出修改 TaskTree.vue 的分步计划。
"
```

让它输出：

* 风险
* 修改点
* 影响范围

你审核。

---

## 🛠 阶段2：Executor

再执行：

```bash
claude -p "
根据已确认的计划，只修改第1步。
输出 diff。
"
```

永远让它输出 diff，不要整文件。

---

## 🔍 阶段3：Reviewer

最后：

```bash
claude -p "
你现在是 code reviewer。
检查刚才的修改。
找出潜在 bug 和性能问题。
"
```

三 Agent 思维：

```
Planner
Executor
Reviewer
```

而不是一个大 prompt 全干。

---

# 四、让 Claude Code 更高效的结构技巧

## ✅ 1. 永远限制作用域

错误：

> 重构整个项目

正确：

> 只修改 TaskTree.vue，不得修改其他文件。

模型的性能与范围强相关。

---

## ✅ 2. 永远要求结构化输出

```bash
--output-format json
```

Prompt 要求：

```text
请输出：
{
  "analysis": "",
  "changes": "",
  "risk": ""
}
```

这样 OpenClaw 可以解析、自动 routing。

---

## ✅ 3. 使用 Hook 自动增强

例如：

### pre-hook

* 自动收集 git diff
* 自动读取相关文件

### post-hook

* 自动运行 lint
* 自动运行 test
* 自动记录 summary

OpenClaw 可以：

```
on_task_start → inject context
on_task_end → summarize → update memory
```

---

# 五、高阶玩法：让 Claude Code 进入“半自主进化模式”

你之前提到想往自主进化方向强化。

给你一个增强模式：

---

## 1️⃣ Capability Self-Discovery

周期性让 Claude 评估自己：

```bash
claude -p "
分析本项目结构。
给出可以自动化的开发任务清单。
"
```

---

## 2️⃣ 错误驱动进化

当 CI 失败时：

```bash
claude -p "
测试失败如下：
<log>

分析根因并给出最小修复。
"
```

---

# 六、终极最佳实践总结（实战版本）

真正高效的 OpenClaw + Claude Code 开发流是：

```
1. 读取 project_rules.md
2. 读取 session_context.md
3. Planner 输出计划
4. 人类确认
5. Executor 输出 diff
6. Reviewer 审查
7. 更新 lessons.md
8. CI 测试
9. 若失败 → 自动修复循环
```

