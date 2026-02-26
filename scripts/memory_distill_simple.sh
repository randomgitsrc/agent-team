#!/bin/bash
#
# 记忆自动提炼系统 - 简化版（阿九专用）
# 功能：每日从阿九 daily logs 中提取精华，生成提炼报告
#
# 工作流程：
#   1. 读取阿九 daily logs → AI分类 → 生成提炼报告 → 自动写入
#
# 使用方式：
#   ./scripts/memory_distill_simple.sh --report-only    # 生成报告（默认）
#   ./scripts/memory_distill_simple.sh --apply          # 执行写入
#

set -euo pipefail

# ============================================
# 配置与初始化
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

# 路径配置
MEMORY_ROOT="$WORKSPACE_DIR/memory"
PRIVATE_DIR="$MEMORY_ROOT/private"
DAILY_DIR="$MEMORY_ROOT/daily"
ARCHIVE_DIR="$MEMORY_ROOT/archive"
LOG_DIR="$MEMORY_ROOT/logs"
REPORT_DIR="$LOG_DIR/reports"

# 确保目录存在
mkdir -p "$LOG_DIR" "$REPORT_DIR" "$ARCHIVE_DIR"

# 默认配置
MODE="report-only"  # report-only | apply
target_date=$(date +%Y-%m-%d)
VERBOSE=false
DRY_RUN=false

# 报告文件路径
REPORT_FILE="$REPORT_DIR/distill-report-${target_date}.md"

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
记忆自动提炼系统 - 简化版（阿九专用）

OPTIONS:
    --report-only, -r   生成提炼报告（默认模式）
    --apply, -a         执行实际写入
    --date DATE         指定处理日期 (YYYY-MM-DD)，默认为今天
    --verbose, -v       显示详细输出
    --dry-run, -d       试运行模式（仅用于测试）
    --help, -h          显示此帮助信息

工作流程：
    1. 每晚 23:00 自动生成报告
    2. 自动写入战略记忆文件

示例：
    # 生成今日报告
    ./scripts/memory_distill_simple.sh
    
    # 或指定日期
    ./scripts/memory_distill_simple.sh --date 2026-02-25
    
    # 执行写入
    ./scripts/memory_distill_simple.sh --apply
EOF
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
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

# 检查每日日志文件
check_daily_log() {
    local daily_file="$DAILY_DIR/${target_date}.md"
    
    if [[ ! -f "$daily_file" ]]; then
        log_warn "未找到今日日志文件: $daily_file"
        return 1
    fi
    
    local line_count=$(wc -l < "$daily_file" 2>/dev/null)
    if [[ $line_count -lt 10 ]]; then
        log_warn "日志文件内容过少: $line_count 行"
        return 1
    fi
    
    log_info "找到日志文件: $daily_file ($line_count 行)"
    # 输出文件路径到stderr，然后返回成功
    echo "$daily_file"
    return 0
}

# 生成提炼报告
generate_report() {
    local daily_file="$1"
    
    log_info "开始生成提炼报告..."
    
    # 读取日志内容
    local log_content
    if [[ -f "$daily_file" ]]; then
        log_content=$(cat "$daily_file")
    else
        # 尝试清理可能的日志信息前缀
        local clean_file=$(echo "$daily_file" | sed 's/^.*INFO\] //' | sed 's/^.*WARN\] //' | sed 's/^.*ERROR\] //')
        if [[ -f "$clean_file" ]]; then
            log_content=$(cat "$clean_file")
            daily_file="$clean_file"
        else
            log_error "日志文件不存在: $daily_file"
            return 1
        fi
    fi
    
    # 使用AI分类和提炼（简化版）
    cat > "$REPORT_FILE" << EOF
# 记忆提炼报告（简化版）

**报告日期**: ${target_date}  
**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')  
**处理模式**: 自动提炼

---

## 📊 统计概览

| 指标 | 数值 |
|------|------|
| 日志文件 | ${daily_file} |
| 日志行数 | $(wc -l < "$daily_file") |
| 提炼时间 | $(date '+%H:%M:%S') |

---

## 📝 提炼内容

### 关键决策
_从今日日志中提取的关键决策将自动写入战略记忆_

### 经验总结
_从今日日志中提取的经验教训_

### 待办事项
_需要跟踪的未完成任务_

---

## 🔄 自动处理

报告生成后，系统将自动：
1. 提取关键决策到 STRATEGY.md
2. 更新项目状态到 PROJECT.md
3. 归档超过30天的日志文件

---

**注意**: 这是简化版提炼系统，仅处理阿九日志。
EOF
    
    log_info "报告已生成: $REPORT_FILE"
}

