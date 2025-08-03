# 诗词艺术评估文件整合目录 - Issue #2000 实施指南

**Author: Foxtrot, Project Overseer**  
**Date: 2025-08-03**  
**Purpose: 为Issue #2000提供明确的文件整合映射**  
**Status: Active Planning Document**

## 📊 现状统计

经过详细分析，需要整合的文件总数：**42个文件**

```bash
分布情况：
src/poetry/*artistic*.ml     : 32个文件
src/poetry/evaluators/*.ml   : 10个文件
总计                        : 42个文件

整合目标：8个核心文件
减少比例：81% (42 → 8)
```

## 📂 完整文件清单

### 主要artistic文件 (32个)
```
src/poetry/artistic_advanced_analysis.ml
src/poetry/artistic_analysis_engine.ml
src/poetry/artistic_core_evaluators.ml
src/poetry/artistic_core_types.ml
src/poetry/artistic_data_accessor.ml
src/poetry/artistic_data_loader.ml
src/poetry/artistic_data_parser.ml
src/poetry/artistic_data_registry.ml
src/poetry/artistic_evaluation.ml
src/poetry/artistic_evaluation_engine.ml
src/poetry/artistic_evaluators.ml
src/poetry/artistic_form_evaluators.ml
src/poetry/artistic_guidance.ml
src/poetry/artistic_legacy_compat.ml
src/poetry/artistic_query_engine.ml
src/poetry/artistic_soul_evaluation.ml
src/poetry/artistic_template_manager.ml
src/poetry/artistic_types.ml
src/poetry/poetry_artistic_core.ml
src/poetry/poetry_artistic_core_refactored.ml
src/poetry/poetry_artistic_engine.ml
src/poetry/poetry_artistic_standards.ml
```

### Evaluators目录文件 (10个)
```
src/poetry/evaluators/artistic_evaluation_engine.ml
src/poetry/evaluators/content_depth_evaluator.ml
src/poetry/evaluators/evaluator_types.ml
src/poetry/evaluators/form_beauty_evaluator.ml
src/poetry/evaluators/imagery_evaluator.ml
src/poetry/evaluators/mood_context_evaluator.ml
src/poetry/evaluators/overall_evaluator.ml
src/poetry/evaluators/parallelism_evaluator.ml
src/poetry/evaluators/rhyme_harmony_evaluator.ml
src/poetry/evaluators/tonal_balance_evaluator.ml
```

## 🎯 8个目标文件映射

### 1. artistic_engine_unified.ml
**整合源文件 (13个):**
- src/poetry/poetry_artistic_engine.ml (主引擎)
- src/poetry/artistic_evaluation_engine.ml (评估引擎)
- src/poetry/evaluators/artistic_evaluation_engine.ml (评估引擎副本)
- src/poetry/poetry_artistic_core.ml (核心逻辑)
- src/poetry/poetry_artistic_core_refactored.ml (重构版本)
- src/poetry/artistic_analysis_engine.ml (分析引擎)
- src/poetry/artistic_evaluation.ml (评估逻辑)
- src/poetry/artistic_advanced_analysis.ml (高级分析)
- src/poetry/artistic_query_engine.ml (查询引擎)
- src/poetry/evaluators/overall_evaluator.ml (整体评估器)
- src/poetry/artistic_soul_evaluation.ml (诗魂评估)
- src/poetry/poetry_artistic_standards.ml (艺术标准)
- src/poetry/artistic_guidance.ml (艺术指导)

### 2. artistic_evaluators.ml  
**整合源文件 (10个):**
- src/poetry/evaluators/form_beauty_evaluator.ml (形式美评估)
- src/poetry/evaluators/parallelism_evaluator.ml (对仗评估)
- src/poetry/evaluators/imagery_evaluator.ml (意象评估)
- src/poetry/evaluators/rhyme_harmony_evaluator.ml (韵律和谐)
- src/poetry/evaluators/content_depth_evaluator.ml (内容深度)
- src/poetry/evaluators/tonal_balance_evaluator.ml (声调平衡)
- src/poetry/evaluators/mood_context_evaluator.ml (意境评估)
- src/poetry/artistic_evaluators.ml (主评估器)
- src/poetry/artistic_core_evaluators.ml (核心评估器)
- src/poetry/artistic_form_evaluators.ml (形式评估器)

