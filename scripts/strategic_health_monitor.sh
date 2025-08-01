#!/bin/bash
# scripts/strategic_health_monitor.sh
# 骆言项目综合健康度监控脚本
# Author: Papa, Project Planner
# Date: 2025-07-31

set -e

REPORT_DIR="monitoring_reports"
DATE=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/health_report_$DATE.md"

mkdir -p $REPORT_DIR

echo "=== 骆言项目健康度监控启动 ===" 
echo "生成时间: $(date)"
echo "报告文件: $REPORT_FILE"
echo

# 创建报告文件
cat > $REPORT_FILE << EOF
# 骆言项目健康度报告

**生成时间**: $(date)  
**监控版本**: v1.0  
**监控周期**: 每日自动  
**Author**: Papa, Project Planner  

---

EOF

# 1. 项目规模统计
echo "## 📈 项目规模指标" >> $REPORT_FILE
echo "" >> $REPORT_FILE

POETRY_FILES=$(find src/poetry -name "*.ml" 2>/dev/null | wc -l || echo "0")
RHYME_FILES=$(find src/poetry -name "*rhyme*" 2>/dev/null | wc -l || echo "0")  
ARTISTIC_FILES=$(find src/poetry -name "*artistic*" 2>/dev/null | wc -l || echo "0")
TOTAL_ML_FILES=$(find src -name "*.ml" 2>/dev/null | wc -l || echo "0")

echo "- **Poetry模块文件数**: $POETRY_FILES" >> $REPORT_FILE
echo "- **韵律相关文件数**: $RHYME_FILES" >> $REPORT_FILE
echo "- **艺术评价文件数**: $ARTISTIC_FILES" >> $REPORT_FILE
echo "- **项目总ML文件数**: $TOTAL_ML_FILES" >> $REPORT_FILE

# 计算总代码行数
if command -v wc >/dev/null 2>&1; then
    TOTAL_LINES=$(find src -name "*.ml" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}' || echo "未知")
    echo "- **总代码行数**: $TOTAL_LINES" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE

# 2. 编译性能监控
echo "## ⚡ 编译性能指标" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "正在进行编译性能测试..."
COMPILE_START=$(date +%s.%N)

if dune build >/dev/null 2>&1; then
    COMPILE_END=$(date +%s.%N)
    if command -v bc >/dev/null 2>&1; then
        COMPILE_TIME=$(echo "$COMPILE_END - $COMPILE_START" | bc 2>/dev/null || echo "计算失败")
    else
        COMPILE_TIME="无bc命令"
    fi
    echo "- ✅ **编译状态**: 成功 (用时: ${COMPILE_TIME}秒)" >> $REPORT_FILE
    echo "✅ 编译成功"
else
    echo "- ❌ **编译状态**: 失败" >> $REPORT_FILE
    echo "❌ 编译失败"
fi

echo "" >> $REPORT_FILE

# 3. 测试状态监控
echo "## 🧪 测试质量指标" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "正在运行测试套件..."
if timeout 300 dune runtest >/dev/null 2>&1; then
    echo "- ✅ **测试状态**: 全部通过" >> $REPORT_FILE
    echo "✅ 测试通过"
else
    echo "- ⚠️ **测试状态**: 部分失败或超时" >> $REPORT_FILE
    echo "⚠️ 测试异常"
fi

# 尝试运行测试覆盖率分析
if [ -f "scripts/test_coverage_accurate.py" ]; then
    echo "正在分析测试覆盖率..."
    if timeout 60 python3 scripts/test_coverage_accurate.py > /tmp/coverage_result.txt 2>&1; then
        if grep -q "覆盖率" /tmp/coverage_result.txt; then
            COVERAGE=$(grep "覆盖率" /tmp/coverage_result.txt | head -1)
            echo "- 📊 **$COVERAGE**" >> $REPORT_FILE
        else
            echo "- 📊 **测试覆盖率**: 分析中..." >> $REPORT_FILE  
        fi
    else
        echo "- 📊 **测试覆盖率**: 分析超时或失败" >> $REPORT_FILE
    fi
