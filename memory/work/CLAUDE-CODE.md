# Claude Code 协作指南

> **类型**: 工具使用指南  
> **更新**: 2026-02-27  
> **关联**: [工作流手册 - 导航](../WORKFLOW.md)

---

## 1. 模式概述

**"我设计 → Claude Code 实现 → 我审查"** 三步循环

```
老板需求
   ↓
阿九：拆解需求 + 设计架构 + 编写提示词
   ↓
Claude Code：编写代码 + 自测验证
   ↓
阿九：代码审查 + 质量把关 + 交付
```

---

## 2. 核心命令

### 2.1 基本调用

```bash
# 自动执行（推荐）
claude --dangerously-skip-permissions "你的任务描述"

# 指定工作目录
cd ~/project/xxx && claude --dangerously-skip-permissions "任务"
```

### 2.2 后台长任务

```bash
bash pty:true \
    workdir:~/project \
    background:true \
    timeout:300 \
    command:"claude --dangerously-skip-permissions '长任务'"
```

### 2.3 参数说明

| 参数 | 作用 | 必需场景 |
|------|------|----------|
| `--dangerously-skip-permissions` | 跳过所有确认提示 | 自动化执行 |
| `pty:true` | 伪终端模式 | Claude Code 需要 TTY |
| `background:true` | 后台运行 | 长任务不阻塞 |
| `timeout:300` | 超时限制（秒） | 防止无限等待 |

---

## 3. 环境配置

### 3.1 必需变量

写入 `~/.openclaw/.env`，OpenClaw 自动加载：

```bash
ANTHROPIC_API_KEY=sk-ant-xxx

# 可选：使用代理（如 Moonshot）
ANTHROPIC_BASE_URL=https://api.moonshot.cn/anthropic
```

### 3.2 生效方式

```bash
# 修改 .env 后重启
cd ~/.openclaw/workspace && openclaw gateway restart
```

---

## 4. 最佳实践

### 4.1 DO（推荐）

- ✅ 任务拆解：一次一个明确目标
- ✅ 让 Claude 自测：用 playwright/puppeteer 截图验证
- ✅ 迭代优化：不满意继续修改直到满足
- ✅ 项目位置：`~/project/ccworkspace/`

### 4.2 DON'T（避免）

- ❌ 一行命令能完成的事（自己做更快）
- ❌ `~/clawd` 工作区（SKILL.md 规定禁止）
- ❌ 简单文件读取（直接用阿九的 read 工具）

---

## 5. 验证案例

### 案例：lucky-button 项目

```bash
# 创建 HTML 页面
cd ~/project/ccworkspace/lucky-button
claude --dangerously-skip-permissions "创建单文件HTML，包含按钮和两种视觉效果..."

# 添加键盘快捷键（迭代优化）
claude --dangerously-skip-permissions "添加空格键和R键快捷键..."
```

**成果**：
- 19KB 完整 HTML 页面
- 两种命运视觉效果（新世界 vs 末日）
- 键盘快捷键支持
- 零手动编码

---

## 6. 踩坑记录

### 6.1 openclaw-claude-code skill ❌

**尝试安装**: `clawhub install openclaw-claude-code`

**问题**: 缺少后端 API 服务
- skill 需要连接 `http://127.0.0.1:18795`
- 后端服务未提供/未开源
- 导致无法使用

**结论**: 暂时放弃，使用原生命令 `claude --dangerously-skip-permissions` 替代

---

## 7. 工作区配置

### 7.1 目录结构

```
~/.openclaw/workspace/          # 阿九主场（策略、文档）
└── projects/code/  → 软链接 →  ~/project/ccworkspace/  # Claude Code 主场
```

### 7.2 软链接创建

```bash
mkdir -p ~/.openclaw/workspace/projects
ln -sf ~/project/ccworkspace ~/.openclaw/workspace/projects/code
```

**作用**：
- 阿九通过软链接看到 Claude Code 的代码（方便审查）
- Claude Code 看不到核心文件（安全隔离）
- 项目代码统一管理
