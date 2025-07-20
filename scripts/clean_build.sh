#!/bin/bash
# 骆言项目构建清理脚本
# 用于清理构建产物和临时文件，减少磁盘使用

set -e

echo "🧹 开始清理骆言项目构建产物..."

# 记录清理前的大小
BUILD_SIZE_BEFORE=$(du -sh _build 2>/dev/null | cut -f1 || echo "0")
echo "📊 清理前 _build 目录大小: $BUILD_SIZE_BEFORE"

# 清理构建产物
echo "🗂️  清理 dune 构建产物..."
dune clean

# 手动清理 _build 目录
if [ -d "_build" ]; then
    echo "🗂️  清理 _build 目录..."
    rm -rf _build/
fi

# 清理临时文件
echo "🗂️  清理临时文件..."
find . -name "*.tmp" -type f -delete 2>/dev/null || true
find . -name "*.temp" -type f -delete 2>/dev/null || true
find . -name "*~" -type f -delete 2>/dev/null || true
find . -name "*.swp" -type f -delete 2>/dev/null || true
find . -name "*.swo" -type f -delete 2>/dev/null || true
find . -name "*.orig" -type f -delete 2>/dev/null || true

# 清理大型日志文件（保留最近100行）
if [ -f "claude.log" ]; then
    LOG_SIZE=$(du -sh claude.log | cut -f1)
    echo "🗂️  发现大型日志文件 claude.log ($LOG_SIZE)，保留最近100行..."
    tail -n 100 claude.log > claude.log.tmp && mv claude.log.tmp claude.log
fi

if [ -f "build_output.log" ]; then
    echo "🗂️  清理构建输出日志..."
    rm -f build_output.log
fi

# 清理其他分析结果文件
find . -name "*_results.txt" -type f -delete 2>/dev/null || true
find . -name "*_output.txt" -type f -delete 2>/dev/null || true

# 记录清理后的状态
BUILD_SIZE_AFTER=$(du -sh _build 2>/dev/null | cut -f1 || echo "0")
echo "📊 清理后 _build 目录大小: $BUILD_SIZE_AFTER"

# 显示磁盘使用情况
echo ""
echo "💾 磁盘使用情况:"
du -sh . | head -1

echo ""
echo "✅ 构建清理完成！"
echo "📝 提示: 下次构建时请使用 'dune build' 重新构建项目"