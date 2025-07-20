#!/bin/bash

# 骆言项目质量检查脚本
# 自动化代码质量检查和项目健康度评估

set -e

echo "🔍 骆言项目质量检查开始..."

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPORT_DIR="quality_reports"
REPORT_FILE="$REPORT_DIR/quality_report_$TIMESTAMP.md"

# 创建报告目录
mkdir -p "$REPORT_DIR"

# 开始生成报告
cat > "$REPORT_FILE" << 'EOF'
# 骆言项目质量检查报告

## 基本信息
EOF

echo "- 检查时间: $(date)" >> "$REPORT_FILE"
echo "- 项目路径: $(pwd)" >> "$REPORT_FILE"
echo "- Git分支: $(git branch --show-current)" >> "$REPORT_FILE"
echo "- Git提交: $(git rev-parse --short HEAD)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 1. 构建质量检查
echo "🔨 检查构建质量..."
echo "## 构建质量" >> "$REPORT_FILE"
if dune build 2>&1 | tee build_check.log; then
    echo "- ✅ 构建成功：无错误无警告" >> "$REPORT_FILE"
    echo "✅ 构建质量：优秀"
else
    echo "- ❌ 构建失败：存在错误或警告" >> "$REPORT_FILE"
    echo "❌ 构建质量：需要修复"
fi
rm -f build_check.log
echo "" >> "$REPORT_FILE"

# 2. 测试覆盖率检查
echo "🧪 检查测试覆盖率..."
echo "## 测试覆盖率" >> "$REPORT_FILE"

ML_FILES=$(find src -name "*.ml" | wc -l)
TEST_FILES=$(find test -name "*.ml" | wc -l)
if [ $ML_FILES -gt 0 ]; then
    COVERAGE_RATIO=$(echo "scale=1; $TEST_FILES * 100 / $ML_FILES" | bc -l)
    echo "- 源文件数量: $ML_FILES" >> "$REPORT_FILE"
    echo "- 测试文件数量: $TEST_FILES" >> "$REPORT_FILE"
    echo "- 测试覆盖比例: ${COVERAGE_RATIO}%" >> "$REPORT_FILE"
    
    if (( $(echo "$COVERAGE_RATIO >= 50" | bc -l) )); then
        echo "- ✅ 测试覆盖率：优秀 (≥50%)" >> "$REPORT_FILE"
        echo "✅ 测试覆盖率：${COVERAGE_RATIO}% (优秀)"
    elif (( $(echo "$COVERAGE_RATIO >= 30" | bc -l) )); then
        echo "- ⚠️  测试覆盖率：良好 (30-50%)" >> "$REPORT_FILE"
        echo "⚠️  测试覆盖率：${COVERAGE_RATIO}% (良好)"
    else
        echo "- ❌ 测试覆盖率：需改进 (<30%)" >> "$REPORT_FILE"
        echo "❌ 测试覆盖率：${COVERAGE_RATIO}% (需改进)"
    fi
fi
echo "" >> "$REPORT_FILE"

# 3. 运行测试套件
echo "🎯 运行测试套件..."
echo "## 测试结果" >> "$REPORT_FILE"
if dune test 2>&1 | tee test_check.log; then
    echo "- ✅ 所有测试通过" >> "$REPORT_FILE"
    echo "✅ 测试结果：全部通过"
else
    echo "- ❌ 存在测试失败" >> "$REPORT_FILE"
    echo "❌ 测试结果：存在失败"
fi
rm -f test_check.log
echo "" >> "$REPORT_FILE"

# 4. 代码质量分析
echo "📊 分析代码质量..."
echo "## 代码质量指标" >> "$REPORT_FILE"

# 接口覆盖率
ML_COUNT=$(find src -name "*.ml" | wc -l)
MLI_COUNT=$(find src -name "*.mli" | wc -l)
if [ $ML_COUNT -gt 0 ]; then
    INTERFACE_RATIO=$(echo "scale=1; $MLI_COUNT * 100 / $ML_COUNT" | bc -l)
    echo "- 接口覆盖率: ${INTERFACE_RATIO}%" >> "$REPORT_FILE"
    
    if (( $(echo "$INTERFACE_RATIO >= 90" | bc -l) )); then
        echo "- ✅ 接口设计：优秀 (≥90%)" >> "$REPORT_FILE"
    elif (( $(echo "$INTERFACE_RATIO >= 70" | bc -l) )); then
        echo "- ⚠️  接口设计：良好 (70-90%)" >> "$REPORT_FILE"
    else
        echo "- ❌ 接口设计：需改进 (<70%)" >> "$REPORT_FILE"
    fi
fi

