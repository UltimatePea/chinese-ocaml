#!/bin/bash

# 骆言项目状态综合检查器
# 集成多种检查工具，提供项目整体状态概览
# 根据CLAUDE.md指导设计，专为AI助理优化

set -e

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
STATUS_DIR="project_status"
STATUS_FILE="$STATUS_DIR/status_$TIMESTAMP.md"

# 创建状态目录
mkdir -p "$STATUS_DIR"

echo "🔍 骆言项目状态检查开始..."
echo "📅 检查时间: $(date)"
echo "==============================="

# 开始生成状态报告
cat > "$STATUS_FILE" << 'EOF'
# 骆言项目状态报告

## 基本信息
EOF

echo "- 检查时间: $(date)" >> "$STATUS_FILE"
echo "- Git分支: $(git branch --show-current)" >> "$STATUS_FILE"
echo "- Git提交: $(git rev-parse --short HEAD)" >> "$STATUS_FILE"
echo "- 工作目录: $(pwd)" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"

# 1. 快速构建检查
echo "🔨 快速构建检查..."
echo "## 构建状态" >> "$STATUS_FILE"
if timeout 30s dune build > /dev/null 2>&1; then
    echo "- ✅ 构建成功" >> "$STATUS_FILE"
    echo "✅ 构建状态: 正常"
else
    echo "- ❌ 构建失败或超时" >> "$STATUS_FILE"
    echo "❌ 构建状态: 异常"
fi
echo "" >> "$STATUS_FILE"

# 2. Git状态检查
echo "📋 Git状态检查..."
echo "## Git状态" >> "$STATUS_FILE"

# 检查未提交的更改
CHANGED_FILES=$(git status --porcelain | wc -l)
if [ $CHANGED_FILES -eq 0 ]; then
    echo "- ✅ 工作区清洁" >> "$STATUS_FILE"
    echo "✅ Git状态: 清洁"
else
    echo "- ⚠️  有 $CHANGED_FILES 个文件未提交" >> "$STATUS_FILE"
    echo "⚠️  Git状态: 有未提交更改"
fi

# 检查未推送的提交
UNPUSHED=$(git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null | wc -l || echo "0")
if [ $UNPUSHED -eq 0 ]; then
    echo "- ✅ 无未推送提交" >> "$STATUS_FILE"
else
    echo "- ⚠️  有 $UNPUSHED 个未推送提交" >> "$STATUS_FILE"
    echo "⚠️  有 $UNPUSHED 个未推送提交"
fi
echo "" >> "$STATUS_FILE"

# 3. 项目规模统计
echo "📊 项目规模统计..."
echo "## 项目规模" >> "$STATUS_FILE"

SRC_FILES=$(find src -name "*.ml" | wc -l)
MLI_FILES=$(find src -name "*.mli" | wc -l)
TEST_FILES=$(find test -name "*.ml" | wc -l)
DOC_FILES=$(find doc -name "*.md" | wc -l)

echo "- 源文件(.ml): $SRC_FILES" >> "$STATUS_FILE"
echo "- 接口文件(.mli): $MLI_FILES" >> "$STATUS_FILE"
echo "- 测试文件: $TEST_FILES" >> "$STATUS_FILE"
echo "- 文档文件: $DOC_FILES" >> "$STATUS_FILE"

# 计算接口覆盖率
if [ $SRC_FILES -gt 0 ]; then
    INTERFACE_RATIO=$(echo "scale=1; $MLI_FILES * 100 / $SRC_FILES" | bc -l)
    echo "- 接口覆盖率: ${INTERFACE_RATIO}%" >> "$STATUS_FILE"
    echo "📊 接口覆盖率: ${INTERFACE_RATIO}%"
fi
echo "" >> "$STATUS_FILE"

# 4. 最新提交信息
echo "📝 最新提交信息..."
echo "## 最近提交" >> "$STATUS_FILE"
git log --oneline -5 | while read line; do
    echo "- $line" >> "$STATUS_FILE"
done
echo "" >> "$STATUS_FILE"

