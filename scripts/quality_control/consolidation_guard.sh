#!/bin/bash
# Poetry模块整合质量控制脚本
# Author: Papa, Project Strategist
# Purpose: 防止包装式"整合"，确保真实的减量整合

set -e

echo "🛡️  Poetry模块整合质量控制检查"

# 配置参数
POETRY_DIR="src/poetry"
TARGET_FILE_COUNT=200
CURRENT_BRANCH=$(git branch --show-current)

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 函数定义
error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 检查1: 防止创建consolidated目录
check_consolidated_directories() {
    echo "=== 检查1: 防止包装式整合目录 ==="
    
    local consolidated_dirs=$(git diff --cached --name-status | grep "^A" | grep -i "consolidated" | wc -l)
    if [ $consolidated_dirs -gt 0 ]; then
        echo "检测到的consolidated目录:"
        git diff --cached --name-status | grep "^A" | grep -i "consolidated"
        error "禁止创建consolidated目录 - 这是包装式整合的标志"
    fi
    
    success "未检测到consolidated目录创建"
}

# 检查2: 防止只新增不删除的操作
check_file_reduction() {
    echo "=== 检查2: 验证文件数减少 ==="
    
    local new_poetry_files=$(git diff --cached --name-status | grep "^A" | grep "$POETRY_DIR" | wc -l)
    local deleted_poetry_files=$(git diff --cached --name-status | grep "^D" | grep "$POETRY_DIR" | wc -l)
    
    echo "Poetry目录新增文件: $new_poetry_files"
    echo "Poetry目录删除文件: $deleted_poetry_files"
    
    if [ $new_poetry_files -gt 0 ] && [ $deleted_poetry_files -eq 0 ]; then
        error "禁止只新增文件不删除文件的整合操作 - 真正的整合必须删除原有分散文件"
    fi
    
    if [ $new_poetry_files -gt 0 ] && [ $deleted_poetry_files -gt 0 ]; then
        local net_change=$((deleted_poetry_files - new_poetry_files))
        if [ $net_change -le 0 ]; then
            warning "整合操作未显示净文件减少 (净变化: $net_change)"
            echo "请确认这是真正的整合而非包装操作"
        else
            success "整合操作显示净减少 $net_change 个文件"
        fi
    fi
    
    success "文件变更检查通过"
}

# 检查3: 验证当前总文件数进展
check_total_file_count() {
    echo "=== 检查3: 总文件数进展验证 ==="
    
    local current_count=$(find $POETRY_DIR -name "*.ml" -o -name "*.mli" | wc -l)
    local remaining=$((current_count - TARGET_FILE_COUNT))
    
    echo "当前Poetry文件数: $current_count"
    echo "目标文件数: $TARGET_FILE_COUNT"
    echo "还需减少: $remaining 个文件"
    
    if [ $remaining -gt 0 ]; then
        local progress=$((100 * (370 - current_count) / (370 - TARGET_FILE_COUNT)))
        echo "整合进度: ${progress}%"
        warning "还需要减少 $remaining 个文件才能达到目标"
    else
        success "已达到文件数目标！"
    fi
}

# 检查4: 代码包装模式检测
check_wrapper_patterns() {
    echo "=== 检查4: 包装模式检测 ==="
    
    # 检查是否有简单的API包装模式
    local wrapper_patterns=(
        "let.*=.*\\..*"  # let func = OtherModule.func 模式
        "module.*=.*struct.*end"  # 简单模块包装模式
    )
    
    local staged_files=$(git diff --cached --name-only | grep "\.ml$")
    for file in $staged_files; do
        if [ -f "$file" ]; then
            for pattern in "${wrapper_patterns[@]}"; do
                if grep -q "$pattern" "$file"; then
                    warning "在 $file 中检测到可能的包装模式: $pattern"
                    echo "请确认这是真正的功能合并而非简单包装"
                fi
            done
        fi
    done
    
    success "包装模式检测完成"
}

# 检查5: 编译完整性验证
check_compilation() {
    echo "=== 检查5: 编译完整性验证 ==="
    
    echo "执行编译检查..."
    if ! dune build 2>/dev/null; then
        error "编译失败 - 整合操作破坏了代码结构"
    fi
    
    success "编译检查通过"
}

# 检查6: 功能完整性验证
check_functionality() {
    echo "=== 检查6: 功能完整性验证 ==="
    
    echo "执行测试检查..."
    if ! dune runtest 2>/dev/null; then
        error "测试失败 - 整合操作破坏了功能"
    fi
    
    success "功能完整性检查通过"
}

# 生成整合报告
generate_consolidation_report() {
    echo "=== 整合质量报告 ==="
    
    local current_count=$(find $POETRY_DIR -name "*.ml" -o -name "*.mli" | wc -l)
    local deleted_files=$(git diff --cached --name-status | grep "^D" | grep "$POETRY_DIR" | wc -l)
    local added_files=$(git diff --cached --name-status | grep "^A" | grep "$POETRY_DIR" | wc -l)
    local net_change=$((deleted_files - added_files))
    
    echo "📊 本次提交影响:"
    echo "   删除文件: $deleted_files 个"
    echo "   新增文件: $added_files 个"
    echo "   净减少: $net_change 个文件"
    echo ""
    echo "📈 整体进展:"
    echo "   当前文件数: $current_count"
    echo "   目标文件数: $TARGET_FILE_COUNT"
    echo "   剩余工作: $((current_count - TARGET_FILE_COUNT)) 个文件"
    
    local progress=$((100 * (370 - current_count) / (370 - TARGET_FILE_COUNT)))
    echo "   完成进度: ${progress}%"
}

# 主执行流程
main() {
    echo "开始Poetry模块整合质量控制检查..."
    echo "分支: $CURRENT_BRANCH"
    echo "检查目录: $POETRY_DIR"
    echo ""
    
    check_consolidated_directories
    check_file_reduction  
    check_total_file_count
    check_wrapper_patterns
    check_compilation
    check_functionality
    
    echo ""
    generate_consolidation_report
    
    echo ""
    success "🎯 所有质量控制检查通过！"
    echo "这是一个符合正确整合方法论的操作。"
}

# 执行主函数
main "$@"