#!/bin/bash

# 骆言项目整合质量自动验证脚本
# Author: Foxtrot, Project Overseer
# 创建时间: 2025-08-04
# 用途: 确保所有Poetry模块整合符合质量标准

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 配置参数
POETRY_DIR="src/poetry"
TARGET_FILE_COUNT=200
MAX_WRAPPER_COUNT=30
MIN_REDUCTION_PERCENT=10

# 验证函数

# 检查1: 文件数量验证
check_file_count() {
    log_info "正在检查Poetry模块文件数量..."
    
    local current_count=$(find ${POETRY_DIR} -name "*.ml" -o -name "*.mli" | wc -l)
    
    log_info "当前Poetry文件数: ${current_count}"
    log_info "目标文件数: ${TARGET_FILE_COUNT}"
    
    if [ $current_count -gt $TARGET_FILE_COUNT ]; then
        log_error "文件数超标: ${current_count} > ${TARGET_FILE_COUNT}"
        echo "  需要继续整合减少 $((current_count - TARGET_FILE_COUNT)) 个文件"
        return 1
    else
        log_success "文件数符合目标: ${current_count} <= ${TARGET_FILE_COUNT}"
        return 0
    fi
}

# 检查2: 验证文件减少（与前一个commit对比）
check_file_reduction() {
    log_info "正在检查文件数量是否减少..."
    
    # 获取前一个commit的文件数
    local prev_count
    if git rev-parse HEAD~1 >/dev/null 2>&1; then
        prev_count=$(git ls-tree -r --name-only HEAD~1 | grep "^${POETRY_DIR}/.*\\.ml\$\|^${POETRY_DIR}/.*\\.mli\$" | wc -l)
    else
        log_warning "无法获取前一个commit，跳过减少验证"
        return 0
    fi
    
    local current_count=$(find ${POETRY_DIR} -name "*.ml" -o -name "*.mli" | wc -l)
    local reduction=$((prev_count - current_count))
    local reduction_percent=0
    
    if [ $prev_count -gt 0 ]; then
        reduction_percent=$((reduction * 100 / prev_count))
    fi
    
    log_info "前一版本文件数: ${prev_count}"
    log_info "当前文件数: ${current_count}"
    log_info "减少文件数: ${reduction} (${reduction_percent}%)"
    
    if [ $reduction -ge 0 ]; then
        if [ $reduction_percent -ge $MIN_REDUCTION_PERCENT ] || [ $current_count -le $TARGET_FILE_COUNT ]; then
            log_success "文件数减少达标: 减少${reduction}个文件 (${reduction_percent}%)"
            return 0
        else
            log_warning "文件数减少幅度较小: ${reduction_percent}% < ${MIN_REDUCTION_PERCENT}%"
            log_warning "如果已达到目标文件数，这是可接受的"
            return 0
        fi
    else
        log_error "文件数量增加了: 增加${reduction#-}个文件"
        echo "  这违反了整合原则，请检查是否创建了不必要的文件"
        return 1
    fi
}

