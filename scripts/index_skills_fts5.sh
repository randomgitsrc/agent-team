#!/bin/bash
# 定时索引 skill 文档到 FTS5
# 用途：精确搜索技能配置、命令参数

SKILLS_DIRS=(
    "/home/nmaster/.openclaw/workspace/skills"
    "/home/nmaster/.nvm/versions/node/v22.22.0/lib/node_modules/openclaw/skills"
)

SOURCE="skills"

echo "[$(date)] Starting skills indexing..."

for dir in "${SKILLS_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "Indexing $dir..."
        find "$dir" -name "*.md" -type f | while read -r file; do
            # 跳过非 skill 文件
            if [[ "$file" == *"SKILL.md" ]] || [[ "$file" == *"README.md" ]]; then
                # 提取相对路径作为标签
                label=$(basename "$file" .md)
                mcporter call context-mode.index "path:$file" "source:$SOURCE" 2>/dev/null
                echo "  - Indexed: $label"
            fi
        done
    fi
done

# 索引 openclaw.json
if [ -f "/home/nmaster/.openclaw/openclaw.json" ]; then
    mcporter call context-mode.index path:/home/nmaster/.openclaw/openclaw.json source:config 2>/dev/null
    echo "  - Indexed: openclaw.json"
fi

echo "[$(date)] Skills indexing complete"
