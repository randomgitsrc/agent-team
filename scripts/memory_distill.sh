#!/bin/bash
#
# 记忆自动提炼系统 - 半自动模式 (方案B)
# 功能：每日从专家 daily logs 中提取精华，生成提炼报告供审核
#
# 工作流程：
#   1. 读取 daily logs → AI分类 → 生成提炼报告 → 阿九审核 → --apply 写入
#
# 使用方式：
#   ./scripts/memory_distill.sh --report-only    # 生成报告（默认）
#   ./scripts/memory_distill.sh --apply          # 审核后执行写入
#

set -euo pipefail

# ============================================
# 配置与初始化
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$WORKSPACE_DIR/.memory-distill-config.json"
LIB_DIR="$SCRIPT_DIR/lib"
CLASSIFIER="$LIB_DIR/memory-classifier.py"

# 路径配置
MEMORY_ROOT="$WORKSPACE_DIR/memory"
TEAM_DIR="$MEMORY_ROOT/team"
CEO_DIR="$MEMORY_ROOT/ceo"
DOCS_DIR="$WORKSPACE_DIR/docs"
ARCHIVE_DIR="$MEMORY_ROOT/archive"
LOG_DIR="$MEMORY_ROOT/logs"
REPORT_DIR="$LOG_DIR/reports"
PENDING_DIR="$LOG_DIR/pending"

# 确保目录存在
mkdir -p "$LOG_DIR" "$REPORT_DIR" "$PENDING_DIR" "$ARCHIVE_DIR"

# 默认配置
MODE="report-only"  # report-only | apply
target_date=$(date +%Y-%m-%d)
VERBOSE=false
DRY_RUN=false

# 报告文件路径
REPORT_FILE="$REPORT_DIR/distill-report-${target_date}.md"
PENDING_FILE="$PENDING_DIR/pending-${target_date}.json"

# ============================================
# 工具函数
# ============================================

log_info() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1"
    echo "$msg"
    echo "$msg" >> "$LOG_DIR/distill.log"
}

log_warn() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1"
    echo "⚠️  $msg" >&2
    echo "$msg" >> "$LOG_DIR/distill.log"
}

log_error() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1"
    echo "❌ $msg" >&2
    echo "$msg" >> "$LOG_DIR/distill.log"
}

# 显示帮助
show_help() {
    cat << 'EOF'
记忆自动提炼系统 - 半自动模式 (方案B)

OPTIONS:
    --report-only, -r   生成提炼报告供审核（默认模式）
    --apply, -a         确认后执行实际写入（需先运行 --report-only）
    --date DATE         指定处理日期 (YYYY-MM-DD)，默认为今天
    --verbose, -v       显示详细输出
    --dry-run, -d       试运行模式（仅用于测试）
    --help, -h          显示此帮助信息

半自动工作流程：
    1. 每晚 23:00 自动生成报告：./memory_distill.sh --report-only
    2. 阿九审核报告：memory/logs/reports/distill-report-YYYY-MM-DD.md
    3. 确认无误后执行写入：./memory_distill.sh --apply

示例：
    # 生成今日报告
    ./scripts/memory_distill.sh
    
    # 或指定日期
    ./scripts/memory_distill.sh --date 2026-02-12
    
    # 审核后写入
    ./scripts/memory_distill.sh --apply
EOF
}

# 解析参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --report-only|-r)
                MODE="report-only"
                shift
                ;;
            --apply|-a)
                MODE="apply"
                shift
                ;;
            --date)
                target_date="$2"
                REPORT_FILE="$REPORT_DIR/distill-report-${target_date}.md"
                PENDING_FILE="$PENDING_DIR/pending-${target_date}.json"
                shift 2
                ;;
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --dry-run|-d)
                DRY_RUN=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# 检查依赖
check_dependencies() {
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 未安装"
        exit 1
    fi
    
    if [[ ! -f "$CLASSIFIER" ]]; then
        log_error "分类器不存在: $CLASSIFIER"
        exit 1
    fi
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "配置文件不存在: $CONFIG_FILE"
        exit 1
    fi
}

# 获取所有专家列表
get_experts() {
    find "$TEAM_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort || true
}

# 提取记忆条目（按markdown标题分割）
extract_entries() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        return
    fi
    
    # 使用 awk 提取各个条目
    awk '
        /^#{2,4} / {
            if (buf) {
                print buf
                print "\x00"  # 使用null字符作为分隔符
            }
            buf = $0
            next
        }
        { buf = buf "\n" $0 }
        END { 
            if (buf) {
                print buf
                print "\x00"
            }
        }
    ' "$file"
}

