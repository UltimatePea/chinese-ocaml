#!/bin/bash
# 骆言项目构建产物清理脚本
# 
# 作者：Alpha代理，技术债务清理专员
# 版本：1.0
# 日期：2025-07-27
# 
# 用途：清理项目中的编译产物和临时文件，保持项目整洁
# 
# 使用方法：
#   ./scripts/clean_build_artifacts.sh          # 标准清理
#   ./scripts/clean_build_artifacts.sh --deep   # 深度清理

set -e

SCRIPT_DIR="$(dirname "$0")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧹 骆言项目构建产物清理工具"
echo "================================"
echo "项目根目录: $PROJECT_ROOT"

cd "$PROJECT_ROOT"

# 统计清理前的文件数量
echo "📊 清理前统计..."
CMI_COUNT=$(find . -name "*.cmi" 2>/dev/null | wc -l)
CMO_COUNT=$(find . -name "*.cmo" 2>/dev/null | wc -l)
CMX_COUNT=$(find . -name "*.cmx" 2>/dev/null | wc -l)
O_COUNT=$(find . -name "*.o" 2>/dev/null | wc -l)
COVERAGE_COUNT=$(find . -name "*.coverage" 2>/dev/null | wc -l)

echo "  编译产物 (.cmi): $CMI_COUNT 个文件"
echo "  编译产物 (.cmo): $CMO_COUNT 个文件"  
echo "  编译产物 (.cmx): $CMX_COUNT 个文件"
echo "  编译产物 (.o): $O_COUNT 个文件"
echo "  覆盖率文件 (.coverage): $COVERAGE_COUNT 个文件"

TOTAL_FILES=$((CMI_COUNT + CMO_COUNT + CMX_COUNT + O_COUNT + COVERAGE_COUNT))
echo "  总计: $TOTAL_FILES 个临时文件"

if [ "$TOTAL_FILES" -eq 0 ]; then
    echo "✅ 项目已经很整洁，无需清理"
    exit 0
fi

echo ""
echo "🗑️ 开始清理..."

# 1. 清理OCaml编译产物
echo "  清理OCaml编译产物..."
find . -name "*.cmi" -delete 2>/dev/null || true
find . -name "*.cmo" -delete 2>/dev/null || true  
find . -name "*.cmx" -delete 2>/dev/null || true
find . -name "*.o" -delete 2>/dev/null || true

# 2. 清理覆盖率文件
echo "  清理覆盖率文件..."
find . -name "*.coverage" -delete 2>/dev/null || true

# 3. 清理dune构建缓存
echo "  清理dune构建缓存..."
if command -v dune >/dev/null 2>&1; then
    dune clean >/dev/null 2>&1 || true
else
    echo "    警告：未找到dune命令，跳过构建缓存清理"
fi

# 4. 深度清理模式（可选）
if [ "$1" = "--deep" ]; then
    echo "  🔥 深度清理模式..."
    
    # 清理更多编译产物
    find . -name "*.cma" -delete 2>/dev/null || true
    find . -name "*.cmxa" -delete 2>/dev/null || true
    find . -name "*.a" -delete 2>/dev/null || true
    
    # 清理临时测试文件
    find . -name "a.out" -delete 2>/dev/null || true
    find . -name "test_simple" -delete 2>/dev/null || true
    
    # 清理_build目录
    if [ -d "_build" ]; then
        rm -rf "_build"
        echo "    已清理 _build/ 目录"
    fi
    
    echo "    深度清理完成"
fi

echo ""
echo "✅ 清理完成！"

# 验证清理效果
echo "📊 清理后统计..."
CMI_COUNT_AFTER=$(find . -name "*.cmi" 2>/dev/null | wc -l)
CMO_COUNT_AFTER=$(find . -name "*.cmo" 2>/dev/null | wc -l)
CMX_COUNT_AFTER=$(find . -name "*.cmx" 2>/dev/null | wc -l)
O_COUNT_AFTER=$(find . -name "*.o" 2>/dev/null | wc -l)
COVERAGE_COUNT_AFTER=$(find . -name "*.coverage" 2>/dev/null | wc -l)

TOTAL_FILES_AFTER=$((CMI_COUNT_AFTER + CMO_COUNT_AFTER + CMX_COUNT_AFTER + O_COUNT_AFTER + COVERAGE_COUNT_AFTER))
CLEANED_FILES=$((TOTAL_FILES - TOTAL_FILES_AFTER))

echo "  清理了 $CLEANED_FILES 个文件"
echo "  剩余临时文件: $TOTAL_FILES_AFTER 个"

if [ "$TOTAL_FILES_AFTER" -eq 0 ]; then
    echo "🎉 项目现在非常整洁！"
else
    echo "⚠️ 还有 $TOTAL_FILES_AFTER 个文件未清理（可能被锁定或受保护）"
fi

echo ""
echo "💡 建议："
echo "  - 定期运行此脚本保持项目整洁"  
echo "  - 使用 'git status' 确认没有重要文件被误删"
echo "  - 如有问题，请运行 'dune build' 重新构建"

echo ""
echo "🔗 相关资源："
echo "  - Issue #1456: https://github.com/UltimatePea/chinese-ocaml/issues/1456"
echo "  - 技术债务分析报告: 骆言编译器技术债务综合分析报告_2025-07-26.md"