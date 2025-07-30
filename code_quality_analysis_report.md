# 骆言项目代码质量分析报告
分析时间: 2025-07-30 16:22:09

## 1. 超长函数分析（超过50行）
- **init_tables** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_converter_unified.ml:114-209)
  - 长度: 96行
  - 建议: 考虑拆分为多个小函数

- **default_converters** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_conversion_unified.ml:32-118)
  - 长度: 87行
  - 建议: 考虑拆分为多个小函数

- **convert_classical_token** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/conversion_lexer.ml:142-220)
  - 长度: 79行
  - 建议: 考虑拆分为多个小函数

- **default_imagery_keywords** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_data_loader.ml:102-169)
  - 长度: 68行
  - 建议: 考虑拆分为多个小函数

- **default_imagery_keywords** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_data_unified.ml:110-177)
  - 长度: 68行
  - 建议: 考虑拆分为多个小函数

- **default_converter_configs** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/core/unified_converter.ml:381-447)
  - 长度: 67行
  - 建议: 考虑拆分为多个小函数

- **errors** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/cache_manager.ml:384-445)
  - 长度: 62行
  - 建议: 考虑拆分为多个小函数

- **keyword_mappings** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/core/unified_converter.ml:153-213)
  - 长度: 61行
  - 建议: 考虑拆分为多个小函数

- **registry** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/core/token_registry.ml:114-168)
  - 长度: 55行
  - 建议: 考虑拆分为多个小函数

- **to_string** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer/tokens/wenyan_keywords.ml:58-111)
  - 长度: 54行
  - 建议: 考虑拆分为多个小函数


## 2. 模块组织问题
- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/value_advanced_ops.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/error_messages.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/semantic_errors.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/conversion_modern.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/conversion_engine.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/compiler.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_token_reducer.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/keyword_matcher.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/builtin_shared_utils.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_conversion_keywords_refactored.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/conversion_lexer.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/value_operations_advanced.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/logging_migration.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/refactoring_analyzer_naming.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_consolidated.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/chinese_best_practices.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/refactoring_analyzer_duplication.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_utils.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/refactoring_analyzer_complexity.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/unicode/unicode_constants_optimized.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/unicode/unicode_mapping.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/performance/benchmark_regression.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/performance/benchmark_memory.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/performance/benchmark_config.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/performance/benchmark_timer.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/utils/conversion_utils.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/utils/rhyme_data_utils.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/utils/token_processing_utils.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_evaluators.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_types.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_scoring.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/parallelism_analysis.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_json_unified.ml)
  - 详情: 建议将类型定义放在文件开头

- **缺少接口文件且函数过多** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_artistic_core_refactored.ml)
  - 详情: 包含29个let绑定但没有.mli文件

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_pattern.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_core.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/tone_pattern.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_database.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_engine.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/config/config_loader.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer/token_mapping/unified_token_mapper.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/core/unified_converter.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/mapping/operator_mapping.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/mapping/keyword_mapping.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/compatibility/legacy_bridge.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/utils/formatting/error_formatter.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/parallelism_checker.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/artistic_evaluator.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/unified_poetry_engine.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/poetry_errors.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/poetry_utils.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_analysis.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/unified_data_loader_extended.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/loaders/unified_loader.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/tone_data/unified_tone_data.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/managers/query_manager.ml)
  - 详情: 建议将类型定义放在文件开头

- **类型定义和函数定义混合** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/managers/source_manager.ml)
  - 详情: 建议将类型定义放在文件开头


## 3. 重复代码模式
- 重复模式出现在 2 个文件中:
  - /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/value_basic_ops.ml
  - /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/value_operations_conversion.ml

- 重复模式出现在 2 个文件中:
  - /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_core.ml
  - /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_utils.ml

- 重复模式出现在 2 个文件中:
  - /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_core.ml
  - /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_utils.ml

- 重复模式出现在 2 个文件中:
  - /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_core.ml
  - /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_utils.ml

- 重复模式出现在 2 个文件中:
  - /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_core.ml
  - /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_utils.ml


