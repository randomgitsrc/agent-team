# Project Rules - Claude Code 开发规范

> **版本**: 1.0.0  
> **更新**: 2026-03-04

## 项目通用规则

### OpenClaw 工作区
- 所有项目放在 `~/projects/personal/<项目名>/`
- 禁止在其他位置创建项目

### 前端开发
- 使用 Composition API
- 所有 API 调用走 apiClient.ts
- 禁止在组件内直接 fetch
- 组件文件使用 Vue 3 SFC 规范

### 后端开发
- 使用 TypeScript
- 优先使用现有的 service 层
- API 路由放在 routes/ 目录

### 测试规范
- 浏览器自动化可能有缓存/延迟，必要时重启服务
- 手动测试比自动化更可靠
- 完成后必须自己实测验证再交付

---

## OpenClaw 特定规则

### 目录结构
```
~/.openclaw/workspace/
├── skills/           # 技能定义
├── memory/           # 记忆存储
│   ├── work/         # 项目记忆
│   └── daily/        # 每日日志
├── projects/         # 项目软链接（如需要）
└── scripts/         # 工具脚本
```

### 调用 Claude Code
- 优先使用 bg_task.sh 后台运行
- 调用前读取 CLAUDEMODEL 环境变量
- 大改动用三阶段模式（Planner/Executor/Reviewer）

---

_维护: 阿九_
