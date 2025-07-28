#!/bin/bash

# 骆言编译器增强测试运行器
# Enhanced Luoyan Compiler Test Runner
# Author: Echo, 测试工程师代理
# 创建时间: 2025-07-28
# 目的: 现代化测试运行，支持并行执行和详细报告

set -e

# 配置参数 
PARALLEL_JOBS=${PARALLEL_JOBS:-4}
VERBOSE=${VERBOSE:-false}
COVERAGE_REPORT=${COVERAGE_REPORT:-false}
TIMEOUT_SECONDS=${TIMEOUT_SECONDS:-30}

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 统计变量
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0
START_TIME=$(date +%s)

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

log_test() {
    echo -e "${PURPLE}[TEST]${NC} $1"
}

# 显示使用说明
show_usage() {
    cat <<EOF
骆言编译器增强测试运行器

用法: $0 [选项] [测试模式]

选项:
  -p, --parallel JOBS     并行作业数 (默认: 4)
  -v, --verbose          详细输出模式
  -c, --coverage         生成覆盖率报告
  -t, --timeout SEC      测试超时时间 (默认: 30)
  -h, --help            显示此帮助信息

测试模式:
  unit                   只运行单元测试
  integration           只运行集成测试
  performance           只运行性能测试
  all                   运行所有测试 (默认)
  quick                 快速测试 (跳过性能测试)

示例:
  $0                     # 运行所有测试
  $0 unit                # 只运行单元测试
  $0 -v -c all          # 详细模式运行所有测试并生成覆盖率报告
  $0 --parallel 8 quick  # 8并行快速测试

环境变量:
  PARALLEL_JOBS         并行作业数
  VERBOSE              详细模式 (true/false)
  COVERAGE_REPORT      覆盖率报告 (true/false)
  TIMEOUT_SECONDS      超时时间
EOF
}

# 解析命令行参数
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--parallel)
                PARALLEL_JOBS="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -c|--coverage)
                COVERAGE_REPORT=true
                shift
                ;;
            -t|--timeout)
                TIMEOUT_SECONDS="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            unit|integration|performance|all|quick)
                TEST_MODE="$1"
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# 检查环境和依赖
check_environment() {
    log_info "检查环境和依赖..."
    
    # 检查是否在正确的目录
    if [ ! -f "dune-project" ]; then
        log_error "请在项目根目录运行此脚本"
        exit 1
    fi
    
    # 检查dune是否可用
    if ! command -v dune &> /dev/null; then
        log_error "dune命令未找到，请确保已安装OCaml构建工具"
        exit 1
    fi
    
    # 检查并行工具
    if ! command -v parallel &> /dev/null && [ "$PARALLEL_JOBS" -gt 1 ]; then
        log_warning "parallel命令未找到，将使用串行执行"
        PARALLEL_JOBS=1
    fi
    
    log_success "环境检查完成"
}

# 构建项目
build_project() {
    log_info "构建项目..."
    
    if [ "$VERBOSE" = true ]; then
        dune build --verbose
    else
        dune build 2>/dev/null || {
            log_error "项目构建失败"
            exit 1
        }
    fi
    
    log_success "项目构建成功"
}

# 运行单个测试模块
run_single_test() {
    local test_name="$1"
    local test_command="$2"
    local test_category="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    local temp_log="/tmp/test_${test_name//\//_}_$$.log"
    local start_time=$(date +%s)
    
    log_test "运行 [$test_category] $test_name"
    
    if [ "$VERBOSE" = true ]; then
        echo "  命令: $test_command"
    fi
    
    # 使用timeout运行测试
    if timeout "$TIMEOUT_SECONDS" bash -c "$test_command" > "$temp_log" 2>&1; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        log_success "✓ [$test_category] $test_name (${duration}s)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        
        if [ "$VERBOSE" = true ]; then
            echo "  输出: $(head -n 3 "$temp_log" | tr '\n' ' ')"
        fi
    else
        local exit_code=$?
        log_error "✗ [$test_category] $test_name"
        
        if [ $exit_code -eq 124 ]; then
            log_error "  原因: 超时 (${TIMEOUT_SECONDS}s)"
        else
            log_error "  原因: 测试失败 (退出码: $exit_code)"
        fi
        
        echo "  错误输出:"
        sed 's/^/    /' "$temp_log"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    rm -f "$temp_log"
}

# 获取测试列表
get_test_list() {
    local mode="$1"
    
    case "$mode" in
        unit)
            echo "单元测试 dune exec test/unit/test_lexer.exe"
            echo "单元测试 dune exec test/unit/test_parser.exe"
            echo "单元测试 dune exec test/unit/test_semantic.exe"
            echo "单元测试 dune exec test/unit/test_types.exe"
            echo "单元测试 dune exec test/unit/test_ast.exe"
            ;;
        integration)
            echo "集成测试 dune exec test/integration_extended/simple_integration.exe"
            echo "集成测试 dune exec test/integration_extended/chinese_best_practices.exe"
            ;;
        performance)
            echo "性能测试 dune exec test/performance/test_simple_coverage_boost.exe"
            ;;
        quick)
            get_test_list unit
            get_test_list integration
            ;;
        all|*)
            get_test_list unit
            get_test_list integration
            get_test_list performance
            ;;
    esac
}

