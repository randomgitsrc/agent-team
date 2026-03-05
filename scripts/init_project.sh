#!/bin/bash
# Claude Code 项目记忆初始化脚本
# 用法: init_project.sh <项目路径> [项目名]

set -e

PROJECT_PATH="$1"
PROJECT_NAME="$(basename "$PROJECT_PATH")"

if [ -z "$PROJECT_PATH" ]; then
    echo "用法: $0 <项目路径> [项目名]"
    exit 1
fi

CLAUDE_DIR="$PROJECT_PATH/.claude"

if [ -d "$CLAUDE_DIR" ]; then
    echo "⚠️ .claude 目录已存在"
    read -p "是否覆盖? (y/N): " confirm
    if [ "$confirm" != "y" ]; then
        exit 0
    fi
fi

echo "📁 创建 .claude/ 目录结构..."

mkdir -p "$CLAUDE_DIR/rules"

# 复制模板
TEMPLATE_DIR="$HOME/.openclaw/workspace/skills/claude-code/templates"

# session.md
cat > "$CLAUDE_DIR/session.md" << 'EOF'
# 当前任务

## 任务描述
（任务开始时填写）

## 进度
- [ ] （步骤1）
- [ ] （步骤2）

## 上下文
（任何需要记住的上下文）

## 完成标准
（如何算完成）
EOF

# lessons.md
cat > "$CLAUDE_DIR/lessons.md" << EOF
# 项目踩坑记录

## $(date +%Y-%m-%d)

（新增记录格式）
- **问题**: 
- **解决**: 
- **教训**: 
EOF

# rules/project.md
cat > "$CLAUDE_DIR/rules/project.md" << EOF
# 项目规则 - $PROJECT_NAME

## 开发规范
- 使用 Composition API
- 所有 API 调用走 apiClient.ts
- 禁止在组件内直接 fetch

## 测试要求
- 完成后必须自己测试验证
EOF

# CLAUDE.md 主入口
cat > "$CLAUDE_DIR/CLAUDE.md" << 'EOF'
# 项目记忆

@rules/project.md

@session.md

---

@lessons.md
EOF

echo "✅ 完成！目录结构:"
tree "$CLAUDE_DIR" 2>/dev/null || ls -la "$CLAUDE_DIR"

echo ""
echo "📝 下一步:"
echo "   1. cd $PROJECT_PATH"
echo "   2. claude --dangerously-skip-permissions /init"
echo "   3. 开始开发"
