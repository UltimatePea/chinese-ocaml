#!/bin/bash  
# Papa综合项目监控仪表板 v2.0
# 骆言项目2025综合战略实施总协调中心监控系统
# Author: Papa, Project Planner

set -e

echo "======================================"
echo "Papa战略协调监控仪表板 v2.0"
echo "监控时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "协调中心: Issue #1910"
echo "======================================"

# 核心架构指标监控
echo
echo "📊 核心架构进展监控:"
POETRY_FILES=$(find src/poetry -name '*.ml' 2>/dev/null | wc -l)
RHYME_FILES=$(find src/poetry -name '*rhyme*' 2>/dev/null | wc -l)
CACHE_FILES=$(find src/poetry -name '*cache*' 2>/dev/null | wc -l)
DATA_FILES=$(find src/poetry -name '*data*' 2>/dev/null | wc -l)

echo "Poetry模块进展: $POETRY_FILES/201 → 目标:150 (需减少$((201-150))个)"
if [ $POETRY_FILES -le 150 ]; then
    echo "✅ Poetry模块整合目标已达成！"
elif [ $POETRY_FILES -le 170 ]; then
    echo "🔄 Poetry模块整合Phase 1进行中"
else
    echo "⚠️ Poetry模块整合需要加速"
fi

echo "韵律文件进展: $RHYME_FILES/138 → 目标:40 (需减少$((138-40))个)"
if [ $RHYME_FILES -le 40 ]; then
    echo "✅ 韵律文件整合目标已达成！"
elif [ $RHYME_FILES -le 100 ]; then
    echo "🔄 韵律文件整合进行中"
else
    echo "⚠️ 韵律文件整合需要加速"
fi

echo "缓存文件进展: $CACHE_FILES/22 → 目标:1 (需减少$((22-1))个)"
if [ $CACHE_FILES -le 1 ]; then
    echo "✅ 缓存统一目标已达成！"
elif [ $CACHE_FILES -le 10 ]; then
    echo "🔄 缓存统一进行中"
else
    echo "⚠️ 缓存统一需要加速"
fi

echo "数据文件总数: $DATA_FILES (优化目标)"

# 编译性能监控
echo
echo "⚡ 编译性能监控:"
COMPILE_START=$(date +%s.%N)
if dune build > /dev/null 2>&1; then
    COMPILE_END=$(date +%s.%N)
    COMPILE_TIME=$(echo "$COMPILE_END - $COMPILE_START" | bc -l 2>/dev/null || echo "0.979")
    printf "编译时间: %.3fs (基线:0.979s, 目标:<0.85s)\n" $COMPILE_TIME
    
    # 判断编译性能状态
    if command -v bc >/dev/null 2>&1; then
        if (( $(echo "$COMPILE_TIME < 0.85" | bc -l 2>/dev/null || echo "0") )); then
            echo "✅ 编译性能目标已达成"
        elif (( $(echo "$COMPILE_TIME < 0.979" | bc -l 2>/dev/null || echo "0") )); then
            echo "🔄 编译性能改善中"
        else
            echo "⚠️ 编译性能需要优化"
        fi
    else
        echo "ℹ️ 编译性能对比需要bc工具"
    fi
    echo "✅ 编译状态正常"
else
    echo "❌ 编译失败，需要立即修复"
    COMPILE_FAILED=1
fi

# 测试质量监控  
echo
echo "🧪 测试质量监控:"
TEST_TOTAL=$(find test -name '*.ml' 2>/dev/null | wc -l)
echo "测试文件总数: $TEST_TOTAL"

# 检查测试是否可以运行
if [ -z "$COMPILE_FAILED" ]; then
    echo "运行基础测试验证..."
    if timeout 30s dune test > /dev/null 2>&1; then
        echo "✅ 基础测试通过"
    else
        echo "⚠️ 测试运行需要检查"
    fi
fi

# Git协作状态监控
echo
echo "🤝 协作状态监控:"
RECENT_COMMITS=$(git log --since="1 day ago" --oneline 2>/dev/null | wc -l)
ACTIVE_BRANCHES=$(git branch -r 2>/dev/null | grep -v HEAD | wc -l)
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "当前分支: $CURRENT_BRANCH"
echo "24小时内提交: $RECENT_COMMITS"
echo "活跃分支数: $ACTIVE_BRANCHES"

# 检查关键PR状态
echo
echo "📋 关键PR状态监控:"
if command -v gh >/dev/null 2>&1; then
    PR_1892_STATUS=$(gh pr view 1892 --json state 2>/dev/null | jq -r '.state' 2>/dev/null || echo "unknown")
    echo "PR #1892 (Poetry整合Phase 1): $PR_1892_STATUS"
    
    if [ "$PR_1892_STATUS" = "MERGED" ]; then
        echo "✅ Poetry整合Phase 1已完成"
    elif [ "$PR_1892_STATUS" = "OPEN" ]; then
        echo "🔄 Poetry整合Phase 1进行中"
    else
        echo "⚠️ PR #1892状态需要检查"
    fi
else
    echo "ℹ️ gh工具未安装，无法检查PR状态"
fi

# Phase进展综合评估
echo
echo "🎯 Phase进展综合评估:"

# Phase 1 评估 (201→170模块)
if [ $POETRY_FILES -le 170 ]; then
    echo "✅ Phase 1目标: Poetry模块初步整合达成 ($POETRY_FILES/170)"
elif [ $POETRY_FILES -le 185 ]; then
    echo "🔄 Phase 1目标: Poetry模块整合进行中 ($POETRY_FILES/170)"
    PROGRESS_PERCENT=$(( (201-POETRY_FILES)*100/(201-170) ))
    echo "   进展: ${PROGRESS_PERCENT}%"
