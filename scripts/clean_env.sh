#!/bin/bash

# 骆言项目环境清理脚本
# 清理构建产物、临时文件和缓存，保持开发环境整洁

set -e

echo "🧹 骆言项目环境清理开始..."

# 记录清理前的磁盘使用情况
BEFORE_SIZE=$(du -sh . 2>/dev/null | cut -f1 || echo "未知")
echo "📊 清理前项目大小: $BEFORE_SIZE"

# 1. 清理 _build 目录 (主要的构建产物)
if [ -d "_build" ]; then
    BUILD_SIZE=$(du -sh _build 2>/dev/null | cut -f1 || echo "未知")
    echo "🗂️  清理 _build 目录 ($BUILD_SIZE)..."
    rm -rf _build
    echo "✅ _build 目录已清理"
else
    echo "ℹ️  _build 目录不存在，跳过"
fi

# 2. 清理编译产物
echo "🔨 清理编译产物..."
find . -name "*.cmi" -delete 2>/dev/null || true
find . -name "*.cmo" -delete 2>/dev/null || true  
find . -name "*.cmx" -delete 2>/dev/null || true
find . -name "*.o" -delete 2>/dev/null || true
find . -name "*.cma" -delete 2>/dev/null || true
find . -name "*.cmxa" -delete 2>/dev/null || true
find . -name "*.a" -delete 2>/dev/null || true
find . -name "*.so" -delete 2>/dev/null || true
find . -name "*.exe" -delete 2>/dev/null || true
find . -name "*.native" -delete 2>/dev/null || true
find . -name "*.byte" -delete 2>/dev/null || true
echo "✅ 编译产物已清理"

# 3. 清理临时文件
echo "🗃️  清理临时文件..."
find . -name "*.tmp" -delete 2>/dev/null || true
find . -name "*.temp" -delete 2>/dev/null || true
find . -name "*~" -delete 2>/dev/null || true
find . -name "*.swp" -delete 2>/dev/null || true
find . -name "*.swo" -delete 2>/dev/null || true
find . -name "*.orig" -delete 2>/dev/null || true
find . -name "*.bak" -delete 2>/dev/null || true
find . -name "*.backup" -delete 2>/dev/null || true
echo "✅ 临时文件已清理"

# 4. 清理日志文件
echo "📋 清理日志文件..."
find . -name "*.log" -not -name "claude.log" -delete 2>/dev/null || true
find . -name "output.txt" -delete 2>/dev/null || true
echo "✅ 日志文件已清理"

# 5. 清理IDE和系统文件
echo "💻 清理IDE和系统文件..."
find . -name ".DS_Store" -delete 2>/dev/null || true
find . -name "Thumbs.db" -delete 2>/dev/null || true
echo "✅ IDE和系统文件已清理"

# 6. 清理覆盖率报告
if [ -d "_coverage" ]; then
    echo "📊 清理覆盖率报告..."
    rm -rf _coverage
    echo "✅ 覆盖率报告已清理"
fi

# 记录清理后的磁盘使用情况
AFTER_SIZE=$(du -sh . 2>/dev/null | cut -f1 || echo "未知")
echo "📊 清理后项目大小: $AFTER_SIZE"

# 验证构建功能
echo "🔍 验证构建功能..."
if dune build > /dev/null 2>&1; then
    echo "✅ 构建验证通过"
else
    echo "⚠️  构建验证失败，请检查"
    exit 1
fi

echo "🎉 环境清理完成！"
echo "💡 项目从 $BEFORE_SIZE 清理到 $AFTER_SIZE"
echo "🚀 开发环境已准备就绪"