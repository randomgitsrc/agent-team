# TOOLS.md - Local Notes

## What Goes Here

- 关键文件或敏感信息
- 技能与技巧
- 典型工作流程
- 注意事项
- 能力地图（skill、mcp及主动应用、主动探索）

## Browser
You have access to a real web browser tool. Use the browser when:
- information may be outdated
- user asks to search or check websites
- verification is needed
- interaction with webpages is required

Browser capabilities:
- open URLs
- search the web
- read page content
- click elements
- extract information

Always prefer using the browser instead of guessing.

Profile: `openclaw` (CDP on port 18800, Chrome at `/usr/bin/google-chrome`)
Start script: `~/.start-openclaw-chrome.sh`

### 操作注意事项
- 打开新页面后**必须等待加载完成**再截图，否则只会截到空白/加载中状态
  - 方法：`act` with `{"kind": "wait", "timeMs": 3000}` 后再 screenshot
- 截图默认是当前视口（非全页），与用户看到的一致；fullPage=true 才是完整长页
- gateway 断线后浏览器工具会超时报错，需用户执行 `openclaw gateway restart` 恢复
- 截图后用 `message(action=send, media=<path>)` 发给用户，不要直接回复路径
- 表单输入用 `act` + `{"kind": "type", "ref": "...", "submit": true}`，ref 从 snapshot 获取

## Examples

### SSH
- home-server → 192.168.1.100，user: admin

### API Keys（路径）
- OpenAI / Gemini / Kimi: `~/.openclaw/.env`

### GitHub
- 用户名: randomgitsrc
- 仓库: videsmemory
- 远程: https://github.com/randomgitsrc/videsmemory.git
- 分支: main
- Token 存储: `~/.git-credentials`（credential store，权限600）

### TTS
- Preferred voice: "Nova"
- Default speaker: Kitchen HomePod

---

## 🤖 能力地图（2026-03-02 更新）

### 已安装 Skills（16个 ready）

| 分类 | Skill | 用途 |
|------|-------|------|
| 编码 | coding-agent | 复杂代码开发（spawn 子 agent） |
| | claude-code-skill | Claude Code 控制 |
| 搜索 | find-skills | 发现新 skills |
| | deepwiki | GitHub 代码研究 |
| | news-aggregator-skill | 新闻聚合（8源） |
| 安全 | healthcheck | 系统安全审计 |
| | skillvet | Skill 安全扫描 |
| 效率 | remind | 定时提醒 |
| | tmux | 终端交互控制 |
| 平台 | agent-reach | 推特/Reddit/YouTube等 |
| 工具 | clawhub | Skill 管理 |
| | mcporter | MCP 管理 |
| | skill-creator | 创建 skill |
| | weather | 天气查询 |
| 任务 | ceo-team | 专项任务模式 |

### MCP 服务
| 服务 | 用途 |
|------|------|
| github | GitHub API 操作 |
| context-mode | 本地代码执行/批量操作 |

### 场景 → 工具映射

| 场景 | 应该用什么 |
|------|------------|
| 查天气 | weather ✅ |
| 搜新闻 | news-aggregator-skill ✅ |
| 搜实时信息 | web_search / agent-reach |
| 查 GitHub 代码 | deepwiki / github-mcp |
| 复杂编码 | coding-agent / claude-code-skill |
| 安全审计 | healthcheck / skillvet |
| 定时提醒 | remind ✅ |
| 浏览器操作 | browser 工具 |
| 搜本地文档 | context-mode_search |
| 搜记忆 | memory_search |
| 读网页 | web_fetch |
| 装新 skill | clawhub |
| 发现新能力 | find-skills |

### 扩展方向（优先级）

| 建议接入 | 理由 | 优先级 |
|----------|------|--------|
| gog | 邮件+日历+文档，办公常用 | ⭐⭐⭐ |
| summarize | 摘要/转录通用强 | ⭐⭐⭐ |
| github skill | 本地 CLI，比 MCP 稳定 | ⭐⭐ |

### 行动计划

1. **遇到陌生场景时，主动说**"这个问题可以用 XX 解决"
2. 每周盘点能力边界 → 不需要，改为"每次装新 skill 时更新 TOOLS.md"
3. 新问题先想"有没有现成工具"，不知道时说"我可以学一下"

### 回答问题准则（2026-03-02 补充）

**不要直接给结论**，而是要有推理过程：

| 场景 | 应该怎么答 |
|------|------------|
| 问"要不要做" | 给建议 + 推理过程 + 替代方案 + 问"要我去执行吗" |
| 问"选哪个" | 给选项 + 推荐 + 理由 + 问"同意吗" |
| 问"能跑吗" | 验证 + 潜在问题 + 改进建议 |

---
