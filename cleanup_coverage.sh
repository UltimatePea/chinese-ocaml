#!/bin/bash

# 骆言项目 - 测试覆盖率文件清理脚本
# 用途：清理项目中积累的测试覆盖率文件和其他临时文件
# 作者：Claude AI Assistant
# 创建时间：2025-07-23

echo "🧹 开始清理骆言项目测试覆盖率文件..."

# 清理覆盖率文件
echo "清理 bisect 覆盖率文件..."
find . -name "bisect*.coverage" -type f -delete 2>/dev/null
removed_count=$(find . -name "bisect*.coverage" -type f | wc -l)
echo "已删除 bisect 覆盖率文件"

# 清理其他临时文件  
echo "清理其他临时文件..."
find . -name "*.tmp" -type f -delete 2>/dev/null
find . -name "*.temp" -type f -delete 2>/dev/null
find . -name "*~" -type f -delete 2>/dev/null
find . -name "*.bak" -type f -delete 2>/dev/null
find . -name "*.backup" -type f -delete 2>/dev/null

# 清理测试输出文件
echo "清理测试输出文件..."
find . -name "*_output.txt" -type f -delete 2>/dev/null
find . -name "*_results.txt" -type f -delete 2>/dev/null

# 清理大型日志文件
echo "清理大型日志文件..."
find . -name "*.log.large" -type f -delete 2>/dev/null
find . -name "*.log.backup" -type f -delete 2>/dev/null

# 清理coverage_reports目录中的旧文件（保留最新5个）
if [ -d "coverage_reports" ]; then
    echo "清理 coverage_reports 目录中的旧文件..."
    cd coverage_reports
    ls -t *.html 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null
    cd ..
fi

echo "✅ 清理完成！"
echo "💡 提示：此脚本可以添加到 pre-commit hook 中以防止文件积累"