# 处理单条记忆，返回JSON结果
classify_memory() {
    local content="$1"
    local expert="$2"
    local source_file="$3"
    
    if [[ -z "$content" ]]; then
        echo "{}"
        return
    fi
    
    # 清理内容
    content=$(echo "$content" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    
    if [[ -z "$content" ]]; then
        echo "{}"
        return
    fi
    
    # 创建临时文件
    local temp_file=$(mktemp)
    printf '%s\n' "$content" > "$temp_file"
    
    # 调用分类器
    local result
    if ! result=$(python3 "$CLASSIFIER" --config "$CONFIG_FILE" --input "$temp_file" --expert "$expert" 2>/dev/null); then
        log_error "分类失败 for $expert"
        rm -f "$temp_file"
        echo "{}"
        return
    fi
    
    rm -f "$temp_file"
    
    # 检查结果是否为空
    if [[ -z "$result" ]] || [[ "$result" == "{}" ]]; then
        echo "{}"
        return
    fi
    
    # 添加源文件信息
    echo "$result" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    d['source_file'] = '$source_file'
    print(json.dumps(d, ensure_ascii=False))
except json.JSONDecodeError:
    print('{}')
"
}

# ============================================
# 报告生成
# ============================================

generate_report() {
    local entries_json="$1"
    
    # 使用Python正确统计
    local stats=$(echo "$entries_json" | python3 -c "
import sys, json
data = json.load(sys.stdin)
total = len(data)
pending = len([e for e in data if e.get('action') == 'write'])
skipped = len([e for e in data if e.get('action') == 'skip'])
high_risk = len([e for e in data if e.get('is_high_risk') and e.get('action') == 'write'])
temp = len([e for e in data if e.get('level') == '临时级'])
dup = len([e for e in data if '重复' in str(e.get('reason',''))])
print(f'{total}|{pending}|{skipped}|{high_risk}|{temp}|{dup}')
")
    
    local total_count=$(echo "$stats" | cut -d'|' -f1)
    local pending_count=$(echo "$stats" | cut -d'|' -f2)
    local skipped_count=$(echo "$stats" | cut -d'|' -f3)
    local high_risk_count=$(echo "$stats" | cut -d'|' -f4)
    local temp_count=$(echo "$stats" | cut -d'|' -f5)
    local dup_count=$(echo "$stats" | cut -d'|' -f6)
    
    # 生成报告头
    cat > "$REPORT_FILE" << EOF
# 记忆提炼报告

**报告日期**: ${target_date}  
**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')  
**处理模式**: 半自动（人工审核）

---

## 📊 统计概览

| 指标 | 数值 |
|------|------|
| 总条目数 | ${total_count} |
| 待写入 | ${pending_count} ✅ |
| 已跳过（重复/临时） | ${skipped_count} |
| 高风险标记 | ${high_risk_count} 🔴 |

---

## 📝 待写入条目清单

EOF

    # 按级别分组输出
    local levels=("战略级" "规范级" "领域级")
    for level in "${levels[@]}"; do
        echo "### ${level}" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
        
        # 提取该级别的条目
        echo "$entries_json" | python3 -c "
import sys, json
entries = json.load(sys.stdin)
level_entries = [e for e in entries if e.get('level') == '$level' and e.get('action') == 'write']

if not level_entries:
    print('_无_')
    sys.exit(0)
    for i, e in enumerate(level_entries, 1):
        print(f\"{i}. **{e.get('summary', '无摘要')[:50]}...**\" if len(e.get('summary', '')) > 50 else f\"{i}. **{e.get('summary', '无摘要')}**\")
        print(f\"   - 专家: {e.get('expert', '未知')}\")
        print(f\"   - 目标: {e.get('target_file', 'N/A')}\")
        print(f\"   - 置信度: {e.get('confidence', 0):.0%}\")
        if e.get('is_high_risk'):
            print(f\"   - ⚠️ **高风险**: 涉及删除/重构等敏感操作\")
        print()
" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    done
    
    # 重要内容详情（战略级、规范级）
    cat >> "$REPORT_FILE" << EOF
---

## 📋 重要内容详情（需重点审核）

以下战略级和规范级内容将写入长期记忆，**请仔细审核内容真实性**：

EOF
    echo "$entries_json" | python3 << 'PYCODE'
import sys, json
try:
    entries = json.load(sys.stdin)
except (json.JSONDecodeError, ValueError):
    entries = []
important_entries = [e for e in entries if e.get('level') in ['战略级', '规范级'] and e.get('action') == 'write']

if not important_entries:
    print("_无重要内容_")
else:
    for i, e in enumerate(important_entries, 1):
        level = e.get('level', '未知')
        expert = e.get('expert', '未知')
        target = e.get('target_file', 'N/A')
        is_auth = e.get('is_authentic', True)
        auth_reason = e.get('auth_reason', '未知')
        auth_status = '通过' if is_auth else f'未通过 - {auth_reason}'
        print(f"### {i}. [{level}] {expert}")
        print(f"**目标文件**: {target}")
        print(f"**真实性验证**: {auth_status}")
        print()
        print("**完整内容预览**:")
        print("```")
        content = e.get('original_content', '')
        print(content[:1000] + ('...[截断]' if len(content) > 1000 else ''))
        print("```")
        print()
        print("---")
        print()
PYCODE

    # 高风险详情
    if [[ $high_risk_count -gt 0 ]]; then
        cat >> "$REPORT_FILE" << EOF
---

## 🔴 高风险条目详情

以下条目涉及敏感操作，请**特别注意审核**：

EOF
        echo "$entries_json" | python3 << 'PYCODE'
import sys, json
try:
    entries = json.load(sys.stdin)
except (json.JSONDecodeError, ValueError):
    entries = []
risk_entries = [e for e in entries if e.get('is_high_risk') and e.get('action') == 'write']

for i, e in enumerate(risk_entries, 1):
    summary = e.get('summary', '无摘要')[:60]
    expert = e.get('expert', '未知')
    level = e.get('level', '未知')
    target = e.get('target_file', 'N/A')
    keywords = ', '.join(e.get('keywords', []))
    print(f"### {i}. {summary}...")
    print(f"- 专家: {expert}")
    print(f"- 级别: {level}")
    print(f"- 目标: {target}")
    print(f"- 关键词: {keywords}")
    print()
    print("**原始内容**:")
    print("```")
    content = e.get('original_content', '')
    print(content[:500] + ('...[截断]' if len(content) > 500 else ''))
    print("```")
    print()
PYCODE
    
    log_info "写入完成！"
    
    # 归档旧日志
    log_info "检查归档任务..."
    fi
    
    # 归档旧日志
    log_info "检查归档任务..."
    archive_old_logs
    
    echo ""
    echo "======================================"
    echo "✅ 记忆提炼完成"
    echo "======================================"
}

# ============================================
# 报告模式 - 只生成报告不写入
# ============================================

run_report_mode() {
    log_info "========== 记忆提炼报告模式 =========="
    log_info "处理日期: $target_date"
    log_info "======================================"
    
    check_dependencies
    
    local experts=$(get_experts)
    if [[ -z "$experts" ]]; then
        log_warn "未找到任何专家目录"
        exit 0
    fi
    
    log_info "发现 $(echo "$experts" | wc -l) 位专家"
    
    # 收集所有条目
    local all_entries="["
    local first_entry=true
    
    while IFS= read -r expert; do
        [[ -n "$expert" ]] || continue
        
        local daily_file="$TEAM_DIR/$expert/daily/${target_date}.md"
        if [[ ! -f "$daily_file" ]]; then
            log_info "无日志: $expert/${target_date}.md"
            continue
        fi
        
        log_info "处理专家: $expert"
        
        # 提取并分类每个条目
        local entry_content=""
        while IFS= read -r -d '' chunk || [[ -n "$chunk" ]]; do
            if [[ -n "$chunk" ]]; then
                local result=$(classify_memory "$chunk" "$expert" "$daily_file")
                if [[ "$result" != "{}" ]]; then
                    if [[ "$first_entry" == true ]]; then
                        first_entry=false
                    else
                        all_entries+=","
                    fi
                    all_entries+="$result"
                fi
            fi
        done < <(extract_entries "$daily_file")
        
    done <<< "$experts"
    
    all_entries+="]"
    
    # 保存待写入数据
    echo "$all_entries" > "$PENDING_FILE"
    
    # 生成报告
    generate_report "$all_entries"
    
    echo ""
    echo "======================================"
    echo "📋 报告已生成: $REPORT_FILE"
    echo "📦 待写入数据: $PENDING_FILE"
    echo ""
    echo "下一步操作："
    echo "  1. 审核报告内容"
    echo "  2. 确认后执行: ./scripts/memory_distill.sh --apply"
    echo "======================================"
}

# ============================================
# 应用模式 - 执行实际写入
# ============================================

run_apply_mode() {
    log_info "========== 记忆提炼执行模式 =========="
    log_info "处理日期: $target_date"
    log_info "======================================"
    
    # 检查待写入数据是否存在
    if [[ ! -f "$PENDING_FILE" ]]; then
        log_error "未找到待写入数据: $PENDING_FILE"
        log_error "请先运行: ./scripts/memory_distill.sh --report-only --date $target_date"
        exit 1
    fi
    
    # 检查报告是否存在
    if [[ ! -f "$REPORT_FILE" ]]; then
        log_warn "未找到报告文件: $REPORT_FILE"
    fi
    
    log_info "加载待写入数据..."
    
    # 读取待写入条目
    local pending_entries=$(cat "$PENDING_FILE")
    local write_entries=$(echo "$pending_entries" | python3 -c "
import sys, json
entries = json.load(sys.stdin)
write_entries = [e for e in entries if e.get('action') == 'write']
print(json.dumps(write_entries, ensure_ascii=False))
")
    
    local count=$(echo "$write_entries" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))")
    
    if [[ "$count" -eq 0 ]]; then
        log_info "没有需要写入的条目"
        exit 0
    fi
    
    log_info "准备写入 $count 个条目..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log_info "[DRY-RUN] 试运行模式，不实际写入"
    fi
    
    # 逐个写入
    echo "$write_entries" | python3 -c "
import sys, json
import os

entries = json.load(sys.stdin)
workspace = '$WORKSPACE_DIR'
dry_run = '$DRY_RUN' == 'true'

for entry in entries:
    target = entry.get('target_file')
    formatted = entry.get('formatted_entry', '')
    expert = entry.get('expert', '未知')
    level = entry.get('level', '未知')
    
    if not target or not formatted:
        continue
    
    full_path = os.path.join(workspace, target)
    
    if dry_run:
        print(f'[DRY-RUN] 将写入 {target}')
    else:
        # 确保目录存在
        os.makedirs(os.path.dirname(full_path), exist_ok=True)
        
        # 追加内容
        with open(full_path, 'a', encoding='utf-8') as f:
            f.write('\n')
            f.write(formatted)
        
        print(f'已写入 [{level}] {target} (by {expert})')
" 
    
    log_info "写入完成！"
    
    # 归档旧日志
    log_info "检查归档任务..."
    archive_old_logs
    
    echo ""
    echo "======================================"
    echo "✅ 记忆提炼完成"
    echo "======================================"
}

# ============================================
# 归档功能
# ============================================

archive_old_logs() {
    log_info "开始归档 (>30天的日志)..."
    
    local cutoff_date
    cutoff_date=$(date -d "30 days ago" +%Y-%m-%d 2>/dev/null || date -v-30d +%Y-%m-%d 2>/dev/null)
    
    local archived_count=0
    
    for expert_dir in "$TEAM_DIR"/*/; do
        local daily_dir="${expert_dir}daily"
        if [[ ! -d "$daily_dir" ]]; then
            continue
        fi
        
        local expert
        expert=$(basename "$expert_dir")
        
        for log_file in "$daily_dir"/*.md; do
            [[ -f "$log_file" ]] || continue
            
            local filename
            filename=$(basename "$log_file" .md)
            
            # 跳过非日期格式的文件
            if [[ ! "$filename" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                continue
            fi
            
            # 比较日期
            if [[ "$filename" < "$cutoff_date" ]]; then
                local target_dir="$ARCHIVE_DIR/$expert/daily"
                mkdir -p "$target_dir"
                
                if mv "$log_file" "$target_dir/"; then
                    ((archived_count++)) || true
                    log_info "已归档: $expert/$filename.md"
                fi
            fi
        done
    done
    
    log_info "归档完成: $archived_count 个文件"
}

# ============================================
# 主流程
# ============================================

main() {
    parse_args "$@"
    
    echo "=============================================="
    echo "🧠 记忆自动提炼系统 v1.0.0 - 半自动模式"
    echo "=============================================="
    echo "处理日期: $target_date"
    echo "工作目录: $WORKSPACE_DIR"
    echo "模式: $MODE"
    echo "=============================================="
    echo ""
    
    case "$MODE" in
        report-only)
            run_report_mode
            ;;
        apply)
            run_apply_mode
            ;;
        *)
            log_error "未知模式: $MODE"
            exit 1
            ;;
    esac
}

# 捕获错误
trap 'log_error "脚本执行失败，行号: $LINENO"' ERR

# 执行主流程
main "$@"