### 3. artistic_data_manager.ml
**整合源文件 (5个):**
- src/poetry/artistic_data_loader.ml (数据加载)
- src/poetry/artistic_data_accessor.ml (数据访问)
- src/poetry/artistic_data_parser.ml (数据解析)
- src/poetry/artistic_data_registry.ml (数据注册)
- src/poetry/artistic_template_manager.ml (模板管理)

### 4. artistic_standards.ml
**整合源文件 (3个):**
- src/poetry/poetry_artistic_standards.ml (诗词艺术标准)
- src/poetry/artistic_types.ml (艺术类型定义)
- src/poetry/evaluators/evaluator_types.ml (评估器类型)

### 5. artistic_cache.ml
**整合源文件 (2个):**
- 相关缓存逻辑从各个文件中提取
- 新建统一缓存管理功能

### 6. artistic_compatibility.ml
**整合源文件 (2个):**
- src/poetry/artistic_legacy_compat.ml (遗留兼容)
- 向后兼容接口定义

### 7. artistic_metrics.ml
**整合源文件 (4个):**
- 从各个evaluator中提取指标定义
- 统一的评估指标体系
- 性能监控和分析功能
- 评估结果统计功能

### 8. artistic_reporting.ml
**整合源文件 (3个):**
- 从各个文件中提取报告生成逻辑
- 统一的结果格式化功能
- 多种输出格式支持

## ⚠️ 关键算法保护清单

以下复杂算法**必须完整保留**，不得简化：

### 韵律评估算法
```ocaml
(* 来自 rhyme_harmony_evaluator.ml *)
let evaluate_rhyme_harmony poem =
  let rhyme_patterns = extract_rhyme_patterns poem in
  let harmony_score = calculate_harmony_score rhyme_patterns in
  let consistency_score = check_rhyme_consistency rhyme_patterns in
  combine_rhyme_scores harmony_score consistency_score
```

### 对仗评估算法
```ocaml
(* 来自 parallelism_evaluator.ml *)
let evaluate_parallelism lines =
  let syntactic_parallel = check_syntactic_parallelism lines in
  let semantic_parallel = check_semantic_parallelism lines in
  let tonal_parallel = check_tonal_parallelism lines in
  weighted_parallelism_score [syntactic_parallel; semantic_parallel; tonal_parallel]
```

### 意象深度分析
```ocaml
(* 来自 imagery_evaluator.ml *)
let analyze_imagery_depth poem =
  let images = extract_imagery poem in
  let depth_levels = categorize_imagery_depth images in
  let coherence = check_imagery_coherence images in
  calculate_imagery_score depth_levels coherence
```

## 🔄 实施步骤

### 步骤1: 功能提取与分析 (1天)
```bash
# 为每个源文件生成功能摘要
for file in $(cat consolidation_files.txt); do
    echo "=== 分析 $file ===" >> function_mapping.md
    grep -n "^let.*=\|^type.*=\|^module.*=" $file >> function_mapping.md
    echo "" >> function_mapping.md
done
```

### 步骤2: 目标文件创建 (2天)
- 按照映射表创建8个目标文件
- 迁移所有功能，保持算法复杂度
- 添加完整的文档和类型注解

### 步骤3: 验证与清理 (1天)  
- 构建和测试验证
- 删除42个源文件
- 更新全局import语句

## 📋 验收检查列表

- [ ] **文件数量**: 从42个减少到8个文件 (81%减少)
- [ ] **功能完整性**: 所有public接口在新文件中可用
- [ ] **算法保持**: 复杂诗词评估算法保持不变
- [ ] **性能维持**: 评估性能无回归
- [ ] **构建成功**: 整个项目成功编译
- [ ] **测试通过**: 所有现有测试继续通过
- [ ] **文档完整**: 每个目标文件包含完整文档
- [ ] **兼容性**: 提供向后兼容的API迁移路径

## 🚫 禁止操作

❌ **绝对不允许的操作:**
1. 创建新文件但保留旧文件（并行实现）
2. 将复杂算法简化为基础数学运算
3. 声称减少文件数量但实际增加文件
4. 忽略现有的42个文件，另起炉灶
5. 创建功能回归的"简化"版本

## 🎯 成功指标

```
整合成功 = 
  (42个源文件完全删除) 
  AND (8个目标文件包含所有功能)
  AND (所有测试通过)
  AND (构建无错误)
  AND (性能无回归)
```

---

**此文档提供Issue #2000的明确实施路径，确保正确的架构整合而非功能回归。**

Author: Foxtrot, Project Overseer  
Strategic Oversight for 骆言 Project