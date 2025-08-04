#!/bin/bash
# Poetry模块整合质量控制脚本
# 
# Author: Whisky, PR Worker
# Purpose: 防止错误的包装式整合，确保真正的文件减少
# Usage: ./poetry_consolidation_guard.sh

set -e

POETRY_DIR="src/poetry"
TARGET_FILE_COUNT=200
REPORT_FILE="doc/issues/consolidation_progress.md"

echo "🔍 Poetry模块整合质量控制检查..."

# 统计当前Poetry文件数
current_count=$(find $POETRY_DIR -name "*.ml" -o -name "*.mli" | wc -l)
echo "📊 当前Poetry文件数: $current_count"
echo "🎯 目标文件数: $TARGET_FILE_COUNT"

# 检查是否达标
if [ $current_count -gt $TARGET_FILE_COUNT ]; then
    deficit=$((current_count - TARGET_FILE_COUNT))
    echo "❌ 文件数未达标，需要减少 $deficit 个文件"
    echo "⚠️  当前整合进度: $(( (370 - current_count) * 100 / 170 ))%"
else
    echo "✅ 文件数达标!"
    surplus=$((TARGET_FILE_COUNT - current_count))
    echo "🎉 超额完成，比目标少 $surplus 个文件"
fi

# 检查是否存在包装式整合迹象
echo ""
echo "🔍 检查包装式整合迹象..."

wrapper_indicators=(
    "src/poetry/.*_consolidated/"
    "unified_.*_api\.ml"
    ".*_wrapper\.ml"
    ".*_facade\.ml"
)

wrapper_found=false
for pattern in "${wrapper_indicators[@]}"; do
    if find $POETRY_DIR -path "$pattern" 2>/dev/null | grep -q .; then
        echo "⚠️  发现可疑包装文件: $(find $POETRY_DIR -path "$pattern" 2>/dev/null)"
        wrapper_found=true
    fi
done

if [ "$wrapper_found" = true ]; then
    echo "❌ 发现包装式整合迹象，需要评估是否为真正整合"
else
    echo "✅ 未发现包装式整合迹象"
fi

# 检查Git提交中的文件变化
echo ""
echo "🔍 检查最近提交的文件变化..."

if git diff --cached --quiet 2>/dev/null; then
    echo "ℹ️  没有待提交的变化"
else
    new_files=$(git diff --cached --name-status | grep "^A" | wc -l)
    deleted_files=$(git diff --cached --name-status | grep "^D" | wc -l)
    modified_files=$(git diff --cached --name-status | grep "^M" | wc -l)
    
    echo "📊 待提交变化统计:"
    echo "   新增文件: $new_files"
    echo "   删除文件: $deleted_files"
    echo "   修改文件: $modified_files"
    
    # 防止伪整合检查
    if [ $new_files -gt 0 ] && [ $deleted_files -eq 0 ]; then
        echo "❌ 警告：只新增文件不删除文件，疑似包装式伪整合"
        echo "❌ 真正的整合必须删除原有分散文件"
        exit 1
    fi
    
    if [ $deleted_files -gt $new_files ]; then
        net_reduction=$((deleted_files - new_files))
        echo "✅ 净减少 $net_reduction 个文件，符合真实整合"
    fi
fi

# 生成进度报告
echo ""
echo "📝 生成整合进度报告..."

mkdir -p "$(dirname $REPORT_FILE)"
cat > $REPORT_FILE << EOF
# Poetry模块整合进度报告

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')  
**生成者**: Whisky, PR Worker  

## 📊 整合进度统计

- **当前文件数**: $current_count
- **目标文件数**: $TARGET_FILE_COUNT  
- **需要减少**: $((current_count > TARGET_FILE_COUNT ? current_count - TARGET_FILE_COUNT : 0)) 个文件
- **整合进度**: $(( (370 - current_count) * 100 / 170 ))%

## 📂 文件分布统计

\`\`\`bash
$(find $POETRY_DIR -type d | sort | while read dir; do
    count=$(find "$dir" -maxdepth 1 -name "*.ml" -o -name "*.mli" | wc -l)
    if [ $count -gt 0 ]; then
        echo "$dir: $count 个文件"
    fi
done)
\`\`\`

## 🎯 整合目标分解

- **韵律系统**: 目标减少60个文件
- **缓存管理**: 目标减少30个文件  
- **数据管理**: 目标减少40个文件
- **艺术评价**: 目标减少20个文件
- **其他模块**: 目标减少20个文件

## ✅ 质量控制检查

- 包装式整合检查: $([ "$wrapper_found" = true ] && echo "⚠️ 需要关注" || echo "✅ 通过")
- 文件数量达标: $([ $current_count -le $TARGET_FILE_COUNT ] && echo "✅ 通过" || echo "❌ 未通过")
- 净文件减少: $([ $deleted_files -gt $new_files ] && echo "✅ 通过" || echo "需要检查")

---
**Author: Whisky, PR Worker**  
**Mission: 确保Poetry模块真正整合，不是包装式伪整合**
EOF

echo "📝 进度报告已生成: $REPORT_FILE"

# 退出码
if [ $current_count -le $TARGET_FILE_COUNT ] && [ "$wrapper_found" = false ]; then
    echo ""
    echo "🎉 Poetry模块整合质量控制通过!"
    exit 0
else
    echo ""
    echo "⚠️  Poetry模块整合需要继续改进"
    exit 1
fi