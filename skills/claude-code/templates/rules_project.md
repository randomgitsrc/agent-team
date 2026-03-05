# 项目规则

> 由阿九管理，请勿手动修改

## 开发规范

- 使用 Composition API
- 所有 API 调用走 apiClient.ts
- 禁止在组件内直接 fetch

## 目录结构

```
src/
├── components/    # Vue 组件
├── api/          # API 接口
├── utils/        # 工具函数
└── ...
```

## 测试要求

- 完成后必须自己测试验证
- 浏览器自动化可能有缓存，必要时重启服务
