# 🧠 记忆索引

> **版本**: v5.0.0 — 摘要加载模式  
> **生效**: 2026-02-25  
> **提炼**: 每日23:45

## 架构
1. **私密记忆** (`private/`) - 战略、身份、用户
2. **工作记忆** (`work/`) - 项目、任务
3. **工作日志** (`daily/`) - 每日记录

## 加载策略
### 自动加载（workspace根目录，OpenClaw注入）
- SOUL.md / USER.md / IDENTITY.md / AGENTS.md / MEMORY.md
- Skill列表（系统注入 available_skills）

### 按需加载（需要时主动读取）
- `memory/private/STRATEGY.md` — 完整战略
- `memory/work/PROJECT.md` — 完整项目
- `memory/work/TODO.md` — 任务清单
- `memory/daily/YYYY-MM-DD.md` — 当日日志

## 自动化
- **记忆提炼**: 每日23:45（提取关键决策）
- **心跳检查**: 每30分钟（任务监控）
- **Git提交**: 每日03:00（自动备份）

---
**详细**: 见 `AGENTS.md`