## 4. 诗词编程模块分析
- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_poetry.ml)
  - 详情: 在诗词相关模块中发现22个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/formatter_poetry.ml)
  - 详情: 在诗词相关模块中发现43个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/performance/benchmark_poetry.ml)
  - 详情: 在诗词相关模块中发现13个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/utils/rhyme_data_utils.ml)
  - 详情: 在诗词相关模块中发现24个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_evaluators.ml)
  - 详情: 在诗词相关模块中发现31个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_forms_evaluation.ml)
  - 详情: 在诗词相关模块中发现6个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_standards.ml)
  - 详情: 在诗词相关模块中发现13个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_guidance.ml)
  - 详情: 在诗词相关模块中发现27个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_types.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_utils.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_utils.ml)
  - 详情: 在诗词相关模块中发现7个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_scoring.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_scoring.ml)
  - 详情: 在诗词相关模块中发现46个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_types_consolidated.ml)
  - 详情: 在诗词相关模块中发现17个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_api_core.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_api_core.ml)
  - 详情: 在诗词相关模块中发现8个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_lookup.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_lookup.ml)
  - 详情: 在诗词相关模块中发现21个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_helpers.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_artistic_standards.ml)
  - 详情: 在诗词相关模块中发现10个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_form_evaluators.ml)
  - 详情: 在诗词相关模块中发现27个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/parallelism_analysis.ml)
  - 详情: 在诗词相关模块中发现41个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_engine.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_engine.ml)
  - 详情: 在诗词相关模块中发现20个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_analysis_engine.ml)
  - 详情: 在诗词相关模块中发现13个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_matching.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_validation.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_data_accessor.ml)
  - 详情: 在诗词相关模块中发现59个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_group_helpers.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_analysis_utils.ml)
  - 详情: 在诗词相关模块中发现7个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_json_unified.ml)
  - 详情: 在诗词相关模块中发现6个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_artistic_core_refactored.ml)
  - 详情: 在诗词相关模块中发现29个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_data_parser.ml)
  - 详情: 在诗词相关模块中发现27个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_form_evaluators.ml)
  - 详情: 在诗词相关模块中发现18个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/form_evaluators.ml)
  - 详情: 在诗词相关模块中发现50个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_types.ml)
  - 详情: 在诗词相关模块中发现17个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_soul_evaluation.ml)
  - 详情: 在诗词相关模块中发现67个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_core_fixed.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_core_fixed.ml)
  - 详情: 在诗词相关模块中发现19个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_evaluation_engine.ml)
  - 详情: 在诗词相关模块中发现52个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_evaluation_engine.ml)
  - 详情: 在诗词相关模块中发现9个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_core_types.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_cache.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_pattern.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_pattern.ml)
  - 详情: 在诗词相关模块中发现30个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_data_engine.ml)
  - 详情: 在诗词相关模块中发现34个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_core.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_core.ml)
  - 详情: 在诗词相关模块中发现54个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_query_engine.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_data.ml)
  - 详情: 在诗词相关模块中发现10个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_recommended_api.ml)
  - 详情: 在诗词相关模块中发现9个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_data_loader.ml)
  - 详情: 在诗词相关模块中发现17个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_core.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_json_core.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_json_core.ml)
  - 详情: 在诗词相关模块中发现11个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/tone_pattern.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/tone_pattern.ml)
  - 详情: 在诗词相关模块中发现24个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_data_unified.ml)
  - 详情: 在诗词相关模块中发现33个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_data_registry.ml)
  - 详情: 在诗词相关模块中发现8个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_group_manager.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_group_manager.ml)
  - 详情: 在诗词相关模块中发现12个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_advanced_analysis.ml)
  - 详情: 在诗词相关模块中发现21个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_core_unified.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_core_unified.ml)
  - 详情: 在诗词相关模块中发现19个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_json_unified.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_json_unified.ml)
  - 详情: 在诗词相关模块中发现29个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_artistic_engine.ml)
  - 详情: 在诗词相关模块中发现42个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_evaluation.ml)
  - 详情: 在诗词相关模块中发现17个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_database.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_database.ml)
  - 详情: 在诗词相关模块中发现7个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_core_consolidated.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_core_consolidated.ml)
  - 详情: 在诗词相关模块中发现25个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_core_evaluators.ml)
  - 详情: 在诗词相关模块中发现56个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_unified.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_unified.ml)
  - 详情: 在诗词相关模块中发现11个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/tone_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/tone_data.ml)
  - 详情: 在诗词相关模块中发现9个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_engine.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_engine.ml)
  - 详情: 在诗词相关模块中发现42个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/consolidated_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/consolidated_rhyme_data.ml)
  - 详情: 在诗词相关模块中发现17个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_data_consolidated.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_data_consolidated.ml)
  - 详情: 在诗词相关模块中发现26个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_data_accessor.ml)
  - 详情: 在诗词相关模块中发现36个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_json_types.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_query_engine.ml)
  - 详情: 在诗词相关模块中发现18个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_groups_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_rhyme_groups_data.ml)
  - 详情: 在诗词相关模块中发现18个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_artistic_core.ml)
  - 详情: 在诗词相关模块中发现29个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_data.ml)
  - 详情: 在诗词相关模块中发现36个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer/tokens/poetry_keywords.ml)
  - 详情: 在诗词相关模块中发现6个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/rhythm_analyzer.ml)
  - 详情: 在诗词相关模块中发现42个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/tonal_checker.ml)
  - 详情: 在诗词相关模块中发现18个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/line_checker.ml)
  - 详情: 在诗词相关模块中发现16个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/rhyme_checker.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/rhyme_checker.ml)
  - 详情: 在诗词相关模块中发现21个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/parallelism_checker.ml)
  - 详情: 在诗词相关模块中发现31个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/artistic_evaluator.ml)
  - 详情: 在诗词相关模块中发现66个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/meter_engine.ml)
  - 详情: 在诗词相关模块中发现37个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/poetry_forms.ml)
  - 详情: 在诗词相关模块中发现9个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/unified_poetry_engine.ml)
  - 详情: 在诗词相关模块中发现48个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/cache_management/cache_storage.ml)
  - 详情: 在诗词相关模块中发现12个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/cache_management/cache_strategy.ml)
  - 详情: 在诗词相关模块中发现11个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/cache_management/cache_utils.ml)
  - 详情: 在诗词相关模块中发现7个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/cache_management/cache_advanced_ops.ml)
  - 详情: 在诗词相关模块中发现12个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/cache_management/cache_manager_registry.ml)
  - 详情: 在诗词相关模块中发现44个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/cache_management/cache_batch_ops.ml)
  - 详情: 在诗词相关模块中发现7个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/tian_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/yue_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/qu_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/wang_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/feng_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/rhyme_data_registry.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/rhyme_data_registry.ml)
  - 详情: 在诗词相关模块中发现29个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/hui_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/si_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/yu_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/jiang_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/an_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/hua_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_data/rhyme_data_core.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_helpers.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/types.ml)
  - 详情: 在诗词相关模块中发现9个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_api.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_api.ml)
  - 详情: 在诗词相关模块中发现34个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_types.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_types.ml)
  - 详情: 在诗词相关模块中发现10个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/poetry_errors.ml)
  - 详情: 在诗词相关模块中发现6个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_data.ml)
  - 详情: 在诗词相关模块中发现14个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_data_modular.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_data_modular.ml)
  - 详情: 在诗词相关模块中发现8个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/json_core.ml)
  - 详情: 在诗词相关模块中发现53个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/poetry_utils.ml)
  - 详情: 在诗词相关模块中发现45个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/unified_data_loader_comprehensive.ml)
  - 详情: 在诗词相关模块中发现58个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/poetry_word_class_loader.ml)
  - 详情: 在诗词相关模块中发现74个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/expanded_word_class_data.ml)
  - 详情: 在诗词相关模块中发现67个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/poetry_data_fallback.ml)
  - 详情: 在诗词相关模块中发现8个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/data_manager_lookup.ml)
  - 详情: 在诗词相关模块中发现10个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_data_management.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_data_management.ml)
  - 详情: 在诗词相关模块中发现32个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_data_loader.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_query_engine.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_query_engine.ml)
  - 详情: 在诗词相关模块中发现14个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/tone_data_loader.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/tone_data_loader.ml)
  - 详情: 在诗词相关模块中发现17个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_analysis.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_analysis.ml)
  - 详情: 在诗词相关模块中发现24个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/data_source_manager.ml)
  - 详情: 在诗词相关模块中发现9个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/cache_manager.ml)
  - 详情: 在诗词相关模块中发现47个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_data_unified.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_data_unified.ml)
  - 详情: 在诗词相关模块中发现30个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/expanded_data_loader.ml)
  - 详情: 在诗词相关模块中发现22个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/json_parser.ml)
  - 详情: 在诗词相关模块中发现19个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/poetry_data_loader_compat.ml)
  - 详情: 在诗词相关模块中发现25个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_data_core.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_data_core.ml)
  - 详情: 在诗词相关模块中发现17个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/data_manager_query.ml)
  - 详情: 在诗词相关模块中发现10个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/data_manager.ml)
  - 详情: 在诗词相关模块中发现15个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/unified_data_loader_extended.ml)
  - 详情: 在诗词相关模块中发现22个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/poetry_data_loader.ml)
  - 详情: 在诗词相关模块中发现23个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/evaluators/rhyme_harmony_evaluator.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/evaluators/rhyme_harmony_evaluator.ml)
  - 详情: 在诗词相关模块中发现25个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/evaluators/overall_evaluator.ml)
  - 详情: 在诗词相关模块中发现8个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/evaluators/artistic_evaluation_engine.ml)
  - 详情: 在诗词相关模块中发现20个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/evaluators/mood_context_evaluator.ml)
  - 详情: 在诗词相关模块中发现9个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/evaluators/tonal_balance_evaluator.ml)
  - 详情: 在诗词相关模块中发现8个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/evaluators/imagery_evaluator.ml)
  - 详情: 在诗词相关模块中发现9个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/evaluators/content_depth_evaluator.ml)
  - 详情: 在诗词相关模块中发现9个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/evaluators/parallelism_evaluator.ml)
  - 详情: 在诗词相关模块中发现11个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/evaluators/form_beauty_evaluator.ml)
  - 详情: 在诗词相关模块中发现10个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/ze_sheng_hua_rhyme.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/ze_sheng_hui_rhyme.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/ping_sheng_qu_rhyme.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/ping_sheng_wang_rhyme.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/ze_sheng_feng_rhyme.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/ping_sheng_tian_rhyme.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/ze_sheng_jiang_rhyme.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/unified_rhyme_groups_data_refactored.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/unified_rhyme_groups_data_refactored.ml)
  - 详情: 在诗词相关模块中发现33个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/ze_sheng_yue_rhyme.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/ping_sheng_si_rhyme.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/rhyme_data_registry.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/rhyme_data_registry.ml)
  - 详情: 在诗词相关模块中发现10个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/ze_sheng_yu_rhyme.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_groups/ping_sheng_an_rhyme.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/core/rhyme_data_engine.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/core/rhyme_data_engine.ml)
  - 详情: 在诗词相关模块中发现13个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/unified_rhyme_database.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/unified_rhyme_database.ml)
  - 详情: 在诗词相关模块中发现19个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/yu_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/yu_rhyme_data.ml)
  - 详情: 在诗词相关模块中发现22个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/hua_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/hua_rhyme_data.ml)
  - 详情: 在诗词相关模块中发现16个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/rhyme_group_types.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/loaders/json_loader.ml)
  - 详情: 在诗词相关模块中发现11个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/loaders/unified_loader.ml)
  - 详情: 在诗词相关模块中发现22个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/tone_data/tone_data_json_loader.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/tone_data/tone_data_json_loader.ml)
  - 详情: 在诗词相关模块中发现25个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/tone_data/unified_tone_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/tone_data/unified_tone_data.ml)
  - 详情: 在诗词相关模块中发现17个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/managers/query_manager.ml)
  - 详情: 在诗词相关模块中发现17个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/managers/cache_manager.ml)
  - 详情: 在诗词相关模块中发现14个英文函数名

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/managers/source_manager.ml)
  - 详情: 在诗词相关模块中发现18个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/ping_sheng/feng_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/ping_sheng/feng_rhyme_data.ml)
  - 详情: 在诗词相关模块中发现23个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/ze_sheng/yue_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/ze_sheng/yue_rhyme_data.ml)
  - 详情: 在诗词相关模块中发现10个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/ze_sheng/hui_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/ze_sheng/hui_rhyme_data.ml)
  - 详情: 在诗词相关模块中发现28个英文函数名

