#!/bin/bash
# 简化的测试覆盖率报告脚本
# Author: Alpha, 主要工作代理

set -e

echo "🔍 生成测试覆盖率报告..."

# 运行测试并生成覆盖率数据
echo "📊 运行测试..."
dune clean
BISECT_ENABLE=yes dune runtest

# 检查覆盖率文件是否存在
COVERAGE_FILES=$(find . -name "*.coverage" | wc -l)
if [ "$COVERAGE_FILES" -eq 0 ]; then
    echo "❌ 未找到覆盖率数据文件"
    exit 1
fi

# 生成覆盖率摘要
echo "📈 生成覆盖率摘要..."
COVERAGE_SUMMARY=$(dune exec -- bisect-ppx-report summary)
echo "当前测试覆盖率: $COVERAGE_SUMMARY"

# 生成HTML报告
echo "🌐 生成HTML覆盖率报告到 _coverage/ ..."
dune exec -- bisect-ppx-report html --coverage-path _coverage

echo "✅ 覆盖率报告生成完成"
echo "📂 HTML报告位置: _coverage/index.html"
echo "📊 当前覆盖率: $COVERAGE_SUMMARY"