# 工作流手册

> **类型**: 索引  
> **更新**: 2026-03-02

## 工作流索引

| 工作流 | 状态 | 文档 |
|--------|------|------|
| Claude Code 协作 | ✅ 完善 | [CLAUDE-CODE.md](./CLAUDE-CODE.md) |
| 记忆提炼 | ⚙️ 建设中 | 脚本: `scripts/memory_distill_simple.sh` → 我审核 → 根目录 STRATEGY.md |
| 每日简报 | ⚙️ 完善中 | 脚本: `daily-news.sh` |

---

## 新增工作流

如需添加新工作流：

1. 创建流程文档（放在 memory/work/ 或 docs/）
2. 添加索引条目到本文件
3. 如需脚本，写入 scripts/ 目录

---

## 流程规范

- **脚本**：放在 `scripts/` 目录
- **报告/素材**：放在 `memory/logs/reports/`
- **最终文件**：需要我审核后写入正式位置