# 并行运行测试
run_tests_parallel() {
    local test_mode="${1:-all}"
    
    log_info "开始并行测试执行 (模式: $test_mode, 并行度: $PARALLEL_JOBS)"
    
    # 创建测试任务文件
    local job_file="/tmp/test_jobs_$$.txt"
    get_test_list "$test_mode" > "$job_file"
    
    if [ ! -s "$job_file" ]; then
        log_warning "没有找到匹配的测试"
        rm -f "$job_file"
        return
    fi
    
    local test_count=$(wc -l < "$job_file")
    log_info "找到 $test_count 个测试任务"
    
    # 使用parallel或者串行执行
    if [ "$PARALLEL_JOBS" -gt 1 ] && command -v parallel &> /dev/null; then
        export -f run_single_test log_test log_success log_error
        export VERBOSE TIMEOUT_SECONDS RED GREEN YELLOW BLUE PURPLE NC
        
        parallel -j "$PARALLEL_JOBS" --colsep ' ' run_single_test {2} {3} {1} :::: "$job_file"
    else
        # 串行执行
        while IFS=' ' read -r category name command; do
            run_single_test "$name" "$command" "$category"
        done < "$job_file"
    fi
    
    rm -f "$job_file"
}

# 生成覆盖率报告
generate_coverage_report() {
    if [ "$COVERAGE_REPORT" = true ]; then
        log_info "生成覆盖率报告..."
        
        if command -v bisect-ppx-report &> /dev/null; then
            bisect-ppx-report html --source-path . --coverage-path _build/
            log_success "覆盖率报告已生成: _coverage/index.html"
        else
            log_warning "bisect-ppx-report未找到，跳过覆盖率报告生成"
        fi
    fi
}

# 显示测试总结
show_summary() {
    local end_time=$(date +%s)
    local total_duration=$((end_time - START_TIME))
    
    echo ""
    echo "=================================================="
    echo -e "${CYAN}测试结果总结${NC}"
    echo "=================================================="
    echo -e "总测试数: ${TOTAL_TESTS}"
    echo -e "${GREEN}通过: ${PASSED_TESTS}${NC}"
    echo -e "${RED}失败: ${FAILED_TESTS}${NC}"
    
    if [ $SKIPPED_TESTS -gt 0 ]; then
        echo -e "${YELLOW}跳过: ${SKIPPED_TESTS}${NC}"
    fi
    
    echo -e "总用时: ${total_duration}s"
    echo -e "平均用时: $((total_duration / (TOTAL_TESTS > 0 ? TOTAL_TESTS : 1)))s/测试"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 所有测试都通过了！${NC}"
        echo "=================================================="
        exit 0
    else
        local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
        echo -e "${RED}❌ 有 ${FAILED_TESTS} 个测试失败 (成功率: ${success_rate}%)${NC}"
        echo "=================================================="
        exit 1
    fi
}

# 主函数
main() {
    local test_mode="all"
    
    # 解析参数
    parse_args "$@"
    
    # 显示启动信息
    echo -e "${CYAN}骆言编译器增强测试运行器${NC}"
    echo -e "作者: Echo, 测试工程师代理"
    echo -e "时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # 执行测试流程
    check_environment
    build_project
    run_tests_parallel "${test_mode:-all}"
    generate_coverage_report
    show_summary
}

# 捕获中断信号
trap 'log_warning "测试被中断"; exit 130' INT TERM

# 运行主函数
main "$@"