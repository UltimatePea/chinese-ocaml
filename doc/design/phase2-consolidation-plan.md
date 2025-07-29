# Poetry模块整合 Phase 2: 技术实施计划

## 项目概述

**Author: Beta, 代码审查专员**  
**任务**: 响应 Issue #1732 - Phase 2 数据加载器统一化  
**目标**: 继续减少技术债务，将剩余数据加载器迁移到unified_data_loader核心

## 当前分析结果

### 文件统计
- 实际文件数量: 271个 ML/MLI 文件 (而非issue中提及的85个)
- 重点整合目标文件已识别

### 待整合的数据加载器
1. `externalized_data_loader.ml/mli` - 词类数据加载器
2. `poetry_data_loader.ml/mli` - 诗词数据加载器  
3. `rhyme_data_loader.ml/mli` - 韵律数据加载器
4. `tone_data_loader.ml/mli` - 声调数据加载器

### 待整合的管理器模块
1. `data/cache_manager.ml/mli` 
2. `data/managers/cache_manager.ml`
3. `data/data_manager.ml` 和 `data_manager_refactored.ml`
4. `data/data_source_manager.ml/mli`

## Phase 2 实施策略

### Phase 2.1: 数据加载器迁移到unified_data_loader

#### 步骤1: 扩展unified_data_loader接口
- 添加对词类数据的支持
- 确保向后兼容性
- 扩展错误处理机制

#### 步骤2: 迁移externalized_data_loader功能
- 将词类数据加载逻辑迁移到unified系统
- 保持现有API接口不变（兼容性层）
- 测试验证

#### 步骤3: 迁移其他专用加载器
- poetry_data_loader → unified_data_loader
- rhyme_data_loader → unified_data_loader  
- tone_data_loader → unified_data_loader

### Phase 2.2: 管理器模块整合

#### 目标架构
创建统一的 `unified_data_management.ml/mli`:
- 整合缓存管理功能
- 整合数据源管理
- 统一错误处理和日志

#### 迁移策略
- 保持现有接口向后兼容
- 渐进式迁移，每个管理器独立处理
- 完整测试覆盖

## 风险控制

### 兼容性保证
- 所有现有API保持向后兼容
- 创建适配器层而不是直接删除旧接口
- 渐进式迁移，避免破坏性变更

### 测试策略
- 每个模块迁移后立即进行回归测试
- 保持现有测试用例通过
- 添加新的集成测试

### 回滚机制
- 保留原始文件作为备份
- 每个阶段独立提交，便于回滚
- CI检查确保每步都是稳定的

## 预期成果

### 短期目标 (Phase 2.1)
- 统一的数据加载入口点
- 减少重复的错误处理代码
- 简化的调试和维护

### 中期目标 (Phase 2.2)  
- 统一的数据管理层
- 减少管理器代码重复
- 更清晰的架构分层

### 长期收益
- 显著减少技术债务
- 提高代码可维护性
- 统一的错误处理和缓存策略
- 更容易的新功能扩展

## 下一步行动

1. 开始 Phase 2.1 - 数据加载器迁移
2. 首先处理 externalized_data_loader
3. 逐步处理其他数据加载器
4. 进行 Phase 2.2 - 管理器整合

---

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>