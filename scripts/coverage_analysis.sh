#!/bin/bash

# 骆言项目代码覆盖率分析脚本 - Phase 25 测试覆盖率提升
# 
# 本脚本使用 bisect_ppx 工具进行代码覆盖率分析，生成详细的覆盖率报告
# 并提供改进建议，支持CI/CD集成和趋势追踪。
#
# 功能特性：
# - 自动化覆盖率测试和报告生成
# - 模块级和函数级覆盖率分析  
# - 覆盖率趋势追踪和对比
# - CI/CD友好的退出码和输出格式
# - 详细的改进建议生成
#
# @author 骆言技术债务清理团队 - Phase 25
# @version 1.0
# @since 2025-07-20 Issue #678 核心模块测试覆盖率提升

set -euo pipefail

# 脚本配置
SCRIPT_NAME="coverage_analysis.sh"
COVERAGE_DIR="coverage_reports"
COVERAGE_TARGET_MIN=45.0
COVERAGE_TARGET_IDEAL=60.0
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_FILE="${COVERAGE_DIR}/coverage_report_${TIMESTAMP}.md"

# 颜色输出配置
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

log_header() {
    echo -e "${CYAN}[HEADER]${NC} $1"
}

# 检查必要工具
check_dependencies() {
    log_info "检查必要工具..."
    
    local missing_tools=()
    
    if ! command -v dune >/dev/null 2>&1; then
        missing_tools+=("dune")
    fi
    
    if ! command -v bisect-ppx-report >/dev/null 2>&1; then
        missing_tools+=("bisect-ppx-report")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "缺少必要工具: ${missing_tools[*]}"
        log_info "请安装缺少的工具："
        for tool in "${missing_tools[@]}"; do
            case $tool in
                "dune")
                    echo "  opam install dune"
                    ;;
                "bisect-ppx-report")
                    echo "  opam install bisect_ppx"
                    ;;
            esac
        done
        exit 1
    fi
    
    log_success "所有必要工具已安装"
}

# 创建覆盖率报告目录
setup_directories() {
    log_info "设置目录结构..."
    
    mkdir -p "${COVERAGE_DIR}"
    mkdir -p "${COVERAGE_DIR}/html"
    mkdir -p "${COVERAGE_DIR}/data"
    
    log_success "目录结构创建完成"
}

# 清理之前的覆盖率数据
cleanup_previous_data() {
    log_info "清理之前的覆盖率数据..."
    
    # 清理 bisect 数据文件
    find . -name "bisect*.coverage" -delete 2>/dev/null || true
    find . -name "_coverage" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # 清理构建缓存以确保重新编译
    dune clean >/dev/null 2>&1 || true
    
    log_success "清理完成"
}

# 构建带覆盖率插桩的项目
build_with_coverage() {
    log_info "构建带覆盖率插桩的项目..."
    
    # 设置覆盖率环境变量
    export BISECT_ENABLE=yes
    export BISECT_FILE="_coverage/bisect"
    
    # 创建覆盖率数据目录
    mkdir -p _coverage
    
    # 使用 bisect_ppx 构建
    if ! dune build --instrument-with bisect_ppx; then
        log_error "项目构建失败"
        exit 1
    fi
    
    log_success "项目构建完成"
}

# 运行测试并收集覆盖率数据
run_tests_with_coverage() {
    log_info "运行测试并收集覆盖率数据..."
    
    # 设置环境变量
    export BISECT_ENABLE=yes
    # Note: BISECT_FILE prefix - coverage files will be generated as bisect*.coverage
    
    # 运行所有测试 - 修复：使用dune exec模式以确保覆盖率文件正确生成
    log_info "运行核心测试以收集覆盖率数据..."
    
    # 运行关键测试以收集覆盖率数据
    test_targets=(
        "test/arrays.exe"
        "test/simple_integration.exe"
        "test/test_core_coverage_enhanced.exe"
        "test/test_semantic_comprehensive_enhanced.exe"
        "test/test_lexer_comprehensive_enhanced.exe"
    )
    
    tests_run=0
    for test_target in "${test_targets[@]}"; do
        if dune exec "$test_target" 2>/dev/null; then
            tests_run=$((tests_run + 1))
            log_info "✅ $test_target 执行成功"
        else
            log_warning "⚠️ $test_target 执行失败或不存在"
        fi
    done
    
    log_info "执行了 $tests_run 个测试目标"
    
    # 如果没有运行任何测试，回退到标准方式
    if [ $tests_run -eq 0 ]; then
        log_warning "回退到标准测试运行方式"
        if ! dune runtest --instrument-with bisect_ppx; then
            log_warning "部分测试可能失败，但继续生成覆盖率报告"
        fi
    fi
    
    # 检查是否生成了覆盖率数据文件
    coverage_files=$(find . -name "bisect*.coverage" 2>/dev/null || true)
    if [ -n "$coverage_files" ]; then
        log_info "找到 $(echo $coverage_files | wc -w) 个覆盖率数据文件"
        log_success "测试运行完成，覆盖率数据已收集"
    else
        log_warning "未找到覆盖率文件，但测试已执行完成"
        # 检查_build目录中是否有覆盖率数据
        if [ -d "_build" ]; then
            coverage_files=$(find _build -name "bisect*.coverage" 2>/dev/null || true)
            if [ -n "$coverage_files" ]; then
                log_info "在_build目录中找到覆盖率文件"
                # 复制到当前目录以便报告生成
                for file in $coverage_files; do
                    cp "$file" . 2>/dev/null || true
                done
                coverage_files=$(find . -name "bisect*.coverage" 2>/dev/null || true)
            fi
        fi
        
        if [ -z "$coverage_files" ]; then
            log_warning "未能收集到任何覆盖率数据"
        fi
    fi
}

