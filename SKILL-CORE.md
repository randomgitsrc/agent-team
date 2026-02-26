# 🎯 核心技能索引

> **版本**: v2.0.0  
> **更新**: 2026-02-25 22:03  
> **策略**: 极简核心 + 按需安装  
> **Token占用**: <0.2KB

---

## 🔧 核心技能（9个）

### 🎯 高频必用
| Skill | 关键词 | 用途 |
|-------|--------|------|
| **github** | GitHub/仓库/PR/issue | GitHub仓库操作、PR管理、issue处理 |
| **weather** | 天气/温度/预报 | 天气查询和预报 |
| **healthcheck** | 安全/审计/防火墙 | 系统安全审计和加固 |
| **skill-creator** | 创建/开发skill | 创建和开发新skill |

### 🛠️ 工具支持
| Skill | 关键词 | 用途 |
|-------|--------|------|
| **clawhub** | 搜索/安装/技能 | 从clawhub.com管理技能 |
| **tmux** | tmux/远程/终端 | 远程服务器管理 |
| **coding-agent** | 代码/开发/重构 | 复杂代码开发任务 |

### 🏠 工作区自定义
| Skill | 关键词 | 用途 |
|-------|--------|------|
| **ceo-team** | 复杂/长任务/专项 | 专项任务处理模式 |
| **find-skills** | 找skill/功能 | 帮助发现和安装技能 |
| **remind** | 提醒/X分钟后/X小时后 | 定时提醒，时间到发 Telegram 消息 |

---

## 📦 扩展方式

### 需要其他功能时：
```
1. "用clawhub搜索[功能名]"
2. 查看搜索结果
3. "安装[skill名]"
4. 临时使用
5. 可选：用完删除
```

### 示例：
```
用户：处理PDF文件
→ 当前无pdf skill
→ "用clawhub搜索pdf"
→ 找到pdf-extract skill
→ "安装pdf-extract"
→ 使用
→ 可选："删除pdf-extract"
```

---

## ⚡ 使用规则

### 自动匹配
- 查询包含关键词 → 推荐对应skill
- 例如："GitHub仓库状态" → github

### 手动调用
- "用github查看PR状态"
- "用healthcheck做安全审计"
- "用ceo-team开发这个功能"

### 复合任务
- "获取天气并生成报告" → weather + 文档处理
- "GitHub issue修复" → github + coding-agent

---

## 📊 精简效果

```
优化前：
- 57个skill目录
- 12KB详细索引
- 维护成本高

优化后：
- 9个核心skill
- <0.2KB极简索引
- 维护成本极低
```

### Token节省：
```
原索引：12KB
新索引：<0.2KB
节省：11.8KB（98.3%）
```

---

## 🔄 恢复说明

### 需要已删除的skill时：
1. **临时安装**：用clawhub重新安装
2. **从备份恢复**：`backup/skills-20260225/`
3. **自定义开发**：用skill-creator创建

### 备份位置：
- 系统skill备份：`backup/skills-20260225/system-skills-backup.tar.gz`
- 自定义skill备份：`backup/skills-20260225/custom-skills-backup.tar.gz`

---

**最后更新**: 2026-02-25  
**维护者**: 阿九  
**原则**: 少即是多，按需安装