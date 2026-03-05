# Agent Team - 多Agent协作任务调度系统

> **版本**: 0.1.0 (概念验证)
> **更新**: 2026-03-05
> **状态**: 构思阶段

## 1. 愿景

打造一个 **Agent 协作操作系统**，用于：
- 管理 AI Agent 团队的任务分配与执行
- 支持任务拆解、并行/串行调度
- 流程编排与自检
- 逐步迭代，从 MVP 到专业化

## 2. 核心概念

### 2.1 任务状态机

| 状态 | 说明 |
|------|------|
| pending | 待处理 |
| assigned | 已分配给 Agent |
| in_progress | 执行中 |
| completed | 完成 |
| failed | 失败 |
| waiting_retry | 等待重试 |

### 2.2 任务类型

| 类型 | 说明 |
|------|------|
| simple | 简单任务，Agent 直接执行 |
| complex | 复杂任务，需要团队协作 |
| sequential | 串行任务，上游完成后下游才能执行 |
| parallel | 并行任务，多个 Agent 同时执行 |

### 2.3 Agent 类型

| 类型 | 来源 |
|------|------|
| internal | OpenClaw subagent |
| external | 外部 Agent（Claude Code、Codex 等） |

### 2.4 任务关系

```
父任务
├── 子任务A (串行)
├── 子任务B (并行)
└── 子任务C (并行)
```

## 3. 核心功能

### 3.1 任务管理

- [ ] 任务拆解（我或专门 Agent 分析需求，生成子任务列表）
- [ ] 任务类型标记（simple/complex/sequential/parallel）
- [ ] 优先级设置（high/medium/low）
- [ ] 依赖关系（阻塞/前置任务）
- [ ] 任务状态流转

### 3.2 Agent 团队管理

- [ ] Agent 池（待命 Agent 列表）
- [ ] Agent 注册（内部 Agent + 外部 Agent）
- [ ] Agent 提示词管理
- [ ] Agent 状态（在线/忙碌/离线）

### 3.3 技能管理

- [ ] Skill 注册表
- [ ] Skill 分配给 Agent
- [ ] 任务与 Skill 匹配

### 3.4 流程编排

- [ ] 任务流程定义
- [ ] 上下游调度
- [ ] 执行顺序控制

### 3.5 组织自检

- [ ] 执行前验证
- [ ] 异常检测
- [ ] 失败重试机制（N 次重试）

### 3.6 重试机制

```
上游任务失败 → 更新父任务内容 → 父任务重新执行 → 下游任务执行
最大重试 N 次 → 任务失败
```

## 4. 技术架构

### 4.1 技术选型

| 层级 | 技术 |
|------|------|
| 任务管理 | TaskFlow（复用） |
| Agent 调度 | OpenClaw subagent / sessions_spawn |
| 持久化 | TaskFlow 数据库 |
| 前端 | Vue 3 + TaskFlow Web |

### 4.2 模块设计

```
agent-team/
├── tasks/          # 任务管理（复用 TaskFlow）
├── agents/         # Agent 团队管理
├── skills/         # 技能管理
├── flows/          # 流程编排
└── scheduler/     # 调度引擎
```

## 5. 迭代计划

### Phase 1: MVP（1-2 Agent）

**目标**：你 + 我，我用 subagent 打下手

**功能**：
- 任务拆解（手动/半自动）
- 任务分配给我或 subagent
- 简单状态追踪

### Phase 2: 团队版（3-5 Agent）

**目标**：多个待命 Agent

**功能**：
- Agent 池管理
- 任务并行/串行调度
- 基础重试机制

### Phase 3: 专业版

**目标**：完整流程编排

**功能**：
- 技能注册与匹配
- 流程自检
- 失败重试优化
- 统计分析

## 7. 已确认

### 7.1 Agent 来源

| Agent | 类型 | 说明 |
|-------|------|------|
| 我（阿九） | internal | 直接执行 |
| OpenClaw subagent | internal | 临时召唤 |
| Claude Code | external | 编码专用 |
| Codex | external | 编码专用 |
| 其他 Agent | external | 可扩展 |

### 7.2 任务拆解流程

```
需求 → 任务拆解 Agent → 拆解结果
                        ↓
                  我确认/头脑风暴/迭代
                        ↓
                  最终任务列表
```

- 专门的拆解 Agent 分析需求
- 拆解不明白的 → 沟通迭代
- 复杂的 → 头脑风暴确认

### 7.3 重试机制

- 可调整参数，不定死
- 根据任务类型灵活配置

### 7.4 MVP 阶段核心功能

| 功能 | 说明 |
|------|------|
| 任务拆解 | 专门的 Agent 拆解 → 我确认/头脑风暴 |
| 流程编排 | 串行 / 并行 / 依赖关系 |
| 状态机 | pending → assigned → in_progress → completed / failed |
| Agent 分配 | 按类型分配给不同 Agent |
| 任务模板 | 定义必填步骤，没走完不能提交 |
| 检查点 | 每个阶段有检查点，必须通过才能进入下一阶段 |

## 8. 执行策略

### 8.1 MVP 阶段：先用现有 TaskFlow

理由：
1. TaskFlow 已成熟，能直接用
2. 先跑通协作流程，再考虑系统化
3. 流程跑通后，再开发专门的调度系统

### 8.2 TaskFlow 项目结构

```
项目：Agent Team
├── Phase 1: 协作流程设计
│   ├── 任务：设计 Agent 协作流程
│   ├── 任务：定义 Agent 角色（拆解/执行/验证）
│   └── 任务：用 subagent 试点
├── Phase 2: 任务拆解 Agent
│   └── ...
└── Phase 3: 调度系统开发
    └── ...
```

### 8.3 后续

当 TaskFlow 管理不过来时，再开发专门的 Agent Team 系统。

---

*持续迭代中...*
