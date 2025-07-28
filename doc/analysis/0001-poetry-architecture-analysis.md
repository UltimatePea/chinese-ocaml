# Poetry模块架构分析报告

**分析时间**: Mon Jul 28 06:44:47 EDT 2025
**总文件数**: 102

## 模块分类统计

### poetry_evaluation (5个模块)
- formatter_poetry
- poetry_evaluation_engine
- poetry_form_dispatch
- poetry_form_evaluators
- poetry_forms_evaluation

### poetry_misc (13个模块)
- benchmark_poetry
- parser_poetry
- poetry_analysis_utils
- poetry_core_types
- poetry_file_reader
- poetry_json_parser
- poetry_json_unified
- poetry_keywords
- poetry_recommended_api
- poetry_standards
- poetry_tokens
- poetry_types_consolidated
- unified_poetry_engine

### artistic_evaluation (6个模块)
- artistic_core_evaluators
- artistic_evaluation
- artistic_evaluator
- artistic_evaluators
- artistic_form_evaluators
- artistic_soul_evaluation

### artistic_misc (11个模块)
- artistic_advanced_analysis
- artistic_guidance
- artistic_types
- poetry_artistic_core
- poetry_artistic_core
- poetry_artistic_core_refactored
- poetry_artistic_core_refactored
- poetry_artistic_engine
- poetry_artistic_engine
- poetry_artistic_standards
- poetry_artistic_standards

### artistic_data (1个模块)
- artistic_data_loader

### rhyme_data (16个模块)
- consolidated_rhyme_data
- expanded_rhyme_data
- feng_rhyme_data
- hua_rhyme_data
- hui_rhyme_data
- jiang_rhyme_data
- poetry_rhyme_data
- poetry_rhyme_data
- rhyme_data_engine
- rhyme_data_loader
- rhyme_data_utils
- rhyme_database
- unified_rhyme_data
- unified_rhyme_database
- yu_rhyme_data
- yue_rhyme_data

### rhyme_core (10个模块)
- poetry_rhyme_core
- poetry_rhyme_core
- rhyme_api_core
- rhyme_core_api
- rhyme_core_data
- rhyme_core_data_modular
- rhyme_core_types
- rhyme_core_unified
- unified_rhyme_api
- unified_rhyme_core

### rhyme_misc (27个模块)
- poetry_rhyme_engine
- poetry_rhyme_engine
- rhyme_cache
- rhyme_group_an
- rhyme_group_feng
- rhyme_group_hua
- rhyme_group_hui
- rhyme_group_jiang
- rhyme_group_qu
- rhyme_group_si
- rhyme_group_tian
- rhyme_group_types
- rhyme_group_wang
- rhyme_group_yu
- rhyme_group_yue
- rhyme_groups_registry
- rhyme_helpers
- rhyme_helpers
- rhyme_lookup
- rhyme_matching
- rhyme_pattern
- rhyme_scoring
- rhyme_types
- rhyme_types
- rhyme_utils
- rhyme_validation
- unified_rhyme_registry

### poetry_data (4个模块)
- poetry_data_fallback
- poetry_data_loader
- poetry_data_loader
- poetry_word_class_loader

### rhyme_json (9个模块)
- rhyme_json_access
- rhyme_json_api
- rhyme_json_cache
- rhyme_json_core
- rhyme_json_io
- rhyme_json_loader
- rhyme_json_parser
- rhyme_json_types
- rhyme_json_unified

## 识别的架构问题

🚨 **excessive_modules** (严重程度: high)
- 分类: poetry_misc
- 模块数量: 13

⚠️ **excessive_modules** (严重程度: medium)
- 分类: artistic_misc
- 模块数量: 11

🚨 **excessive_modules** (严重程度: high)
- 分类: rhyme_data
- 模块数量: 16

⚠️ **excessive_modules** (严重程度: medium)
- 分类: rhyme_core
- 模块数量: 10

🚨 **excessive_modules** (严重程度: high)
- 分类: rhyme_misc
- 模块数量: 27

⚠️ **excessive_modules** (严重程度: medium)
- 分类: rhyme_json
- 模块数量: 9

⚠️ **high_coupling** (严重程度: medium)

## 推荐重构计划

### Phase 1: 核心类型系统重构
统一核心类型定义，消除类型重复

**行动项:**
- 合并 poetry_core_types, rhyme_types, artistic_types
- 建立统一的错误处理类型
- 定义清晰的模块接口

**影响模块数量**: 18

### Phase 2: 数据访问层统一
消除多个data loader，建立统一数据访问

**行动项:**
- 合并所有 *_data_loader 模块
- 实现统一的缓存策略
- 建立数据源抽象层

**影响模块数量**: 22

### Phase 3: API层重构
统一韵律和艺术性分析API

**行动项:**
- 建立统一的韵律分析API
- 建立统一的艺术性评价API
- 移除重复的JSON处理模块

**影响模块数量**: 15

