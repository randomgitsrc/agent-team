# Claude Code 技能

> **类型**: 编程开发工具  
> **版本**: 3.0.0  
> **更新**: 2026-03-05

## 触发条件

当用户要求以下操作时自动加载：
- 调用 Claude Code 进行开发
- 编程、开发，写代码
- 用 claude code / codex / claude 开发

---

## 1. 核心原则

1. **所有代码修改必须通过 Claude Code 执行**，禁止自己用 edit/write 工具写代码
2. **所有功能开发必须先写 SPEC.md 确认方案再调用 Claude Code 进行开发**
3. **调用 Claude Code 必须用 bg_task.sh 包装**，确保可靠通知

### 强调：
- 禁止直接用 edit/write 工具改代码
- 禁止不经 plan mode 直接让 Claude Code 写

---

## 2. 调用命令模板

### 获取模型（每条命令前执行）

### Planning（前台）、plan mode、计划模式
```bash
cd ~/projects/personal/<项目名>
# important
claude -p --dangerously-skip-permissions '<prompt>'
```

### 执行开发（后台，推荐）
```bash
cd ~/projects/personal/<项目名>
# important
bash ~/.openclaw/workspace/scripts/bg_task.sh "任务描述" claude -p --dangerously-skip-permissions '<prompt>'
```

### 调用后检查清单
1. 等待 bg_task.sh 通知
2. 检查实现是否完整（函数、API、样式等）
3. 实测功能是否正常
4. **积极想办法解决问题**，不要轻易放弃
5. 修复 2 次仍有问题 → 停止、汇报情况、说明卡点

---

## 3. 开发流程（标准模式）

### 流程
```
需求 → Planning（只沟通不写代码）→ 确认方案 → 后台开发 → 验收 → 交付
         ↑                          │
         └──────── 有疑问────────────┘
```

### Phase 1: Planning（必做）
Claude Code 只分析需求、问问题、给出方案草稿，**不写代码**

```bash
cd ~/projects/personal/<项目名>
MODEL=$(grep CLAUDEMODEL ~/.openclaw/.env | cut -d'=' -f2 | tr -d ' ')

# 前台调用，可以交互
claude -p --dangerously-skip-permissions --model "$MODEL" "
你是开发顾问。
用户需求：<描述需求>
请分析需求，输出方案草稿。
不要写代码，只输出分析和方案。
有疑问先记录，最后一起问。
"
```

### Phase 2: 确认方案
- 我把方案给老板看
- 老板确认后形成文档 SPEC.md
- 有问题 → 回到 Phase 1

### Phase 3: 执行开发
方案明确后，用 bg_task.sh 后台开发：

```bash
cd ~/projects/personal/<项目名>
MODEL=$(grep CLAUDEMODEL ~/.openclaw/.env | cut -d'=' -f2 | tr -d ' ')
bash ~/.openclaw/workspace/scripts/bg_task.sh "任务描述" claude -p --dangerously-skip-permissions --model "$MODEL" '<prompt>'
```

### Phase 4: 验收
- 等待 bg_task.sh 通知
- **必需自己实测验证**，不能只看回报
- **Claude Code 说"完成"不等于真正完成**，必须检查实现是否完整
- 交付老板

## 4. 代码问题处理流程

### 原则
```
1. 代码问题 → 不自己改
2. 先 Claude Code plan mode → 分析问题
3. 确认后 → 让 Claude Code 开发
4. 1轮修不好 → 我和Claude Code 一起再 plan 再修复
5. 2轮仍然没修改好，给老板汇报情况
```

### 具体流程
1. 遇到代码问题 → 不自己动手
2. 调用 Claude Code plan mode 分析问题原因
3. 我确认分析结果后，让 Claude Code 修复
4. 如果修复 2 次仍有问题 → 停止，汇报情况，说明卡点
5. 你们一起再 plan，再让 Claude Code 修复

---

## 5. 项目结构（记忆管理）

采用 Claude Code 官方 `.claude/` 目录结构：

```
~/projects/personal/<项目名>/
├── .claude/
│   ├── CLAUDE.md         # 主入口（@import 下面文件）
│   ├── session.md        # L1: 当前任务上下文
│   ├── rules/
│   │   └── project.md   # L2: 项目规则
│   └── lessons.md       # L3: 踩坑经验
└── ...
```

### Session 管理
- 开始任务 → 创建/更新 session.md
- 任务结束 → 有价值经验追加到 lessons.md

---

## 6. 踩坑记录

### 2026-03-05: Claude Code 超时但代码已写入
- **问题**: Claude Code 超时退出，但代码实际写入了
- **解决**: 用 bg_task.sh 包装，依赖通知判断完成状态

### 2026-03-04: .env 换行符问题
- **问题**: CRLF 导致环境变量读取异常
- **解决**: sed -i 's/\r$//' ~/.openclaw/.env

### 2026-03-04: Claude Code 认证失败
- **问题**: 默认走 openai provider
- **解决**: 用 --model combo-code

---

## 7. 规则

1. **不要用技术术语轰炸用户**
2. **如果用户走错路，要 push back**
3. **诚实面对限制**
4. **快速前进，但要让我能跟上**
5. **不只是要能工作，要能展示给别人**
6. **不确定的事说不知道，不要编造**

---

_维护: 阿九_
