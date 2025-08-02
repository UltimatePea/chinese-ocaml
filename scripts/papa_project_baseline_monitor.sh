#!/bin/bash
# Papa项目基线监控脚本
# Author: Papa, Project Planner
# Date: 2025年8月2日
# Purpose: 建立骆言项目技术执行基线和持续监控

set -euo pipefail

echo "=============================================="
echo "🎯 Papa项目技术执行基线监控 v1.0"
echo "监控时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "监控分支: $(git branch --show-current)"
echo "=============================================="

# 创建基线报告目录
BASELINE_DIR="baseline_reports"
mkdir -p "$BASELINE_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$BASELINE_DIR/papa_baseline_report_$TIMESTAMP.md"

# 开始生成基线报告
{
    echo "# Papa项目技术执行基线报告"
    echo ""
    echo "**生成时间**: $(date '+%Y年%m月%d日 %H:%M:%S')"
    echo "**生成者**: Papa项目监控系统"
    echo "**目的**: 建立技术执行阶段性能和质量基线"
    echo ""
    echo "---"
    echo ""

    # 1. 代码规模统计
    echo "## 📊 代码规模基线"
    echo ""
    TOTAL_ML=$(find src -name "*.ml" | wc -l)
    TOTAL_MLI=$(find src -name "*.mli" | wc -l)
    POETRY_ML=$(find src/poetry -name "*.ml" | wc -l)
    POETRY_MLI=$(find src/poetry -name "*.mli" | wc -l)
    TEST_ML=$(find test -name "*.ml" | wc -l)
    
    echo "- **OCaml源文件总数**: $TOTAL_ML 个"
    echo "- **OCaml接口文件总数**: $TOTAL_MLI 个"
    echo "- **Poetry模块数量**: $POETRY_ML 个 (.ml文件)"
    echo "- **Poetry接口数量**: $POETRY_MLI 个 (.mli文件)"
    echo "- **测试文件数量**: $TEST_ML 个"
    echo "- **接口完整性比率**: $(echo "scale=1; $TOTAL_MLI * 100 / $TOTAL_ML" | bc -l)%"
    echo ""

    # 2. Poetry模块详细分析
    echo "## 🎭 Poetry模块详细基线"
    echo ""
    RHYME_COUNT=$(find src/poetry -name "*rhyme*" | wc -l)
    ARTISTIC_COUNT=$(find src/poetry -name "*artistic*" | wc -l)
    CACHE_COUNT=$(find src -name "*cache*" | wc -l)
    DATA_COUNT=$(find src -name "*data*" | wc -l)
    
    echo "- **韵律相关文件**: $RHYME_COUNT 个"
    echo "- **艺术评估文件**: $ARTISTIC_COUNT 个"
    echo "- **缓存相关文件**: $CACHE_COUNT 个"
    echo "- **数据处理文件**: $DATA_COUNT 个"
    echo ""
    echo "### Poetry模块分类统计"
    echo "\`\`\`"
    find src/poetry -name "*.ml" | head -20 | while read file; do
        lines=$(wc -l < "$file")
        echo "$(basename "$file"): $lines 行"
    done
    echo "..."
    echo "\`\`\`"
    echo ""

    # 3. 编译性能基线
    echo "## ⚡ 编译性能基线"
    echo ""
    echo "开始编译性能测试..."
    
    # 清理并重新编译
    dune clean > /dev/null 2>&1
    
    COMPILE_START=$(date +%s.%N)
    if dune build > /dev/null 2>&1; then
        COMPILE_END=$(date +%s.%N)
        COMPILE_TIME=$(echo "$COMPILE_END - $COMPILE_START" | bc -l)
        
        printf "- **编译时间**: %.3f 秒\\n" $COMPILE_TIME
        echo "- **编译状态**: ✅ 成功"
        echo "- **编译目标**: 优化15%+ (目标: <0.85秒)"
        
        # 检查编译输出大小
        if [ -d "_build" ]; then
            BUILD_SIZE=$(du -sh _build | cut -f1)
            echo "- **构建产物大小**: $BUILD_SIZE"
        fi
    else
        echo "- **编译状态**: ❌ 失败"
        echo "- **需要立即修复**: 编译错误阻塞项目进展"
    fi
    echo ""

    # 4. 测试覆盖率基线
    echo "## 🧪 测试覆盖率基线"
    echo ""
    
    # 尝试运行测试
    if dune runtest > /dev/null 2>&1; then
        echo "- **测试状态**: ✅ 通过"
        
        # 计算测试覆盖率（如果有相关工具）
        if command -v bisect-ppx-report &> /dev/null; then
            echo "- **覆盖率工具**: 可用"
            # 可以添加具体的覆盖率计算
        else
            echo "- **覆盖率工具**: 未安装"
        fi
        
        # 统计测试文件
        TEST_COUNT=$(find test -name "*.ml" | wc -l)
        echo "- **测试文件数量**: $TEST_COUNT 个"
        echo "- **测试覆盖率目标**: >70% (关键模块)"
        
    else
        echo "- **测试状态**: ⚠️ 存在失败"
        echo "- **需要关注**: 测试失败需要修复"
    fi
    echo ""

    # 5. Git协作状态
    echo "## 🤝 Git协作状态基线"
    echo ""
    RECENT_COMMITS=$(git log --since="1 week ago" --oneline | wc -l)
    TOTAL_COMMITS=$(git log --oneline | wc -l)
    CURRENT_BRANCH=$(git branch --show-current)
    
    echo "- **当前分支**: $CURRENT_BRANCH"
    echo "- **最近一周提交**: $RECENT_COMMITS 个"
    echo "- **项目总提交数**: $TOTAL_COMMITS 个"
    echo "- **最新提交**: $(git log -1 --pretty=format:'%h - %s (%cr)')"
    echo ""

    # 6. 项目健康度评估
    echo "## 🏥 项目健康度基线评估"
    echo ""
    
    HEALTH_SCORE=0
    TOTAL_CHECKS=5
    
    # 检查1: 编译成功
    if dune build > /dev/null 2>&1; then
        echo "- ✅ 编译健康: 项目编译成功"
        HEALTH_SCORE=$((HEALTH_SCORE + 1))
    else
        echo "- ❌ 编译健康: 项目编译失败"
    fi
    
    # 检查2: Poetry模块数量合理
    if [ $POETRY_ML -le 200 ] && [ $POETRY_ML -ge 150 ]; then
        echo "- ✅ 架构健康: Poetry模块数量合理 ($POETRY_ML)"
        HEALTH_SCORE=$((HEALTH_SCORE + 1))
    else
        echo "- ⚠️ 架构健康: Poetry模块需要优化 ($POETRY_ML)"
    fi
    
    # 检查3: 接口完整性
    INTERFACE_RATIO=$(echo "scale=0; $TOTAL_MLI * 100 / $TOTAL_ML" | bc -l)
    if [ $INTERFACE_RATIO -ge 60 ]; then
        echo "- ✅ 接口健康: 接口完整性良好 (${INTERFACE_RATIO}%)"
        HEALTH_SCORE=$((HEALTH_SCORE + 1))
    else
        echo "- ⚠️ 接口健康: 接口完整性需要改善 (${INTERFACE_RATIO}%)"
    fi
    
    # 检查4: 测试存在性
    if [ $TEST_ML -gt 20 ]; then
        echo "- ✅ 测试健康: 测试文件充足 ($TEST_ML 个)"
        HEALTH_SCORE=$((HEALTH_SCORE + 1))
    else
        echo "- ⚠️ 测试健康: 测试文件不足 ($TEST_ML 个)"
    fi
    
    # 检查5: 最近活跃度
    if [ $RECENT_COMMITS -gt 0 ]; then
        echo "- ✅ 活跃健康: 项目持续活跃 ($RECENT_COMMITS 次提交)"
        HEALTH_SCORE=$((HEALTH_SCORE + 1))
    else
        echo "- ⚠️ 活跃健康: 项目活跃度较低"
    fi
    
    HEALTH_PERCENTAGE=$(echo "scale=0; $HEALTH_SCORE * 100 / $TOTAL_CHECKS" | bc -l)
    echo ""
    echo "**整体健康度**: $HEALTH_SCORE/$TOTAL_CHECKS (${HEALTH_PERCENTAGE}%)"
    
    if [ $HEALTH_PERCENTAGE -ge 80 ]; then
        echo "**健康状态**: 🟢 优秀 - 项目状态良好，适合技术执行"
    elif [ $HEALTH_PERCENTAGE -ge 60 ]; then
        echo "**健康状态**: 🟡 良好 - 项目基本健康，需要改进"
    else
        echo "**健康状态**: 🔴 需要关注 - 项目存在问题，需要优先修复"
    fi
    echo ""

    # 7. Papa执行建议
    echo "## 🎯 Papa执行建议"
    echo ""
    echo "基于当前基线分析，Papa提供以下执行建议："
    echo ""
    
    # 根据Poetry模块数量给出建议
    if [ $POETRY_ML -gt 180 ]; then
        echo "### 🎭 Poetry模块优化 (优先级: 高)"
        echo "- **当前状态**: $POETRY_ML 个模块，超出理想范围"
        echo "- **优化目标**: 减少至150-165个模块 (减少15-23%)"
        echo "- **实施策略**: 韵律数据统一，艺术评估引擎整合"
        echo "- **预期收益**: 编译性能提升15%+，维护效率提升"
        echo ""
    fi
    
    # 根据编译性能给出建议
    if command -v bc &> /dev/null && [ $(echo "$COMPILE_TIME > 0.9" | bc -l) -eq 1 ]; then
        echo "### ⚡ 编译性能优化 (优先级: 中)"
        printf "- **当前性能**: %.3f 秒，有提升空间\\n" $COMPILE_TIME
        echo "- **优化目标**: <0.85秒 (提升15%+)"
        echo "- **优化方向**: 模块依赖优化，编译并行化"
        echo ""
    fi
    
    # 测试覆盖率建议
    echo "### 🧪 测试覆盖率提升 (优先级: 中)"
    echo "- **当前状态**: $TEST_ML 个测试文件"
    echo "- **优化目标**: 关键模块覆盖率>70%"
    echo "- **重点模块**: AST、二元运算、内置函数、Poetry核心"
    echo ""
    
    # 总结
    echo "### 📋 立即行动项"
    echo "1. **启动Poetry模块分析**: 完成194个模块依赖关系图"
    echo "2. **建立性能监控**: 定期运行本基线脚本"
    echo "3. **开始模块整合**: 第一批15-20个模块重构"
    echo "4. **质量门控**: 每个变更都要通过编译和基础测试"
    echo ""

    # 8. 监控计划
    echo "## 📅 持续监控计划"
    echo ""
    echo "Papa建议建立以下监控机制："
    echo ""
    echo "- **每日监控**: 运行本脚本，跟踪关键指标变化"
    echo "- **每周报告**: 生成详细的进展分析报告"
    echo "- **里程碑检查**: 在关键节点进行全面评估"
    echo ""
    echo "**下次监控建议时间**: $(date -d '+1 day' '+%Y-%m-%d %H:%M')"
    echo ""

    echo "---"
    echo ""
    echo "**报告结束** - Papa项目监控系统"
    echo "**文件位置**: $REPORT_FILE"
    echo "**使用方法**: 定期运行此脚本跟踪项目改进进展"

} > "$REPORT_FILE"