# 生成覆盖率报告
generate_coverage_report() {
    log_info "生成覆盖率报告..."
    
    # 检查是否有覆盖率文件可用
    coverage_files=$(find . -name "bisect*.coverage" 2>/dev/null || true)
    
    if [ -z "$coverage_files" ]; then
        log_warning "未找到覆盖率文件，尝试使用_coverage目录"
        coverage_files=$(find _coverage -name "*.coverage" 2>/dev/null || true)
        coverage_files_param="_coverage/*.coverage"
    else
        log_info "使用当前目录中的覆盖率文件: $(echo $coverage_files | wc -w) 个文件"
        coverage_files_param="bisect*.coverage"
    fi
    
    # 生成 HTML 报告
    if [ -n "$coverage_files" ] && bisect-ppx-report html -o "${COVERAGE_DIR}/html/" $coverage_files_param 2>/dev/null; then
        log_success "HTML覆盖率报告生成完成: ${COVERAGE_DIR}/html/index.html"
    else
        log_warning "HTML报告生成失败，尝试使用默认模式"
        # 创建一个简单的HTML报告占位符
        mkdir -p "${COVERAGE_DIR}/html"
        cat > "${COVERAGE_DIR}/html/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head><title>覆盖率报告</title></head>
<body>
<h1>覆盖率报告生成中...</h1>
<p>bisect_ppx覆盖率数据收集存在问题，请检查测试执行是否正确启用了覆盖率插桩。</p>
</body>
</html>
EOF
    fi
    
    # 生成汇总报告
    if [ -n "$coverage_files" ] && bisect-ppx-report summary $coverage_files_param > "${COVERAGE_DIR}/data/summary_${TIMESTAMP}.txt" 2>/dev/null; then
        log_success "汇总报告生成完成"
    else
        log_warning "汇总报告生成失败，创建备用报告"
        # 创建一个基本的汇总报告
        cat > "${COVERAGE_DIR}/data/summary_${TIMESTAMP}.txt" << 'EOF'
总体覆盖率: 0.00%
注意：bisect_ppx数据收集存在问题，此报告可能不准确。
请检查dune配置中的bisect_ppx设置。
EOF
    fi
    
    # 不生成CSV报告，因为bisect-ppx-report不支持csv命令
    log_info "bisect-ppx-report不支持CSV格式，跳过CSV报告生成"
}

# 分析覆盖率数据
analyze_coverage_data() {
    log_info "分析覆盖率数据..."
    
    # 提取总体覆盖率
    local summary_file="${COVERAGE_DIR}/data/summary_${TIMESTAMP}.txt"
    if [ -f "$summary_file" ]; then
        local overall_coverage=$(grep -o '[0-9]*\.[0-9]*%' "$summary_file" | head -1 | sed 's/%//')
        
        if [ -n "$overall_coverage" ]; then
            echo "$overall_coverage" > "${COVERAGE_DIR}/data/latest_coverage.txt"
            
            # 判断覆盖率等级
            if (( $(echo "$overall_coverage >= $COVERAGE_TARGET_IDEAL" | bc -l) )); then
                log_success "覆盖率 ${overall_coverage}% - 优秀 (≥${COVERAGE_TARGET_IDEAL}%)"
                COVERAGE_GRADE="优秀"
                COVERAGE_EMOJI="🏆"
            elif (( $(echo "$overall_coverage >= $COVERAGE_TARGET_MIN" | bc -l) )); then
                log_success "覆盖率 ${overall_coverage}% - 良好 (≥${COVERAGE_TARGET_MIN}%)"
                COVERAGE_GRADE="良好"
                COVERAGE_EMOJI="✅"
            else
                log_warning "覆盖率 ${overall_coverage}% - 需要改进 (<${COVERAGE_TARGET_MIN}%)"
                COVERAGE_GRADE="需要改进"
                COVERAGE_EMOJI="⚠️"
            fi
        else
            log_error "无法解析覆盖率数据"
            overall_coverage="未知"
            COVERAGE_GRADE="未知"
            COVERAGE_EMOJI="❓"
        fi
    else
        log_error "找不到汇总报告文件"
        overall_coverage="未知"
        COVERAGE_GRADE="未知"
        COVERAGE_EMOJI="❓"
    fi
    
    # 导出变量供后续使用
    export OVERALL_COVERAGE="$overall_coverage"
    export COVERAGE_GRADE
    export COVERAGE_EMOJI
}

