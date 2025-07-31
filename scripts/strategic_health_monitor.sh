#!/bin/bash
# strategic_health_monitor.sh - 骆言项目战略发展健康度监控
# Author: Papa, Project Planner
# 创建日期: 2025-07-31

set -e

echo "=== 骆言战略发展健康度监控报告 ==="
echo "生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 项目规模统计
echo "📊 项目规模指标:"
TOTAL_ML_FILES=$(find src -name "*.ml" | wc -l)
TOTAL_TEST_FILES=$(find test -name "*.ml" | wc -l)
POETRY_FILES=$(find src/poetry -name "*.ml" | wc -l)
TEST_RATIO=$(echo "scale=1; $TOTAL_TEST_FILES * 100 / $TOTAL_ML_FILES" | bc -l)

echo "- 源代码文件: $TOTAL_ML_FILES 个"
echo "- 测试文件: $TOTAL_TEST_FILES 个 (${TEST_RATIO}%比例)"
echo "- Poetry模块: $POETRY_FILES/194 个 (目标: 120个, -38%)"

# 构建状态检查
echo ""
echo "🔧 构建系统状态:"
if dune build > /dev/null 2>&1; then
    echo "- 构建状态: ✅ 成功"
else
    echo "- 构建状态: ❌ 失败"
fi

# GitHub状态监控
echo ""
echo "🔄 GitHub协作状态:"
OPEN_PRS=$(gh pr list --state open | wc -l)
OPEN_ISSUES=$(gh issue list --state open | wc -l)
P0_ISSUES=$(gh issue list --state open --search "P0" | wc -l)

echo "- 开放PR数量: $OPEN_PRS"
echo "- 开放Issues: $OPEN_ISSUES"
echo "- P0阻塞问题: $P0_ISSUES"

# 技术债务指标
echo ""
echo "⚠️ 技术债务监控:"
RHYME_FILES=$(find src/poetry -name "*rhyme*" | wc -l)
ARTISTIC_FILES=$(find src/poetry -name "*artistic*" | wc -l)
JSON_FILES=$(find src/poetry -name "*json*" | wc -l)

echo "- 韵律相关文件: $RHYME_FILES (重复度高)"
echo "- 艺术评价文件: $ARTISTIC_FILES (需要整合)"
echo "- JSON处理文件: $JSON_FILES (需要统一)"

# Unicode优化状态
echo ""
echo "🚀 Unicode优化状态:"
if gh pr view 1850 --json state -q '.state' | grep -q "OPEN"; then
    echo "- PR #1850状态: 🔄 等待合并"
    echo "- Unicode突破: 待合并 (15-20倍性能提升)"
else
    echo "- PR #1850状态: ✅ 已合并"
    echo "- Unicode突破: 已生效"
fi

# 战略规划状态
echo ""
echo "📋 战略规划监控:"
STRATEGIC_ISSUE="1860"
if gh issue view $STRATEGIC_ISSUE --json state -q '.state' | grep -q "OPEN"; then
    echo "- 统一战略路线图: ✅ 激活中 (#$STRATEGIC_ISSUE)"
else
    echo "- 统一战略路线图: ❌ 需要检查"
fi

echo ""
echo "=== 监控完成 ==="
echo "📈 总体评估: $([ $P0_ISSUES -eq 0 ] && echo "良好" || echo "需关注P0问题")"
echo "🎯 下一步: 查看Issue #1860了解详细执行计划"