#!/bin/bash
# Papa Poetry模块优化进度监控脚本
# Author: Papa, Roadmap Planner
# Purpose: 监控Poetry模块优化进展和质量指标

set -e

# 配置参数
REPORT_DIR="monitoring_reports"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
REPORT_FILE="${REPORT_DIR}/papa_poetry_optimization_report_${TIMESTAMP}.md"

# 创建报告目录
mkdir -p "$REPORT_DIR"

# 开始生成报告
cat > "$REPORT_FILE" << 'EOF'
# Papa Poetry模块优化进度报告

**生成时间**: $(date '+%Y年%m月%d日 %H:%M:%S')
**生成者**: Papa Poetry优化监控系统
**分支**: $(git branch --show-current)
**提交**: $(git rev-parse --short HEAD)

---

## 📊 Poetry模块现状统计

EOF

# 获取基础统计数据
echo "正在收集Poetry模块统计数据..."

# Poetry模块统计
poetry_ml_count=$(find src/poetry -name "*.ml" | wc -l)
poetry_mli_count=$(find src/poetry -name "*.mli" | wc -l)
interface_ratio=$(echo "scale=1; $poetry_mli_count * 100 / $poetry_ml_count" | bc)

# 按目录分类统计
data_modules=$(find src/poetry -path "*/data/*" -name "*.ml" | wc -l)
rhyme_modules=$(find src/poetry -name "*rhyme*" -name "*.ml" | wc -l)
artistic_modules=$(find src/poetry -name "*artistic*" -name "*.ml" | wc -l)
cache_modules=$(find src/poetry -path "*/cache*" -name "*.ml" | wc -l)
evaluators_modules=$(find src/poetry -path "*/evaluators/*" -name "*.ml" | wc -l)

# 代码质量指标
total_lines=$(find src/poetry -name "*.ml" -exec wc -l {} + | tail -1 | awk '{print $1}')
avg_lines=$(echo "scale=0; $total_lines / $poetry_ml_count" | bc)

# 大文件统计
large_files=$(find src/poetry -name "*.ml" -exec wc -l {} + | awk '$1 > 200 {count++} END {print count+0}')
very_large_files=$(find src/poetry -name "*.ml" -exec wc -l {} + | awk '$1 > 400 {count++} END {print count+0}')

# 写入统计结果
cat >> "$REPORT_FILE" << EOF

### 模块数量统计
- **总ML文件数**: $poetry_ml_count 个
- **总MLI文件数**: $poetry_mli_count 个
- **接口完整性**: ${interface_ratio}%

### 按功能分类
- **数据处理模块**: $data_modules 个
- **韵律处理模块**: $rhyme_modules 个
- **艺术评估模块**: $artistic_modules 个
- **缓存管理模块**: $cache_modules 个
- **评估器模块**: $evaluators_modules 个

### 代码规模指标
- **总代码行数**: $total_lines 行
- **平均文件大小**: $avg_lines 行
- **大文件数(>200行)**: $large_files 个
- **超大文件数(>400行)**: $very_large_files 个

---

## 🔧 编译与测试状态

EOF

echo "正在检查编译和测试状态..."

# 编译状态检查
echo "### 编译状态检查" >> "$REPORT_FILE"
if dune build src/poetry/ 2>/dev/null; then
    echo "- ✅ Poetry模块编译成功" >> "$REPORT_FILE"
    compile_status="SUCCESS"
else
    echo "- ❌ Poetry模块编译失败" >> "$REPORT_FILE"
    compile_status="FAILED"
fi

# 测试状态检查
echo "" >> "$REPORT_FILE"
echo "### 测试状态检查" >> "$REPORT_FILE"
if dune runtest 2>/dev/null; then
    echo "- ✅ 所有测试通过" >> "$REPORT_FILE"
    test_status="PASSED"
else
    echo "- ⚠️ 部分测试失败" >> "$REPORT_FILE"
    test_status="FAILED"
fi

# 性能基准测试
echo "" >> "$REPORT_FILE"
echo "### 性能基准测试" >> "$REPORT_FILE"
compile_start=$(date +%s.%N)
dune build src/poetry/ 2>/dev/null || true
compile_end=$(date +%s.%N)
compile_time=$(echo "$compile_end - $compile_start" | bc)

echo "- Poetry模块编译时间: ${compile_time}秒" >> "$REPORT_FILE"

# 依赖关系分析
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## 🔍 技术债务分析" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 重复模块模式检测
unified_modules=$(find src/poetry -name "unified_*" -name "*.ml" | wc -l)
legacy_modules=$(find src/poetry -name "*legacy*" -name "*.ml" | wc -l)
compat_modules=$(find src/poetry -name "*compat*" -name "*.ml" | wc -l)

cat >> "$REPORT_FILE" << EOF
### 模块重复度分析
- **统一模块数量**: $unified_modules 个
- **兼容层模块**: $compat_modules 个
- **遗留模块**: $legacy_modules 个

### 重复代码热点
EOF

# 查找可能的重复代码模式
echo "- **韵律处理重复**: $(grep -r "rhyme_analysis\|rhyme_check" src/poetry/ | wc -l) 个相似函数" >> "$REPORT_FILE"
echo "- **数据加载重复**: $(grep -r "load_data\|data_loader" src/poetry/ | wc -l) 个相似函数" >> "$REPORT_FILE"
echo "- **JSON处理重复**: $(grep -r "json_parse\|parse_json" src/poetry/ | wc -l) 个相似函数" >> "$REPORT_FILE"