# 生成Markdown报告
generate_markdown_report() {
    log_info "生成Markdown覆盖率报告..."
    
    cat > "$REPORT_FILE" << EOF
# 骆言项目代码覆盖率分析报告

## 基本信息
- 分析时间: $(date '+%Y-%m-%d %H:%M:%S')
- 项目路径: $(pwd)
- Git分支: $(git branch --show-current 2>/dev/null || echo "未知")
- Git提交: $(git rev-parse --short HEAD 2>/dev/null || echo "未知")

## 覆盖率概览

### ${COVERAGE_EMOJI} 总体覆盖率: ${OVERALL_COVERAGE}% (${COVERAGE_GRADE})

| 指标 | 当前值 | 目标值 | 状态 |
|------|--------|--------|------|
| 总体覆盖率 | ${OVERALL_COVERAGE}% | ≥${COVERAGE_TARGET_MIN}% | $([ "$COVERAGE_GRADE" != "需要改进" ] && echo "✅ 达标" || echo "❌ 未达标") |
| 理想覆盖率 | ${OVERALL_COVERAGE}% | ≥${COVERAGE_TARGET_IDEAL}% | $([ "$COVERAGE_GRADE" = "优秀" ] && echo "🏆 优秀" || echo "⚠️ 待提升") |

## 详细分析

### 模块覆盖率分布
EOF

    # 如果CSV文件存在，分析模块覆盖率
    local csv_file="${COVERAGE_DIR}/data/details_${TIMESTAMP}.csv"
    if [ -f "$csv_file" ]; then
        echo "" >> "$REPORT_FILE"
        echo "| 模块 | 覆盖率 | 状态 |" >> "$REPORT_FILE"
        echo "|------|--------|------|" >> "$REPORT_FILE"
        
        # 简单分析（实际实现会更复杂）
        echo "| parser模块 | 待分析 | 🔍 需要详细分析 |" >> "$REPORT_FILE"
        echo "| poetry模块 | 待分析 | 🔍 需要详细分析 |" >> "$REPORT_FILE"
        echo "| lexer模块 | 待分析 | 🔍 需要详细分析 |" >> "$REPORT_FILE"
    fi

    cat >> "$REPORT_FILE" << EOF

## 改进建议

### 🎯 短期目标 (1-2周)
- [ ] 重点关注覆盖率低于30%的模块
- [ ] 为核心解析器函数添加单元测试
- [ ] 增加诗词处理模块的边界测试

### ⚡ 中期目标 (1个月)
- [ ] 将总体覆盖率提升至${COVERAGE_TARGET_MIN}%以上
- [ ] 建立覆盖率回归保护机制
- [ ] 集成覆盖率检查到CI/CD流程

### 🚀 长期目标 (持续)
- [ ] 达到${COVERAGE_TARGET_IDEAL}%的理想覆盖率
- [ ] 建立全面的集成测试框架
- [ ] 实现性能测试覆盖率监控

## 技术建议

### 测试增强重点
1. **解析器模块**: 增加表达式解析的边界测试
2. **诗词模块**: 完善韵律分析和评价算法测试
3. **词法分析**: 加强Unicode和中文字符处理测试
4. **错误处理**: 建立全面的异常情况测试

### 工具和自动化
- ✅ 已集成 bisect_ppx 覆盖率工具
- ✅ 自动化覆盖率报告生成
- 🔄 建议集成到CI/CD流程
- 📊 建立覆盖率趋势追踪

## 文件列表

### 生成的报告文件
- HTML报告: [${COVERAGE_DIR}/html/index.html](${COVERAGE_DIR}/html/index.html)
- 汇总数据: [${COVERAGE_DIR}/data/summary_${TIMESTAMP}.txt](${COVERAGE_DIR}/data/summary_${TIMESTAMP}.txt)
- 详细数据: [${COVERAGE_DIR}/data/details_${TIMESTAMP}.csv](${COVERAGE_DIR}/data/details_${TIMESTAMP}.csv)

### 使用方法
\`\`\`bash
# 重新生成覆盖率报告
./scripts/coverage_analysis.sh

# 查看HTML报告
open ${COVERAGE_DIR}/html/index.html

# 查看趋势数据
cat ${COVERAGE_DIR}/data/latest_coverage.txt
\`\`\`

## 项目价值

### 🟢 积极影响
- **质量保障**: 高覆盖率提供更好的回归测试保护
- **重构支持**: 安全的代码重构和优化
- **开发信心**: 减少功能变更的风险
- **文档价值**: 测试用例作为使用示例

### 📊 关键指标追踪
- 当前覆盖率: ${OVERALL_COVERAGE}%
- 目标覆盖率: ${COVERAGE_TARGET_MIN}%+
- 理想覆盖率: ${COVERAGE_TARGET_IDEAL}%+
- 测试数量: $(find test/ -name "*.ml" | wc -l) 个测试文件

---
*报告生成时间: $(date '+%Y-%m-%d %H:%M:%S')*  
*生成工具: 骆言覆盖率分析脚本 v1.0*
EOF

    log_success "Markdown报告生成完成: $REPORT_FILE"
}

# 检查覆盖率目标
check_coverage_target() {
    log_info "检查覆盖率目标..."
    
    if [ "$OVERALL_COVERAGE" != "未知" ]; then
        if (( $(echo "$OVERALL_COVERAGE >= $COVERAGE_TARGET_MIN" | bc -l) )); then
            log_success "覆盖率目标达成: ${OVERALL_COVERAGE}% ≥ ${COVERAGE_TARGET_MIN}%"
            return 0
        else
            log_warning "覆盖率目标未达成: ${OVERALL_COVERAGE}% < ${COVERAGE_TARGET_MIN}%"
            return 1
        fi
    else
        log_error "无法确定覆盖率"
        return 1
    fi
}

# 清理临时文件
cleanup() {
    log_info "清理临时文件..."
    
    # 清理 bisect 数据文件（保留报告） - 注意：仅在报告生成完成后清理
    find . -name "bisect*.coverage" -delete 2>/dev/null || true
    rm -rf _coverage 2>/dev/null || true
    
    log_success "清理完成"
}

# 显示使用帮助
show_help() {
    cat << EOF
骆言项目代码覆盖率分析脚本

用法: $SCRIPT_NAME [选项]

选项:
  -h, --help              显示此帮助信息
  -t, --target PERCENT    设置最小覆盖率目标 (默认: ${COVERAGE_TARGET_MIN}%)
  -i, --ideal PERCENT     设置理想覆盖率目标 (默认: ${COVERAGE_TARGET_IDEAL}%)
  -k, --keep-data         保留中间数据文件
  -q, --quiet             静默模式，减少输出信息
  -v, --verbose           详细模式，显示更多信息

示例:
  $SCRIPT_NAME                    # 使用默认设置运行分析
  $SCRIPT_NAME -t 50              # 设置最小目标为50%
  $SCRIPT_NAME -k                 # 保留中间数据文件
  $SCRIPT_NAME -t 45 -i 65        # 自定义目标值

退出码:
  0 - 成功且覆盖率达标
  1 - 成功但覆盖率未达标
  2 - 执行过程中出现错误
EOF
}

# 解析命令行参数
parse_arguments() {
    local keep_data=false
    local quiet=false
    local verbose=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -t|--target)
                COVERAGE_TARGET_MIN="$2"
                shift 2
                ;;
            -i|--ideal)
                COVERAGE_TARGET_IDEAL="$2"
                shift 2
                ;;
            -k|--keep-data)
                keep_data=true
                shift
                ;;
            -q|--quiet)
                quiet=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 2
                ;;
        esac
    done
    
    # 导出配置
    export KEEP_DATA=$keep_data
    export QUIET=$quiet
    export VERBOSE=$verbose
}

# 主函数
main() {
    log_header "骆言项目代码覆盖率分析 - Phase 25"
    log_header "========================================================"
    
    parse_arguments "$@"
    
    check_dependencies
    setup_directories
    cleanup_previous_data
    build_with_coverage
    run_tests_with_coverage
    generate_coverage_report
    analyze_coverage_data
    generate_markdown_report
    
    # 显示结果总结
    echo
    log_header "分析完成总结"
    echo "📊 总体覆盖率: ${COVERAGE_EMOJI} ${OVERALL_COVERAGE}% (${COVERAGE_GRADE})"
    echo "📄 详细报告: $REPORT_FILE"
    echo "🌐 HTML报告: ${COVERAGE_DIR}/html/index.html"
    echo
    
    # 检查目标并设置退出码
    if check_coverage_target; then
        log_success "覆盖率分析成功完成！"
        exit_code=0
    else
        log_warning "覆盖率分析完成，但未达到目标"
        exit_code=1
    fi
    
    # 清理（除非指定保留数据）
    if [ "$KEEP_DATA" != "true" ]; then
        cleanup
    fi
    
    exit $exit_code
}

# 错误处理
trap 'log_error "脚本执行过程中发生错误"; exit 2' ERR

# 运行主函数
main "$@"