- **缺少中文注释** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/ze_sheng/jiang_rhyme_data.ml)
  - 详情: 诗词相关模块应该有详细的中文注释说明

- **中文语境中使用过多英文标识符** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/ze_sheng/jiang_rhyme_data.ml)
  - 详情: 在诗词相关模块中发现10个英文函数名


## 5. 文档缺失分析
- **复杂函数rhyme_weight缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_types_consolidated.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数is_valid_score缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_types_consolidated.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数parse_char_info_from_json缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_data_accessor.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数analyze_poem_rhyme_scheme缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_data_accessor.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数parse_word_info_from_json缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_data_parser.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数parse_evaluation_standards_from_json缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_data_parser.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数parse_artistic_templates_from_json缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_data_parser.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数preload_category缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_data_engine.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数diagnose_source缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/unified_data_engine.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数analyze_poem_rhyme缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_core.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数initialize缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_data_registry.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数suggest_template_for_context缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_template_manager.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数default_imagery_words缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_legacy_compat.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数to_string缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer/tokens/poetry_keywords.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数from_string缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer/tokens/poetry_keywords.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数format_comprehensive_evaluation缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/analysis/artistic_evaluator.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数tian_yun_ping_sheng_chars缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_data.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数load_ze_sheng_rhymes_comprehensive缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/unified_data_loader_comprehensive.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数load_all_data_types缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/unified_data_loader_comprehensive.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数export_rhyme_data缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_data_management.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数check_source_health缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_data_management.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数get缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/data_manager_query.ml)
  - 详情: 诗词分析函数应该有详细的中文说明

- **复杂函数export_evaluation_json缺少文档** (/home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/evaluators/artistic_evaluation_engine.ml)
  - 详情: 诗词分析函数应该有详细的中文说明


## 6. 总体改进建议

### 优先级1 - 立即修复
- 重构超长函数，提高代码可读性
- 为诗词相关模块添加详细的中文注释

### 优先级2 - 近期改进
- 完善模块接口文件(.mli)
- 补充缺失的函数和模块文档

### 优先级3 - 长期优化
- 考虑提取诗词数据到外部配置文件
- 增强诗词编程特性的艺术表现力
- 实现更智能的中文语言处理