#!/bin/bash
# 骆言项目性能检查脚本
# 用于监控和分析项目性能指标

set -e

echo "⚡ 骆言项目性能基准测试"
echo "检查时间: $(date)"
echo "====================================="

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
PERF_DIR="performance_reports"
PERF_FILE="$PERF_DIR/performance_report_$TIMESTAMP.md"

# 创建性能报告目录
mkdir -p "$PERF_DIR"

# 开始生成性能报告
cat > "$PERF_FILE" << 'EOF'
# 骆言项目性能基准报告

## 基本信息
EOF

echo "- 测试时间: $(date)" >> "$PERF_FILE"
echo "- Git分支: $(git branch --show-current)" >> "$PERF_FILE"
echo "- Git提交: $(git rev-parse --short HEAD)" >> "$PERF_FILE"
echo "" >> "$PERF_FILE"

# 1. 编译性能测试
echo "🔨 测试编译性能..."
echo "## 编译性能" >> "$PERF_FILE"

# 清理并重新构建以获取准确的编译时间
dune clean > /dev/null 2>&1

echo "执行全量构建性能测试..."
BUILD_START=$(date +%s.%N)
dune build > /dev/null 2>&1
BUILD_END=$(date +%s.%N)
BUILD_TIME=$(echo "$BUILD_END - $BUILD_START" | bc -l)

echo "- 全量构建时间: ${BUILD_TIME}秒" >> "$PERF_FILE"

# 增量构建测试
echo "测试增量构建性能..."
INCR_BUILD_START=$(date +%s.%N)
dune build > /dev/null 2>&1
INCR_BUILD_END=$(date +%s.%N)
INCR_BUILD_TIME=$(echo "$INCR_BUILD_END - $INCR_BUILD_START" | bc -l)

echo "- 增量构建时间: ${INCR_BUILD_TIME}秒" >> "$PERF_FILE"

if (( $(echo "$BUILD_TIME < 10.0" | bc -l) )); then
    echo "- ✅ 构建性能：优秀 (<10秒)" >> "$PERF_FILE"
    echo "✅ 构建性能：优秀 (${BUILD_TIME}秒)"
elif (( $(echo "$BUILD_TIME < 30.0" | bc -l) )); then
    echo "- ⚠️  构建性能：良好 (10-30秒)" >> "$PERF_FILE"
    echo "⚠️  构建性能：良好 (${BUILD_TIME}秒)"
else
    echo "- ❌ 构建性能：需优化 (>30秒)" >> "$PERF_FILE"
    echo "❌ 构建性能：需优化 (${BUILD_TIME}秒)"
fi

echo "" >> "$PERF_FILE"

# 2. 测试执行性能
echo "🧪 测试执行性能..."
echo "## 测试性能" >> "$PERF_FILE"

TEST_START=$(date +%s.%N)
dune test > /dev/null 2>&1
TEST_END=$(date +%s.%N)
TEST_TIME=$(echo "$TEST_END - $TEST_START" | bc -l)

echo "- 测试套件执行时间: ${TEST_TIME}秒" >> "$PERF_FILE"

if (( $(echo "$TEST_TIME < 5.0" | bc -l) )); then
    echo "- ✅ 测试性能：优秀 (<5秒)" >> "$PERF_FILE"
    echo "✅ 测试性能：优秀 (${TEST_TIME}秒)"
elif (( $(echo "$TEST_TIME < 15.0" | bc -l) )); then
    echo "- ⚠️  测试性能：良好 (5-15秒)" >> "$PERF_FILE"
    echo "⚠️  测试性能：良好 (${TEST_TIME}秒)"
else
    echo "- ❌ 测试性能：需优化 (>15秒)" >> "$PERF_FILE"
    echo "❌ 测试性能：需优化 (${TEST_TIME}秒)"
fi

echo "" >> "$PERF_FILE"

# 3. 诗词处理性能测试
echo "🎨 测试诗词处理性能..."
echo "## 诗词处理性能" >> "$PERF_FILE"

if [ -f "test/test_poetry_rhyme_analysis.ml" ]; then
    echo "测试韵律分析性能..."
    POETRY_START=$(date +%s.%N)
    dune exec test/test_poetry_rhyme_analysis.exe > /dev/null 2>&1
    POETRY_END=$(date +%s.%N)
    POETRY_TIME=$(echo "$POETRY_END - $POETRY_START" | bc -l)
    
    echo "- 韵律分析测试时间: ${POETRY_TIME}秒" >> "$PERF_FILE"
    echo "✅ 韵律分析性能：${POETRY_TIME}秒"
