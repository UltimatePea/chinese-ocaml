#!/bin/bash

# Papa Phase 2 协调监控脚本
# Author: Papa, Project Planner
# 用途: 实时监控骆言项目Phase 2技术现代化进展
# 关联Issue: #2116

echo "============================================="
echo "Papa Phase 2 协调监控报告 - $(date)"
echo "============================================="
echo ""

# 基础配置
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
REPORT_DIR="monitoring_reports"
mkdir -p "$REPORT_DIR"

# 1. 核心技术指标监控
echo "📊 核心技术指标监控"
echo "---------------------------------------------"

# Poetry模块数量
POETRY_COUNT=$(find src/poetry -name '*.ml' | wc -l)
echo "Poetry模块总数: $POETRY_COUNT (基线: 196, 目标: ≤100)"

# 接口完整性
ML_COUNT=$POETRY_COUNT
MLI_COUNT=$(find src/poetry -name '*.mli' | wc -l)
if [ $ML_COUNT -gt 0 ]; then
    INTERFACE_RATIO=$(echo "scale=1; $MLI_COUNT * 100 / $ML_COUNT" | bc)
    echo "接口完整性: ${INTERFACE_RATIO}% (基线: 71.4%, 目标: ≥85%)"
else
    echo "接口完整性: 计算错误 - 模块数量为0"
    INTERFACE_RATIO=0
fi

# 编译状态检查
echo ""
echo "🔧 编译质量状态"
echo "---------------------------------------------"
if dune build > /tmp/build_output 2>&1; then
    WARNINGS=$(grep -c "Warning\|unused-field" /tmp/build_output)
    ERRORS=$(grep -c "Error" /tmp/build_output)
    echo "编译状态: ✅ 通过"
    echo "编译警告: $WARNINGS (目标: 0)"
    echo "编译错误: $ERRORS (目标: 0)"
    
    # 特别关注unused-field警告
    UNUSED_FIELDS=$(grep -c "unused-field" /tmp/build_output)
    echo "unused-field警告: $UNUSED_FIELDS (Phase 2.1重点修复)"
else
    echo "编译状态: ❌ 失败"
    WARNINGS=999
    ERRORS=999
    UNUSED_FIELDS=999
fi

# 性能基准测试
echo ""
echo "⚡ 性能基准监控"
echo "---------------------------------------------"
COMPILE_START=$(date +%s.%N)
dune build > /dev/null 2>&1
COMPILE_END=$(date +%s.%N)
COMPILE_TIME=$(echo "$COMPILE_END - $COMPILE_START" | bc -l)
printf "编译时间: %.3fs (目标: <0.200s)\n" $COMPILE_TIME

# 检查性能是否达标
PERFORMANCE_OK=0
if (( $(echo "$COMPILE_TIME < 0.200" | bc -l) )); then
    echo "编译性能: ✅ 达标"
    PERFORMANCE_OK=1
else
    echo "编译性能: ⏳ 需要优化"
fi

# 2. Phase 2进展评估
echo ""
echo "🛣️ Phase 2进展评估"
echo "---------------------------------------------"

# Phase 2.1 (8月2-9日) - 编译系统稳定化
if [ $WARNINGS -eq 0 ] && [ $ERRORS -eq 0 ]; then
    PHASE21_STATUS="✅ 已完成"
elif [ $UNUSED_FIELDS -eq 0 ]; then
    PHASE21_STATUS="🟡 进行中 - unused-field已修复"
else
    PHASE21_STATUS="🔄 进行中 - 需要修复$UNUSED_FIELDS个unused-field警告"
fi
echo "Phase 2.1 编译系统稳定化: $PHASE21_STATUS"

# Phase 2.2 (8月10-23日) - Poetry模块整合
if [ $POETRY_COUNT -le 150 ]; then
    if [ $POETRY_COUNT -le 100 ]; then
        PHASE22_STATUS="✅ 已完成 - 达到最终目标"
    else
        PHASE22_STATUS="🟡 进行中 - 第二阶段目标已达成"
    fi
elif [ $POETRY_COUNT -le 180 ]; then
    PHASE22_STATUS="🔄 进行中 - 第一阶段整合"
else
    PHASE22_STATUS="⏳ 待开始"
fi
echo "Phase 2.2 Poetry模块整合: $PHASE22_STATUS"

# Phase 2.3 (8月24-31日) - 缓存与性能优化
if [ $PERFORMANCE_OK -eq 1 ] && (( $(echo "$INTERFACE_RATIO >= 85.0" | bc -l) )); then
    PHASE23_STATUS="✅ 已完成"
elif [ $PERFORMANCE_OK -eq 1 ]; then
    PHASE23_STATUS="🟡 进行中 - 性能达标，接口标准化进行中"
else
    PHASE23_STATUS="⏳ 待开始"
fi
echo "Phase 2.3 缓存与性能优化: $PHASE23_STATUS"

# 3. 韵律系统模块分析
echo ""
echo "🎵 韵律系统整合分析"
echo "---------------------------------------------"
RHYME_COUNT=$(find src/poetry -path "*/rhyme/*" -name '*.ml' | wc -l)
echo "韵律模块数量: $RHYME_COUNT (目标: ≤15)"