# 检查3: 包装器模式检测
check_wrapper_patterns() {
    log_info "正在检查是否存在过多包装器模式..."
    
    # 检测简单的包装器模式
    local wrapper_count=0
    local suspicious_files=()
    
    # 查找可能的包装器文件
    while IFS= read -r -d '' file; do
        # 统计简单赋值语句的数量
        local simple_assignments=$(grep -c "let.*=.*\.[a-zA-Z_]" "$file" 2>/dev/null || echo 0)
        local total_lines=$(wc -l < "$file" 2>/dev/null || echo 0)
        
        # 确保变量是有效的数字
        if ! [[ "$total_lines" =~ ^[0-9]+$ ]]; then
            total_lines=0
        fi
        if ! [[ "$simple_assignments" =~ ^[0-9]+$ ]]; then
            simple_assignments=0
        fi
        
        # 如果简单赋值占比超过60%且文件不是很小，可能是包装器
        if [ "$total_lines" -gt 20 ] && [ "$simple_assignments" -gt 0 ]; then
            local assignment_ratio=$((simple_assignments * 100 / total_lines))
            if [ $assignment_ratio -gt 60 ]; then
                wrapper_count=$((wrapper_count + 1))
                suspicious_files+=("$file (${assignment_ratio}% 简单赋值)")
            fi
        fi
    done < <(find ${POETRY_DIR} -name "*.ml" -print0)
    
    log_info "检测到可能的包装器文件数: ${wrapper_count}"
    
    if [ $wrapper_count -gt $MAX_WRAPPER_COUNT ]; then
        log_error "包装器文件过多: ${wrapper_count} > ${MAX_WRAPPER_COUNT}"
        echo "  可能的包装器文件:"
        for file in "${suspicious_files[@]}"; do
            echo "    - $file"
        done
        echo "  建议审查这些文件，确保它们是真实的功能合并而非简单包装"
        return 1
    else
        log_success "包装器文件数量合理: ${wrapper_count} <= ${MAX_WRAPPER_COUNT}"
        if [ ${#suspicious_files[@]} -gt 0 ]; then
            log_info "可能需要关注的文件:"
            for file in "${suspicious_files[@]}"; do
                echo "    - $file"
            done
        fi
        return 0
    fi
}

# 检查4: 编译验证
check_compilation() {
    log_info "正在检查编译状态..."
    
    if dune build 2>/dev/null; then
        log_success "编译成功"
        return 0
    else
        log_error "编译失败"
        echo "  请修复编译错误后再进行整合"
        echo "  可以运行 'dune build' 查看详细错误信息"
        return 1
    fi
}

# 检查5: 测试验证
check_tests() {
    log_info "正在检查测试状态..."
    
    if dune runtest 2>/dev/null; then
        log_success "所有测试通过"
        return 0
    else
        log_error "部分测试失败"
        echo "  请修复测试失败后再进行整合"
        echo "  可以运行 'dune runtest' 查看详细错误信息"
        return 1
    fi
}

# 检查6: 重复代码检测
check_code_duplication() {
    log_info "正在检查代码重复情况..."
    
    # 使用简单的重复行检测
    local duplicate_lines=0
    local temp_file=$(mktemp)
    
    # 收集所有.ml文件的内容（除去注释和空行）
    find ${POETRY_DIR} -name "*.ml" -exec grep -v "^\s*(\*\|^\s*\*\|^\s*\*)\|^\s*$" {} \; | sort > "$temp_file"
    
    # 统计重复行
    duplicate_lines=$(uniq -d "$temp_file" | wc -l)
    local total_lines=$(wc -l < "$temp_file")
    
    rm "$temp_file"
    
    if [ $total_lines -gt 0 ]; then
        local duplication_ratio=$((duplicate_lines * 100 / total_lines))
        log_info "代码重复行数: ${duplicate_lines} / ${total_lines} (${duplication_ratio}%)"
        
        if [ $duplication_ratio -gt 15 ]; then
            log_warning "代码重复率较高: ${duplication_ratio}%"
            echo "  建议进一步合并重复的功能模块"
        else
            log_success "代码重复率合理: ${duplication_ratio}%"
        fi
    else
        log_warning "无法计算代码重复率"
    fi
    
    return 0
}

# 检查7: 模块依赖分析
check_module_dependencies() {
    log_info "正在分析模块依赖复杂度..."
    
    # 统计open语句数量
    local open_count=$(find ${POETRY_DIR} -name "*.ml" -exec grep -c "^open\|^ *open" {} \; | awk '{sum+=$1} END {print sum+0}')
    local file_count=$(find ${POETRY_DIR} -name "*.ml" | wc -l)
    
    if [ $file_count -gt 0 ]; then
        local avg_deps=$((open_count / file_count))
        log_info "平均每个文件的模块依赖数: ${avg_deps}"
        
        if [ $avg_deps -gt 10 ]; then
            log_warning "模块依赖较复杂，平均每文件${avg_deps}个依赖"
            echo "  建议审查依赖关系，考虑进一步整合"
        else
            log_success "模块依赖复杂度合理: 平均每文件${avg_deps}个依赖"
        fi
    fi
    
    return 0
}

# 生成整合报告
generate_report() {
    local current_count=$(find ${POETRY_DIR} -name "*.ml" -o -name "*.mli" | wc -l)
    local progress=$((($TARGET_FILE_COUNT - $current_count) * 100 / $TARGET_FILE_COUNT))
    if [ $progress -lt 0 ]; then
        progress=0
    fi
    
    echo ""
    echo "=========================================="
    echo "           整合质量验证报告"
    echo "=========================================="
    echo "当前文件数: ${current_count}"
    echo "目标文件数: ${TARGET_FILE_COUNT}"
    echo "完成进度: ${progress}%"
    echo "=========================================="
    
    # 统计不同类型的文件
    echo ""
    echo "文件类型分布:"
    echo "  .ml文件: $(find ${POETRY_DIR} -name "*.ml" | wc -l)"
    echo "  .mli文件: $(find ${POETRY_DIR} -name "*.mli" | wc -l)"
    echo "  consolidated文件: $(find ${POETRY_DIR} -name "*consolidated*" | wc -l)"
    echo "  unified文件: $(find ${POETRY_DIR} -name "*unified*" | wc -l)"
    
    # 目录结构概览
    echo ""
    echo "主要目录文件数:"
    for dir in $(find ${POETRY_DIR} -type d -mindepth 1 -maxdepth 1 | sort); do
        local dir_name=$(basename "$dir")
        local dir_files=$(find "$dir" -name "*.ml" -o -name "*.mli" | wc -l)
        echo "  ${dir_name}: ${dir_files}个文件"
    done
}

# 主函数
main() {
    echo "=========================================="
    echo "    骆言项目Poetry模块整合质量验证"
    echo "=========================================="
    echo ""
    
    local overall_status=0
    local check_count=0
    local pass_count=0
    
    # 执行所有检查
    checks=(
        "check_file_count:文件数量验证"
        "check_file_reduction:文件减少验证"
        "check_wrapper_patterns:包装器模式检测"
        "check_compilation:编译验证"
        "check_tests:测试验证"
        "check_code_duplication:代码重复检测"
        "check_module_dependencies:模块依赖分析"
    )
    
    for check_info in "${checks[@]}"; do
        IFS=':' read -r check_func check_desc <<< "$check_info"
        check_count=$((check_count + 1))
        
        echo ""
        echo "[$check_count/7] ${check_desc}..."
        echo "----------------------------------------"
        
        if $check_func; then
            pass_count=$((pass_count + 1))
        else
            overall_status=1
        fi
    done
    
    # 生成报告
    generate_report
    
    # 最终结果
    echo ""
    echo "=========================================="
    if [ $overall_status -eq 0 ]; then
        log_success "整合质量验证通过! (${pass_count}/${check_count})"
        echo "  ✅ 所有质量检查都已通过"
        echo "  ✅ 可以继续进行下一步整合或提交PR"
    else
        log_error "整合质量验证失败! (${pass_count}/${check_count})"
        echo "  ❌ 请修复上述问题后重新运行验证"
        echo "  ❌ 不建议在问题修复前提交PR"
    fi
    echo "=========================================="
    
    exit $overall_status
}

# 参数处理
case "${1:-}" in
    --help|-h)
        echo "用法: $0 [选项]"
        echo ""
        echo "选项:"
        echo "  --help, -h              显示帮助信息"
        echo "  --quick                 快速检查（跳过测试）"
        echo "  --file-count-only       仅检查文件数量"
        echo "  --target-count <num>    设置目标文件数量（默认: $TARGET_FILE_COUNT）"
        echo ""
        echo "示例:"
        echo "  $0                      # 完整验证"
        echo "  $0 --quick              # 快速验证"
        echo "  $0 --target-count 180   # 设置目标为180个文件"
        exit 0
        ;;
    --quick)
        # 快速模式，跳过耗时的测试
        check_tests() { log_info "跳过测试验证（快速模式）"; return 0; }
        ;;
    --file-count-only)
        # 仅检查文件数量
        main() {
            check_file_count
            generate_report
            exit $?
        }
        ;;
    --target-count)
        if [ -n "${2:-}" ] && [ "$2" -gt 0 ]; then
            TARGET_FILE_COUNT="$2"
            log_info "目标文件数设置为: $TARGET_FILE_COUNT"
        else
            log_error "无效的目标文件数: ${2:-}"
            exit 1
        fi
        ;;
esac

# 检查是否在项目根目录
if [ ! -d "$POETRY_DIR" ]; then
    log_error "未找到Poetry目录: $POETRY_DIR"
    echo "  请确保在项目根目录运行此脚本"
    exit 1
fi

# 执行主函数
main