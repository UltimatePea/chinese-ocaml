#!/bin/bash
# 骆言内置函数模块覆盖率报告生成脚本
# Coverage Report Generation Script for Builtin Functions Module
# Author: Whisky, PR Worker
# Issue: #2149 - 内置函数模块测试覆盖率提升

echo "骆言内置函数模块覆盖率报告生成 - Fix #2149"
echo "================================================="

# 清理之前的构建文件
echo "清理构建文件..."
dune clean

# 启用覆盖率并运行测试
echo "运行覆盖率测试..."
BISECT_ENABLE=yes dune exec test/builtin/test_builtin_functions_enhanced_comprehensive_2149.exe

# 生成覆盖率报告
echo "生成覆盖率报告..."
bisect-ppx-report summary --per-file --coverage-path=. > coverage_summary.txt

# 提取builtin_functions.ml的覆盖率
echo "提取内置函数模块覆盖率..."
BUILTIN_COVERAGE=$(grep "src/builtin_functions.ml" coverage_summary.txt | awk '{print $1 " " $2}')

echo "================================================="
echo "覆盖率结果："
echo "内置函数模块 (src/builtin_functions.ml): $BUILTIN_COVERAGE"
echo "================================================="

# 检查是否达到80%目标
COVERAGE_PERCENT=$(echo $BUILTIN_COVERAGE | cut -d'%' -f1)
COVERAGE_NUM=$(echo $COVERAGE_PERCENT | tr -d ' ')

if [ "${COVERAGE_NUM%.*}" -ge 80 ]; then
    echo "✓ 覆盖率目标达成: ${COVERAGE_PERCENT}% >= 80%"
    exit 0
else
    echo "✗ 覆盖率目标未达成: ${COVERAGE_PERCENT}% < 80%"
    exit 1
fi