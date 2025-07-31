#!/bin/bash
# Papa综合项目监控仪表板
# Author: Papa, Project Planner
# 用途: 监控骆言项目健康度和Phase进展

echo "======================================"
echo "🎯 Papa Phase 6战略协调监控仪表板 v2.0"
echo "监控时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "基于: Issue #1908 Phase 6综合战略规划与实施协调中心"
echo "======================================"

# 核心架构指标监控
echo
echo "📊 核心架构进展监控:"
POETRY_FILES=$(find src/poetry -name '*.ml' 2>/dev/null | wc -l)
RHYME_FILES=$(find src/poetry -name '*rhyme*' 2>/dev/null | wc -l)
CACHE_FILES=$(find src -name '*cache*' -name '*.ml' 2>/dev/null | wc -l)
TOTAL_ML_FILES=$(find src -name '*.ml' 2>/dev/null | wc -l)

echo "总ML文件数: $TOTAL_ML_FILES"
echo "Poetry模块进展: $POETRY_FILES/201 → Phase 6目标:150 (25.4%架构优化)"

# 计算Poetry模块减少百分比 (基线201个)
if [ $POETRY_FILES -lt 201 ]; then
    REDUCTION=$((201 - POETRY_FILES))
    PERCENTAGE=$(echo "scale=1; $REDUCTION * 100 / 201" | bc -l 2>/dev/null || echo "0")
    echo "Poetry模块已减少: $REDUCTION个 (${PERCENTAGE}%)"
else
    echo "Poetry模块减少: 尚未开始 (Phase 6目标: 25.4%减少)"
fi

echo "韵律文件进展: $RHYME_FILES → 目标:100"
echo "缓存文件现状: $CACHE_FILES → 目标:统一缓存引擎"

# 编译性能监控
echo
echo "⚡ 编译状态与性能监控:"
COMPILE_START=$(date +%s.%N)
if dune build > /dev/null 2>&1; then
    COMPILE_END=$(date +%s.%N)
    if command -v bc >/dev/null 2>&1; then
        COMPILE_TIME=$(echo "$COMPILE_END - $COMPILE_START" | bc -l)
        printf "编译时间: %.3fs\n" $COMPILE_TIME
        
        # 性能基准评估 (假设基线为1.0秒)
        BASELINE=1.0
        if (( $(echo "$COMPILE_TIME < $BASELINE" | bc -l) )); then
            echo "✅ 编译性能: 优于基线"
        else
            echo "⚠️ 编译性能: 可优化空间"
        fi
    else
        echo "编译时间: 测量需要bc工具"
    fi
    echo "✅ 编译状态: 正常"
else
    echo "❌ 编译状态: 失败，需要立即修复"
fi

# 测试状态监控
echo
echo "🧪 测试质量监控:"
TEST_FILES=$(find test -name '*.ml' 2>/dev/null | wc -l)
echo "测试文件总数: $TEST_FILES"

# 简单的测试运行检查
if dune exec test/test_minimal.exe > /dev/null 2>&1; then
    echo "✅ 基础测试: 通过"
else
    echo "⚠️ 基础测试: 可能存在问题"
fi

# Git协作状态监控
echo
echo "🤝 协作状态监控:"
RECENT_COMMITS=$(git log --since="1 day ago" --oneline 2>/dev/null | wc -l)
ACTIVE_BRANCHES=$(git branch -r 2>/dev/null | grep -v HEAD | wc -l)
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)

echo "当前分支: $CURRENT_BRANCH"
echo "24小时内提交: $RECENT_COMMITS"
echo "远程活跃分支: $ACTIVE_BRANCHES"

# Phase进展评估
echo
echo "🎯 Phase进展自动评估:"
echo
echo "Phase 1 (8月1-15日) 目标进展:"
if [ $POETRY_FILES -le 170 ]; then
    echo "✅ Poetry模块整合: 已达成Phase 1目标"
elif [ $POETRY_FILES -le 180 ]; then
    echo "🔄 Poetry模块整合: 接近Phase 1目标"
