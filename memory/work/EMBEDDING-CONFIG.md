# Embedding 供应商配置参考

> 用途: OpenClaw memory_search 向量模型配置  
> 更新: 2026-02-27

## 供应商对比

| 供应商 | 免费额度 | 价格 | 速度 | 质量 | 推荐场景 |
|--------|---------|------|------|------|---------|
| **Gitee AI** | 需购买资源包 | 低 | 中 | 高 | 国产合规、长期稳定使用 |
| **SiliconFlow** | 无免费 | 极低 | 快 | 高 | 成本敏感、大量数据 |
| **阿里云百炼** | 100万 token (90天) | 中 | 快 | 高 | 国内大厂背书 |
| **Jina AI** | 100万/月 | 免费档够用 | 快 | 中 | 小用量、快速验证 |

## Gitee AI 配置（当前使用）

```json
{
  "memorySearch": {
    "enabled": true,
    "sources": ["memory"],
    "provider": "openai",
    "remote": {
      "baseUrl": "https://ai.gitee.com/v1",
      "apiKey": "sk-xxxx"
    },
    "model": "Qwen3-Embedding-8B"
  }
}
```

**⚠️ 注意**: 模型名称是 `Qwen3-Embedding-8B`，不是 `Qwen3-VL-Embedding-8B`（VL 是多模态版）。

**验证命令**:
```bash
curl https://ai.gitee.com/v1/embeddings \
  -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $API_KEY" \
  -d '{
    "model": "Qwen3-Embedding-8B",
    "input": "测试文本",
    "dimensions": 1024
  }'
```

## SiliconFlow 配置（备选）

```json
{
  "memorySearch": {
    "enabled": true,
    "provider": "openai",
    "remote": {
      "baseUrl": "https://api.siliconflow.cn/v1",
      "apiKey": "sk-xxxx"
    },
    "model": "BAAI/bge-m3"
  }
}
```

## 故障排查

| 现象 | 原因 | 解决 |
|------|------|------|
| `disabled: true` | 配置错误 | 检查 baseUrl、model 名称 |
| `timeout after 60s` | 端点不通 | 用 curl 测试连通性 |
| `0 results` | 索引未建立 | 删除 `memory/main.sqlite` 重启 |

## 相关脚本

- **清理 session**: `scripts/cleanup_sessions.sh`
- **记忆提炼**: `scripts/memory_distill_simple.sh`
