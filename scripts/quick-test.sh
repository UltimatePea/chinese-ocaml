#!/bin/bash
# 快速测试脚本 - 骆言项目
# 用于快速验证代码质量

set -e

echo "🚀 开始骆言项目快速测试..."
echo "时间: $(date)"
echo "=================================="

# 构建项目
echo "📦 构建项目..."
time dune build

# 运行测试
echo "🧪 运行测试..."
time dune runtest

# 检查构建警告
echo "⚠️ 检查构建警告..."
dune build 2>&1 | grep -i warning && echo "⚠️ 发现构建警告" || echo "✅ 无构建警告"

# 基本代码质量检查
echo "🔍 代码质量检查..."
if [ -f "scripts/analysis/find_long_functions.py" ]; then
    python3 scripts/analysis/find_long_functions.py src/ | head -5
fi

echo "=================================="
echo "✅ 快速测试完成!"
echo "时间: $(date)"