# 5. 大文件检查
echo "📁 大文件检查..."
echo "## 大文件分析" >> "$STATUS_FILE"
echo "### 超过200行的源文件" >> "$STATUS_FILE"
find src -name "*.ml" -exec wc -l {} + | sort -nr | head -10 | while read lines file; do
    if [ "$lines" -gt 200 ] && [ "$file" != "total" ]; then
        basename_file=$(basename "$file")
        echo "- $basename_file: ${lines}行" >> "$STATUS_FILE"
    fi
done
echo "" >> "$STATUS_FILE"

# 6. 待办事项检查
echo "📋 待办事项检查..."
echo "## 待办事项" >> "$STATUS_FILE"
TODO_COUNT=$(grep -r -i "todo\|fixme\|hack" src/ test/ | wc -l || echo "0")
if [ $TODO_COUNT -eq 0 ]; then
    echo "- ✅ 无待办事项" >> "$STATUS_FILE"
    echo "✅ 待办事项: 无"
else
    echo "- ⚠️  发现 $TODO_COUNT 个待办事项" >> "$STATUS_FILE"
    echo "⚠️  待办事项: $TODO_COUNT 个"
    # 显示前5个
    echo "### 待办事项详情" >> "$STATUS_FILE"
    grep -r -i "todo\|fixme\|hack" src/ test/ | head -5 | while read line; do
        echo "- $line" >> "$STATUS_FILE"
    done
fi
echo "" >> "$STATUS_FILE"

# 7. 磁盘使用检查
echo "💾 磁盘使用检查..."
echo "## 磁盘使用" >> "$STATUS_FILE"
PROJECT_SIZE=$(du -sh . | cut -f1)
BUILD_SIZE=$(du -sh _build/ 2>/dev/null | cut -f1 || echo "0")
echo "- 项目总大小: $PROJECT_SIZE" >> "$STATUS_FILE"
echo "- 构建目录大小: $BUILD_SIZE" >> "$STATUS_FILE"
echo "💾 项目大小: $PROJECT_SIZE (构建: $BUILD_SIZE)"
echo "" >> "$STATUS_FILE"

# 8. 环境检查
echo "🔧 环境检查..."
echo "## 开发环境" >> "$STATUS_FILE"
echo "- OCaml版本: $(ocaml -version 2>/dev/null || echo '未安装')" >> "$STATUS_FILE"
echo "- Dune版本: $(dune --version 2>/dev/null || echo '未安装')" >> "$STATUS_FILE"
echo "- Python版本: $(python3 --version 2>/dev/null || echo '未安装')" >> "$STATUS_FILE"
echo "- Git版本: $(git --version 2>/dev/null || echo '未安装')" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"

# 9. 最近修改的文件
echo "📝 最近修改检查..."
echo "## 最近修改文件" >> "$STATUS_FILE"
echo "### 源代码文件 (最近7天)" >> "$STATUS_FILE"
find src -name "*.ml" -o -name "*.mli" | xargs ls -lt | head -5 | while read line; do
    echo "- $line" >> "$STATUS_FILE"
done
echo "" >> "$STATUS_FILE"

# 10. 质量指标概览
echo "🎯 质量指标概览..."
echo "## 质量指标概览" >> "$STATUS_FILE"

# 测试覆盖率
if [ $SRC_FILES -gt 0 ]; then
    TEST_RATIO=$(echo "scale=1; $TEST_FILES * 100 / $SRC_FILES" | bc -l)
    echo "- 测试覆盖率: ${TEST_RATIO}%" >> "$STATUS_FILE"
fi

# 平均文件长度
TOTAL_LINES=$(find src -name "*.ml" -exec wc -l {} + | tail -1 | awk '{print $1}')
if [ $SRC_FILES -gt 0 ]; then
    AVG_LENGTH=$(echo "scale=0; $TOTAL_LINES / $SRC_FILES" | bc -l)
    echo "- 平均文件长度: ${AVG_LENGTH}行" >> "$STATUS_FILE"
fi

