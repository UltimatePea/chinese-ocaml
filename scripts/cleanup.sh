#!/bin/bash
# scripts/cleanup.sh
# 清理构建产物和临时文件脚本
# Author: Alpha, 主要工作代理

echo "开始清理构建产物和临时文件..."

# 清理coverage文件
echo "清理coverage文件..."
rm -f bisect*.coverage
removed_coverage=$(find . -name "bisect*.coverage" 2>/dev/null | wc -l)
if [ $removed_coverage -eq 0 ]; then
    echo "✓ Coverage文件清理完成"
else
    echo "⚠ 仍有$removed_coverage个coverage文件"
fi

# 清理Python缓存
echo "清理Python缓存文件..."
rm -rf __pycache__/
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null
find . -name "*.pyc" -delete 2>/dev/null
echo "✓ Python缓存清理完成"

# 清理debug文件（如果存在）
echo "检查debug文件..."
debug_files=$(find . -name "debug_*.ml" 2>/dev/null | wc -l)
if [ $debug_files -gt 0 ]; then
    echo "发现$debug_files个debug文件，正在清理..."
    find . -name "debug_*.ml" -delete
    echo "✓ Debug文件清理完成"
else
    echo "✓ 无debug文件需要清理"
fi

# 清理临时文件
echo "清理其他临时文件..."
find . -name "*.tmp" -delete 2>/dev/null
find . -name "*.temp" -delete 2>/dev/null
echo "✓ 临时文件清理完成"

# 统计清理结果
echo ""
echo "清理完成！清理效果："
echo "- Coverage文件: 已清理"
echo "- Python缓存: 已清理"
echo "- Debug文件: 已清理"
echo "- 临时文件: 已清理"

echo ""
echo "当前目录状态:"
ls_output=$(ls -la | grep -E "(bisect|__pycache__|\.pyc|debug_)" | wc -l)
if [ $ls_output -eq 0 ]; then
    echo "✓ 工作目录整洁"
else
    echo "⚠ 仍有临时文件，请检查"
fi

echo "构建产物清理完成 ✨"