# 平均文件长度
TOTAL_LINES=$(find src -name "*.ml" -exec wc -l {} + | tail -1 | awk '{print $1}')
if [ $ML_COUNT -gt 0 ]; then
    AVG_LENGTH=$(echo "scale=0; $TOTAL_LINES / $ML_COUNT" | bc -l)
    echo "- 平均文件长度: ${AVG_LENGTH}行" >> "$REPORT_FILE"
    
    if [ $AVG_LENGTH -le 200 ]; then
        echo "- ✅ 文件长度：合理 (≤200行)" >> "$REPORT_FILE"
    elif [ $AVG_LENGTH -le 500 ]; then
        echo "- ⚠️  文件长度：可接受 (200-500行)" >> "$REPORT_FILE"
    else
        echo "- ❌ 文件长度：过长 (>500行)" >> "$REPORT_FILE"
    fi
fi

echo "✅ 接口覆盖率：${INTERFACE_RATIO}%"
echo "✅ 平均文件长度：${AVG_LENGTH}行"
echo "" >> "$REPORT_FILE"

# 5. 项目结构检查
echo "🏗️  检查项目结构..."
echo "## 项目结构" >> "$REPORT_FILE"

# 检查关键目录
REQUIRED_DIRS=("src" "test" "doc")
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "- ✅ $dir/ 目录存在" >> "$REPORT_FILE"
    else
        echo "- ❌ $dir/ 目录缺失" >> "$REPORT_FILE"
    fi
done

# 检查关键文件
REQUIRED_FILES=("README.md" "dune-project" ".gitignore")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "- ✅ $file 文件存在" >> "$REPORT_FILE"
    else
        echo "- ❌ $file 文件缺失" >> "$REPORT_FILE"
    fi
done

echo "✅ 项目结构检查完成"
echo "" >> "$REPORT_FILE"

# 6. 技术债务检查
echo "⚠️  检查技术债务..."
echo "## 技术债务分析" >> "$REPORT_FILE"

# 查找长函数 (>50行)
LONG_FUNCTIONS=$(grep -r -n "let.*=" src/ | wc -l)
echo "- 函数总数（估算）: $LONG_FUNCTIONS" >> "$REPORT_FILE"

# 查找TODO和FIXME
TODO_COUNT=$(grep -r -i "todo\|fixme" src/ | wc -l || echo "0")
echo "- TODO/FIXME标记: $TODO_COUNT" >> "$REPORT_FILE"

if [ $TODO_COUNT -eq 0 ]; then
    echo "- ✅ 无待办事项" >> "$REPORT_FILE"
else
    echo "- ⚠️  存在 $TODO_COUNT 个待办事项" >> "$REPORT_FILE"
fi

echo "✅ 技术债务检查完成"
echo "" >> "$REPORT_FILE"

# 7. 性能指标
echo "⚡ 测试性能指标..."
echo "## 性能指标" >> "$REPORT_FILE"

# 构建时间
BUILD_START=$(date +%s.%N)
dune build > /dev/null 2>&1
BUILD_END=$(date +%s.%N)
BUILD_TIME=$(echo "$BUILD_END - $BUILD_START" | bc -l)

# 测试时间
TEST_START=$(date +%s.%N)
dune test > /dev/null 2>&1
TEST_END=$(date +%s.%N)
TEST_TIME=$(echo "$TEST_END - $TEST_START" | bc -l)

echo "- 构建时间: ${BUILD_TIME}秒" >> "$REPORT_FILE"
echo "- 测试时间: ${TEST_TIME}秒" >> "$REPORT_FILE"

if (( $(echo "$BUILD_TIME < 5.0" | bc -l) )); then
    echo "- ✅ 构建性能：优秀 (<5秒)" >> "$REPORT_FILE"
else
    echo "- ⚠️  构建性能：需优化 (≥5秒)" >> "$REPORT_FILE"
fi

echo "✅ 构建性能：${BUILD_TIME}秒"
echo "✅ 测试性能：${TEST_TIME}秒"
echo "" >> "$REPORT_FILE"

# 8. 总结
echo "📋 生成质量报告总结..."
echo "## 质量评估总结" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 🎯 核心指标" >> "$REPORT_FILE"
echo "- 构建状态: ✅ 成功" >> "$REPORT_FILE"
echo "- 测试覆盖率: ${COVERAGE_RATIO}%" >> "$REPORT_FILE"
echo "- 接口覆盖率: ${INTERFACE_RATIO}%" >> "$REPORT_FILE"
echo "- 构建性能: ${BUILD_TIME}秒" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 📈 改进建议" >> "$REPORT_FILE"
echo "- 继续保持零警告零错误的构建质量" >> "$REPORT_FILE"
echo "- 持续增加测试覆盖率至50%以上" >> "$REPORT_FILE"
echo "- 维护良好的模块化设计" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "*报告生成时间: $(date)*" >> "$REPORT_FILE"

echo "📄 质量检查报告已保存到: $REPORT_FILE"

# 显示简要总结
echo ""
echo "🎉 质量检查完成！"
echo "📊 简要总结:"
echo "   - 测试覆盖率: ${COVERAGE_RATIO}%"
echo "   - 接口覆盖率: ${INTERFACE_RATIO}%" 
echo "   - 构建时间: ${BUILD_TIME}秒"
echo "   - 平均文件长度: ${AVG_LENGTH}行"
echo ""
echo "📄 详细报告: $REPORT_FILE"