echo "- 代码总行数: $TOTAL_LINES" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"

# 11. 建议行动项
echo "🛠️ 生成建议..."
echo "## 建议行动项" >> "$STATUS_FILE"

# 基于检查结果给出建议
if [ $CHANGED_FILES -gt 0 ]; then
    echo "- 🔄 提交未保存的更改" >> "$STATUS_FILE"
fi

if [ $UNPUSHED -gt 0 ]; then
    echo "- 📤 推送未发布的提交" >> "$STATUS_FILE"
fi

if [ "$BUILD_SIZE" != "0" ] && [ "$BUILD_SIZE" != "0K" ]; then
    echo "- 🧹 考虑清理构建目录以释放空间" >> "$STATUS_FILE"
fi

if [ $TODO_COUNT -gt 0 ]; then
    echo "- 📋 处理待办事项以改善代码质量" >> "$STATUS_FILE"
fi

# 如果没有建议
if [ $CHANGED_FILES -eq 0 ] && [ $UNPUSHED -eq 0 ] && [ $TODO_COUNT -eq 0 ]; then
    echo "- ✅ 项目状态良好，无紧急行动项" >> "$STATUS_FILE"
fi
echo "" >> "$STATUS_FILE"

# 12. 总结
echo "📋 生成总结..."
echo "## 项目状态总结" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"
echo "### 🎯 关键指标" >> "$STATUS_FILE"
echo "- 源文件数: $SRC_FILES" >> "$STATUS_FILE"
echo "- 接口覆盖率: ${INTERFACE_RATIO:-N/A}%" >> "$STATUS_FILE"
echo "- 测试覆盖率: ${TEST_RATIO:-N/A}%" >> "$STATUS_FILE"
echo "- 待办事项: $TODO_COUNT" >> "$STATUS_FILE"
echo "- 项目大小: $PROJECT_SIZE" >> "$STATUS_FILE"
echo "" >> "$STATUS_FILE"

# 健康度评级
HEALTH_SCORE=100
if [ $CHANGED_FILES -gt 0 ]; then HEALTH_SCORE=$((HEALTH_SCORE - 10)); fi
if [ $UNPUSHED -gt 0 ]; then HEALTH_SCORE=$((HEALTH_SCORE - 5)); fi
if [ $TODO_COUNT -gt 10 ]; then HEALTH_SCORE=$((HEALTH_SCORE - 15)); fi

echo "### 📊 项目健康度" >> "$STATUS_FILE"
if [ $HEALTH_SCORE -ge 90 ]; then
    echo "- 🟢 优秀 (${HEALTH_SCORE}/100)" >> "$STATUS_FILE"
    echo "🟢 项目健康度: 优秀 (${HEALTH_SCORE}/100)"
elif [ $HEALTH_SCORE -ge 75 ]; then
    echo "- 🟡 良好 (${HEALTH_SCORE}/100)" >> "$STATUS_FILE"
    echo "🟡 项目健康度: 良好 (${HEALTH_SCORE}/100)"
else
    echo "- 🟠 需要关注 (${HEALTH_SCORE}/100)" >> "$STATUS_FILE"
    echo "🟠 项目健康度: 需要关注 (${HEALTH_SCORE}/100)"
fi
echo "" >> "$STATUS_FILE"

echo "---" >> "$STATUS_FILE"
echo "*报告生成时间: $(date)*" >> "$STATUS_FILE"
echo "*工具版本: 骆言项目状态检查器 v1.0*" >> "$STATUS_FILE"

echo ""
echo "==============================="
echo "📄 详细状态报告: $STATUS_FILE"
echo "🎉 项目状态检查完成！"

# 显示简要总结
echo ""
echo "📊 快速概览:"
echo "   - 源文件: $SRC_FILES"
echo "   - 接口覆盖率: ${INTERFACE_RATIO:-N/A}%"
echo "   - 测试覆盖率: ${TEST_RATIO:-N/A}%"
echo "   - 待办事项: $TODO_COUNT"
echo "   - 健康度: ${HEALTH_SCORE}/100"