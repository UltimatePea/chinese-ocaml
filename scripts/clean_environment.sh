#!/bin/bash
# 骆言项目环境清理脚本
# Environment cleanup script for the Luoyan project

set -e

echo "🧹 开始清理骆言项目环境..."
echo "🧹 Starting Luoyan project environment cleanup..."

# 记录清理前的磁盘使用
BEFORE_SIZE=$(du -sh . | cut -f1)
echo "📊 清理前项目大小: $BEFORE_SIZE"

# 1. 清理构建工件
echo "🔧 清理构建工件..."
if [ -d "_build" ]; then
    echo "  - 清理 _build/ 目录"
    dune clean
fi

# 2. 清理临时日志文件
echo "📝 清理临时日志文件..."
find . -name "*.log" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true
find . -name "*_output.txt" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true
find . -name "*_results.txt" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true

# 3. 清理编译产物
echo "🏗️ 清理编译产物..."
find . -name "*.cmo" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true
find . -name "*.cmi" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true
find . -name "*.cmx" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true
find . -name "*.o" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true

# 4. 清理临时测试文件
echo "🧪 清理临时测试文件..."
find . -name "test_simple.*" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true
find . -name "debug_*.ml" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true

# 5. 清理旧的报告文件
echo "📋 清理旧的报告文件..."
if [ -d "quality_reports" ]; then
    find quality_reports/ -name "quality_report_*.md" -mtime +7 -exec rm -f {} \; 2>/dev/null || true
fi
if [ -d "performance_reports" ]; then
    find performance_reports/ -name "performance_report_*.md" -mtime +7 -exec rm -f {} \; 2>/dev/null || true
fi
if [ -d "project_status" ]; then
    find project_status/ -name "status_*.md" -mtime +7 -exec rm -f {} \; 2>/dev/null || true
fi

# 6. 清理Python缓存
echo "🐍 清理Python缓存..."
find . -name "__pycache__" -type d -not -path "./.git/*" -exec rm -rf {} \; 2>/dev/null || true
find . -name "*.pyc" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true

# 7. 清理编辑器临时文件
echo "✏️ 清理编辑器临时文件..."
find . -name "*~" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true
find . -name "*.swp" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true
find . -name "*.swo" -not -path "./.git/*" -exec rm -f {} \; 2>/dev/null || true

# 记录清理后的磁盘使用
AFTER_SIZE=$(du -sh . | cut -f1)
echo "📊 清理后项目大小: $AFTER_SIZE"

echo "✅ 环境清理完成！"
echo "✅ Environment cleanup completed!"

# 重新构建以确保项目状态正常
echo "🔨 重新构建项目以验证状态..."
if dune build; then
    echo "✅ 项目构建成功，环境清理完成且正常工作"
else
    echo "❌ 项目构建失败，请检查清理过程是否出现问题"
    exit 1
fi