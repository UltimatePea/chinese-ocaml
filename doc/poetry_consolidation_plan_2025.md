# Poetry模块整合计划 - Issue #1999实施文档

Author: Whisky, PR Worker  
Date: 2025-08-02  
Target: 将Poetry模块从336个文件整合为15个核心文件，实现30%查询速度提升和20%编译时间减少

## 当前模块结构分析

通过分析发现Poetry模块包含336个.ml/.mli文件，分布在以下目录结构中：

### 主要功能模块分类

1. **韵律数据模块** (100+ 文件)
   - rhyme_data/, rhyme_groups/, data/等目录
   - 包含各种韵部数据，如风韵、花韵、语韵等

2. **艺术评价模块** (80+ 文件)  
   - artistic_* 系列文件
   - 诗词艺术性评价和分析引擎

3. **核心类型模块** (50+ 文件)
   - types, core等相关文件
   - 基础数据类型定义

4. **缓存管理模块** (30+ 文件)
   - cache_management/ 目录
   - 性能优化相关

5. **查询引擎模块** (40+ 文件)
   - query, engine相关文件
   - 韵律查询和匹配

6. **数据加载模块** (30+ 文件)
   - loader, parser相关文件
   - JSON数据解析和加载

## 15个核心文件整合计划

### 1. poetry_core.ml/.mli
**整合目标**: 核心类型和基础API
**来源文件**: poetry_types_*.ml, core/types.ml, poetry_recommended_api.ml等

### 2. poetry_rhyme_engine.ml/.mli  
**整合目标**: 韵律匹配和查询引擎
**来源文件**: rhyme_query_engine.ml, rhyme_matching.ml, unified_rhyme_engine.ml等

### 3. poetry_data_unified.ml/.mli
**整合目标**: 统一的韵律数据访问接口
**来源文件**: 所有rhyme_data目录文件，unified_rhyme_data.ml等

### 4. poetry_artistic_engine.ml/.mli
**整合目标**: 诗词艺术性评价引擎
**来源文件**: artistic_*系列文件，evaluation_framework.ml等

### 5. poetry_cache_manager.ml/.mli
**整合目标**: 统一缓存管理
**来源文件**: cache_management/下所有文件，data_cache_manager.ml等

### 6. poetry_forms_analyzer.ml/.mli
**整合目标**: 诗词格律分析
**来源文件**: analysis/目录下文件，form_evaluators.ml等

### 7. poetry_tone_analyzer.ml/.mli
**整合目标**: 声调模式分析
**来源文件**: tone_data.ml, tone_pattern.ml, tonal_*相关文件

### 8. poetry_data_loader.ml/.mli
**整合目标**: 数据加载和解析
**来源文件**: data/目录下loader文件，json_parser相关文件

### 9. poetry_query_api.ml/.mli
**整合目标**: 统一查询接口
**来源文件**: query相关文件，lookup文件

### 10. poetry_validation.ml/.mli
**整合目标**: 数据验证和错误处理
**来源文件**: validation相关文件，error处理文件

### 11. poetry_performance.ml/.mli
**整合目标**: 性能监控和优化
**来源文件**: parallelism_analysis.ml, benchmark相关文件

### 12. poetry_helpers.ml/.mli
**整合目标**: 工具函数集合
**来源文件**: *_helpers.ml, *_utils.ml文件

### 13. poetry_compat.ml/.mli
**整合目标**: 向后兼容层
**来源文件**: *_compat.ml, legacy相关文件

### 14. poetry_standards.ml/.mli
**整合目标**: 诗词标准和规范
**来源文件**: poetry_standards.ml, poetry_forms相关文件

### 15. poetry_unified_api.ml/.mli
**整合目标**: 对外统一API接口
**来源文件**: 各模块的对外接口整合

## 性能优化策略

1. **查询优化**: 使用Hash表替代线性搜索，预计30%速度提升
2. **编译优化**: 减少模块依赖，简化编译图，预计20%编译时间减少
3. **内存优化**: 统一缓存策略，减少重复数据加载

## 向后兼容保证

- 保留所有现有公共API
- 使用Module别名维护旧模块名
- 添加deprecated警告但不破坏现有代码

## 实施阶段

1. **Phase 1**: 创建15个核心文件框架
2. **Phase 2**: 逐步迁移功能代码
3. **Phase 3**: 性能测试和优化
4. **Phase 4**: 向后兼容性验证

## 质量保证

- 所有现有测试必须通过
- 新增性能基准测试
- 代码审查和文档更新