#!/bin/bash

# 骆言项目性能基准测试脚本
# 测试核心模块的性能指标

set -e

echo "⚡ 骆言项目性能基准测试开始..."

BENCHMARK_DIR="benchmarks"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
RESULT_FILE="$BENCHMARK_DIR/benchmark_$TIMESTAMP.txt"

# 创建基准测试目录
mkdir -p "$BENCHMARK_DIR"

echo "📊 性能基准测试 - $TIMESTAMP" > "$RESULT_FILE"
echo "=========================================" >> "$RESULT_FILE"

# 1. 构建性能测试
echo "🔨 测试构建性能..."
BUILD_START=$(date +%s.%N)
dune build > /dev/null 2>&1
BUILD_END=$(date +%s.%N)
BUILD_TIME=$(echo "$BUILD_END - $BUILD_START" | bc -l)
echo "构建时间: ${BUILD_TIME}秒" >> "$RESULT_FILE"
echo "✅ 构建性能: ${BUILD_TIME}秒"

# 2. 测试套件性能
echo "🧪 测试套件性能..."
TEST_START=$(date +%s.%N)
dune test > /dev/null 2>&1
TEST_END=$(date +%s.%N)
TEST_TIME=$(echo "$TEST_END - $TEST_START" | bc -l)
echo "测试时间: ${TEST_TIME}秒" >> "$RESULT_FILE"
echo "✅ 测试性能: ${TEST_TIME}秒"

# 3. 文件统计
echo "" >> "$RESULT_FILE"
echo "项目统计:" >> "$RESULT_FILE"
echo "--------" >> "$RESULT_FILE"
ML_FILES=$(find . -name "*.ml" | wc -l)
MLI_FILES=$(find . -name "*.mli" | wc -l) 
TEST_FILES=$(find . -name "*test*.ml" | wc -l)
echo "源文件数: $ML_FILES" >> "$RESULT_FILE"
echo "接口文件数: $MLI_FILES" >> "$RESULT_FILE"
echo "测试文件数: $TEST_FILES" >> "$RESULT_FILE"

echo "📊 项目统计: $ML_FILES个源文件, $MLI_FILES个接口文件, $TEST_FILES个测试文件"

# 4. 记录系统信息
echo "" >> "$RESULT_FILE"
echo "系统信息:" >> "$RESULT_FILE"
echo "--------" >> "$RESULT_FILE"
echo "OCaml版本: $(ocaml -version)" >> "$RESULT_FILE"
echo "Dune版本: $(dune --version)" >> "$RESULT_FILE"
echo "操作系统: $(uname -s)" >> "$RESULT_FILE"

echo "📈 基准测试结果已保存到: $RESULT_FILE"
echo "🎯 基准指标:"
echo "   - 构建性能: ${BUILD_TIME}秒"
echo "   - 测试性能: ${TEST_TIME}秒"
echo "   - 代码规模: $ML_FILES个源文件"

echo "✅ 性能基准测试完成"