# 输出到控制台
echo
echo "📊 基线报告核心指标:"
echo "   📁 总OCaml文件: $(find src -name "*.ml" | wc -l) 个"
echo "   🎭 Poetry模块: $(find src/poetry -name "*.ml" | wc -l) 个"
echo "   🧪 测试文件: $(find test -name "*.ml" | wc -l) 个"

# 编译性能测试
echo "   ⚡ 编译性能测试中..."
dune clean > /dev/null 2>&1
COMPILE_START=$(date +%s.%N)
if dune build > /dev/null 2>&1; then
    COMPILE_END=$(date +%s.%N)
    COMPILE_TIME=$(echo "$COMPILE_END - $COMPILE_START" | bc -l)
    printf "   ✅ 编译时间: %.3f 秒\\n" $COMPILE_TIME
else
    echo "   ❌ 编译失败，需要立即修复"
fi

echo
echo "📄 详细基线报告已生成: $REPORT_FILE"
echo "🎯 Papa建议："
echo "   1. 定期运行此脚本监控项目改进进展"
echo "   2. 重点关注Poetry模块数量减少目标"
echo "   3. 监控编译性能优化效果"
echo "   4. 确保每个技术变更都通过质量验证"
echo
echo "🚀 骆言项目技术执行基线建立完成！"
echo "=============================================="