else
    echo "- 📊 **测试覆盖率**: 分析工具不可用" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE

# 4. 代码质量分析
echo "## 🔍 代码质量指标" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "### 最大文件分析 (Poetry模块)" >> $REPORT_FILE
echo "" >> $REPORT_FILE
echo "\`\`\`" >> $REPORT_FILE

if [ -d "src/poetry" ]; then
    echo "正在分析Poetry模块最大文件..."
    find src/poetry -name "*.ml" -exec wc -l {} + 2>/dev/null | sort -nr | head -5 >> $REPORT_FILE || echo "分析失败" >> $REPORT_FILE
else
    echo "Poetry目录不存在" >> $REPORT_FILE
fi

echo "\`\`\`" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 5. 技术债务热点分析
echo "## 🔥 技术债务热点" >> $REPORT_FILE
echo "" >> $REPORT_FILE

if [ -d "src/poetry" ]; then
    RHYME_DATA_FILES=$(find src/poetry -path "*/rhyme_data/*" -name "*.ml" 2>/dev/null | wc -l || echo "0")
    CACHE_FILES=$(find src/poetry -name "*cache*" -name "*.ml" 2>/dev/null | wc -l || echo "0")
    DATA_FILES=$(find src/poetry -path "*/data/*" -name "*.ml" 2>/dev/null | wc -l || echo "0")
    
    echo "### 重复文件模式分析" >> $REPORT_FILE
    echo "- **韵律数据文件**: ${RHYME_DATA_FILES}个" >> $REPORT_FILE
    echo "- **缓存管理文件**: ${CACHE_FILES}个" >> $REPORT_FILE  
    echo "- **数据层文件**: ${DATA_FILES}个" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE

# 6. 重构目标进度追踪
echo "## 🎯 重构目标追踪" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 基于当前文件数计算进度
TARGET_POETRY_FILES=120
if [ "$POETRY_FILES" -gt 0 ]; then
    if [ "$POETRY_FILES" -le "$TARGET_POETRY_FILES" ]; then
        echo "- ✅ **Poetry文件数目标**: 已达成 ($POETRY_FILES ≤ $TARGET_POETRY_FILES)" >> $REPORT_FILE
    else
        REMAINING=$((POETRY_FILES - TARGET_POETRY_FILES))
        PROGRESS=$(echo "scale=1; (194 - $POETRY_FILES) * 100 / (194 - $TARGET_POETRY_FILES)" | bc 2>/dev/null || echo "未知")
        echo "- 🔄 **Poetry文件数进度**: ${PROGRESS}% (当前:$POETRY_FILES, 目标:$TARGET_POETRY_FILES, 待减少:$REMAINING)" >> $REPORT_FILE
    fi
fi

TARGET_RHYME_FILES=80
if [ "$RHYME_FILES" -gt 0 ]; then
    if [ "$RHYME_FILES" -le "$TARGET_RHYME_FILES" ]; then
        echo "- ✅ **韵律文件数目标**: 已达成 ($RHYME_FILES ≤ $TARGET_RHYME_FILES)" >> $REPORT_FILE
    else
        REMAINING_RHYME=$((RHYME_FILES - TARGET_RHYME_FILES))
        RHYME_PROGRESS=$(echo "scale=1; (133 - $RHYME_FILES) * 100 / (133 - $TARGET_RHYME_FILES)" | bc 2>/dev/null || echo "未知")
        echo "- 🔄 **韵律文件数进度**: ${RHYME_PROGRESS}% (当前:$RHYME_FILES, 目标:$TARGET_RHYME_FILES, 待减少:$REMAINING_RHYME)" >> $REPORT_FILE
    fi
fi

echo "" >> $REPORT_FILE

# 7. 基准数据管理
echo "## 📊 基准数据更新" >> $REPORT_FILE
echo "" >> $REPORT_FILE