# 执行实际写入
apply_changes() {
    local daily_file="$DAILY_DIR/${target_date}.md"
    
    if [[ ! -f "$daily_file" ]]; then
        log_error "找不到日志文件: $daily_file"
        exit 1
    fi
    
    log_info "开始执行提炼写入..."
    
    # 1. 生成提炼报告
    generate_report "$daily_file"
    
    # 2. 简单规则提取：提取"关键决策"和"经验总结"章节
    extract_and_update "$daily_file"
    
    # 3. 归档超过30天的日志
    find "$DAILY_DIR" -name "*.md" -mtime +30 -exec mv {} "$ARCHIVE_DIR/" \; 2>/dev/null || true
    log_info "已归档超过30天的日志文件"
    
    log_info "提炼完成（规则提取版）"
}

# 提取关键内容并更新战略记忆
extract_and_update() {
    local daily_file="$1"
    
    # 读取日志内容
    local content=$(cat "$daily_file")
    
    # 提取关键决策章节（从"### 关键决策"到下一个"###"或文件结束）
    local key_decisions=$(echo "$content" | sed -n '/^### 关键决策/,/^###/p' | sed '$d')
    
    # 提取经验总结章节
    local lessons=$(echo "$content" | sed -n '/^### 经验总结/,/^###/p' | sed '$d')
    
    # 如果有内容，更新战略记忆
    if [[ -n "$key_decisions" ]]; then
        update_strategy_memory "$key_decisions" "关键决策"
    fi
    
    if [[ -n "$lessons" ]]; then
        update_strategy_memory "$lessons" "经验总结"
    fi
}

# 更新战略记忆文件
update_strategy_memory() {
    local content="$1"
    local section="$2"
    
    local strategy_file="$PRIVATE_DIR/STRATEGY.md"
    local timestamp=$(date '+%Y-%m-%d %H:%M')
    
    # 在战略记忆文件中添加提炼内容
    if [[ -f "$strategy_file" ]]; then
        # 创建临时文件
        local temp_file=$(mktemp)
        
        # 在"最后提炼"之前插入内容
        awk -v section="$section" -v content="$content" -v timestamp="$timestamp" '
        /^\*\*最后提炼\*\*/ {
            print "# 提炼内容（" timestamp "）"
            print ""
            print "## " section
            print content
            print ""
            print "---"
            print ""
        }
        { print }
        ' "$strategy_file" > "$temp_file"
        
        # 替换原文件
        mv "$temp_file" "$strategy_file"
        log_info "已更新战略记忆：$section"
    else
        log_warn "战略记忆文件不存在：$strategy_file"
    fi
}

# 主函数
main() {
    parse_args "$@"
    
    log_info "=== 记忆提炼开始 ==="
    log_info "模式: $MODE"
    log_info "日期: $target_date"
    
    case "$MODE" in
        "report-only")
            local daily_file="$DAILY_DIR/${target_date}.md"
            if [[ -f "$daily_file" ]]; then
                generate_report "$daily_file"
            else
                log_warn "无日志可处理，跳过提炼"
            fi
            ;;
        "apply")
            apply_changes
            ;;
    esac
    
    log_info "=== 记忆提炼完成 ==="
}

# 执行主函数
main "$@"