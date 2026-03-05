# Agent Team 研究笔记

> 更新: 2026-03-05
> 状态: 持续研究中

---

## 一、竞品/参考项目研究

### 1. Control-Center (BEKO2210)

**定位**: Claw Bot 编排仪表盘

**功能模块**:
- Dashboard / Task Board (Kanban) / Content Pipeline / Calendar
- Memory Bank / Team Structure / Digital Office / Shell Themes
- Claw Manager / Setup Wizard

**连接协议**: WebSocket / REST API / MQTT

**状态**: v1.4.0

**研究状态**: 未完全研究透，GitHub 仓库可能已删除/改名

### 2. Command Center (jontsai) ⭐ 轻量级

**定位**: AI Agent 命令控制面板

**技术特点**:
- 零依赖（纯 Vanilla JS + Node.js）
- ~200KB，无需构建步骤
- SSE 实时推送（2秒更新）
- 单 API 端点

**功能**:
- Session Monitoring - 实时会话
- LLM Fuel Gauges - Token 使用/成本
- System Vitals - CPU/内存/磁盘
- Cron Jobs - 定时任务
- Cerebro Topics - 自动话题标记
- Memory Browser - 记忆浏览器
- Cost Breakdown - 成本分析

**部署**:
```bash
npx clawhub@latest install command-center
```

### 3. openclaw-dashboard (mudrii)

**定位**: 零依赖命令中心

**核心功能**:
- Top Metrics (CPU/RAM/Disk + Gateway状态)
- 系统健康 / 成本追踪 / Cron监控
- 活跃会话 / Sub-Agent活动
- AI Chat (自然语言查询)

**技术特点**:
- 零依赖 (纯HTML/CSS/JS + Python stdlib)
- 单文件 Go 编译 (6.2MB)
- 本地运行

**可借鉴点**:
- 成本追踪
- Sub-Agent 活动监控
- 系统健康检查
- AI Chat

### 3. mission-control (crshdn) ⭐ 最重要

**定位**: AI Agent 编排仪表盘

**核心设计**:

#### 3.1 任务生命周期 (6阶段)
```
INBOX → ASSIGNED → IN_PROGRESS → TESTING → REVIEW → DONE
```

| 状态 | 说明 |
|------|------|
| INBOX | 新任务待处理 |
| ASSIGNED | 已分配给 Agent |
| IN_PROGRESS | 工作中 |
| TESTING | 自动化质量门 (浏览器测试、CSS验证) |
| REVIEW | 通过测试，等待人工审批 |
| DONE | 完成并审批 |

#### 3.2 Agent 协作 API

| API | 作用 |
|-----|------|
| `POST /api/tasks/{id}/subagent` | 注册子 Agent |
| `POST /api/tasks/{id}/activities` | 记录活动 |
| `POST /api/tasks/{id}/deliverables` | 注册交付物 |
| `PATCH /api/tasks/{id}` | 更新状态 |

#### 3.3 活动类型

- `spawned` - 子 Agent 启动
- `updated` - 进度更新
- `completed` - 工作完成
- `file_created` - 创建交付物
- `status_changed` - 状态变更

#### 3.4 核心团队 (4 Agent)

| Agent | 角色 |
|-------|------|
| Builder | 开发者 🛠️ |
| Tester | 测试 🧪 |
| Reviewer | 审查 🔍 |
| Learner | 学习 📚 |

#### 3.5 学习知识循环

- Learner 捕获转换结果
- 注入未来调度

#### 3.6 失败回环路由

- 阶段失败自动回退
- 记录详细原因

---

## 二、我们的差异化定位

| 项目 | 定位 |
|------|------|
| Control-Center | Claw Bot 编排 |
| openclaw-dashboard | 系统监控 |
| mission-control | 任务编排 |
| **Agent Team** | **多Agent协作 + 流程编排 + 自检迭代** |

**我们的核心价值**:
1. 流程编排（可配置模板）
2. 状态机机制
3. 消息协议
4. Agent 角色管理
5. 自检 + 迭代

---

## 三、可借鉴设计

### 3.1 任务生命周期
参考 mission-control 的 6 阶段，可简化为我们的版本

### 3.2 交付物注册
确保交付物真实存在，避免"已完成但没文件"

### 3.3 质量门 TESTING
自动化测试阶段

### 3.4 核心 Agent 角色
Builder / Tester / Reviewer / Learner

### 3.5 活动日志
追踪每一步操作

---

## 四、后续研究

- [ ] mission-control 源码深入分析
- [ ] 4 Agent 的 prompt 设计
- [ ] 消息协议设计
- [ ] 流程模板数据结构
- [ ] 自检机制设计