BASELINE_FILE="$REPORT_DIR/baseline_metrics.txt"
if [ -f "$BASELINE_FILE" ]; then
    BASELINE_POETRY=$(head -1 "$BASELINE_FILE" 2>/dev/null || echo "0")
    if [ "$BASELINE_POETRY" != "$POETRY_FILES" ]; then
        CHANGE=$((POETRY_FILES - BASELINE_POETRY))
        if [ "$CHANGE" -gt 0 ]; then
            echo "- 📈 **Poetry文件变化**: +$CHANGE (基准:$BASELINE_POETRY → 当前:$POETRY_FILES)" >> $REPORT_FILE
        elif [ "$CHANGE" -lt 0 ]; then
            echo "- 📉 **Poetry文件变化**: $CHANGE (基准:$BASELINE_POETRY → 当前:$POETRY_FILES) ✅" >> $REPORT_FILE
        else
            echo "- ➡️ **Poetry文件变化**: 无变化 ($POETRY_FILES)" >> $REPORT_FILE
        fi
    fi
else
    echo "- 🆕 **基准数据**: 初次建立" >> $REPORT_FILE
    echo "$POETRY_FILES" > "$BASELINE_FILE"
    echo "$RHYME_FILES" >> "$BASELINE_FILE"
    echo "$ARTISTIC_FILES" >> "$BASELINE_FILE"
fi

echo "" >> $REPORT_FILE

# 8. 系统建议
echo "## 💡 自动化建议" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 基于数据给出建议
if [ "$POETRY_FILES" -gt 150 ]; then
    echo "- ⚠️ **紧急建议**: Poetry文件数过多($POETRY_FILES)，建议立即启动重构" >> $REPORT_FILE
elif [ "$POETRY_FILES" -gt 120 ]; then
    echo "- 📋 **重构建议**: Poetry文件数较多($POETRY_FILES)，建议继续推进重构计划" >> $REPORT_FILE
else
    echo "- ✅ **状态良好**: Poetry文件数控制良好($POETRY_FILES)" >> $REPORT_FILE
fi

if [ "$RHYME_FILES" -gt 100 ]; then
    echo "- 🔄 **优先任务**: 韵律文件重复度高($RHYME_FILES)，优先统一韵律数据模型" >> $REPORT_FILE
fi

if [ "$ARTISTIC_FILES" -gt 30 ]; then
    echo "- 🎨 **整合建议**: 艺术评价文件分散($ARTISTIC_FILES)，建议建立统一评价框架" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE

# 结束标记
cat >> $REPORT_FILE << EOF
---

## 📞 报告说明

本报告由骆言项目健康度自动监控系统生成，用于跟踪项目重构进展和技术债务状况。

### 相关链接
- 战略实施计划: Issue #1875
- Poetry重构计划: Issue #1876  
- 监控自动化方案: Issue #1877

### 下次监控
建议每日运行此脚本，或在重大代码变更后手动运行。

*报告生成时间: $(date)*  
*监控脚本版本: v1.0*  
*Author: Papa, Project Planner*

EOF

# 输出总结
echo
echo "✅ 健康度报告已生成: $REPORT_FILE"
echo "📊 报告摘要:"
echo "   - Poetry模块: $POETRY_FILES 文件"
echo "   - 韵律相关: $RHYME_FILES 文件"  
echo "   - 艺术评价: $ARTISTIC_FILES 文件"
echo "   - 编译状态: $(dune build >/dev/null 2>&1 && echo "✅成功" || echo "❌失败")"

# 如果是CI环境，自动提交报告
if [ "$CI" = "true" ] && [ -d ".git" ]; then
    echo "CI环境检测到，准备提交监控报告..."
    git add "$REPORT_FILE" || true
    git commit -m "📊 自动生成项目健康度报告 - $(date +%Y-%m-%d)" || echo "无需提交或提交失败"
fi

echo "=== 监控完成 ==="