else
    echo "⚠️ Phase 1目标: Poetry模块整合需要加速 ($POETRY_FILES/170)"
fi

# Phase 2 评估 (201→150模块)
if [ $POETRY_FILES -le 150 ]; then
    echo "🚀 Phase 2目标: Poetry模块最终整合已达成！"
elif [ $POETRY_FILES -le 170 ]; then
    echo "🎯 Phase 2目标: 准备启动最终整合阶段"
else
    echo "📋 Phase 2目标: 等待Phase 1完成"
fi

# 风险预警系统
echo
echo "⚠️ 风险预警系统:"
RISK_LEVEL="LOW"
RISK_MESSAGES=()

# 编译时间风险检查
if [ -n "$COMPILE_FAILED" ]; then
    echo "🚨 高风险: 编译失败，需要立即修复"
    RISK_LEVEL="CRITICAL"
    RISK_MESSAGES+=("编译失败需要立即处理")
elif command -v bc >/dev/null 2>&1; then
    if (( $(echo "$COMPILE_TIME > 1.2" | bc -l 2>/dev/null || echo "0") )); then
        echo "🚨 高风险: 编译时间超过基线20%"
        RISK_LEVEL="HIGH"
        RISK_MESSAGES+=("编译性能显著下降")
    fi
fi

# Poetry模块整合进展风险检查
if [ $POETRY_FILES -gt 185 ]; then
    echo "⚠️ 中风险: Poetry模块减少进展缓慢"
    if [ "$RISK_LEVEL" = "LOW" ]; then
        RISK_LEVEL="MEDIUM"
    fi
    RISK_MESSAGES+=("Poetry模块整合进展需要加速")
fi

# 韵律文件整合风险检查
if [ $RHYME_FILES -gt 120 ]; then
    echo "⚠️ 中风险: 韵律文件整合进展缓慢"
    if [ "$RISK_LEVEL" = "LOW" ]; then
        RISK_LEVEL="MEDIUM"
    fi
    RISK_MESSAGES+=("韵律文件整合需要推进")
fi

# 协作活跃度检查
if [ $RECENT_COMMITS -eq 0 ]; then
    echo "ℹ️ 提醒: 24小时内无新提交"
    RISK_MESSAGES+=("项目活跃度需要关注")
fi

echo "当前风险等级: $RISK_LEVEL"

# 生成建议行动
echo
echo "💡 Papa建议行动:"
if [ "$RISK_LEVEL" = "CRITICAL" ]; then
    echo "🚨 立即行动: 修复编译问题，确保系统基础稳定"
elif [ "$RISK_LEVEL" = "HIGH" ]; then
    echo "⚡ 优先行动: 解决性能问题，检查代码质量"
elif [ "$RISK_LEVEL" = "MEDIUM" ]; then
    echo "📋 计划行动: 加速Poetry模块整合，推进韵律文件统一"
else
    echo "✅ 保持现状: 项目进展良好，继续按计划执行"
fi

# 下一步重点任务提醒
echo
echo "🎯 下一步重点任务:"
if [ $POETRY_FILES -gt 170 ]; then
    echo "1. 推进PR #1892的Poetry模块整合工作"
    echo "2. 完成201→170模块的Phase 1目标"
fi

if [ $RHYME_FILES -gt 100 ]; then
    echo "3. 启动韵律文件整合，目标138→100个文件"
fi

if [ $CACHE_FILES -gt 10 ]; then
    echo "4. 规划缓存系统统一，目标22→1个引擎"
fi

echo "5. 保持测试覆盖率持续提升"
echo "6. 维护Issue #1910协调中心的活跃度"

# 成功指标总结
echo
echo "📊 当前成功指标总结:"
echo "├── Poetry模块整合: $(( (201-POETRY_FILES)*100/51 ))% (目标51个减少)"
echo "├── 韵律文件整合: $(( (138-RHYME_FILES)*100/98 ))% (目标98个减少)"  
echo "├── 缓存文件整合: $(( (22-CACHE_FILES)*100/21 ))% (目标21个减少)"
echo "├── 编译稳定性: $([ -z "$COMPILE_FAILED" ] && echo "✅ 稳定" || echo "❌ 需修复")"
echo "└── 测试基础设施: $TEST_TOTAL个测试文件 ✅"

echo
echo "======================================"
echo "Papa监控报告生成完成"
echo "下次监控建议: $(date -d '+1 hour' '+%H:%M' 2>/dev/null || echo '1小时后')"
echo "协调中心: https://github.com/UltimatePea/chinese-ocaml/issues/1910"
echo "======================================"

# 如果存在风险，提供详细的处理建议
if [ ${#RISK_MESSAGES[@]} -gt 0 ]; then
    echo
    echo "🔧 详细风险处理建议:"
    for message in "${RISK_MESSAGES[@]}"; do
        echo "   • $message"
    done
    echo
fi

# 生成简要状态报告供其他脚本使用
cat > /tmp/papa_monitor_status.txt << EOF
POETRY_FILES=$POETRY_FILES
RHYME_FILES=$RHYME_FILES
CACHE_FILES=$CACHE_FILES
TEST_FILES=$TEST_TOTAL
RISK_LEVEL=$RISK_LEVEL
COMPILE_STATUS=$([ -z "$COMPILE_FAILED" ] && echo "OK" || echo "FAILED")
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
EOF

echo "状态报告已保存至: /tmp/papa_monitor_status.txt"