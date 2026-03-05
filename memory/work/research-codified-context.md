# Codified Context Infrastructure 研究

> 来源：https://github.com/arisvas4/codified-context-infrastructure  
> 日期：2026-03-02

## 核心：三层上下文基础设施

```
┌─────────────────────────────────────────────────────┐
│ Tier 1: CONSTITUTION（热记忆 — 始终加载）           │
│  • 惯例、构建命令、命名规范                          │
│  • Agent 触发表（何时调用哪个 Agent）               │
│  • 关键文件引用地图                                 │
├─────────────────────────────────────────────────────┤
│ Tier 2: SPECIALIZED AGENTS（专业 Agent）           │
│  • Code Reviewer / Network Protocol / Debug ...     │
│  • 领域专家，带专用 prompt + 上下文                 │
├─────────────────────────────────────────────────────┤
│ Tier 3: KNOWLEDGE BASE（冷记忆 — 按需加载）        │
│  • 子系统规格、架构文档、协议文档                    │
│  • MCP 检索服务，按需加载                           │
└─────────────────────────────────────────────────────┘
```

## 关键数据

| 指标 | 值 |
|------|-----|
| 知识/代码比 | ~24%（1 行文档 : 4 行代码）|
| 上下文总量 | ~26,000 行 |
| Agent 放大 | 2,801 prompts → 1,197 调用 → 16,522 轮交互 |

## 设计原则

1. **文档即基础设施** — 上下文文档是"活"的，不是被动参考
2. **写给 AI 看** — 用表格/代码块，不用自然语言
3. **热/冷记忆分离** — Constitution 始终加载，详细规格按需加载
4. **交叉验证** — 文档间相互引用，有 drift 检测脚本
5. **迭代生长** — 不是一开始就设计完美，而是从问题中长出来

## MCP 检索服务（Tier 3）

暴露 7 个工具：

| Tool | 用途 |
|------|------|
| `list_subsystems()` | 列出所有子系统 |
| `get_files_for_subsystem(subsystem)` | 获取子系统的关键文件 |
| `find_relevant_context(task)` | 模糊匹配任务到相关文件 |
| `get_context_files()` | 列出所有上下文文档 |
| `search_context_documents(query)` | 全文搜索 |
| `suggest_agent(task)` | 推荐用哪个专业 Agent |
| `list_agents()` | 列出所有 Agent 及触发条件 |

## Agent 路由机制

在 Constitution 中定义触发条件：

```python
AGENTS = {
    "coordinate-wizard": {
        "description": "Isometric coordinate and camera specialist",
        "triggers": ["camera", "isometric", "world-to-screen"],
        "model": "opus",
    },
}
```

AI Agent 会根据任务描述自动调用对应的专业 Agent。

## 案例：CLAUDE.md 结构

来自 case-study/CLAUDE.md（约 660 行）：

```markdown
# 项目概述
- 技术栈
- 代码质量标准
- 项目结构

# 任务管理（Slash Commands）
/start-task /finish-task /abandon-task

# 构建命令

# 架构概述
- ECS 模式
- 系统注册清单（Common Bug）
- 服务层
- 游戏状态机
- 网络同步

# 关键约定
- 文件组织
- 命名规范
- 数据文件

# 具体系统文档
- Ghost Mode
- Turbo System
- 装备系统
...

# MCP 工具使用指南
```

## 常见坑：系统注册

新系统必须注册到 `GameProjectGame.RegisterSystems()`，否则系统存在但永远不会运行。

## 对 fox + cat 架构的价值

| 问题 | 方案 |
|------|------|
| fox → cat 任务分发 | Constitution 里的 Agent 触发表 |
| cat 按需获取上下文 | MCP 工具按需检索 |
| 记忆不膨胀 | 热/冷记忆分离 |
| 协作规范化 | Constitution = 团队宪法 |

---

## 待研究

- [ ] 细化 Agent 触发表设计
- [ ] MCP 检索服务实现
- [ ] 与 MemOS 插件对比（记忆共享）
- [ ] 渐进式落地路径
