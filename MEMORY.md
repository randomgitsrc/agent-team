# 🧠 记忆索引

> **版本**: v5.0.0 — 摘要加载模式  
> **生效**: 2026-02-25  
> **提炼**: 每日23:45

## 架构
1. **私密记忆** (`private/`) - 战略、身份、用户
2. **工作记忆** (`work/`) - 项目、任务
3. **工作日志** (`daily/`) - 每日记录

## 加载策略
### 基础加载（摘要）
- `PROJECT-SNAPSHOT.md` — 项目快照
- `STRATEGY-SUMMARY.md` — 战略摘要  
- `MEMORY-SNAPSHOT.md` — 架构快照

### 按需加载
- `memory/private/STRATEGY.md` — 完整战略
- `memory/work/PROJECT.md` — 完整项目
- `memory/daily/YYYY-MM-DD.md` — 今日日志

## 自动化
- **记忆提炼**: 每日23:45（提取关键决策）
- **心跳检查**: 每30分钟（任务监控）
- **Git提交**: 每日03:00（自动备份）

## Token优化
```
原体系: 15-18KB
现目标: 3-4KB
节省: 11-14KB（73-78%）
```

---
**详细**: 见 `AGENTS.md`