else
    echo "- ⚠️  韵律分析测试文件未找到" >> "$PERF_FILE"
    echo "⚠️  韵律分析测试未执行"
fi

echo "" >> "$PERF_FILE"

# 4. 内存使用情况
echo "💾 检查内存使用..."
echo "## 内存使用" >> "$PERF_FILE"

# 检查构建产物大小
BUILD_SIZE=$(du -sh _build 2>/dev/null | cut -f1 || echo "0")
echo "- 构建产物大小: $BUILD_SIZE" >> "$PERF_FILE"

# 检查源码大小
SRC_SIZE=$(du -sh src | cut -f1)
echo "- 源码大小: $SRC_SIZE" >> "$PERF_FILE"

echo "✅ 构建产物：$BUILD_SIZE"
echo "✅ 源码大小：$SRC_SIZE"
echo "" >> "$PERF_FILE"

# 5. 项目规模指标
echo "📊 项目规模分析..."
echo "## 项目规模" >> "$PERF_FILE"

ML_FILES=$(find src -name "*.ml" | wc -l)
MLI_FILES=$(find src -name "*.mli" | wc -l)
TOTAL_LINES=$(find src -name "*.ml" -exec wc -l {} + | tail -1 | awk '{print $1}')
TEST_FILES=$(find test -name "*.ml" | wc -l)

echo "- 实现文件数量: $ML_FILES" >> "$PERF_FILE"
echo "- 接口文件数量: $MLI_FILES" >> "$PERF_FILE"
echo "- 总代码行数: $TOTAL_LINES" >> "$PERF_FILE"
echo "- 测试文件数量: $TEST_FILES" >> "$PERF_FILE"

if [ $ML_FILES -gt 0 ]; then
    AVG_LENGTH=$(echo "scale=0; $TOTAL_LINES / $ML_FILES" | bc -l)
    echo "- 平均文件长度: ${AVG_LENGTH}行" >> "$PERF_FILE"
    echo "✅ 平均文件长度：${AVG_LENGTH}行"
fi

echo "" >> "$PERF_FILE"

# 6. 性能趋势建议
echo "📈 生成性能建议..."
echo "## 性能优化建议" >> "$PERF_FILE"
echo "" >> "$PERF_FILE"

echo "### 🎯 当前性能等级" >> "$PERF_FILE"
echo "- 构建速度: ${BUILD_TIME}秒" >> "$PERF_FILE"
echo "- 测试速度: ${TEST_TIME}秒" >> "$PERF_FILE"
echo "- 项目规模: $ML_FILES个模块" >> "$PERF_FILE"
echo "" >> "$PERF_FILE"

echo "### 💡 优化建议" >> "$PERF_FILE"
if (( $(echo "$BUILD_TIME > 10.0" | bc -l) )); then
    echo "- 考虑并行构建优化：dune build -j4" >> "$PERF_FILE"
fi

if [ $ML_FILES -gt 200 ]; then
    echo "- 项目规模较大，考虑模块化重构" >> "$PERF_FILE"
elif [ $ML_FILES -lt 50 ]; then
    echo "- 项目规模适中，保持当前架构" >> "$PERF_FILE"
fi

echo "- 定期执行性能基准测试" >> "$PERF_FILE"
echo "- 监控构建时间变化趋势" >> "$PERF_FILE"
echo "" >> "$PERF_FILE"

echo "---" >> "$PERF_FILE"
echo "*性能报告生成时间: $(date)*" >> "$PERF_FILE"

echo "📄 性能报告已保存到: $PERF_FILE"

# 显示简要总结
echo ""
echo "====================================="
echo "🎉 性能检查完成！"
echo "📊 性能摘要:"
echo "   - 构建时间: ${BUILD_TIME}秒"
echo "   - 测试时间: ${TEST_TIME}秒"
echo "   - 项目模块: $ML_FILES个"
echo "   - 代码行数: $TOTAL_LINES行"
echo ""
echo "📄 详细报告: $PERF_FILE"
echo ""
echo "💡 运行建议:"
echo "   - 定期监控性能趋势"
echo "   - 执行 ./scripts/quality_check.sh 进行质量检查"
echo "   - 使用 ./scripts/quick-test.sh 进行快速验证"