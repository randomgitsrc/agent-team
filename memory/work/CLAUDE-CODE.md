# Claude Code 协作指南

> **类型**: 工具使用指南  
> **更新**: 2026-02-28  
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

---

## 8. 经验建议（必读）

### 8.1 关于权限跳过

**必须**使用 `--dangerously-skip-permissions` 才能实现自动化：
- 非交互式 shell 无法处理确认提示
- 普通 `claude -p` 会卡住等待输入
- 这是设计如此，不是 bug

### 8.2 关于代理服务

`ANTHROPIC_BASE_URL` 可以指向兼容代理（如 Moonshot）：
- ✅ 基本代码生成可用
- ⚠️ 某些高级功能可能受限
- ⚠️ 需要测试验证具体功能

### 8.3 关于环境变量

`.env` 文件修改后**必须重启**才生效：
```bash
openclaw gateway restart
```
仅修改文件不重启，新会话仍用旧值。

### 8.4 关于浏览器测试

WSL2 网络隔离导致浏览器工具受限：
- ❌ 无法直接访问 `127.0.0.1` 服务
- ✅ Claude Code 可用 playwright/puppeteer 自测
- ✅ 文件截图后通过 message 发送查看

### 8.5 关于 skill 选择

不是所有 skill 都能工作：
- ❌ `openclaw-claude-code` 缺少后端服务
- ✅ `coding-agent` 是指导文档，可用
- ✅ 原生命令 `claude` 最可靠

**原则**：先试原生命令，再考虑 skill。

### 8.6 关于任务拆解

复杂任务要拆解，Claude Code 不是万能的：
- ✅ "创建一个登录页面" → 好
- ❌ "创建一个完整的电商网站" → 太大，会超时或失败
- ✅ 拆分为：首页 → 商品列表 → 购物车 → 结算

### 8.7 关于迭代优化

第一次结果不满意很正常：
- 让 Claude Code 继续修改具体点
- 提供明确的优化方向
- 多次迭代直到满足

**示例**：
```bash
# 第一轮
claude --dangerously-skip-permissions "创建按钮"

# 第二轮：优化
claude --dangerously-skip-permissions "按钮颜色太淡，改成深蓝色，字体加大"

# 第三轮：继续优化
claude --dangerously-skip-permissions "添加悬停效果，鼠标放上去有阴影"
```

---

## 9. 实战经验（2026-02-28）

### 9.1 成功案例：21点游戏

**项目**: 单文件 Python 21点纸牌游戏
**耗时**: 约 50 分钟（含踩坑）
**迭代**: 1 次通过

**调用方式**:
```bash
# 直接起 Claude CLI（不用 skill）
cd ~/project/blackjack
claude --dangerously-skip-permissions '创建 21 点游戏...'
```

**关键成功要素**:
1. 项目目录先 `git init`（Claude Code 需要 git 仓库）
2. `--dangerously-skip-permissions` + 交互时输入 `1` 选择信任文件夹
3. 任务粒度合适（单文件，规则清晰）

### 9.2 失败案例：迷宫游戏（更早）

**问题**: Claude Code 2.1.62 安全检查加强
**现象**: `--dangerously-skip-permissions` 仍卡在 "review what's in this folder first"
**解决**: 
- 输入数字 `1` 选择 "Yes, trust this folder" 可绕过
- 或先手动创建目录和文件，Claude Code 只负责修改

### 9.3 重要教训

| 教训 | 说明 |
|------|------|
| **不手改代码** | 让 Claude Code 改，我手改容易引入新 bug |
| **双保险通知** | prompt 末尾加 `openclaw system event --mode now`，防止后台任务跑完我不知道 |
| **用原生命令** | `claude --dangerously-skip-permissions` 比 skill 可靠 |
