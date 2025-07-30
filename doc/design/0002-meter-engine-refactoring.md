# 格律引擎模块化重构设计 - Fix #1775

**Author: Alpha, 主要开发代理**  
**Date: 2025-07-30**  
**Issue: #1775 - 严重技术债务预警**  
**Priority: 🔴 极高**

## 🎯 重构目标

将 `src/poetry/analysis/meter_engine.ml` (587行) 拆分为多个职责明确的子模块，解决单一职责原则违反问题。

## 📊 当前问题分析

### 技术债务指标
- **文件行数**: 587行 (目标: <200行/模块)
- **函数数量**: 26个函数 (职责过多)
- **类型定义**: 4个主要类型 (可分离)
- **职责混合**: 模式定义、验证逻辑、缓存管理、格式化等

### 违反的设计原则
1. **单一职责原则**: 一个模块承担过多职责
2. **接口分离原则**: 没有清晰的抽象层级
3. **依赖倒置原则**: 硬编码诗体模式

## 🏗️ 模块化重构方案

### 新模块结构

```
src/poetry/analysis/
├── meter_core/
│   ├── meter_types.ml         # 核心类型定义 (~80行)
│   ├── poetry_forms.ml        # 诗体模式定义 (~120行)  
│   ├── meter_patterns.ml      # 格律模式管理 (~100行)
│   └── meter_cache.ml         # 缓存管理 (~60行)
├── meter_checkers/
│   ├── line_checker.ml        # 行数/字数检查 (~80行)
│   ├── rhyme_checker.ml       # 韵律检查 (~100行)
│   ├── tonal_checker.ml       # 平仄检查 (~80行)
│   └── parallelism_checker.ml # 对仗检查 (~70行)
├── meter_engine.ml            # 主引擎接口 (~150行)
└── meter_formatters.ml        # 格式化输出 (~60行)
```

### 职责分离详情

#### 1. `meter_core/meter_types.ml` - 核心类型定义
```ocaml
(** 所有格律相关的类型定义 *)
type poetry_form = ...
type meter_pattern = ...
type meter_check_result = ...
type form_recognition_result = ...
```

#### 2. `meter_core/poetry_forms.ml` - 诗体模式定义
```ocaml  
(** 预定义的诗体格律模式 *)
val wuyan_lushi_pattern : meter_pattern
val qiyan_lushi_pattern : meter_pattern
val wuyan_jueju_pattern : meter_pattern
val qiyan_jueju_pattern : meter_pattern
val guti_pattern : meter_pattern
```

#### 3. `meter_checkers/` - 专业检查器
每个检查器负责单一验证功能：
- **line_checker.ml**: 行数和字数验证
- **rhyme_checker.ml**: 韵律符合性检查
- **tonal_checker.ml**: 平仄模式验证  
- **parallelism_checker.ml**: 对仗要求检查

#### 4. `meter_engine.ml` - 统一接口
```ocaml
(** 主要API接口，协调各子模块 *)
val check_meter : string list -> meter_pattern -> meter_engine_state -> meter_check_result
val auto_check_meter : string list -> meter_engine_state -> meter_check_result
val recognize_poetry_form : string list -> meter_engine_state -> form_recognition_result
```

## 📋 实施计划

### Phase 1: 基础设施创建 (1-2天)
1. ✅ 创建新的目录结构
2. ✅ 提取核心类型定义到 `meter_types.ml`
3. ✅ 迁移诗体模式到 `poetry_forms.ml`
4. ✅ 确保编译通过

### Phase 2: 检查器模块化 (2-3天)  
1. ✅ 实现 `line_checker.ml`
2. ✅ 实现 `rhyme_checker.ml`
3. ✅ 实现 `tonal_checker.ml`
4. ✅ 实现 `parallelism_checker.ml`
5. ✅ 更新主引擎使用新检查器

### Phase 3: 接口优化和清理 (1天)
1. ✅ 优化 `meter_engine.ml` 接口
2. ✅ 实现 `meter_formatters.ml`
3. ✅ 清理缓存管理到 `meter_cache.ml`
4. ✅ 完整测试和性能验证

## 🔒 向后兼容性保证

### API保持策略
- 保持所有现有公共函数签名不变
- 现有调用代码无需修改
- 渐进式内部重构，外部接口稳定

### 测试策略
- 保持现有测试通过
- 添加各子模块单元测试
- 性能基准测试确保无回归

## 📈 预期收益

### 量化指标
- **行数减少**: 587行 → ~860行总计 (但分布在9个模块)
- **单模块行数**: 最大150行 (符合<200行目标)
- **可测试性**: 每个检查器独立测试
- **可维护性**: 单一职责，修改范围明确

### 质量提升
- ✅ 遵循单一职责原则
- ✅ 清晰的模块边界  
- ✅ 更好的代码复用
- ✅ 更容易的并行开发

## ⚠️ 风险控制

### 主要风险
1. **性能回归**: 模块化可能带来函数调用开销
2. **编译错误**: 依赖关系重构风险
3. **测试失败**: 逻辑迁移可能引入bug

### 缓解措施
1. **性能基准**: 重构前后对比测试
2. **渐进实施**: 每个模块独立验证
3. **完整测试**: 保持100%测试覆盖率
4. **回滚准备**: 保留原始代码备份

## 🎪 成功标准

### 代码质量标准
- [ ] 所有模块 < 200行
- [ ] 编译零警告 (不压制warn-error)
- [ ] 测试覆盖率保持 > 80%
- [ ] 性能回归 < 5%
- [ ] 循环复杂度 < 10

### 架构质量标准  
- [ ] 清晰的模块职责边界
- [ ] 最小化模块间依赖
- [ ] 统一的错误处理策略
- [ ] 完整的文档覆盖

---

**结论**: 此重构将显著改善代码结构，为后续开发奠定坚实基础。严格按照渐进式策略执行，确保稳定性和质量。