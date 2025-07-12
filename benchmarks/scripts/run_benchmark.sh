#!/bin/bash

# 骆言性能基准测试运行脚本
# Luoyan Language Performance Benchmark Runner

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BENCHMARK_DIR="$PROJECT_ROOT/benchmarks"
RESULTS_DIR="$BENCHMARK_DIR/results"

# 创建结果目录
mkdir -p "$RESULTS_DIR"

# 时间戳
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")
REPORT_FILE="$RESULTS_DIR/benchmark_report_$TIMESTAMP.md"

echo -e "${BLUE}骆言编程语言性能基准测试${NC}"
echo -e "${BLUE}====================================${NC}"

# 初始化报告文件
cat > "$REPORT_FILE" << EOF
# 骆言编程语言性能基准测试报告

**测试时间**: $(date)
**测试环境**: $(uname -a)
**OCaml版本**: $(ocaml -version)

## 测试概述

本报告对比了骆言编程语言与OCaml在相同算法实现下的性能表现。

EOF

# 运行单个基准测试
run_single_benchmark() {
    local benchmark_name="$1"
    local luoyan_file="$2"
    local ocaml_file="$3"
    
    echo -e "\n${YELLOW}>>> 运行基准测试: $benchmark_name${NC}"
    
    # 添加到报告
    echo -e "\n## $benchmark_name\n" >> "$REPORT_FILE"
    
    # 运行骆言版本
    echo -e "${GREEN}运行骆言版本...${NC}"
    cd "$PROJECT_ROOT"
    
    # 执行骆言程序并记录时间和输出
    echo "### 骆言版本结果" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    
    local luoyan_start=$(date +%s.%N)
    if timeout 60s dune exec yyocamlc -- "$luoyan_file" > "$RESULTS_DIR/luoyan_${benchmark_name}_output.txt" 2>&1; then
        local luoyan_end=$(date +%s.%N)
        local luoyan_time=$(echo "$luoyan_end - $luoyan_start" | bc -l)
        
        echo "执行时间: ${luoyan_time}秒" >> "$REPORT_FILE"
        cat "$RESULTS_DIR/luoyan_${benchmark_name}_output.txt" >> "$REPORT_FILE"
        echo -e "${GREEN}✓ 骆言版本执行成功 (耗时: ${luoyan_time}s)${NC}"
    else
        echo "错误: 骆言版本执行失败或超时" >> "$REPORT_FILE"
        cat "$RESULTS_DIR/luoyan_${benchmark_name}_output.txt" >> "$REPORT_FILE"
        echo -e "${RED}✗ 骆言版本执行失败${NC}"
        luoyan_time="timeout/error"
    fi
    echo '```' >> "$REPORT_FILE"
    
    # 运行OCaml版本
    echo -e "${GREEN}运行OCaml版本...${NC}"
    
    echo -e "\n### OCaml版本结果" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    
    local ocaml_start=$(date +%s.%N)
    if timeout 60s ocaml "$ocaml_file" > "$RESULTS_DIR/ocaml_${benchmark_name}_output.txt" 2>&1; then
        local ocaml_end=$(date +%s.%N)
        local ocaml_time=$(echo "$ocaml_end - $ocaml_start" | bc -l)
        
        echo "执行时间: ${ocaml_time}秒" >> "$REPORT_FILE"
        cat "$RESULTS_DIR/ocaml_${benchmark_name}_output.txt" >> "$REPORT_FILE"
        echo -e "${GREEN}✓ OCaml版本执行成功 (耗时: ${ocaml_time}s)${NC}"
    else
        echo "错误: OCaml版本执行失败或超时" >> "$REPORT_FILE"
        cat "$RESULTS_DIR/ocaml_${benchmark_name}_output.txt" >> "$REPORT_FILE"
        echo -e "${RED}✗ OCaml版本执行失败${NC}"
        ocaml_time="timeout/error"
    fi
    echo '```' >> "$REPORT_FILE"
    
    # 性能对比分析
    echo -e "\n### 性能对比" >> "$REPORT_FILE"
    if [[ "$luoyan_time" != "timeout/error" && "$ocaml_time" != "timeout/error" ]]; then
        local ratio=$(echo "scale=2; $luoyan_time / $ocaml_time" | bc -l)
        echo "- **骆言耗时**: ${luoyan_time}秒" >> "$REPORT_FILE"
        echo "- **OCaml耗时**: ${ocaml_time}秒" >> "$REPORT_FILE"
        echo "- **性能比率**: ${ratio}x (骆言/OCaml)" >> "$REPORT_FILE"
        
        if (( $(echo "$ratio < 1.2" | bc -l) )); then
            echo "- **结论**: 性能相当 ✅" >> "$REPORT_FILE"
        elif (( $(echo "$ratio < 2.0" | bc -l) )); then
            echo "- **结论**: 性能略慢，在可接受范围内 ⚠️" >> "$REPORT_FILE"
        else
            echo "- **结论**: 性能明显落后，需要优化 ❌" >> "$REPORT_FILE"
        fi
    else
        echo "- **结论**: 无法进行性能对比（存在执行失败）" >> "$REPORT_FILE"
    fi
    
    echo -e "${BLUE}基准测试 $benchmark_name 完成${NC}"
}

# 主要基准测试列表
declare -a BENCHMARKS=(
    "算术运算,micro/simple_bench.yu,ocaml-equiv/simple_bench.ml"
    "斐波那契数列,macro/fib_bench.yu,ocaml-equiv/fib_bench.ml"
)

# 构建项目
echo -e "${YELLOW}构建骆言编译器...${NC}"
cd "$PROJECT_ROOT"
if ! dune build; then
    echo -e "${RED}构建失败，退出测试${NC}" >&2
    exit 1
fi
echo -e "${GREEN}✓ 构建成功${NC}"

# 运行所有基准测试
for benchmark in "${BENCHMARKS[@]}"; do
    IFS=',' read -r name luoyan_file ocaml_file <<< "$benchmark"
    run_single_benchmark "$name" "$BENCHMARK_DIR/$luoyan_file" "$BENCHMARK_DIR/$ocaml_file"
done

# 生成总结
echo -e "\n## 总结\n" >> "$REPORT_FILE"
echo "本次基准测试对比了骆言编程语言与OCaml在相同算法实现下的性能表现。" >> "$REPORT_FILE"
echo "测试涵盖了微基准测试（如算术运算）和宏基准测试（如算法实现）。" >> "$REPORT_FILE"
echo -e "\n**测试完成时间**: $(date)" >> "$REPORT_FILE"

echo -e "\n${GREEN}=======================================\n${NC}"
echo -e "${GREEN}✓ 所有基准测试完成！${NC}"
echo -e "${BLUE}详细报告保存在: $REPORT_FILE${NC}"
echo -e "${BLUE}=======================================\n${NC}"

# 显示报告文件内容概要
if command -v head >/dev/null 2>&1; then
    echo -e "${YELLOW}报告概要:${NC}"
    head -20 "$REPORT_FILE"
    echo "..."
    echo -e "${BLUE}完整报告请查看: $REPORT_FILE${NC}"
fi