else
    echo "⚠️ Poetry模块整合: 需要加速推进"
fi

if [ $RHYME_FILES -le 100 ]; then
    echo "✅ 韵律文件整合: 已达成目标"
elif [ $RHYME_FILES -le 120 ]; then
    echo "🔄 韵律文件整合: 进行中"
else
    echo "⚠️ 韵律文件整合: 需要启动"
fi

# Unicode优化状态
echo
echo "Unicode优化完善状态:"
if git log --oneline | grep -q "Unicode.*fix\|Unicode.*optimization"; then
    echo "✅ Unicode优化: 已有相关改进"
else
    echo "📋 Unicode优化: 等待Issue #1857处理"
fi

# 风险预警系统
echo
echo "⚠️ 风险预警系统:"
RISK_LEVEL="LOW"
RISK_FACTORS=()

# 检查编译状态风险
if ! dune build > /dev/null 2>&1; then
    echo "🚨 高风险: 编译系统异常"
    RISK_LEVEL="HIGH"
    RISK_FACTORS+=("编译失败")
fi

# 检查Poetry模块减少进展
if [ $POETRY_FILES -gt 185 ]; then
    echo "⚠️ 中风险: Poetry模块减少进展缓慢"
    if [ "$RISK_LEVEL" != "HIGH" ]; then
        RISK_LEVEL="MEDIUM"
    fi
    RISK_FACTORS+=("Poetry整合滞后")
fi

# 检查最近提交活跃度
if [ $RECENT_COMMITS -eq 0 ]; then
    echo "📋 信息: 24小时内无提交 (可能正常)"
fi

echo "当前风险等级: $RISK_LEVEL"
if [ ${#RISK_FACTORS[@]} -gt 0 ]; then
    echo "风险因素: ${RISK_FACTORS[*]}"
fi

# 下一步行动建议
echo
echo "📋 Papa行动建议:"
if [ $POETRY_FILES -gt 180 ]; then
    echo "1. 优先启动Poetry模块依赖分析"
    echo "2. 识别最容易整合的模块群组"
fi

if [ $RHYME_FILES -gt 120 ]; then
    echo "3. 开始韵律数据重复分析"
    echo "4. 设计统一韵律数据架构"
fi

echo "5. 持续监控Issue #1891的Agent任务认领情况"
echo "6. 准备Phase 2性能优化基准测试"

# 监控数据保存
REPORT_DIR="monitoring_reports"
mkdir -p "$REPORT_DIR"
REPORT_FILE="$REPORT_DIR/papa_health_report_$(date +%Y%m%d_%H%M%S).md"

cat > "$REPORT_FILE" << EOF
# Papa项目健康度报告

**生成时间**: $(date '+%Y-%m-%d %H:%M:%S')  
**基于**: Issue #1891综合战略路线图

## 核心指标
- Poetry模块数: $POETRY_FILES/194
- 韵律文件数: $RHYME_FILES
- 测试文件数: $TEST_FILES
- 风险等级: $RISK_LEVEL

## Phase 1 进展
- Poetry模块目标(170): $([ $POETRY_FILES -le 170 ] && echo "✅ 达成" || echo "⚠️ 进行中")
- 韵律文件目标(100): $([ $RHYME_FILES -le 100 ] && echo "✅ 达成" || echo "⚠️ 进行中")

## 协作状态
- 24小时提交: $RECENT_COMMITS
- 当前分支: $CURRENT_BRANCH
- 活跃分支: $ACTIVE_BRANCHES

**Author: Papa监控系统**
EOF

echo
echo "======================================"
echo "📊 监控报告已保存: $REPORT_FILE"
echo "下次建议监控时间: $(date -d '+4 hours' '+%H:%M')"
echo "持续跟踪Issue: #1891"
echo "======================================"

# 如果是CI环境，输出GitHub Actions格式
if [ "$GITHUB_ACTIONS" = "true" ]; then
    echo "::notice title=Papa监控::Poetry模块:$POETRY_FILES/194, 风险等级:$RISK_LEVEL"
fi