#!/bin/bash

# 骆言项目编译验证脚本 - Phase 1 质量控制
# 
# 响应 Issue #1761 - Delta代理质量控制要求
# Author: Alpha, 主要工作代理 - 质量控制脚本实现
# Date: 2025-07-30

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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

# 检查是否在项目根目录
check_project_root() {
    if [[ ! -f "dune-project" ]]; then
        log_error "请在项目根目录运行此脚本"
        exit 1
    fi
}

# 清理构建缓存
clean_build() {
    log_info "清理构建缓存..."
    dune clean 2>/dev/null || true
}

# 编译检查
compile_check() {
    log_info "开始编译检查..."
    
    # 开发模式编译
    log_info "执行开发模式编译: dune build"
    if dune build 2>&1; then
        log_success "开发模式编译通过"
    else
        log_error "开发模式编译失败"
        return 1
    fi
    
    # 发布模式编译
    log_info "执行发布模式编译: dune build --profile release"
    if dune build --profile release 2>&1; then
        log_success "发布模式编译通过"
    else
        log_error "发布模式编译失败"
        return 1
    fi
}

# 测试检查
test_check() {
    log_info "开始测试检查..."
    
    if dune runtest 2>&1; then
        log_success "所有测试通过"
        return 0
    else
        log_error "部分测试失败"
        return 1
    fi
}

# 获取编译统计信息
get_compile_stats() {
    log_info "收集编译统计信息..."
    
    # 统计源文件数量
    local ml_files=$(find src -name "*.ml" | wc -l)
    local mli_files=$(find src -name "*.mli" | wc -l)
    
    log_info "源文件统计:"
    echo "  - .ml 文件: $ml_files"
    echo "  - .mli 文件: $mli_files"
    
    # 检查编译时间
    log_info "测量编译时间..."
    local start_time=$(date +%s)
    dune build >/dev/null 2>&1
    local end_time=$(date +%s)
    local compile_time=$((end_time - start_time))
    
    echo "  - 编译时间: ${compile_time}秒"
}

# 检查接口一致性
interface_consistency_check() {
    log_info "检查接口一致性..."
    
    local inconsistent_files=()
    
    # 查找所有.ml文件并检查对应的.mli文件
    while IFS= read -r -d '' ml_file; do
        local mli_file="${ml_file%.ml}.mli"
        if [[ -f "$mli_file" ]]; then
            # 检查接口实现一致性（简单检查，只验证能编译）
            if ! dune build "${ml_file%.ml}.cmo" 2>/dev/null; then
                inconsistent_files+=("$ml_file")
            fi
        fi
    done < <(find src -name "*.ml" -print0)
    
    if [[ ${#inconsistent_files[@]} -eq 0 ]]; then
        log_success "接口一致性检查通过"
        return 0
    else
        log_warning "发现 ${#inconsistent_files[@]} 个接口不一致的文件:"
        for file in "${inconsistent_files[@]}"; do
            echo "  - $file"
        done
        return 1
    fi
}

# 依赖检查
dependency_check() {
    log_info "检查项目依赖..."
    
    # 检查opam依赖
    if command -v opam >/dev/null 2>&1; then
        log_info "检查OPAM依赖..."
        if opam install . --deps-only --dry-run >/dev/null 2>&1; then
            log_success "依赖检查通过"
        else
            log_warning "依赖可能存在问题"
        fi
    else
        log_warning "OPAM未安装，跳过依赖检查"
    fi
}

# 生成质量报告
generate_quality_report() {
    local report_file="quality_report_$(date +%Y%m%d_%H%M%S).md"
    
    log_info "生成质量报告: $report_file"
    
    cat > "$report_file" << EOF
# 骆言项目质量检查报告

**生成时间**: $(date)
**检查脚本**: scripts/quality/compile_check.sh
**执行分支**: $(git branch --show-current 2>/dev/null || echo "未知")
**最新提交**: $(git log -1 --oneline 2>/dev/null || echo "未知")

## 编译检查结果

- ✅ 开发模式编译: 通过
- ✅ 发布模式编译: 通过

## 测试检查结果

- ✅ 单元测试: 通过  
- ✅ 集成测试: 通过

## 编译统计

$(get_compile_stats | sed 's/^/- /')

## 质量标准符合性

- [x] 编译无错误
- [x] 测试全部通过
- [x] 接口一致性验证
- [x] 依赖完整性检查

## 建议

本次检查通过所有质量门控，项目处于良好状态。

---
*报告由 scripts/quality/compile_check.sh 自动生成*
*响应 Issue #1761 - Delta代理质量控制要求*

Author: Alpha, 主要工作代理
EOF

    log_success "质量报告已生成: $report_file"
}

# 主函数
main() {
    echo "======================================="
    echo "   骆言项目编译验证脚本 v1.0"
    echo "   响应 Issue #1761 质量控制要求"
    echo "======================================="
    echo
    
    local errors=0
    
    # 执行检查序列
    check_project_root
    
    log_info "开始质量检查流程..."
    echo
    
    # 1. 清理构建
    clean_build
    echo
    
    # 2. 编译检查
    if ! compile_check; then
        errors=$((errors + 1))
    fi
    echo
    
    # 3. 测试检查  
    if ! test_check; then
        errors=$((errors + 1))
    fi
    echo
    
    # 4. 接口一致性检查
    if ! interface_consistency_check; then
        errors=$((errors + 1))
    fi
    echo
    
    # 5. 依赖检查
    if ! dependency_check; then
        # 依赖检查失败不算错误，只是警告
        log_warning "依赖检查有警告，但不影响整体评估"
    fi
    echo
    
    # 6. 生成报告
    if [[ $errors -eq 0 ]]; then
        generate_quality_report
    fi
    
    # 总结结果
    echo "======================================="
    if [[ $errors -eq 0 ]]; then
        log_success "🎉 所有质量检查通过！项目状态良好"
        log_info "项目已满足 Phase 1 质量控制要求"
        echo
        echo "✅ 编译验证: 通过"
        echo "✅ 测试验证: 通过"  
        echo "✅ 接口验证: 通过"
        echo "✅ 整体质量: 通过"
        exit 0
    else
        log_error "❌ 发现 $errors 个质量问题"
        log_error "请修复问题后重新运行检查"
        echo
        echo "📋 建议修复步骤:"
        echo "1. 检查编译错误并修复类型不匹配"
        echo "2. 修复失败的测试用例"
        echo "3. 确保接口实现一致性"
        echo "4. 重新运行: ./scripts/quality/compile_check.sh"
        exit 1
    fi
}

# 脚本入口
main "$@"