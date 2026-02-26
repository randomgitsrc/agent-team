# TOOLS-GUIDE.md - 工具使用指南

> **适用范围**: 阿九工作区  
> **说明**: 此文件为脱敏版，不含敏感信息（SSH/IP/Key 位置等）

---

## Git 工作流

- **分支**: main
- **提交规范**: `feat/fix/docs/chore:` 前缀
- **提交前必检查**: `git status`
- **标准消息格式**:
  ```
  feat(scope): description
  
  Refs: related-files
  ```

## 常用路径

| 目录 | 用途 |
|------|------|
| `docs/` | 规范文档 |
| `scripts/` | 工具脚本 |
| `projects/` | 项目交付物 |
| `memory/work/` | 工作记忆 |
| `memory/private/` | 私密记忆 |

## 标准操作

| 操作 | 命令 |
|------|------|
| 部署 | `./deploy.sh [local\|staging\|prod]` |
| 测试 | `./test.sh` |
| 日志 | `./logs.sh` |

## 文档规范

- Markdown 格式
- 标题层级：# ## ###
- 表格用于结构化数据
- 代码块标注语言

---

**敏感操作**（API key、SSH、部署到生产等）请咨询 CEO
