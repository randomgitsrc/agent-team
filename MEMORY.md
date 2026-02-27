# 🧠 记忆索引

> **版本**: v5.0.0 — 摘要加载模式  
> **生效**: 2026-02-25  
> **提炼**: 每日23:45

## 架构
1. **私密记忆** (`private/`) - 战略、身份、用户
2. **工作记忆** (`work/`) - 项目、任务
3. **工作日志** (`daily/`) - 每日记录
4. **Session 临时记录** (`~/.openclaw/sessions/`) - 自动清理，非 Git 追踪

## Session 文件管理（安全隔离）
OpenClaw 自动生成 `memory/20*.md` 对话记录，可能包含敏感信息（API key）。

**处理方案**（2026-02-27 更新）：
- **生成位置**: `workspace/memory/20*.md`
- **自动转移**: 每天 03:00 移动到 `~/.openclaw/sessions/`
- **保留期限**: 7 天自动删除
- **Git 排除**: `.gitignore` 已配置 `memory/20*-*.md`

**手动清理**:
```bash
~/.openclaw/workspace/scripts/cleanup_sessions.sh
```

**重要**: 如需长期保留对话内容，提炼后写入 `memory/daily/` 或 `memory/work/`，勿直接依赖 session 文件。

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