if [ $RHYME_COUNT -le 15 ]; then
    echo "韵律整合状态: ✅ 目标已达成"
elif [ $RHYME_COUNT -le 40 ]; then
    echo "韵律整合状态: 🟡 进行中 - 显著进展"
else
    echo "韵律整合状态: 🔄 需要加速整合"
fi

# 4. 风险评估
echo ""
echo "⚠️ 风险评估与预警"
echo "---------------------------------------------"

RISK_LEVEL="LOW"
RISK_FACTORS=""

# 检查编译失败风险
if [ $ERRORS -gt 0 ]; then
    RISK_LEVEL="CRITICAL"
    RISK_FACTORS="$RISK_FACTORS\n  - 编译系统失败，需要立即修复"
fi

# 检查模块数量异常
if [ $POETRY_COUNT -gt 210 ]; then
    RISK_LEVEL="HIGH"
    RISK_FACTORS="$RISK_FACTORS\n  - Poetry模块数量异常增长，超出预期"
fi

# 检查警告数量过多
if [ $WARNINGS -gt 20 ]; then
    if [ "$RISK_LEVEL" = "LOW" ]; then
        RISK_LEVEL="MEDIUM"
    fi
    RISK_FACTORS="$RISK_FACTORS\n  - 编译警告数量过多，影响代码质量"
fi

echo "当前风险级别: $RISK_LEVEL"
if [ -n "$RISK_FACTORS" ]; then
    echo "风险因素:$RISK_FACTORS"
else
    echo "风险因素: 无显著风险"
fi

# 5. Agent协作状态监控
echo ""
echo "🤝 Agent协作状态"
echo "---------------------------------------------"
echo "Master协调Issue: #2116 (本次监控相关)"
echo "Papa监控频率: 每2小时执行一次"
echo "任务认领状态: 等待技术实施Agent认领编译警告修复任务"
echo "质量门控: 本脚本提供基础监控，待建立完整质量门控"

# 6. 综合评估与建议
echo ""
echo "📋 综合评估与行动建议"
echo "---------------------------------------------"

OVERALL_PROGRESS="开始阶段"
if [ $WARNINGS -eq 0 ] && [ $ERRORS -eq 0 ]; then
    if [ $POETRY_COUNT -le 150 ]; then
        if [ $POETRY_COUNT -le 100 ]; then
            OVERALL_PROGRESS="接近完成"
        else
            OVERALL_PROGRESS="良好进展"
        fi
    else
        OVERALL_PROGRESS="稳定基础"
    fi
fi

echo "整体进展评估: $OVERALL_PROGRESS"
echo ""
echo "立即行动建议:"

if [ $UNUSED_FIELDS -gt 0 ]; then
    echo "  🔧 优先级P0: 修复rhyme_engine.ml中的$UNUSED_FIELDS个unused-field警告"
fi

if (( $(echo "$INTERFACE_RATIO < 80.0" | bc -l) )); then
    NEEDED_MLI=$((ML_COUNT * 80 / 100 - MLI_COUNT))
    echo "  📋 优先级P1: 添加$NEEDED_MLI个.mli文件以达到80%接口完整性"
fi

if [ $POETRY_COUNT -gt 180 ]; then
    echo "  🏗️ 优先级P1: 开始Poetry模块整合，目标减少至150个"
fi

# 7. 生成详细报告文件
REPORT_FILE="$REPORT_DIR/papa_phase2_report_$TIMESTAMP.md"

cat > "$REPORT_FILE" << EOF
# Papa Phase 2 监控报告

**生成时间**: $(date)  
**报告版本**: v1.0  
**关联Issue**: #2116  

## 核心指标摘要

- **Poetry模块数量**: $POETRY_COUNT (目标: ≤100)
- **接口完整性**: ${INTERFACE_RATIO}% (目标: ≥85%)
- **编译警告**: $WARNINGS (目标: 0)
- **编译时间**: ${COMPILE_TIME}s (目标: <0.200s)
- **风险级别**: $RISK_LEVEL

## Phase进展状态

- **Phase 2.1**: $PHASE21_STATUS
- **Phase 2.2**: $PHASE22_STATUS  
- **Phase 2.3**: $PHASE23_STATUS

## 详细分析

### 编译质量
$(if [ $WARNINGS -eq 0 ]; then echo "✅ 编译质量达标，无警告"; else echo "⚠️ 存在$WARNINGS个编译警告，需要处理"; fi)

### 模块整合进展
$(if [ $POETRY_COUNT -le 150 ]; then echo "✅ 模块整合取得良好进展"; else echo "🔄 模块整合需要加速，当前$POETRY_COUNT个模块"; fi)

### 性能基准
$(if [ $PERFORMANCE_OK -eq 1 ]; then echo "✅ 编译性能达标"; else echo "⏳ 编译性能需要优化"; fi)

**Author: Papa Phase 2 监控系统**
EOF

echo ""
echo "📄 详细报告已生成: $REPORT_FILE"
echo ""
echo "============================================="
echo "Papa Phase 2 监控完成 - $(date)"
echo "下次监控: 2小时后"
echo "============================================="