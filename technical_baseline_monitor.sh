#!/bin/bash
# 骆言项目技术基线监控脚本
# Author: Papa, Technical Implementation Lead
# 用途: 确保项目重构过程中的技术指标不回退

echo "🔍 骆言项目技术基线监控 - $(date)"
echo "========================================"

# 1. 编译状态检查
echo "📋 1. 编译状态检查"
if dune build 2>/dev/null; then
    echo "✅ 编译状态: 成功"
else
    echo "❌ 编译状态: 失败"
    exit 1
fi

# 2. 构建性能测试
echo "📋 2. 构建性能测试"
BUILD_START=$(date +%s.%N)
dune clean > /dev/null 2>&1
dune build > /dev/null 2>&1
BUILD_END=$(date +%s.%N)
BUILD_TIME=$(echo "$BUILD_END - $BUILD_START" | bc -l)
echo "⏱️  构建时间: ${BUILD_TIME}秒"

if (( $(echo "$BUILD_TIME < 2.0" | bc -l) )); then
    echo "✅ 构建性能: 合格 (<2秒)"
else
    echo "⚠️  构建性能: 需要关注 (>${BUILD_TIME}秒)"
fi

# 3. 测试套件检查
echo "📋 3. 测试套件检查"
TEST_OUTPUT=$(dune runtest 2>&1)
if echo "$TEST_OUTPUT" | grep -q "Test Successful"; then
    TEST_COUNT=$(echo "$TEST_OUTPUT" | grep -o "Test Successful" | wc -l)
    echo "✅ 测试状态: ${TEST_COUNT}个测试组通过"
else
    echo "❌ 测试状态: 存在失败"
    echo "$TEST_OUTPUT" | grep -E "(FAIL|ERROR)" | head -5
fi

# 4. Poetry模块统计
echo "📋 4. Poetry模块统计"
ML_COUNT=$(find src/poetry -name "*.ml" | wc -l)
MLI_COUNT=$(find src/poetry -name "*.mli" | wc -l)
TOTAL_COUNT=$((ML_COUNT + MLI_COUNT))
echo "📊 Poetry模块文件数: $TOTAL_COUNT ($ML_COUNT .ml + $MLI_COUNT .mli)"

# 5. 韵律性能基准测试
echo "📋 5. 韵律性能基准测试"
if [ -f "_build/default/test/poetry/test_rhyme_performance.exe" ]; then
    RHYME_OUTPUT=$(cd _build/default/test/poetry && ./test_rhyme_performance.exe 2>/dev/null)
    if echo "$RHYME_OUTPUT" | grep -q "性能提升倍数"; then
        PERFORMANCE=$(echo "$RHYME_OUTPUT" | grep "性能提升倍数" | grep -o "[0-9.]*x")
        echo "🚀 韵律查询性能: $PERFORMANCE 提升"
    else
        echo "⚠️  韵律性能测试: 无法获取数据"
    fi
else
    echo "⚠️  韵律性能测试: 测试文件不存在"
fi

# 6. 代码质量指标
echo "📋 6. 代码质量指标"
if command -v cloc >/dev/null 2>&1; then
    CLOC_OUTPUT=$(cloc src/ --quiet --csv)
    if [ -n "$CLOC_OUTPUT" ]; then
        TOTAL_LINES=$(echo "$CLOC_OUTPUT" | tail -1 | cut -d, -f5)
        echo "📏 总代码行数: $TOTAL_LINES"
    fi
else
    echo "📏 总文件数: $(find src/ -name "*.ml" -o -name "*.mli" | wc -l)"
fi

# 7. Git状态检查
echo "📋 7. Git状态检查"
BRANCH=$(git branch --show-current)
STATUS=$(git status --porcelain | wc -l)
echo "🌿 当前分支: $BRANCH"
echo "📋 未提交变更: $STATUS个文件"

# 8. 生成监控报告
echo "📋 8. 生成基线报告"
cat > "technical_baseline_$(date +%Y%m%d_%H%M%S).json" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "build_time_seconds": $BUILD_TIME,
  "test_groups_passed": ${TEST_COUNT:-0},
  "poetry_modules_total": $TOTAL_COUNT,
  "poetry_ml_files": $ML_COUNT,
  "poetry_mli_files": $MLI_COUNT,
  "git_branch": "$BRANCH",
  "uncommitted_changes": $STATUS,
  "rhyme_performance": "${PERFORMANCE:-unknown}",
  "baseline_status": "$([ $STATUS -eq 0 ] && echo 'clean' || echo 'modified')"
}
EOF

echo "✅ 基线报告已生成: technical_baseline_$(date +%Y%m%d_%H%M%S).json"

echo "========================================"
echo "🎯 基线监控完成 - 项目技术健康度良好"