# 优化建议
cat >> "$REPORT_FILE" << EOF

---

## 📋 优化建议与下一步

### 立即优化项 (高优先级)
EOF

if [ $rhyme_modules -gt 100 ]; then
    echo "- 🔥 **韵律模块整合**: 当前$rhyme_modules个韵律模块，建议整合至80-90个" >> "$REPORT_FILE"
fi

if [ $interface_ratio -lt 80 ]; then
    echo "- 📝 **接口完整性提升**: 当前${interface_ratio}%，目标>80%" >> "$REPORT_FILE"
fi

if [ $large_files -gt 5 ]; then
    echo "- ✂️ **大文件重构**: ${large_files}个大文件需要分解，目标<5个" >> "$REPORT_FILE"
fi

if [ "$compile_status" = "FAILED" ]; then
    echo "- 🚨 **编译修复**: 优先修复编译错误" >> "$REPORT_FILE"
fi

# 中期优化项
cat >> "$REPORT_FILE" << EOF

### 中期优化项 (中优先级)
- 🎨 **艺术评估引擎统一**: 整合$artistic_modules个艺术模块
- 💾 **缓存系统优化**: 统一$cache_modules个缓存模块
- 📊 **数据访问层重构**: 优化$data_modules个数据模块
- 🧹 **兼容层清理**: 评估$compat_modules个兼容层模块

### 长期优化项 (低优先级)
- 📚 **API标准化**: 建立统一的Poetry API接口
- ⚡ **性能优化**: 韵律查询目标<50ms
- 🧪 **测试覆盖率**: 目标Poetry模块覆盖率>70%
- 📖 **文档完善**: 完善接口文档和使用示例

---

## 📈 进度跟踪指标

### 基线指标 (起始状态)
- **模块总数**: $poetry_ml_count 个
- **接口完整性**: ${interface_ratio}%
- **编译时间**: ${compile_time}秒
- **大文件数量**: $large_files 个

### 目标指标 (阶段一完成)
- **模块总数**: 170-180 个 (减少15-30%)
- **接口完整性**: >80%
- **编译时间**: <$(echo "$compile_time * 0.8" | bc)秒
- **大文件数量**: <5 个

---

## 🎯 Papa路线图执行状态

EOF

# 检查Papa路线图文档
if [ -f "PAPA_COMPREHENSIVE_STRATEGIC_ROADMAP_2025_Q3.md" ]; then
    echo "- ✅ **Papa战略路线图**: 已创建并可执行" >> "$REPORT_FILE"
else
    echo "- ❌ **Papa战略路线图**: 文档缺失" >> "$REPORT_FILE"
fi

# 检查执行分支
current_branch=$(git branch --show-current)
if [[ $current_branch == *"papa"* ]] || [[ $current_branch == *"poetry"* ]]; then
    echo "- ✅ **执行分支**: 当前分支 '$current_branch' 符合执行要求" >> "$REPORT_FILE"
else
    echo "- ⚠️ **执行分支**: 建议创建专用的papa-poetry-optimization分支" >> "$REPORT_FILE"
fi

# 质量门控状态
cat >> "$REPORT_FILE" << EOF

### 质量门控状态
- **编译通过**: $compile_status
- **测试通过**: $test_status
- **接口完整性**: $([ $(echo "$interface_ratio >= 70" | bc) -eq 1 ] && echo "✅ PASS" || echo "⚠️ NEEDS_IMPROVEMENT")
- **代码规模**: $([ $large_files -le 10 ] && echo "✅ ACCEPTABLE" || echo "⚠️ NEEDS_REFACTOR")

---

## 📞 下一步行动建议

### 本周待办 (8月2-9日)
1. **模块依赖分析**: 完成Poetry模块依赖关系图
2. **重构计划制定**: 确定第一批整合模块清单
3. **性能基准建立**: 建立韵律查询和艺术评估基准
4. **质量监控部署**: 自动化质量门控检查

### 本月目标 (8月)
1. **韵律模块整合**: 减少15-20个重复韵律模块
2. **API接口统一**: 建立统一的Poetry访问接口
3. **性能提升验证**: 韵律查询性能提升30%+
4. **向后兼容确保**: 100%现有功能保持可用

---

**报告生成时间**: $(date '+%Y年%m月%d日 %H:%M:%S')
**Papa Poetry优化监控系统** 🎭💻🚀

EOF

echo "✅ Papa Poetry优化进度报告生成完成"
echo "📄 报告文件: $REPORT_FILE"
echo ""
echo "📊 关键指标摘要:"
echo "   Poetry模块总数: $poetry_ml_count 个"
echo "   接口完整性: ${interface_ratio}%"
echo "   编译状态: $compile_status"
echo "   大文件数量: $large_files 个"
echo ""
echo "🎯 优化目标: 194 → 170-180个模块, 性能提升40%+"
echo "📅 下次检查: $(date -d '+1 week' '+%Y年%m月%d日')"

# 显示报告文件内容
echo ""
echo "📋 完整报告内容:"
echo "=================="
cat "$REPORT_FILE"